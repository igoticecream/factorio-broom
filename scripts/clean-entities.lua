--- @param surface LuaSurface The surface from which entities will be removed
--- @param area BoundingBox The selected area
--- @param preferences table The initiating player's cleanup preferences
--- @param player LuaPlayer The player who made the selection
return function(surface, area, preferences, player)
    if player.controller_type ~= defines.controllers.editor then
        return
    end

    if not preferences.entities then
        return
    end

    if not preferences.entities_exclude_flames then
        for _, entity in ipairs(surface.find_entities_filtered { area = area, name = "fire-flame" }) do
            if entity.valid and entity.can_be_destroyed() then
                entity.destroy()
            end
        end
    end

    if not preferences.entities_exclude_enemies then
        for _, entity in ipairs(surface.find_entities_filtered { area = area, type = { "unit", "segmented-unit" }, force = "enemy" }) do
            if entity.valid and entity.can_be_destroyed() then
                entity.destroy()
            end
        end

        for _, entity in ipairs(surface.find_entities_filtered { area = area, type = "turret", force = "enemy" }) do
            if entity.name:sub(-12) == "-worm-turret" and entity.valid and entity.can_be_destroyed() then
                entity.destroy()
            end
        end
    end

    if not preferences.entities_exclude_spawners then
        for _, entity in ipairs(surface.find_entities_filtered { area = area, type = "unit-spawner" }) do
            if entity.valid and entity.can_be_destroyed() then
                entity.destroy()
            end
        end
    end
end
