local skynet = require "skynet"
require "skynet.manager"
local command = {}
function command.test()
    print("its a test func")
end

skynet.start(function()
    print("im register service");
    skynet.dispatch("lua", function(session, source, cmd, ...)
        local f = command[cmd]
        f(...)
    end)
    skynet.register("loginService")
end)