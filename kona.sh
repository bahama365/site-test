#!/bin/bash
#
# v1:010518
#
########################################################################################################################
#
# A script to parse over a list of hostnames/URL's and find out their status, initially into the following categories:
#
# LOW:	No DNS resolution for hostname
# MED:	DNS resolution but no page/content
# HIGH:	Content, i.e: a site with stuff on it
#
#########################################################################################################################
#
# First, check if the hostname resolves to anything
clear
echo > summary.txt
#echo > detailed.txt
sitesCompleted=0
lines=$(cat sites.txt | wc -l)
#
echo "There are: $lines sites to test..."
sleep 2
echo
for hostname in $(cat sites.txt)
do
	ipAddress=$(dnsget -qq $hostname)
		if [ $? -gt 0 ]
		then
			echo "Hostname: $hostname DNS?: no Category: LOW" >> summary.txt
			sitesCompleted=$[$sitesCompleted + 1]
			echo "Sites Completed: $sitesCompleted"
		else
			ipAddress=$(dnsget -qq $hostname | awk 'NR==1{print $1}')
			errorCode=$(curl -kIL -m 2 -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 \
                                (KHTML, like Gecko) Chrome/44.403.89 Safari/537.36" \
				--write-out %{http_code} --silent --output /dev/null $hostname)
				if [ $errorCode == 200 ]
				then
					echo "Hostname: $hostname DNS?: $ipAddress Category: HIGH Error_Code: $errorCode" >> summary.txt
				else
					errorCode=$(curl -kIL -m 2 -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) \
						AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.403.89 Safari/537.36" \
						--write-out %{http_code} --silent --output /dev/null https://$hostname)
					if [ $errorCode == 200 ]
					then
						echo "Hostname: $hostname DNS?: $ipAddress Category: HIGH Error_Code: $errorCode" >> summary.txt
					else
						echo "Hostname: $hostname DNS?: $ipAddress Category: MED Error_Code: $errorCode" >> summary.txt
					fi
				fi
			sitesCompleted=$[$sitesCompleted + 1]
                        echo "Sites Completed: $sitesCompleted"
		fi
done
clear
echo "Summary output: summary.txt"
echo "See below for top 20 lines..."
echo
cat summary.txt | column -t | sort -k 6 | head -n 20
echo
#cat detailed.txt | head -n 20
echo
