local skynet = require "skynet"
local socket = require "skynet.socket"
require "skynet.manager"
local userApi = require "net/user"
local harbor = require "skynet.harbor"
local userMap = {}
local command = {}
local json = require "json"

local socketdriver = require "skynet.socketdriver"
local socket


local function hash(uid)

    return "#"..uid
end
function command.close(uid)
    skynet.send(userMap[hash(uid)],"lua","send","close",uid)
end

function command.broadCast(tb,name,msg)
    for k,v in pairs(tb) do
        if v then
            skynet.send(userMap[hash(k)],"lua","send",name,msg)
        end
    end
end

function command.LoginOutReq(msg)
    
    --通知场景，清空角色信息
    local serviceName = "sceneService"
    local serviceAddress =  harbor.queryname(serviceName)
    skynet.send(serviceAddress,"lua","leaveScene",msg)

    --关闭角色服务
    serviceAddress = userMap[hash(msg.uid)]
    skynet.send(serviceAddress,"lua","close",msg.uid)
    
end

skynet.start(function()

    socket = socketdriver.listen("0.0.0.0", 9201)
	socketdriver.start(socket)
    socketdriver.nodelay(true)
    local id = socket.listen("0.0.0.0", 9201)
    print("Listen socket :", "0.0.0.0", 9201)
    socket.start(id , function(id, addr)
        print("connect from " .. addr .. " " .. id)
        local address = skynet.newservice("userAgent")
        skynet.call(address,"lua","init",id)
        userMap[hash(id)] = address 
    end)
    skynet.dispatch("lua", function(session, source, cmd, ...)
        local f = command[cmd]
        if f ~= nil then
            local head = f(...)
            if head ~= nil then
                skynet.retpack(head,msg)
            end
        end
    end)
    skynet.register("connection")
end)