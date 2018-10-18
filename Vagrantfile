# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

config.vm.box = "ubuntu/xenial64"
config.vm.boot_timeout = 120
config.vm.synced_folder '.', '/vagrant', disabled: true

config.vm.provider "virtualbox" do |vb|
    # Customize the amount of memory on the VM:
    vb.memory = "1024"
end


config.vm.define "admin" do |admin|
    admin.vm.network "private_network", ip: "192.168.77.5"
    
    admin.vm.provision "ansible" do |ansible|
        ansible.playbook="ansible/admin.yml"
        # Run commands as root.
        ansible.become = true
    end
end


config.vm.define "node1" do |node1|
    node1.vm.network "private_network", ip: "192.168.77.10"
    node1.vm.hostname = "node1"
    node1.vm.provider :virtualbox do |vb|
        file_to_disk = 'node1.vdi'
        unless File.exist?(file_to_disk)
            # 20 GB
            vb.customize ['createhd', '--filename', file_to_disk, '--size', 20 * 1024]
        end
        vb.customize ['storageattach', :id, '--storagectl', 'SCSI', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', file_to_disk]
    end
    node1.vm.provision "ansible" do |ansible|
        ansible.playbook="ansible/node_master.yml"
        # Run commands as root.
        ansible.become = true
    end
end

config.vm.define "node2" do |node2|
    node2.vm.network "private_network", ip: "192.168.77.20"
    node2.vm.hostname = "node2"
    node2.vm.provider :virtualbox do |vb|
        file_to_disk = 'node2.vdi'
        unless File.exist?(file_to_disk)
            # 20 GB
            vb.customize ['createhd', '--filename', file_to_disk, '--size', 20 * 1024]
        end
        vb.customize ['storageattach', :id, '--storagectl', 'SCSI', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', file_to_disk]
    end
    node2.vm.provision "ansible" do |ansible|
        ansible.playbook="ansible/node.yml"
        # Run commands as root.
        ansible.become = true
    end
end

config.vm.define "node3" do |node3|
    node3.vm.network "private_network", ip: "192.168.77.30"
    node3.vm.hostname = "node3"
    node3.vm.provider :virtualbox do |vb|
        file_to_disk = 'node3.vdi'
        unless File.exist?(file_to_disk)
            # 20 GB
            vb.customize ['createhd', '--filename', file_to_disk, '--size', 20 * 1024]
        end
        vb.customize ['storageattach', :id, '--storagectl', 'SCSI', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', file_to_disk]
    end
    node3.vm.provision "ansible" do |ansible|
        ansible.playbook="ansible/node.yml"
        # Run commands as root.
        ansible.become = true
     end
end





end
