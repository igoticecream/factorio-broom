local area_util = require("util.area")

local this = {}

--- @param surface LuaSurface The surface on which the regeneration will occur
--- @param area BoundingBox The bounding box area to be regenerated
this.regenerate_area = function(surface, area)
    local chunks = area_util.area_to_chunks(area)
    local chunks_area = area_util.chunks_to_area(chunks)

    surface.destroy_decoratives { area = chunks_area }
    surface.regenerate_decorative(nil, chunks)
end

return this
