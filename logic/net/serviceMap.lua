
local map = {}


--loginService
map["LoginReq"] = {{name = "loginService",ret = 1}}
map["LoginOutReq"] = {{name = "loginService",ret = 0}}
map["RegisterReq"] = {{name = "loginService",ret = 1}}

map["DelayReq"] = {{name = "testService",ret = 1}}
map["DelayReq"] = {{name = "testService",ret = 1}}

--sceneService
map["MoveReq"] = {{name = "sceneService",ret = 1}}
map["QryScenesReq"] = {{name = "sceneService",ret = 1}}
map["EnterSceneReq"] = {
    {name = "sceneService",ret = 1},
    {name = "loginService",ret = 0}
}

map["QryScenePlayerReq"] = {{name = "sceneService",ret = 1}}
map["SetPosReq"] = {{name = "sceneService",ret = 1}}
map["SetRotReq"] = {{name = "sceneService",ret = 1}}
map["TestFindPathReq"] ={{name = "sceneService",ret = 1}}

map["PlayerAtkMonsterReq"] ={{name = "sceneService",ret = 0}}

--sceneService.Bro
map["TestBro"] = {{name = "sceneService",ret = 2}}
map["MoveAnimBro"] ={{name = "sceneService",ret = 2}}

--connection

--skillService
map["SkillTestReq"] = {{name = "skillService",ret = 2}}
map["SkillReleaseReq"] = {{name = "skillService",ret = 2}}
map["SkillAnimReq"] = {{name = "skillService",ret = 2}}

--skillService.Bro
map["SkillElementChangeBro"] = {{name = "skillService",ret = 2}}
map["SkillReleaseBro"] = {{name = "skillService",ret = 2}}
map["SkillDestroyBro"] = {{name = "skillService",ret = 2}}
map["SkillAniBro"] = {{name = "skillService",ret = 2}}

map["SkillAniReleaseBro"] = {{name = "skillService",ret = 2}}

--bagService

map["BagPullReq"] = {{name = "bagService",ret = 1}}
map["BagDragReq"] = {{name = "bagService",ret = 1}}
map["BagPackUpReq"] = {{name = "bagService",ret = 1}}
map["BagUseReq"] = {{name = "bagService",ret = 1}}
map["BagAddReq"] = {{name = "bagService",ret = 1}}
map["BagDiscardReq"] ={{name = "bagService",ret = 1}}


--statuService
map["SetHpReq"] = {{name = "statuService",ret = 2}}
map["SetMpReq"] = {{name = "statuService",ret = 2}}

--pointService

map["EqsInsertReq"] = {{name = "pointService",ret = 1}}
map["EqsDeleteReq"] = {{name = "pointService",ret = 1}}
map["EqsSelectAllReq"] = {{name = "pointServce",ret = 1}}


return map