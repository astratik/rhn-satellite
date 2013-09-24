#!/bin/bash
#########################################################################
# Description: Ask to confirm RHEL/Fedora instalation and allow to set
# some custom parameters such as: Hostname and IP Address.
#
# How to use: Insert this code on %pre section of kickstart file
# Version: 1.0
# Author: Alexandre Stratikopoulos <ale.stratik@gmail.com>
# Last Modified: September 24, 2013
# Licensed under the GPLv2
#########################################################################
#
# Ask for (re)instalation
exec < /dev/tty5 > /dev/tty5 2>&1
chvt 5
install="no"
while [ "$install" != "yes" ]; do
clear
echo
echo '********************************************************************************'
echo '* W A R N I N G *'
echo '* *'
echo '* This process will (re)install this system *'
echo '* *'
echo '* Do you wish to continue? (Type the entire word "yes" to proceed.) *'
echo '* *'
echo '********************************************************************************'
echo
read -p "Proceed with install? " install
done
#
#########################################################################
#
# Ask for HOSTNAME
chvt 1
exec < /dev/tty5 > /dev/tty5 2>&1
chvt 5
echo -n "Type the hostname: "
read MEUHOSTNAME
echo "**** $MEUHOSTNAME ****"
export HOSTNAME=$MEUSHOSTNAME
hostname $MEUHOSTNAME
read
chvt 1
#
# Ask for NETWORK CONFIGURATION
#
exec < /dev/tty5 > /dev/tty5 2>&1
chvt 5
confnet="no"
while [ "$confnet" != "yes" ]; do
echo -n "Probing networking "
echo -n "Detected network interfaces"
for i in $(ifconfig |grep -B3  BROADCAST |grep eth |awk '{print $1}')
do
echo ' '
echo -n $i
done
echo ' '
echo -n "Network configuration"
echo ''
echo -n "Type the IP ADDRESS: "
read IPSERV
echo -n "Type the MASK ADDRESS: "
read MASKSERV
echo -n "Type the DEFAULT GATEWAY: "
read GATSERV
echo '*************************************************************************'
echo '* PLEASE, CONFIRM THE FOLLOWING INFORMATIONS *'
echo '* *'
echo "* $IPSERV *"
echo "* $MASKSERV *"
echo "* $GATSERV *"
echo '* *'
echo '* Do you wish to continue? (Type the entire word "yes" to proceed.) *'
echo '* *'
echo '*************************************************************************'
echo ''
read -p "Continue? " confnet
done
ifconfig eth0 $IPSERV netmask $MASKSERV up
ping -I eth0 -c 3 $GATSERV
echo -e "DEVICE=\"eth0\"\nBOOTPROTO=\"static\"\nGATEWAY=\"$GATSERV\"\nHWADDR=\"$(ifconfig eth0 |grep -i HWaddr |awk '{print $5}')\"\nIPADDR=\"$IPSERV\"\nNETMASK=\"$MASKSERV\"\nONBOOT=\"yes\"" > /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i '/^NM_CONTROLLED/d' /etc/sysconfig/network-scripts/ifcfg-eth0
chvt 1
