#!/bin/bash
set -e

if [[ ! -f /etc/openvpn/pki/ca.crt ]]; then
  export EASYRSA_BATCH=1 # see https://superuser.com/questions/1331293/easy-rsa-v3-execute-build-ca-and-gen-req-silently
  cd /opt/app/easy-rsa

  # Copy easy-rsa variables
  cp /etc/openvpn/config/easy-rsa.vars ./vars

  # Building the CA
  echo 'Setting up public key infrastructure...'
  ./easyrsa init-pki

  echo 'Generating certificate authority...'
  ./easyrsa build-ca nopass

  # Creating the Server Certificate, Key, and Encryption Files
  echo 'Creating the Server Certificate...'
  ./easyrsa gen-req server nopass

  echo 'Sign request...'
  ./easyrsa sign-req server server

  echo 'Generate Diffie-Hellman key...'
  ./easyrsa gen-dh

  echo 'Generate HMAC signature...'
  openvpn --genkey secret pki/ta.key

  echo 'Create certificate revocation list (CRL)...'
  ./easyrsa gen-crl
  chmod +r ./pki/crl.pem

  # Copy to mounted volume
  cp -r ./pki/. /etc/openvpn/pki
else
  # Copy from mounted volume
  cp -r /etc/openvpn/pki /opt/app/easy-rsa
  echo 'PKI already set up.'
fi

# Configure network
mkdir -p /dev/net
if [ ! -c /dev/net/tun ]; then
  mknod /dev/net/tun c 10 200
fi

echo 'Configuring networking rules...'
if ! grep -q 'net.ipv4.ip_forward=1' /etc/sysctl.conf; then
  echo 'net.ipv4.ip_forward=1' >>/etc/sysctl.conf
fi
sysctl -p /etc/sysctl.conf

echo 'Configuring iptables...'

# Auto-detect the default outgoing network interface
DEFAULT_IF=$(ip route show default | awk '/default/ {print $5}' | head -1)
DEFAULT_IF=${DEFAULT_IF:-eth0}

# Flush existing NAT rules to avoid duplicates on restart
iptables -t nat -F POSTROUTING
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o "$DEFAULT_IF" -j MASQUERADE

echo 'Start openvpn process...'
exec /usr/sbin/openvpn --cd /etc/openvpn --script-security 2 --config /etc/openvpn/config/server.conf
