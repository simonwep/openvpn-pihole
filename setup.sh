# Partly copied from https://github.com/kylemanna/docker-openvpn/blob/master/docs/docker-compose.md

# Initialize the configuration files and certificates
docker-compose run --rm openvpn ovpn_genconfig -u udp://$1
docker-compose run --rm openvpn ovpn_initpki

# Fix ownership (depending on how to handle your backups, this may not be needed)
chown -R $(whoami): ./openvpn

# Start services
docker-compose up
