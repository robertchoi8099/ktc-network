#
## Cookbook Name:: quantum
## Attributes:: default
##
## Copyright 2012, Rackspace US, Inc.
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
##

include_attribute "openstack-network::default"

default["openstack"]["network"]["api"]["agent"]["agent_report_interval"] = 4
default["openstack"]["network"]["rabbit_server_chef_role"] = "ktc-messaging"
default["openstack"]["network"]["core_plugin"] = "quantum.plugins.linuxbridge.lb_quantum_plugin.LinuxBridgePluginV2"
default["openstack"]["network"]["interface_driver"] = "quantum.agent.linux.interface.BridgeInterfaceDriver"
default["openstack"]["network"]["use_namespaces"] = "False"
default["openstack"]["network"]["enable_multi_host"] = "True"
default["openstack"]["network"]["l3"]["external_network_bridge"]= ""
default["openstack"]["network"]["l3"]["router_name"] = "private-router-01"
default["openstack"]["network"]["platform"]["quantum_linuxbridge_agent_service"] = "quantum-plugin-linuxbridge-agent"
default["openstack"]["network"]["platform"]["quantum_packages"] = []
default["openstack"]["network"]["platform"]["quantum_server_packages"] = []
default["openstack"]["network"]["platform"]["quantum_client_packages"] = []
default["openstack"]["network"]["platform"]["quantum_dhcp_packages"] = []
default["openstack"]["network"]["platform"]["quantum_l3_packages"] = []
default["openstack"]["network"]["platform"]["quantum_metadata_agent_packages"] = []
default["openstack"]["network"]["platform"]["pip_requires_packages"] = %w{
  python-cliff python-cmd2 python-pyparsing python-paste python-pastedeploy 
  python-routes python-amqplib python-anyjson python-eventlet python-greenlet 
  python-httplib2 python-iso8601 python-kombu python-netaddr python-pyudev 
  python-sqlalchemy python-webob python-keystoneclient alembic python-oslo.config
  python-quantumclient
}
default["openstack"]["network"]["platform"]["quantum_linuxbridge_agent_service"] = "quantum-plugin-linuxbridge-agent"
default["openstack"]["compute"]["platform"]["quantum"]["git_repo"] = "https://github.com/kt-cloudware/quantum.git"
default["openstack"]["compute"]["platform"]["quantum"]["git_ref"] = "ipc-develop"
default["openstack"]["network"]["linuxbridge"]["physical_network"] = "private-net-01"

# set sysctl properties
default['sysctl']['params']['net']['ipv4']['ip_forward'] = 1
default['sysctl']['params']['net']['bridge']['bridge-nf-call-iptables'] = 0
default['sysctl']['params']['net']['bridge']['bridge-nf-call-ip6tables'] = 0
default['sysctl']['params']['net']['bridge']['bridge-nf-call-arptables'] = 0
