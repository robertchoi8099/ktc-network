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
  if @new_resource.action.include? :add_interface
    default_options = {
      "id" => nil,
      "subnet_id" => nil
    }
  elsif @new_resource.action.include? :update
    default_options = {
      "id" => nil
    }
  else
    default_options = {
      "name" => nil
    }
  end
  compiled_options = compile_options @new_resource.options, @new_resource.search_id
  @complete_options = get_complete_options default_options, compiled_options
  @current_resource.entity = find_existing_entity "routers", @complete_options
end

action :create do
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
  if @new_resource.store_id 
    store_id_in_attr id, @new_resource.store_id
  end
end

action :update do
  if @current_resource.entity
    if need_update? @complete_options, @current_resource.entity
      resp = send_request "update_router", @complete_options, @current_resource.entity["id"]
      Chef::Log.info("Updated router: #{resp[:body]["router"]}")
      new_resource.updated_by_last_action(true)
    else
      Chef::Log.info("Router already has the same options.. Not updating.")
      Chef::Log.info("Existing router: #{@current_resource.entity}")
      new_resource.updated_by_last_action(false)
    end
  else
    raise RuntimeError, "Unable to find Router: \"id\"=>\"#{@complete_options["id"]}\""
  end
end
 
action :add_interface do
  if @current_resource.entity
    id = @current_resource.entity["id"]
    subnet_id = @complete_options["subnet_id"]
    filter_options = {
      "device_id" => id
    }
    port_list = send_request("list_ports", filter_options)[:body]["ports"]
    existing_port = nil
    port_list.each do |port|
      port["fixed_ips"].each do |f|
        if f["subnet_id"] == subnet_id
          existing_port = port 
          break
        end
      end
    end
    if !existing_port 
      resp = send_request "add_router_interface", @complete_options, id, subnet_id
      Chef::Log.info("Added Router interface: #{resp[:body]}")
      new_resource.updated_by_last_action(true)
    else
      Chef::Log.info("Router already has a port.. Not adding.")
      Chef::Log.info("Existing port: #{existing_port}")
      new_resource.updated_by_last_action(false)
    end
  else
    raise RuntimeError, "Unable to find Router: \"id\"=>\"#{@complete_options["id"]}\""
  end
end
