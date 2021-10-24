

local module = {}
    function module.new(uid)
        local item = {}
        item.uid = uid
        item.pos = {x = 0,y = 0,z =0}
        item.rot = {x = 0,y = 0,z = 0,w = 0}
        
        function item:setPos(pos)
            self.pos.x = pos.x
            self.pos.y = pos.y
            self.pos.z = pos.z
        end
        return item

    end

return module