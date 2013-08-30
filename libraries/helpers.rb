module KTC
  class Network

    attr_accessor :auth_uri, :user, :api_key, :tenant, :net

    def load_gem
      begin
        require 'fog'
      rescue LoadError
        Chef::Log.info "fog gem not found. Attempting to install "
        # we do this cause there are some pacakges and system things that
        # may need to get installed as well as this gem
        Gem::DependencyInstaller.new.install('fog')
        require 'fog'
      end
    end

    def patch_create_network
      Fog::Network::OpenStack::Real.send(:define_method, :create_network) do |options = {}|
        data = { 'network' => {} }
  
        vanilla_options = [
          :name,
          :shared,
          :admin_state_up,
          :tenant_id
        ]
  
        vanilla_options.reject{ |o| options[o].nil? }.each do |key|
          data['network'][key] = options[key]
        end
  
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
  
        provider_options.reject{ |o| options[o].nil? }.each do |key|
          aliased_key = aliases[key] || key
          data['network'][aliased_key] = options[key]
        end
  
        request(
          :body     => Fog::JSON.encode(data),
          :expects  => [201],
          :method   => 'POST',
          :path     => 'networks'
        )
      end
    end

    def patch_create_router
      Fog::Network::OpenStack::Real.send(:define_method, :create_router) do |name, options = {}|
        Chef::Log.info "#{name}, #{options}"
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

        vanilla_options.reject{ |o| options[o].nil? }.each do |key|
          data['router'][key] = options[key]
        end

        provider_options = [
          :multihost_network_id
        ]

        aliases = {
          :multihost_network_id => 'multihost:network_id'
        }

        provider_options.reject{ |o| options[o].nil? }.each do |key|
          aliased_key = aliases[key] || key
          data['router'][aliased_key] = options[key]
        end

        request(
          :body     => Fog::JSON.encode(data),
          :expects  => [201],
          :method   => 'POST',
          :path     => 'routers'
        )
      end
    end

    def fog_monkey_patch
      patch_create_network
      patch_create_router
    end

    def initialize(args)
      load_gem
      @auth_uri= args[:auth_uri]
      @user    = args[:user]
      @api_key = args[:api_key]
      @tenant  = args[:tenant]

      validate
      net
      fog_monkey_patch
    end

    def net
      @net ||= Fog::Network.new :provider           => "OpenStack",
                                :openstack_tenant   => @tenant,
                                :openstack_api_key  => @api_key,
                                :openstack_auth_url => @auth_uri+"/tokens",
                                :openstack_username => @user
    end

    def validate
      %w/auth_uri user api_key tenant/.each do |opt|
        if opt.to_sym.nil?
          raise "Argument must not be empty '#{opt.to_sym}'"
        end
      end
    end

  end
end
