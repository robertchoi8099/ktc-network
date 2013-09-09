#
# Cookbook Name:: ktc-network
# Recipe:: agents
#
include_recipe "sysctl::default"

class Chef::Recipe
  include KTCUtils
end

set_rabbit_servers "network"
set_database_servers "network"

platform_options = node["openstack"]["network"]["platform"]

driver_name = node["openstack"]["network"]["interface_driver"]
driver_name = driver_name.split('.').last.downcase
main_plugin = node["openstack"]["network"]["interface_driver_map"][driver_name]

include_recipe "ktc-network::common"
include_recipe "ktc-network::#{main_plugin}"

# get metadata endpoint and set attribute for metadata_agent.ini to use it.
set_service_endpoint "compute-metadata-api"
ip = node["openstack"]["endpoints"]["compute-metadata-api"]["host"]
port = node["openstack"]["endpoints"]["compute-metadata-api"]["port"]
node.set["openstack"]["network"]["metadata"]["nova_metadata_ip"] = ip
node.set["openstack"]["network"]["metadata"]["nova_metadata_port"] = port

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

  rewind :template => "/etc/quantum/#{agent}_agent.ini" do
    cookbook_name "ktc-network"
  end
end

rewind :package => "quantum-plugin-#{main_plugin}" do
  action :nothing
end
