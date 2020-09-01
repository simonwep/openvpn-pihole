<h3 align="center">
    <img src="https://user-images.githubusercontent.com/30767528/91841822-4a3a5900-ec53-11ea-92fe-4bde2acccac4.png" alt="Logo" width="500">
</h3>

<h3 align="center">
    OpenVPN and PiHole wrapped up in a docker-compose setup
</h3>

<br/>

<p align="center">
  <a href="https://github.com/Simonwep/openvpn-pihole/actions?query=workflow%3ACI"><img
     alt="CI Status"
     src="https://github.com/Simonwep/openvpn-pihole/workflows/CI/badge.svg"/></a>
  <a href="https://github.com/sponsors/Simonwep"><img
     alt="GitHub Sponsors"
     src="https://img.shields.io/badge/GitHub-sponsor-0A5DFF.svg"></a>
  <a href="https://www.buymeacoffee.com/aVc3krbXQ"><img
     alt="Buy me a Coffee"
     src="https://img.shields.io/badge/Buy%20Me%20A%20Coffee-donate-FF813F.svg"></a>
  <a href="https://www.patreon.com/simonwep"><img
     alt="Support on Patreon"
     src="https://img.shields.io/badge/Patreon-support-FA8676.svg"></a>
</p>
<br>

Many thanks to the official [PiHole Docker Image](https://github.com/pi-hole/docker-pi-hole)!

### Setup

Make sure you're using the latest [docker](https://docs.docker.com/get-docker/) and [docker-compose](https://docs.docker.com/compose/install/). I'm using `v3.5` for the [docker-compose.yml](docker-compose.yml)so you'll need at least `v17.12.0` for the docker-ngine (see [this table](https://docs.docker.com/compose/compose-file/#compose-and-docker-compatibility-matrix)).

After you've installed all the pre-requisites you can run.
```sh
$ sudo docker-compose up -d
```

After this is done you'll find two new folders inside of this repository - the `/openvpn` folder will contain all of your certificates as well as an easy-rsa configuration file.
`/pihole` will contain the content of `/etc/pihole` and `/etc/dnsmasq.d`.

> Until [this issue](https://github.com/moby/moby/issues/32582) has been resolved I'll be using mounted host directories for the sake of simplicity.

If you want to migrate settings, or your query-database you can now copy it into the corresponding folder in `/pihole` :)
The PiHole admin dashboard can only be reached through the vpn. If you want to change your admin-dashboard-password you can do that in the [docker-compose](docker-compose.yml) file.

> If you're using a VPS make sure to open 1194/udp!

#### Generating `.ovpn files`

```sh
sudo docker exec openvpn bash /opt/app/bin/genclient.sh <name>
```

You can find you `.ovpn` file under `/openvpn/clients/<name>.ovpn`, make sure to change the remote ip-address.

#### Revoking `.ovpn files`

```sh
sudo docker exec openvpn bash /opt/app/bin/rmclient.sh <name>
```

Revoked certificates won't kill active connections, you'll have to restart the service if you want the user to immediately disconnect:
```sh
sudo docker-compose restart openvpn
``` 

### Troubleshooting

#### Port 53 is already in use

> ERROR: for pihole  Cannot start service pihole: driver failed programming external connectivity on endpoint pihole (...): Error starting userland proxy: listen tcp 0.0.0.0:53: bind: address already in use

You'll need to disable the local dns-server, see [this](https://askubuntu.com/questions/907246/how-to-disable-systemd-resolved-in-ubuntu) and [this](https://askubuntu.com/questions/191226/dnsmasq-failed-to-create-listening-socket-for-port-53-address-already-in-use) askubuntu thread.
You can stop, disable and mask the `systemd-resolved` service using the following commands:
```sh
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved
sudo systemctl mask systemd-resolved
```