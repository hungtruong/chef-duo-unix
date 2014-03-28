#
# Cookbook Name:: duo_unix
# Recipe:: default
#
# Copyright 2013, Hung Truong
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

case node[:platform]
when "debian", "ubuntu"
	package "libssl-dev" do
		action :upgrade
	end
	package "make" do
		action :upgrade
	end
end

#install duo_unix from source
configure_options = node['duo_unix']['configure_options'].join(" ")
version = node['duo_unix']['version']
remote_file "#{Chef::Config[:file_cache_path]}/duo_unix-#{version}.tar.gz" do
  source "#{node['duo_unix']['url']}#{version}.tar.gz"
  checksum node['duo_unix']['checksum']
  mode "0644"
end

bash "build-and-install-duo_unix" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOF
  tar -xzvf duo_unix-#{version}.tar.gz
  (cd duo_unix-#{version} && ./configure #{configure_options})
  (cd duo_unix-#{version} && make && make install)
  EOF
end

#set up the config file
template "/etc/duo/login_duo.conf" do
  source "login_duo.conf.erb"
  mode 0600
  owner "sshd"
  group "root"
end

#enable login_duo for ssh
ssh_config "ForceCommand" do
  string "ForceCommand /usr/sbin/login_duo"
  action :add
  only_if { node['duo_unix']['conf']['login_duo_enabled'] == true } 
end

#disable login_duo for ssh
ssh_config "ForceCommand" do
  string "ForceCommand /usr/sbin/login_duo"
  action :remove
  only_if { node['duo_unix']['conf']['login_duo_enabled'] == false } 
end

#adds PermitTunnel setting to sshd_config
ssh_config "PermitTunnel" do
  string "PermitTunnel #{node['duo_unix']['conf']['PermitTunnel']}"
  action :add
end

#adds AllowTcpForwarding setting to sshd_config
ssh_config "AllowTcpForwarding" do
  string "AllowTcpForwarding #{node['duo_unix']['conf']['AllowTCPForwarding']}"
  action :add
end