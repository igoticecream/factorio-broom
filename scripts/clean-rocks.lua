local target_entities = {
    'huge-rock',
    'big-rock',
    'big-sand-rock',
}

-- Check Mods for Factorio Space Age
if script.active_mods['space-age'] then
    -- Add entities specific for Space Age
    table.insert(target_entities, 'huge-volcanic-rock')
    table.insert(target_entities, 'big-volcanic-rock')
    table.insert(target_entities, 'big-fulgora-rock')
end

--- @param surface LuaSurface The surface from which rocks will be removed
--- @param area BoundingBox The bounding box area where rocks will be removed
local function clean_rocks(surface, area)
    -- Remove rocks
    for _, entity in ipairs(surface.find_entities_filtered { area = area, name = target_entities }) do
        if entity.valid and entity.can_be_destroyed() then
            entity.destroy()
        end
    end
end

local this = {}

this.events = {
    --- @param event EventData.on_player_selected_area
    [defines.events.on_player_selected_area] = function(event)
        if event.item == "broom-selection-tool" and settings.global["broom-rock"].value then
            clean_rocks(event.surface, event.area)
        end
    end,
}

return this
