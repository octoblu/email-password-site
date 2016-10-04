FROM nginx
MAINTAINER Octoblu <docker@octoblu.com>

HEALTHCHECK CMD curl --fail http://localhost:80/healthcheck || exit 1

EXPOSE 80

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      wget \
      && rm -rf /var/lib/apt/lists/*

COPY package.json .

RUN cat package.json \
  | grep version \
  | head -1 \
  | awk -F: '{ print $2 }' \
  | sed 's/[",]//g' \
  | tr -d '[[:space:]]' > .PKG_VERSION

COPY public/ public/ 
COPY public/ /usr/share/nginx/bundled/
COPY scripts/ scripts/
COPY templates/ templates/ 

RUN ./scripts/rewrite-files.sh "https://login-static.octoblu.com/v$(cat .PKG_VERSION)" '/public' '/usr/share/nginx/html'
  
RUN sed -e \
  "s/PKG_VERSION/$(cat .PKG_VERSION)/" \
  /templates/default.template > \
  /templates/default.conf

RUN sed -e \
  "s/PKG_VERSION/$(cat .PKG_VERSION)/" \
  /templates/bundled-default.template > \
  /templates/bundled-default.conf

CMD [ "./scripts/run-nginx.sh" ]
