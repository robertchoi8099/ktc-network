#
# Cookbook Name:: ktc-network
# Recipe:: agents
#

platform_options = node["openstack"]["network"]["platform"]

driver_name = node["openstack"]["network"]["interface_driver"].split('.').last.downcase
main_plugin = node["openstack"]["network"]["interface_driver_map"][driver_name]

include_recipe "ktc-network::common"
include_recipe "ktc-network::#{main_plugin}"

chef_gem "chef-rewind"
require 'chef/rewind'

%w{ dhcp l3 metadata }.each do |agent|

  cookbook_file "/etc/init/quantum-#{agent}-agent.conf" do
    source "etc/init/quantum-#{agent}-agent.conf"
    action :create
    notifies :restart, "service[quantum-#{agent}-agent]", :immediately
  end
  
  include_recipe "openstack-network::#{agent}_agent"
  rewind :service => "quantum-#{agent}-agent" do
    provider Chef::Provider::Service::Upstart
  end
end

# from openstack-network::l3_agent
rewind :execute => "create external network bridge" do
  action :nothing
end

rewind :package => "quantum-plugin-#{main_plugin}" do
  action :nothing
end
