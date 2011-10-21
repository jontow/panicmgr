#
# 2011-10-21 -- jontow@zenbsd.net
#
# Parsing and handling for IF-MIB related SNMP traps
#

module IFMIB
	def self.linkdown(evinfo)
		if evinfo =~ /IF-MIB::ifName\.[0-9]+\ ::\ (.*)/
			return "linkfail: #{$1}"
		end
	end

	def self.linkup(evinfo)
		if evinfo =~ /IF-MIB::ifName\.[0-9]+\ ::\ (.*)/
			return "linkfail: #{$1}"
		end
	end
end
