#!/bin/bash
#
# GET and PUT via curl for s3 buckets
#
# updated on Nov 2022 - Peter Long
#

OPENSSL=/usr/bin/openssl
CURL="/usr/bin/curl"
ACCESS_KEY="118ba69ba40785084a18" 
SECRET_KEY="eZuJdqdmccvFeKwXDkpW+eTm1oREGzOKgdtV6Cep"

function curl_get {
	endpoint=${1}
	fullpath=${2}
	bucket=$(echo $fullpath | awk -F'/' '{print $1}')
	key=$(echo $fullpath | awk -F'/' '{print $2}')
	CONTENT_TYPE="text/html; charset=UTF-8" 
	date="`date -u +'%a, %d %b %Y %H:%M:%S GMT'`"
	resource="/${bucket}/${key}"
	string="GET\n\n${CONTENT_TYPE}\n\nx-amz-date:${date}\n${resource}"
	signature=`echo -en $string | $OPENSSL sha1 -hmac "${SECRET_KEY}" -binary | base64` 
	$CURL -k -H "x-amz-date: ${date}" \
		-H "Content-Type: ${CONTENT_TYPE}" \
		-H "Authorization: AWS ${ACCESS_KEY}:${signature}" \
		"https://${endpoint}${resource}"
}

function curl_put {
	file=${1}
	endpoint=${2}
	fullpath=${3}
	bucket=$(echo $fullpath | awk -F'/' '{print $1}')
	key=$(echo $fullpath | awk -F'/' '{print $2}')
	resource="/${bucket}/${key}"
	contentType="text/plain"
	dateValue="`date -u +'%a, %d %b %Y %H:%M:%S GMT'`"
	stringToSign="PUT\n\n${contentType}\n${dateValue}\n${resource}"
	signature=`echo -en ${stringToSign} | $OPENSSL sha1 -hmac "${SECRET_KEY}" -binary | base64`
	$CURL -k -X PUT -T "${file}" \
	  -H "Host: ${bucket}.s3-cloudlab.demo.lab" \
	  -H "Date: ${dateValue}" \
	  -H "Content-Type: ${contentType}" \
	  -H "Authorization: AWS ${ACCESS_KEY}:${signature}" \
	  https://${bucket}.${endpoint}/${key}
}

# MAIN CODE

echo "curl_get endpoint bucketname/object > path/file"
curl_get s3-cloudlab.demo.lab bucket-4000/text.txt > /tmp/text.txt

echo "curl_put path/file bucketname/object"
curl_put /tmp/text2.txt s3-cloudlab.demo.lab bucket-4001/text4.txt





