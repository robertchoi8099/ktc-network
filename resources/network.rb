actions :create

attribute :auth_uri, :kind_of => String, :required => true
attribute :tenant_name, :kind_of => String, :required => true
attribute :user_name, :kind_of => String, :required => true
attribute :user_pass, :kind_of => String, :required => true
attribute :search_id, :kind_of => Hash, :default => {}
attribute :options,   :kind_of => Hash, :default => {}

attr_accessor :entity
