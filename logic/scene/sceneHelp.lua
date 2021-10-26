
local skynet = require "skynet"
local harbor = require "skynet.harbor"
local module = {}

function module.broadCast(uid,head,msg)
    local serviceName = "sceneService" 
    local serviceAddress =  harbor.queryname(serviceName)
    skynet.send(serviceAddress,"lua","broadCast",uid,head,msg)
end

return module