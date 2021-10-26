
local map = {}


--loginService
map["LoginReq"] = {name = "loginService",ret = 0}
map["LoginOutReq"] = {name = "loginService",ret = 0}


map["RegisterReq"] = {name = "registerService",ret = 0}
map["DelayReq"] = {name = "testService",ret = 1}
map["DelayReq"] = {name = "testService",ret = 1}

--sceneService
map["MoveReq"] = {name = "sceneService",ret = 1}
map["QryScenesReq"] = {name = "sceneService",ret = 1}
map["EnterSceneReq"] = {name = "sceneService",ret = 1}
map["QryScenePlayerReq"] = {name = "sceneService",ret = 1}
map["SetPosReq"] = {name = "sceneService",ret = 1}
map["SetRotReq"] = {name = "sceneService",ret = 1}
map["TestFindPathReq"] = {name = "sceneService",ret = 1}


--sceneService.Bro
map["TestBro"] = {name = "sceneService",ret = 2}

--connection

--skillService
map["SkillTestReq"] = {name = "skillService",ret = 2}

--skillService.Bro
map["SkillElementChangeBro"] = {name = "skillService",ret = 2}

return map