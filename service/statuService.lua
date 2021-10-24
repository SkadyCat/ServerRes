local skynet = require "skynet"
require "skynet.manager"
local harbor = require "skynet.harbor"
local playerMap = require "statu/playerMap"

local command = {}

--外部接口
function command.SetPosReq(msg)
    
end



--内部调用
function command.addPlayer(msg)
    playerMap.addPlayer(msg.uid)
end

function command.removePlayer(msg)
    playerMap.removePlayer(msg.uid)
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