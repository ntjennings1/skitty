#!/bin/bash

function throw_exec(){
  if [ "$1" = "service" ]; then
    echo "[ERR] Missing service."
    help "serv"
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
    echo "| restart.                                        |"
    echo "|                                                 |"
    echo "| ex. ssh, ufw, wpa_supplicant                    |"
    echo "|                                                 |"
    echo "|-------------------------------------------------|"
  fi
}

function servover(){
  SERVICE="$1"

  clear
  logo

  #sudo systemctl disable "$1"
  sudo systemctl stop "$1"
  sleep 2
  #sudo systemctl enable "$1"
  sudo systemctl start "$1"
}

function main(){
  if [ -n "$1" ]; then
    servover $1 || throw_exec "serv"
  else
    throw_exec "service"
  fi
  exit
}


main $1
