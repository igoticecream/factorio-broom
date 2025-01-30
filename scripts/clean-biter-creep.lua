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

local this = {}

this.events = {
    --- @param event EventData.on_player_selected_area
    [defines.events.on_player_selected_area] = function(event)
        if event.item == "broom-selection-tool" and settings.global["broom-biter-creep"].value then
            clean_biter_creep(event.surface, event.area)
        end
    end,
}

return this
