FROM ubuntu:24.04

COPY . /opt/app
WORKDIR /opt/app

# Install Latest OpenVPN Version
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install gnupg wget openvpn -y

# Download easy-rsa
RUN wget -q https://github.com/OpenVPN/easy-rsa/releases/download/v3.2.0/EasyRSA-3.2.0.tgz && \
    tar xf EasyRSA-3.2.0.tgz && \
    rm -f EasyRSA-3.2.0.tgz && \
    mv EasyRSA-3.2.0 easy-rsa

# Install iptables
RUN apt-get install iptables -y

EXPOSE 1194/udp

RUN chmod +x bin/*
RUN chmod +x docker-entrypoint.sh
ENTRYPOINT ./docker-entrypoint.sh
