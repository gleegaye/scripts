from mininet.topo import Topo
class Tree( Topo ):
	
	def __init__(self):
		"creating custom topo"

		"initialze topo"
		Topo.__init__( self )

		#Add hosts 
		h1 = self.addHost( 'h1' )
		h2 = self.addHost( 'h2' )
		h3 = self.addHost( 'h3' )
		h4 = self.addHost( 'h4' )
		h5 = self.addHost( 'h5' )

	
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
topos= { 'tree': ( lambda: Tree() ) }		


