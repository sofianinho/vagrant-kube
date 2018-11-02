#!/bin/bash

DOCKER_REPO_URL="https://download.docker.com/linux/ubuntu"
DOCKER_REPO_GPG=$DOCKER_REPO_URL"/gpg"
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

info "Installing Docker"
curl -fsSL $DOCKER_REPO_GPG -o docker.gpg
sudo apt-key add docker.gpg
sudo add-apt-repository "deb [arch=amd64] $DOCKER_REPO_URL bionic stable"
sudo apt-get install -y docker-ce
sudo usermod -aG docker "${USER}"

info "Installing kubernetes binaries"

curl -sLSf $GOOGLE_REPO_GPG -o google.gpg 
sudo apt-key add google.gpg
sudo apt-add-repository "deb $K8S_REPO_URL kubernetes-xenial main"
sudo swapoff -a
sudo apt-get install -y kubeadm
mkdir /home/vagrant/.kube
kubectl completion bash > kubectl
sudo mv kubectl /etc/bash_completion.d/

info "adding kernel modules for kubeadm"
sudo modprobe ip_vs_wrr 
sudo modprobe ip_vs_rr
sudo modprobe ip_vs_sh
sudo modprobe ip_vs


