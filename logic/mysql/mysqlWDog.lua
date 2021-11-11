
local timer = require "timerCore"
local mysql = require "mysql/mysqlHelp"


local module = {}
local index = 0
function update()
    mysql.log("mysql runner --- "..index);
    index = index+1
end
function module.init()
    timer.start(update,1000)
end


return module