#!/bin/bash

STATUS=1

function throw_exec(){
  if [ "$1" == "con" ]; then
    STATUS=0
    echo "[!] Error connecting to the Internet."
  fi
}

function inetcheck(){
  ping google.com -c 1 &> /dev/null || throw_exec "con"
  if [ $STATUS -eq 1  ]; then
    echo 'Connected.'
  fi
}

inetcheck
