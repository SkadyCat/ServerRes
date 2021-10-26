

local module = {}

function module.new(uid,acc)
    local tp = {}
    tp.uid = uid
    tp.acc = acc
    function tp:init()
        -- 从数据库中查询数据
        --如果没有则向数据库中初始化
        tp.sceneName = "TestLab"
    end
    
    return tp
end


return module