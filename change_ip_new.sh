#!/bin/bash

FILE_IP="/tmp/change_ip.csv"
LOCAL_IP_CONFIG=($(/sbin/ifconfig |awk -F"\n" '$1~/^[^ ]/{print $1}'|awk '$1 !~ /lo/{print $1}'))
#或ifconfig |awk -F"\n" '$1~/^[^ ]/{print $1}'|awk 'NR<=2{print $1}'
IP_WAN_CONFIG="/etc/sysconfig/network-scripts/ifcfg-${LOCAL_IP_CONFIG[0]}"
IP_LAN_CONFIG="/etc/sysconfig/network-scripts/ifcfg-${LOCAL_IP_CONFIG[1]}"
OLD_LAN_IP=$(cat ${IP_LAN_CONFIG}|awk -F"=" '$1~/IPADDR/{print $2}')
OLD_WAN_IP=$(cat ${IP_WAN_CONFIG}|awk -F"=" '$1~/IPADDR/{print $2}')
OLD_WAN_MASK=$(awk -F"=" '$1~/NETMASK/{print $2}' ${IP_WAN_CONFIG})
OLD_WAN_GATEWAY=$(awk -F"=" '$1~/GATEWAY/{print $2}' ${IP_WAN_CONFIG})
#
echo "local ip config file is ${LOCAL_IP_CONFIG[*]}"
#
if [[ -f ${FILE_IP} ]];then
   echo "${FILE_IP} is exist."
else
   echo "${FILE_IP} is not exist."
   exit 1
fi
#
change_ip ()
{
while read line
  do
  local NEW_WAN_IP=`echo $line |awk -F"," '{print $3}'`
  local NEW_WAN_MASK=`echo $line |awk -F"," '{print $4}'`
  local NEW_WAN_GATEWAY=`echo $line |awk -F"," '{print $5}'`
  local NEW_LAN_IP=`echo $line |awk -F"," '{print $6}'`
  local FILE_WAN_IP=$(echo $line |awk -F"," '{print $1}')    
  local FILE_LAN_IP=$(echo $line |awk -F"," '{print $2}')    

    if [[ "$OLD_WAN_IP" = "$FILE_WAN_IP"  ]] && [[ "$OLD_LAN_IP" = "$FILE_LAN_IP" ]];then
      echo "local wan ip:${OLD_WAN_IP} is found..."
      echo "local lan ip:${OLD_LAN_IP} is found..."
      sed "s/${OLD_WAN_IP}/${NEW_WAN_IP}/" -i ${IP_WAN_CONFIG}
      sed "s/${OLD_WAN_MASK}/${NEW_WAN_MASK}/" -i ${IP_WAN_CONFIG}
      sed "s/${OLD_WAN_GATEWAY}/${NEW_WAN_GATEWAY}/" -i ${IP_WAN_CONFIG}
      sed "s/${OLD_LAN_IP}/${NEW_LAN_IP}/" -i ${IP_LAN_CONFIG}
      break 
#      /sbin/reboot
    else
      continue
      echo "local ip is no found."
    fi
  done < "${FILE_IP}"
}
#
if [[ -f ${IP_WAN_CONFIG} ]] && [[ -f ${IP_LAN_CONFIG} ]];then
   echo "local ip config is ${LOCAL_IP_CONFIG[*]}"
   change_ip 
else
   echo "local ip config is not ${LOCAL_IP_CONFIG}"
   exit 1
fi



