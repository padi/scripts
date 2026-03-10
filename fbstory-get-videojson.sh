#!/bin/bash

# FB Story Scraper
# 1. In Chrome: Right click > View Source,
# 2. Save the html file
# 3. Use is it as a parameter here
# 4. Result: returns relevant URLs for extraction

if [ -z "$1" ]; then
  echo "Usage: $0 <html_file>"
  exit 1
fi

input_file="$1"

if [ ! -f "$input_file" ]; then
  echo "Error: File '$input_file' not found."
  exit 1
fi

cat "$input_file" | grep ScheduledServerJS | grep VideoPlayerShakaPerformanceLoggerConfig >targetscripttag.html
sed -n 's/.*<script[^>]*>\(.*\)<\/script>.*/\1/p' targetscripttag.html >target.json
./fbjson_url_extractor.rb target.json >testresult.txt
