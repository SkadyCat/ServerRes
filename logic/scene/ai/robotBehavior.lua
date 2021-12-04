

local module = {}
local vec3 = require "vec3"

local json = require "json"
local skillConfig = require "config/skillConfig"

local command = {}

local next = false
local back = true
local deltaTime = 0.1
local dstGap = 1
local atkRange = 25
local maxCD = 1
local aktDis = 2


local function slowdownProcess(sc,param,slowdown)
    if slowdown > 0 and slowdown < 1 then
        sc:broadCast("MonsterSpecialStautRet",{id = param.id,type = 1})
        param.slowdown = slowdown
        param.slowdownTime = 3
    end
    if slowdown == 1 then
        sc:broadCast("MonsterSpecialStautRet",{id = param.id,type = 2})
        param.slowdown = slowdown
        param.slowdownTime = 3
    end
end

local function hurtProcess(sc,param,crit,hurt,posSet,msg,skillModel)
    local hurtModel = msg.model
    hurt = hurtModel.hurtValue
    hurtModel.skill = msg.skill
    -- param.hp = param.hp - hurtModel.hurtValue
    table.insert(param.hurtTB,hurtModel)

    
end

local function hateProcess(param,hateId,scene)
    -- param.atkGap = 0.2
    param.hateMap[hateId] = 1
    param.hateID = hateId
end

