#!/bin/bash

#Остановка скрипта передачей сигнала SIGINT
#pkill -2 -f bash_bot.sh

#Поправь логирование
#Переработай сбор метрик
#Добавь service systemd
#добавь метод остановки

#vars
TOKEN="6856700358:AAECiPV0PQmmDxmUSEBAQVsWt3Dxjj4yoms"
CHAT_ID="566855756"
message="Hello world -_-"
send_message_log="send_message.log"
offset_file="offset.txt"

log() {
  echo "$(date): Sending message: $1" >> $send_message_log
}


send_message() {
  curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$CHAT_ID&text=$1" >> curl.log  2>&1
}

get_message() {
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
    commands "$text"
    echo "$text"
  }
  ##save offset
  echo "$updates" | jq ".result[-1].update_id"  > $offset_file
  fi
}

send_command_output() {
  local command_output="$($1)"
  send_message "$command_output"
  log "$command_output"
}

commands() {
  local command="$1"
  case "$command" in
    "/start")
      send_message "Available commands:
1. /start
2. /memory
3. /df
4. /cpu"
      ;;

    "/memory")
      send_command_output "free -m"
      ;;

    "/df")
      send_command_output "df -h"
      ;;

    "/cpu")
      #send_command_output "top -bn1 | awk '/Cpu/ { print $2}'"
      ;;

    *)
      send_message "No matching option found for: $command"
      log "No matching option found for: $command"
      ;;
  esac
}

stop_script() {
  log "Stopping script..."
  echo "Stopping script..."
  exit 0
}

trap 'stop_script' SIGINT

#######LOOP#############
while true; do
  get_message
  sleep 5

done


