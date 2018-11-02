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

info "Initializing kubeadm"
sudo kubeadm init --apiserver-advertise-address=$PEER_ADDRESS --pod-network-cidr=10.244.0.0/16
sudo cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo chown vagrant:vagrant /home/vagrant/.kube/config

info "Setting the master as a worker too"
kubectl taint nodes --all node-role.kubernetes.io/master-

info "setting the networking driver: Flannel"
FLANNEL_URL="https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml"
kubectl apply -f $FLANNEL_URL


info "Setting the join command"
JOIN_TOKEN=$(kubeadm token list |tail -n -1| awk '{ print $1 }')
JOIN_HASH=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null |    openssl dgst -sha256 -hex | sed 's/^.* //')
JOIN_COMMAND="sudo kubeadm join "$PEER_ADDRESS":6443 --token "$JOIN_TOKEN" --discovery-token-ca-cert-hash sha256:"$JOIN_HASH

info "In order to join the cluster, run this command: "
info "$JOIN_COMMAND"
echo $JOIN_COMMAND > /vagrant/join.txt
