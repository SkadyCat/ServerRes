
local playerApi = require "statu/player"
local playerMap = {}

local module = {}

function module.addPlayer(uid)
    playerMap[uid] = playerApi.new(uid)
end

function module.removePlayer(uid)
    playerMap[uid] = nil
end

function module.getRole(uid)
    return playerMap[uid]
end


return module
