[![Build Status](https://travis-ci.org/HandsetDetection/logstash-filter-handsetdetection.svg?branch=master)](https://travis-ci.org/HandsetDetection/logstash-filter-handsetdetection)
[![Gem Version](https://badge.fury.io/rb/logstash-filter-handsetdetection.svg)](https://badge.fury.io/rb/logstash-filter-handsetdetection)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

# Handset Detection for Logstash

This is the [Handset Detection](http://www.handsetdetection.com/) plugin for [Logstash](https://github.com/elastic/logstash).

## Example

Extract the User-Agent header from an Apache log with Grok, and then enrich the log with Headset Detection data:

```
    filter { 
        grok { 
            match => {  
                "message" => "%{COMBINEDAPACHELOG}" 
            } 
        } 
        handsetdetection {
            username   => "xxxxxxxxxx" 
            password   => "xxxxxxxxxxxxxxxx"
            site_id    => 000000
            online_api => false
            match      => { 
                "agent" => "user-agent" 
            }
            filter     => [
                "general_vendor", "general_model", "general_type"
            ]
        } 
    }
```

## Configuration Fields

| Field | Description | Default |
| --- | --- | --- |
| `online_api` | Set to `true` in order to do **online** lookups against the Handset Detection API  | `false` |
| `username` | Your Handset Detection API username | |
| `password` | Your Handset Detection API password | |
| `site_id` | The Handset Detection API site ID to use | |
| `match` | An associative array mapping input field names to header names used for handset detection. For example: Extract the `user-agent` header from the `agent` input field. | `{ "agent" => "user-agent" }` |
| `filter` | Optionally, define an array of the handset spec properties to be included in the output. By default, all properties are included in the output. | [] |
| `use_proxy` | Set to `true` if accessing the web through a proxy | `false` |
| `proxy_server` | The proxy server address, if using a proxy ||
| `proxy_port` | The proxy server port, if using a proxy ||
| `proxy_user` | Your proxy server username, if authenticating to a proxy ||
| `proxy_password` | Your proxy server password, if authenticating to a proxy ||

## Installation

```
# Logstash 2.3 and higher
bin/logstash-plugin install logstash-filter-handsetdetection-1.1.0

# Prior to Logstash 2.3
bin/plugin install logstash-filter-handsetdetection-1.1.0
```

## Building from source

```
gem build  logstash-filter-handsetdetection.gemspec
```
