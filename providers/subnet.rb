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

  default_options = {
    "network_id" => nil,
    "cidr" => nil,
    "ip_version" => 4
  }
  compiled_options = compile_options @new_resource.options, @new_resource.search_id
  @complete_options = get_complete_options default_options, compiled_options
  @current_resource.entity = find_existing_entity "subnets", @complete_options
end

action :create do
  if !@current_resource.entity
    resp = send_request "create_subnet", @complete_options, @complete_options["network_id"], @complete_options["cidr"], @complete_options["ip_version"]
    Chef::Log.info("Created subnet: #{resp[:body]["subnet"]}")
    new_resource.updated_by_last_action(true)
  else
    Chef::Log.info("Subnet already exists.. Not creating.")
    Chef::Log.info("Existing subnet: #{@current_resource.entity}")
    new_resource.updated_by_last_action(false)
  end
end
