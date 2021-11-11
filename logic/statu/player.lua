local vec3 = require "scene/vec3"
local proto = require "proto"

local module = {}
    local socket = require "skynet.socket"
    function module.new(uid)
        local player = {}
        player.uid = uid
        player.pos = vec3.Vector3D(0,0,0)
        player.rot = vec3.Vector3D(0,0,0)
        function player:setPos(pos)
            self.pos:setX(pos.x)
            self.pos:setY(pos.y)
            self.pos:setZ(pos.z)
        end
        
        function player:getPos()
            local tp = {x = self.pos:getX(),y = self.pos:getY(),z = self.pos:getZ()}
            return tp
        end
        
        function player:setRot(rot)
            self.rot:setX(rot.x)
            self.rot:setY(rot.y)
            self.rot:setZ(rot.z)
        end
        function player:getRot()
            local tp = {x = self.rot:getX(),y = self.rot:getY(),z = self.rot:getZ()}
            return tp
        end
        
        function player:write(name,msg)
            local rBuf = proto.encode(name,msg)
            socket.write(self.uid,rBuf)
        end

        return player
    end
return module