return  unless  chef_environment == "ipc-stage"
# we want to override defaults
include_attribute "ktc-network::ng_l3"

# override this like the example below
default["openstack"]["network"]["ng_l3"]["setup_entities"] = true
default["openstack"]["network"]["ng_l3"]["private_network"] = "ipc-stage"
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
      "name" => "ipc-stage",
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
      "cidr" => "10.210.11.0/24",
      "dns_nameservers" => ["8.8.8.8"],
      "gateway_ip" => :null
    }
  },
  {
    "search_id" => { :network => { "name" => "ipc-stage" } },
    "options" => {
      "network_id" => :network,
      "name" => "ipc-stage",
      "cidr" => "10.210.10.0/24",
      "dns_nameservers" => ["8.8.8.8"],
      "gateway_ip" => :null
    }
  }
]
