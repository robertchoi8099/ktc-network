include KTCNetwork

def whyrun_supported?
  false
end

def initialize(new_resource, run_context)
  super
  # create the fog connection
  conn = Quantum.new             :auth_uri  => new_resource.auth_uri,
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
  @current_resource.options     @new_resource.options

  # load the router from quantum if it exists
  # fog returns nil if its not found
  response = send_request "list_routers"
  entity_list = response[:body]["routers"]
  entity = find_entity(entity_list, @current_resource.options)
  if entity
    @current_resource.entity = entity
  end
end

action :create do
  load_current_resource 
  if !@current_resource.entity
    options = @current_resource.options
    ordered_args_map = {
      "name" => nil
    }
    ordered_args = get_request_args @new_resource, ordered_args_map
    resp = send_request "create_router", @new_resource.options, *ordered_args
    Chef::Log.info("Created router: #{resp[:body]["router"]}")
    id = resp[:body]["router"]["id"]
    new_resource.updated_by_last_action(true)
  else
    Chef::Log.info("Router already exists.. Not creating.")
    Chef::Log.info("Existing router: #{@current_resource.entity}")
    id = @current_resource.entity["id"]
    new_resource.updated_by_last_action(false)
  end
  store_id_in_attr "router", id
end
