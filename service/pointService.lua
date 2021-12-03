local skynet = require "skynet"
require "skynet.manager"
local mysql = require "mysql/mysqlHelp"
local json = require "json"
local command = {}

function command.EqsInsertReq(item)
    local msg = item.item
    mysql.query("eqsEvent","insert",msg.type,msg.x,msg.y,msg.z,msg.scene)
    local newest = mysql.query("eqsEvent","newID")
    print("insert index = "..json.encode(newest))
    msg.main_index = newest[1].main_index
    local ret= {code = 1,item = msg}
    return "EqsInsertRet",ret
end

function command.EqsSelectAllReq(msg)
    local infos = mysql.query("eqsEvent","selectAll",msg.scene)
    local ret = {items = infos}
    return "EqsSelectAllRet",ret
end

function command.EqsDeleteReq(msg)
    mysql.query("eqsEvent","delete",msg.main_index)
    local ret= {main_index = msg.main_index,code = 1}
    return "EqsDeleteRet",ret
end


skynet.start(function()
    skynet.dispatch("lua", function(session, source, cmd, ...)
        local f = command[cmd]
        local head,msg = f(...)
        if head ~= nil then
            skynet.retpack(head,msg)
        end
    end)
    skynet.register("pointService")
end)