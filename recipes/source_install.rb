#
# Cookbook Name:: ktc-network
# Recipe:: source_install 
#

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

bash "install_quantum" do
  cwd "#{Chef::Config[:file_cache_path]}/quantum"
  code <<-EOH
    python ./setup.py build
    python ./setup.py install
    EOH
end
