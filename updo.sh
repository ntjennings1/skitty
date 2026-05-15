#!/bin/bash

DIR=$(dirname "$0")
LFILE="$DIR/logs/updo"

function throw_exec(){
  if [ "$1" = "updo" ]; then
    echo "[ERR] Error performing updo."
  fi
}

function logo(){
cat<<'EOF'
 __   __             _
|  | |  |           | |
|  | |  |           | | _____
|  | |  | -----  ---| ||     |
|  \_/  ||  x  ||  x  ||  X  |
 \_____/ | |___||_____||_____|
         | |
         |_|
EOF
}

function help(){
  if [ "$1" = "main" ]; then
    logo
    echo
    echo "Welcome to the Updo system package updater (sudo required)."
    echo "Any parameters will open this help menu."
    echo "Otherwise, your system's package management system will be"
    echo "cleaned, and your packages updated and upgraded."
  fi
}

function check(){
  if [ ! -d "$DIR/logs" ]; then
    mkdir "$DIR/logs"
  fi

  if [ ! -f "$LFILE" ]; then
    touch '$LFILE'
  else
    rm $LFILE
    touch $LFILE
  fi
}

function updo(){
  logo
  check
  sudo apt-get clean >> $LFILE
  sudo apt-get autoremove -y >> $LFILE
  sudo apt-get update -y >> $LFILE
  sudo apt-get upgrade -y >> $LFILE

  sudo apt autoclean >> $LFILE
  sudo apt autoremove >> $LFILE
  sudo apt update -y >> $LFILE
  sudo apt full-upgrade -y >> $LFILE
}

# Updates the machine
#
# @return null
function main(){
  if [ -n "$1" ]; then
    help "main"
  else
    clear
    updo || throw_exec "updo"
  fi
}

# Runs the update function
main "$1"
