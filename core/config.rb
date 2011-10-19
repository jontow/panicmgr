#
# 2011-10-19 -- jontow@zenbsd.net
#

class CoreConfig
	attr_accessor :listenhost, :listenport
	def initialize
		@listenhost = 'localhost'
		@listenport = '4411'
	end
end
