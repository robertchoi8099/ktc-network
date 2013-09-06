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
  if (@new_resource.action.include? :add_interface)
    default_options = {
      "id" => nil,
      "subnet_id" => nil
    }
  else
    default_options = {
      "name" => nil
    }
  end
  @complete_options = get_complete_options default_options, @new_resource.options
  @current_resource.entity = find_existing_entity "routers", @complete_options
end

action :create do
  load_current_resource 
  if !@current_resource.entity
    resp = send_request "create_router", @complete_options, @complete_options["name"]
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

action :add_interface do
  load_current_resource
  if @current_resource.entity
    id = @current_resource.entity["id"]
    subnet_id = @complete_options["subnet_id"]
    filter_options = {
      "device_id" => id,
      "subnet_id" => subnet_id
    }
    port = find_existing_entity "ports", filter_options
    if !port 
      resp = send_request "add_router_interface", @complete_options, id, subnet_id
      Chef::Log.info("Added Router interface: #{resp[:body]}")
      new_resource.updated_by_last_action(true)
    else
      Chef::Log.info("Router already has a port.. Not adding.")
      Chef::Log.info("Existing port: #{port}")
      new_resource.updated_by_last_action(false)
    end
  else
    raise RuntimeError, "Unable to find Router: \"id\"=>\"#{@complete_options["id"]}\""
  end
end
