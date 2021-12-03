

local module = {}
local vec3 = require "vec3"

local json = require "json"
local skillConfig = require "config/skillConfig"

local command = {}

local next = false
local back = true
local deltaTime = 0.1
local dstGap =2
local atkRange = 20
local maxCD = 2


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

local function hateProcess(param,hateId)
    -- param.atkGap = 0.2
    param.hateMap[hateId] = 1
    param.hateID = hateId
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
    param.dst = nil
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

    slowdownProcess(sc,param,slowdown)
    hurtProcess(sc,param,crit,hurt,rb.posSet,msg,skillInfo)
    hateProcess(param,msg.uid)
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

function module.new(scene,posSet,id)
    local rb = {}
    rb.scene = scene
    rb.posSet = posSet
    rb.param = {
        hateID = 0,
        CD = 0,
        dst = nil,
        pos = posSet:random(),
        paths = nil,
        speed = 0.4,
        maxSpeed = 0.4,
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
    }
    function rb:allowMove()
        if self.param.isStop == false then
            return next
        end
        return back
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
    function rb:relive()
        self.param.isDead = false
        self.param.pos = self.param.bornPos
        self.scene:updateAoi(self.param.id)
        local param = self.param
        self.scene:broadCast("MonsterReliveRet",{id = param.id,pos = param.pos})
        param.hateMap = {}
        param.hateID = 0
        param.dst = self.posSet:random()
        param.index = 1
        self.param.paths = self.scene:findPath(self.param.pos,
        self.param.dst)
        self.param.index = 1
        self.param.speed = 0.1
        param.hp = param.maxHp

        return next
    end


    -- 减速模块
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
    function rb:Log()
        -- print("log")
        -- -- print("speed : "..self.param.speed.." "..self.param.slowdownTime)
        return next
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
            sc:broadCast("MonsterHpRet",rInfo)
        end
        param.hurtTB = {}
    end

    function rb:update(msg)
        command[msg.code](rb,msg.value)
    end
    function rb:updatePlayerPos()
        local param = self.param
        self.param.dst = {}
        vec3.copy(self.param.dst,self.scene.playerMap[param.hateID].pos)
        return next
    end

    function rb:judgeDis()
        local param = self.param
        if vec3.dis(param.pos,param.dst) > atkRange then
            return next
        end
        return back
    end
    function rb:clearHate()
        print("清空仇恨")
        local param = self.param
        param.hateID = 0
        param.hateMap = {}
        local info = {}
        info.id = param.id

        self.scene:broadCast("MonsterStopRet",info)
        return back
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
        if vec3.dis(param.pos,param.dst) > dstGap then
            return next
        end
        return back
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
    function rb:findPath()

        self.scene:setSpeed(self.param.speed)
        self.param.paths = self.scene:findPath(self.param.pos,
        self.param.dst)
        self.param.index = 1
        local info = {}
        info.pos = self.param.paths
        info.id = self.param.id
        self.scene:broadCast("MonsterUpdatePosRet",info)
        return next
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

    function rb:atkPlayer()
        local msg = {id = self.param.id,type = 1}
        self.scene:broadCast("MonsterAtkRet",msg)
        self.param.CD = maxCD
        self.param.atkGap = maxCD
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

    function rb:hateEnd()
        -- print("超出攻击范围，仇恨结束")
        userLeaveEvent(rb,self.param.hateID)
        return next
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
        if vec3.dis(pr.pos,pr.dst)>dstGap then
            return next
        end
        return back
    end
    local lastPos = vec3.new(0,0,0)
    function rb:goDst()
        if self.param.hateID ~= 0 then
            -- print("hate id = "..self.param.hateID)
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
    function rb:pathMove()
        local pr = self.param
        if pr.paths[pr.index] == nil then
            return
        end
        pr.pos = pr.paths[pr.index]
        pr.index = pr.index+1
        local msg = {id = pr.id,pos = pr.pos}
        -- print("path move...")
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
        if vec3.dis(pr.pos,pr.dst) < dstGap*1.3 then
            return next
        end
        return back
    end

    function rb:clearPath()
        self.param.paths = nil
        return next
    end

    function rb:findRandomDst()
        self.param.dst = self.posSet:random()
    end

    function rb:havePath()
        if self.param.paths == nil then
            return back
        end
        return next
    end
    return rb
end




return module