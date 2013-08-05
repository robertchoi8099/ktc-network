#
## Cookbook Name:: ktc-network
## Recipe:: default
##

class Chef::Recipe
  include KTCUtils
end

set_rabbit_servers "network"
set_service_endpoint_ip "network-api"

include_recipe "openstack-common"
include_recipe "openstack-common::logging"
include_recipe "openstack-network::server"
include_recipe "openstack-network::identity_registration"
