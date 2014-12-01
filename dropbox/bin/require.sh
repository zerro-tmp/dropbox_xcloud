#!/bin/sh
APPKEY="$1"
#xmuevlmpojrs8cw
APPSECRET="$2"
#8plci2hfmadk9vd 
PROXY="$3"  
#http://10.211.209.21:8080 

CURL_BIN="/opt/app/dropbox/bin/curl --proxy $PROXY "

RANDOM=$(awk 'BEGIN{srand();print rand()*10000000}')
API_REQUEST_TOKEN_URL="https://api.dropbox.com/1/oauth/request_token"
API_USER_AUTH_URL="https://www2.dropbox.com/1/oauth/authorize"
RESPONSE_FILE="/tmp/du_resp_$RANDOM"
ACCESS_LEVEL="dropbox"
ACCESS_MSG="Full Dropbox"

    #TOKEN REQUESTS

$CURL_BIN -k -s --show-error --globoff -i -o "$RESPONSE_FILE" --data "oauth_consumer_key=$APPKEY&oauth_signature_method=PLAINTEXT&oauth_signature=$APPSECRET%26&oauth_nonce=$RANDOM" "$API_REQUEST_TOKEN_URL" 2> /dev/null
    OAUTH_TOKEN_SECRET=$(sed -n 's/oauth_token_secret=\([a-z A-Z 0-9]*\).*/\1/p' "$RESPONSE_FILE")
    OAUTH_TOKEN=$(sed -n 's/.*oauth_token=\([a-z A-Z 0-9]*\)/\1/p' "$RESPONSE_FILE")

    if [[ $OAUTH_TOKEN != "" && $OAUTH_TOKEN_SECRET != "" ]]; then
        echo -ne "${API_USER_AUTH_URL}?oauth_token=$OAUTH_TOKEN\n$OAUTH_TOKEN_SECRET\n$OAUTH_TOKEN"
         rm -fr "$RESPONSE_FILE"
    else
        echo -ne "FAILED"
        rm -fr "$RESPONSE_FILE"
        exit 1
    fi

    


