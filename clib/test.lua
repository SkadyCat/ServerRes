local aoi = require "LAoi"

-- local path = "F:\\UnityProj\\Third24\\Assets\\Skill\\Config\\Config.csv"
local infos = {"leave","enter"}
-- local data = config.read(path)
local function test(watcher,marker,flag)
    -- body
    print("watcher: "..watcher.."marker: "..marker.."flag: "..infos[flag+1])


end
local space = aoi.new()
aoi.cb(space,test)
print("register...")
local p1 = aoi.add(space,"wm",0,0)
local p2 = aoi.add(space,"wm",0,0)

aoi.update(space,p2,10.1,0)
aoi.update(space,p2,9.9,0)
aoi.update(space,p2,9,0)
aoi.update(space,p2,4,4)

-- aoi.update(space,p1,4,4)