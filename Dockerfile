FROM ubuntu:20.10

RUN apt-get -y update
RUN apt-get -y install curl bash
RUN curl -s https://install.speedtest.net/app/cli/install.deb.sh | bash
RUN apt-get -y install speedtest

HEALTHCHECK --interval=5m --timeout=5s --retries=1 \
    CMD ./healthcheck.sh

WORKDIR /opt/speedtest

ADD scripts/ .

RUN chmod +x ./init_test_connection.sh \
    && chmod +x ./healthcheck.sh

CMD ./init_test_connection.sh
