#!/bin/bash

logstash-plugin install /test.gem

# Online API

gosu logstash logstash -e '
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
            filter => ["general_vendor", "general_model", "general_type"]
            online_api => true
        } 
    }
    output { 
        stdout { 
            codec => rubydebug 
        } 
    }
' < sample.log

# Offline API

gosu logstash logstash -e '
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
            filter => ["general_vendor", "general_model", "general_type"]
        } 
    }
    output { 
        stdout { 
            codec => rubydebug 
        } 
    }
' < sample.log
