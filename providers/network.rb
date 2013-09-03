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
  @current_resource ||= Chef::Resource::KtcNetworkNetwork.new (@new_resource.name)
  @current_resource.auth_uri      @new_resource.auth_uri
  @current_resource.user_pass     @new_resource.user_pass
  @current_resource.tenant_name   @new_resource.tenant_name
  @current_resource.user_name     @new_resource.user_name
  @current_resource.options     @new_resource.options

  # load the router from quantum if it exists
  # fog returns nil if its not found
  response = send_request "list_networks"
  entity_list = response[:body]["networks"]
  entity = find_entity(entity_list, @current_resource.options)
  if entity
    @current_resource.entity = entity
  end
end

action :create do
  load_current_resource 
  if !@current_resource.entity
    resp = send_request "create_network", @new_resource.options
    network = resp[:body]["network"]
    Chef::Log.info("Created network: #{resp[:body]["network"]}")
    id = resp[:body]["network"]["id"]
    new_resource.updated_by_last_action(true)
  else
    Chef::Log.info("Network already exists.. Not creating.")
    Chef::Log.info("Existing network: #{@current_resource.entity}")
    id = @current_resource.entity["id"]
    new_resource.updated_by_last_action(false)
  end
  store_id_in_attr "network", id
end
