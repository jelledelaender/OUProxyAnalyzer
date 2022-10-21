# OUProxyAnalyzer

Open University - The Netherlands

Software to support for MSc Software Engineer thesis, "Do iOS applications respects your privacy? A case study on popular iPhone apps in Belgium." by Jelle De Laender.

## Intro

This software helps in processing and analysing data collected via proxy software and DNS requests
This project is written in Ruby and exists in multiple smaller projects.

### Process Requests

When an application in scope was tested, a proxy setup kept track of all requests.
The overview of all requests was also exported as a CSV list (see example.csv for an example).
This process_request.rb script was made to analyze all requests to get initial insight.

The script will return a list of all domains that was contacted by the application, and how many times.
It also verifies if a secure connection or plain text connection was used.

This data will give some information about the setup, and if any trackers were used.

Usage:
`ruby process_requests.rb <csv_file.csv> <optional: filter_ip>`

The script has 2 parameters. The first one is the export file, like example.csv
The filter_ip is optional and can be used to filter the dataset by all requests from this IP

### Process DNS Requests

Related to the proxy setup, a custom local DNS server (like PiHole) was used.
All DNS requests were logged and collected.

This process_dns.rb script was developped to process this log file (dnsmasq),
in order to get an overview of all DNS requests.

This list can be used to verify the list of domains via the proxy.

Usage:
`ruby process_dns.rb <log_file> <optional: filter_ip>`

The script has 2 parameters. The first one is the log file, like example.log
The filter_ip is optional and can be used to filter the dataset by all requests from this IP



