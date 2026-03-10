#!/usr/bin/env ruby

require "json"
require "uri"

class URLExtractor
  attr_reader :urls

  def initialize(json_file)
    @json_file = json_file
    @urls = { jpg: [], mp4: [], others: [] }
  end

  def extract
    begin
      data = JSON.parse(File.read(@json_file))
    rescue JSON::ParserError => e
      puts "Error parsing JSON: #{e.message}"
      exit 1
    rescue Errno::ENOENT
      puts "File not found: #{@json_file}"
      exit 1
    end

    traverse(data)
    # display_results
    quick_display # Alternative display: just show url
  end

  private

  def traverse(obj, path = [])
    case obj
    when Hash
      obj.each do |key, value|
        traverse(value, path + [key])
      end
    when Array
      obj.each_with_index do |item, index|
        traverse(item, path + [index.to_s])
      end
    when String
      check_url(obj, path)
    end
  end

  def check_url(value, path)
    return unless value.is_a?(String)

    # TODO: removeme puts "string: #{value}" # if value.match?(/http/i)

    # TODO: see if you can change the regex matching better.
    # Check if it looks like a URL
    # || value.match?(%r{^/[\w/.-]+}) || value.match?(%r{^[\w/.-]+\.(jpg|mp4)})
    return unless value.match?(/^http/i)
    return if value.match?(/jpg_fb20_s235x350/) # ignore intermediary blurred image urls
    return if value.match?(/jpg_s81x81/) # ignore small image urls
    return if value.match?(/jpg_s80x80/) # ignore small image urls
    return if value.match?(/tag=progressive_h264-basic-gen2_360p/) # ignore urls of low-res videos

    case value.downcase
    when /jpg/
      @urls[:jpg] << { url: value, path: path.join(" > ") }
    when /mp4/
      @urls[:mp4] << { url: value, path: path.join(" > ") }
      # else
      #   @urls[:others] << { url: value, path: path.join(" > ") }
    end
  end

  def quick_display
    if @urls[:jpg].empty? && @urls[:mp4].empty? && @urls[:others].empty?
      # puts "No JPG or MP4 URLs found in the JSON file. So are other URLs"
      puts "#### No URLs found ####"
      return
    end

    unless @urls[:jpg].empty?
      puts "\n📷 JPG URLs found: #{@urls[:jpg].count}"
      puts "-" * 60
      @urls[:jpg].each_with_index do |item, index|
        puts "    #{item[:url]}"
        puts
      end
    end

    unless @urls[:mp4].empty?
      puts "\n🎥 MP4 URLs found: #{@urls[:mp4].count}"
      puts "-" * 60
      @urls[:mp4].each_with_index do |item, index|
        # puts "#{index + 1}. #{item[:url]}"
        puts "    #{item[:url]}"
        puts
      end
    end

    puts "=" * 60
  end

  def display_results
    if @urls[:jpg].empty? && @urls[:mp4].empty?
      # puts "No JPG or MP4 URLs found in the JSON file."
      puts "#### No URLs found ####"
      return
    end

    puts "\n" + ("=" * 60)
    puts "URL EXTRACTION RESULTS"
    puts "=" * 60

    unless @urls[:jpg].empty?
      puts "\n📷 JPG URLs found: #{@urls[:jpg].count}"
      puts "-" * 60
      @urls[:jpg].each_with_index do |item, index|
        # puts "#{index + 1}. #{item[:url]}"
        puts "    #{item[:url]}"
        puts "   Path: #{item[:path]}" if item[:path]
        puts
      end
    end

    unless @urls[:mp4].empty?
      puts "\n🎥 MP4 URLs found: #{@urls[:mp4].count}"
      puts "-" * 60
      @urls[:mp4].each_with_index do |item, index|
        # puts "#{index + 1}. #{item[:url]}"
        puts "    #{item[:url]}"
        puts "   Path: #{item[:path]}" if item[:path]
        puts
      end
    end

    # unless @urls[:others].empty?
    #   puts "\n🎥 URLs found: #{@urls[:others].count}"
    #   puts "-" * 60
    #   @urls[:others].each_with_index do |item, index|
    #     # puts "#{index + 1}. #{item[:url]}"
    #     puts "    #{item[:url]}"
    #     puts "   Path: #{item[:path]}" if item[:path]
    #     puts
    #   end
    # end

    puts "=" * 60
    puts "Total URLs found: #{@urls[:jpg].count + @urls[:mp4].count + @urls[:others].count}"
    puts "=" * 60
  end
end

# Script execution
if ARGV.length != 1
  puts "Usage: #{$0} <json_file>"
  puts "Example: #{$0} data.json"
  exit 1
end

extractor = URLExtractor.new(ARGV[0])
extractor.extract
