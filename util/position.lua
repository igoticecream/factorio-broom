local this = {}

--- @param pos MapPosition|TilePosition
--- @return ChunkPosition
function this.to_chunk(pos)
    if pos.x then
        return { x = math.floor(pos.x / 32), y = math.floor(pos.y / 32) }
    else
        return { math.floor(pos[1] / 32), math.floor(pos[2] / 32) }
    end
end

--- @param pos ChunkPosition
--- @return TilePosition
function this.from_chunk(pos)
    if pos.x then
        return { x = pos.x * 32, y = pos.y * 32 }
    else
        return { pos[1] * 32, pos[2] * 32 }
    end
end

return this
