#--
# Copyright (c) Richard Uren 2016 <richard@teleport.com.au>
# All Rights Reserved
#
# LICENSE: Redistribution and use in source and binary forms, with or
# without modification, are permitted provided that the following
# conditions are met: Redistributions of source code must retain the
# above copyright notice, this list of conditions and the following
# disclaimer. Redistributions in binary form must reproduce the above
# copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the
# distribution.
#
# THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN
# NO EVENT SHALL CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
# OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
# USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
# DAMAGE.
#++

require 'logstash/filters/base'
require 'logstash/namespace'
require 'handset_detection'

class LogStash::Filters::HandsetDetection < LogStash::Filters::Base

  config_name 'handsetdetection'

  config :online_api,   :validate => :boolean, :default => false
  config :username,     :validate => :string,  :default => ''
  config :password,     :validate => :string,  :default => ''
  config :site_id,      :validate => :number,  :default => 0
  config :apiserver,    :validate => :string,  :default => 'api.handsetdetection.com'
  config :match,        :validate => :hash,    :default => { 'agent' => 'user-agent' }
  config :filter,       :validate => :array,   :default => [] 
  config :use_proxy,    :validate => :boolean, :default => false 
  config :proxy_server, :validate => :string,  :default => '' 
  config :proxy_port,   :validate => :number,  :default => 3128 
  config :proxy_user,   :validate => :string,  :default => '' 
  config :proxy_pass,   :validate => :string,  :default => '' 
  config :local_archive_source, :validate => :string, :default => nil

  public
  def register
    @hd_config = {}
    @hd_config['username'] = @username
    @hd_config['secret'] = @password
    @hd_config['site_id'] = @site_id
    @hd_config['use_local'] = @online_api ? false : true 
    @hd_config['filesdir'] = '/tmp'
    @hd_config['cache'] = {'none' => {}}
    @hd_config['debug'] = false
    @hd_config['api_server'] = @apiserver
    @hd_config['cache_requests'] = false
    @hd_config['geoip'] = true
    @hd_config['timeout'] = 30
    @hd_config['use_proxy'] = @use_proxy
    @hd_config['proxy_server'] = @proxy_server
    @hd_config['proxy_port'] = @proxy_port
    @hd_config['proxy_user'] = @proxy_user
    @hd_config['proxy_pass'] = @proxy_pass
    @hd_config['retries'] = 3 
    @hd_config['log_unknown'] = true 
    @hd_config['local_archive_source'] = @local_archive_source 

    @@pool = []
    unless @online_api
      hd = HD4.new @hd_config
      hd.set_timeout 500
      hd.device_fetch_archive
      hd.set_timeout 30
      @@pool << hd
    end
  end

  public
  def filter(event)
    data = {}
    @match.each do |src, dest|
      unless event.get(src).nil?
        data[dest] = event.get src
      end
    end 
    hd = @@pool.pop
    hd = HD4.new @hd_config if hd.nil?
    hd.device_detect data
    r = hd.get_reply
    @@pool << hd
    if r.key? 'class'
      event.set 'handset_class', r['class']
    end
    if r.key? 'hd_specs'
      if @filter.empty?
        event.set 'handset_specs', r['hd_specs']
      else
        event.set 'handset_specs', {} 
        @filter.each do |f|
          if r['hd_specs'].key? f
            event.set "[handset_specs][#{f}]", r['hd_specs'][f]
          end
        end 
      end
    end
    filter_matched event
  end
end
