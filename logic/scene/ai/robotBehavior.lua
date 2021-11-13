

local module = {}
local vec3 = require "vec3"

local json = require "json"
local command = {}

local next = false
local back = true

function command.aoi(rb,msg)
    local param = rb.param
    local sc = rb.scene
    if msg.flag == 1 then
        param.hateID = msg.marker
    else 
        param.hateID = 0
        param.dst = nil
        param.paths = nil
    end
end
function command.userLeave(rb,msg)
    local param = rb.param
    if param.hateID == msg then
        print("player leave"..msg)
        param.hateID = 0
        param.dst = nil
        param.paths = nil
    end
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
        playerPos = {x = 0,y = 0,z = 0}
    }
    -- {"value":{"watcher":1,"watcherType":"monster","marker":9,"markerType":"player","flag":0},"code":"aoi"}
    
    
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
            return false
        end
        return true
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
        print("find atk path dst = "..json.encode(self.param.dst))
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
        print("atk player")
        self.param.CD = 5
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

    function rb:noArriveDst()
        local pr = self.param
        if vec3.dis(pr.pos,pr.dst)>1 then
            return next
        end
        return back
    end
    local lastPos = vec3.new(0,0,0)
    function rb:goDst()
        if #self.param.paths == 0 then
            return
        end
        local pr = self.param
        pr.pos = pr.paths[pr.index]
        pr.index = pr.index+1
        local msg = {id = pr.id,pos = pr.pos}
        scene:broadCast("MonsterPosRet",msg)
    end
    function rb:pathMove()
        local pr = self.param
        pr.pos = pr.paths[pr.index]
        pr.index = pr.index+1
        local msg = {id = pr.id,pos = pr.pos}
        scene:broadCast("MonsterPosRet",msg)
    end
    function rb:goPlayer()
        print("跟踪玩家")
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