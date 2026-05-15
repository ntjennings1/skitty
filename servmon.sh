#!/bin/bash

DIR=$(dirname "$0")
LFILE="$DIR/logs/servmon"

function throw_exec(){
  if [ "$1" = "service" ]; then
    echo "[ERR] Missing service."
    help "serv"
  elif [ "$1" = "hz" ]; then
    echo "[ERR] Missing frequency."
    help "hz"
  elif [ "$1" = "serv" ]; then
    echo "[ERR] Error monitoring service."
  fi
}

function logo(){
cat <<'EOF'
[-------------------------------------------------]
] [         ]                                     [
[ [     ____] [-------][---] [---] [-----\/-----] ]
] _\__     \  [  _____] \  \ /  /  [   \    /   ] [
[ [         ] [   ]      \  ^  /   [   ]\  /[   ] ]
] [_________] [___]       \___/    [___] ^^ [___] [
[-------------------------------------------------]
EOF

}

function help(){
  if [ "$1" = "serv" ]; then
    clear
    logo
    echo
    echo "|-------------------------------------------------|"
    echo "| You need to indicate the service you want to    |"
    echo "| start monitoring.                               |"
    echo "|                                                 |"
    echo "| ex. ssh, ufw, wpa_supplicant                    |"
    echo "|                                                 |"
    echo "|-------------------------------------------------|"
  elif [ "$1" = "hz" ]; then
    clear
    logo
    echo
    echo "|-------------------------------------------------|"
    echo "| You need to indicate how often you want to log  |"
    echo "| service attributes.                             |"
    echo "|                                                 |"
    echo "| Indicate a frequency (seconds.)                 |"
    echo "|                                                 |"
    echo "|-------------------------------------------------|"
  fi
}

function describe(){
  logged_last=$(cat "$2" | grep "" -n | tail -n 1)
  logged=$(echo "$logged_last" | cut -d':' -f1)

  echo "[-->] Service: $1"
  echo "[-->] Log file: $2"
  echo "[-->] Status: $3"
  echo "[-->] Frequency: $4s"
  echo "[-->] Times logged: $logged"
  echo "[-->] Last Log Time: $(date)"
}

function servmon(){
  SERVICE="$1"

  while true; do
    clear
    logo
    STATUS=$(sudo systemctl is-active "$SERVICE")
    TIME=$(date +"%Y-%m-%d %H:%M:%S")

    if [ "$STATUS" == "active" ]; then
      describe $SERVICE $LFILE "Active" $2
      echo "$TIME - ALERT: $SERVICE is $STATUS" >> "$LFILE"
    else
      describe $SERVICE $LFILE "Inactive" $2
      echo "$TIME - ALERT: $SERVICE is $STATUS" >> "$LFILE"
    fi
    sleep "$2"
  done

}

function main(){
  if [ -n "$1" ]; then
    if [ -n "$2" ]; then
      servmon $1 $2 || throw_exec "serv"
    else
      throw_exec "hz"
    fi
  else
    throw_exec "service"
  fi
  exit
}


main $1 $2
