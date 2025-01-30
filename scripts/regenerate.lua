local area_util = require("util.area")

--- @param surface LuaSurface The surface on which the regeneration will occur
--- @param area BoundingBox The bounding box area to be regenerated
local function regenerate_area(surface, area)
    local chunks = area_util.area_to_chunks(area)
    local chunks_area = area_util.chunks_to_area(chunks)

    surface.destroy_decoratives { area = chunks_area }
    surface.regenerate_decorative(nil, chunks)
end

local this = {}

this.events = {
    --- @param event EventData.on_player_alt_selected_area
    [defines.events.on_player_alt_selected_area] = function(event)
        if event.item == "broom-selection-tool" then
            regenerate_area(event.surface, event.area)
        end
    end,
}

return this
