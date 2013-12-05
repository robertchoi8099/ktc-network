if !(node["openstack"]["network"]["ng_l3"] &&
  node["openstack"]["network"]["ng_l3"]["kitchen"])
  return
end
# we want to override defaults
include_attribute "ktc-network::ng_l3"

default["openstack"]["network"]["ng_l3"]["setup_entities"] = true
default["openstack"]["network"]["ng_l3"]["private_network"] = "private-net-01"
default["openstack"]["network"]["ng_l3"]["networks"] = [
  {
    "options" => {
      "name" => "heartbeat",
      "multihost:multi_host" => true,
      "shared" => true
    }
  },
  {
    "options" => {
      "name" => "private-net-01",
      "multihost:multi_host" => true,
      "shared" => true
    }
  }
]
default["openstack"]["network"]["ng_l3"]["subnets"] = [
  {
    "search_id" => { :network => { "name" => "heartbeat" } },
    "options" => {
      "network_id" => :network,
      "name" => "heartbeat",
      "cidr" => "10.0.0.0/24",
      "dns_nameservers" => ["8.8.8.8"],
      "gateway_ip" => :null
    }
  },
  {
    "search_id" => { :network => { "name" => "private-net-01" } },
    "options" => {
      "network_id" => :network,
      "name" => "private-subnet-01",
      "cidr" => "10.18.18.0/24",
      "dns_nameservers" => ["8.8.8.8"],
      "gateway_ip" => :null
    }
  }
]
