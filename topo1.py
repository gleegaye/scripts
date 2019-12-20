from mininet.topo import Topo
class MyTopo( Topo ):
	
	def __init__(self):
		"creating custom topo"

		"initialze topo"
		Topo.__init__( self )

		#Add hosts and switches
		Host1 = self.addHost( 'host1' )
		Host2 = self.addHost( 'host2' )
		Host3 = self.addHost( 'host3' )
		Switch1 = self.addSwitch( 'switch1' )
		Switch2 = self.addSwitch( 'switch2' )
		Switch3 = self.addSwitch( 'switch3' )

		#Add link
		self.addLink( Host1, Switch2 )
		self.addLink( Host2, Switch2 )
		self.addLink( Host3, Switch3 )
		self.addLink( Switch1, Switch2 )
		self.addLink( Switch1, Switch3 )


topos= { 'mytopo': ( lambda: MyTopo() ) }		
