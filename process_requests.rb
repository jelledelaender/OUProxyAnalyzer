#!/usr/bin/env ruby

require 'csv'
require 'uri'

hosts = Hash.new(0)
schemes = Hash.new(0)
insecure_requests = Array.new
number_of_requests = 0

# data = CSV.read("CancyCrush.csv")

CSV.foreach(("example.csv"), headers: true, col_sep: ",") do |row|
    number_of_requests += 1

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

    url = row["URL"]
    
    uri = URI.parse(url)
    
#    uri.host.split('.').first
    
    schemes[uri.scheme] += 1
    hosts[uri.host] += 1

    insecure_requests.append url if uri.scheme == "http"
end 

schemes = schemes.sort_by {|_key, value| -value}.to_h
hosts = hosts.sort_by {|_key, value| -value}.to_h


puts "Results:"
puts "Total Requests: #{number_of_requests}"
puts "Hosts: #{hosts}"
puts "Schemes: #{schemes}" 
puts "Insecure Requests: #{insecure_requests}" 

