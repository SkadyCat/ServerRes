
local bf = require "BufferReader"
local proto = require "proto"
local function new()
    local bufferItem = {}
    bufferItem.buffer = bf.new()
    function bufferItem.read(buf)
        bf.read(bufferItem.buffer,buf,#buf)
    end
    function bufferItem.getProto()
        local head,msg = bf.getProto(bufferItem.buffer)
        return head,msg
    end
    function bufferItem.table2buf(tb)
        local buf = ""
        for i,j in pairs(tb) do
            buf = buf .. string.char(j)
        end
        return buf
    end
    function bufferItem.encode(name,msg)
        local msgBuf = proto.encode(name,msg)
        return bf.encode(name,#name,msgBuf,#msgBuf)
    end
    function bufferItem.decode()
        local head,msg = bufferItem.getProto()
        if head == nil then
            return false
        end
        local msgTb = proto.decode(head,msg)
        return head,msgTb
    end
    function bufferItem.log(buf)
        bf.log(buf,#buf)
    end
    return bufferItem
end
return new

