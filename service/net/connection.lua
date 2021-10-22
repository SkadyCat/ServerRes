local skynet = require "skynet"
local socket = require "skynet.socket"
local bf = require "buffer"

local harbor = require "skynet.harbor"
local buffer = bf()
local serviceMap = require "serviceMap"

local function echo(id)
	socket.start(id)
	while true do
		local str = socket.read(id)
		if str then
            buffer.read(str)
            while true do
                local head,msg = buffer.decode()
                if not head then
                    break
                end
                print(head)
                local tb = serviceMap[head]
                local serviceName = tb.name
                local serviceAddress =  harbor.queryname(serviceName)
                if msg == nil then
                    msg = {}
                    msg.uid = id
                else
                    msg.uid = id
                end
                if tb.ret == 0 then
                    skynet.send(serviceAddress,"lua",head,msg)
                else 
                    local retHead,retMsg = skynet.call(serviceAddress,"lua",head,msg)
                    if retMsg.uid ~= nil then
                        retMsg.uid = nil
                    end
                    local retBuf = buffer.encode(retHead,retMsg)
                    socket.write(id,retBuf)
                end
            end
		else
			socket.close(id)
            print("close ->"..id)
			return
		end
	end
end
skynet.start(function()
    local id = socket.listen("0.0.0.0", 9201)
    print("Listen socket :", "0.0.0.0", 9201)
    socket.start(id , function(id, addr)
        print("connect from " .. addr .. " " .. id)
        skynet.fork(echo, id)
    end)
end)