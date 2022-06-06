# vim: set ft=ruby

Vagrant.configure(2) do |config|

  config.vm.define :freebsd1 do |freebsd1|
    freebsd1.vm.box = "freebsd/FreeBSD-10.2-RELEASE"
    freebsd1.vm.hostname = "freebsd1"
    freebsd1.vm.network "private_network", ip: "10.0.10.5", adapter: 2
    freebsd1.vm.base_mac = "080027D14C66"
    freebsd1.vm.synced_folder ".", "/vagrant", type: "nfs"
    freebsd1.ssh.shell = "/bin/sh"
    freebsd1.vm.provider "virtualbox" do |vb|
       vb.memory = 512
       vb.cpus = 1
       vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
       vb.customize ["modifyvm", :id, "--nictype2", "virtio"]
       vb.customize ["modifyvm", :id, "--hwvirtex", "on"]
       vb.customize ["modifyvm", :id, "--ioapic", "on"]
    end
    freebsd1.vm.provision "ansible" do |ansiblefreebsd1|
      ansiblefreebsd1.playbook = "freebsd.yml"
      ansiblefreebsd1.sudo = true
    end
  end

  config.vm.define :centos1 do |centos1|
    centos1.vm.box = "geerlingguy/centos7"
    centos1.vm.hostname = "centos1"
    centos1.vm.network "private_network", ip: "10.0.10.6"
    centos1.vm.network :forwarded_port, guest: 22, host: 10106
    centos1.vm.synced_folder ".", "/vagrant"
    centos1.vm.provider "virtualbox" do |vb|
       vb.memory = 512
       vb.cpus = 1
    end
    centos1.vm.provision "ansible" do |ansiblecentos1|
      ansiblecentos1.playbook = "centos.yml"
      ansiblecentos1.sudo = true
    end
  end

  config.vm.define :debian1 do |debian1|
    debian1.vm.box = "Jessie-v0.1"
    debian1.vm.hostname = "debian1"
    debian1.vm.network "private_network", ip: "10.0.10.7"
    debian1.vm.network :forwarded_port, guest: 22, host: 10107
    debian1.vm.synced_folder ".", "/vagrant"
    debian1.vm.provider "virtualbox" do |vb|
       vb.memory = 512
       vb.cpus = 1
    end
    debian1.vm.provision "ansible" do |ansibledebian1|
      ansibledebian1.playbook = "debian.yml"
      ansibledebian1.sudo = true
    end
  end

end
