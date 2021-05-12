FROM alpine:3

RUN apk add --update --no-cache py-pip curl bash
RUN pip install --upgrade pip
RUN pip install speedtest-cli --upgrade

HEALTHCHECK --interval=5m --timeout=5s --retries=1 \
    CMD ./healthcheck.sh

WORKDIR /opt/speedtest

ADD scripts/ .

RUN chmod +x ./init_test_connection.sh \
    && chmod +x ./healthcheck.sh

CMD ./init_test_connection.sh
