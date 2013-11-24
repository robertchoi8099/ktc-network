include_attribute "ktc-network"

default["openstack"]["network"]["ng_l3"]["setup_entities"] = false
default["openstack"]["network"]["ng_l3"]["private_network"] = nil
default["openstack"]["network"]["ng_l3"]["networks"] = []
default["openstack"]["network"]["ng_l3"]["subnets"] = []

# If cloud has AZs, don't set private_network. Make a network named the same 
# to AZ name (node["openstack"]["availability_zone"]), and that network will be
# refered to as a private_network. Set "zone" key for every network and subnet
# which belongs to AZs, too. See ipc-ng.rb as an example.
# If cloud doesn't have AZs, set private_network attr to the name of real
# private network. Never set "zone" key for any entry. Every network and subnet
# will be assumed if it belongs to the 'nil' zone. See kitchen.rb as an
# example.
