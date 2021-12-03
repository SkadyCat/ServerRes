local skynet = require "skynet"
require "skynet.manager"
local harbor = require "skynet.harbor"
local statuMap = require "statu/statuMap"
local scene = require "scene/sceneHelp"
local user = require "net/userHelp"

local command = {}

--外部接口
function command.SetHpReq(msg)
    local statu = statuMap.get(msg.uid)
    statu:setHp(msg.hp)
    scene.broadCast(msg.uid,"SetHpRet",msg)
end

function command.SetMpReq(msg)
    local statu = statuMap.get(msg.uid)
    statu:setMp(msg.mp)
    scene.broadCast(msg.uid,"SetMpRet",msg)
end

--内部调用

function command.init(uid)
    statuMap.new(uid)

end

function command.onRegister(uid)
    
end

function command.onEnterScene(uid,players)
    local role = statuMap.get(uid)
    local tp = {
        hp = role.statu.hp,
        mp = role.statu.mp,
        maxMp = role.statu.maxMp,
        maxHp = role.statu.maxHp        
    }
    tp.uid = uid
    scene.broadCast(uid,"StatuInitRet",tp)

    for k,v in pairs(players) do
        role = statuMap.get(k)
        tp = {
            hp = role.statu.hp,
            mp = role.statu.mp,
            maxMp = role.statu.maxMp,
            maxHp = role.statu.maxHp        
        }
        tp.uid = k
        user.send(uid,"StatuInitRet",tp)
    end
end

function command.onLeave(uid)
    statuMap.remove(uid)
end

skynet.start(function()
    skynet.dispatch("lua", function(session, source, cmd, ...)
        local f = command[cmd]
        local head,msg = f(...)
        if head ~= nil then
            skynet.retpack(head,msg)
        end
    end)
    skynet.register("statuService")
end)