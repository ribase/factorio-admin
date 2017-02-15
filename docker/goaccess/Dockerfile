FROM debian:jessie

MAINTAINER Sebastian Thadewald <sthadewald@gmail.com>

RUN apt-get update -y && apt-get install -y git \
    lsb-release \
    wget \
    python3 \
    supervisor \
    cron

RUN echo "deb http://deb.goaccess.io/ $(lsb_release -cs) main" | tee -a /etc/apt/sources.list.d/goaccess.list
RUN wget -O - http://deb.goaccess.io/gnugpg.key | apt-key add -
RUN apt-get update
RUN apt-get install -y goaccess

ADD goaccess_access.conf /etc/
ADD goaccess_error.conf /etc/
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ADD root /var/spool/cron/crontabs

RUN mkdir /var/goaccess
RUN mkdir /var/goaccess/output

ADD start_webserver.sh /
RUN chmod +x /start_webserver.sh

CMD ["/usr/bin/supervisord"]