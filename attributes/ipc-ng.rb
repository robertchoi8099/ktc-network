return  unless  chef_environment == "ipc-ng"
# we want to override defaults
include_attribute "ktc-network::ng_l3"

# override this like the example below
default["openstack"]["network"]["ng_l3"] = {
  "setup_entities" => true,
  "private_network" => "ktis-dev",
  "private_subnet" => "ktis-dev",
  "private_cidr" => "10.217.174.0/24",
  "private_nameservers" => ["8.8.8.8"],
  "private_gateway_ip" => :null,
  "private_allocation_pools" => [{ "start" => "10.217.174.11", "end" => "10.217.174.250" }]
}
