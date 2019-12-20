#!/usr/bin/python

from mininet.topo import Topo
from mininet.net import Mininet
from mininet.link import TCLink

TARGET_BW = 500
INITIAL_BW = 200

class MyTopo( Topo ):
	
	def __init__(self):
		"creating custom topo with 3 hosts"

		"initialze topo"
		Topo.__init__( self )

		#Add hosts and switches
		Host1 = self.addHost( 'host1' )
		Host2 = self.addHost( 'host2' )
		Host3 = self.addHost( 'host3' )
		Switch1 = self.addSwitch( 'switch1' )
		Switch2 = self.addSwitch( 'switch2' )
		Switch3 = self.addSwitch( 'switch3' )

		#Add links and perf
		self.addLink( Host1, Switch2, bw = 10 , delay='5ms' )
		self.addLink( Host2, Switch2, bw = 10 , delay='5ms' )
		self.addLink( Host3, Switch3, bw = 10 , delay='5ms' )
		self.addLink( Switch1, Switch2, bw = 100 , delay='5ms' )
		self.addLink( Switch1, Switch3, bw = 100 , delay='5ms' )

		
topos= { 'mytopo': ( lambda: MyTopo() ) }		
