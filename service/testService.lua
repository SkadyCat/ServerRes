local skynet = require "skynet"
require "skynet.manager"

local command = {}
local times = 0
function command.DelayReq(msg)
    print("receive time = "..skynet.time()..","..msg.time_stamp.."..."..times)
    times = times+1
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