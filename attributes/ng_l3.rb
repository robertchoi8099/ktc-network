include_attribute "ktc-network"

# override this like the example below
default["openstack"]["network"]["ng_l3"] = {
  "setup_entities" => false,
  "private_network" => nil,
  "private_router" => nil,
  "private_subnet" => nil,
  "private_cidr" => nil,
  "private_nameservers" => nil,
  "private_gateway_ip" => nil,
  "floating_network" => nil,
  "floating_cidrs" => nil
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
