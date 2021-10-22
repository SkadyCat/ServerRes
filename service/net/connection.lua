local skynet = require "skynet"
local socket = require "skynet.socket"

require "skynet.manager"
local harbor = require "skynet.harbor"

local serviceMap = require "serviceMap"

local handleMap = {}

local function echo(id)
    local bf = require "buffer"
    local buffer = bf()
    handleMap[id] = {statu = true}
	socket.start(id)
	while handleMap[id].statu do
		local str = socket.read(id)
        if true then
            if str then
                buffer.read(str)
                print("b------------------1")
                while true do
                    print("b------------------2")
                    local head,msg = buffer.decode()
                    if not head then
                        break
                    end
                    local tb = serviceMap[head]
                    local serviceName = tb.name
                    
                    local serviceAddress =  harbor.queryname(serviceName)
                    if msg == "#" then
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
                        print("b------------------3")
                        local retBuf = buffer.encode(retHead,retMsg)
                        print("b------------------4")
                        socket.lwrite(id,retBuf)
                    end
                end
            else
                socket.close(id)
                handleMap[id].statu = false
            end
        end
		
	end
    print("end echo ->"..id)
end

local command = {}

function command.close(uid)
    socket.close(uid)
end

skynet.start(function()
    local id = socket.listen("0.0.0.0", 9201)
    print("Listen socket :", "0.0.0.0", 9201)
    socket.start(id , function(id, addr)
        print("connect from " .. addr .. " " .. id)
        skynet.fork(echo, id)
    end)

    skynet.dispatch("lua", function(session, source, cmd, ...)
        local f = command[cmd]
        local head = f(...)
        if head ~= nil then
            skynet.retpack(head,msg)
        end
    end)
    skynet.register("connection")
end)