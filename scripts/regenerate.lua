local area_util = require("util.area")

-- How far (in tiles) outside the regenerated chunks decoratives are preserved
local MARGIN = 8

local this = {}

--- @param surface LuaSurface The surface on which the regeneration will occur
--- @param area BoundingBox The bounding box area to be regenerated
this.regenerate_area = function(surface, area)
    local chunks = area_util.area_to_chunks(area)
    local chunks_area = area_util.chunks_to_area(chunks)

    -- Snapshot decoratives anchored just outside the regenerated chunks; both the area
    -- destroy and the regeneration can clobber them across the chunk border
    local snapshot = {}
    local outer_area = {
        left_top = { x = chunks_area.left_top.x - MARGIN, y = chunks_area.left_top.y - MARGIN },
        right_bottom = { x = chunks_area.right_bottom.x + MARGIN, y = chunks_area.right_bottom.y + MARGIN },
    }
    for _, found in ipairs(surface.find_decoratives_filtered { area = outer_area }) do
        local position = found.position
        if position.x < chunks_area.left_top.x or position.x >= chunks_area.right_bottom.x
            or position.y < chunks_area.left_top.y or position.y >= chunks_area.right_bottom.y then
            table.insert(snapshot, { name = found.decorative.name, position = position, amount = found.amount })
        end
    end

    -- An edge lying exactly on a tile boundary also selects the tile beyond it, which
    -- would destroy a one-tile strip in neighbouring chunks that never gets regenerated
    chunks_area.right_bottom.x = chunks_area.right_bottom.x - 1 / 256
    chunks_area.right_bottom.y = chunks_area.right_bottom.y - 1 / 256

    surface.destroy_decoratives { area = chunks_area }
    surface.regenerate_decorative(nil, chunks)

    -- Restore the band outside the chunks to its pre-regeneration state; destroying
    -- first prevents doubling wherever the band survived
    for _, decorative in ipairs(snapshot) do
        surface.destroy_decoratives { position = decorative.position, name = decorative.name }
    end
    surface.create_decoratives { check_collision = false, decoratives = snapshot }
end

return this
