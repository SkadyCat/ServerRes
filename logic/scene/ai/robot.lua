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
module.monsterMap = monsterMap
module.CODE = CODE



function module.new(nav,num,pos)
    local role = {}
    monsterMap[#monsterMap + 1] = role
    role.model = model.new(nav,posSet,k)
    role.tree = treeApi.new("monster",role.model)
    vec3.copy(role.model.param.pos,pos)
    vec3.copy(role.model.param.bornPos,pos)
    role.model.param.id = #monsterMap
end

-- 状态更新
function module.update(v,msg)
    monsterMap[v].model:update(msg)
end

-- 每一帧都会调用
function module.run()
    for k,v in pairs(monsterMap) do
        v.tree:run()
    end

end

return module