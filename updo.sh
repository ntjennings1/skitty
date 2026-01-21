#!/bin/bash

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

function updo(){
  logo
  sudo apt-get clean
  sudo apt-get autoremove -y
  sudo apt-get update -y
  sudo apt-get upgrade -y
}

# Updates the machine
#
# @return null
function main(){
  if [ -n "$1" ]; then
    help "main"
  else
    updo || throw_exec "updo"
  fi
}

# Runs the update function
main "$1"
