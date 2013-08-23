#
# Cookbook Name:: ktc-network
# Recipe:: server
#
class Chef::Recipe
  include KTCUtils
end

d = get_openstack_service_template(get_interface_address("management"), "9696")
register_member("network-api", d)

set_rabbit_servers "network"
set_database_servers "network"
set_service_endpoint_ip "network-api"

include_recipe "ktc-network::common"
include_recipe "openstack-network::server"

chef_gem "chef-rewind"
require 'chef/rewind'

cookbook_file "/etc/init/quantum-server.conf" do
  source "etc/init/quantum-server.conf"
  action :create
end

rewind :service => "quantum-server" do
  provider Chef::Provider::Service::Upstart
end
