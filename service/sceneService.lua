local skynet = require "skynet"
require "skynet.manager"
local sceneMap = require "scene/sceneMap"
local json = require "json"

local command = {}

function command.EnterSceneReq(msg)
    print("enter scene")
    local sceneInfo = sceneMap.setScene(msg.uid,msg.sceneName)
    return "EnterSceneRet",msg
end


function command.BroadCast(name,msg)
    sceneMap.broadCast(name,msg)
    
end

function command.QryScenesReq(msg)
    local scenes = sceneMap.queryScenes(msg)
    return "QryScenesRet",scenes
end

function command.QryScenePlayerReq(msg)
    local players = sceneMap.queryPlayers(msg.uid)
    return "QryScenePlayerRet",{ids = players}
end
function command.MoveReq(msg)
    local tp = {id = msg.uid,pos = msg.pos,timeStamp = msg.timeStamp}
    return "MoveRet",tp;
end

function command.SetPosReq(msg)
    sceneMap.setPos(msg.uid,msg)
end
function command.SetRotReq(msg)
    local scene = sceneMap.getScene(msg.uid)
    scene:setRot(msg.uid,msg)
end

function command.TestFindPathReq(msg)
    print(json.encode(msg))
    local sc = sceneMap.getScene(msg.uid)
    if sc then
        local paths = sc:findPath(msg.bginPos,msg.endPos)
        local tp = {paths = paths}
        return "TestFindPathRet",tp
    end
end

--非协议内部调用

function command.init(uid,sceneName)
    local sc = sceneMap.setScene(uid,sceneName)
end

function command.leaveScene(msg)
    
    sceneMap.leave(msg.uid)
end

function command.broadCast(uid,head,msg)
    local sc = sceneMap.getScene(uid)
    sc:broadCast(head,msg)
end




skynet.start(function()
    skynet.dispatch("lua", function(session, source, cmd, ...)
        -- 在这里进行转接
        local prefix = ""
        if #cmd > 4 then
            prefix = string.sub(cmd,#cmd - 2,#cmd)
        end
        if prefix == "Bro" then
            local f = command["BroadCast"]
            local head = f(cmd,...)
            skynet.retpack(head)
        else
            local f = command[cmd]
            local head,msg = f(...)
            skynet.retpack(head,msg)
        end
        
        
    end)
    skynet.register("sceneService")
end)