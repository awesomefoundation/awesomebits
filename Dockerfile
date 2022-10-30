FROM ruby:2.7.6-alpine

RUN apk update && \
    apk upgrade && \
    apk add --no-cache linux-headers libxml2-dev make gcc libc-dev libc6-compat nodejs tzdata postgresql-dev postgresql && \
    apk add --virtual build-packages --no-cache build-base curl-dev

WORKDIR /app
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN bundle install
ADD . /app

CMD ["/app/docker-runapp.sh"]
