#!/usr/bin/env bash

INTERFACE=$(ip -o address list|grep "inet $1/"|awk '{print $2}')
if [ "$?" -eq "0" ];then
  IP=$(ip -o address list|grep "inet $1/"|awk '{print $4}')
  ip address del dev ${INTERFACE} ${IP}
fi
