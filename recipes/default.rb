#
## Cookbook Name:: ktc-network
## Recipe:: default
##

class Chef::Recipe
  include KTCUtils
end

d = get_openstack_service_template(get_interface_address("management"), "9696")
register_service("network-api", d)

set_rabbit_servers "network"
set_service_endpoint_ip "network-api"

include_recipe "openstack-common"
include_recipe "openstack-common::logging"
include_recipe "openstack-network::server"
include_recipe "openstack-network::identity_registration"
