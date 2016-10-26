# encoding: utf-8
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

    unless @online_api
      hd = HD4.new @hd_config
      hd.set_timeout 500
      hd.device_fetch_archive
      hd.set_timeout 30
    end
    @pool = [ hd ]
  end

  public
  def filter(event)
    data = {}
    @match.each do |src, dest|
      if event.include? src
        data[dest] = event[src]
      end
    end 
    hd = @pool.pop
    hd = HD4.new @hd_config if hd.nil?
    hd.device_detect data
    r = hd.get_reply
    @pool << hd
    if r.key? 'class'
      event['handset_class'] = r['class']
    end
    if r.key? 'hd_specs'
      if @filter.empty?
        event['handset_specs'] = r['hd_specs']
      else
        event['handset_specs'] = {} 
        @filter.each do |f|
          if r['hd_specs'].key? f
            event['handset_specs'][f] = r['hd_specs'][f]
          end
        end 
      end
    end
    filter_matched event
  end
end
