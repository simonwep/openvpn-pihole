#!/bin/bash
set -e

export EASYRSA_BATCH=1 # see https://superuser.com/questions/1331293/easy-rsa-v3-execute-build-ca-and-gen-req-silently

# Generate request
cd /opt/app/easy-rsa
./easyrsa gen-req "client-$1" nopass
./easyrsa sign-req client "client-$1"

# Generate and print config
echo "$(cat /opt/app/client.conf)
<ca>
$(cat ./pki/ca.crt )
</ca>
<cert>
$(cat ./pki/issued/client-${1}.crt)
</cert>
<key>
$(cat ./pki/private/client-${1}.key)
</key>
<tls-auth>
$(cat ./pki/ta.key)
</tls-auth>
" > "/opt/app/clients/$1.ovpn"
