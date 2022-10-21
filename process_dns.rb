#!/usr/bin/env ruby

require 'csv'
require 'uri'

hosts = Hash.new(0)
number_of_queries = 0

IP_FILTER = "192.168.1.54"

File.open("example.log", "r").each_line do |line|
  ## Query based on PiHole log format to get type of request, filter on queries with from
  result = line.split(/^(.*) dnsmasq\[\d+\]\: (.+\[(.+)\]|.+) (.+) (from|is|to) (.+).*$/)

  date = result[1]
  type = result[2]

  if type == "query[A]" || type == "query[AAAA]"
    requester_ip = result[6]

    ## Filter on IP of Requester
    if requester_ip == IP_FILTER
      number_of_queries += 1
      host = result[4]
      hosts[host] += 1
    end

  end ## Ignoring other log entries like replies
end

hosts = hosts.sort_by {|_key, value| -value}.to_h

puts "Results:"
puts "Total Query Requests: #{number_of_queries}"
puts "Hosts: #{hosts}"
