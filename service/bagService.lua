local skynet = require "skynet"
require "skynet.manager"

local harbor = require "skynet.harbor"
local bag_data = require "bag/bag_data"
local bag = require "bag/bag"
local running
local json = require "json"

local command = {}
local command = {}
-- 内部调用
function command.start()
	running = bag.init(bag_data)
	return running
end

function command.stop()
	if running then
		running = false
		bag.clear()
		serviceCore.async(serviceCore.exit)
	end
end

function command.bagInit(character_id)
    bag.bagInit(character_id)
end

function command.bagOffline(character_id)
    bag.bagOffline(character_id)
end

-- 外部接口
function command.BagPullReq(msg)
    local data = bag.BagPullRequest(msg.user_acc,msg)
    return "BagPullRet",data
end

function command.BagDragReq(msg)
    local tb = bag.BagDragRequest(msg.user_acc,msg)
    print(json.encode(tb))
    return "BagDragRet",tb
end

function command.BagSplitReq(self,character_id,proto)

    -- local tb = bag.BagSplitRequest(character_id,proto)
    -- if tb then
    --     serviceCore.reply("BagSplitRet",tb)
    -- end
end

function command.BagDiscardReq(msg)
    local tb = bag.BagDiscardRequest(msg.user_acc,msg)
    return "BagDiscardRet",tb
end

function command.BagAddReq(msg)
    local tb = bag.BagAddRequest(msg.user_acc,msg)
    return "BagAddRet",tb
end

function command.BagUseReq(msg)
    local tb = bag.BagUseRequest(msg.user_acc,msg)
    print(json.encode(tb)..json.encode(msg))
    return "BagUseRet",tb
end

function command.BagPackUpReq(self,character_id,proto)
    -- local tb = bag.BagPackUpRequest(character_id,proto)
    -- if tb then
    --     serviceCore.reply("BagPackUpRet",tb)
    -- end
end

skynet.start(function()
    command.start()
    skynet.dispatch("lua", function(session, source, cmd, ...)
        local f = command[cmd]
        local head,msg = f(...)
        if head ~= nil then
            skynet.retpack(head,msg)
        end
    end)
    skynet.register("bagService")
end)