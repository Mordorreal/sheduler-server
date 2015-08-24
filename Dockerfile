FROM ruby:2.2.2

RUN apt-get update -qq && apt-get install -y build-essential

RUN apt-get install -y libpq-dev
RUN apt-get install -y libxml2-dev libxslt1-dev
RUN apt-get install -y nodejs

WORKDIR /tmp

ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock

RUN bundle install

WORKDIR /app

RUN apt-get clean