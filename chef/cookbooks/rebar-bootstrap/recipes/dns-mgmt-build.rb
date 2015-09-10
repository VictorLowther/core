#
# Cookbook Name:: rebar-bootstrap
# Recipe:: dns-mgmt-build
#
# Copyright (C) 2015 Greg Althaus

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#

ENV["GOPATH"]=node["bootstrap"]["gopath"]
dnsmgmtrepo=node["bootstrap"]["dnsmgmt"]

bash "Build and Install DNS mgmt server" do
  code <<EOC
/usr/local/go/bin/go get -u #{dnsmgmtrepo}
/usr/local/go/bin/go install #{dnsmgmtrepo}
mv ${GOPATH}/bin/rebar-dns-mgmt /usr/local/bin
mkdir -p /etc/dns-mgmt.d
cp -r ${GOPATH}/src/#{dnsmgmtrepo}/*.tmpl /etc/dns-mgmt.d
EOC
  not_if "which rebar-dns-mgmt"
end
