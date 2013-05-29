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
if node['duo_unix']['conf']['login_duo_enabled'] 
	bash "require login_duo for ssh" do
		code <<-WTAF
		grep -q 'ForceCommand /usr/sbin/login_duo' /etc/ssh/sshd_config || echo 'ForceCommand /usr/sbin/login_duo' >> /etc/ssh/sshd_config
		WTAF
	end
else
	bash "disable login_duo for ssh" do
		code <<-WTAF
		sed -i '\#ForceCommand /usr/sbin/login_duo#d' /etc/ssh/sshd_config
		WTAF
	end
end

#hacky way of editing the sshd_config file to add or remove lines
if node['duo_unix']['conf']['PermitTunnel'] 
	bash "remove permit tunnel no" do
		code <<-WTAF
		sed -i '\#PermitTunnel no#d' /etc/ssh/sshd_config
		WTAF
	end
else
	bash "add permit tunnel no" do
		code <<-WTAF
		grep -q 'PermitTunnel no' /etc/ssh/sshd_config || echo 'PermitTunnel no' >> /etc/ssh/sshd_config
		WTAF
	end
end

if node['duo_unix']['conf']['AllowTcpForwarding'] 
	bash "remove AllowTcpForwarding no" do
		code <<-WTAF
		sed -i '\#AllowTcpForwarding no#d' /etc/ssh/sshd_config
		WTAF
	end
else
	bash "add AllowTcpForwarding no" do
		code <<-WTAF
		grep -q 'AllowTcpForwarding no' /etc/ssh/sshd_config || echo 'AllowTcpForwarding no' >> /etc/ssh/sshd_config
		WTAF
	end
end

#restart the sshd process so the next login will be duo protected
bash "restart sshd process" do
	code "kill -HUP `cat /var/run/sshd.pid`"
end

