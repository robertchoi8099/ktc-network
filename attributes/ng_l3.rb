include_attribute "ktc-network"

default["openstack"]["network"]["ng_l3"] = {
  "private_network" => node["openstack"]["network"]["linuxbridge"]["physical_network"],
  "private_router" => "private-router-01",
  "private_subnet" => "private-subnet-01",
  "private_cidr" => "172.27.4.0/22",
  "private_nameservers" => ["8.8.8.8"],
  "floating_network" => "floating-net",
  "floating_cidrs" => [
    "14.63.205.50/32",
    "14.63.205.51/32",
    "14.63.205.52/32",
    "14.63.205.53/32",
    "14.63.205.54/32",
    "14.63.205.55/32",
    "14.63.205.56/32",
    "14.63.205.57/32",
    "14.63.205.58/32",
    "14.63.205.59/32",
    "14.63.205.60/32"
  ]
}
