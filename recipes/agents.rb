#
# Cookbook Name:: ktc-network
# Recipe:: agents
#

include_recipe "ktc-network::common"
include_recipe "openstack-network::linuxbridge"
include_recipe "openstack-network::dhcp_agent"
include_recipe "openstack-network::l3_agent"
include_recipe "openstack-network::metadata_agent"

chef_gem "chef-rewind"
require 'chef/rewind'

%w{ plugin-linuxbridge dhcp l3 metadata }.each do |agent|
  cookbook_file "/etc/init/quantum-#{agent}-agent.conf"
    source "init/quantum-#{agent}-agent.conf"
    action :create
  end
  
  rewind :service => "quantum-#{agent}-agent" do
    provider Chef::Provider::Service::Upstart
  end
end
