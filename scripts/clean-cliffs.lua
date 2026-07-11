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

--- @param surface LuaSurface The selected surface
--- @param area BoundingBox The selected area
--- @param preferences table The initiating player's cleanup preferences
return function(surface, area, preferences)
    if preferences.cliffs then
        clean_cliffs(surface, area)
    end
end
