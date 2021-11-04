
local skynet = require "skynet"
local module = {}
local skillMap = {}
local config = require "config/skillConfig"

function module.new(uid,scene)
    local skillObj = {}
    skillObj.id = uid
    skillObj.scene = scene
    skillMap[uid] = skillObj
    skillObj.cd = {}

    function skillObj:getCD(id)
        return self.cd[id]
    end

    function skillObj: setCD(id)
        self.cd[id] = skynet.time()
    end

    function skillObj:judgeCD(id)
        if self.cd[id] == nil then
            return 1
        end

        if config:get(id) == nil then 
            return -1

        end
        if (skynet.time() - self.cd[id])<tonumber(config:get(id).CD) then
            return -1
        end
        return 1
    end
    return skillMap[uid]
end

function module.clear(uid)
    skillMap[uid] = nil
end

function module.get(uid)

    return skillMap[uid]
end




return module