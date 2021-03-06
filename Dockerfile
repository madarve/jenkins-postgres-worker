FROM jenkins/jnlp-slave:3.16-1-alpine
MAINTAINER Infrastructure team <team-infrastructure@newstore.com>

ENV PG_MAJOR 10
ENV PG_VERSION 10.6

ENV PATH /usr/lib/postgresql/$PG_MAJOR/bin:$PATH
ENV PGDATA /var/lib/postgresql/data

ENV LANG en_US.utf8

USER root

RUN apk update && \
    apk add build-base \
    readline-dev \
    openssl-dev \
    zlib-dev \
    libxml2-dev \
    glib-lang \
    wget \
    gnupg \
    ca-certificates \
    libssl1.0 \
    py3-virtualenv \
    python3-dev \
    py3-psycopg2 \
    build-base \
    perl \
    gcc \
    grep \
    su-exec \    
    findutils && \
    gpg --keyserver ipv4.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
    gpg --list-keys --fingerprint --with-colons | sed -E -n -e 's/^fpr:::::::::([0-9A-F]+):$/\1:6:/p' | gpg --import-ownertrust && \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.7/gosu-amd64" && \
    wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.7/gosu-amd64.asc" && \
    gpg --verify /usr/local/bin/gosu.asc && \
    rm /usr/local/bin/gosu.asc && \
    chmod +x /usr/local/bin/gosu && \
    mkdir -p /docker-entrypoint-initdb.d && \
    wget https://ftp.postgresql.org/pub/source/v$PG_VERSION/postgresql-$PG_VERSION.tar.bz2 -O /tmp/postgresql-$PG_VERSION.tar.bz2 && \
    tar xvfj /tmp/postgresql-$PG_VERSION.tar.bz2 -C /tmp && \
    cd /tmp/postgresql-$PG_VERSION && ./configure --enable-integer-datetimes --enable-thread-safety --prefix=/usr/local --with-libedit-preferred --with-openssl  && make world && make install world && make -C contrib install && \
    cd /tmp/postgresql-$PG_VERSION/contrib && make && make install && \
    apk --purge del openssl-dev zlib-dev libxml2-dev gnupg ca-certificates && \
    rm -r /tmp/postgresql-$PG_VERSION* /var/cache/apk/*

COPY jenkins-slave /jenkins-slave


ENTRYPOINT ["/jenkins-slave"]
