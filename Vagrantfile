# -*- mode: ruby -*-
# vi: set ft=ruby :

# Specify Vagrant version and Vagrant API version
Vagrant.require_version ">= 1.7.0"
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "centos/7"

  # Assign a friendly name to this host VM
  config.vm.hostname = "sugarcrm"

  # Skip checking for an updated Vagrant box
  config.vm.box_check_update = false

  config.vm.network "private_network", ip: "10.10.10.11"
  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 3306, host:3306
  config.vm.network "forwarded_port", guest: 9200, host:9200

  config.vm.synced_folder ".", "/var/www", nfs: true

  config.vm.provider "virtualbox" do |v|
    host = RbConfig::CONFIG['host_os']

    # Give VM 1/4 system memory & access to all cpu cores on the host
    if host =~ /darwin/
      cpus = `sysctl -n hw.ncpu`.to_i
      # sysctl returns Bytes and we need to convert to MB
      mem = `sysctl -n hw.memsize`.to_i / 1024 / 1024 / 3
    elsif host =~ /linux/
      cpus = `nproc`.to_i
      # meminfo shows KB and we need to convert to MB
      mem = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024 / 3
    else # sorry Windows folks, I can't help you
      cpus = 2
      mem = 1024
    end

    v.customize ["modifyvm", :id, "--memory", mem]
    v.customize ["modifyvm", :id, "--cpus", cpus]

  end

  # Setup the server
  config.vm.provision "shell", inline: <<-SHELL

  # Run as root
  sudo -s

  # fix permission issue by disabling SELinux
  sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

  ###################### Web Server ######################

  #reference - https://webtatic.com/packages/php54/

  # Enable EPEL
  su -c 'rpm -Uvh https://mirror.webtatic.com/yum/el7/epel-release.rpm'
  su -c 'rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm'

  #Installing PHP
  yum install -y php54w  php54w-cgi php54w-cli php54w-common php54w-curl php54w-gd php54w-mysql php54w-imap php54w-bcmath php54w-ldap php54w-pdo php54w-mbstring php54w-pecl-apc php54w-process php54w-soap php54w-xml

  #Installing apache, vim, and memcache
  yum install -y httpd mod_ssl vim memcached

  # Configure apache and PHP
  sed -i -e"s/^max_execution_time\s*=\s*30/max_execution_time = 300/" /etc/php.ini
  sed -i -e"s/^memory_limit\s*=\s*128M/memory_limit = 256M/" /etc/php.ini
  sed -i -e"s/^post_max_size\s*=\s*8M/post_max_size = 32M/" /etc/php.ini
  sed -i -e"s/^upload_max_filesize\s*=\s*2M/upload_max_filesize = 32M/" /etc/php.ini
  sed -i 's/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf
  sed -i 's|DocumentRoot "/var/www/html"|DocumentRoot "/var/www"|g' /etc/httpd/conf/httpd.conf

  #Cron job setup has been removed as it wil take more resources

  #Staring apache service
  systemctl enable httpd.service
  systemctl start httpd.service
  systemctl enable memcached
  systemctl start memcached


  ###################### MYSQL Server ######################

  rpm -Uvh http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm

  yum install -y mysql-server

  #Staring MYSQL service
  systemctl enable mysqld.service
  systemctl start mysqld.service

  # Setup root user
  mysql -e "GRANT ALL ON *.* to 'root'@'%'; FLUSH PRIVILEGES;"


  ###################### Elasticsearch ######################

  #Installing Java
  yum install -y java-1.8.0-openjdk.x86_64

  rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch

  echo "[elasticsearch-1.4]\nname=Elasticsearch repository for 1.4.x packages\nbaseurl=http://packages.elastic.co/elasticsearch/1.4/centos\ngpgcheck=1\ngpgkey=http://packages.elastic.co/GPG-KEY-elasticsearch\nenabled=1" > /etc/yum.repos.d/elasticsearch.repo

  #Installing elasticsearch
  yum install -y elasticsearch

  #Enabling elasticsearch service
  systemctl enable elasticsearch.service

  SHELL

end
