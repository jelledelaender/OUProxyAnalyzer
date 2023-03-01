#!/usr/bin/env ruby

# process_dns.rb
# 
# Objective of process_dns.rb is to analyze the log file generated by pihole or dnsmasq.
# The end result is an overview of all domains that were queried
# Via an optional parameter, an IP can be given to limit the results of this host
# 
# Usage
# ruby process_dns.rb <log_file> <optional: filter_ip>
# 


require 'csv'
require 'uri'

## Validating parameters
arg_length = ARGV.length
if arg_length < 1 || arg_length > 2
  puts "Incorrect usage."
  puts "Usage: ruby process_dns.rb <file> <optional: filter_ip>"
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
number_of_queries = 0


begin
  File.open(file, "r").each_line do |line|

    ## Query based on PiHole log format to get type of request, filter on queries with from
    result = line.split(/^(.*) dnsmasq\[\d+\]\: (.+\[(.+)\]|.+) (.+) (from|is|to) (.+).*$/)

    ## Getting data of log line
   date = result[1]
   type = result[2]

    if type == "query[A]" || type == "query[AAAA]" ## We are only interested in query logs
      requester_ip = result[6]

      ## Filter on IP of Requester
      if ip == false || requester_ip == ip
       number_of_queries += 1
        host = result[4]
       hosts[host] += 1
      end

    end ## Ignoring other log entries like replies, forwards
end

rescue Exception => e
  puts "Exception triggered while processing file '#{file}': #{e}"
  exit
end

if hosts.length == 0
  puts "No data found. Is the correct dnsmasq / PiHole file used as input?"
  exit
end

hosts = hosts.sort_by {|_key, value| -value}.to_h ## Sorting on hosts with most requests

puts "Results:"
puts "Total Query Requests: #{number_of_queries}"
puts "Total Unique Hosts: #{hosts.length}"
puts ""
puts "Detected hosts:"
hosts.each { |key, value| puts "#{key}: #{value} times" }
puts "---"



