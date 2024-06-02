#!/bin/bash

SCRIPT_NAME='./clients'

# Function to add clients
add_clients() {
  local password=$1
  shift
  for name in "$@"; do
    sudo docker exec openvpn bash /opt/app/bin/genclient.sh "$name" "$password"
  done
}

# Function to remove clients
remove_clients() {
  for name in "$@"; do
    sudo docker exec openvpn bash /opt/app/bin/rmclient.sh "$name"
  done
}

# Main script logic
case "$1" in
  add)
    if [ "$#" -lt 3 ]; then
      echo "Usage: $SCRIPT_NAME add <password> <names...>"
      exit 1
    fi
    add_clients "$2" "${@:3}"
    ;;
  remove)
    if [ "$#" -lt 2 ]; then
      echo "Usage: $SCRIPT_NAME remove <names...>"
      exit 1
    fi
    remove_clients "${@:2}"
    ;;
  *)
    echo "Usage: $SCRIPT_NAME {add|remove} <arguments>"
    exit 1
    ;;
esac
