#!/bin/bash
set -e

export EASYRSA_BATCH=1 # see https://superuser.com/questions/1331293/easy-rsa-v3-execute-build-ca-and-gen-req-silently

# Generate request
cd /opt/app/easy-rsa
./easyrsa gen-req "client-$1" nopass
./easyrsa sign-req client "client-$1"

# Certificate properties
CA="$(cat ./pki/ca.crt )"
CERT="$(cat ./pki/issued/client-${1}.crt | grep -zEo -e '-----BEGIN CERTIFICATE-----(\n|.)*-----END CERTIFICATE-----')"
KEY="$(cat ./pki/private/client-${1}.key)"
TLS_AUTH="$(cat ./pki/ta.key)"
DEST_FILE_PATH="/opt/app/clients/$1.ovpn"

# Generate and print config
echo "$(cat /opt/app/client.conf)
<ca>
$CA
</ca>
<cert>
$CERT
</cert>
<key>
$KEY
</key>
<tls-auth>
$TLS_AUTH
</tls-auth>
" > "$DEST_FILE_PATH"

echo 'OpenVPN Client configuration successfully generated!'
echo "Checkout openvpn/clients/$1.ovpn"
