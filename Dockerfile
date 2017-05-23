FROM postgres:9-alpine

WORKDIR /usr/src/app
COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/

RUN apk update && \
    apk add --no-cache \
    build-base \
    libxml2-dev \
    libxslt-dev \
    tzdata

# install ruby through rbenv; based on https://hub.docker.com/r/gendosu/alpine-ruby/~/dockerfile/
ENV PATH /usr/local/rbenv/shims:/usr/local/rbenv/bin:$PATH
ENV RBENV_ROOT /usr/local/rbenv
ENV CONFIGURE_OPTS --disable-install-doc
RUN apk add --update --no-cache --virtual .ruby-builddeps \
    linux-headers \
    imagemagick-dev \
    qt-webkit \
    xvfb \
    autoconf \
    bison \
    bzip2 \
    bzip2-dev \
    ca-certificates \
    coreutils \
    gcc \
    git \
    gdbm-dev \
    glib-dev \
    libc-dev \
    libffi-dev \
    libxml2-dev \
    libxslt-dev \
    make \
    ncurses-dev \
    openssl \
    openssl-dev \
    procps \
    readline-dev \
    ruby \
    tar \
    yaml-dev \
    zlib-dev \
    && rm -rf /var/cache/apk/*

RUN git clone --depth 1 git://github.com/sstephenson/rbenv.git ${RBENV_ROOT} \
    &&  git clone --depth 1 https://github.com/sstephenson/ruby-build.git ${RBENV_ROOT}/plugins/ruby-build \
    && git clone --depth 1 git://github.com/jf/rbenv-gemset.git ${RBENV_ROOT}/plugins/rbenv-gemset \
    &&  ${RBENV_ROOT}/plugins/ruby-build/install.sh

RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh \
    &&  echo 'eval "$(rbenv init -)"' >> /root/.bashrc

ENV RUBY_VERSION 2.4.0
RUN rbenv install $RUBY_VERSION \
  && rbenv global $RUBY_VERSION

RUN gem install bundler && \
    bundle install -j 4 && \
    rm -fr /usr/share/ri

RUN adduser -u 9000 -D app
COPY . /usr/src/app
RUN chown -R app:app /usr/src/app

#USER app

VOLUME /code
WORKDIR /code

CMD ["/usr/src/app/bin/git-legal-cc-scan"]
