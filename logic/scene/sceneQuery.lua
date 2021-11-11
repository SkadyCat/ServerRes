


local mysql = require "common/mysql"
local json = require "json"
local sceneEvent

local module = {}


function module.onEnterScene(uid)

end

function module.onLeaveScene(uid)

end

function init()
    mysql.connect()
    sceneEvent = mysql.sceneEvent()
end
return module