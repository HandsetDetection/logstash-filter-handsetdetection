#!/bin/bash

set -e

gem build logstash-filter-handsetdetection.gemspec
mv logstash-filter-handsetdetection-*.gem test.gem

LS="$(echo $LS_URL | sed -e s/.*\\/// -e s/.tar.gz$//)"
rm -rf $LS
[ -e $LS.tar.gz ] || wget --no-verbose $LS_URL
tar xzf $LS.tar.gz
cd $LS

./bin/logstash-plugin install ../test.gem
./bin/logstash -e '
    input { 
        stdin { } 
    }
    filter { 
        grok { 
            match => { 
                "message" => "%{COMBINEDAPACHELOG}" 
            } 
        } 
        handsetdetection {
            username => "'$API_USERNAME'"
            password => "'$API_SECRET'"
            site_id => '$API_SITE_ID' 
            filter => ["general_vendor", "general_model", "general_type", "general_platform", "general_platform_version", "general_browser", "general_browser_version"]
            online_api => '$API_ONLINE' 
        } 
    }
    output { 
        stdout { 
            codec => rubydebug 
        } 
    }
' < ../ci/sample.log | tee output.txt

grep \"general_[a-z_]*\"\ = output.txt | sort | cmp ../ci/expected.txt
cd ..
