local timer = require("timer");


local timerCore = {}
local id
function timerCore.start(func,gap)
    timer:new();
    timer:init(gap);
    id = timer:register(1,function()
        func() 
    end,true);
end

function timerCore.endTimer()
    timer:unregister(id)
end

return timerCore