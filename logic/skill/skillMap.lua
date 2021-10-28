

local module = {}
local skillMap = {}
function module.new(uid,scene)
    local skillObj = {}
    skillObj.id = uid
    skillObj.scene = scene
    skillMap[uid] = skillObj
    skillObj.cd = {}
    
    function skillObj:getCD(id)
        return self.cd[id]
    end

    function skillObj: setCD(id,cd)
        self.cd[id] = skynet.time()
    end

    function skillObj:judgeCD(id)

    end
    return skillMap[uid]
end

function module.clear(uid)
    skillMap[uid] = nil
end

function module.get(uid)

    return skillMapp[uid]
end




return module