
local playerApi = require "statu/player"
local playerMap = {}

local module = {}

function module.new(uid)
    local tp = {}
    tp.statu = {
        hp = 100,
        mp = 100,
        maxHp = 100,
        maxMp = 100
    }
    function tp:setHp(hp)
        self.statu.hp = hp
    end
    function tp:setMp(mp)
        self.statu.mp = mp
    end

    playerMap[uid] = tp
    return tp
end

function module.remove(uid)
    playerMap[uid] = nil
end

function module.get(uid)
    return playerMap[uid]
end


return module
