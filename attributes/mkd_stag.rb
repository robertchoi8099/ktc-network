return  unless  chef_environment == "mkd_stag"
# we want to override defaults
include_attribute "ktc-network::ng_l3"

# override this like the example below
default["openstack"]["network"]["ng_l3"] = {
  "setup_entities" => true,
  "private_network" => "heartbeat",
  "private_subnet" => "heartbeat",
  "private_cidr" => "172.27.0.0/24",
  "private_nameservers" => ["8.8.8.8"],
  "private_gateway_ip" => :null
}

# Example: Assume we use physical_network as our private_network. In this case,
#          don't override "private_network". setup_entities recipe will choose
#          node["openstack"]["network"]["linuxbridge"]["physical_network"] as the
#          private_network in runtime
#
# override["openstack"]["network"]["linuxbridge"]["physical_network"] = "private-net-01"
# override["openstack"]["network"]["ng_l3"] = {
#   "setup_entities" => true,
#   "private_router" => "private-router-01",
#   "private_subnet" => "private-subnet-01",
#   "private_cidr" => "xxx.xxx.xxx.0/22",
#   "private_nameservers" => ["xxx.xxx.xxx.xxx"],
#   "private_gateway_ip" => :null,
#   "floating_network" => "floating-net",
#   "floating_cidrs" => [
#     "xxx.xxx.xxx.xxx/32",
#     "xxx.xxx.xxx.xxx/32"
#   ]
# }
