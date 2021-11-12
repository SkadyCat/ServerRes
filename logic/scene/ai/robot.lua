local treeApi = require "scene/ai/bTree"
local model = require "scene/ai/robotBehavior"
local vec3 = require "vec3"
local eqs = require "scene/ai/eqs"
local posSet = eqs.new("TestLab")

local monsterMap = {}
local module = {}
local CODE = {
    MOVE = "move",
    ATK = "atk"
}

module.CODE = CODE



function module.new(nav,num)
    for k = 1,num do
        local role = {}
        monsterMap[k] = role
        role.model = model.new(nav,posSet,k)
        role.tree = treeApi.new("monster",role.model)
        function role:update(code,msg)
            if code == CODE.MOVE then
                
            elseif code == CODE.ATK then

            end
        end
    end
    return monsterMap
end

-- 状态更新
function module.update(code,msg)
    for k,v in pairs(monsterMap) do
        v:update(code,msg)
    end
end

-- 每一帧都会调用
function module.run()
    for k,v in pairs(monsterMap) do
        v.tree:run()
    end

end

return module