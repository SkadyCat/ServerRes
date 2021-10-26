
local prefix = "/home/magic/Server/res/static/btree/"
local suffix = ".ai"

local function readFile(fileName)
    local f = assert(io.open(fileName,'r'))
    local content = f:read('*all')
    f:close()
    return content
end

local module = {}

function module.new(name,model)
    local tp = {}
    tp.treeApi = require "scene/ai/behaviorTree"
    local str = readFile(prefix..name..suffix)
    tp.treeApi:ctor(str)
    function tp:run()
        self.treeApi:behave(model)
    end
    return tp
end

return module
