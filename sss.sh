#!/bin/bash

DIR="$(dirname "$(readlink -f "$0")")"
LFILE="$DIR/sss"

function throw_exec(){
  if [ "$1" = "sss" ]; then
    echo '[ERR] Error running secure socket service.'
  fi
}

function logo(){
cat<<'EOF'
  _____  _____  _____
 /__ ./ /__ ./ /__ ./
/____\ /____\ /____\ [ ]

EOF
}

function help(){
  if [ "$1" = "main" ]; then
    logo
    echo '========================'
    echo '=         sss          ='
    echo '=                      ='
    echo '=  This secure socket  ='
    echo '=  service requires a  ='
    echo '=  port (ex. 9500).    ='
    echo '========================'
  fi
}

function check(){
  if ss -ltn 2>/dev/null | grep -q ":$1"; then
    echo 'Used.'
  else
    echo 'Available.'
  fi
}

function sss(){

  echo $LFILE
  check $1

}

function main(){
  if [ -n "$1" ]; then
    clear
    logo
    sss $1 || throw_exec "sss"
  else
    help "main"
  fi
}

main $1
