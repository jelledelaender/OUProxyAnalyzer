#!/usr/bin/env ruby

# process_detect_trackers.rb
# 
# Objective of process_detect_trackers.rb is to analyze the CSV export of the proxy
# The end result is an overview of all detected trackers, and all unknown domains for manual matching
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

## DataSet is not complete, based on found data
trackers = [
   ## Ads
   {"name"=>"Facebook", "type"=>"Ads", "domains"=>["graph.facebook.com"], "occurrences"=>0},
   {"name"=>"DoubleClick", "type"=>"Ads", "domains"=>["doubleclick.net"], "occurrences"=>0},
   {"name"=>"Quant", "type"=>"Ads", "domains"=>[".quantcast.com"], "occurrences"=>0},
   {"name"=>"OutBrain", "type"=>"Ads", "domains"=>["outbrainimg.com","outbrain.com"], "occurrences"=>0},
   {"name"=>"AddAppTr", "type"=>"Ads", "domains"=>[".aatkit.com"], "occurrences"=>0},
   {"name"=>"PubNative", "type"=>"Ads", "domains"=>["pubnative.net"], "occurrences"=>0},
   {"name"=>"Amazon", "type"=>"Ads", "domains"=>["amazon-adsystem.com"], "occurrences"=>0},
   {"name"=>"Vungle", "type"=>"Ads", "domains"=>["ads.vungle.com", ".vungle.com"], "occurrences"=>0},
   {"name"=>"UnityAds", "type"=>"Ads", "domains"=>[".unityads.unity3d.com"], "occurrences"=>0},
   {"name"=>"SuperSonic", "type"=>"Ads", "domains"=>["supersonicads.com"], "occurrences"=>0},
   {"name"=>"Criteo", "type"=>"Ads", "domains"=>[".criteo.com", ".criteo.net"], "occurrences"=>0},
   {"name"=>"Teads", "type"=>"Ads", "domains"=>["teads.tv"], "occurrences"=>0},
   {"name"=>"AdColony", "type"=>"Ads", "domains"=>[".adcolony.com"], "occurrences"=>0},
   {"name"=>"SmartAds", "type"=>"Ads", "domains"=>["smartadserver.com"], "occurrences"=>0},
   {"name"=>"GoogleAdservices", "type"=>"Ads", "domains"=>["googleadservices.com", "pagead2.googlesyndication.com", "adservice.google.be", "adservice.google.com"], "occurrences"=>0},
   {"name"=>"MoatAds", "type"=>"Ads", "domains"=>["moatads.com"], "occurrences"=>0},
   ## Games
   {"name"=>"Unity3D", "type"=>"Games", "domains"=>["config.uca.cloud.unity3d.com","cdp.cloud.unity3d.com", "events.mz.unity3d.com"], "occurrences"=>0},
   {"name"=>"DeltaDNA", "type"=>"Games", "domains"=>[".deltadna.net"], "occurrences"=>0},
   {"name"=>"GameAnalytics", "type"=>"Games", "domains"=>["gameanalytics.com"], "occurrences"=>0},
   {"name"=>"LuneLabs", "type"=>"Games", "domains"=>[".lunalabs.io"], "occurrences"=>0},
   ## App Usage
   {"name"=>"App-Measurement", "type"=>"App Usage", "domains"=>["app-measurement.com"], "occurrences"=>0},
   {"name"=>"Google Analytics", "type"=>"App Usage", "domains"=>["google-analytics.com"], "occurrences"=>0},
   {"name"=>"AppsFlyer", "type"=>"App Usage", "domains"=>["appsflyer.com", ".appsflyersdk.com"], "occurrences"=>0},
   {"name"=>"Flurry", "type"=>"App Usage", "domains"=>["data.flurry.com"], "occurrences"=>0},
   {"name"=>"Facebook", "type"=>"App Usage", "domains"=>["graph.facebook.com"], "occurrences"=>0},
   {"name"=>"Hotjar", "type"=>"App Usage", "domains"=>[".hotjar.com",".hotjar.io"], "occurrences"=>0},
   {"name"=>"Amplitude", "type"=>"App Usage", "domains"=>["api2.amplitude.com","lab.amplitude.com"], "occurrences"=>0},
   {"name"=>"AppLoving", "type"=>"App Usage", "domains"=>["applovin.com"], "occurrences"=>0},
   {"name"=>"IronSource", "type"=>"App Usage", "domains"=>["ironsrc.mobi"], "occurrences"=>0},
   {"name"=>"FitAnalytics", "type"=>"App Usage", "domains"=>["fitanalytics.com"], "occurrences"=>0},
   ## App Performance
   {"name"=>"CrashLytics", "type"=>"App Performance", "domains"=>["crashlytics.com","crashlyticsreports-pa.googleapis.com"], "occurrences"=>0},
   {"name"=>"Sentry", "type"=>"App Performance", "domains"=>["sentry.io"], "occurrences"=>0},
   {"name"=>"DataDog", "type"=>"App Performance", "domains"=>["browser-intake-datadoghq.com", "logs.datadoghq.eu"], "occurrences"=>0},
   {"name"=>"AppCenter", "type"=>"App Usage", "domains"=>["in.appcenter.ms"], "occurrences"=>0},
   {"name"=>"BugSnag", "type"=>"App Usage", "domains"=>["sessions.bugsnag.com"], "occurrences"=>0},
   {"name"=>"NewRelic", "type"=>"App Performance", "domains"=>["js-agent.newrelic.com"], "occurrences"=>0},
]

def host_contain_tracker(host, tracker)
  tracker["domains"].each do |domain|
    return true if host.end_with?(domain) ## Allowing more generic domains
  end

  tracker["domains"].include? host
end

def exclude_host host
  hosts = ["c.apple.news",".apple.com",".icloud.com","token.safebrowsing.apple"] ## Skipping hosts of Apple

  hosts.each do |domain|
    return true if host.end_with? domain
  end

  false
end

begin
  CSV.foreach((file), headers: true, col_sep: ",") do |row|

    if ip != false && row["Client Address"] != "/#{ip}" ## Skip entry if IP filter is active, and client-address is different
        next
    end

    ## Processing entry
    number_of_requests += 1


    url = row["URL"]
    uri = URI.parse(url)
    host = uri.host

    next if exclude_host host ## Skip system hosts

    match = false
    trackers.each do |tracker|
      if  host_contain_tracker(host, tracker)
        tracker["occurrences"] += 1
        match = true
      end
    end

    unknown_domains[host] += 1 if match == false ## Tracking unique unknown domains


  end 

rescue Exception => e
  puts "Exception triggered while processing file '#{file}': #{e}"
  exit
end

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

