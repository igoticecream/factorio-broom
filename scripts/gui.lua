-- Settings window for the broom tool. Checkboxes read/write the runtime-global
-- mod settings, so the window stays in sync with Factorio's mod settings menu.

local FRAME_NAME = "broom_settings_frame"
local INNER_FRAME_NAME = "broom_inner_frame"
local SCROLL_NAME = "broom_settings_scroll"
local PIN_BUTTON_NAME = "broom_pin_button"
local CLOSE_BUTTON_NAME = "broom_close_button"
local CHECKBOX_PREFIX = "broom_gui_"

local OPTIONS = {
    { setting = "broom-trees" },
    { setting = "broom-rock" },
    { setting = "broom-cliffs" },
    { setting = "broom-resources" },
    { setting = "broom-nuclear" },
    { setting = "broom-biter-creep" },
    { setting = "broom-decoratives" },
    { setting = "broom-decoratives-only-artificial-tiles", indent = true },
    { setting = "broom-corpses" },
    { setting = "broom-corpses-exclude-biter",      indent = true },
    { setting = "broom-corpses-exclude-scorchmark", indent = true },
    { setting = "broom-corpses-exclude-stump",      indent = true },
    { setting = "broom-corpses-exclude-remnants",   indent = true },
}

local CHECKBOX_TO_SETTING = {}
for _, option in ipairs(OPTIONS) do
    CHECKBOX_TO_SETTING[CHECKBOX_PREFIX .. option.setting] = option.setting
end

--- @param player_index uint
--- @return boolean
local function is_pinned(player_index)
    storage.broom_gui = storage.broom_gui or { pin = {} }
    return storage.broom_gui.pin[player_index] == true
end

--- @param player LuaPlayer
--- @return LuaGuiElement? frame The settings frame, or nil if not built
local function get_frame(player)
    local frame = player.gui.screen[FRAME_NAME]
    if frame and frame.valid then
        return frame
    end
    return nil
end

--- @param frame LuaGuiElement
--- @return LuaGuiElement pin_button
local function get_pin_button(frame)
    return frame.broom_titlebar[PIN_BUTTON_NAME]
end

--- Update every checkbox from the current runtime-global settings
--- @param frame LuaGuiElement
local function refresh(frame)
    local scroll = frame[INNER_FRAME_NAME][SCROLL_NAME]
    for _, option in ipairs(OPTIONS) do
        local checkbox = scroll[CHECKBOX_PREFIX .. option.setting]
        if checkbox and checkbox.valid then
            checkbox.state = settings.global[option.setting].value --[[@as boolean]]
        end
    end
end

--- Create the settings window (hidden state handled by callers)
--- @param player LuaPlayer
--- @return LuaGuiElement frame
local function build_frame(player)
    local frame = get_frame(player)
    if frame then
        return frame
    end

    frame = player.gui.screen.add {
        type = "frame",
        name = FRAME_NAME,
        direction = "vertical",
        style = "frame",
    }
    frame.style.maximal_height = 600
    frame.style.natural_width = 250

    -- Titlebar
    local titlebar = frame.add { type = "flow", name = "broom_titlebar", direction = "horizontal" }
    titlebar.style.horizontal_spacing = 8
    titlebar.style.vertical_align = "center"
    titlebar.style.bottom_padding = 4

    local title = titlebar.add {
        type = "label",
        caption = { "shortcut-name.broom-get-selection-tool" },
        style = "frame_title",
    }
    title.drag_target = frame

    local dragger = titlebar.add { type = "empty-widget", style = "draggable_space_header" }
    dragger.style.height = 24
    dragger.style.horizontally_stretchable = true
    dragger.drag_target = frame

    titlebar.add {
        type = "sprite-button",
        name = PIN_BUTTON_NAME,
        sprite = "utility/track_button_white",
        style = "close_button",
        auto_toggle = true,
        tooltip = { "factoriopedia.pin-tooltip" },
    }

    titlebar.add {
        type = "sprite-button",
        name = CLOSE_BUTTON_NAME,
        sprite = "utility/close",
        clicked_sprite = "utility/close_black",
        style = "close_button",
        tooltip = { "gui.close-instruction" },
    }

    -- Body
    local inner = frame.add {
        type = "frame",
        name = INNER_FRAME_NAME,
        direction = "vertical",
        style = "inside_shallow_frame",
    }

    local subheader = inner.add { type = "frame", style = "subheader_frame" }
    subheader.style.horizontally_stretchable = true
    subheader.add {
        type = "label",
        caption = { "item-description.broom-selection-tool" },
        style = "subheader_caption_label",
    }

    local scroll = inner.add { type = "scroll-pane", name = SCROLL_NAME, direction = "vertical" }
    scroll.style.padding = 12

    for _, option in ipairs(OPTIONS) do
        local checkbox = scroll.add {
            type = "checkbox",
            name = CHECKBOX_PREFIX .. option.setting,
            caption = { "mod-setting-name." .. option.setting },
            tooltip = { "mod-setting-description." .. option.setting },
            state = settings.global[option.setting].value --[[@as boolean]],
        }
        if option.indent then
            checkbox.style.left_margin = 16
        end
    end

    frame.auto_center = true
    return frame
