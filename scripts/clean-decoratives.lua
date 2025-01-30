--- @param surface LuaSurface The surface from which decoratives will be removed
--- @param area BoundingBox The bounding box area where decoratives will be removed
local function clean_decoratives(surface, area)
    -- Remove decoratives
    if settings.global["broom-decoratives-only-artificial-tiles"].value then
        local tiles_name = {}
        for name, tile in pairs(prototypes.tile) do
            if tile.subgroup.name == "artificial-tiles" then
                table.insert(tiles_name, name)
            end
        end

        for _, tile in ipairs(surface.find_tiles_filtered { area = area, name = tiles_name }) do
            surface.destroy_decoratives {
                position = tile.position
            }
        end
    else
        surface.destroy_decoratives {
            area = area,
        }
    end
end

local this = {}

this.events = {
    --- @param event EventData.on_player_selected_area
    [defines.events.on_player_selected_area] = function(event)
        if event.item == "broom-selection-tool" and settings.global["broom-decoratives"].value then
            clean_decoratives(event.surface, event.area)
        end
    end,
}

return this
