local target_entities = {
    'corpse'
}

--- @param surface LuaSurface The surface from which corpses will be removed
--- @param area BoundingBox The bounding box area where corpses will be removed
local function clean_corpses(surface, area)
    -- Get corpses preferences
    local exclude_biter      = settings.global["broom-corpses-exclude-biter"].value
    local exclude_scorchmark = settings.global["broom-corpses-exclude-scorchmark"].value
    local exclude_stump      = settings.global["broom-corpses-exclude-stump"].value
    local exclude_remnants   = settings.global["broom-corpses-exclude-remnants"].value

    -- Remove corpses
    for _, entity in ipairs(surface.find_entities_filtered { area = area, type = target_entities }) do
        local skip = false

        if exclude_biter and string.find(entity.name, "-corpse") then skip = true end
        if exclude_scorchmark and string.find(entity.name, "-scorchmark") then skip = true end
        if exclude_stump and string.find(entity.name, "-stump") then skip = true end
        if exclude_remnants and string.find(entity.name, "-remnants") then skip = true end

        if not skip and entity.valid and entity.can_be_destroyed() then
            entity.destroy()
        end
    end
end

local this = {}

this.events = {
    --- @param event EventData.on_player_selected_area
    [defines.events.on_player_selected_area] = function(event)
        if event.item == "broom-selection-tool" and settings.global["broom-corpses"].value then
            clean_corpses(event.surface, event.area)
        end
    end,
}

return this
