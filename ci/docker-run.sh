#!/bin/bash

gem build logstash-filter-handsetdetection.gemspec

mv logstash-filter-handsetdetection-*.gem test.gem

docker run -i --rm \
    -e API_USERNAME \
    -e API_SECRET \
    -e API_SITE_ID \
    -v $(pwd)/test.gem:/test.gem:z \
    -v $(pwd)/ci/logstash.sh:/logstash.sh:z \
    -v $(pwd)/ci/sample.log:/sample.log:z \
    logstash:2.3.4 \
    /logstash.sh | tee output.txt 
 
grep general_model output.txt | cmp ci/general_model.txt
