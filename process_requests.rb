#!/usr/bin/env ruby

# process_requests.rb
# 
# Objective of process_rquests.rb is to analyze the CSV export of the proxy
# The end result is an overview of the requests
# Which domains were requested, was HTTPS used
# How many times was the less secure HTTP used, and showing those URLs
#
# Via an optional parameter, an IP can be given to limit the results of this host
# 
# Usage
# ruby process_requests.rb <csv_file.csv> <optional: filter_ip>
# 

require 'csv'
require 'uri'
require 'date'

## Validating parameters
arg_length = ARGV.length
if arg_length < 1 || arg_length > 2
  puts "Incorrect usage."
  puts "Usage: ruby process_requests.rb <csv_file.csv> <optional: filter_ip>"
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
hosts = Hash.new(0)
schemes = Hash.new(0)
insecure_requests = Array.new
number_of_requests = 0
date_first_test = false
date_last_test = false

# data = CSV.read("CancyCrush.csv")

CSV.foreach((file), headers: true, col_sep: ",") do |row|
    ## DataFields
    # URL
    # Status
    # Response Code
    # Protocol
    # Method
    # Content-Type
    # Client Address
    # Client Port
    # Remote Address
    # Remote Port
    # Exception
    # Request Start Time
    # Request End Time
    # Response Start Time
    # Response End Time
    # Duration (ms)
    # DNS Duration (ms)
    # Connect Duration (ms)
    # SSL Duration (ms),Request Duration (ms)
    # Response Duration (ms)
    # Latency (ms)
    # Speed (KB/s)
    # Request Speed (KB/s)
    # Response Speed (KB/s)
    # Request Handshake Size (bytes)
    # Request Header Size (bytes)
    # Request Body Size (bytes)
    # Response Handshake Size (bytes)
    # Response Header Size (bytes)
    # Response Body Size (bytes)
    # Request Compression
    # Response Compression

    if ip != false && row["Client Address"] != "/#{ip}" ## Skip entry if IP filter is active, and client-address is different
        next
    end

    ## Processing entry
    number_of_requests += 1

    date_last_test = DateTime.parse row["Request Start Time"]

    date_first_test = date_last_test  if date_first_test == false


    url = row["URL"]
    
    uri = URI.parse(url)
        
    schemes[uri.scheme] += 1
    hosts[uri.host] += 1

    insecure_requests.append url if uri.scheme == "http"
end 

## Sorting counters
schemes = schemes.sort_by {|_key, value| -value}.to_h
hosts = hosts.sort_by {|_key, value| -value}.to_h

puts "Results:"
puts "Total Requests: #{number_of_requests}"
puts "Proxy requests detected between  #{date_first_test} and #{date_last_test}"
puts "Testing time (based on proxy): #{((date_last_test - date_first_test)*60*24).to_i} minutes"
puts "Hosts: #{hosts}"
puts "Hosts (as string): #{hosts.keys.join(",")}"
puts "Schemes: #{schemes}" 
puts "Insecure Requests: #{insecure_requests}" 

