#
# Cookbook Name:: ktc-network
# Recipe:: common
#

include_recipe "ktc-network::source_install"
include_recipe "openstack-network::common"

chef_gem "chef-rewind"
require 'chef/rewind'

rewind :template => "/etc/quantum/quantum.conf" do
  cookbook_name "ktc-network"
end

platform_options = node["openstack"]["network"]["platform"]

driver_name = node["openstack"]["network"]["interface_driver"]
driver_name = driver_name.split('.').last.downcase
main_plugin = node["openstack"]["network"]["interface_driver_map"][driver_name]

case main_plugin
when "linuxbridge"

include_recipe "services"
include_recipe "ktc-utils"

  pif = KTC::Network.if_lookup "private"
  iface = "#{node["openstack"]["network"]["linuxbridge"]["physical_network"]}:#{pif}"
  node.set["openstack"]["network"]["linuxbridge"]["physical_interface_mappings"] = iface

  rewind :template => "/etc/quantum/plugins/linuxbridge/linuxbridge_conf.ini" do
    cookbook_name "ktc-network"
  end

end
