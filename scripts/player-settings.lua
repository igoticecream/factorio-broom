local DEFAULTS = {
    trees = false,
    rocks = false,
    rocks_action = "remove",
    cliffs = false,
    resources = false,
    nuclear = false,
    biter_creep = false,
    decoratives = false,
    decoratives_action = "remove",
    corpses = false,
    corpses_exclude_biter = false,
    corpses_exclude_scorchmark = false,
    corpses_exclude_stump = false,
    corpses_exclude_remnants = false,
}

local function default_settings()
    local settings = {}
    for key, value in pairs(DEFAULTS) do
        settings[key] = value
    end
    return settings
end

local this = {}

--- @param player_index uint
--- @return table settings
this.get = function(player_index)
    storage.broom_settings = storage.broom_settings or {}
    local player_settings = storage.broom_settings[player_index]
    if not player_settings then
        player_settings = default_settings()
        storage.broom_settings[player_index] = player_settings
    end
    return player_settings
end

--- @param player_index uint
--- @return table settings
this.reset = function(player_index)
    storage.broom_settings = storage.broom_settings or {}
    local settings = default_settings()
    storage.broom_settings[player_index] = settings
    return settings
end

this.on_init = function()
    storage.broom_settings = {}
end

this.on_configuration_changed = function()
    storage.broom_settings = storage.broom_settings or {}
    -- Backfill keys added by newer versions into settings persisted by older saves
    for _, player_settings in pairs(storage.broom_settings) do
        for key, value in pairs(DEFAULTS) do
            if player_settings[key] == nil then
                player_settings[key] = value
            end
        end
    end
end

this.events = {
    [defines.events.on_player_removed] = function(event)
        if storage.broom_settings then
            storage.broom_settings[event.player_index] = nil
        end
    end,
}

return this
