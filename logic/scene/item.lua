
local json = require "json"
local module = {}
    function module.new(uid,scene)
        local item = {}
        item.uid = uid
        item.pos = {x = 0,y = 0,z =0}
        item.rot = {x = 0,y = 0,z = 0,w = 0}
        item.paths = {}
        item.index = 1
        item.scene = scene
        
        function item:setPos(pos)
            self.pos = pos
        end
        function item:setRot(rot)
            self.rot = rot
        end
        function item:run()
            if #self.paths == 0 then
                return
            end
            print(self.index)
            if item.index<= #self.paths then
                self.pos = self.paths[self.index]
                self.index = self.index+1
            end
        end

        function item:getSendPos()
            if item.index == #self.paths then
                return nil
            end
            return self.pos
        end
        return item

    end

return module