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

def load_current_resource (entity_type)
  @current_resource ||= Chef::Resource::KtcNetworkRouter.new (@new_resource.name)
  @current_resource.auth_uri      @new_resource.auth_uri
  @current_resource.user_pass     @new_resource.user_pass
  @current_resource.tenant_name   @new_resource.tenant_name
  @current_resource.user_name     @new_resource.user_name

  # load the router from quantum if it exists
  # fog returns nil if its not found
  type_pl = entity_type.to_s + "s"
  response = @quantum.send_request("list_#{type_pl}")
  entity_list = response[:body]["#{type_pl}"]
  @current_resource.entity = find_entity(entity_list, @current_resource.options)
end

action :create_network do
  load_current_resource :network
  if @current_resource.entity
    if resp = send_request("create_network")
      Chef::Log.info "Running action #{request_name}... Success"
      Chef::Log.info resp[:body].to_s
      store_id_in_attr "network", resp[:body]["network"]["id"]
      new_resource.updated_by_last_action(true)
    end
end

action :create_router do
  #
  # for now we only create, we don't set
  # external_gateway
  #
  router_name = @new_resource.options[:name]
  if entity_exist? (:router, @new_resource.options)
    Log
  if resp = send_request("create_router", @new_resource.options, router_name)
    # if it exists already store its id and return
    store_id_in_attr "router", resp[:body]["router"]["id"]
  end
end 

private
def find_entity(entity_list, entity_options)
  entity_list.each do |entity|
    found = true
    entity.each do |k, v|
      if (entity_options.has_key? k) && (entity_options[k] != v)
        found = false
        break
      end
    end
    return entity if found
  end
  nil
end

private
def entity_exist? (entity_type, entity_options={})
  type_pl = entity_type.to_s + "s"
  entity_list = @quantum.send_request("list_#{type_pl}")
  entity = find_entity(entity_list, entity_options)
end

private
def send_request(request_name, options={}, *args)
    begin
      resp = @quantum.send(request_name, *args, options)
    rescue Exception => e
      if e.class == Excon::Errors::Conflict
        Chef::Log.info "Not running action #{request_name}... Seems up to date."
        Chef::Log.info "(#{e.response[:body]})"
        new_resource.updated_by_last_action(false)
        nil
      else
        raise RuntimeError, e
      end
    end
end

private
def store_id_in_attr(entity_type, id)
 node.set["openstack"]["network"]["l3"]["#{entity_type}_id"] = id
end
