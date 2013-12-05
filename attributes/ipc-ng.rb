return  unless chef_environment == "ipc-ng"
# we want to override defaults
include_attribute "ktc-network::ng_l3"

# override this like the example below
default["openstack"]["network"]["ng_l3"]["setup_entities"] = true
default["openstack"]["network"]["ng_l3"]["networks"] = [
  {
    "zone" => "cheonan.dev.ktis",
    "options" => {
      "name" => "cheonan.dev.ktis",
      "multihost:multi_host" => true,
      "shared" => true
    }
  },
  {
    "zone" => "cheonan.dev.ktis",
    "options" => {
      "name" => "cheonan.dev.ktis.private",
      "multihost:multi_host" => true,
      "shared" => true
    }
  },
  {
    "zone" => "cheonan.dev.dmz",
    "options" => {
      "name" => "cheonan.dev.dmz",
      "multihost:multi_host" => true,
      "shared" => true
    }
  },
  {
    "zone" => "cheonan.dev.dmz",
    "options" => {
      "name" => "cheonan.dev.dmz.private",
      "multihost:multi_host" => true,
      "shared" => true
    }
  }
]
default["openstack"]["network"]["ng_l3"]["subnets"] = [
  {
    "zone" => "cheonan.dev.ktis",
    "search_id" => { :network => { "name" => "cheonan.dev.ktis" } },
    "options" => {
      "network_id" => :network,
      "name" => "cheonan.dev.ktis",
      "cidr" => "10.217.174.0/24",
      "dns_nameservers" => ["8.8.8.8"],
      "gateway_ip" => :null,
      "allocation_pools" => [{ "start" => "10.217.174.11", "end" => "10.217.174.250" }]
    }
  },
  {
    "zone" => "cheonan.dev.ktis",
    "search_id" => { :network => { "name" => "cheonan.dev.ktis.private" } },
    "options" => {
      "network_id" => :network,
      "name" => "cheonan.dev.ktis.private",
      "cidr" => "10.217.141.0/24",
      "dns_nameservers" => ["8.8.8.8"],
      "gateway_ip" => :null,
      "allocation_pools" => [{ "start" => "10.217.141.11", "end" => "10.217.141.250" }]
    }
  },
  {
    "zone" => "cheonan.dev.dmz",
    "search_id" => { :network => { "name" => "cheonan.dev.dmz" } },
    "options" => {
      "network_id" => :network,
      "name" => "cheonan.dev.dmz",
      "cidr" => "14.63.135.0/24",
      "dns_nameservers" => ["8.8.8.8"],
      "gateway_ip" => :null,
      "allocation_pools" => [{ "start" => "14.63.135.11", "end" => "14.63.135.250" }]
    }
  },
  {
    "zone" => "cheonan.dev.dmz",
    "search_id" => { :network => { "name" => "cheonan.dev.dmz.private" } },
    "options" => {
      "network_id" => :network,
      "name" => "cheonan.dev.dmz.private",
      "cidr" => "10.217.140.0/24",
      "dns_nameservers" => ["8.8.8.8"],
      "gateway_ip" => :null,
      "allocation_pools" => [{ "start" => "10.217.140.11", "end" => "10.217.140.250" }]
    }
  }
]
