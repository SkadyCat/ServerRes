local skynet = require "skynet"
local socket = require "skynet.socket"
require "skynet.manager"
local userApi = require "net/user"
local harbor = require "skynet.harbor"
local socketdriver = require "skynet.socketdriver"


local userMap = {}
local command = {}
local json = require "json"
local function hash(uid)
    return "#"..uid
end

function command.broadCast(tb,name,msg)
    for k,v in pairs(tb) do
        if v then
            skynet.send(userMap[hash(k)],"lua","send",name,msg)
        end
    end
end

function command.send(uid,head,msg)
    skynet.send(userMap[hash(uid)],"lua","send",head,msg)
end

function command.close(uid)
    local serviceAddress = userMap[hash(uid)]
    skynet.send(serviceAddress,"lua","close",uid)
end

skynet.start(function()
    local id = socket.listen("0.0.0.0", 9201)
    print("Listen socket :", "0.0.0.0", 9201)
    socket.start(id , function(id, addr)
        print("connect from " .. addr .. " " .. id)
        local address = skynet.newservice("userAgent")
        socketdriver.nodelay(id)
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