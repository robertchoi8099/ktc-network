require 'uri'

include_recipe "ktc-network::common"

identity_endpoint = endpoint "identity-api"
auth_uri = ::URI.decode identity_endpoint.to_s
service_pass = service_password "openstack-network"
tenant_name = node["openstack"]["network"]["service_tenant_name"]
user_name = node["openstack"]["network"]["service_user"]

private_net = node["openstack"]["network"]["ng_l3"]["private_network"] ||
  node["openstack"]["network"]["linuxbridge"]["physical_network"]
private_subnet = node["openstack"]["network"]["ng_l3"]["private_subnet"]
private_cidr = node["openstack"]["network"]["ng_l3"]["private_cidr"]
private_nameservers = node["openstack"]["network"]["ng_l3"]["private_nameservers"]

private_net_options = {
  "name" => private_net,
  "multihost:multi_host" => true,
  "shared" => true
}

ktc_network_network "Create Private Network" do
  auth_uri    auth_uri
  user_pass   service_pass
  tenant_name tenant_name
  user_name   user_name
  options     private_net_options
  action :create
end

ktc_network_subnet "Create Private Subnet" do
  auth_uri    auth_uri
  user_pass   service_pass
  tenant_name tenant_name
  user_name   user_name
  search_id(
    :network => private_net_options
  )
  options(
    "network_id" => :network,
    "cidr" => private_cidr,
    "dns_nameservers" => private_nameservers,
    "name" => private_subnet,
    "gateway_ip" => :null
  )
  action :create
end
