local serviceCore = require "serviceCore"


local bagObj = {}

function bagObj.createGrid(id)

    local tp = {
        item_id = -1,
        grid_id = id,
        grid_num = 0,
        cd = 0
    }
    return tp
end

function bagObj.createBag(_character_id)
    local tp = {
        character_id = _character_id,
        grids = {},
        cdMap = {},
        orderGrids = {},
        maxgrids = 30
    }
    return tp
end

return bagObj