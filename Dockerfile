FROM alpine:latest

LABEL maintainer="Chandan Ghosh <ckghosh1983@gmail.com>" description="Unbound DNS"

EXPOSE 53/tcp
EXPOSE 53/udp

# Read the VERSION file
ARG VERSION=1.22.0-r0


RUN apk add --no-cache unbound=${VERSION} tini curl wget bind-tools drill sed \
&& curl -o /etc/unbound/root.hints http://www.internic.net/domain/named.root \
&& wget -O /etc/unbound/unbound_ad_servers "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=unbound&showintro=0&startdate[day]=&startdate[month]=&startdate[year]=&mimetype=plaintext"


COPY unbound.conf /etc/unbound/unbound.conf
COPY a-records.conf /etc/unbound/a-records.conf
COPY forward-records.conf /etc/unbound/forward-records.conf

RUN unbound-anchor \
&& unbound-checkconf /etc/unbound/unbound.conf

HEALTHCHECK --interval=20s --timeout=30s --start-period=10s --retries=3 CMD drill @127.0.0.1 cloudflare.com || exit 1

ENTRYPOINT ["/sbin/tini", "--", "unbound"]
