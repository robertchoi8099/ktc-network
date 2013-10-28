#
# Cookbook Name:: ktc-network
# Recipe:: server
#

include_recipe "services"
include_recipe "ktc-utils"

iface = KTC::Network.if_lookup "management"
ip = KTC::Network.address "management"

Services::Connection.new run_context: run_context
network_api = Services::Member.new node["fqdn"],
  service: "network-api",
  port: 9696,
  proto: "tcp",
  ip: ip

network_api.save
KTC::Attributes.set

# Use the managment address as the bind_address
node.set["openstack"]["network"]["api"]["bind_interface"] = iface

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

# process monitoring and sensu-check config
processes = node['openstack']['network']['server_processes']

processes.each do |process|
  sensu_check "check_process_#{process['name']}" do
    command "check-procs.rb -c 10 -w 10 -C 1 -W 1 -p #{process['name']}"
    handlers ["default"]
    standalone true
    interval 20
  end
end

collectd_processes "quantum-server-processes" do
  input processes
  key "shortname"
end
