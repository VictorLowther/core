# Copyright 2015, RackN
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
class NetworkAllocationsController < ::ApplicationController
  respond_to :json

  def match
    attrs = NetworkAllocation.attribute_names.map{|a|a.to_sym}
    objs = []
    ok_params = params.permit(attrs)
    objs = NetworkAllocation.where(ok_params) if !ok_params.empty?
    respond_to do |format|
      format.html {}
      format.json { render api_index NetworkAllocation, objs }
    end
  end
  
  def create
    params.require(:node_id)
    node = Node.find(params[:node_id])
    network = Network.find_by(id: params[:network_id])
    range = NetworkRange.find_by(id: params[:network_range_id])
    suggestion = params[:address]
    suggestion = nil if suggestion && suggestion == ""
    if range
      ret = range.allocate(node,suggestion)
    elsif network
      ret = network.auto_allocate(node)
    else
      raise "Need a network or range"
    end
    render :json => ret
  end

  def destroy
    params.require(:id)
    @allocation = NetworkAllocation.find(params[:id])
    @allocation.destroy
    render api_delete @allocation
  end

  def index
    @list = if params.has_key? :network_id or params.has_key? :network
              Network.find_key(params[:network_id] || params[:network]).network_allocations
            elsif params.has_key?(:network_range_id)
              NetworkRange.find(params[:network_range_id]).network_allocations
            elsif params.has_key?(:node_id) || params.has_key?(:node)
              Node.find_key(params[:node_id] || params[:node]).network_allocations
            else
              NetworkAllocation.all
            end
    respond_to do |format|
      format.html { }
      format.json { render api_index NetworkAllocation, @list }
    end
  end

  def show
    @allocation = NetworkAllocation.find_key(params[:id]) rescue nil
    respond_to do |format|
      format.html {
                    @list = [@allocation]
                    render :action=>:index
                  }
      format.json { render api_show @allocation }
    end
  end

end
