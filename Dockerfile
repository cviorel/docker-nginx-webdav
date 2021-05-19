FROM alpine:latest
MAINTAINER Viorel Ciucu <viorel.ciucu@gmail.com>

ENV TIMEZONE Europe/Brussels

ENV PACKAGE_LIST="openssl nginx apache2-utils tzdata"

RUN apk update && \
    apk add --no-cache ${PACKAGE_LIST} && \
    cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
    echo "${TIMEZONE}" > /etc/timezone && \
    mkdir /etc/nginx/certificates && \
    openssl req \
        -x509 \
        -newkey rsa:2048 \
        -keyout /etc/nginx/certificates/key.pem \
        -out /etc/nginx/certificates/cert.pem \
        -days 365 \
        -nodes \
        -subj /CN=localhost && \
    mkdir -p /www && \
    mkdir -p /run/nginx && \
    apk del tzdata && \
    rm -rf /tmp/* && rm -rf /var/cache/apk/*

VOLUME ["/www"]

EXPOSE 80

COPY files/webdav.conf /etc/nginx/conf.d/default.conf

COPY entrypoint.sh /
RUN chmod +x entrypoint.sh
CMD /entrypoint.sh && nginx -g "daemon off;"
