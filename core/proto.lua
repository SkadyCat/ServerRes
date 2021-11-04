
local protoPath = "/home/magic/Server/res/static/protos/pb/"
local pb = require "protobuf" 

local function register(name)
    pb.register_file(protoPath..name..".pb")
end
local function init()
    register("Account")
    register("Test")
    register("Scene")
    register("Skill")
    register("Statu")
    register("Bag")
end
init()

local command = {}

function command.encode(name,tb)
    return pb.encode(name,tb)
end
function command.decode(name,bytes)
    return pb.decode(name,bytes)
end
return command