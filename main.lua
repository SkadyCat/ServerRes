local skynet = require "skynet"
local json = require "json"
local mysql = require "mysql/mysqlHelp"
skynet.start(function()

    skynet.newservice("connection")
    skynet.newservice("loginService")
    skynet.newservice("testService")
    skynet.newservice("sceneService")
    skynet.newservice("skillService")
    skynet.newservice("statuService")
    skynet.newservice("bagService")
    skynet.newservice("mysqlService")
    
    local ans =  mysql.log("hello world")
    -- print(json.encode(ans))
    skynet.exit()
end)