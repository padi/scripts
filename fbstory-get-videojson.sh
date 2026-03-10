#!/bin/bash

cat fbraw.html | grep ScheduledServerJS | grep VideoPlayerShakaPerformanceLoggerConfig >targetscripttag.html
sed -n 's/.*<script[^>]*>\(.*\)<\/script>.*/\1/p' targetscripttag.html >target.json
./fbjson_url_extractor.rb target.json >testresult.txt
