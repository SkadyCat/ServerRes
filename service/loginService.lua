local skynet = require "skynet"
require "skynet.manager"

local harbor = require "skynet.harbor"
local userMap = require "login/userMap"

local command = {}

function command.LoginReq(msg)
    
    --初始化信息
    -- 查询当前所在场景
    local user = userMap.add(msg.uid,"123")
    -- 场景服务初始化
    local serviceName = "sceneService"
    local serviceAddress =  harbor.queryname(serviceName)
    skynet.send(serviceAddress,"lua","init",user.uid,user.sceneName)
    
    -- 技能服务初始化
    local serviceName = "skillService"
    local serviceAddress =  harbor.queryname(serviceName)
    skynet.send(serviceAddress,"lua","init",msg.uid)
    
    -- 背包服务初始化


    
end



function command.LoginOutReq(msg)
    --通知场景，清空角色信息
    local serviceName = "sceneService"
    local serviceAddress =  harbor.queryname(serviceName)
    skynet.send(serviceAddress,"lua","leaveScene",msg)

    --关闭角色服务
    serviceName = "connection"
    serviceAddress = harbor.queryname(serviceName)
    skynet.send(serviceAddress,"lua","close",msg.uid)

        
end
skynet.start(function()
    skynet.dispatch("lua", function(session, source, cmd, ...)
        local f = command[cmd]
        local head,msg = f(...)
        if head ~= nil then
            skynet.retpack(head,msg)
        end
    end)
    skynet.register("loginService")
end)