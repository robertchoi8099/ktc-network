require 'uri'

include_recipe "ktc-network::common"

identity_endpoint = endpoint "identity-api"
auth_uri = ::URI.decode identity_endpoint.to_s
service_pass = service_password "openstack-network"

physical_net = node["openstack"]["network"]["linuxbridge"]["physical_network"] 
network_id = node["openstack"]["network"]["l3"]["network_id"]
ktc_network_network "Create Private Network" do
  auth_uri    auth_uri
  user_pass   service_pass
  tenant_name node["openstack"]["network"]["service_tenant_name"]
  user_name   node["openstack"]["network"]["service_user"]
  options(
    "name" => physical_net,
    "multihost:multi_host" => true,
    "provider:network_type" => "flat",
    "provider:physical_network" => physical_net,
    "shared" => true
  )
  action :create
end

ktc_network_router "Create Private Router" do
  auth_uri    auth_uri
  user_pass   service_pass
  tenant_name node["openstack"]["network"]["service_tenant_name"]
  user_name   node["openstack"]["network"]["service_user"]
  options(
    "name" => node["openstack"]["network"]["l3"]["router_name"],
    "multihost:network_id" => network_id
  )
  action :create
end

ktc_network_subnet "Create Private Subnet" do
  auth_uri    auth_uri
  user_pass   service_pass
  tenant_name node["openstack"]["network"]["service_tenant_name"]
  user_name   node["openstack"]["network"]["service_user"]
  options(
    "network_id" => network_id,
    "cidr" => node["openstack"]["network"]["linuxbridge"]["physical_cidr"],
    "dns_nameservers" => node["openstack"]["network"]["linuxbridge"]["dns_nameservers"],
    "name" => node["openstack"]["network"]["linuxbridge"]["physical_subnet"]
  )
  action :create
end

ktc_network_router "Add Private Subnet to Private Router" do
  auth_uri    auth_uri
  user_pass   service_pass
  tenant_name node["openstack"]["network"]["service_tenant_name"]
  user_name   node["openstack"]["network"]["service_user"]
  options(
    "id" => node["openstack"]["network"]["l3"]["router_id"],
    "subnet_id" => node["openstack"]["network"]["l3"]["subnet_id"]
  )
  action :add_interface
end
