actions :create_router, :create_network

attribute :auth_uri, :kind_of => String, :required => true
attribute :tenant_name, :kind_of => String, :required => true
attribute :user_name, :kind_of => String, :required => true
attribute :user_pass, :kind_of => String, :required => true
attribute :router_name, :kind_of => String, :default => nil
attribute :options,   :kind_of => Hash, :default => {}

attr_accessor :entity
