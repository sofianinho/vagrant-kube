#!/bin/bash

# utilities functions (logging) 
log() {
 echo "$(date "+%F %T.%2N")|$(hostname)|${*}"
}

debug() {
 log "DEBUG|${*}"
}

info() {
 log "INFO|${*}"
}

warn() {
 log "WARN|${*}"
}

error() {
 log "ERROR|${*}"
}

#default peering subnet for the cluster
PEER_SUBNET="192.168.66.0"

wrong_arg(){
 error "Invalid parameter for $1"
 exit "1"
}

while [ $# -gt 0 ]; do
case "$1" in
  -s|--subnet)
    PEER_SUBNET="$2"
    shift 2
    ;;
  *)
    wrong_arg "$1"
    break
    ;;
esac
done

info "Getting private ip address"

_SUBNET=$(echo $PEER_SUBNET|cut -d "." -f1-3)
PEER_ADDRESS=$(ip -4 a |grep $_SUBNET |awk -F "inet |/" '{ print $2 }')
info "Peering address for master is: "$PEER_ADDRESS

info "Initializing kubeadm by joining master"
while [ ! -f /vagrant/join.txt ]; do
  sleep 5
done

JOIN_COMMAND=$(cat /vagrant/join.txt)
$JOIN_COMMAND

info "joined cluster!"

