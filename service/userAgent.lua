local skynet = require "skynet"
local userApi = require "net/user"
local user = nil

local command = {}

function command.init(uid)
    user = userApi.new(uid)
end

function command.close(uid)
    user:close()
    skynet.exit()
end

function command.send(name,msg)
    user:send(name,msg)
end

skynet.start(function()
    skynet.dispatch("lua", function(session, source, cmd, ...)
        local f = command[cmd]
        if f ~= nil then
            local head = f(...)
            skynet.retpack(head)
        end
    end)
end)