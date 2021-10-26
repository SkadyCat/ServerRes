
local userApi = require "login/user"
local userMap = {}

function userMap.add(uid,acc)
    local nUser = userApi.new(uid,acc)
    nUser:init()
    userMap[uid] = nUser
    return nUser
end

function userMap.remove(uid)
    userMap[uid] = nil
end

function userMap.get(uid)
    return userMap[uid]
end

return userMap