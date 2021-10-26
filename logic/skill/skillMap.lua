

local module = {}
local skillMap = {}
function module.new(uid,scene)
    local skillObj = {}
    skillObj.id = uid
    skillObj.scene = scene
    skillMap[uid] = skillObj
end

function module.clear(uid)
    skillMap[uid] = nil
end

function module.get(uid)

    return skillMapp[uid]
end




return module