local function specialFlag(v,flag)
    local ff = string.sub(v,1,1)
    if ff == flag then
        return true,string.sub(v,2,#v)
    end
    return false,v
end


local function userLeaveEvent(rb,uid)
    local param = rb.param
    local sc = rb.scene
    param.hateMap[uid] = 0
    param.hateID = 0
    for k,v in pairs(param.hateMap) do
        if v == 1 then
            param.hateID = k
            return
        end
    end
    param.hateID = 0
    param.paths = nil
    param.speed = param.maxSpeed
end
function command.aoi(rb,msg)
    local param = rb.param
    local sc = rb.scene
    param.hateMap[msg.marker] = msg.flag
    if msg.flag == 1 then
        -- print("player enter...")
        param.hateID = msg.marker
        param.speed = param.maxSpeed
    -- else
        -- userLeaveEvent(rb,msg.marker)
    end
end

function command.playerEvent(rb,msg)
    local param = rb.param
    local sc = rb.scene
    local skillInfo = skillConfig:get(msg.skill)
  
    local slowdown = tonumber(skillInfo.slowdown)
    local crit = tonumber(skillInfo.crit)
    local baseHurt = tonumber(skillInfo.hurt)
    local hurt = baseHurt*(1+crit)

    hurtProcess(sc,param,crit,hurt,rb.posSet,msg,skillInfo)
    hateProcess(param,msg.uid,sc)
end
function command.userLeave(rb,msg)
    -- print("user leave...")
    userLeaveEvent(rb,msg)
end

local function hurtModel(hp,uid)
    local v = {}
    v.hp = hp
    v.uid = uid
    return v
end
local function compare(flag,v1,v2)
    if flag == "==" then
        if v1 == v2 then
            return next
        end
    elseif flag == ">" then
        if v1>v2 then
            return next
        end
    elseif flag == "<" then
        if v1<v2 then
            return next
        end
    end
    return back
end
function module.new(scene,posSet,id)
    local rb = {}
    rb.scene = scene
    rb.posSet = posSet
    rb.param = {
        hateID = 0,
        CD = 0,
        dst = {x = 0,y = 0,z = 0},
        pos = {x = 0,y = 0,z = 0},
        paths = nil,
        speed = 0.8,
        maxSpeed = 0.8,
        bornPos = {x = 0,y = 0,z = 0},
        index = 1,
        id = id,
        playerPos = {x = 0,y = 0,z = 0},
        atkGap = -0.1,
        hateMap = {},
        isStop = false,
        maxHp = 1000,
        hp = 1000,
        isDead = false,
        deadTime = 0,
        hurtTB = {},
        slowdown = 0,
        slowdownTime = 0,
        abnormalStatu = 0,
        abnormalTB = {},
        code = 0
    }

    -- 广播行为
    function rb:relive()
        self.param.isDead = false
        self.param.pos = self.param.bornPos
        self.scene:updateAoi(self.param.id)
        local param = self.param
        self.scene:broadCast("MonsterReliveRet",{id = param.id,pos = param.pos})
        param.hateMap = {}
        param.hateID = 0
        param.index = 1
        self.param.paths = self.scene:findPath(self.param.pos,
        self.param.dst)
        self.param.index = 1
        self.param.speed = 0.1
        param.hp = param.maxHp

        return next
    end

    function rb:processAbnormal()
        local param = self.param
        print("处理异常状态")
        if param.abnormalStatu == 1 then
            -- 减速状态
            param.speed = self.param.maxSpeed * (1-self.param.slowdown)
            param.abnormalTB[param.abnormalStatu] = 3
            self.scene:broadCast("MonsterSpecialStautRet",{id = param.id,type = 1})
            self:findPath()
        end
        param.abnormalStatu = 0
        return next
    end
    function rb:updatePlayerPos()
        local param = self.param
        vec3.copy(self.param.playerPos,self.scene.playerMap[param.hateID].pos)
        return next
    end
    function rb:stopMove()
        local param = self.param
        local info = {}
        info.id = param.id
        self.scene:broadCast("MonsterStopRet",info)
    end
    function rb:findPath(v)
        self.scene:setSpeed(self.param.speed)
        self.param.paths = self.scene:findPath(self.param.pos,
        self.param.dst)
        self.param.index = 1
        local param = self.param

        local info = {}
        info.pos = self.param.paths
        info.id = self.param.id
        self.scene:broadCast("MonsterUpdatePosRet",info)
        if v[#v] == "log" then
            print("begin: "..json.encode(param.paths[1])..json.encode(param.pos).." end: "..json.encode(param.paths[#param.paths])..json.encode(param.dst))
        end
        -- return next
    end

    function rb:pathMove()
        local pr = self.param
        if pr.paths[pr.index] == nil then
            return
        end
        pr.pos = pr.paths[pr.index]
        pr.index = pr.index+1
        local msg = {id = pr.id,pos = pr.pos}
    end
    function rb:Log(v)
        print(v[1])
        -- -- print("speed : "..self.param.speed.." "..self.param.slowdownTime)
    end
    
    function rb:atkPlayer()
        local msg = {id = self.param.id,type = 1,aimID = self.param.hateID,aimType = 1}
        self.scene:broadCast("MonsterAtkRet",msg)
    end
    function rb:hateEnd()
        -- print("超出攻击范围，仇恨结束")
        userLeaveEvent(rb,self.param.hateID)
        return next
    end
    function rb:hurt(k,v)
        local param = self.param
        local sc = self.scene
        param.hp = param.hp - v.hurtValue
        if param.hp <= 0 then
            param.isDead = true
            param.deadTime = 10
            sc:broadCast("MonsterDeadRet",{id = param.id,pos = param.pos})
        end
        local hurtType = v.hurtType
        local rInfo = {
            id = param.id,
            hp = param.hp,
            maxHp = param.maxHp,
            hurtType = hurtType,
            hurtVal = v.hurtValue,
            skill = v.skill
        }
        local skillInfo = skillConfig:get(v.skill)
        local slowdown = tonumber(skillInfo.slowdown)
        if slowdown > 0 then
            param.abnormalStatu = 1
            param.slowdown = slowdown
        end
        sc:broadCast("MonsterHpRet",rInfo)
        return next
    end

    function rb:abnormalFlush()
        local param = self.param
        for k,v in pairs(param.abnormalTB) do
            local last = v
            param.abnormalTB[k] = param.abnormalTB[k] - deltaTime
            local n = param.abnormalTB[k]
            if v>0 and n<= 0 then
                self:recoverAbnormalStatu(k)
            end
        end
    end
    
    function rb:compare_list(v)
        local tbName = v[1]
        local flag = v[2]
        local param = self.param
        local tb = param[tbName]
        if flag == "unempty" and tb ~= nil and #tb >0 then
            return next
        end
        if flag == "empty" and (tb == nil or #tb == 0) then
            return next
        end
        return back
    end

    function rb:process_list(v)
        local tbName = v[1]
        local param = self.param
        local tb = param[tbName]
        for k,_v in pairs(tb) do
            self[v[2]](self,k,_v)
        end
    end

    function rb:clear_list(v)
        local tbName = v[1]
        local param = self.param
        param[tbName] = {}
    end
    function rb:compare_bool(v)
        local param = self.param
        if param[v[1]] == true and v[2] == "true" then
            return next
        elseif param[v[1]] == false and v[2] == "false" then
            return next
        end
        return back
    end

    function rb:compare_float(v)
        local param = self.param
        local f1 = param[v[1]]
        local f2 = v[3]
        local dst = nil
        if string.sub(f2,1,1) == "*" then
            dst = param[string.sub(f2,2,#f2)]
        else
            dst = tonumber(f2)
        end
        local flag = v[2]
        local rf = compare(flag,f1,dst)

        if v[#v] == "log" then
            print(f1..flag..dst)
        end
        return rf
    end
    -- 复活事件---------------

    function rb:isNotDeading()
        if self.param.isDead == false then
            return next
        end
        return back
    end
    
    function rb:isDeading()
        if self.param.isDead == true then
            return next
        end
        return back
    end
    function rb:flushDeadTime()
        self.param.deadTime = self.param.deadTime - deltaTime
        return next
    end
    function rb:deadTimeEnd()
        if self.param.deadTime < 0 then
            return next
        end
        return back
    end



    -- 减速模块

    function rb:detectAbnormal()
        local param = self.param
        if param.abnormalStatu == 0 then
            return back
        end
        return next
    end




    function rb:recoverAbnormalStatu(k)
        local param = self.param
        if k == 1 then
            param.speed = param.maxSpeed
            self.scene:broadCast("MonsterSpecialStautRecoverRet",{id = self.param.id,type = 2})
            self:findPath()
        end

    end


    function rb:compare_int(v)
        local param = self.param
        local v1 = v[1]
        local flag = v[2]
        local v2 = tonumber(v[3])
        if flag == "==" then
            if param[v1] == v2 then
                return next
            end
        elseif flag == ">" then
            if param[v1] > v2 then
                return next
            end
        elseif flag == "<" then
            if param[v1] < v2 then
                return next
            end
        end
        if v[#v] == "log" then
            print(v[1]..":"..param[v[1]])
        end
        return back
    end
    function rb:compare_vec3(v)
        local param = self.param
        local f1 = param[v[1]]
        local op = v[3]
        local f3 = param[v[2]]
        local f4 = tonumber(v[4])
        local dis = vec3.dis(vec3.new(f1.x,0,f1.z),vec3.new(f3.x,0,f3.z))

        if (op == '>') and (dis>f4) then
            return next
        elseif (op == "<") and (dis<f4) then
            return next
        end
        if v[#v] == 'log' then
            print("dis: "..dis.." ".."between:"..v[1]..","..v[2])
        end
        return back
    end
    
    function rb:change_v3(v)
        local origin = v[1]
        local aim = v[2]
        local param = self.param
        vec3.copy(param[origin],param[aim])
    end

    function rb:change_int(v)
        local origin = v[1]
        local aim = v[2]
        local param = self.param
        param[origin] = param[aim]
    end

    function rb:set_int(v)
        local origin = v[1]
        local aim = tonumber(v[2])
        local param = self.param
        param[origin] = aim

        if v[#v] == "log" then
            print(origin..":"..aim)
        end
    end

    function rb:change_str(v)

    end




    function rb:notEndSlowDownTime()
        if self.param.slowdownTime > 0 then
            return next
        end
        return back
    end

    function rb:cutSlowDownTime()
        self.param.slowdownTime = self.param.slowdownTime - deltaTime
        return next
    end

    function rb:slowDownTimeLowerZero()
        if self.param.slowdownTime < 0 then
            return next
        end
        return back
    end

    function rb:setSpeed()
        if self.param.speed ~= self.param.maxSpeed * self.param.slowdown then
            self.param.speed = self.param.maxSpeed * (1-self.param.slowdown)
        end
        return next
    end

    function rb:recoverSpeed()
        self.param.slowdownTime = 0
        self.param.slowdown = 0
        self.param.speed = self.param.maxSpeed
        self.scene:broadCast("MonsterSpecialStautRecoverRet",{id = self.param.id,type = 2})
        return next
    end


    -- 被攻击模块
    function rb:detectHurt()
        local param = self.param
        if #param.hurtTB > 0 then

            return next
        end
        return back
    end




    function rb:hurtProcess()
        local param = self.param
        local sc = self.scene
        print("#"..#param.hurtTB)
        for k,v in pairs(param.hurtTB) do
            param.hp = param.hp - v.hurtValue
            if param.hp <= 0 then
                param.isDead = true
                param.deadTime = 10
                sc:broadCast("MonsterDeadRet",{id = param.id,pos = param.pos})
                break
            end
            local hurtType = v.hurtType
            local rInfo = {
                id = param.id,
                hp = param.hp,
                maxHp = param.maxHp,
                hurtType = hurtType,
                hurtVal = v.hurtValue,
                skill = v.skill
            }
            local skillInfo = skillConfig:get(v.skill)
            local slowdown = tonumber(skillInfo.slowdown)
            if slowdown > 0 then
                param.abnormalStatu = 1
                param.slowdown = slowdown
            end


            sc:broadCast("MonsterHpRet",rInfo)
        end
        param.hurtTB = {}
    end

    function rb:update(msg)
        command[msg.code](rb,msg.value)
    end


    function rb:judgeDis()
        local param = self.param
        if vec3.dis(param.pos,param.playerPos) > atkRange then
            return next
        end
        return back
    end
    function rb:clearHate()
        print("清空仇恨")
        local param = self.param
        param.hateID = 0
        param.hateMap = {}
    end

    function rb:lowOffset()
        local param = self.param
        if vec3.dis(param.dst,param.dst) < 1 then
            
            return next
        end
        return back
    end

    function rb:moreOffset()
        local param = self.param
        if vec3.dis(param.playerPos,param.dst) > dstGap then
            return next
        end
        return back
    end
    function rb:updateDst2PlayerPos()
        local param = self.param
        vec3.copy(param.dst,param.playerPos)
    end
    function rb:doNext()
        -- print("继续")
        return next
    end
    function rb:updateAtkPos()
        local param = self.param
        vec3.copy(param.dst,param.playerPos)
        return next
    end

    function rb:noDst()
        if self.param.dst == nil then
            return next
        end
        return back
    end
    function rb:haveHate()
        if self.param.hateID ~= 0 then
            return next
        end
        return back
    end
    function rb:haveHate2()
        if self.param.hateID ~= 0 then
            return next
        end
        return back
    end

    function rb:noHate()
        if self.param.hateID == 0 then
            return next
        end
        return back
    end 

    

    function rb:noPlayerPos()

        return false
    end
    function rb:noPath()
        if self.param.paths == nil then
            return next
        end
        return back
    end


    function rb:findAtkPath()
        self.param.paths = self.scene:findPath(self.param.pos,
        self.param.dst)
        self.param.index = 1
        local info = {}
        info.pos = self.param.paths
        info.id = self.param.id
        self.scene:broadCast("MonsterUpdatePosRet",info)
        return next
    end

    function rb:haveDst()
        if self.param.dst ~= nil then
            
            return next
        end
        return back
    end
    function rb:detectCD()
        local param = self.param
        -- print("检测cd："..param.CD)
        if param.CD <= 0 then
            return next
        end
        return back
    end

 

    function rb:inCD()
        local param = self.param
        if param.CD >0 then
            return next
        end
        return back
    end
    function rb:flushCD()
        self.param.CD = self.param.CD - deltaTime
    end

    function rb:moreAtkRange()
        local pr = self.param
        -- print("攻击范围："..vec3.dis(pr.pos,pr.dst))
        if vec3.dis(pr.pos,pr.dst)>atkRange then
            return next
        end
        return back
    end



    
    function rb:isNotAtking()
        if self.param.atkGap > 0 then
            return back
        end
        return next
    end

    function rb:isAtking()
        if self.param.atkGap > 0 then
            return next
        end
        return back
    end
    function rb:flushAtkGap()
        self.param.atkGap = self.param.atkGap - deltaTime
        
    end
    function rb:noArriveDst()
        local pr = self.param
        if pr.pos == nil then
            pr.pos = pr.dst
        end
        -- print("dis = "..vec3.dis(pr.pos,pr.dst))
        if vec3.dis(pr.pos,pr.playerPos)>aktDis then
            return next
        end
        return back
    end
    local lastPos = vec3.new(0,0,0)
    function rb:goDst()
        if self.param.paths == nil then
            return
        end
        if #self.param.paths == 0 then
            return
        end
        local pr = self.param
        if pr.paths[pr.index] == nil then
            return back
        end
        pr.pos = pr.paths[pr.index]
        pr.index = pr.index+1
        local msg = {id = pr.id,pos = pr.pos}
        scene:broadCast("MonsterPosRet",msg)
        return next
    end
   
    function rb:goPlayer()
        local pr = self.param
        if pr.paths[pr.index] == nil then
            return
        end
        pr.pos = pr.paths[pr.index]
        pr.index = pr.index+1
        local msg = {id = pr.id,pos = pr.pos}
        scene:broadCast("MonsterPosRet",msg)
        return next
    end
    function rb:arriveDst()
        local pr = self.param
        -- print("arriveDst: "..vec3.dis(pr.pos,pr.dst) )
        if vec3.dis(pr.pos,pr.playerPos) < aktDis then
            return next
        end
        return back
    end

    function rb:clearPath()
        self.param.paths = nil
        return next
    end

    function rb:findRandomDst()
        -- self.param.dst = self.posSet:random()
    end
    function rb:flush(v)
        local param = self.param
        local s1 = v[1]
        param[s1] = param[s1] - deltaTime
    end
    function rb:havePath()
        if self.param.paths == nil then
            print("不存在路径")
            return back
        end
        return next
    end
    return rb
end




return module