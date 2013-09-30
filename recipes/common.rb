#
# Cookbook Name:: ktc-network
# Recipe:: common
#

include_recipe "ktc-utils"

iface = KTC::Network.if_lookup "management"
node.set["openstack"]["network"]["api"]["bind_interface"] = iface

include_recipe "ktc-network::source_install"
include_recipe "openstack-network::common"

chef_gem "chef-rewind"
require 'chef/rewind'

rewind :template => "/etc/quantum/quantum.conf" do
  cookbook_name "ktc-network"
end
