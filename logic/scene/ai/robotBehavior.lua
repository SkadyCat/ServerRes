

local module = {}
local vec3 = require "vec3"



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
        id = id
    }

    function rb:noDst()
        if self.dst == nil then
            return true
        end
        return false
    end
    function rb:haveHate()
        if hateID ~= 0 then
            return true
        end
        return false
    end

    function rb:noHate()
        if hateID == 0 then
            return true
        end
        return false
    end 
    function rb:noPath()
        if self.param.paths == nil then
            return true
        end
        return false
    end
    function rb:findPath()
        self.param.paths = self.scene:findPath(self.param.pos,
    self.param.dst)
    self.param.index = 1
    end

    function rb:haveDst()
        if self.param.dst ~= nil then
            return true
        end
        return false
    end

    function rb:noArriveDst()
        local pr = self.param
        if pr.index < #pr.paths then
            return true
        end
        return false
    end
    local lastPos = vec3.new(0,0,0)
    function rb:goDst()
        local pr = self.param
        pr.pos = pr.paths[pr.index]
        pr.index = pr.index+1
        local msg = {id = pr.id,pos = pr.pos}
        scene:broadCast("MonsterPosRet",msg)
        -- print(pr.id.." 前往: "..vec3.toString(self.param.dst).." 当前"..vec3.toString(pr.pos))
    end

    function rb:arriveDst()
        local pr = self.param
        if pr.index == #pr.paths or #pr.paths == 0 then
            return true
        end
        return false
    end

    function rb:clearPath()
        self.param.paths = nil
    end

    function rb:findRandomDst()
        -- print("寻找一个随机点")
        self.param.dst = self.posSet:random()
    end

    function rb:havePath()
        if self.param.paths == nil then
            return false
        end
        return true
    end


    return rb
end




return module