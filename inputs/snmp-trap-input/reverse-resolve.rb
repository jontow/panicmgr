#
# 2007-12-03 -- andrew@hijacked.us
#
# Module add-in to reverse-resolve a numerical OID to a reasonably
# descriptive string instead.
#

module SNMP
	class MIB
		def backwards(oid)
			oid = oid.to_s
			hash = @by_name.invert
			buf = []
			until foo = hash[oid]
				break unless oid.include?('.')
				buf.unshift(oid[oid.rindex('.')+1..-1])
				oid = oid[0...oid.rindex('.')]
			end
 
			if foo.nil?
				return "#{oid}#{buf.empty? ? '' :'.'+buf.join('.')}"
			else
				mod = @by_module_by_name.detect{|k,v| v.values.include?(oid)}[0]
				return "#{mod}::#{foo}#{buf.empty? ? '' : '.'+buf.join('.')}"
			end
		end
	end
end
