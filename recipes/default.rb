#
## Cookbook Name:: ktc-network
## Recipe:: default
##

include_recipe "openstack-common"
include_recipe "ktc-logging::logging"
include_recipe "ktc-network::server"
include_recipe "openstack-network::identity_registration"
if node["openstack"]["network"]["ng_l3"]["setup_entities"]
  include_recipe "ktc-network::setup_entities"
end
