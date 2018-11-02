# Kubernetes cluster with vagrant and kubeadm

Simple vagrantfile for any sized cluster (master + workers) in Ubuntu 18.04 VMs. Very configurable through 2 env variables.

## Use

The following commands for instance will bootstrap a kubernetes cluster with a master and 2 workers with a specific private subnet:
```sh
export VAGRANT_SUBNET=192.168.195.0 
export VAGRANT_WORKERS=2 
vagrant up
```
Default values for workers and subnet are 1 and 192.168.66.0, respectively

## Interact with the cluster remotely (from host)

For that, I find the simplest way is to copy your cluster config outside of the master vm and use kubectl with --kubeconfig flag
```sh
vagrant ssh master
cp .kube/config /vagrant
exit
kubectl --kubeconfig=./config cluster-info #may take a while the first time
kubectl --kubeconfig=./config get nodes
kubectl --kubeconfig=./config describe nodes
```
To make this step more secure, follow instructions from [here](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/) and this [cheatsheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/#kubectl-context-and-configuration).

## LICENSE
MIT
