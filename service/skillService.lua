local skynet = require "skynet"
require "skynet.manager"
local skillMap = require "skill/skillMap"
local json = require "json"
local scene = require "scene/sceneHelp"
local mysql = require "mysql/mysqlHelp"
local command = {}

function command.SkillTestReq(msg)

    return "SkillTestRet",msg
end

function command.SkillBroadcast(head,msg)
    scene.broadCast(msg.uid,head.."Ret",msg)
end
local index = 0
function command.SkillReleaseReq(msg)
    msg.index = index
    index = index+1
    local item = skillMap.get(msg.uid)
    item:setCD(msg.type)
    scene.broadCast(msg.uid,"SkillReleaseBroRet",msg)
end

function command.SkillAnimReq(msg)
    local id = msg.type
    local uid = msg.uid
    local item = skillMap.get(uid)
    local ans = item:judgeCD(id)
    msg.cdRet = ans
    scene.broadCast(msg.uid,"SkillAnimRet",msg)
end
--内部调用
function command.init(uid,scene)
    
    skillMap.new(uid,scene)
end






skynet.start(function()
    skynet.dispatch("lua", function(session, source, cmd, ...)
        
        local prefix = ""
        if #cmd > 4 then
            prefix = string.sub(cmd,#cmd - 2,#cmd)
        end
        if prefix == "Bro" then
            command.SkillBroadcast(cmd,...)
            skynet.retpack(nil)
            return
        end
        local f = command[cmd]
        local head,msg = f(...)
        
        skynet.retpack(head,msg)
    end)
    skynet.register("skillService")
end)