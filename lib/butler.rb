# 
# COPYRIGHT LESTER COVEY,
#
# 2022

require_relative "butler/version"
require_relative "../config"
require "miwifi"

module Butler

	class Person
		attr_accessor :device_name, :short_name, :at_home
		def initialize(device_name, short_name, at_home)
			@device_name = device_name
			@short_name = short_name
			@at_home = at_home
		end
	end

	class SecondAttemptFailedError < StandardError
		def initialize(msg="Couldn't get data in two attempts", exception_type="custom")
			@exception_type = exception_type
			super(msg)
		end
	end

	def self.update_token
		$router.auth
		$router.bury_token(TOKEN_FILE_LOCATION)
	end

	def self.report(message)
		system("#{SHELL_COMMAND} \"#{message}\"")
	end

	def self.main
		$verbose = ARGV.include?('-V')
		$router = Miwifi::Router.new(ROUTER_IP, ROUTER_PASSWORD, ROUTER_USERNAME)
		people = []
		attempt_two = false
		loop do
			if attempt_two
				update_token
			elsif File.file?(TOKEN_FILE_LOCATION) then
				$router.restore_token(TOKEN_FILE_LOCATION)
				puts "Using saved token..." if $verbose
			else 
				puts "No token found, fetching new..." if $verbose
				update_token
			end
			puts "Fetching device list..." if $verbose
			begin
				devices = $router.device_list["list"]
			rescue Miwifi::AccessDeniedError
				if attempt_two then raise SecondAttemptFailedError end
				puts "Token expired, fetching new..." if $verbose
				attempt_two = true
				next
			end
			TRACK.each do |k, v|
				person = Person.new(k, v, false)
				devices.each do |i|
					if i["name"] == k
						person.at_home = true
					end
				end
				people << person
			end
			if File.file?(CACHE_FILE_LOCATION) and not $verbose
				file = File.read(CACHE_FILE_LOCATION)
				cached = Marshal.load(file)
				updated = people.select do |i| 
					c = cached.find{ |j| j.device_name == i.device_name }
					!c.nil? && c.at_home != i.at_home
				end
			else 
				updated = people
			end
			if updated.length == 0
				if $verbose then puts "Nothing" end
				return
			end
			s = "At home:"
			div = "\n"
			updated.each do |i|
				s += "#{div}#{i.short_name} — #{i.at_home ? 'yes' : 'no'}"
			end
			if $verbose
				puts s
			else
				report s
			end
			file = File.new(CACHE_FILE_LOCATION, 'w')
			file.puts(Marshal.dump(people))
			break
		end
	end

end
