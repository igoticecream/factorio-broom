local player_settings = require("scripts.player-settings")

-- Cleaning tasks applied to every broom selection; each checks its own preferences
local cleaners = {
    require("scripts.clean-decoratives"),
    require("scripts.clean-biter-creep"),
    require("scripts.clean-corpses"),
    require("scripts.clean-nuclear"),
    require("scripts.clean-resources"),
    require("scripts.clean-rocks"),
    require("scripts.clean-trees"),
    require("scripts.clean-cliffs"),
}

--- @param event EventData.on_player_selected_area|EventData.on_player_alt_selected_area
local function on_selected_area(event)
    if event.item ~= "broom-selection-tool" then
        return
    end
    local preferences = player_settings.get(event.player_index)
    for _, clean in ipairs(cleaners) do
        clean(event.surface, event.area, preferences)
    end
end

local this = {}

this.events = {
    [defines.events.on_player_selected_area] = on_selected_area,
    [defines.events.on_player_alt_selected_area] = on_selected_area,
}

return this
