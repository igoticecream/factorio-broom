local position_util = require("util.position")
local surface_util = require("util.surface")

local target_tiles = {
    'nuclear-ground'
}
local target_entities = {
    'nuclear-smouldering-smoke-source',
    'huge-scorchmark',
}
local target_decoratives = {
    'nuclear-ground-patch'
}

--- @param surface LuaSurface The surface from which nuclear elements will be removed
--- @param area BoundingBox The bounding box area where nuclear elements will be removed
local function clean_nuclear(surface, area)
    -- Remove nuclear explosion decoratives
    surface.destroy_decoratives {
        area = area,
        name = target_decoratives
    }

    -- Remove nuclear explosion entities
    for _, entity in ipairs(surface.find_entities_filtered { area = area, name = target_entities }) do
        if entity.valid and entity.can_be_destroyed() then
            entity.destroy()
        end
    end

    -- Remove nuclear explosion tiles
    if surface.count_tiles_filtered { area = area, name = target_tiles } > 0 then
        local chunks = {}
        local tiles = surface.find_tiles_filtered {
            area = area,
            name = target_tiles
        }

        for _, tile in ipairs(tiles) do
            local chunk = position_util.to_chunk(tile.position)
            local chunk_key = ("%d,%d"):format(chunk.x, chunk.y)
            chunks[chunk_key] = chunk
        end

        surface_util.with_hidden_surface(surface.map_gen_settings, function(hidden_surface)
            for _, chunk in pairs(chunks) do
                hidden_surface.request_to_generate_chunks(position_util.from_chunk(chunk), 0)
            end

            hidden_surface.force_generate_chunk_requests()

            local new_tiles = {}

            for _, tile in ipairs(tiles) do
                local x, y = tile.position.x, tile.position.y

                local hidden_tile = hidden_surface.get_tile(x, y)
                local hidden_tile_name = hidden_tile.name

                -- Replace water tiles wil landfill
                if string.find(hidden_tile_name, "water") then
                    hidden_tile_name = "landfill"
                end

                if hidden_tile.valid then
                    table.insert(new_tiles, { name = hidden_tile_name, position = hidden_tile.position })
                end
            end
            surface.set_tiles(new_tiles, true)
        end)
    end
end

local this = {}

this.events = {
    --- @param event EventData.on_player_selected_area
    [defines.events.on_player_selected_area] = function(event)
        if event.item == "broom-selection-tool" and settings.global["broom-nuclear"].value then
            clean_nuclear(event.surface, event.area)
        end
    end,
}

return this
