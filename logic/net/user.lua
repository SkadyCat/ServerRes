
local skynet = require "skynet"
local socket = require "skynet.socket"
local timer = require "timerCore"
require "skynet.manager"
local harbor = require "skynet.harbor"
local serviceMap = require "net/serviceMap"
local bf = require "buffer"
local json = require "json"
local module = {}
    function module.new(uid)
        local user = {}
        user.uid = uid
        user.buffer = bf()
        user.closeFlag = true
        user.buf = ""
        function user.echo()
            local id = user.uid
            socket.start(id)
            user:send("ConnectRet",{id = id})
            while user.closeFlag do
                local str = socket.read(id)
                if true then
                    if str then
                        user.buffer.read(str)
                        while true do
                            local head,msg = user.buffer.decode()
                            if not head then
                                break
                            end
                            local tb = serviceMap[head]
                            local serviceName = tb.name
                            local serviceAddress =  harbor.queryname(serviceName)
                            
                            if msg == "#" then
                                msg = {}
                                msg.uid = id
                            else
                                msg.uid = id
                            end

                            if tb.ret == 0 then
                                skynet.send(serviceAddress,"lua",head,msg)
                            elseif tb.ret == 1 then 
                                local retHead,retMsg = skynet.call(serviceAddress,"lua",head,msg)
                                if retMsg then
                                    if retMsg.uid ~= nil then
                                        retMsg.uid = nil
                                    end
                                    -- local retBuf = user.buffer.encode(retHead,retMsg)
                                    -- socket.write(user.uid,retBuf)
                                    user:send(retHead,retMsg)
                                    -- user.buf = user.buf..retBuf
                                end

                            elseif tb.ret == 2 then
                                --Bro类型的数据
                                local retHead,retMsg = skynet.send(serviceAddress,"lua",head,msg)

                            end
                        end
                    else
                        socket.close(id)
                        user.closeFlag = false
                    end
                end
            end
            print("end echo ->"..id)
        end

        function user:close()
            self.closeFlag = true
            socket.close(self.uid)
        end
        
        function user.update()
            -- if #user.buf > 0 then
            --     socket.write(user.uid,user.buf)
            --     user.buf = ""
            -- end
        end
        
        function user:send(name,msg)
            -- print(name..json.encode(msg))
            local tBuf = self.buffer.encode(name,msg)
            -- self.buf = self.buf .. tBuf
            socket.write(self.uid,tBuf)
        end
        skynet.fork(user.echo)
        -- timer.start(user.update,1)
        return user

    end



return module