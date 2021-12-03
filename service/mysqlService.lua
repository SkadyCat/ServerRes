local skynet = require "skynet"
require "skynet.manager"
local mysql = require "mysql/mysql"
local watchDog = require "mysql.mysqlWDog"
local db = nil
local command = {}

function command.query(et,field,...)
    local rt = mysql.execute(mysql.evt[et][field],...)
    return rt
end

function command.start()


end

skynet.start(function()
    mysql.connect()
    mysql.init()
    watchDog.init()
    skynet.dispatch("lua", function(session, source, cmd, ...)
        local f = command[cmd]
        local head,msg = f(...)
        if head ~= nil then
            skynet.retpack(head,msg)
        end
    end)
    skynet.register("mysqlService")
end)