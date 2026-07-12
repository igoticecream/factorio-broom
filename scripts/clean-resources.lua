local target_entities = {
    'resource'
}

--- @param surface LuaSurface The surface from which resources will be removed
--- @param area BoundingBox The bounding box area where resources will be removed
--- @param preferences table The initiating player's cleanup preferences
local function clean_resources(surface, area, preferences)
    -- Remove resources
    for _, entity in ipairs(surface.find_entities_filtered { area = area, type = target_entities }) do
        if not preferences.resources_exclude[entity.name] and entity.valid and entity.can_be_destroyed() then
            entity.destroy()
        end
    end
end

--- @param surface LuaSurface The selected surface
--- @param area BoundingBox The selected area
--- @param preferences table The initiating player's cleanup preferences
return function(surface, area, preferences)
    if preferences.resources then
        clean_resources(surface, area, preferences)
    end
end
