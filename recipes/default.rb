#
## Cookbook Name:: ktc-network
## Recipe:: default
##

include_recipe "openstack-common"
include_recipe "openstack-common::logging"
include_recipe "ktc-network::server"
include_recipe "openstack-network::identity_registration"
include_recipe "ktc-network::setup_entities"
