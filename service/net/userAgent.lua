local skynet = require "skynet"
local socket = require "skynet.socket"

local id = ...

local function echo(id)
	socket.start(id)
	socket.write(id, "Hello Skynet\n")
	
	while true do
		local str = socket.read(id)
		if str then
			socket.write(id, str)
		else
			socket.close(id)
			return
		end
	end
end
id = tonumber(id)
skynet.start(function()
	skynet.fork(function()
		echo(id)
		skynet.exit()
	end)
end)