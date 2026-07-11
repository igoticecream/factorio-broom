local regenerate = require("scripts.regenerate")

-- Prototype data is immutable for the session, so the list is computed once on first use
local artificial_tiles

--- @return string[] tiles_name Names of the tiles in the "artificial-tiles" subgroup
local function get_artificial_tiles()
    if not artificial_tiles then
        artificial_tiles = {}
        for name, tile in pairs(prototypes.tile) do
            if tile.subgroup.name == "artificial-tiles" then
                table.insert(artificial_tiles, name)
            end
        end
    end
    return artificial_tiles
end

--- @param surface LuaSurface The surface from which decoratives will be removed
--- @param area BoundingBox The bounding box area where decoratives will be removed
--- @param artificial_only boolean Whether to limit removal to artificial tiles
local function clean_decoratives(surface, area, artificial_only)
    -- Remove decoratives
    if artificial_only then
        for _, tile in ipairs(surface.find_tiles_filtered { area = area, name = get_artificial_tiles() }) do
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

--- @param surface LuaSurface The selected surface
--- @param area BoundingBox The selected area
--- @param preferences table The initiating player's cleanup preferences
return function(surface, area, preferences)
    if not preferences.decoratives then
        return
    end
    if preferences.decoratives_action == "regenerate" then
        regenerate.regenerate_area(surface, area)
    else
        clean_decoratives(surface, area, preferences.decoratives_action == "artificial")
    end
end
