# Commands taken from https://askubuntu.com/questions/907246/how-to-disable-systemd-resolved-in-ubuntu

# Stop and remove service
systemctl disable systemd-resolved
systemctl stop systemd-resolved

# Switch to default dns-resolve
echo "dns=default" >> /etc/NetworkManager/NetworkManager.conf

# Remove symlink (??)
rm /etc/resolv.conf

# Restart network-manager
systemctl restart NetworkManager
