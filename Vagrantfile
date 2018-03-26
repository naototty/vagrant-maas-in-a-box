# -*- mode: ruby -*-
# vi: set ft=ruby :

# Setup our MAAS and node boxes
# MAAS will use Virtualbox and 1024M RAM
# Nodes will use Virtualbox and 512M RAM
# Recommended to have at least 6G RAM with roughly 2G free disk space

DEPLOY_MAAS = 0
deploy_IRONIC = 0

if DEPLOY_MAAS == 0
  deploy_IRONIC = 1
end

# MAAS Properties
if DEPLOY_MAAS == 1
  MAAS_MEM = '1024'
elsif DEPLOY_MAAS == 0
  ## MAAS_MEM = '8192'
  MAAS_MEM = '4096'
end
# Node Properties
NODE_MEM = '512'

if num_nodes_str = ENV['MAAS_NUM_NODES']
  num_nodes = num_nodes_str.to_i + 1
else
  ## num_nodes = 10
  num_nodes = 2
end

if ENV['MAAS_NODE_GUI']
  gui_mode = true
  puts "Running in gui mode"
else
  gui_mode = false
end

VAGRANT_DISABLE_VBOXSYMLINKCREATE=1

# IP's range at 192.168.50.[101:1xx] - gives you 99 nodes plus 1 maas instance
# Keep this in mind when configuring your cluster controller's min/max ip ranges
BOXES = { maas: { ip: "192.168.50.99" } }
# 初期値として、BOXES (hash) を定義しているけど、次のhashで上書きしている?
# ==> 単に"maas" という名称が使われているので、skip しているだけかも
(1..num_nodes).each do |i|
  if i < 10
    gen_ip = "192.168.50.10#{i}"
  else
    gen_ip = "192.168.50.1#{i}"
  end
  BOXES["node#{i}".to_sym] = { ip: gen_ip }
end

$do_01_yum_script = <<SCRIPT_AA
echo I am provisioning...
    sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    sudo yum -y install ansible
    cd /vagrant/provision; sudo ansible-playbook -i localhost vagrant.yml
SCRIPT_AA

$do_02_yum_apt = <<SCRIPT_AB
echo I am provisioning...
    sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    sudo yum -y install ansible
    cd /vagrant/provision; sudo ansible-playbook -i localhost vagrant.yml
SCRIPT_AB


master_node_host_name = "maascontroller"
if deploy_IRONIC == 1
  master_node_host_name = "bare-ironic-controller"
end 

