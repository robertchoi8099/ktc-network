module KTCNetwork
  def find_existing_entity(list_type, request_options)
    # reject array type options from request options because those cause quantum internal server error
    array_rejected = request_options.reject { |k, v| v.kind_of? Array }
    response = send_request "list_#{list_type}", array_rejected
    entity_list = response[:body]["#{list_type}"]
    if entity_list.empty?
      entity = nil
    elsif entity_list.length == 1
      entity = entity_list[0]
    else
      msg = "Found multiple existing #{list_type}: #{entity_list}\n"\
            "Need more specific options. Stop here."
      raise RuntimeError, msg
    end
    entity
  end

  def store_id_in_attr(entity_type, id)
    node.set["openstack"]["network"]["l3"]["#{entity_type}_id"] = id
    Chef::Log.info "Set node['openstack']['network']['l3']['#{entity_type}_id'] to '#{id}'"
  end
  
  def send_request(request, entity_options={}, *args)
    options = Hash[entity_options.map { |k, v| [k.gsub(':','_').to_sym, v] }]
    begin
      resp = @quantum.send(request, *args, options)
    rescue Exception => e
      Chef::Log.info "An error occured with options: #{options}"
      raise e
    end
  end

  def get_complete_options(default_options, resource_options)
    default_options.each do |k, v|
      if (v == nil) && (!resource_options.has_key? k)
        raise RuntimeError, "Must provide option \"#{k}\". Provided options: #{resource_options}"
      end
    end
    complete_options = default_options.clone
    complete_options.merge!(resource_options)
  end
end
