#
# Load bridge module
# 'modules' recipe reads module list from node["modules"] and loads them
#
include_recipe "modules"

chef_gem "chef-rewind"
require 'chef/rewind'

# Ubuntu Precise and Quantal provide 'module-init-tools' instead of 'kmod'.
case node["platform"]
when "ubuntu"
  if Gem::Dependency.new(nil, "<= 12.10").match?(nil, node["platform_version"])
    rewind :package => "kmod" do
      package_name "module-init-tools"
    end
  end
end

#
# Drop packets from VMs to management network
#
include_recipe "simple_iptables"

private_cidr = node["openstack"]["network"]["ng_l3"]["private_cidr"]
management_cidr = nil
iface = KTC::Network.if_lookup "management"
ip = KTC::Network.address "management"
node["network"]["interfaces"][iface]["routes"].each do |route|
  if route.has_key?("src") && (route["src"] == ip)
    management_cidr = route["destination"]
    break
  end
end

simple_iptables_rule "ng-INPUT" do
  direction "INPUT"
  rule "-s #{private_cidr} -d #{management_cidr}"
  jump "DROP"
end

simple_iptables_rule "ng-FORWARD" do
  direction "FORWARD"
  rule "-s #{private_cidr} -d #{management_cidr}"
  jump "DROP"
end
