# -*- mode: ruby -*-
# # vi: set ft=ruby :


# Config parameters
$image_version = "ubuntu/bionic64"
$enable_serial_logging = false
$vm_gui = false
$vm_memory = 2048
$vm_cpus = 1
$default_subnet = ENV.fetch('VAGRANT_SUBNET', '192.168.66.0')
$default_workers = ENV.fetch('VAGRANT_WORKERS', 1).to_i
$subnet_ip = "#{$default_subnet.split(%r{\.\d*$}).join('')}"
$master_ip = $subnet_ip + ".100"

Vagrant.configure("2") do |config|
# Master
  config.vm.define "master" do |master_conf|
    master_conf.vm.box = $image_version
    master_conf.vm.provider :virtualbox do |v|
       v.check_guest_additions = false
    end
    master_conf.vm.define vm_name = "master" do |config|
      config.vm.hostname = "master" 
      config.vm.provider :virtualbox do |vb|
        vb.gui = $vm_gui
        vb.memory = $vm_memory
        vb.cpus = $vm_cpus
      end
    end
    master_conf.vm.network :private_network, ip: $master_ip
    master_conf.vm.provision :shell, :path => "common.sh"
    master_conf.vm.provision :shell, :path => "master.sh", :args => "--subnet "+$subnet_ip
  end

# Worker config
  (1..$default_workers).each do |i|
    config.vm.define "worker-#{i}" do |worker_conf|
      worker_conf.vm.box = $image_version
      worker_conf.vm.provider :virtualbox do |v|
        v.check_guest_additions = false
      end
      worker_conf.vm.hostname = "worker-#{i}"
      worker_conf.vm.provider :virtualbox do |vb|
        vb.gui = $vm_gui
        vb.memory = $vm_memory
        vb.cpus = $vm_cpus
      end
      ip = $subnet_ip + "." + "#{i+150}"
      worker_conf.vm.network :private_network, ip: ip
      worker_conf.vm.provision :shell, :path => "common.sh"
      worker_conf.vm.provision :shell, :path => "worker.sh", :args => "--subnet "+$subnet_ip
    end
  end
end

