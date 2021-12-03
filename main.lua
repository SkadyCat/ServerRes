local skynet = require "skynet"
local json = require "json"
local mysql = require "mysql/mysqlHelp"
skynet.start(function()


    local mysqlService = skynet.newservice("mysqlService")
    skynet.newservice("pointService")


    skynet.newservice("connection")
    skynet.newservice("loginService")
    skynet.newservice("testService")
    local sceneService = skynet.newservice("sceneService")
    skynet.newservice("skillService")
    skynet.newservice("statuService")
    skynet.newservice("bagService")

    
    skynet.send(sceneService,"lua","start")
    skynet.send(mysqlService,"lua","start")
    local ans =  mysql.log("hello world")
    -- print(json.encode(ans))
    skynet.exit()
end)