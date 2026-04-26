#!/bin/bash
set -e

# .ovpn file path
DEST_FILE_PATH="/etc/openvpn/clients/$1.ovpn"

# Validate username and check for duplicates
if [[ -z $1 ]]; then
  echo 'Name cannot be empty.'
  exit 1
elif [[ -f $DEST_FILE_PATH ]]; then
  echo "User with name $1 already exists under openvpn/clients." >&2
  exit 1
fi

export EASYRSA_BATCH=1 # see https://superuser.com/questions/1331293/easy-rsa-v3-execute-build-ca-and-gen-req-silently

echo 'Generate client certificate...'

# Copy easy-rsa variables
cd /opt/app/easy-rsa
cp /etc/openvpn/config/easy-rsa.vars ./vars

# Generate certificates
if [[ -z $2 ]]; then
  echo 'Without password...'
  ./easyrsa --batch gen-req "client-$1" nopass
else
  echo 'With password...'
  export EASYRSA_PASSIN="pass:${2}"
  export EASYRSA_PASSOUT="pass:${2}"
  (echo -e '\n') | ./easyrsa --batch gen-req "client-$1"
  unset EASYRSA_PASSIN EASYRSA_PASSOUT
fi

# Sign request
./easyrsa sign-req client "client-$1"

# Certificate properties
CA="$(cat ./pki/ca.crt)"
CERT="$(cat ./pki/issued/client-${1}.crt | grep -zEo -e '-----BEGIN CERTIFICATE-----(\n|.)*-----END CERTIFICATE-----' | tr -d '\0')"
KEY="$(cat ./pki/private/client-${1}.key)"
TLS_AUTH="$(cat ./pki/ta.key)"

echo 'Sync pki directory...'
cp -r ./pki/. /etc/openvpn/pki

echo 'Generate .ovpn file...'
echo "$(grep -vE '^#|^$|^;' /etc/openvpn/config/client.conf)
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
" >"$DEST_FILE_PATH"

echo 'OpenVPN Client configuration successfully generated!'
echo "Checkout openvpn/clients/$1.ovpn"
