#
# Cookbook Name:: ktc-network
# Recipe:: server
#

include_recipe "services"
include_recipe "ktc-utils"

iface = KTC::Network.if_lookup "management"
ip = KTC::Network.address "management"

Services::Connection.new run_context: run_context
network_api = Services::Member.new node.fqdn,
  service: "network-api",
  port: 9696,
  proto: "tcp",
  ip: ip

network_api.save
KTC::Network.add_service_nat "network-api", 9696
KTC::Attributes.set

include_recipe "ktc-network::common"

chef_gem "chef-rewind"
require 'chef/rewind'

cookbook_file "/etc/init/quantum-server.conf" do
  source "etc/init/quantum-server.conf"
  action :create
end

# start quantum-server later than quantum-server init script is created
include_recipe "openstack-network::server"

rewind :service => "quantum-server" do
  provider Chef::Provider::Service::Upstart
  action [:enable, :start]
end
