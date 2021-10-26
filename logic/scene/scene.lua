
local skynet = require "skynet"
local harbor = require "skynet.harbor"
local item = require "scene/item"
local navApi = require "scene/nav"
local json = require "json"
local robot = require "scene/ai/robot"
local timer = require "timerCore"
local module = {}
    function module.new(sceneName)
        local scene = {}
        scene.sceneName = scene
        scene.playerMap = {}
        scene.broadCastMap = {}
        scene.nav = navApi.new(sceneName)
        -- print(scene.nav)
        -- print("hello world")
        scene.monsterMap = robot.new(scene,1)
        function scene:enter(uid)
            self.playerMap[uid] = item.new(uid,self)
            self.broadCastMap[uid] = true
            scene:broadCast("NewUserEnterBroRet",{id =uid})
            
            -- 广播怪物信息
            for k,v in pairs(self.monsterMap) do
                scene:send(uid,"MonsterGenRet",{id = k,pos = v.model.param.pos})
            end

            -- 广播当前场景中的玩家消息
            scene:broadCast("QryScenePlayerRet",{ids = scene:queryPlayers()})


        end

        function scene:leave(uid)
            self.playerMap[uid] = nil
            self.broadCastMap[uid] = nil
            scene:broadCast("UserLeaveBroRet",{id =uid})
        end
        
        function scene:send(uid,head,msg)
            local serviceName = "connection" 
            local serviceAddress =  harbor.queryname(serviceName)
            skynet.send(serviceAddress,"lua","send",uid,head,msg)
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
            msg.id = uid
            msg.uid = nil
            scene:broadCast("SetPosRet",msg)
        end
        function scene:setRot(uid,msg)
            self.playerMap[uid]:setRot(msg.rot)
            msg.uid = nil
            msg.id = uid
            scene:broadCast("SetRotRet",msg)
        end
        function scene:findPath(bPos,ePos)
            local tp = self.nav:findPath(bPos,ePos)
            return tp
        end
       
        function scene.update()
            robot.run()
            -- for k,v in pairs(scene.playerMap) do
            --     if v  then
            --         v:run()
            --         local ps = v:getSendPos()
            --         if ps then
            --             local msg = {id = v.uid,pos = ps}
                       
            --         end
            --     end
            -- end
        end
        timer.start(scene.update,5)
        return scene
    end
    
return module
