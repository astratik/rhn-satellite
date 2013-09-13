#!/usr/bin/env python

##########################################################
# Description: Reporting script for satellite server
# File: spacewalk-reportservers.py
# Version: 1.0
# Author: Alexandre Stratikopoulos <ale.stratik@gmail.com>
# Last Modified: September 11, 2013
# Licensed under the GPLv2
##########################################################

import xmlrpclib
import socket
import sys
import datetime
import time
from optparse import OptionParser

parser = OptionParser()
parser.add_option("-u", "--user", dest="user", help="Login user for satellite", metavar="USER")
parser.add_option("-p", "--password", dest="password", help="Password for specified user on satellite", metavar="PASSWORD")
parser.add_option("-s", "--server", dest="rhnserver", help="FQDN of satellite server - omit https://", metavar="RHNSERVER")
(options, args) = parser.parse_args()

if not ( options.user and options.password and options.rhnserver ):
    print "Must specify user, password and server options.  See usage:"
    parser.print_help()
    print "\nExample usage: ./spacewalk-reportservers.py -u user -p password -s server.example.com"
    sys.exit(1)
else:
    user = options.user
    password = options.password
    rhnserver = options.rhnserver

try:
    server = xmlrpclib.Server("https://%s/rpc/api" % rhnserver)
    session = server.auth.login(user, password)

    now = datetime.datetime.now()
    print
    print "Report generated at:"
    print now.strftime("%Y-%m-%d %H:%M")
    print
    print "--------------------------------------------------------\n"
    active_systems = server.system.listUserSystems(session)
    print "%i systems are registered with Satellite Server\n" % len(active_systems)
    print "--------------------------------------------------------\n"

    for system in active_systems:
        print "\tHostname: %s" % system['name']


        cpu_type = server.system.getCpu(session, system['id'])
        print "\tCPU configuration is: %s" % cpu_type['model']

        memory_type = server.system.getMemory(session, system['id'])
        print "\tMemory configuration is: %iMB" % (memory_type['ram'])

        net_device = server.system.getNetworkDevices(session, system['id'])
        for device in net_device:
                if device.get('interface') == "eth0":
                        print '\tInterface:   ' + device.get('interface')
                        print '\tMAC Address: ' + device.get('hardware_address').upper()

        net_device = server.system.getNetworkDevices(session, system['id'])
        for device in net_device:
                if device.get('interface') == "eth1":
                        print '\tInterface:   ' + device.get('interface')
                        print '\tMAC Address: ' + device.get('hardware_address').upper()

        registered = server.system.getRegistrationDate(session, system['id'])
        print "\tRegistration date: %s" % registered

        activationkey = server.system.listActivationKeys(session, system['id'])
        print "\tActivation Key: %s" % activationkey

        print
    print "-----------------------\n"

    server.auth.logout(session)

except xmlrpclib.Fault,e:
    print "Could not connect to Satellite server.  Got exception:", e
    sys.exit(1)
except socket.error,e:
    print "Got Socket error:", e
    sys.exit(1)
except KeyboardInterrupt:
    print "Got Ctrl-C.  Exiting"
except Exception, e:
    print "Got general exception", e
    sys.exit(1)

sys.exit(0)
