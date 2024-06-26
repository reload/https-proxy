#!/usr/bin/env bash

set -euo pipefail

FIRST_VIRTUAL_HOST=$(awk '{print $1;}' <<<"${VIRTUAL_HOST:-default}")
export FIRST_VIRTUAL_HOST

echo "export FIRST_VIRTUAL_HOST=${FIRST_VIRTUAL_HOST}" >>/docker-entrypoint.d/10-first_virtual_host.envsh
chmod +x /docker-entrypoint.d/10-first_virtual_host.envsh

CERT="/cert/${FIRST_VIRTUAL_HOST:-default}.crt"
CERT_KEY="/cert/${FIRST_VIRTUAL_HOST:-default}.key"
CA_CERT="/rootCA/rootCA.pem"
CA_KEY="/rootCA/rootCA-key.pem"

if [ ! -r "${CA_CERT}" ] || [ ! -r "${CA_KEY}" ]; then
	echo "No root certificate, skipping certificate generation"
	exit 0
fi

IP_ADDRESS=$(hostname -i)
export IP_ADDRESS

envsubst </etc/cert.cfg.template >/tmp/cert.cfg

for host in $VIRTUAL_HOST; do
	echo "dns_name = $host" >>/tmp/cert.cfg
done

certtool --generate-privkey --outfile "${CERT_KEY}"
certtool --generate-request --load-privkey "${CERT_KEY}" --template /tmp/cert.cfg --outfile /tmp/request.pem
certtool --generate-certificate --load-request /tmp/request.pem --load-ca-certificate "${CA_CERT}" --load-ca-privkey "${CA_KEY}" --template /tmp/cert.cfg --outfile "${CERT}"

cp "${CA_CERT}" /usr/local/share/ca-certificates/
/usr/sbin/update-ca-certificates

mkdir -p /etc/nginx/include.d
envsubst </etc/ssl.conf.template >/etc/nginx/include.d/ssl.conf
