
local userApi = require "login/user"
local userMap = {}

function userMap.add(uid,info)
    userMap[uid] = info
    return info
end

function userMap.remove(uid)
    userMap[uid] = nil
end

function userMap.get(uid)
    return userMap[uid]
end

return userMap