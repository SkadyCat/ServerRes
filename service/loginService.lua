local skynet = require "skynet"
require "skynet.manager"

local harbor = require "skynet.harbor"


local command = {}

function command.LoginReq(msg)
    print(msg.name)
    local tb = {code = 3,info = "connect success",handle = msg.uid}
    return "LoginRet",tb
end

function command.LoginOutReq(msg)
    print("loginOut"..msg.uid)
    local serviceAddress =  harbor.queryname("connection")
    skynet.send(serviceAddress,"lua","close",msg.uid)
end
skynet.start(function()
    skynet.dispatch("lua", function(session, source, cmd, ...)
        local f = command[cmd]
        local head,msg = f(...)
        if head ~= nil then
            skynet.retpack(head,msg)
        end
    end)
    skynet.register("loginService")
end)