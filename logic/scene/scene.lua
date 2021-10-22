
local module = {}
    local playerApi = require "scene/player"
    function module.new(sceneName)
        local scene = {}
        scene.sceneName = scene
        scene.playerMap = {}

        function scene:enter(uid)
            self.playerMap[uid] = playerApi.new(uid)
        end
        function scene:leave(uid)
            self.playerMap[uid] = nil
        end

        function scene:broadCast(name,msg)
            for k,v in pairs(self.playerMap) do
                v:write(name,msg)
            end
        end
        
        return scene
    end
    
    

    
    
return module
