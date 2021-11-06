local serviceCore = require "serviceCore"
local bagObj = require "bag.bagObj"
local csv = require "bag/csv"
local skynet = require "skynet"
local bagCode = {
    BAG_SUCCESS = 1,
    BAG_FAIL = 0,
    success = 1
}
local bag_data
local command = {}
local json = require "json"
local logExt = function(...)

end
local function hash(k)
    if k == nil then
        return "hash:0"
    end
    return "hash:"..k
end
function command.init(_bag_data)
    bag_data = _bag_data
    bag_data.bags = {}
    bag_data.bagQueryApi = require "bag/bagQueryApi"
    bag_data.bagQueryApi.init()
    csv.read("CommonItem.csv")
    return true
end

function command.addBag(_id,_character_id)
    if not bag_data.bags[_id] then
        bag_data.bags[_id] = bagObj.createBag(_character_id)
    end
end

local function resetCD(_character_id)
    local bag =  bag_data.bags[_character_id]
    local grids = bag.grids
    for k,v in pairs(grids) do
        if v.grid_num ~= 0 then
            if bag.cdMap[hash(v.item_id)] == nil then
                bag.cdMap[hash(v.item_id)] = 0
            end
            v.cd = bag.cdMap[hash(v.item_id)]
        end
    end
end

local function getMaxOverlapNum(item_id)

    return tonumber(csv.get(item_id).overlayLimit)
end

local function getConfigCD(item_id)
    
    return 5000
end

local function clearGrid(grid)
    grid.item_id = -1
    grid.grid_num = 0
    grid.cd = 0
end

local function copy(origin,dst)
    origin.item_id = dst.item_id
    origin.grid_num = dst.grid_num
    origin.cd = dst.cd

end
local function swap(origin,dst)
    local cache = {}
    copy(cache,origin)
    copy(origin,dst)
    copy(dst,cache)
end

local function findEmptyGrid(bag)

    for k=0,29 do
        local v = bag.grids["hash:"..k]
        if v.item_id == 0 then
            return v
        end
    end
    return nil
end
-- 查找背包里面所有相同item_id的，未满的格子
local function findEqualItemIDGrid(bag,item_id,maxOverlapNum)    
    local tb = {}
    local rest = 0
    for k,v in pairs(bag.orderGrids) do
        if v.item_id == item_id and v.grid_num < maxOverlapNum then
            table.insert(tb,v)
            rest = rest +(maxOverlapNum - v.grid_num)
        end
    end
    local collect = {}
    collect.data = tb
    collect.rest = rest
    return collect
end

----------------------------------------------内部服务调用---------------------------------------

-- 登录时初始化
function command.bagInit(_character_id)

    local data = bag_data.bagQueryApi.pull(_character_id)
    local bag = bagObj.createBag(_character_id)
    bag_data.bags[_character_id] = bag
    for k = 0,bag.maxgrids-1 do
        bag.grids[hash(k)] = bagObj.createGrid(k)
        table.insert(bag.orderGrids,bag.grids[hash(k)])
    end

    local flag = 0
    for i,v in pairs(data) do
        local k = i - 1
        v.grid_num = tonumber(v.grid_num)
        v.item_id = tonumber(v.item_id)
        v.cd = tonumber(v.cd)
        copy(bag.grids[hash(k)],v)
        bag.cdMap[hash(v.item_id)] = v.cd
        flag = flag+1
    end
    if flag == 0 then
        command.BagAddRequest(_character_id,{item_id = 1001,origin_id = 0,num = 1})
    end

end
-- 离线操作
function command.bagOffline(_character_id)
    print("off line :".._character_id)
    bag_data.bagQueryApi.push(_character_id,bag_data.bags[_character_id])
    bag_data.bags[_character_id] = nil
end
----------------------------------------------对客户端暴露的接口---------------------------------------
-- pull
function command.BagPullRequest(_character_id)
    assert(bag_data.bags[_character_id],"bag pull failed")
    local tb = {}
    for k,v in pairs(bag_data.bags[_character_id].grids) do
        if v.grid_num ~= 0 then
            table.insert(tb,v)
        end
    end
    local rtb = {}
    rtb.code = bagCode.BAG_SUCCESS
    rtb.grid_info_list =tb
    
    rtb.open_timestamp = skynet.time()*1000
    return rtb
