<h3 align="center">
    <img src="https://user-images.githubusercontent.com/30767528/91842261-0a27a600-ec54-11ea-9572-04c213f80374.png" alt="Logo" width="500">
</h3>

<h3 align="center">
    OpenVPN Docker Image
</h3>

There is already an existing docker-image for openvpn created by (kylemanna/docker-openvpn)[https://github.com/kylemanna/docker-openvpn] - With over [180](https://github.com/kylemanna/docker-openvpn/issues) issues, 
[40](https://github.com/kylemanna/docker-openvpn/pulls) open PR's and last commit done in March 2020 I decided to tread this image as not maintained anymore, also It was a good way for me to make myself more familiar with building and setting up docker iamges so that's why I created my own.

Most of its documentation can be found in the [root](https://github.com/Simonwep/openvpn-pihole) directory, if you want to run it without anything else you'll have to edit the [dns-configuration](https://github.com/Simonwep/openvpn-pihole/blob/master/openvpn-docker/server.conf#L200) (which currently points to the PiHole DNS Server) and
if you don't want to use a custom dns-resolve at all you may also want to comment out [this line](https://github.com/Simonwep/openvpn-pihole/blob/master/openvpn-docker/server.conf#L192)