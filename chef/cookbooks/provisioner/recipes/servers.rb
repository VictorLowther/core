# Copyright 2011, Dell
# Copyright 2012, SUSE Linux Products GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License
# You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied
# See the License for the specific language governing permissions and
# limitations under the License
#
# This recipe sets up Apache and TFTP servers.

node.normal["crowbar"]["provisioner"]["server"]["name"]=node.name
v4addr=node.address("admin",IP::IP4)
v6addr=node.address("admin",IP::IP6)
node.normal["crowbar"]["provisioner"]["server"]["v4addr"]=v4addr.addr if v4addr
node.normal["crowbar"]["provisioner"]["server"]["v6addr"]=v6addr.addr if v6addr
web_port = node["crowbar"]["provisioner"]["server"]["web_port"]
provisioner_web="http://#{v4addr.addr}:#{web_port}"
node.normal["crowbar"]["provisioner"]["server"]["webserver"]=provisioner_web
localnets = ["127.0.0.1","::1","fe80::/10"] + node.all_addresses.map{|a|a.network.to_s}.sort
swsrepo="github.com/VictorLowther/sws"
bash "Build stupid web server" do

  code <<EOC
. /etc/profile
set -e
go get #{swsrepo}
cd "$GOPATH/src/#{swsrepo}"
go build
mv sws /usr/local/bin
EOC
  not_if "which sws"
end

template "/etc/systemd/system/provisioner.service" do
  source "provisioner.service.erb"
  variables(:docroot => node["crowbar"]["provisioner"]["server"]["root"],
            :port => node["crowbar"]["provisioner"]["server"]["web_port"])
  notifies :restart, "service[provisioner]"
end

service "provisioner" do
  action [ :enable, :start ]
end

# Set up the TFTP server as well.
case node["platform"]
when "ubuntu", "debian"
  package "tftpd-hpa"
when "redhat","centos"
  package "tftp-server"
when "suse"
  package "tftp"
end

case node["platform"]
when "suse"
  service "tftp" do
    enabled true
    if node["platform_version"].to_f >= 12.3
      provider Chef::Provider::Service::Systemd
      service_name "tftp.socket"
      action [ :enable, :start ]
    else
      # on older releases just enable, don't start (xinetd takes care of it)
      action [ :enable ]
    end
  end
  service "xinetd" do
    running true
    enabled true
    action [ :enable, :start ]
  end unless node["platform_version"].to_f >= 12.3
when "redhat","centos"
  template "/etc/xinetd.d/tftp" do
    source "xinetd.tftp.erb"
    variables(:tftproot => node["crowbar"]["provisioner"]["server"]["root"])
    mode 0644
    user "root"
    group "root"
    notifies :restart, "service[xinetd]"
  end
  service "xinetd" do
    action [:enable, :start]
  end
when "ubuntu"
  service "tftpd-hpa" do
    action [ :enable ]
  end
  template "/etc/default/tftpd-hpa" do
    source "tftpd-ubuntu.erb"
    mode 0644
    user "root"
    group "root"
    variables(
              :address => "0.0.0.0:69",
              :tftproot => node["crowbar"]["provisioner"]["server"]["root"]
              )
    notifies :restart, resources(:service => "tftpd-hpa")
  end
else
  raise "Cannot set up TFTP on #{node[platform]}"
end

