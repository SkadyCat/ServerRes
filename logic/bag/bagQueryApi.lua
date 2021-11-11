local mysql = require "mysql/mysqlHelp"
local json = require "json"

local bagCode = require "bag/bagCode"
local command = {}
function command.pull(_character_id)
    local tp = mysql.query("bagEvent","pullBag",_character_id)
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
        mysql.query("bagEvent","updateBag",v.item_id,v.grid_num,v.cd,_character_id,v.grid_id)
    end
end
----------------------------base event----------------------------

function command.init()
    return true
end

return command