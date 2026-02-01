FROM alpine:3.20 AS builder

RUN apk add --no-cache git make gcc musl-dev
RUN git clone --depth 1 https://github.com/3proxy/3proxy.git /3proxy
WORKDIR /3proxy
RUN make -f Makefile.Linux

FROM alpine:3.20

COPY --from=builder /3proxy/bin/3proxy /usr/local/bin/3proxy

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3128

CMD ["/bin/sh", "/entrypoint.sh"]
