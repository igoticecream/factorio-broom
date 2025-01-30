local this = {}

---@param area BoundingBox
---@return ChunkPosition[]
function this.area_to_chunks(area)
    -- Calculate the chunk coordinates for the corners
    local start_chunk = {
        x = math.floor(area.left_top.x / 32),
        y = math.floor(area.left_top.y / 32)
    }
    local end_chunk = {
        x = math.floor(area.right_bottom.x / 32),
        y = math.floor(area.right_bottom.y / 32)
    }

    -- Initialize array to store chunk positions
    local chunks = {}

    -- Iterate through all chunks in the area
    for x = start_chunk.x, end_chunk.x do
        for y = start_chunk.y, end_chunk.y do
            table.insert(chunks, { x = x, y = y })
        end
    end

    return chunks
end

---@param chunks ChunkPosition[]
---@return BoundingBox
function this.chunks_to_area(chunks)
    -- Find min and max coordinates
    local min_x = math.huge
    local min_y = math.huge
    local max_x = -math.huge
    local max_y = -math.huge

    -- Iterate through chunks to find bounds
    for _, chunk in pairs(chunks) do
        min_x = math.min(min_x, chunk.x)
        min_y = math.min(min_y, chunk.y)
        max_x = math.max(max_x, chunk.x)
        max_y = math.max(max_y, chunk.y)
    end

    -- Convert chunk coordinates to tile coordinates and return as BoundingBox
    return {
        left_top = {
            x = min_x * 32,
            y = min_y * 32
        },
        right_bottom = {
            x = (max_x + 1) * 32,
            y = (max_y + 1) * 32
        }
    }
end

return this
