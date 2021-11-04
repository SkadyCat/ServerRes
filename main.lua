local skynet = require "skynet"
skynet.start(function()

    skynet.newservice("connection")
    skynet.newservice("loginService")
    skynet.newservice("testService")
    skynet.newservice("sceneService")
    skynet.newservice("skillService")
    skynet.newservice("statuService")
    skynet.newservice("bagService")
    skynet.exit()
end)