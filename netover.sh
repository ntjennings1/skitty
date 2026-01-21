#!/usr/bin/env bash

function throw_exec(){
  if [ "$1" = "params" ]; then
    echo "[!] Missing params."
    help "main"
  fi
}

function logo(){
cat <<'EOF'
    /|    / /         ______  //^^ ) )
   //|   / /  ___    __  ___ //   / /      __   ___      __
  // |  / / //___) )  / /   //   / /   || / / //___) ) //  ) )
 //  | / / //        / /   //   / /    ||/ / //       //
//   |/ / ((____    / /   ((___/ /     |  / ((____   //
EOF
}

function help(){
  if [ "$1" = "main" ]; then
    logo
    echo
    echo "Welcome to the NetOver network interface control tool."
    echo "Enter the following parameters in order:"
    echo
    echo "[1] Network Interface Name"
  fi
}

function netover(){
  if [ -n "$1" ]; then
    logo
    sudo ifconfig "$1" down
    echo "[-->] Interface down."
    sleep 1
    sudo ifconfig "$1" up
    echo "[-->] Interface up."
 else
    throw_exec "params"
  fi

}

# Restarts a wireless interface
#
# @param $1 : The name of the wireless interface
function main(){

  clear
  netover $1

}

# Runs the wlanover function
main $1
