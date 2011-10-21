#!/usr/bin/env ruby
#
# 2011-10-19 -- jontow@zenbsd.net
#
# Main listener loop
#

require 'socket'
require 'thread'
require 'rubygems'
require 'json'

require File.dirname(__FILE__) + '/config'
require File.dirname(__FILE__) + '/alarm'
require File.dirname(__FILE__) + '/../handlers/snmp-trap-handler/snmp-trap-handler'

Thread.abort_on_exception = true

class CoreListener
	def initialize
		@sockets = []
		@eventqueue = Queue.new
		@cfg = CoreConfig.new
		@alarm = Alarm.new
		@active_alarms = []

		corelisten
	end

	def corelisten
		runloop

		puts "Listening on #{@cfg.listenhost}:#{@cfg.listenport}"
		socket = TCPServer.new(@cfg.listenhost, @cfg.listenport)
		loop do
			client = socket.accept
			@sockets << client
			puts "New connection from #{client.peeraddr[2]}"
		end
	end

	def runloop
		Thread.new do
			loop do
				if sessions = select(@sockets, [], [], 1)
					unless sessions[0].empty?
						sessions[0].each do |s|
							input = s.gets
							if input.nil?
								# dead session
								puts "Dead connection (#{s.peeraddr[2]})"
								@sockets.delete s
								next
							end
							parse_event(input)
						end
					end
				end
			end
		end
	end

	def parse_event(rawevent)
		# XXX
		# I don't know if this code will stay here or not.. doesn't
		# seem right to duplicate it, and the use case seems rare.
		#
		#if rawevent =~ /^set (.*)/
		#	if alarm_set($1)
		#		puts "\nSET ALARM: #{$1}\n\n"
		#	else
		#		puts "\nSET ALARM (ALREADYSET): #{$1}\n\n"
		#	end
		#elsif rawevent =~ /^clear (.*)/
		#	if alarm_clear($1)
		#		puts "\nCLEAR ALARM: #{$1}\n\n"
		#	else
		#		puts "\nCLEAR ALARM (NOTSET): #{$1}\n\n"
		#	end
		#else
			begin
				event = JSON.parse(rawevent)
				route_event(event)
			rescue => e
				puts "Malformed event!  JSON parse error: #{e.message}"
			end
		#end
	end

	def route_event(event)
		case event['type']
		when "snmptrap"
			th = SNMPTrapHandler.new(event)
			case th.state
			when :set
				set(th.alarm)
			when :clear
				clear(th.alarm)
			else
				puts "Trap state unknown: #{th.alarm}"
			end
		else
			puts "GOT UNHANDLED EVENT:"
			puts event
		end
	end

	def alarm_active?(alarm)
		@active_alarms.include?(alarm)
	end

	def set(alarm)
		if !alarm_active?(alarm)
			@active_alarms << alarm
			puts "ALARM SET (#{@active_alarms.join(", ")})"
			return true
		else
			puts "ALARM ALREADY SET (#{@active_alarms.join(", ")})"
			return false
		end
	end

	def clear(alarm)
		if alarm_active?(alarm)
			@active_alarms.delete(alarm)
			puts "ALARM CLEAR (#{@active_alarms.join(", ")})"
			return true
		else
			puts "ALARM ALREADY CLEAR (#{@active_alarms.join(", ")})"
			return false
		end
	end
end

cl = CoreListener.new
