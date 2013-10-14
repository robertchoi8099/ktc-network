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
require 'fog/openstack/requests/network/create_subnet'
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

          data['network'].merge! osum(vanilla_options, provider_options, options, aliases)

          request(
            :body     => Fog::JSON.encode(data),
            :expects  => [201],
            :method   => 'POST',
            :path     => 'networks'
          )
        end

        def create_subnet(network_id, cidr, ip_version, options = {})
          data = {
            'subnet' => {
              'network_id' => network_id,
              'cidr'       => cidr,
              'ip_version' => ip_version,
            }
          }

          vanilla_options = [:name, :gateway_ip, :allocation_pools,
            :dns_nameservers, :host_routes, :enable_dhcp,
            :tenant_id]
          data['subnet'].merge! osum(vanilla_options, [], options, {})

          request(
            :body     => Fog::JSON.encode(data),
            :expects  => [201],
            :method   => 'POST',
            :path     => 'subnets'
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

          provider_options = [
            :multihost_network_id
          ]

          aliases = {
            :multihost_network_id => 'multihost:network_id'
          }

          data['router'].merge! osum(vanilla_options, provider_options, options, aliases)

          request(
            :body     => Fog::JSON.encode(data),
            :expects  => [201],
            :method   => 'POST',
            :path     => 'routers'
          )
        end

        private
        def osum(vanilla_options, provider_options, options, aliases)
          data = {}
          joined_options = vanilla_options | provider_options
          joined_options.reject { |o| options[o].nil? }.each do |key|
            aliased_key = aliases[key] || key
            # change keyword :null to nil then JSON.encode will encode it to null
            value = (options[key] == :null) ? nil : options[key]
            data[aliased_key] = value
          end
          data
        end
      end

    end
  end
end
