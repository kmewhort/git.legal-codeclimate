FROM ruby:2.4-alpine

LABEL maintainer "Kent Mewhort <kent@git.legal>"

COPY engine.json /

WORKDIR /usr/src/app
COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/

# install necessary packages and bundle in one-go so that we can clean-up build-base without
# a size impact
RUN apk update && \
    apk add --no-cache build-base libxml2-dev libxslt-dev tzdata sqlite sqlite-dev nodejs && \
    gem install bundler && \
    bundle install --without development test -j 4 && \
    rm -fr /usr/share/ri && \
    apk del build-base

RUN adduser -u 9000 -D app
COPY . /usr/src/app
# avoid changing the user for the large db files, as they'll end up doubling the container by their size under
# docker's standard aufs storage driver - see https://github.com/moby/moby/issues/5505 and
# https://github.com/moby/moby/issues/6119#issuecomment-70606158;
# as a workaround, we keep these files world-writable
RUN find /usr/src/app -not -path "/usr/src/app/db/*" -print0 | xargs -0 chown app:app

USER app

VOLUME /code
WORKDIR /code

ENV RAILS_ENV="production"

CMD ["/usr/src/app/bin/git-legal-cc-scan"]
