local target_decoratives = {
    'enemy-decal-transparent',
    'enemy-decal',
    'worms-decal',
    'shroom-decal',
    'lichen-decal',
    'red-croton',
    'red-pita',
    'muddy-stump',
    -- 'dark-mud-decal',
    -- 'light-mud-decal',
}

--- @param surface LuaSurface The surface from which biter decals will be removed
--- @param area BoundingBox The bounding box area where biter decals will be removed
local function clean_biter_creep(surface, area)
    -- Remove biter decals
    surface.destroy_decoratives {
        area = area,
        name = target_decoratives
    }
end

--- @param surface LuaSurface The selected surface
--- @param area BoundingBox The selected area
--- @param preferences table The initiating player's cleanup preferences
return function(surface, area, preferences)
    if preferences.biter_creep then
        clean_biter_creep(surface, area)
    end
end
