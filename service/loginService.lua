local skynet = require "skynet"
require "skynet.manager"

local harbor = require "skynet.harbor"
local userMap = require "login/userMap"

local sender = require "net/userHelp"
local mysql = require "mysql/mysqlHelp"
local json = require "json"
local code = require "common/code"
local command = {}

function command.LoginReq(msg)
    
    local tp = {}

    if userMap.get(msg.user_acc) ~= nil then
        tp.code = code.FAILED
        tp.info = "have login"
        return "LoginRet",tp
    end
    --初始化信息
    local info = mysql.query("loginEvent","login",msg.user_acc)
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
    local user = userMap.add(msg.user_acc,info[1])
    user.user_acc = msg.user_acc

    -- 技能服务初始化
    local serviceName = "skillService"
    local serviceAddress =  harbor.queryname(serviceName)
    skynet.send(serviceAddress,"lua","init",msg.uid)
    
    --状态服务初始化
    serviceName = "statuService"
    serviceAddress =  harbor.queryname(serviceName)
    skynet.send(serviceAddress,"lua","init",msg.uid)
    
    --初始化背包信息
    local serviceName = "bagService"
    local serviceAddress =  harbor.queryname(serviceName)
    skynet.send(serviceAddress,"lua","bagInit",msg.user_acc)

    -- 反馈技能信息
    local infos = mysql.query("skillEvent","select",msg.user_acc)
    print(json.encode(infos))
    local tb = {}
    tb.configs = {}
    for k,v in pairs(infos) do
        local info = {id = v.skill_index,index = v.sub_index}
        table.insert(tb.configs,info)
    end
    sender.send(msg.uid,"SkillInfoRet",tb)

    tp.code = 1
    tp.info = "Login Success"
    return "LoginRet",tp
    
end




function command.LoginOutReq(msg)

    if msg.user_acc == nil then
        --关闭链接
        serviceName = "connection"
        serviceAddress = harbor.queryname(serviceName)
        skynet.send(serviceAddress,"lua","close",msg.uid)
        return
    end

    local userInfo = userMap.get(msg.user_acc)
    --通知场景，清空角色信息
    local serviceName = "sceneService"
    local serviceAddress =  harbor.queryname(serviceName)
    skynet.send(serviceAddress,"lua","leaveScene",msg)

    --关闭链接
    serviceName = "connection"
    serviceAddress = harbor.queryname(serviceName)
    skynet.send(serviceAddress,"lua","close",msg.uid)

    serviceName = "bagService"
    serviceAddress = harbor.queryname(serviceName)
    skynet.send(serviceAddress,"lua","bagOffline",userInfo.user_acc)
    
    userMap.remove(msg.user_acc)
end

function command.RegisterReq(msg)
    local data = mysql.query("loginEvent","register",msg.user_acc,msg.user_pwd,msg.nick_name)
    local rBack = {}
    if not data.err then
        rBack.code = code.SUCCESS
        rBack.info = "注册成功"
        -- 初始化数据库信息
        -- 初始化场景数据
        local mInfo = mysql.query("sceneEvent","init",msg.user_acc,0,0,0)
        -- 初始化背包数据
        for i = 0,29 do
            mysql.query("bagEvent","initBag",msg.user_acc,i,0,0,0)
        end

        -- 初始化技能数据
        mysql.query("skillEvent","init",1,1111,msg.user_acc)
        mysql.query("skillEvent","init",2,2222,msg.user_acc)
        mysql.query("skillEvent","init",3,3333,msg.user_acc)
        mysql.query("skillEvent","init",4,4444,msg.user_acc)
        mysql.query("skillEvent","init",5,0,msg.user_acc)
        mysql.query("skillEvent","init",6,0,msg.user_acc)
        
    else
        rBack.code = code.FAILED
        rBack.info = "注册失败"
    end
    return "RegisterRet",rBack
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