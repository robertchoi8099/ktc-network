module KTCNetwork
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
  
  def store_id_in_attr(entity_type, id)
    node.set["openstack"]["network"]["l3"]["#{entity_type}_id"] = id
    Chef::Log.info "Set node['openstack']['network']['l3']['#{entity_type}_id'] to '#{id}'"
  end
  
  def send_request(request, entity_options={}, *args)
    options = Hash[entity_options.map { |k, v| [k.gsub(':','_').to_sym, v] }]
    resp = @quantum.send(request, *args, options)
  end

  # make arguments for fog openstack requests
  # ordered_args_map must be ordered same to the args of fog openstack request
  def get_request_args(ordered_args_map, resource)
    options = resource.options
    ordered_args = []
    ordered_args_map.each do |k, v|
      if options.has_key? k 
        ordered_args << options[k]
      elsif (resource.respond_to? k) && (resource.send(k) != nil)
        ordered_args << resource.send(k.to_sym)
      else
        ordered_args << v
      end
    end

    ordered_args
  end
end
