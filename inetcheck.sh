#!/bin/bash

STATUS=1

# Throws a specified exception.
#
# Parameters:
#   $1 - An exception
# Returns:
#   None
function throw_exec(){
  if [ "$1" == "con" ]; then
    clear
    logo
    STATUS=0
    describe "No web access."
  fi
}

# Displays the scripts logo.
#
# Parameters:
#   None
# Returns:
#   None
function logo(){
cat<<'EOF'
|---------------------------|
|          ,  -  .          |
|        0 ------- 0        |
|     0               0     |
|    0 --------------- 0    |
|   (                   )   |
|    0 --------------- 0    |
|     0               0     |
|        0 ------- 0        |
|           * _ *           |
|---------------------------|
EOF
}

# Describes the script's findings.
#
# Parameters:
#   $1 - The findings.
# Returns:
#   None
function describe(){

  echo
  echo '|---------------------------|'
  echo "  $1"
  echo '|---------------------------|'

}

# Checks connection to the Internet.
#
# Parameters:
#   None
# Returns:
#   None
function inetcheck(){
  ping google.com -c 1 &> /dev/null || throw_exec "con"
  if [ $STATUS -eq 1  ]; then
    clear
    logo
    describe 'Connected to the Internet.'
  fi
}

inetcheck
