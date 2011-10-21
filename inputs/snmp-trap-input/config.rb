#
# 2011-10-19 -- jontow@zenbsd.net
#

class SNMPTrapInputConfig
	attr_accessor :corehost, :coreport, :portcomm, :loadmibs
	def initialize
		@corehost = "127.0.0.1"
		@coreport = 4411
		@portcomm = [
			{'port' => '10162', 'community' => 'vrfw/default@slicint'},
			{'port' => '11162', 'community' => 'public'}
		]

		@loadmibs = [
			"IF-MIB",
			"IP-MIB",
			"SNMPv2-MIB",
			"DS1-MIB",
			"BGP4-MIB",
			"OSPF-MIB",
			"OSPF-TRAP-MIB"
		]
	end
end
