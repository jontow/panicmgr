#!/usr/bin/env ruby
#
# 2011-10-19 -- jontow@zenbsd.net
#

class SNMPTrapHandler
	def initialize(event)
		puts "TRAP -- #{event['name']}:"
		puts event['info']
	end
end