Vagrant.configure("2") do |config|
  # Define our MAAS instance
  config.vm.define "maas", primary: true do |maas|
    ## maas.vm.box = "ubuntu/trusty64"
    maas.vm.box = "ubuntu/xenial64"
    maas.vm.box_version = "20180322.0.0"
    ## maas.vm.hostname = "maascontroller"
    maas.vm.hostname = master_node_host_name
    if deploy_IRONIC == 1
      ## https://app.vagrantup.com/centos/boxes/7/versions/1705.02
      ## maas.vm.box = "centos/7"
      ## maas.vm.box_version = "1705.02" 20180322.0.0
      maas.vm.box = "ubuntu/xenial64"
      maas.vm.box_version = "20180322.0.0"
      maas.disksize.size = '60GB'
      ## maas.vm.hostname = "bare-ironic-controller"
    end
    maas.vm.network :private_network, ip: '192.168.50.99'
    maas.vm.network :forwarded_port, guest: 80, host: 8080
    maas.vm.provider "virtualbox" do |vbox|
      vbox.gui = gui_mode
      ## vbox.name = "maascontroller"
      vbox.name = master_node_host_name
      vbox.customize ["modifyvm", :id, "--memory", "#{MAAS_MEM}"]
    end
    ## OS=Windows_NT
    if /Windows_NT/ =~ "#{ENV['OS']}"
      if DEPLOY_MAAS == 1
        maas.vm.provision "shell" do |s|
          s.inline = "ls -l /vagrant/ > /vagrant/log-shell-inline-maas.log"
        end
        maas.vm.provision "ansible_local" do |lo_ansible|
          lo_ansible.verbose = "vvv"
          lo_ansible.playbook = "deploy/maas.yml"
        end
      elsif DEPLOY_MAAS == 0
        maas.vm.provision "shell" do |s|
          s.inline = "ls -l /vagrant/ > /vagrant/log-shell-inline-ironic.log"
        end
        maas.vm.provision "ansible_local" do |lo_ansible|
          lo_ansible.verbose = "vvv"
          lo_ansible.playbook = "deploy/os-ironic.yml"
        end
      end
    else
      maas.vm.provision "ansible" do |ansible|
        ansible.verbose = "vvv"
        if DEPLOY_MAAS == 1
          ansible.playbook = "deploy/maas.yml"
          # ansible.inventory_path = "deploy/hosts"
          # ansible.inventory_path = ".vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory"
          if Vagrant::Util::Platform::cygwin?
            ansible.raw_arguments = ["--inventory-file=.vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory"]
          end
          #if File.file?(".vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory")
          #  ansible.inventory_path = ".vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory"
          #end
          #ansible.limit = 'all'
        elsif DEPLOY_MAAS == 0
          ansible.playbook = "deploy/os-ironic.yml"
          # ansible.inventory_path = "deploy/hosts"
          # ansible.inventory_path = ".vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory"
          if Vagrant::Util::Platform::cygwin?
            ansible.raw_arguments = ["--inventory-file=.vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory"]
          end
          #if File.file?(".vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory")
          #  ansible.inventory_path = ".vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory"
          #end
          #ansible.limit = 'all'
        end
      end
    end
    ## end config
  end

  # Define our nodes
  BOXES.each do |node_name, node_config|
    config.vm.define(node_name.to_sym) do |vm_conf|
      if "#{NODE_MEM}" != "maas"
        ## vm_conf.vm.box = "ubuntu/trusty64"
        vm_conf.vm.box = "ubuntu/xenial64"
        vm_conf.vm.box_version = "20180322.0.0"
        vm_conf.vm.hostname = "#{node_name}"
        vm_conf.vm.network :private_network, ip: node_config[:ip]
        vm_conf.vm.provider "virtualbox" do |vbox|
          vbox.gui = gui_mode
          vbox.name = "#{node_name}"
          vbox.customize ["modifyvm", :id, "--memory", "#{NODE_MEM}"]
          vbox.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
          vbox.customize ["modifyvm", :id, "--boot1", "net"]
          vbox.customize ["modifyvm", :id, "--boot2", "disk"]
        end
        ## OS=Windows_NT
        if /Windows_NT/ =~ "#{ENV['OS']}"
          vm_conf.vm.provision "shell" do |s|
            s.inline = "ls -l /vagrant/ > /vagrant/log-shell-inline-nodes.log"
          end
          vm_conf.vm.provision "ansible_local" do |lo_ansible|
            lo_ansible.verbose = "vvv"
            lo_ansible.playbook = "deploy/nodes.yml"
          end
        else
          vm_conf.vm.provision "ansible" do |ansible|
            ansible.verbose = "vvv"
            ansible.playbook = "deploy/nodes.yml"
            # ansible.inventory_path = "deploy/hosts"
            # ansible.inventory_path = ".vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory"
            if Vagrant::Util::Platform::cygwin?
              ansible.raw_arguments = ["--inventory-file=.vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory"]
            end
            #if File.file?(".vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory")
            #  ansible.inventory_path = ".vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory"
            #end
            #ansible.limit = 'all'
          end
        end
        ## end if OS=Windows_NT else
      end
      ## end if "#{NODE_MEM}" != "maas"
    end
    ## end config
  end
  ## end BOXES.each do
end
## end Vagrant.configure("2") do |config|


