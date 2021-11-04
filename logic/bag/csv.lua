

local csv = require "Csvparse"
local json = require "json"
local command = {}
local map = {}
local orderMap = {}
function command.read(name)

    local tp = csv.read("/home/magic/Server/res/static/config/"..name)
    for k,v in pairs(tp) do
        map[tonumber(v.id)] = v
        table.insert(orderMap,v)
    end
    
end

function command.load(name)
    local maps = {}
    local tp = csv.read("/home/magic/Server/res/static/config/"..name)
    for k,v in pairs(tp) do
        maps[tonumber(v.id)] = v
    end
    return maps
end

function command.randomItem()
    return orderMap[math.ceil(math.random()*(#orderMap))]
end

function command.get(key)
    return map[key]
end

return command