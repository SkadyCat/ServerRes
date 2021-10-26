
local prefix = "/home/magic/Server/res/static/eqs/"
local suffix = ".eqs"
local json = require "json"
local function readFile(fileName)
    local f = assert(io.open(fileName,'r'))
    local content = f:read('*all')
    f:close()
    return content
end


local module = {}
function module.new(name)
    local eqs = {}
    local str = readFile(prefix..name..suffix)
    local tp = json.decode(str)
    eqs.data = tp.list
    print("tp.."..json.encode( eqs.data[1]))
    eqs.len = #tp.list
    function eqs:get(id)
        return self.data[id]
    end

    function eqs:random()
        return self.data[math.random(eqs.len)]
    end

    return eqs
end

return module

