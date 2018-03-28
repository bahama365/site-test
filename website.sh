#!/bin/bash

# Script to check over the list of sites and let you know which ones
# are up, on what port and if they have a redirect
clear
siteCount=0
httpCount=0
httpsCount=0
status=$?
for i in $(cat sites.txt)
do
  siteCount=$[$siteCount + 1]
  echo
  echo
  echo "-------------------------------------"
  echo "This is site: $i"
  echo
  echo The site reolves to:
  domain=$(echo $i | cut -d / -f 1)
  dig +noall +answer $domain
  echo
  echo "The following ports are open:"
  nmap -sS $domain -p 80 |sed -ne '6,7p'
  nmap -sS $domain -p 443 |sed -ne '6,7p'
  echo
  echo "Now running Curl on the URL: "$i" over HTTP and following redirects"
  echo
  curl -kIL -m 2 http://$i 2> /dev/null
  if [ $? -gt 0 ]
  then
    echo "Site is not listing to Curl"
    echo "Site: $i is NOT listening on HTTP" >> site_results.txt
    httpCount=$[$httpCount + 1]
  else
    echo "Site: $i is listening on HTTP" >> site_results.txt
  fi
  echo
  echo "Now also running Curl over HTTPS following redirects"
  echo
  curl -kIL -m 2 https://$i 2> /dev/null
  if [ $? -gt 0 ]
  then
    echo "No response on Curl HTTPS"
    echo "Site: $i is NOT listening on HTTPS" >> site_results.txt
    httpsCount=$[$httpsCount + 1]
  else
    echo "Site: $i is listening on HTTPS" >> site_results.txt
  fi
  echo
  echo
  echo
  sleep 1
  echo "-------------------------------------"
  echo
done

echo "I tested $siteCount x sites"
echo "There are $httpCount sites listening on HTTP"
echo "There are $httpsCount sites listening on HTTPS"
