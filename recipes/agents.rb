#
# Cookbook Name:: ktc-network
# Recipe:: agents
#

platform_options = node["openstack"]["network"]["platform"]

driver_name = node["openstack"]["network"]["interface_driver"].split('.').last.downcase
main_plugin = node["openstack"]["network"]["interface_driver_map"][driver_name]

include_recipe "ktc-network::common"
include_recipe "openstack-network::#{main_plugin}"
include_recipe "openstack-network::dhcp_agent"
include_recipe "openstack-network::l3_agent"
include_recipe "openstack-network::metadata_agent"

chef_gem "chef-rewind"
require 'chef/rewind'

agent_list = [ "plugin-#{main_plugin}" ].concat(%w{ dhcp l3 metadata })
agent_list.each do |agent|
  cookbook_file "/etc/init/quantum-#{agent}-agent.conf" do
    source "etc/init/quantum-#{agent}-agent.conf"
    action :create
  end
  
  rewind :service => "quantum-#{agent}-agent" do
    provider Chef::Provider::Service::Upstart
  end
end

rewind :package => "quantum-plugin-#{main_plugin}" do
  action :nothing
end
