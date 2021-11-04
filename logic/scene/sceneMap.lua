local scene = require "scene/scene"
local module = {}
local sceneMap = {}

local user_sceneMap = {}

function module.init()
    local sc = scene.new("TestLab")
    sceneMap["TestLab"] = sc
end

function module.leave(uid)
    local sceneName = user_sceneMap[uid]
    if sceneName then
        sceneMap[sceneName]:leave(uid)
        user_sceneMap[uid] = nil
    end
end
function module.queryScenes()
    local tp = {}
    for j,v in pairs(sceneMap) do
        table.insert(tp,j)
    end
    local rq = {scenes = tp}
    return rq
end

function module.queryPlayers(uid)
    local sceneName = user_sceneMap[uid]
    if sceneName == nil then
        return nil
    end
    local scene = sceneMap[sceneName]
    local players = scene:queryPlayers()
    return players
end

function module.broadCast(name,msg)
    local uid = msg.uid
    -- msg.uid = nil
    local sc = sceneMap["TestLab"]
    sc:broadCast((name.."Ret"),msg)
end
function module.setScene(uid,sceneName,userInfo)
    local isInMap = sceneMap[sceneName]:query(uid)

    if isInMap then
        sceneMap[sceneName]:leave(uid)
        sceneMap[sceneName]:enter(uid,userInfo)
    else
        sceneMap[sceneName]:enter(uid,userInfo)
    end
    user_sceneMap[uid] = sceneName
    return sceneMap[sceneName]
end

function module.setPos(uid,msg)
    local sceneName = user_sceneMap[uid]
    if sceneName then
        local sc = sceneMap[sceneName]
        sc:setPos(uid,msg)
    end
end

function module.getScene(uid)
    local sceneName = user_sceneMap[uid]
    if sceneName == nil then
        return false
    end
    return sceneMap[sceneName]
end
module.init()
return module