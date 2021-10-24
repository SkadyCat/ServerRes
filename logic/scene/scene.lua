
local skynet = require "skynet"
local harbor = require "skynet.harbor"
local item = require "scene/item"

local json = require "json"
local module = {}
    function module.new(sceneName)
        local scene = {}
        scene.sceneName = scene
        scene.playerMap = {}
        scene.broadCastMap = {}
        function scene:enter(uid)
            self.playerMap[uid] = item.new(uid)
            self.broadCastMap[uid] = true
            scene:broadCast("NewUserEnterBroRet",{id =uid})
        end

        function scene:leave(uid)
            self.playerMap[uid] = false
            self.broadCastMap[uid] = false
            scene:broadCast("UserLeaveBroRet",{id =uid})
        end
        
        function scene:broadCast(head,msg)
            local serviceName = "connection"
            local serviceAddress =  harbor.queryname(serviceName)
            skynet.send(serviceAddress,"lua","broadCast",self.broadCastMap,head,msg)
        end

        function scene:query(uid)
            return self.playerMap[uid] 
        end

        function scene:queryPlayers()
            local tb = {}
            for k,v in pairs(self.playerMap) do
                if v then
                    table.insert(tb,k)
                end
            end
            return tb
        end

        function scene:setPos(uid,msg)
            self.playerMap[uid]:setPos(msg.pos)
            msg.uid = nil
            msg.id = uid
            print(skynet.time().."  "..msg.timeStamp)
            scene:broadCast("SetPosRet",msg)
        end

        
        return scene
    end
    
return module
