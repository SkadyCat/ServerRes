local skynet = require "skynet"

require "skynet.manager"
local harbor = require "skynet.harbor"

-- 启动服务(启动函数)
skynet.start(function()
    local address = skynet.newservice("service/loginService")
    name = harbor.queryname("loginService")
    print(name)
    skynet.exit()
end)