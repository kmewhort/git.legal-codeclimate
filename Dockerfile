FROM ruby:2.4-alpine

WORKDIR /usr/src/app
COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/

RUN apk update && \
    apk add --no-cache \
    build-base \
    postgresql \
    postgresql-dev \
    postgresql-contrib \
    libxml2-dev \
    libxslt-dev \
    tzdata

RUN gem install bundler && \
    bundle install -j 4 && \
    rm -fr /usr/share/ri

RUN adduser -u 9000 -D app
COPY . /usr/src/app
RUN chown -R app:app /usr/src/app

USER app

VOLUME /code
WORKDIR /code

CMD ["/usr/src/app/bin/git-legal-cc-scan"]
