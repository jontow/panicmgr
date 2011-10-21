#!/usr/bin/env ruby
#
# 2011-10-19 -- jontow@zenbsd.net
#

Dir[File.dirname(__FILE__) + '/*-mib-handler.rb'].each do |handlerdep|
	puts "Requiring #{handlerdep}"
	require handlerdep
end

class SNMPTrapHandler
	attr_reader :state, :alarm

	def initialize(event)
		@state = nil
		@alarm = nil

		puts "TRAP -- #{event['name']}:"
		puts event['info']

		case event['name']
		when "IF-MIB::linkDown"
			@state = :set
			@alarm = IFMIB.linkdown(event['info'])
			p @alarm
		when "IF-MIB::linkUp"
			@state = :clear
			@alarm = IFMIB.linkup(event['info'])
			p @alarm
		else
			puts "Unhandled IF-MIB trap: #{event['name']}"
		end
	end
end
