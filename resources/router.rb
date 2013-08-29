actions :create

attribute :auth_uri, :kind_of => String, :required => true
attribute :tenant_name, :kind_of => String, :required => true
attribute :user_name, :kind_of => String, :required => true
attribute :user_pass, :kind_of => String, :required => true

attr_accessor :router
