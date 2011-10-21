#!/usr/bin/env ruby
#
# 2011-10-19 -- jontow@zenbsd.net
#

require 'rubygems'
require 'snmp'
require 'json'
require File.dirname(__FILE__) + '/reverse-resolve'
require File.dirname(__FILE__) + '/config'

Thread.abort_on_exception = true
@cfg = SNMPTrapInputConfig.new

@mib = SNMP::MIB.new()

@cfg.loadmibs.each do |mibfile|
	puts "Loading #{mibfile}"
	@mib.load_module(mibfile)
end

#Dir['mib/OCCAM-*.yaml'].each do |mibfile|
#	@mib.load_module(File.basename(mibfile, '.yaml'), File.dirname(mibfile))
#end

@uplink = STDOUT
@trappers = []
@coreq = Queue.new

Thread.new do
	begin
		@corelink = TCPSocket.new(@cfg.corehost, @cfg.coreport)
	rescue Errno::ECONNREFUSED, Errno::EBADF, Errno::EINVAL
		puts "CoreListener socket not listening"
		exit
	rescue SocketError
		puts "CoreListener socket error: #{e.message}"
	end

	loop do
		if !@coreq.empty?
			event = @coreq.shift
			puts "Sending to corelink: #{event}"
			@corelink.puts event
		end
	end
end

@cfg.portcomm.each do |pc|
	p pc
	Thread.new do
		puts "Spawning listener for #{pc['community']} on #{pc['port']}"
		@trappers << SNMP::TrapListener.new(:Host => '0.0.0.0', :Port => pc['port'], :Community => pc['community']) do |manager|
			manager.on_trap_default do |trap|
				puts "(TRAPPER:#{pc['port']}) #{@mib.backwards(trap.trap_oid.to_s)} received from #{trap.source_ip}"
				trapinfo = ""
				trap.each_varbind do |vb|
					trapinfo += "#{@mib.backwards(vb.name.to_s)} :: #{vb.value.to_s}\n"
				end

				event = {
					'header' => "EVENT",
					'type' => "snmptrap",
					'name' => @mib.backwards(trap.trap_oid.to_s),
					'info' => trapinfo
				}
				@coreq << event.to_json
			end
		end
	end
end

@trappers.each do |tp|
	tp.join
end
