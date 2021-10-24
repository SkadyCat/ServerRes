
local map = {}


--loginService
map["LoginReq"] = {name = "loginService",ret = 1}


map["RegisterReq"] = {name = "registerService",ret = 0}
map["DelayReq"] = {name = "testService",ret = 1}
map["DelayReq"] = {name = "testService",ret = 1}

--sceneService
map["MoveReq"] = {name = "sceneService",ret = 1}
map["QryScenesReq"] = {name = "sceneService",ret = 1}
map["EnterSceneReq"] = {name = "sceneService",ret = 1}
map["QryScenePlayerReq"] = {name = "sceneService",ret = 1}
map["SetPosReq"] = {name = "sceneService",ret = 1}
--sceneService.Bro
map["TestBro"] = {name = "sceneService",ret = 2}

--connection
map["LoginOutReq"] = {name = "connection",ret = 0}


return map