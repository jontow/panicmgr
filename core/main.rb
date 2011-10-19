#!/usr/bin/env ruby
#
# 2011-10-19 -- jontow@zenbsd.net
#
# Main listener loop
#

require 'socket'
require 'thread'
require 'config'

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
			@sockets << socket.accept
			puts "New connection"
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
								puts "Dead connection"
								@sockets.delete s
								next
							end
							input.chomp!
							puts input
						end
					end
				end
			end
		end
	end
end

cl = CoreListener.new
