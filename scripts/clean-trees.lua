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

--- @param surface LuaSurface The surface on which trees will be healed
--- @param area BoundingBox The bounding box area where trees will be healed
--- @param only_unpolluted boolean Heal only trees on pollution-free chunks
local function heal_trees(surface, area, only_unpolluted)
    -- Restore trees to full health and regrow their foliage
    for _, entity in ipairs(surface.find_entities_filtered { area = area, type = target_entities }) do
        if entity.valid and (not only_unpolluted or surface.get_pollution(entity.position) == 0) then
            if entity.health then
                entity.health = entity.max_health
            end
            -- Dead-tree prototypes have no variations and reject stage writes
            pcall(function()
                entity.tree_stage_index = 1
                entity.tree_gray_stage_index = 0
            end)
        end
    end
end

--- @param surface LuaSurface The selected surface
--- @param area BoundingBox The selected area
--- @param preferences table The initiating player's cleanup preferences
return function(surface, area, preferences)
    if not preferences.trees then
        return
    end
    if preferences.trees_action == "remove" then
        clean_trees(surface, area)
    elseif preferences.trees_action == "heal" then
        heal_trees(surface, area, false)
    elseif preferences.trees_action == "heal_unpolluted" then
        heal_trees(surface, area, true)
    end
end
