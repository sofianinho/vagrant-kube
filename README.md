# Kubernetes cluster with vagrant and kubeadm

Simple vagrantfile for any sized cluster (master + workers) in Ubuntu 18.04 VMs. Very configurable through 2 env variables.

## Warning

This branch is the CRI-O branch. In this branch I use [cri-o](https://cri-o.io/) instead of Docker as the CNI runtime.

## Use

The following commands for instance will bootstrap a kubernetes cluster with a master and 2 workers with a specific private subnet:
```sh
export VAGRANT_SUBNET=192.168.195.0 
export VAGRANT_WORKERS=2 
vagrant up
```
Default values for workers and subnet are 1 and 192.168.66.0, respectively

## Full list of possible configurations

| Variable        | Definition           | Default  | Example value |
| :-------------: |:-------------:| :-----:|:------:|
| `VAGRANT_SUBNET`| Private subnet for VMs where the cluster is formed and peered. <br> Master is at .100 and Workers start at .150 | `192.168.66.0` |`192.168.178.0`, `10.10.0.0`|
| `VAGRANT_WORKERS`      | Number of workers in the cluster (master is also a worker)      |   1 | 5|
| `VAGRANT_MASTER_RAM` | Memory for the master      |    2048 | 4096, 1024 |
| `VAGRANT_MASTER_CPU` | Number of CPUs for the master      |    1 | 2 |
| `VAGRANT_WORKER_RAM` | Memory per worker      |    2048 | 4096, 1024 |
| `VAGRANT_WORKER_CPU` | Number of CPUs for per worker      |    1 | 2 |


## Interact with the cluster remotely (from host)

For that, I find the simplest way is to copy your cluster config outside of the master vm and use kubectl with --kubeconfig flag
```sh
vagrant ssh master
cp .kube/config /vagrant
exit
alias vk8s="kubectl --kubeconfig=./config"
vk8s cluster-info #may take a while the first time
vk8s get nodes
vk8s describe nodes
```
To make this step more secure, follow instructions from [here](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/) and this [cheatsheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/#kubectl-context-and-configuration).

## LICENSE
MIT
