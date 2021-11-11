
local mysql = require "skynet.db.mysql"
local json = require "json"
local module = {}
local event = {}
function module.connect()
    local db=mysql.connect({
		host="127.0.0.1",
		port=3306,
		database="magic",
		user="magicer",
		password="12345678a",
                charset="utf8mb4",
		max_packet_size = 1024 * 1024,
		on_connect = on_connect
	})
    module.db = db
    event.user_info = {}
    event.user_info.register = db:prepare("insert into user_info(user_acc,user_pwd,nick_name) values(?,?,?)")
    event.user_info.login =  db:prepare("select * from user_info where user_acc = ?")

    return db
end
module.event = event
function module.execute(stmt,...)
	local res = module.db:execute(stmt,...)
    -- db:stmt_close(stmt)
    return res
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
    -- sv.init = module.db:prepare("insert into scene(user_acc,x,y,z) values(?,?,?,?)")
    -- sv.pull = module.db:
    return sv
end


return module