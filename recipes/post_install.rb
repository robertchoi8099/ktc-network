include_recipe "simple_iptables"

# Drop packets from VMs to management network
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
