#!/bin/bash

#vars
TOKEN="6856700358:AAECiPV0PQmmDxmUSEBAQVsWt3Dxjj4yoms"
CHAT_ID="566855756"
message="Hello world -_-"
send_message_log="send_message.log"
offset_file="offset.txt"

log() {
  echo "$(date): Sending message: $1" >> $send_message_log
}


#SEND message
##logs
log "$message"
##send
curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$CHAT_ID&text=$message" >> curl.log  2>&1


#GET message
##get offset old message
offset=$(cat "$offset_file")

##get message
updates=$(curl -s "https://api.telegram.org/bot$TOKEN/getUpdates?offset=$offset")

##save respone
echo "$updates" > response.log

##count message in updates
message_count=$( echo "$updates" | jq '.result | length' )

##parsing message in cicle
if [ $message_count -gt 0 ]
then
for (( i=1; i < message_count; i++ )){
  text=$(echo "$updates" | jq ".result[$i].message.text" | tr -d \")
  echo "$text"
}
##save offset
echo "$updates" | jq ".result[-1].update_id"  > $offset_file
fi



