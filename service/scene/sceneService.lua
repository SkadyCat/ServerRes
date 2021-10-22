local skynet = require "skynet"
require "skynet.manager"
local sceneMap = require "scene/sceneMap"



local command = {}

function command.EnterSceneReq(msg)
    sceneMap.move(msg.uid,msg.dst)
end

function command.BroadCast(msg)
    
end

skynet.start(function()
    skynet.dispatch("lua", function(session, source, cmd, ...)
        -- 在这里进行转接
        local prefix = ""
        if #cmd > 4 then
            prefix = cmd[1]+cmd[2]+cmd[3]
        end
        if prefix == "Bro_" then

        else
            local f = command[cmd]
        end
        
        local head,msg = f(...)
        if head ~= nil then
            skynet.retpack(head,msg)
        end
    end)
    skynet.register("sceneService")
end)