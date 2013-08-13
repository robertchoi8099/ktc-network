#
# Cookbook Name:: ktc-network
# Recipe:: source_install 
#

include_recipe "python"

user node["openstack"]["network"]["platform"]["user"] do
  home "/var/lib/quantum"
  shell "/bin/false"
  supports :manage_home => true
end

git "#{Chef::Config[:file_cache_path]}/quantum" do
  repository "https://github.com/kt-cloudware/quantum.git"
  reference "develop"
  action :sync
end

python_pip "pip-requires" do
  package_name "#{Chef::Config[:file_cache_path]}/quantum/tools/pip-requires"
  options "-r"
  action :install
end

python "setup.py install" do
  cwd "#{Chef::Config[:file_cache_path]}/quantum"
  action :run
end
