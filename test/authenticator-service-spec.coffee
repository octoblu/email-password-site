describe 'AuthenticatorService', ->
  beforeEach ->
    module 'email-password', ($provide) =>
      @http = post: sinon.stub()
      $provide.value '$http', @http
      return

    inject ($q, $rootScope, AuthenticatorService) =>
      @q = $q
      @rootScope = $rootScope
      @sut = AuthenticatorService

  describe '->authenticate', ->
    describe 'when called with a email, password, and a callbackUrl', ->
      beforeEach ->
        headers  = {Location: 'whatevs.co'}
        response = headers: (key) => headers[key] # WTF, angular?

        @http.post.returns @q.when(response)
        @sut.authenticate 'sliced@diced.net', 'one-easy-payment', 'laptop.com'
        @rootScope.$digest()

      it 'should call POST /sessions', ->
        url = 'https://email-password.octoblu.com/sessions'
        params =
          email: 'sliced@diced.net'
          password: 'one-easy-payment'
          callbackUrl: 'laptop.com'

        expect(@http.post).to.have.been.calledWith url, params

    describe 'when called and meshblu rejects the email & password', ->
      beforeEach (done) ->
        @http.post.returns @q.reject(data: 'Bad email & password')
        @sut.authenticate 'sliced@diced.net', 'one-easy-payment', 'laptop.com'
            .catch (@error) => done()
        @rootScope.$digest()

      it 'should reject the authenticate promise', ->
        expect(@error).to.equal 'Bad email & password'

    describe 'when called and meshblu resolves with the location', ->
      beforeEach (done) ->
        headers  = {Location: 'google.com?some-other=stuff'}
        response = headers: (key) => headers[key] # WTF, angular?

        @http.post.returns @q.when(response)
        @sut.authenticate 'sliced@diced.net', 'one-easy-payment', 'google.com'
            .then (@result) => done()
        @rootScope.$digest()

      it 'should return the Location url', ->
        expect(@result).to.deep.equal 'google.com?some-other=stuff'

  describe '->register', ->
    describe 'when called', ->
      beforeEach ->
        @http.post.returns @q.when({})
        @sut.register 'taft@president.org', 'bathtub'
        @rootScope.$digest()

      it 'should post to signup.octoblu.com with the email and password', ->
        url = 'https://email-password.octoblu.com/devices'
        params =
          email: 'taft@president.org'
          password: 'bathtub'
        expect(@http.post).to.have.been.calledWith url, params

    describe 'when called and the service rejects', ->
      beforeEach (done) ->
        @http.post.returns @q.reject({data: 'you done screwed up'})
        @sut.register 'complicated', 'dolphin'
            .then (@errorMessage) => done()
        @rootScope.$digest()

      it 'should reject the promise and return the error', ->
        expect(@errorMessage).to.equal 'you done screwed up'
