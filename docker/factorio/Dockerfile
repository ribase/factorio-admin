FROM ubuntu:16.04

MAINTAINER Sebastian Thadewald <sthadewald@gmail.com>

RUN apt-get update -y && apt-get install -y git \
    supervisor

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf