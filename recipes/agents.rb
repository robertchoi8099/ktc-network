#
# Cookbook Name:: ktc-network
# Recipe:: agents
#
include_recipe "openstack-common"
include_recipe "openstack-common::logging"
include_recipe "sysctl::default"
include_recipe "services"
include_recipe "ktc-utils"

KTC::Attributes.set

platform_options = node["openstack"]["network"]["platform"]

driver_name = node["openstack"]["network"]["interface_driver"]
driver_name = driver_name.split('.').last.downcase
main_plugin = node["openstack"]["network"]["interface_driver_map"][driver_name]

include_recipe "ktc-network::common"
include_recipe "ktc-network::#{main_plugin}"

ip = node["openstack"]["endpoints"]["compute-metadata-api"]["host"]
port = node["openstack"]["endpoints"]["compute-metadata-api"]["port"]
node.set["openstack"]["network"]["metadata"]["nova_metadata_ip"] = ip
node.set["openstack"]["network"]["metadata"]["nova_metadata_port"] = port

networks = ["openstack"]["network"]["ng_l3"]["networks"].select do |n|
  n["zone"] == node["openstack"]["availability_zone"]
end
node.set["openstack"]["network"]["metadata_network"] = networks.join(",")
node.set["openstack"]["network"]["enabled_networks"] = networks.join(",")

chef_gem "chef-rewind"
require 'chef/rewind'

%w{ dhcp metadata }.each do |agent|

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
