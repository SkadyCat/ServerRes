
local mysql = require "skynet.db.mysql"
local json = require "json"
local module = {}
local event = {}
function module.connect()
    local db=mysql.connect({
		host="127.0.0.1",
		port=3306,
		database="magic",
		user="magic",
		password="123",
                charset="utf8mb4",
		max_packet_size = 1024 * 1024,
		on_connect = on_connect
	})
    module.db = db

    return db
end
module.event = event
function module.execute(stmt,...)
	local res = module.db:execute(stmt,...)
    return res
end

function module.loginEvent()
    local loginEvent = {}
    loginEvent = {}
    loginEvent.register =  module.db:prepare("insert into user_info(user_acc,user_pwd,nick_name) values(?,?,?)")
    loginEvent.login =   module.db:prepare("select * from user_info where user_acc = ?")
    loginEvent.getUserInfo = module.db:prepare("select * from user_info where user_acc = ?")
    loginEvent.updateScene = module.db:prepare("update user_info set scene = ? where user_acc = ?")
    return loginEvent
end

function module.bagEvent()
    local bagEvent = {}
    bagEvent.initBag =  module.db:prepare("insert into bag(character_id,grid_id,item_id,grid_num,cd) values(?,?,?,?,?)")
    bagEvent.pullBag = module.db:prepare("select * from bag where character_id = ?")
    bagEvent.updateBag = module.db:prepare("update bag set item_id = ?,grid_num = ?,cd = ? where character_id = ? and grid_id = ?")
    return bagEvent
end

function module.sceneEvent()
    local sv = {}
    sv.init = module.db:prepare("insert into scene(user_acc,x,y,z) values(?,?,?,?)")
    sv.update = module.db:prepare("update scene set x = ?,y = ?,z = ? where user_acc = ?")
    sv.select = module.db:prepare("select * from scene where user_acc = ?")
    return sv
end


function module.logEvent()
    local tb = {}
    tb.log = module.db:prepare("insert into log(info,time) values(?,?)")
    return tb
end

function module.skillEvent()
    local tb = {}
    tb.init = module.db:prepare("insert into skill_config(sub_index,skill_index,user_acc) values(?,?,?)")
    tb.select = module.db:prepare("select * from skill_config where user_acc = ?")
    return tb
end

function module.statuEvent()
    local tb = {}
    tb.insert =  module.db:prepare("insert into statu(user_acc,hp,mp,max_hp,max_mp,atk,defense,dodge,atk_speed,crit,crit_chance,efire,eground,ewind,ewater,speed,equip_const_atk,equip_coe_atk,equip_coe_def,equip_const_def,skill_const_def,skill_const_atk,coins) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)")
    tb.select = module.db:prepare("select * from statu where user_acc = ?")
    return tb
end
function module.eqsEvent()
    local tb = {}
        tb.insert = module.db:prepare("insert into eqs(type,x,y,z,scene) values(?,?,?,?,?)")
        tb.selectAll = module.db:prepare("select * from eqs where scene = ?")
        tb.delete = module.db:prepare("delete from eqs where main_index = ?")
        tb.newID = module.db:prepare("select * from eqs order by main_index DESC limit 1;")
    return tb
end
function module.init()
    local evt = {}
    evt.bagEvent = module.bagEvent()
    evt.sceneEvent = module.sceneEvent()
    evt.loginEvent = module.loginEvent()
    evt.logEvent = module.logEvent()
    evt.skillEvent = module.skillEvent()
    evt.eqsEvent = module.eqsEvent()
    evt.statuEvent= module.statuEvent()
    module.evt = evt
end


return module