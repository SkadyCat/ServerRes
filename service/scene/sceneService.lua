local skynet = require "skynet"
require "skynet.manager"
local sceneMap = require "scene/sceneMap"



local command = {}

function command.EnterSceneReq(msg)
    sceneMap.move(msg.uid,msg.dst)
end

function command.BroadCast(msg)
    
end

function command.MoveReq(msg)
    print(msg.pos.x)
    local tp = {id = msg.uid,pos = msg.pos,timeStamp = msg.timeStamp}
    return "MoveRet",tp;
end
skynet.start(function()
    skynet.dispatch("lua", function(session, source, cmd, ...)
        -- 在这里进行转接
        local prefix = ""
        if #cmd > 4 then
            prefix = string.sub(cmd,1,4)
            print(prefix)
        end
        if prefix == "Bro_" then

        else
            local f = command[cmd]
            local head,msg = f(...)
            if head ~= nil then
                skynet.retpack(head,msg)
            end
        end
        
        
    end)
    skynet.register("sceneService")
end)