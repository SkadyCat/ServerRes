

local csv = require "Csvparse"
local prefix = "/home/magic/Server/res/static/config/"
local sufix = ".csv"
local json = require "json"
local module = {}
function module.new(name)
    local function hash(id) 

        return ""..id
    end
    local tp = {}
    local data = csv.read(prefix..name..sufix)
    tp.dic = {}
    for k,v in pairs(data) do
        print(json.encode(v))
        tp.dic[hash(v.id)] = v
    end


    function tp:get(id) 
        return self.dic[hash(id)]
    end

    return tp
end


return module