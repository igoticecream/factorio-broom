local target_entities = {
    'cliff',
}

--- @param surface LuaSurface The surface from which cliffs will be removed
--- @param area BoundingBox The bounding box area where cliffs will be removed
local function clean_cliffs(surface, area)
    -- Remove cliffs
    for _, entity in ipairs(surface.find_entities_filtered { area = area, type = target_entities }) do
        if entity.valid and entity.can_be_destroyed() then
            entity.destroy()
        end
    end
end

local this = {}

this.events = {
    --- @param event EventData.on_player_selected_area
    [defines.events.on_player_selected_area] = function(event)
        if event.item == "broom-selection-tool" and settings.global["broom-cliffs"].value then
            clean_cliffs(event.surface, event.area)
        end
    end,
}

return this
