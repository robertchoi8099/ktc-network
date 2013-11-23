require 'uri'

include_recipe "ktc-network::common"

identity_endpoint = endpoint "identity-api"
auth_uri = ::URI.decode identity_endpoint.to_s
service_pass = service_password "openstack-network"
tenant_name = node["openstack"]["network"]["service_tenant_name"]
user_name = node["openstack"]["network"]["service_user"]

node["openstack"]["network"]["ng_l3"]["networks"].each do |network|
  ktc_network_network "Create network: #{network["options"]["name"]}" do
    auth_uri    auth_uri
    user_pass   service_pass
    tenant_name tenant_name
    user_name   user_name
    options     network["options"]
    action :create
  end
end

node["openstack"]["network"]["ng_l3"]["subnets"].each do |subnet|
  ktc_network_subnet "Create subnet: #{subnet["options"]["name"]}" do
    auth_uri    auth_uri
    user_pass   service_pass
    tenant_name tenant_name
    user_name   user_name
    search_id   subnet["search_id"]
    options     subnet["options"]
    action :create
  end
end
