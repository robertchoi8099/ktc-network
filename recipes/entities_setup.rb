require 'uri'

include_recipe "ktc-network::common"

identity_endpoint = endpoint "identity-api"
auth_uri = ::URI.decode identity_endpoint.to_s
service_pass = service_password "openstack-network"

private_net = node["openstack"]["network"]["linuxbridge"]["physical_network"] 
private_net_options = {
  "name" => private_net,
  "multihost:multi_host" => true,
  "provider:network_type" => "flat",
  "provider:physical_network" => private_net,
  "shared" => true
}
 
ktc_network_network "Create Private Network" do
  auth_uri    auth_uri
  user_pass   service_pass
  tenant_name node["openstack"]["network"]["service_tenant_name"]
  user_name   node["openstack"]["network"]["service_user"]
  options     private_net_options
  action :create
end

ktc_network_router "Create Private Router" do
  auth_uri    auth_uri
  user_pass   service_pass
  tenant_name node["openstack"]["network"]["service_tenant_name"]
  user_name   node["openstack"]["network"]["service_user"]
  search_id(
    :network => private_net_options
  )
  options(
    "name" => node["openstack"]["network"]["l3"]["router_name"],
    "multihost:network_id" => :network
  )
  action :create
end

ktc_network_subnet "Create Private Subnet" do
  auth_uri    auth_uri
  user_pass   service_pass
  tenant_name node["openstack"]["network"]["service_tenant_name"]
  user_name   node["openstack"]["network"]["service_user"]
  search_id(
    :network => private_net_options
  )
  options(
    "network_id" => :network,
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
  search_id(
    :router => {
      "name" => node["openstack"]["network"]["l3"]["router_name"],
    },
    :subnet => {
      "cidr" => node["openstack"]["network"]["linuxbridge"]["physical_cidr"],
      "dns_nameservers" => node["openstack"]["network"]["linuxbridge"]["dns_nameservers"],
      "name" => node["openstack"]["network"]["linuxbridge"]["physical_subnet"]
    }
  )
  options(
    "id" => :router,
    "subnet_id" => :subnet
  )
  action :add_interface
end

floating_net_options = {
  "name" => node["openstack"]["network"]["l3"]["floating_network"],
  "router:external" => true
}

ktc_network_network "Create Floating Network" do
  auth_uri    auth_uri
  user_pass   service_pass
  tenant_name node["openstack"]["network"]["service_tenant_name"]
  user_name   node["openstack"]["network"]["service_user"]
  options floating_net_options
  action :create
end

node["openstack"]["network"]["l3"]["floating_ips"].each do |floating_ip|
  ktc_network_subnet "Create Floating Subnet" do
    auth_uri    auth_uri
    user_pass   service_pass
    tenant_name node["openstack"]["network"]["service_tenant_name"]
    user_name   node["openstack"]["network"]["service_user"]
    search_id(
      :network => floating_net_options
    )
    options(
      "network_id" => :network,
      "cidr" => floating_ip
    )
    action :create
  end
end

ktc_network_router "Set Private Router's gateway to Floating Network" do
  auth_uri    auth_uri
  user_pass   service_pass
  tenant_name node["openstack"]["network"]["service_tenant_name"]
  user_name   node["openstack"]["network"]["service_user"]
  search_id(
    :router => {
      "name" => node["openstack"]["network"]["l3"]["router_name"],
    },
    :network => floating_net_options
  )
  options(
    "id" => :router,
    "external_gateway_info" => {
      "network_id" => :network
    }
  )
  action :update
end
