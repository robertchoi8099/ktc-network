require 'uri'

include_recipe "ktc-network::common"

set_service_endpoint "compute-metadata-api"
identity_endpoint = endpoint "identity-api"
auth_uri = ::URI.decode identity_endpoint.to_s
service_pass = service_password "openstack-network"

ktc_network_router node["openstack"]["network"]["l3"]["router_name"] do
  auth_uri    auth_uri
  user_pass   service_pass
  tenant_name node["openstack"]["network"]["service_tenant_name"]
  user_name   node["openstack"]["network"]["service_user"]
  action :create
end
