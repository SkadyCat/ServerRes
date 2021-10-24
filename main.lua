local skynet = require "skynet"
skynet.start(function()

    skynet.newservice("connection")
    skynet.newservice("loginService")
    skynet.newservice("testService")
    skynet.newservice("sceneService")
--     local watchdog = skynet.newservice("watchdog")
-- skynet.call(watchdog, "lua", "start", {
-- 	port = 9201,
-- 	maxclient = 100,
-- 	nodelay = true,
-- })


    skynet.exit()
end)