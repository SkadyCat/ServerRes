
local skynet = require "skynet"
local harbor = require "skynet.harbor"
local json  = require "json"
local module = {}

function module.query(type,evt,...)
    local serviceName = "mysqlService" 
    local serviceAddress =  harbor.queryname(serviceName)
    local rt = skynet.call(serviceAddress,"lua","query",type,evt,...)
    return rt
end

function module.log(info)
    local date=os.date("%Y-%m-%d %H:%M:%S");
    local ans =  module.query("logEvent","log",info,date)
end

return module