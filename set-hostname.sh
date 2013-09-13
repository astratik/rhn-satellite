#!/bin/bash

###########################################################################################
# Description: Ask to confirm RHEL instalation and setting Hostname during RHEL instalation
# How to use: Insert this code on %pre section of kickstart file
# Version: 1.0
# Author: Alexandre Stratikopoulos <ale.stratik@gmail.com>
# Last Modified: September 12, 2013
# Licensed under the GPLv2
############################################################################################

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
