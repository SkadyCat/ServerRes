
local serviceCore = require "serviceCore"
local aoi = require "LAoi"
local space
local index = 0
local infos = {"离开","进入"}
local flags = {}
local scene
local function hash(id)

    return "hash:"..id
end

local function aoiMsg(watcher,marker,flag)

    local msg = {}
    msg.watcher = watcher
    msg.marker = marker
    msg.flag = flag
    return msg
end
local command = {}
command.msgQueue = {}

local function callBack(watcher,marker,flag)

    if flags[hash(watcher)] == nil then
        return
    end
    if flag == 1 then
        if  flags[hash(watcher)][hash(marker)] == false or  flags[hash(watcher)][hash(marker)] == nil then
            flags[hash(watcher)][hash(marker)] = true
            print(index..":"..watcher.."--"..marker.."--"..infos[2])
            -- scene:broadCast("MonsterHateRet",{monster_id = 3,player_id = 4})
            table.insert(command.msgQueue,aoiMsg(watcher,marker,flag))
        end
    else
        if flags[hash(watcher)][hash(marker)] == true then
            table.insert(command.msgQueue,aoiMsg(watcher,marker,flag))
            print(index..":"..watcher.."--"..marker.."--"..infos[1])
            flags[hash(watcher)][hash(marker)] = false
        end
        
    end
    index = index+ 1

end

function command.init(sc)
    space = aoi.new()
    aoi.cb(space,callBack)
    scene = sc
end

function command.add(mode,x,y)
    local index = aoi.add(space,mode,x,y)
    print("加入的index = "..index)
    if mode == "w" or mode == "wm" then
        flags[hash(index)] = {}
    end
    return index
end

function command.remove(id)
    aoi.remove(space,id)
end

function command.update(id,x,y)
    if id== nil then
        return
    end
    -- print("update,,,"..id)
    aoi.update(space,id,x,y)
end




return command