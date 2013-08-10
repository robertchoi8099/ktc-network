#
# Cookbook Name:: ktc-network
# Recipe:: server
#

include_recipe "ktc-network::common"
include_recipe "openstack-network::server"

chef_gem "chef-rewind"
require 'chef/rewind'

cookbook_file "/etc/init/quantum-server.conf"
  source "init/quantum-server.conf"
  action :create
end

rewind :service => "quantum-server" do
  provider Chef::Provider::Service::Upstart
end
