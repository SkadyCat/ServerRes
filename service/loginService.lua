local skynet = require "skynet"
require "skynet.manager"

local harbor = require "skynet.harbor"
local userMap = require "login/userMap"
local mysql = require "common/mysql"
local json = require "json"
local code = require "common/code"
local db = nil
local command = {}

function command.LoginReq(msg)
    
    --初始化信息
    local info = mysql.execute(mysql.event.user_info.login,msg.user_acc)
    print(json.encode(info))
    local tp = {}
    if #info ~= 0 then
        data = info[1]
        if data.user_pwd ~= msg.user_pwd then
            
            tp.code = code.FAILED
            tp.info = "pwd err"
            return "LoginRet",tp
        end
        tp.nick_name = data.nick_name
        tp.user_acc = data.user_acc
    else
        tp.code = code.FAILED
        tp.info = "no acc"
        return "LoginRet",tp
    end

    -- 查询当前所在场景
    local user = userMap.add(msg.uid,"123")
    user.user_acc = msg.user_acc
    -- 场景服务初始化
    -- local serviceName = "sceneService"
    -- local serviceAddress =  harbor.queryname(serviceName)
    -- skynet.send(serviceAddress,"lua","init",user.uid,user.sceneName)
    
    -- 技能服务初始化
    local serviceName = "skillService"
    local serviceAddress =  harbor.queryname(serviceName)
    skynet.send(serviceAddress,"lua","init",msg.uid)
    
    -- 背包服务初始化

    --状态服务初始化
    serviceName = "statuService"
    serviceAddress =  harbor.queryname(serviceName)
    skynet.send(serviceAddress,"lua","init",msg.uid)
    
    --初始化背包信息
    local serviceName = "bagService"
    local serviceAddress =  harbor.queryname(serviceName)
    skynet.send(serviceAddress,"lua","bagInit",msg.user_acc)

            
    tp.code = 1
    tp.info = "Login Success"
    return "LoginRet",tp
    
end




function command.LoginOutReq(msg)

    local userInfo = userMap[msg.uid]
    --通知场景，清空角色信息
    local serviceName = "sceneService"
    local serviceAddress =  harbor.queryname(serviceName)
    skynet.send(serviceAddress,"lua","leaveScene",msg)

    --关闭角色服务
    serviceName = "connection"
    serviceAddress = harbor.queryname(serviceName)
    skynet.send(serviceAddress,"lua","close",msg.uid)

    serviceName = "bagService"
    serviceAddress = harbor.queryname(serviceName)
    skynet.send(serviceAddress,"lua","bagOffline",userInfo.user_acc)

end

function command.RegisterReq(msg)

    print("注册请求...................")
    local data = mysql.execute(mysql.event.user_info.register,msg.user_acc,msg.user_pwd,msg.nick_name)
    local rBack = {}
    if not data.err then
        rBack.code = code.SUCCESS
        rBack.info = "注册成功"


    

    else
        rBack.code = code.FAILED
        rBack.info = "注册失败"
    end
    return "RegisterRet",rBack
end


skynet.start(function()
    db = mysql.connect()

    skynet.dispatch("lua", function(session, source, cmd, ...)
        local f = command[cmd]
        local head,msg = f(...)
        if head ~= nil then
            skynet.retpack(head,msg)
        end
    end)
    skynet.register("loginService")
end)