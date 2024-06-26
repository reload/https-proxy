# shellcheck shell=sh

mkdir -p /cert /etc/nginx/include.d

CERT="/cert/${FIRST_VIRTUAL_HOST:-localhost}.crt"
CERT_KEY="/cert/${FIRST_VIRTUAL_HOST:-localhost}.key"
CA_CERT="/rootCA/rootCA.pem"
CA_KEY="/rootCA/rootCA-key.pem"

IP_ADDRESS=$(hostname -i)
export IP_ADDRESS

envsubst </etc/cert.cfg.template >/tmp/cert.cfg

for host in ${VIRTUAL_HOST:-localhost}; do
	echo "dns_name = $host" >>/tmp/cert.cfg
done

certtool --generate-privkey --outfile "${CERT_KEY}"

if [ ! -r "${CA_CERT}" ] || [ ! -r "${CA_KEY}" ]; then
	certtool --generate-certificate --generate-self-signed --load-privkey "${CERT_KEY}" --template /tmp/cert.cfg --outfile "${CERT}"
else
	certtool --generate-request --load-privkey "${CERT_KEY}" --template /tmp/cert.cfg --outfile /tmp/request.pem
	certtool --generate-certificate --load-request /tmp/request.pem --load-ca-certificate "${CA_CERT}" --load-ca-privkey "${CA_KEY}" --template /tmp/cert.cfg --outfile "${CERT}"
fi

if [ -r "${CA_CERT}" ]; then
	cp "${CA_CERT}" /usr/local/share/ca-certificates/
	/usr/sbin/update-ca-certificates
fi

envsubst </etc/ssl.conf.template >/etc/nginx/include.d/ssl.conf
