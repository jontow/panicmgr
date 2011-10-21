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
	end
end
