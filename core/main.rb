#!/usr/bin/env ruby
#
# 2011-10-19 -- jontow@zenbsd.net
#
# Main listener loop
#

require 'socket'
require 'thread'
require 'config'
require 'rubygems'
require 'json'

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

	def parse_event(event)
		(header, type, name, ser_info) = event.split("|", 4)
		if header.nil? or type.nil? or name.nil? or ser_info.nil?
			puts "Malformed event: #{event}"
		else
			begin
				evinfo = JSON.parse(ser_info.chomp).to_s
			rescue => e
				puts "JSON parse error: #{e.message}"
			end

			route_event(header, type, name, evinfo)
		end
	end

	def route_event(header, type, name, evinfo)
		puts "H(#{header}) T(#{type}) N(#{name}):\n#{evinfo}"
	end
end

cl = CoreListener.new
