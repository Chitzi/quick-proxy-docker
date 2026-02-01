FROM alpine:3.20

RUN apk add --no-cache 3proxy

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3128

CMD ["/bin/sh", "/entrypoint.sh"]
