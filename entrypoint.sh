#!/bin/sh
set -eu

: "${LOCAL_USER:?LOCAL_USER is required}"
: "${LOCAL_PASS:?LOCAL_PASS is required}"
: "${UPSTREAM_HOST:?UPSTREAM_HOST is required}"
: "${UPSTREAM_PORT:?UPSTREAM_PORT is required}"
: "${ALLOW_CIDRS:=0.0.0.0/0}"

cat > /etc/3proxy.cfg <<EOF
nscache 65536
timeouts 1 5 30 60 180 1800 15 60

internal 0.0.0.0
external 0.0.0.0

# Local auth for your app
auth strong
users ${LOCAL_USER}:CL:${LOCAL_PASS}
EOF

# allow rules (comma-separated CIDRs)
echo "$ALLOW_CIDRS" | tr ',' '\n' | while read -r cidr; do
  cidr="$(echo "$cidr" | xargs)"
  [ -n "$cidr" ] && echo "allow ${LOCAL_USER} ${cidr}" >> /etc/3proxy.cfg
done

cat >> /etc/3proxy.cfg <<EOF
deny * * 0.0.0.0/0

# Forward everything to upstream proxy (no auth)
parent 1000 http ${UPSTREAM_HOST} ${UPSTREAM_PORT}

# Local proxy listens on 3128 (supports CONNECT)
proxy -p3128 -a
flush
EOF

echo "[proxy-gateway] listening on :3128 -> upstream ${UPSTREAM_HOST}:${UPSTREAM_PORT}"
exec /usr/local/bin/3proxy /etc/3proxy.cfg
