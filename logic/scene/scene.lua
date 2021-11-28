
local skynet = require "skynet"
local harbor = require "skynet.harbor"
local item = require "scene/item"
local navApi = require "scene/nav"
local json = require "json"
local robot = require "scene/ai/robot"
local timer = require "timerCore"
local vec3 = require "vec3"

local module = {}
    function module.new(sceneName)
        local scene = {}
        scene.sceneName = scene
        scene.playerMap = {}
        scene.broadCastMap = {}
        scene.nav = navApi.new(sceneName)
        scene.aoiMap = {}
        scene.aoi = require "scene/aoi"
        scene.queryApi = require "scene/sceneQuery"
        scene.aoi.init(scene)
        scene.queryApi.init(scene)
        function scene:enter(uid,userInfo)
            self.playerMap[uid] = item.new(uid,self,userInfo)
            self.broadCastMap[uid] = true
            local uInfo = self.playerMap[uid]
            
            -- 从数据库中获取玩家在场景中的位置信息
            local info = self.queryApi.onEnterScene(uid)
            uInfo.pos.x = 0
            uInfo.pos.y = 0
            uInfo.pos.z = 0

            -- BornPlayerRet
            scene:broadCast("BornPlayerRet",{id =uid,nickName = uInfo.userInfo.nickName,userAcc = uInfo.userInfo.userAcc,playerPos = uInfo.pos})
            for k,v in pairs(self.playerMap) do
                uInfo = v
                print(json.encode(uInfo.userInfo))
                scene:send(uid,"BornPlayerRet",{id =v.uid,nickName = uInfo.userInfo.nickName,userAcc = uInfo.userInfo.userAcc,playerPos = uInfo.pos})
            end
            
            
            --各个服务的场景初始化
            for k,v in pairs(self.monsterMap) do
                scene:send(uid,"MonsterGenRet",{id = k,pos = v.model.param.pos})
            end
            --状态服务的初始化
            local serviceName = "statuService"
            local serviceAddress =  harbor.queryname(serviceName)
            skynet.send(serviceAddress,"lua","onEnterScene",uid,self.broadCastMap)
            
            local aoiIndex = self.aoi.add("wm",uInfo.pos.x,uInfo.pos.z)
            self.playerMap[uid].aoiIndex = aoiIndex
            self.aoiMap[aoiIndex] = {id = uid,type = "player"}
            
           
        end
        function scene:init()
            -- 获取场景的怪物信息
            for k,v in pairs(self.monsterMap) do
                v.aoiIndex =  self.aoi.add("w",v.model.param.pos.x,v.model.param.pos.z)
                self.aoiMap[v.aoiIndex] = {id = k,type = "monster"}
            end
        end

        function scene:getUser(uid)
            return self.playerMap[uid]
        end
        function scene:leave(uid)
            local uInfo = self.playerMap[uid]
            self.queryApi.onLeaveScene(uid)
            self.playerMap[uid] = nil
            self.broadCastMap[uid] = nil
            local num = 0
            for k,v in pairs(self.playerMap) do
                num = num+1
            end
            print("player leave "..uid.."rest: "..num)
            scene:broadCast("UserLeaveBroRet",{id =uid})
            local msg = {code = "userLeave",value = uid}
            for k,v in pairs(self.monsterMap) do
                robot.update(k,msg) 
            end
            self.aoi.remove(uInfo.aoiIndex)
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

        function scene:setSpeed(v)
            self.nav:setSpeed(v)
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
            local sv = self.playerMap[uid]
            self.aoi.update(sv.aoiIndex,msg.pos.x,msg.pos.z)
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

        function scene:monsterEvent(msg)
            local tp = {code = "playerEvent",value = msg}
            robot.update(msg.id,tp)
        end
        function scene:updateAoi(id)
            local v = scene.monsterMap[id]
            self.aoi.update(v.aoiIndex,v.model.param.pos.x,v.model.param.pos.z)
        end
        function scene.update()
            robot.run()
            for k,v in pairs(scene.monsterMap) do
                scene.aoi.update(v.aoiIndex,v.model.param.pos.x,v.model.param.pos.z)
            end
            for k,v in pairs(scene.aoi.msgQueue) do
                local w = v.watcher
                local m = v.marker
                v.watcher = scene.aoiMap[w].id
                v.marker = scene.aoiMap[m].id
                v.watcherType = scene.aoiMap[w].type
                v.markerType = scene.aoiMap[m].type
                scene:broadCast("AoiRet",v)

                local msg = {code = "aoi",value = v}
                if scene.aoiMap[w].type == "monster" then
                    robot.update(scene.aoiMap[w].id,msg)
                end
            end
            scene.aoi.msgQueue = {}
        end
        scene.monsterMap = robot.new(scene,1)
        timer.start(scene.update,10)
        return scene
    end
    
return module
