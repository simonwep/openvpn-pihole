#!/bin/bash

# Check if the correct number of arguments is provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <password> <username1> [<username2> ... <usernameN>]"
    exit 1
fi

# Check if the 'openvpn' container is running
if ! sudo docker ps --format '{{.Names}}' | grep -q '^openvpn$'; then
    echo "Error: The 'openvpn' container is not running."
    exit 1
fi

# Get the password (first argument)
password="$1"
username_suffix=$(date +%Y)
error_log_file="genclients_log.txt"

# Shift the arguments to exclude the password and process only the usernames
shift

# Loop through the remaining arguments (usernames) and create clients for each
for username in "$@"; do
    username="$username-$username_suffix"
    sudo docker exec openvpn bash /opt/app/bin/genclient.sh "$username" "$password" >>/dev/null 2>>"$error_log_file"

    if [ $? -eq 0 ]; then
        echo "Client '$username' created successfully."
    else
        echo "Error creating client '$username'. Check out '$error_log_file' for more info."
    fi
done

echo "Done."
