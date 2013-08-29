def whyrun_supported?
  false
end

def initialize(new_resource, run_context)
  super
  # create the fog connection
  conn = KTC::Network.new        :auth_uri  => new_resource.auth_uri,
                                 :api_key   => new_resource.user_pass,
                                 :user      => new_resource.user_name,
                                 :tenant    => new_resource.tenant_name
  @quantum = conn.net
end

def load_current_resource
  @current_resource ||= Chef::Resource::KtcNetworkRouter.new (@new_resource.name)
  @current_resource.auth_uri      @new_resource.auth_uri
  @current_resource.user_pass     @new_resource.user_pass
  @current_resource.tenant_name   @new_resource.tenant_name
  @current_resource.user_name     @new_resource.user_name

  # load the router from quantum if it exists
  # fog returns nil if its not found
  router_list = @quantum.list_routers[:body]["routers"]
  @current_resource.router = find_router(router_list, @current_resource.name)
end

action :create do
  #
  # for now we only create, we don't set
  # external_gateway
  #
  if @current_resource.router
    # if it exists already store its id and return
    Chef::Log.info("Router '#{new_resource.name}' already exists in tenant '#{new_resource.tenant_name}'. Not creating.")
    Chef::Log.info("Router UUID: #{@current_resource.router['id']}")    
    store_router_id @current_resource.router["id"]
    new_resource.updated_by_last_action(false)
  else
    @new_resource.router = @quantum.create_router(@new_resource.name)[:body]["router"]
    Chef::Log.info("Created Router '#{new_resource.name}' in Tenant '#{new_resource.tenant_name}'")
    Chef::Log.info("Router UUID: #{@new_resource.router['id']}")    
    store_router_id @new_resource.router["id"]
    new_resource.updated_by_last_action(true)
  end
end 

private
def find_router(router_list, router_name)
  router_list.each do |router|
    return router if router["name"] == router_name
  end
  nil
end

private
def store_router_id(id)
 node.set["openstack"]["network"]["l3"]["router_id"] = id
end
