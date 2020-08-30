#!/bin/bash
set -e

if [[ ! -f /etc/openvpn/pki/ca.crt ]]; then
    export EASYRSA_BATCH=1 # see https://superuser.com/questions/1331293/easy-rsa-v3-execute-build-ca-and-gen-req-silently
    cd /opt/app/easy-rsa

    # Building the CA
    echo 'Setting up public key infrastructure'
    ./easyrsa init-pki

    echo 'Generating ertificate authority'
    ./easyrsa build-ca nopass

    # Creating the Server Certificate, Key, and Encryption Files
    echo 'Creating the Server Certificate'
    ./easyrsa gen-req server nopass
    
    echo 'Sign request'
    ./easyrsa sign-req server server
    
    echo 'Generate Diffie-Hellman key'
    ./easyrsa gen-dh

    echo 'Generate HMAC signature'
    openvpn --genkey --secret pki/ta.key
    cp ./pki/ta.key /etc/openvpn/
    
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
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
sysctl -p

# Copy configuration and start openvpn
echo 'Copying configuration...'
cp /opt/app/server.conf /etc/openvpn

echo 'Starting OpenVPN server...'
/usr/sbin/openvpn --cd /etc/openvpn --script-security 2 --config /etc/openvpn/server.conf
