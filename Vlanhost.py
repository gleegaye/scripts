#!/usr/bin/python

from mininet.topo import Topo
from mininet.net import Mininet
from mininet.node import Controller, RemoteController, OVSController
from mininet.node import CPULimitedHost, Host, Node
from mininet.node import OVSKernelSwitch, UserSwitch
from mininet.node import IVSSwitch 
from mininet.cli import CLI 
from mininet.log import setLogLevel, info
from mininet.link import Link, TCLink, Intf
from subprocess import call



def sample( ):
	
	"creating custom topo"
	"initialze topo"

	#Add hosts 
	h1 = net.addHost( 'h1' )
	h2 = net.addHost( 'h2' )
	h3 = net.addHost( 'h3' )
	h4 = net.addHost( 'h4' )
	h5 = net.addHost( 'h5' )

	
	#Add switches 
	s1 = self.addSwitch( 's1' )
	s2 = self.addSwitch( 's2' )
	s3 = self.addSwitch( 's3' )
	s4 = self.addSwitch( 's4' )
	s5 = self.addSwitch( 's5' )
	s6 = self.addSwitch( 's6' )
	s7 = self.addSwitch( 's7' )
	s8 = self.addSwitch( 's8' )
	s9 = self.addSwitch( 's9' )
	s10 = self.addSwitch( 's10' )

	#Add link for s1
	self.addLink( s1, s3 )
	self.addLink( s1, s4 )
	self.addLink( s1, s5 )
	self.addLink( s1, s6 )

	#Add link for s2
	self.addLink( s2, s3 )
	self.addLink( s2, s4 )
	self.addLink( s2, s5 )
	self.addLink( s2, s6 )
	
	#Add link for s3
	self.addLink( s3, s7 )
	self.addLink( s3, s8 )

	#Add link for s4
	self.addLink( s4, s7 )
	self.addLink( s4, s8 )

	#Add link for s5
	self.addLink( s5, s9 )
	self.addLink( s5, s10 )

	#Add link for s6
	self.addLink( s6, s9 )
	self.addLink( s6, s10 )

	#Add link for s7
	self.addLink( h1, s7 )
	self.addLink( h2, s7 )

	#Add link for s8
	self.addLink( h3, s8 )

	#Add link for s9
	self.addLink( h4, s9 )

	#Add link for s10
	self.addLink( h5, s10 )

	#remove default interface
	h1.cmd("ifconfig h1-etho 0")
	h2.cmd("ifconfig h2-etho 0")
	h3.cmd("ifconfig h3-etho 0")
	h4.cmd("ifconfig h4-etho 0")
	h5.cmd("ifconfig h4-etho 0")
	s7.cmd("ifconfig s7-eth1 0")
	s7.cmd("ifconfig s7-eth2 0")
	s6.cmd("ifconfig s6-eth1 0")
	s6.cmd("ifconfig s6-eth2 0")
	
	#Add virtual interface
	s7.cmd("ifconfig s7-eth2 10")
	s6.cmd("ifconfig s6-eth2 20")

	# set interfcae up
	s7.cmd("ifconfig s7-eth2.10 up")
	s7.cmd("ifconfig s7-eth2.20 up")

	# set vlan 10 and 20
	s7.cmd("brctl addbr vlan10")
	s7.cmd("brctl addbr vlan20")
	s6.cmd("brctl addbr vlan10")
	s6.cmd("brctl addbr vlan20")

	#Assign vlan to switch facing to host
	s7.cmd("brctl addbr vlan10  s7-eth0")
	s7.cmd("brctl addbr vlan20 s7-eth1")
	s6.cmd("brctl addbr vlan10 s6-eth0")
	s6.cmd("brctl addbr vlan20 s6-eth1")
	
	# set vlan up	
	s7.cmd("ifconfig vlan10 up")
	s7.cmd("ifconfig vlan20 up")

	s6.cmd("ifconfig vlan10 up")
	s6.cmd("ifconfig vlan20 up")

	CLI(net)
	net.stop()
#topos= { 'tree': ( lambda: Tree() ) }		


