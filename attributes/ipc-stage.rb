return  unless  chef_environment == "ipc-stage"
# we want to override defaults
include_attribute "ktc-network::ng_l3"

# override this like the example below
default["openstack"]["network"]["ng_l3"] = {
  "setup_entities" => true,
  "heartbeat_network" => "heartbeat",
  "heartbeat_subnet" => "heartbeat",
  "heartbeat_cidr" => "10.210.11.0/24",
  "heartbeat_nameservers" => ["8.8.8.8"],
  "heartbeat_gateway_ip" => :null,
  "private_network" => "ipc-stage",
  "private_subnet" => "ipc-stage",
  "private_cidr" => "10.210.10.0/24",
  "private_nameservers" => ["8.8.8.8"],
  "private_gateway_ip" => :null
}
