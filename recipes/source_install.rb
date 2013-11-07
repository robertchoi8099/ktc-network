#
# Cookbook Name:: ktc-network
# Recipe:: source_install 
#

include_recipe "sudo"
include_recipe "git"
include_recipe "python"

user node["openstack"]["network"]["platform"]["user"] do
  home "/var/lib/quantum"
  shell "/bin/false"
  system  true
  supports :manage_home => true
end

sudo "quantum_sudoers" do
  user     "quantum"
  host     "ALL"
  runas    "root"
  nopasswd true
  commands ["/usr/local/bin/quantum-rootwrap"]
end

# Install pip-requires using ubuntu packages first, then install the rest with pip.
# Prefer installing ubuntu pakcages to compiling python modules on nodes.
node["openstack"]["network"]["platform"]["pip_requires_packages"].each do |pkg|
  package pkg
end

git "#{Chef::Config[:file_cache_path]}/quantum" do
  repository node["openstack"]["network"]["platform"]["quantum"]["git_repo"]
  reference node["openstack"]["network"]["platform"]["quantum"]["git_ref"]
  action :sync
  notifies :install, "python_pip[quantum-pip-requires]", :immediately
  notifies :run, "bash[install_quantum]", :immediately
end

python_pip "quantum-pip-requires" do
  package_name "#{Chef::Config[:file_cache_path]}/quantum/tools/pip-requires"
  options "-r"
  action :nothing
end

bash "install_quantum" do
  cwd "#{Chef::Config[:file_cache_path]}/quantum"
  code <<-EOF
    python ./setup.py install
  EOF
  action :nothing
end

directory "/var/log/quantum" do
  owner node["openstack"]["network"]["platform"]["user"]
  group "adm"
  mode 00750
  action :create
end
