FROM alpine:3.24

LABEL maintainer="Chandan Ghosh <ckghosh1983@gmail.com>" description="Unbound DNS"

EXPOSE 53/tcp
EXPOSE 53/udp

# Read the VERSION file
ARG VERSION=1.22.0-r0


RUN apk update && apk add --no-cache unbound=${VERSION} tini curl wget bind-tools net-tools sed ca-certificates \
&& curl -o /etc/unbound/root.hints http://www.internic.net/domain/named.root \
&& wget -O /etc/unbound/unbound_ad_servers "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=unbound&showintro=0&startdate[day]=&startdate[month]=&startdate[year]=&mimetype=plaintext"


COPY unbound.conf /etc/unbound/unbound.conf
COPY a-records.conf /etc/unbound/a-records.conf
COPY forward-records.conf /etc/unbound/forward-records.conf

RUN unbound-anchor \
&& unbound-checkconf /etc/unbound/unbound.conf

HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD netstat -ln | grep -q ":53" || exit 1

ENTRYPOINT ["/sbin/tini", "--", "unbound"]
