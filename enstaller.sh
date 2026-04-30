#!/bin/bash

DIR=$(dirname "$0")
LFILE="$DIR/logs/enstaller"

function throw_exec(){
  if [ '$1' = 'en' ]; then
    echo '[ERR] Error installing essentials.'
  fi
}

function logo(){
cat<<'EOF'
 _____   <>
|  ___|  __
|  _|   |  |
|____ | |__|

EOF
}

function logger(){
  if [ ! -f $LFILE ]; then
    touch '$LFILE'
  else
    rm $LFILE
    touch $LFILE
  fi
}

function enstaller(){
  efile='packages.txt'
  logger
  for e in $(cat $efile); do
    echo '' >> $LFILE
    echo "[-->] Installing $e." >> $LFILE
    sudo apt-get install $e -y >> $LFILE || sudo apt install $e -y >> $LFILE
  done
}

function main(){
  clear
  logo
  echo '[-->] Installing essentials.'
  sleep 2
  enstaller || throw_exec 'en'
}

main
