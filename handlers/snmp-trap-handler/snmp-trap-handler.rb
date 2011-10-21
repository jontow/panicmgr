#!/usr/bin/env ruby
#
# 2011-10-19 -- jontow@zenbsd.net
#

Dir[File.dirname(__FILE__) + '/*-mib-handler.rb'].each do |handlerdep|
	puts "Requiring #{handlerdep}"
	require handlerdep
end

class SNMPTrapHandler
	def initialize(event)
		puts "TRAP -- #{event['name']}:"
		puts event['info']

		case event['name']
		when "IF-MIB::linkDown"
			alarm = IFMIB.linkdown(event['info'])
			p alarm
		when "IF-MIB::linkUp"
			alarm = IFMIB.linkup(event['info'])
			p alarm
		else
			puts "Unhandled IF-MIB trap: #{event['name']}"
		end
	end
end
