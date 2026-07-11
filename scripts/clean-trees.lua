local target_entities = {
    'tree',
}

--- @param surface LuaSurface The surface from which trees will be removed
--- @param area BoundingBox The bounding box area where trees will be removed
local function clean_trees(surface, area)
    -- Remove trees
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
    if preferences.trees then
        clean_trees(surface, area)
    end
end
