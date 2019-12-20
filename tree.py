from mininet.topo import Topo
from mininet.net import Mininet
from mininet.link import TCLink


class Tree( Topo ):
	
	def build(self):
		"creating custom topo"

		"initialze topo"
		#Topo.__init__( self )

		#Add hosts and switches
		Host1 = self.addHost( 'host1' )
		Host2 = self.addHost( 'host2' )
		Host3 = self.addHost( 'host3' )
		Switch1 = self.addSwitch( 'switch1' )
		Switch2 = self.addSwitch( 'switch2' )
		Switch3 = self.addSwitch( 'switch3' )

		#Add link
		self.addLink( Host1, Switch2, bw=10, delay='5ms', use_htb=True )
		self.addLink( Host2, Switch2, bw=10, delay='5ms', use_htb=True )
		self.addLink( Host3, Switch3, bw=10, delay='5ms', use_htb=True )
		self.addLink( Switch1, Switch2 )
		self.addLink( Switch1, Switch2, bw=100, delay='5ms', use_htb=True )
		self.addLink( Switch1, Switch3, bw=100, delay='5ms', use_htb=True )


topos= { 'tree': ( lambda: Tree() ) }		
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

		
