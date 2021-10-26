
local tb = {}
local json = require "json"

function tb.new(x,y,z)

    local vec = {}
    vec.x = x
    vec.y = y
    vec.z = z



    return vec

end

function tb.random(range)
    local tp = tb.new(0,0,0)
    tp.x = math.random(range)
    tp.y = math.random(range)
    tp.z = math.random(range)
    return tp
end
function tb.dis(v1,v2)
    local tx = v1.x - v2.x
    local ty = v1.y - v2.y
    local tz = v1.z - v2.z
    tx = tx*tx
    ty = ty*ty
    tz = tz*tz
    local dis = math.sqrt(tx+ty+tz)
    return dis
end

function tb.toString(v1)
    return json.encode(v1)
end

function tb.sub(v1,v2)
    return tb.new(v1.x - v2.x,v1.y - v2.y,v1.z - v2.z) 
end
function tb.plus(v1,v2)
    return tb.new(v1.x + v2.x,v1.y + v2.y,v1.z + v2.z)
end
function tb.divc(v1,c)
    return tb.new(v1.x/c,v1.y/c,v1.z/c) 
end

function tb.mulc(v1,c)
    return tb.new(v1.x*c,v1.y*c,v1.z*c) 
end

function tb.norm(v1)
    local dis = tb.dis(v1,tb.new(0,0,0))
    return tb.new(v1.x/dis,v1.y/dis,v1.z /dis)
end

return tb