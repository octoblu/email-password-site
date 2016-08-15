FROM nginx
MAINTAINER Octoblu <docker@octoblu.com>

COPY package.json .

RUN cat package.json \
      | grep version \
      | head -1 \
      | awk -F: '{ print $2 }' \
      | sed 's/[",]//g' \
      | tr -d '[[:space:]]' > .PKG_VERSION

COPY public/ public/ 
COPY scripts/ scripts/
COPY templates/ templates/ 

RUN ./scripts/rewrite-files.sh "https://login-static.octoblu.com/v$(cat .PKG_VERSION)" '/public' '/usr/share/nginx/html'

RUN sed -e \
  "s/PKG_VERSION/$(cat .PKG_VERSION)/" \
  /templates/default.template > \
  /etc/nginx/conf.d/default.conf

RUN cp /templates/*.conf /etc/nginx/conf.d/
