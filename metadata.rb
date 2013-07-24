maintainer        "KT Cloudware, Inc."
description	  "Installs/Configures Openstack Network Service"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.2.0"
recipe		 "ktc-network::default", "Installs packages required for network-server"

%w{ ubuntu fedora }.each do |os|
  supports os
end

%w{
  ktc-utils
  openstack-common
  openstack-network
}.each do |dep|
  depends dep
end
