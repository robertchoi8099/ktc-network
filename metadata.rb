name          "ktc-network"
maintainer    "KT Cloudware, Inc."
description	  "Installs/Configures Openstack Network Service"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.2.20'
recipe		  "ktc-network::default", "Installs packages required for network-server"

%w{ ubuntu fedora }.each do |os|
  supports os
end

depends "git"
depends "ktc-utils", "> 0.3.1"
depends "openstack-common", "~> 0.4.3"
depends "openstack-network", "~> 7.0.0"
depends "python"
depends "services"
depends "sudo"
depends "sysctl"
depends "simple_iptables"
depends "modules"
depends "ktc-monitor"
depends "ktc-logging"
