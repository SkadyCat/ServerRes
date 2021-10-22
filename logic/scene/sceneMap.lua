local scene = require "scene/scene"
local sceneMap = {}
local playerSceneMap = {}
function sceneMap.init()
    local sc = scene.new("TestLab")
    sceneMap["TestLab"] = sc
end

function sceneMap.move(uid,dst)
    print("move to world")
    local isInMap = playerSceneMap[uid]
    if isInMap then
        playerSceneMap[uid]:leave(uid)
        sceneMap[dst]:enter(uid)
    else
        sceneMap[dst]:enter(uid)
    end
end
sceneMap.init()
return sceneMap