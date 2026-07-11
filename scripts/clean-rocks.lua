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

--- @param surface LuaSurface The surface on which rocks will be healed
--- @param area BoundingBox The bounding box area where rocks will be healed
local function heal_rocks(surface, area)
    -- Restore rocks to full health so their health bar disappears
    for _, entity in ipairs(surface.find_entities_filtered { area = area, name = target_entities }) do
        if entity.valid and entity.health then
            entity.health = entity.max_health
        end
    end
end

--- @param surface LuaSurface The selected surface
--- @param area BoundingBox The selected area
--- @param preferences table The initiating player's cleanup preferences
return function(surface, area, preferences)
    if not preferences.rocks then
        return
    end
    if preferences.rocks_action == "remove" then
        clean_rocks(surface, area)
    elseif preferences.rocks_action == "heal" then
        heal_rocks(surface, area)
    end
end
