local mysql = require "mysql/mysqlHelp"
local json = require "json"

local sceneEvent

local module = {}


function module.onEnterScene(uid)
    local sc = module.sc
    local uInfo = sc:getUser(uid).userInfo
    local user_acc = uInfo.userAcc
    local info = mysql.query("sceneEvent","select",user_acc)
    return info[1],points
end

function module.getPoints()
    local sc = module.sc
    local points = mysql.query("eqsEvent","selectAll",sc.sceneName)
    return points
end

function module.onLeaveScene(uid)
    local sc = module.sc
    local pos = sc:getUser(uid).pos
    local uInfo = sc:getUser(uid).userInfo
    local user_acc = uInfo.userAcc
    local info = mysql.query("sceneEvent","update",pos.x,pos.y,pos.z,user_acc)
    -- ,uInfo.pos.x,uInfo.pos.y,uInfo.pos.z
end

function module.init(scene)
    module.sc = scene
end
return module