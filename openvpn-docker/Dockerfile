FROM ubuntu:24.04

COPY . /opt/app
WORKDIR /opt/app

# Install Latest OpenVPN Version
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y gnupg wget openvpn iptables iproute2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download easy-rsa
RUN wget -q https://github.com/OpenVPN/easy-rsa/releases/download/v3.2.6/EasyRSA-3.2.6.tgz && \
    tar xf EasyRSA-3.2.6.tgz && \
    rm -f EasyRSA-3.2.6.tgz && \
    mv EasyRSA-3.2.6 easy-rsa

EXPOSE 1194/udp

HEALTHCHECK CMD pgrep openvpn || exit 1

RUN chmod +x bin/*
RUN chmod +x docker-entrypoint.sh

ENTRYPOINT ["./docker-entrypoint.sh"]
