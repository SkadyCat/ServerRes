local skynet = require "skynet"
require "skynet.manager"

local command = {}
function command.DelayReq(msg)
    return "DelayRet",msg
end
skynet.start(function()
    skynet.dispatch("lua", function(session, source, cmd, ...)
        local f = command[cmd]
        local head,msg = f(...)
        if head ~= nil then
            skynet.retpack(head,msg)
        end
    end)
    skynet.register("testService")
end)