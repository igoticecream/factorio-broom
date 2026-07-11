local target_entities = {
    'corpse'
}

--- @param surface LuaSurface The surface from which corpses will be removed
--- @param area BoundingBox The bounding box area where corpses will be removed
--- @param preferences table The initiating player's cleanup preferences
local function clean_corpses(surface, area, preferences)
    -- Remove corpses
    for _, entity in ipairs(surface.find_entities_filtered { area = area, type = target_entities }) do
        local skip = false

        if preferences.corpses_exclude_biter and string.find(entity.name, "-corpse") then skip = true end
        if preferences.corpses_exclude_scorchmark and string.find(entity.name, "-scorchmark") then skip = true end
        if preferences.corpses_exclude_stump and string.find(entity.name, "-stump") then skip = true end
        if preferences.corpses_exclude_remnants and string.find(entity.name, "-remnants") then skip = true end

        if not skip and entity.valid and entity.can_be_destroyed() then
            entity.destroy()
        end
    end
end

--- @param surface LuaSurface The selected surface
--- @param area BoundingBox The selected area
--- @param preferences table The initiating player's cleanup preferences
return function(surface, area, preferences)
    if preferences.corpses then
        clean_corpses(surface, area, preferences)
    end
end
