#!/usr/bin/env bash

INTERFACE=$(ip -o address list|grep -m1 "inet $1/"|awk '{print $2}')
if [ "$?" -eq "0" ];then
  ip address add dev ${INTERFACE} $2
fi
