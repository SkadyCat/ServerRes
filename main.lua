local skynet = require "skynet"

require "skynet.manager"
local harbor = require "skynet.harbor"
local json = require "json"
local proto = require "proto"
local pb = require "protobuf"
pb.register_file "/home/magic/Server/res/protos/pb/Person.pb"
pb.register_file "/home/magic/Server/res/protos/pb/Account.pb"


local a = require "BufferReader"
-- 启动服务(启动函数)
local command = {}
function command.log(...)
    for k,v in pairs({...}) do
        if type(v) == "table" then

            print("logs key = "..k..": "..json.encode(v));
        else
            print("logs key = "..k..": "..v);
        end
    end
end

function command.toBytes(buf) 
    t={}
    for i=1,string.len(buf) do
        table.insert(t,string.byte(string.sub(buf,i,i)))
    end
    return t;
end
function command.logBytes(buf) 
    t={}
    
    for i=1,string.len(buf) do
        table.insert(t,string.byte(string.sub(buf,i,i)))
    end
    command.log(t);
    
end

local function frombt(bt)
    local buf = ""
    for i,j in pairs(bt) do
        buf = buf .. string.char(j)
    end

    return buf

end

skynet.start(function()
    local address = skynet.newservice("service/loginService")
    name = harbor.queryname("loginService")
    local buffer = a.new()

    -- stringbuffer = pb.encode("LoginReq",
    -- {
   	--     name = "23333333",psd = "lkkkk",id = 3333,cd = 2333123123
    --     -- id = 3333
   	-- })

    stringbuffer = proto.encode("LoginReq",    {
        name = "23333333",psd = "lkkkk",id = 3333,cd = 2333123123
     -- id = 3333
    })
    ts = proto.decode("LoginReq",stringbuffer)


    print(ts.name.."<<<<")
    local b = {0,8,76,111,103,105,110,82,101,113,0,21,20,10,5,108,107,107,107,107,18,8,50,51,51,51,51,51,51,51,24,133,26}
    local buf = ""
    for i,j in pairs(b) do
        buf = buf .. string.char(j)
    end
    a.read(buffer,buf,#buf)
    local protoName = a.getString(buffer)
    local data = a.getMsg(buffer)
    print("--"..protoName)
    a.log(buffer,data,#data)
    skynet.exit()
end)