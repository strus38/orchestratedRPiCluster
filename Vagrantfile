# kuberverse k8s lab provisioner
# dependencies: https://raw.githubusercontent.com/strus38/orchestratedRPiCluster/master/common.sh
#               https://raw.githubusercontent.com/strus38/orchestratedRPiCluster/master/master.sh
#               https://raw.githubusercontent.com/strus38/orchestratedRPiCluster/master/worker.sh

BOX_IMAGE = "bento/ubuntu-20.04"
BOX_IMAGE_VERSION = "202008.16.0"
MASTER_COUNT = 1
WORKER_COUNT = 4
POD_CIDR = "172.18.0.0/16"
API_ADV_ADDRESS = "10.0.0.210"
ETH1_NAME="Realtek USB GbE Family Controller"
KVMSG = "Kuberverse"
COMMON_SCRIPT_URL = "https://raw.githubusercontent.com/strus38/orchestratedRPiCluster/master/common.sh"
MASTER_SCRIPT_URL = "https://raw.githubusercontent.com/strus38/orchestratedRPiCluster/master/master.sh"
WORKER_SCRIPT_URL = "https://raw.githubusercontent.com/strus38/orchestratedRPiCluster/master/worker.sh"

Vagrant.configure("2") do |config|
  if Vagrant::Util::Platform.windows? then
    unless Vagrant.has_plugin?("vagrant-winnfsd")
      raise  Vagrant::Errors::VagrantError.new, "vagrant-winnfsd plugin is missing. Please install it using 'vagrant plugin install vagrant-winnfsd' and rerun 'vagrant up'"
    end
    unless Vagrant.has_plugin?("vagrant-cachier")
      raise  Vagrant::Errors::VagrantError.new, "vagrant-cachier plugin is missing. Please install it using 'vagrant plugin install vagrant-cachier' and rerun 'vagrant up'"
    end
  end
  # Installing the necessary packages for this provisioner  
  config.vm.provision "shell" do |s|
      s.inline = <<-SCRIPT
         mkdir -p /home/vagrant/.kv
         wget -q #{COMMON_SCRIPT_URL} -O /home/vagrant/.kv/common.sh
         chmod +x /home/vagrant/.kv/common.sh
         /home/vagrant/.kv/common.sh #{KVMSG}
      SCRIPT
  end

  (0..MASTER_COUNT-1).each do |i|
    config.vm.define "kv-master-#{i}" do |subconfig|
      subconfig.vm.box = BOX_IMAGE
      subconfig.vm.box_version = BOX_IMAGE_VERSION
      subconfig.cache.scope = :box
      subconfig.vm.synced_folder 'src/', "/var/www", 
        type:"nfs", 
        mount_options: %w{rw,async,fsc,nolock,vers=3,udp,rsize=32768,wsize=32768,hard,noatime,actimeo=2}
      subconfig.vm.hostname = "kv-master-#{i}"
      subconfig.vm.network :public_network, ip: "10.0.0.2#{i + 10}", bridge: "#{ETH1_NAME}"
      subconfig.vm.network :private_network, ip: "172.28.128.2#{i + 10}"
      subconfig.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--cpus", 2]
        vb.memory = 2048
      end

      # This if is here just to remember me to create a multi-master cluster
      # the behavior and overal configuration is different and this will require a HAProxy installation
      if i == 0

        subconfig.vm.provision "shell" do |s|
          s.inline = <<-SCRIPT
            mkdir -p /home/vagrant/.kv
            wget -q #{MASTER_SCRIPT_URL} -O /home/vagrant/.kv/master.sh
            chmod +x /home/vagrant/.kv/master.sh
            /home/vagrant/.kv/master.sh #{KVMSG} #{i} #{POD_CIDR} #{API_ADV_ADDRESS}
          SCRIPT
        end

      end

    end
  end
  
  (0..WORKER_COUNT-1).each do |i|
    config.vm.define "kv-worker-#{i}" do |subconfig|
      subconfig.vm.box = BOX_IMAGE
      subconfig.vm.box_version = BOX_IMAGE_VERSION
      subconfig.cache.scope = :box
      subconfig.vm.synced_folder 'src/', "/var/www", 
        type:"nfs", 
        mount_options: %w{rw,async,fsc,nolock,vers=3,udp,rsize=32768,wsize=32768,hard,noatime,actimeo=2}
      subconfig.vm.hostname = "kv-worker-#{i}"
      subconfig.vm.network :public_network, ip: "10.0.0.2#{i + 20}", bridge: "#{ETH1_NAME}"
      subconfig.vm.network :private_network, ip: "172.28.128.2#{i + 20}"
      subconfig.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--cpus", 2]
        vb.memory = 3072
      end

      subconfig.vm.provision "shell" do |s|
        s.inline = <<-SCRIPT
          mkdir -p /home/vagrant/.kv
          wget -q #{WORKER_SCRIPT_URL} -O /home/vagrant/.kv/worker.sh
          chmod +x /home/vagrant/.kv/worker.sh
          /home/vagrant/.kv/worker.sh #{KVMSG} #{i} #{POD_CIDR} #{API_ADV_ADDRESS}
        SCRIPT
      end

    end
  end

  config.vm.provision "shell",
   run: "always",
   inline: "swapoff -a"

end