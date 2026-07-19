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
    require("scripts.clean-entities"),
}

--- @param event EventData.on_player_selected_area|EventData.on_player_alt_selected_area
local function on_selected_area(event)
    if event.item ~= "broom-selection-tool" then
        return
    end
    local preferences = player_settings.get(event.player_index)
    local player = game.get_player(event.player_index)
    if not player then
        return
    end
    for _, clean in ipairs(cleaners) do
        clean(event.surface, event.area, preferences, player)
    end
end

local this = {}

this.events = {
    [defines.events.on_player_selected_area] = on_selected_area,
    [defines.events.on_player_alt_selected_area] = on_selected_area,
}

return this
