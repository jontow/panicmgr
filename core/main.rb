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

require 'core/config'
require 'handlers/snmp-trap-handler/snmp-trap-handler'

Thread.abort_on_exception = true

class CoreListener
	def initialize
		@sockets = []
		@eventqueue = Queue.new
		@cfg = CoreConfig.new

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
		begin
			event = JSON.parse(rawevent)
			route_event(event)
		rescue => e
			puts "Malformed event!  JSON parse error: #{e.message}"
			p rawevent
		end
	end

	def route_event(event)
		case event['type']
		when "snmptrap"
			SNMPTrapHandler.new(event)
		else
			puts "GOT UNHANDLED EVENT:"
			puts event
		end
				
	end
end

cl = CoreListener.new
