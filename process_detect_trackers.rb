#!/usr/bin/env ruby

# process_detect_trackers.rb
# 
# Objective of process_detect_trackers.rb is to analyze the CSV export of the proxy
# The end result is an overview of all detected trackers
#
# Via an optional parameter, an IP can be given to limit the results of this host
#
# 
# Usage
# ruby ruby process_detect_trackers.rb <csv_file.csv> <optional: filter_ip>
# 

require 'csv'
require 'uri'
require 'date'

## Validating parameters
arg_length = ARGV.length
if arg_length < 1 || arg_length > 2
  puts "Incorrect usage."
  puts "Usage: ruby process_detect_trackers.rb <csv_file.csv> <optional: filter_ip>"
  exit
end

file = ARGV[0]

if !File.exists?(file)
  puts "No such file or directory"
  exit
end


ip = false
ip = ARGV[1] if arg_length > 1

if ip
  puts "Only processing requests from #{ip}"
end

## Initialising variables
number_of_requests = 0
unknown_domains = Hash.new(0)

trackers = [
   {"name"=>"Google Analytics", "type"=>"Ads", "domains"=>["ssl.google-analytics.com"], "occurrences"=>0},
   {"name"=>"Unity3D", "type"=>"Games", "domains"=>["config.uca.cloud.unity3d.com","cdp.cloud.unity3d.com"], "occurrences"=>0},
   {"name"=>"App-Measurement", "type"=>"App Usage", "domains"=>["app-measurement.com"], "occurrences"=>0},
   {"name"=>"DataDog", "type"=>"App Performance", "domains"=>["app-measurement.com"], "occurrences"=>0}
]

## TODO: Make more smart. Regex?

#begin
  CSV.foreach((file), headers: true, col_sep: ",") do |row|

    if ip != false && row["Client Address"] != "/#{ip}" ## Skip entry if IP filter is active, and client-address is different
        next
    end

    ## Processing entry
    number_of_requests += 1


    url = row["URL"]
    uri = URI.parse(url)
    host = uri.host

    next if host.end_with? ".apple.com" ## Skipping hosts of Apple
    next if host.end_with? ".icloud.com" ## Skipping hosts of Apple

    match = false
    trackers.each do |tracker|
      if tracker["domains"].include? host
        tracker["occurrences"] += 1
        match = true
        break ## Domain should be unique per tracker, optimising loop
      end

    end

    unknown_domains[host] += 1 if match == false ## Tracking unique unknown domains


  end 

# rescue Exception => e
#   puts "Exception triggered while processing file '#{file}': #{e}"
#   exit
# end

if  number_of_requests == 0
  puts "No data found. Is the correct CSV file used as input? Does the file meet the requirements?"
  exit
end

  ## Sort unknown domains, based on occurrences
  unknown_domains = unknown_domains.sort_by {|_key, value| -value}.to_h
  trackers = trackers.sort_by { |tracker| [ tracker["type"], tracker["occurrences"], tracker["name"] ] }

  puts "Detected Trackers:"
  trackers.each do
    |tracker| puts " - #{tracker["type"]}: #{tracker["name"]}: #{tracker["occurrences"]} times" if tracker["occurrences"] > 0
  end
 
  puts ""
  puts "Unknown Domains: #{unknown_domains.length}"
  unknown_domains.each { |key, value| puts " - #{key}: #{value} times" }
  puts ""

