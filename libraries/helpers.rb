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
end