end
-- 拖拽
function command.BagDragRequest(_character_id,proto)
    local dst = hash(proto.dst_id)
    local origin = hash(proto.origin_id)
    print("dst: "..dst.." origin:"..origin)
    local bag =  bag_data.bags[_character_id]
    local grids = bag.grids
    if dst == origin then
        return false
    end
    if grids[origin] then
        local tp = {}
        copy(tp,grids[origin])
        if grids[dst] then
            if grids[dst].grid_num ~= 0 then

                print("overlap process..........."..grids[dst].item_id.." "..grids[origin].item_id)
                if grids[dst].item_id == grids[origin].item_id then
                    local sum = grids[dst].grid_num + grids[origin].grid_num
                    -- 大于可堆叠数量的处理
                    local maxOverlapNum = getMaxOverlapNum(grids[dst].item_id)
                    
                    if sum> maxOverlapNum then
                        if grids[dst].grid_num == maxOverlapNum then
                            swap(grids[origin],grids[dst])
                        else
                            grids[dst].grid_num = maxOverlapNum
                            grids[origin].grid_num = sum - maxOverlapNum
                        end
                    else
                        grids[dst].grid_num = sum
                        clearGrid(grids[origin])
                    end
                else
                    swap(grids[origin],grids[dst])
                end
            else
                copy(grids[dst],grids[origin])
                clearGrid(grids[origin])
            end
        else
            copy(grids[dst],grids[origin])
            clearGrid(grids[origin])
        end
    else
        serviceCore.log("warning: the client wanto swap a empty grids")
    end
    resetCD(_character_id)
    local tb = {}
    tb.code = bagCode.success
    tb.origin = grids[origin]
    tb.dst = grids[dst]
    return tb
end
-- 拆分
function command.BagSplitRequest(_character_id,proto)
    local origin = hash(proto.origin_id)
    local dst = hash(proto.dst_id)
    local bag =  bag_data.bags[_character_id]
    local grids = bag.grids
    if grids[origin] then
        if grids[dst].grid_num ==0 and proto.dst_id < bag.maxgrids then
            copy(grids[dst],grids[origin])
            grids[dst].grid_num = proto.dst_num
            grids[origin].grid_num = proto.origin_num
        else
            error("grids is not empty")
            return false
        end
    else
        serviceCore.log("warning: the client wanto swap a empty grids")
    end
    resetCD(_character_id)
    local tb = {}
    tb.code = bagCode.success
    tb.origin = grids[origin]
    tb.dst = grids[dst]
    
    return tb
end
-- 丢弃
function command.BagDiscardRequest(_character_id,proto)
    local origin = hash(proto.origin_id)
    local bag =  bag_data.bags[_character_id]
    local grids = bag.grids
    -- 做日志记录
    clearGrid(grids[origin])
    resetCD(_character_id)
    local tb = {}
    tb.code = bagCode.success
    tb.origin = grids[origin]
    return tb
end
-- 添加
function command.BagAddRequest(_character_id,proto)


    local origin = hash(proto.origin_id)
    local bag =  bag_data.bags[_character_id]
    local grids = bag.grids
    local tb = {}
    -- 已经生效的格子
    local theOperationGrids = {}
    local maxOverlapNum = getMaxOverlapNum(proto.item_id)
   
    print("max over lap = "..maxOverlapNum)
    local collect = findEqualItemIDGrid(bag,proto.item_id,maxOverlapNum)
    local curNum = proto.num
    for k,v in pairs(collect.data) do
        if curNum >0 then
            local maxRestCapacity = maxOverlapNum - v.grid_num
            table.insert(theOperationGrids,v)
            if curNum <=maxRestCapacity then
                v.grid_num = curNum+ v.grid_num
                curNum = 0
                break
            else
                v.grid_num = maxOverlapNum
                curNum =curNum - maxRestCapacity
            end
        end
    end

    print("rest : "..curNum)
    -- 如果还剩余，说明还需要新的格子去存
    if curNum>0 then
        local requiredGridsNum = math.ceil(curNum/maxOverlapNum)
        
        for k = 1,requiredGridsNum do
            print(json.encode(bag))
            local grid = findEmptyGrid(bag)

            print(json.encode(grid))
            if grid then
                grid.item_id = proto.item_id 
                table.insert(theOperationGrids,grid)
                if curNum<maxOverlapNum then
                    grid.grid_num = curNum
                else
                    grid.grid_num = maxOverlapNum
                    curNum = curNum - maxOverlapNum
                end
            end
        end
    end
    resetCD(_character_id)
    tb.origin = theOperationGrids
    tb.code = bagCode.success
    return tb
