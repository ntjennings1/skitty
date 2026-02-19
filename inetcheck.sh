#!/bin/bash

STATUS=1

function throw_exec(){
  if [ "$1" == "con" ]; then
    clear
    logo
    STATUS=0
    describe "No web access."
  fi
}

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

function describe(){

  echo
  echo '|---------------------------|'
  echo "  $1"
  echo '|---------------------------|'

}

function inetcheck(){
  ping google.com -c 1 &> /dev/null || throw_exec "con"
  if [ $STATUS -eq 1  ]; then
    clear
    logo
    describe 'Connected to the Internet.'
  fi
}

inetcheck
