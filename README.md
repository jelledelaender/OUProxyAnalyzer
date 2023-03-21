# OUProxyAnalyzer

Open University - The Netherlands

Software to support for MSc Software Engineer thesis, "Do iOS applications respect your privacy? A case study on popular iPhone apps in Belgium." by Jelle De Laender.

## Intro

This software helps in processing and analysing data collected via proxy software and DNS requests
This project is written in Ruby and exists in multiple smaller scripts.

### Process Requests

When an application in scope was tested, a proxy setup kept track of all requests.
The overview of all requests was also exported as a CSV list (see example_proxy.csv for an example).
The process_request.rb script was made to analyse all requests to get initial insight.

The script will return a list of all domains that were contacted by the application and how many times.
It also verifies if a secure connection or plain text connection was used.

This data will give some information about the setup and if any trackers were used.

Usage:
`ruby process_requests.rb <csv_file.csv> <optional: filter_ip>`

The script has two parameters. The first one is the export file, e.g. example_proxy.csv
The filter_ip is optional and can be used to filter the dataset by all requests from the given IP, to ensure you only process requests that were made from this IP.

Example output:

> Only processing requests from 192.168.1.54
> Total Requests Intercepted: 274
> Proxy requests detected between  2022-11-13T15:12:24+00:00 and 2022-11-13T15:18:04+00:00
> Testing time (based on proxy data): 5 minutes
> Total Unique Hosts: 37
> 
> Detected hosts:
>  - apptoogoodtogo.com: 86 times
>  - gspe19-ssl.ls.apple.com: 64 times
>  - images.tgtg.ninja: 25 times
>  - toogoodtogo.be: 21 times
>  - api2.amplitude.com: 16 times
>  - fonts.gstatic.com: 9 times
>  - sdk.fra-01.braze.eu: 8 times
>  - skadsdkless.appsflyer.com: 4 times
>  - policy.app.cookieinformation.com: 4 times
>  - region1.app-measurement.com: 4 times
>  - firebaseremoteconfig.googleapis.com: 3 times
>  - token.safebrowsing.apple: 2 times
>  - consent.app.cookieinformation.com: 2 times
>  - gspe79-ssl.ls.apple.com: 2 times
>  - gsp64-ssl.ls.apple.com: 2 times
>  - configuration.ls.apple.com: 1 times
>  - gsp-ssl.ls.apple.com: 1 times
>  - www.googletagmanager.com: 1 times
>  - sentry.io: 1 times
>  - mkt-cms.toogoodtogo.com: 1 times
>  - firebaselogging-pa.googleapis.com: 1 times
>  - apptrailers-ssl.itunes.apple.com: 1 times
>  - launches.appsflyer.com: 1 times
>  - firebase-settings.crashlytics.com: 1 times
>  - firebaseinstallations.googleapis.com: 1 times
>  - firebasedynamiclinks.googleapis.com: 1 times
>  - app-measurement.com: 1 times
>  - cdn-settings.appsflyersdk.com: 1 times
>  - skadsdk.appsflyer.com: 1 times
>  - ca.iadsdk.apple.com: 1 times
>  - conversions.appsflyer.com: 1 times
>  - dynamic-config-api.appsflyer.com: 1 times
>  - gcdsdk.appsflyer.com: 1 times
>  - attr.appsflyer.com: 1 times
>  - pancake.apple.com: 1 times
>  - safebrowsing.googleapis.com: 1 times
>  - gspe35-ssl.ls.apple.com: 1 times
> 
> Schemes: {"https"=>274}
> Insecure Requests: 0

### Process DNS Requests

Besides the proxy setup, a custom local DNS server (such as PiHole) was used.
All DNS requests were logged and collected.

The process_dns.rb script was developed to process this log file (dnsmasq),
in order to get an overview of all DNS requests.

This list can be used to verify the list of domains via the proxy.

Usage:
`ruby process_dns.rb <log_file> <optional: filter_ip>`

The script has two parameters. The first one is the log file, e.g. example_dns.log
The filter_ip is optional and can be used to filter the dataset by all requests from the given IP, to ensure you only process requests that were made from this IP.

Example output:

> Only processing requests from 192.168.1.54
> Results:
> Total Query Requests: 98
> Total Unique Hosts: 39
> 
> Detected hosts:
>  - gateway.icloud.com: 6 times
>  - apptoogoodtogo.com: 4 times
>  - api2.amplitude.com: 4 times
>  - sdk.fra-01.braze.eu: 4 times
>  - region1.app-measurement.com: 4 times
>  - firebaseremoteconfig.googleapis.com: 4 times
>  - skadsdkless.appsflyer.com: 4 times
>  - token.safebrowsing.apple: 4 times
>  - gsp64-ssl.ls.apple.com: 4 times
>  - app-measurement.com: 3 times
>  - attr.appsflyer.com: 2 times
>  - safebrowsing.googleapis.com: 2 times
>  - configuration.ls.apple.com: 2 times
>  - gsp-ssl.ls.apple.com: 2 times
>  - gspe35-ssl.ls.apple.com: 2 times
>  - gspe19-ssl.ls.apple.com: 2 times
>  - images.tgtg.ninja: 2 times
>  - toogoodtogo.be: 2 times
>  - www.googletagmanager.com: 2 times
>  - sentry.io: 2 times
>  - policy.app.cookieinformation.com: 2 times
>  - fonts.gstatic.com: 2 times
>  - mkt-cms.toogoodtogo.com: 2 times
>  - consent.app.cookieinformation.com: 2 times
>  - c.apple.news: 2 times
>  - gspe79-ssl.ls.apple.com: 2 times
>  - firebaselogging-pa.googleapis.com: 2 times
>  - launches.appsflyer.com: 2 times
>  - bag.itunes.apple.com: 2 times
>  - firebase-settings.crashlytics.com: 2 times
>  - firebaseinstallations.googleapis.com: 2 times
>  - firebasedynamiclinks.googleapis.com: 2 times
>  - cdn-settings.appsflyersdk.com: 2 times
>  - skadsdk.appsflyer.com: 2 times
>  - ca.iadsdk.apple.com: 2 times
>  - conversions.appsflyer.com: 2 times
>  - gcdsdk.appsflyer.com: 2 times
>  - dynamic-config-api.appsflyer.com: 2 times
>  - pancake.apple.com: 1 times

### Listing trackers

By analysing all requests, the called domains can be listed and filtered on known domains of tracker services.
The "process_detect_trackers.rb" script helps with this.

The process_detect_trackers.rb script was developed to process the proxy log file and list all detected trackers

Usage:
`ruby process_detect_trackers.rb <log_file> <optional: filter_ip>`

The script has two parameters. The first one is the log file, e.g. example_proxy.log
The filter_ip is optional and can be used to filter the dataset by all requests from the given IP, to ensure you only process requests that were made from this IP.

Example output:

> Only processing requests from 192.168.1.54
> Detected Trackers:
> - Ads: Vungle: 4 times
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