end
-- 整理
function command.BagPackUpRequest(_character_id,proto)

    local from = {}
    local bag =  bag_data.bags[_character_id]
    local grids = bag.grids
    for k,v in pairs(proto.from) do
        local grid_key = hash(v)
        from[k] = {}
        copy(from[k],grids[grid_key])
        clearGrid(grids[grid_key])
    end
    for k,v in pairs(proto.to) do
        local grid_key = hash(v)
        copy(grids[grid_key],from[k])
    end
    local to = {}
    local sameItemGrids = {}
    -- 将所有相同的格子合并，这个时候混空余出空格子o(n)
    for k,v in pairs(bag.orderGrids) do
        if v.grid_num ~= 0 then
            if not sameItemGrids[v.item_id] then
                sameItemGrids[v.item_id] = {}
            end
            table.insert(sameItemGrids[v.item_id],v)
        end
    end
    -- 分别将同种格子合并o(n)
    for k,v in pairs(sameItemGrids) do
        local tp = v
        if #tp > 1 then
            local lastGrid = tp[1]
            local maxOverlapNum = getMaxOverlapNum(lastGrid.item_id)
            for k =2,#tp do
                local preGrid = tp[k]
                local sum = lastGrid.grid_num + preGrid.grid_num
                if sum >maxOverlapNum then
                    lastGrid.grid_num = maxOverlapNum
                    preGrid.grid_num = sum - maxOverlapNum
                    lastGrid = preGrid
                else
                    lastGrid.grid_num = sum
                    clearGrid(preGrid)
                end
            end
        end
    end
    -- 拷贝所有格子数据，清空所有格子，按照拷贝的数据重写格子内容o(n)
    local content_order = {}
    for k,v in pairs(bag.orderGrids) do
        if v.grid_num ~= 0 then
            local tp = {}
            content_order[#content_order+1] =tp
            copy(tp,v)
        end
        clearGrid(v)
    end
    resetCD(_character_id)
    -- 回写背包中格子内容 o(n)
    for k,v in pairs(content_order) do
        copy(bag.orderGrids[k],content_order[k])
        table.insert(to,bag.orderGrids[k])
    end
    local tb = {}
    tb.code =  bagCode.success
    tb.to = to
    return tb
end
-- 使用
function command.BagUseRequest(_character_id,proto)

    local origin = hash(proto.origin_id)

    local bag =  bag_data.bags[_character_id]
    local grids = bag.grids
    
    local originGrid = grids[origin]

    local item_id = originGrid.item_id
    local preCd = bag.cdMap[hash(item_id)]
    local nowTime = skynet.time()*1000
    print(preCd.." "..nowTime.." "..getConfigCD(item_id))
    local dif = (nowTime - preCd)
    if dif < getConfigCD(item_id) then
        local tb = {}
        tb.code = bagCode.BAG_FAIL
        return tb
    end
    bag.cdMap[hash(item_id)] = nowTime
    if originGrid.grid_num > 0 then
        originGrid.grid_num = originGrid.grid_num-1
    else
        serviceCore.log("warning: the grid is empty its should be client problem")
    end
    -- 处理cd 事件 o(n)
    resetCD(_character_id)
    --清空格子
    local originSet = {}
    for k,v in pairs(grids) do
        if v.item_id == item_id then
            table.insert(originSet,v)
        end
    end
    if grids[origin].grid_num == 0 then
        clearGrid(grids[origin])
    end
    local tb = {}
    tb.code = bagCode.BAG_SUCCESS
    tb.origin = originSet
    return tb
end

return command