end

--- @param player LuaPlayer
local function show(player)
    local frame = build_frame(player)
    refresh(frame)
    frame.visible = true
    frame.bring_to_front()
    if not is_pinned(player.index) then
        player.opened = frame
    end
end

--- @param player LuaPlayer
local function hide(player)
    local frame = get_frame(player)
    if not frame then
        return
    end
    frame.visible = false
    get_pin_button(frame).toggled = false
    storage.broom_gui.pin[player.index] = nil
    if player.opened == frame then
        player.opened = nil
    end
end

local function destroy_all()
    for _, player in pairs(game.players) do
        local frame = get_frame(player)
        if frame then
            if player.opened == frame then
                player.opened = nil
            end
            frame.destroy()
        end
    end
end

--- Give the broom tool to the cursor (replicates the old spawn-item shortcut
--- behavior) and open the settings window.
--- @param event EventData.on_lua_shortcut|EventData.CustomInputEvent
local function on_shortcut(event)
    local name = event.prototype_name or event.input_name
    if name ~= "broom-get-selection-tool" then
        return
    end
    local player = game.get_player(event.player_index)
    if not (player and player.valid) then
        return
    end
    local cursor = player.cursor_stack
    if cursor and cursor.valid_for_read and cursor.name == "broom-selection-tool" then
        show(player)
        return
    end
    if not cursor or not player.clear_cursor() then
        return
    end
    cursor.set_stack({ name = "broom-selection-tool", count = 1 })
    show(player)
end

local this = {}

this.on_init = function()
    storage.broom_gui = { pin = {} }
end

this.on_configuration_changed = function()
    storage.broom_gui = { pin = {} }
    destroy_all()
end

this.events = {
    [defines.events.on_lua_shortcut] = on_shortcut,
    ["broom-get-selection-tool"] = on_shortcut,

    --- Keep the window in sync with the cursor: open while the broom tool is
    --- held, closed otherwise (unless pinned).
    --- @param event EventData.on_player_cursor_stack_changed
    [defines.events.on_player_cursor_stack_changed] = function(event)
        local player = game.get_player(event.player_index)
        if not (player and player.valid) then
            return
        end
        local cursor = player.cursor_stack
        if cursor and cursor.valid_for_read and cursor.name == "broom-selection-tool" then
            show(player)
        elseif not is_pinned(player.index) then
            hide(player)
        end
    end,

    --- @param event EventData.on_gui_click
    [defines.events.on_gui_click] = function(event)
        local element = event.element
        if not (element and element.valid) then
            return
        end
        if element.name == CLOSE_BUTTON_NAME then
            hide(game.get_player(event.player_index))
        elseif element.name == PIN_BUTTON_NAME then
            local player = game.get_player(event.player_index)
            local frame = get_frame(player)
            storage.broom_gui = storage.broom_gui or { pin = {} }
            if element.toggled then
                storage.broom_gui.pin[event.player_index] = true
                if player.opened == frame then
                    player.opened = nil
                end
            else
                storage.broom_gui.pin[event.player_index] = nil
                player.opened = frame
            end
        end
    end,

    --- @param event EventData.on_gui_checked_state_changed
    [defines.events.on_gui_checked_state_changed] = function(event)
        local element = event.element
        if not (element and element.valid) then
            return
        end
        local setting = CHECKBOX_TO_SETTING[element.name]
        if setting then
            settings.global[setting] = { value = element.state }
        end
    end,

    --- @param event EventData.on_gui_closed
    [defines.events.on_gui_closed] = function(event)
        local element = event.element
        if not (element and element.valid and element.name == FRAME_NAME) then
            return
        end
        -- Detaching player.opened when pinning also fires this event; a pinned
        -- window must stay open.
        if is_pinned(event.player_index) then
            return
        end
        hide(game.get_player(event.player_index))
    end,

    --- @param event EventData.on_runtime_mod_setting_changed
    [defines.events.on_runtime_mod_setting_changed] = function(event)
        if event.setting_type ~= "runtime-global" then
            return
        end
        for _, player in pairs(game.players) do
            local frame = get_frame(player)
            if frame then
                refresh(frame)
            end
        end
    end,

    --- @param event EventData.on_player_removed
    [defines.events.on_player_removed] = function(event)
        if storage.broom_gui then
            storage.broom_gui.pin[event.player_index] = nil
        end
    end,
}

return this
