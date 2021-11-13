

local module = {}
local vec3 = require "vec3"

local json = require "json"
local command = {}

local next = false
local back = true


local function userLeaveEvent(rb,uid)
    local param = rb.param
    local sc = rb.scene
    param.hateMap[uid] = 0
    for k,v in pairs(param.hateMap) do
        if v == 1 then
            param.hateID = k
            return
        end
    end
    param.hateID = 0
    param.dst = nil
    param.paths = nil
    sc:setSpeed(0.1)
end
function command.aoi(rb,msg)
    local param = rb.param
    local sc = rb.scene
    param.hateMap[msg.marker] = msg.flag
    if msg.flag == 1 then
        param.hateID = msg.marker
        sc:setSpeed(0.3)
    end
end

function command.playerEvent(rb,msg)

    local param = rb.param
    local sc = rb.scene
    param.hp = param.hp - 50
    if param.hp <= 0 then

        
        param.isDead = true
        param.deadTime = 10

        param.pos = rb.posSet:random()
        sc:broadCast("MonsterDeadRet",{id = param.id,pos = param.pos})
        return
    end
    param.atkGap = 1
    param.hateMap[msg.uid] = 1
    param.hateID = msg.uid

    sc:broadCast("MonsterHpRet",{id = param.id,hp = param.hp,maxHp = param.maxHp})
end
function command.userLeave(rb,msg)
    userLeaveEvent(rb,msg)
end
function module.new(scene,posSet,id)
    local rb = {}
    rb.scene = scene
    rb.posSet = posSet
    rb.param = {
        hateID = 0,
        CD = 0,
        dst = nil,
        pos = {x = 0,y = 0,z = 0},
        paths = nil,
        speed = 1,
        index = 1,
        id = id,
        playerPos = {x = 0,y = 0,z = 0},
        atkGap = -0.1,
        hateMap = {},
        isStop = false,
        maxHp = 200,
        hp = 200,
        isDead = false,
        deadTime = 0
    }
    rb.scene:setSpeed(0.1)
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
        self.param.deadTime = self.param.deadTime - 0.05
        return next
    end
    function rb:deadTimeEnd()
        if self.param.deadTime < 0 then
            return next
        end
        return back
    end
    function rb:relive()
        print("重生")
        self.param.isDead = false
        self.param.pos = self.posSet:random()
        local param = self.param
        self.scene:broadCast("MonsterReliveRet",{id = param.id,pos = param.pos})
        param.hateMap = {}
        param.hateID = 0
        param.dst = self.posSet:random()
        param.index = 1
        self.param.paths = self.scene:findPath(self.param.pos,
        self.param.dst)
        self.param.index = 1
        self.scene:setSpeed(0.1)
        param.hp = param.maxHp

    end
    function rb:update(msg)
        command[msg.code](rb,msg.value)
    end
    function rb:updatePlayerPos()
        local param = self.param
        vec3.copy(param.playerPos,self.scene.playerMap[param.hateID].pos)
    end
    function rb:lowOffset()
        local param = self.param
        if vec3.dis(param.dst,param.playerPos) < 1 then
            return next
        end
        return back
    end

    function rb:moreOffset()
        local param = self.param
        -- print("more: "..vec3.dis(param.dst,param.playerPos)..json.encode(param.playerPos)..json.encode(param.dst))
        
        -- print(param.dst)
        -- print(param.playerPos)
        if vec3.dis(param.dst,param.playerPos) > 1 then
            return next
        end
        return back
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
        if param.CD <= 0 then
            return next
        end
        return back
    end

    function rb:atkPlayer()
        local msg = {id = self.param.id,type = 1}
        self.scene:broadCast("MonsterAtkRet",msg)
        self.param.CD = 2.6
        self.param.atkGap = 2.5
    end
    function rb:inCD()
        local param = self.param
        if param.CD >0 then
            return next
        end
        return back
    end
    function rb:flushCD()
        self.param.CD = self.param.CD - 0.05
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
        self.param.atkGap = self.param.atkGap - 0.05
        return next
    end
    function rb:noArriveDst()
        local pr = self.param
        if pr.pos == nil then
            pr.pos = pr.dst
        end
        if vec3.dis(pr.pos,pr.dst)>1 then
            return next
        end
        return back
    end
    local lastPos = vec3.new(0,0,0)
    function rb:goDst()
        if self.param.hateID ~= 0 then
            print("hate id = "..self.param.hateID)
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
        pr.pos = pr.paths[pr.index]
        pr.index = pr.index+1
        local msg = {id = pr.id,pos = pr.pos}
        scene:broadCast("MonsterPosRet",msg)
    end
    function rb:goPlayer()
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
    function rb:arriveDst()
        local pr = self.param
        if vec3.dis(pr.pos,pr.dst) < 2.4 then
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