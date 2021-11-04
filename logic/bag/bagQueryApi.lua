local serviceCore = require "serviceCore"
local mysql = require "common/mysql"
local json = require "json"
local bagEvent
local logExt = function(...)

end

local bagCode = require "bag/bagCode"
local mysqlDB

local command = {}

function command.pull(_character_id)
    local tp = mysql.execute(bagEvent.pullBag,_character_id)
    if #tp == 0 then
        for i = 0,29 do
            mysql.execute(bagEvent.initBag,_character_id,i,0,0,0)
        end
        tp = mysql.execute(bagEvent.pullBag,_character_id)
    end
    return tp
end

function command.push(_character_id,tb)
    for k = 0,29  do
        local v = tb.grids["hash:"..k]
        mysql.execute(bagEvent.updateBag,v.item_id,v.grid_num,v.cd,_character_id,v.grid_id)
    end
end
----------------------------base event----------------------------

function command.init()
    mysql.connect()
    bagEvent = mysql.bagEvent()

    return true
end

return command