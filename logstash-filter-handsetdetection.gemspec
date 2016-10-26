Gem::Specification.new do |s|
  s.name = 'logstash-filter-handsetdetection'
  s.version = '1.2.0'
  s.licenses = ['Apache-2.0']
  s.summary = "Handset Detection filter plugin for Logstash"
  s.description = "This gem is a Logstash plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/logstash-plugin install gemname. This gem is not a stand-alone program"
  s.authors = ["Handset Detection"]
  s.email = 'hello@handsetdetection.com'
  s.homepage = "http://www.handsetdetection.com/"
  s.require_paths = ["lib"]

  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE','NOTICE.TXT']
   # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "filter" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core", ">= 2.0.0", "< 3.0.0"
  s.add_runtime_dependency "json", "~> 1.8"
  s.add_runtime_dependency "handset_detection", "~> 0.1", ">= 0.1.8"

  #s.add_development_dependency 'logstash-devutils'
end
