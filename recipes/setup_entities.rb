require 'uri'

include_recipe "ktc-network::common"

identity_endpoint = endpoint "identity-api"
auth_uri = ::URI.decode identity_endpoint.to_s
service_pass = service_password "openstack-network"
tenant_name = node["openstack"]["network"]["service_tenant_name"]
user_name = node["openstack"]["network"]["service_user"]

heartbeat_net = node["openstack"]["network"]["ng_l3"]["heartbeat_network"]
heartbeat_subnet = node["openstack"]["network"]["ng_l3"]["heartbeat_subnet"]
heartbeat_cidr = node["openstack"]["network"]["ng_l3"]["heartbeat_cidr"]
heartbeat_nameservers = node["openstack"]["network"]["ng_l3"]["heartbeat_nameservers"]
heartbeat_gateway_ip = node["openstack"]["network"]["ng_l3"]["heartbeat_gateway_ip"]
heartbeat_net_options = {
  "name" => heartbeat_net,
  "multihost:multi_host" => true,
  "shared" => true
}
private_net = node["openstack"]["network"]["ng_l3"]["private_network"]
private_subnet = node["openstack"]["network"]["ng_l3"]["private_subnet"]
private_cidr = node["openstack"]["network"]["ng_l3"]["private_cidr"]
private_nameservers = node["openstack"]["network"]["ng_l3"]["private_nameservers"]
private_gateway_ip = node["openstack"]["network"]["ng_l3"]["private_gateway_ip"]

private_net_options = {
  "name" => private_net,
  "multihost:multi_host" => true,
  "shared" => true
}

ktc_network_network "Create Heartbeat Network" do
  auth_uri    auth_uri
  user_pass   service_pass
  tenant_name tenant_name
  user_name   user_name
  options     heartbeat_net_options
  action :create
end

ktc_network_subnet "Create Heartbeat Subnet" do
  auth_uri    auth_uri
  user_pass   service_pass
  tenant_name tenant_name
  user_name   user_name
  search_id(
    :network => heartbeat_net_options
  )
  options(
    "network_id" => :network,
    "cidr" => heartbeat_cidr,
    "dns_nameservers" => heartbeat_nameservers,
    "name" => heartbeat_subnet,
    "gateway_ip" => heartbeat_gateway_ip
  )
  action :create
end

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
    "gateway_ip" => private_gateway_ip
  )
  action :create
end
