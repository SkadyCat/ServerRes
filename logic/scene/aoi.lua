
local serviceCore = require "serviceCore"
local aoi = require "laoi"
local sc
local command = {}
local aroundRole = {}
local monsterAround = {}


local aroundRoleList = {}
local mtype = {monsterType = 100,userType = 101}



-- code 0 entity
-- code 1 trigger
local entityEvent =function(code,type,mself,other,st,ot)
    if ot == mtype.monsterType and st == 0 then
        aroundRole[mself][other] = type
        aroundRole[other][mself] = type
    end
    if ot == mtype.userType and st == 0 then
        aroundRole[mself][other] = type
        aroundRole[other][mself] = type
    end
    if st == mtype.monsterType then
        if code == 0 then
            aroundRole[mself][other] = type
            aroundRole[other][mself] = type
        end
        if code == 1 then
            if ot == mtype.userType then
                monsterAround[mself][other] = type;
            else
                aroundRole[mself][other] = type
                aroundRole[other][mself] = type
            end
        end
    end
    
    if st == mtype.userType then
        if code == 1 then
            aroundRole[mself][other] = type
            aroundRole[other][mself] = type
        end
        if code == 0 then
            if ot == mtype.monsterType then
                monsterAround[other][mself] = type;
            else
                aroundRole[mself][other] = type
                aroundRole[other][mself] = type
            end
        end
    end
    if code == 0 then
        -- -- 0 是离开，就是 other 离开mself
        -- if type == 0 then
        --     -- if mself == mtype.userType then
        --     -- end
        --     aroundRole[mself][other] = 0
        --     aroundRole[other][mself] = 0
        -- elseif type == 1 then
        --     -- print("entity other = "..other.." enter "..mself)
        --     aroundRole[mself][other] = 1
        --     aroundRole[other][mself] = 1
        -- end
        -- aroundRole[mself][other] = type
        -- aroundRole[other][mself] = type
    end
    if code == 1 then

        -- aroundRole[mself][other] = type
        -- aroundRole[other][mself] = type

        -- if type == 0 then

        --     if st == mtype.userType then
        --         aroundRole[mself][other] = 0
        --         aroundRole[other][mself] = 0
        --     end
        --     -- aroundRole[mself][other] = 0
        --     -- aroundRole[other][mself] = 0
        -- elseif type == 1 then

        -- end
    end
end
local triggerEvent = function(code,type,mself,other,st,ot)
    if code == 0 then
        -- 0 是离开，就是 other 离开mself
        if type == 0 then
            print("other = "..other.." leave "..mself)
            aroundRole[mself][other] = 0
        elseif type == 1 then
            print("other = "..other.." enter "..mself)
            aroundRole[mself][other] = 1
        end
    end
    if code == 1 then
        if type == 0 then
            print("other = "..other.." lefve "..mself)
            aroundRole[mself][other] = 0
        elseif type == 1 then
            print("other = "..other.." enter "..mself)
            aroundRole[mself][other] = 1
        end
    end
end

function command.init()
    sc = aoi.new()
    aoi.setecall(sc,entityEvent)
    aoi.settcall(sc,triggerEvent)
end

function command.add(id,x,y,range,type)
    aroundRole[id] = {}
    aroundRoleList[id] = {}
    if type == mtype.monsterType then
        monsterAround[id] = {}
    end
    aoi.add(sc,id,x+1500,y+1500,range,type)
end

function command.remove(id)
    for k,v in pairs(aroundRoleList[id]) do
        aroundRole[v][id] = nil
    end
    -- 广播一下角色的状况
    aroundRole[id] = nil
    aroundRoleList[id] = nil
    monsterAround[id] = {}
    aoi.remove(sc,id)
end

function command.setPos(id,x,y)
    local re = aoi.update(sc,id,x+1500,y+1500)
    for k,v in pairs(re) do
        entityEvent(v.code,v.type,v.self,v.other,v.st,v.ot)
    end
end

function command.aroundMonster(id)
    local tp = {}
    for k,v in pairs(monsterAround[id]) do
        if v == 1 then
            table.insert(tp,k)
        end
    end
    return tp
end
function command.getAroundRole(id)
    aroundRoleList[id] = {}

    for k,v in pairs(aroundRole[id]) do
        if v == 1 then
            table.insert(aroundRoleList[id],k)
        end
    end
    return aroundRoleList[id]
end
return command