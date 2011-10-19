#!/usr/bin/env ruby
#
# 2011-10-19 -- jontow@zenbsd.net
#

class SNMPTrapHandler
	def initialize(name, evinfo)
		puts "TRAP -- #{name}:"
		puts evinfo
	end
end
