local nav = require("NavCore")
local prefix = "/home/magic/Server/res/static/navmesh/"
local module = {}
    local suffix = ".bin"
    function module.new(name)
        local path = prefix..name..suffix
        local naver = {}
        naver.buf = nav.load(path)
        function naver:findPath(bpos,epos)
            return nav.findPath(self.buf,bpos.x,bpos.y,bpos.z
            ,epos.x,epos.y,epos.z)
        end
        function naver:setSpeed(v)
            nav.setSpeed(v)
        end
        return naver
    end
-- print("hello world")
-- local naver = module.new("F:\\UnityProj\\NavMesh\\navmesh.bin")
-- local ans = naver:findPath({x =1.36 ,y =-0.89 ,z =2.55 },{x = -4.12,y = -1.321063,z = 0.29})
-- print(#ans)
return module


