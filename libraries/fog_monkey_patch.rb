begin
  require 'fog'
rescue LoadError
  Chef::Log.info "fog gem not found. Attempting to install "
  # we do this cause there are some pacakges and system things that
  # may need to get installed as well as this gem
  Gem::DependencyInstaller.new.install('fog')
  require 'fog'
end
require 'fog/openstack/requests/network/create_network'
require 'fog/openstack/requests/network/create_router'

module Fog
  module Network
    class OpenStack

      class Real
        def create_network(options = {})
          data = { 'network' => {} }
    
          vanilla_options = [
            :name,
            :shared,
            :admin_state_up,
            :tenant_id
          ]
    
#          vanilla_options.reject{ |o| options[o].nil? }.each do |key|
#            data['network'][key] = options[key]
#          end
          data['network'].merge! filter_options(vanilla_options, options)    

          provider_options = [
            :router_external,
            :provider_network_type,
            :provider_segmentation_id,
            :provider_physical_network,
            :multihost_multi_host
          ]
    
          aliases = {
            :provider_network_type     => 'provider:network_type',
            :provider_physical_network => 'provider:physical_network',
            :provider_segmentation_id  => 'provider:segmentation_id',
            :router_external           => 'router:external',
            :multihost_multi_host      => 'multihost:multi_host'
          }
    
#          provider_options.reject{ |o| options[o].nil? }.each do |key|
#            aliased_key = aliases[key] || key
#            data['network'][aliased_key] = options[key]
#          end
          data['network'].merge! filter_options(provider_options, options, aliases)
    
          request(
            :body     => Fog::JSON.encode(data),
            :expects  => [201],
            :method   => 'POST',
            :path     => 'networks'
          )
        end

        def create_router(name, options = {})
          data = {
            'router' => {
              'name' => name,
            }
          }
  
          vanilla_options = [
            :admin_state_up,
            :tenant_id,
            :network_id,
            :external_gateway_info,
            :status,
            :subnet_id,
          ]
  
#          vanilla_options.reject{ |o| options[o].nil? }.each do |key|
#            data['router'][key] = options[key]
#          end
          data['network'].merge! filter_options(vanilla_options, options)    
  
          provider_options = [
            :multihost_network_id
          ]
  
          aliases = {
            :multihost_network_id => 'multihost:network_id'
          }
  
#          provider_options.reject{ |o| options[o].nil? }.each do |key|
#            aliased_key = aliases[key] || key
#            data['router'][aliased_key] = options[key]
#          end
          data['network'].merge! filter_options(provider_options, options, aliases) 
  
          request(
            :body     => Fog::JSON.encode(data),
            :expects  => [201],
            :method   => 'POST',
            :path     => 'routers'
          )
        end

        private
        def filter_options(acceptable_options, options, aliases = {})
          data = {}
          acceptable_options.reject{ |o| options[o].nil? }.each do |key|
            aliased_key = aliases[key] || key
            data[aliased_key] = options[key]
          end
          data
        end
      end

    end
  end
end
