# 
# COPYRIGHT LESTER COVEY,
#
# 2022

module Butler

	# Edit your config data here
	TRACK = { "Moms-iPhone" => "mom", "Dads-iPhone" => "dad" }
	ROUTER_IP = "192.168.31.1"
	ROUTER_USERNAME = "admin"
	ROUTER_PASSWORD = "admin"
	SHELL_COMMAND = "sudo report BUTLER: "
	CACHE_FILE_LOCATION = "#{__dir__}/butler_cache.bin"
	TOKEN_FILE_LOCATION = "#{__dir__}/butler_token.bin"

end