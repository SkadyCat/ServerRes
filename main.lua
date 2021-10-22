local skynet = require "skynet"
skynet.start(function()

    skynet.newservice("net/connection")
    skynet.newservice("account/loginService")
    skynet.newservice("test/testService")
    skynet.newservice("scene/sceneService")
    skynet.exit()
end)