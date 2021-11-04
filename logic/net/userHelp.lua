
local skynet = require "skynet"
local harbor = require "skynet.harbor"
local module = {}

function module.send(uid,head,msg)
    local serviceName = "connection" 
    local serviceAddress =  harbor.queryname(serviceName)
    skynet.send(serviceAddress,"lua","send",uid,head,msg)
end

return module