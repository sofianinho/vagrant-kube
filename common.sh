#!/bin/bash

CRIO_REPO_PPA="ppa:projectatomic/ppa"
GOOGLE_REPO_GPG="https://packages.cloud.google.com/apt/doc/apt-key.gpg"
K8S_REPO_URL="http://apt.kubernetes.io/"

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

# Installation 
sudo apt-get update -q && sudo apt-get upgrade -y

info "Installing CRI-O"
sudo add-apt-repository $CRIO_REPO_PPA
#get the latest version of crio
LATEST_CRIO_VERSION=$(sudo apt search cri-o |awk  '/cri\-o\-[0-9]\.[0-9]+/{print $1}'|cut -d'/' -f1|tail -n 1)
sudo apt-get install -y $LATEST_CRIO_VERSION


info "Installing kubernetes binaries"

curl -sLSf $GOOGLE_REPO_GPG -o google.gpg 
sudo apt-key add google.gpg
sudo apt-add-repository "deb $K8S_REPO_URL kubernetes-xenial main"
sudo swapoff -a
sudo apt-get install -y kubeadm
mkdir /home/vagrant/.kube
kubectl completion bash > kubectl
sudo mv kubectl /etc/bash_completion.d/

info "fixing issues of crio"
sudo sed 's|/usr/libexec/crio/conmon|/usr/bin/conmon|' -i /etc/crio/crio.conf
sudo systemctl restart cri-o.service

info "adding kernel modules for kubeadm"
sudo modprobe ip_vs_wrr 
sudo modprobe ip_vs_rr
sudo modprobe ip_vs_sh
sudo modprobe ip_vs
sudo modprobe br_netfilter
echo "net.bridge.bridge-nf-call-iptables = 1" |sudo tee -a /etc/sysctl.conf
sudo sysctl -p
sudo echo 1 > /proc/sys/net/ipv4/ip_forward


