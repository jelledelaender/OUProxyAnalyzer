# OUProxyAnalyzer

Open University - The Netherlands

Software to support for MsC Software Engineer thesis, "Do iOS applications respects your privacy? A case study on popular iPhone apps in Belgium." by Jelle De Laender.

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

Example output:

> Only processing requests from 192.168.1.54
> Results:
> Total Requests: 61
> Hosts: {"mobilecrush.king.com"=>48, "graph.facebook.com"=>11, "scontent.fbru5-1.fna.fbcdn.net"=>1, "gsp-ssl.ls.apple.com"=>1}
> Schemes: {"https"=>61}
> Insecure Requests: []

### Process DNS Requests

Besides to the proxy setup, a custom local DNS server (like PiHole) was used.
All DNS requests were logged and collected.

This process_dns.rb script was developped to process this log file (dnsmasq),
in order to get an overview of all DNS requests.

This list can be used to verify the list of domains via the proxy.

Usage:
`ruby process_dns.rb <log_file> <optional: filter_ip>`

The script has 2 parameters. The first one is the log file, like example.log
The filter_ip is optional and can be used to filter the dataset by all requests from this IP

Example output:

> Only processing requests from 192.168.1.54
> Results:
> Total Query Requests: 17
> Hosts: {"mobilecrush.king.com"=>7, "p.midasplayer.com"=>2, "www.google.com"=>2, "king-candycrush-prod.secure2.footprint.net"=>1, "commnat-main-gc.ess.apple.com"=>1, "commnat-cohort-gc.ess.apple.com"=>1, "bling2.midasplayer.com"=>1, "servicelayer.king.com"=>1, "king-contenido-prod.secure2.footprint.net"=>1}

### Listing trackers

By analysing all requests, the called domains can be listed, and filtered on known domains of tracker services.
The "process_detect_trackers.rb" script helps with this.

The process_detect_trackers.rb script was developed to process the proxy log file, and list all detected trackers

Usage:
`ruby process_detect_trackers.rb <log_file> <optional: filter_ip>`

The script has 2 parameters. The first one is the log file, like example.log
The filter_ip is optional and can be used to filter the dataset by all requests from this IP

Example output:

> Only processing requests from 192.168.1.54
> Detected Trackers:
>  - Ads: Vungle: 4 times
> - Ads: SuperSonic: 5 times
> - Ads: Facebook: 12 times
> - Ads: UnityAds: 25 times
> - App Performance: Sentry: 3 times
> - App Usage: AppCenter: 2 times
> - App Usage: App-Measurement: 5 times
> - App Usage: Facebook: 12 times
> - App Usage: AppsFlyer: 21 times
> - Games: Unity3D: 4 times
> 
> Unknown Domains: 21
> - fishdom.playrix.com: 47 times
> - 3444.api.swrve.com: 44 times
> - fishdom-cdn.playrix.com: 35 times
> - uinfo6.playrix.com: 23 times
> - www.playrix.com: 15 times
> - stats.playrix.com: 13 times
> - playrix.helpshift.com: 8 times
> - cookie-cdn.cookiepro.com: 7 times
> - networksdk.ssacdn.com: 7 times
> - s3.amazonaws.com: 6 times
> - cdn-creatives-akamaistls-prd.acquire.unity3dusercontent.com: 4 times
> - code.jquery.com: 2 times
> - cdn.playrix.com: 2 times
> - cdn.liftoff-creatives.io: 2 times
> - firebaselogging-pa.googleapis.com: 2 times
> - safebrowsing.googleapis.com: 1 times
> - scontent.fbru5-1.fna.fbcdn.net: 1 times
> - firebaseinstallations.googleapis.com: 1 times
> - www.googletagmanager.com: 1 times
> - geolocation.onetrust.com: 1 times
> - is4-ssl.mzstatic.com: 1 times

