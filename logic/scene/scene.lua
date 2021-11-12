
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
        scene.monsterMap = robot.new(scene,10)
        function scene:enter(uid,userInfo)
            self.playerMap[uid] = item.new(uid,self,userInfo)
            self.broadCastMap[uid] = true
            

            local uInfo = self.playerMap[uid]
            scene:broadCast("BornPlayerRet",{id =uid,nickName = uInfo.userInfo.nickName,userAcc = uInfo.userInfo.userAcc})
            
            -- 获取场景的怪物信息
            for k,v in pairs(self.monsterMap) do
                scene:send(uid,"MonsterGenRet",{id = k,pos = v.model.param.pos})
            end
            --获取场景的玩家信息
            for k,v in pairs(self.playerMap) do
                uInfo = v
                print(json.encode(uInfo.userInfo))
                scene:send(uid,"BornPlayerRet",{id =v.uid,nickName = uInfo.userInfo.nickName,userAcc = uInfo.userInfo.userAcc})
            end

            -- 广播当前场景中的玩家消息
            -- scene:broadCast("QryScenePlayerRet",{ids = scene:queryPlayers()})

            --各个服务的场景初始化

            --状态服务的初始化
            local serviceName = "statuService"
            local serviceAddress =  harbor.queryname(serviceName)
            skynet.send(serviceAddress,"lua","onEnterScene",uid,self.broadCastMap)
            
            


        end

        function scene:leave(uid)
            self.playerMap[uid] = nil
            self.broadCastMap[uid] = nil
            local num = 0
            for k,v in pairs(self.playerMap) do
                num = num+1
            end
            print("player leave "..uid.."rest: "..num)
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
