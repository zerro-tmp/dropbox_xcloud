#!/opt/app/dropbox/bin/bash
APPKEY=$1
APPSECRET=$2
PROXY=$3
OAUTH_TOKEN_SECRET=$4
OAUTH_TOKEN=$5
CONFIG_FILE=/opt/app/dropbox/etc/config
CURL_BIN="/opt/app/dropbox/bin/curl --proxy $PROXY "
RESPONSE_FILE="/tmp/du_resp_$RANDOM"
API_ACCESS_TOKEN_URL="https://api.dropbox.com/1/oauth/access_token"
ACCESS_LEVEL="dropbox"

function utime
{
    echo $(date +%s)
}
function remove_temp_files
{
    
        rm -fr "$RESPONSE_FILE"
 
}
function check_http_response
{
    CODE=$?

    #Checking curl exit code
    case $CODE in

        #OK
        0)

        ;;

        #Proxy error
        5)
            print "\nError: Couldn't resolve proxy. The given proxy host could not be resolved.\n"

            remove_temp_files
            exit 1
        ;;

        #Missing CA certificates
        60|58)
            print "\nError: cURL is not able to performs peer SSL certificate verification.\n"
            remove_temp_files
            exit 1
        ;;

        6)
            print "\nError: Couldn't resolve host.\n"

            remove_temp_files
            exit 1
        ;;

        7)
            print "\nError: Couldn't connect to host.\n"

            remove_temp_files
            exit 1
        ;;

    esac

    #Checking response file for generic errors
    if grep -q "HTTP/1.1 400" "$RESPONSE_FILE"; then
        ERROR_MSG=$(sed -n -e 's/{"error": "\([^"]*\)"}/\1/p' "$RESPONSE_FILE")

        case $ERROR_MSG in
             *access?attempt?failed?because?this?app?is?not?configured?to?have*)
                echo -e "\nError: The Permission type/Access level configured doesn't match the DropBox App settings!\nPlease run \"$0 unlink\" and try again."
                exit 1
            ;;
        esac

    fi

}

        #USER AUTH  #API_ACCESS_TOKEN_URL   
        $CURL_BIN -k -s --show-error --globoff -i -o "$RESPONSE_FILE" --data "oauth_consumer_key=$APPKEY&oauth_token=$OAUTH_TOKEN&oauth_signature_method=PLAINTEXT&oauth_signature=$APPSECRET%26$OAUTH_TOKEN_SECRET&oauth_timestamp=$(utime)&oauth_nonce=$RANDOM" "$API_ACCESS_TOKEN_URL" 2> /dev/null
        check_http_response
        OAUTH_ACCESS_TOKEN_SECRET=$(sed -n 's/oauth_token_secret=\([a-z A-Z 0-9]*\)&.*/\1/p' "$RESPONSE_FILE")
        OAUTH_ACCESS_TOKEN=$(sed -n 's/.*oauth_token=\([a-z A-Z 0-9]*\)&.*/\1/p' "$RESPONSE_FILE")
        OAUTH_ACCESS_UID=$(sed -n 's/.*uid=\([0-9]*\)/\1/p' "$RESPONSE_FILE")

        if [[ $OAUTH_ACCESS_TOKEN != "" && $OAUTH_ACCESS_TOKEN_SECRET != "" && $OAUTH_ACCESS_UID != "" ]]; then
            #Saving data in new format, compatible with source command.
            echo "APPKEY=$APPKEY" > "$CONFIG_FILE"
            echo "APPSECRET=$APPSECRET" >> "$CONFIG_FILE"
            echo "ACCESS_LEVEL=$ACCESS_LEVEL" >> "$CONFIG_FILE"
            echo "OAUTH_ACCESS_TOKEN=$OAUTH_ACCESS_TOKEN" >> "$CONFIG_FILE"
            echo "OAUTH_ACCESS_TOKEN_SECRET=$OAUTH_ACCESS_TOKEN_SECRET" >> "$CONFIG_FILE"
            echo "PROXY=$PROXY" >> "$CONFIG_FILE"
            

  					echo "LocalDir=/xcloud" >> "$CONFIG_FILE"
  					echo "RemmoteDir=/xcloud" >> "$CONFIG_FILE"
  					echo "ActTime=3" >> "$CONFIG_FILE"
  					echo "Mode=0" >> "$CONFIG_FILE"
					echo "Cron=0" >> "$CONFIG_FILE"
            echo -ne "OK"
        else
            echo "FAILED"
            ERROR_STATUS=1
        fi

remove_temp_files

