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

driver_name = node["openstack"]["network"]["interface_driver"].split('.').last.downcase
main_plugin = node["openstack"]["network"]["interface_driver_map"][driver_name]

case main_plugin
when "linuxbridge"

  class Chef::Recipe
    include KTCUtils
  end
  
  physical_interface = get_interface "private"
  node.set["openstack"]["network"]["linuxbridge"]["physical_interface_mappings"] = "#{node["openstack"]["network"]["linuxbridge"]["physical_network"]}:#{physical_interface}"

  rewind :template => "/etc/quantum/plugins/linuxbridge/linuxbridge_conf.ini" do
    cookbook_name "ktc-network"
  end

end
