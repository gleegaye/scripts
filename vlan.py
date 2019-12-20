#!/usr/bin/python

from mininet.node import Host
from mininet.topo import Topo

class VLANHost( Host ):
	"Host connected to VLAN Interface"
	
	def config( self, vlan=100, **params ):
		r = super(VLANHost, self).config( **params )
		intf = self.defaultIntf()
		#remove ip from default, "physical" interface
		self.cmd( 'ifconfig %s inet 0' %intf )
	
		#create vlan int
		self.cmd( 'vconfig add %s %d' % ( intf, vlan ))
		#assign the host ip to the vlan int
		self.cmd( 'ifconfig %s.%d inet %s' % (intf, vlan) )
		#update the intf name and host's intd map
		newName = '%s.%d' %(intf, vlan )
		# update the mininet int to refer to vlan int name
		intf.name = newName
		#Add vlan int to host's name to intf map
		self.nameToIntf[ newName ] = intf
		
		return r
host = { 'vlan': VLANHost }

		
