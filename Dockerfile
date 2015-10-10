FROM ruby:2.1

RUN apt-get update -qq \
  && apt-get install -y build-essential libpq-dev libqtwebkit-dev qt4-qmake

WORKDIR /app
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN bundle install
ADD . /app

ENTRYPOINT ["/app/docker-entrypoint.sh"]