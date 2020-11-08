# -*- mode: ruby -*-
# vi: set ft=ruby :

$squidsetup = <<-SCRIPT
apt update
# apt upgrade -y

apt install -y squid apache2-utils ruby vim curl mlocate tcpdump rsync
echo "set background=dark"|tee -a ~/.vimrc

rsync -av /vagrant/squid_htpasswd /etc/squid/htpasswd
rsync -av /vagrant/squid.conf /etc/squid/squid.conf
rsync -av /vagrant/note.rb /usr/local/bin/note.rb
rsync -av /vagrant/user-to-ip.txt /etc/squid/user-to-ip.txt

chmod +x /usr/local/bin/note.rb
chown proxy:proxy /etc/squid -R

/vagrant/add-ip-range.rb 192.168.10.101 192.168.10. 102 200
/vagrant/collect-32-subnet-addresses.rb >/etc/squid/outgoing.conf

systemctl enable --now squid
systemctl reload squid
touch $HOME/.hushlogin

/vagrant/generate-htpasswd.rb /etc/squid/htpasswd 01 80
/vagrant/generate-user-to-ip.rb /etc/squid/user-to-ip.txt 01 80
SCRIPT

$websetup = <<-SCRIPT
apt update
# apt upgrade -y

apt install -y apache2 php rsync vim mlocate
systemctl enable --now apache2
echo "<?php phpinfo(); ?>" > /var/www/html/info.php
echo '<?php echo $_SERVER["REMOTE_ADDR"]."\n"; ?>' > /var/www/html/ip.php
SCRIPT

instances = ["squid", "web"]

vmgui = false

ENV["VAGRANT_DEFAULT_PROVIDER"] = "virtualbox"

Vagrant.configure("2") do |config|
  config.vm.boot_timeout = 300
  # config.vm.box = "ubuntu/xenial64" # 18.04
  # config.vm.box = "ubuntu/focal64" # 20.04
  # config.vm.box = "ubuntu/bionic4" # 16.04
  # config.vm.box = "debian/buster64" # 10.4.0

  # config.vm.box = "bento/ubuntu-20.04"
  # config.vm.box = "bento/ubuntu-18.04"
  # config.vm.box = "bento/ubuntu-16.04"

  # config.vm.box = "bento/debian-10.6"

  instances.each_with_index.map do |item, index|
    config.vm.define item do |node|
      node.vm.synced_folder "shared", "/vagrant", type: "virtualbox"
      # node.vm.synced_folder "./shared", "/vagrant",  type: "rsync", automount: true
      config.vm.box = "bento/ubuntu-20.04"
      node.vm.hostname = item

      node.vm.provider :virtualbox do |vbox|
        vbox.gui = vmgui
        vbox.memory = "1024"
        vbox.name = item
        # "ubuntu/focal64" image boot issue workaround tests
        # vbox.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
        # vbox.customize ["modifyvm", :id, "--uartmode1", "file", File::NULL]
      end

      case item
      when "squid"
        node.vm.network "private_network", ip: "192.168.10.101", netmask: "255.255.255.0", virtualbox__intnet: "squidnet"
        node.vm.provision "shell", inline: $squidsetup
      when "web"
        node.vm.network "private_network", ip: "192.168.10.80", netmask: "255.255.255.0", virtualbox__intnet: "squidnet"
        node.vm.provision "shell", inline: $websetup
      end
    end
  end
end
