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
default["openstack"]["network"]["metadata"]["nova_metadata_ip"] = "10.1.1.2"
default["openstack"]["network"]["platform"]["quantum_linuxbridge_agent_packages"] = [ "quantum-plugin-linuxbridge-agent" ]
default["openstack"]["network"]["platform"]["quantum_linuxbridge_agent_service"] = "quantum-plugin-linuxbridge-agent"
default["openstack"]["network"]["platform"]["quantum_python_package"] = "python-quantumclient"
default["openstack"]["network"]["platform"]["quantum_server_packages"] = [ "quantum-server" ]
default["openstack"]["network"]["plugins"] = [ "linuxbridge", "dhcp_agent",  ]
