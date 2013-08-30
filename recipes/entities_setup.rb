require 'uri'

include_recipe "ktc-network::common"

identity_endpoint = endpoint "identity-api"
auth_uri = ::URI.decode identity_endpoint.to_s
service_pass = service_password "openstack-network"

physical_net = node["openstack"]["network"]["linuxbridge"]["physical_network"] 
ktc_network_entity physical_net do
  auth_uri    auth_uri
  user_pass   service_pass
  tenant_name node["openstack"]["network"]["service_tenant_name"]
  user_name   node["openstack"]["network"]["service_user"]
  options(
    :name => physical_net,
    :multihost_multi_host => true,
    :provider_network_type => "flat",
    :provider_physical_network => physical_net,
    :shared => true
  )
  action :create_network
end

ktc_network_entity node["openstack"]["network"]["l3"]["router_name"] do
  auth_uri    auth_uri
  user_pass   service_pass
  tenant_name node["openstack"]["network"]["service_tenant_name"]
  user_name   node["openstack"]["network"]["service_user"]
  options(
    :multihost_network_id => node["openstack"]["network"]["l3"]["network_id"]
  )
  action :create_router
end
