local player_settings = require("scripts.player-settings")

local FRAME_NAME = "broom_settings_frame"
local INNER_FRAME_NAME = "broom_inner_frame"
local SCROLL_NAME = "broom_settings_scroll"
local PIN_BUTTON_NAME = "broom_pin_button"
local CLOSE_BUTTON_NAME = "broom_close_button"
local RESET_BUTTON_NAME = "broom_reset_button"
local CHECKBOX_PREFIX = "broom_gui_"
local SECTION_HEADER_NAME = "broom_section_header"
local SECTION_ARROW_NAME = "broom_section_arrow"
local SECTION_OPTIONS_NAME = "broom_section_options"
local LABEL_COLOR = { 200, 200, 200 }

-- Every category is a section. Single settings render directly as checkboxes;
-- multi-option sections are collapsible and use an action string for radios.
local SECTIONS = {
    {
        caption = "gui.broom-trees",
        tooltip = "gui.broom-trees-tooltip",
        key = "trees",
        options = {
            { key = "trees_action", value = "remove",          indent = true, caption = "gui.broom-remove",               tooltip = "gui.broom-remove-trees-tooltip" },
            { key = "trees_action", value = "heal",            indent = true, caption = "gui.broom-tree-heal",            tooltip = "gui.broom-tree-heal-tooltip" },
            { key = "trees_action", value = "heal_unpolluted", indent = true, caption = "gui.broom-tree-heal-unpolluted", tooltip = "gui.broom-tree-heal-unpolluted-tooltip" },
        },
    },
    {
        caption = "gui.broom-rocks",
        tooltip = "gui.broom-rocks-tooltip",
        key = "rocks",
        options = {
            { key = "rocks_action", value = "remove", indent = true, caption = "gui.broom-remove",    tooltip = "gui.broom-remove-rocks-tooltip" },
            { key = "rocks_action", value = "heal",   indent = true, caption = "gui.broom-rock-heal", tooltip = "gui.broom-rock-heal-tooltip" },
        },
    },
    {
        caption = "gui.broom-decoratives",
        tooltip = "gui.broom-decoratives-tooltip",
        key = "decoratives",
        options = {
            { key = "decoratives_action", value = "remove",     indent = true, caption = "gui.broom-remove",            tooltip = "gui.broom-remove-decoratives-tooltip" },
            { key = "decoratives_action", value = "artificial", indent = true, caption = "gui.broom-remove-artificial", tooltip = "gui.broom-remove-artificial-tooltip" },
            { key = "decoratives_action", value = "regenerate", indent = true, caption = "gui.broom-regenerate",        tooltip = "gui.broom-regenerate-tooltip" },
        },
    },
    { caption = "gui.broom-cliffs",      tooltip = "gui.broom-cliffs-tooltip",      key = "cliffs" },
    { caption = "gui.broom-resources",   tooltip = "gui.broom-resources-tooltip",   key = "resources" },
    { caption = "gui.broom-nuclear",     tooltip = "gui.broom-nuclear-tooltip",     key = "nuclear" },
    { caption = "gui.broom-biter-creep", tooltip = "gui.broom-biter-creep-tooltip", key = "biter_creep" },
    {
        caption = "gui.broom-corpses",
        tooltip = "gui.broom-corpses-tooltip",
        key = "corpses",
        options = {
            { key = "corpses_exclude_biter",      indent = true, caption = "gui.broom-exclude-biter",      tooltip = "gui.broom-exclude-biter-tooltip" },
            { key = "corpses_exclude_scorchmark", indent = true, caption = "gui.broom-exclude-scorchmark", tooltip = "gui.broom-exclude-scorchmark-tooltip" },
            { key = "corpses_exclude_stump",      indent = true, caption = "gui.broom-exclude-stump",      tooltip = "gui.broom-exclude-stump-tooltip" },
            { key = "corpses_exclude_remnants",   indent = true, caption = "gui.broom-exclude-remnants",   tooltip = "gui.broom-exclude-remnants-tooltip" },
        },
    },
}

-- Expand the single-setting shorthand, derive each section's frame name from
-- its settings key ("trees" -> "broom_trees_frame"), and build the lookups
-- used by the event handlers.
local CONTROL_BY_NAME = {}
for _, section in ipairs(SECTIONS) do
    section.name = "broom_" .. section.key .. "_frame"
    section.has_options = section.options ~= nil
    section.options = section.options or { { key = section.key, caption = section.caption, tooltip = section.tooltip } }
    if section.has_options then
        local name = CHECKBOX_PREFIX .. section.key
        CONTROL_BY_NAME[name] = { key = section.key }
    end
    for _, option in ipairs(section.options) do
        option.name = CHECKBOX_PREFIX .. option.key .. (option.value and "_" .. option.value or "")
        CONTROL_BY_NAME[option.name] = option
    end
end

-- The frame location persists with the save, while this table resets on load.
-- Multiplayer resets through on_player_joined_game to avoid desyncs.
local session_position_reset = {}

--- @param settings table
--- @param control table
--- @return boolean
local function control_state(settings, control)
    if control.value then
        return settings[control.key] == control.value
    end
    return settings[control.key] == true
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

--- Update every checkbox from the player's settings
--- @param frame LuaGuiElement
--- @param settings table
local function refresh(frame, settings)
    local scroll = frame[INNER_FRAME_NAME][SCROLL_NAME]
    for _, section in ipairs(SECTIONS) do
        local section_frame = scroll[section.name]
        if section_frame and section_frame.valid then
            if section.has_options then
                local header = section_frame[SECTION_HEADER_NAME]
                local checkbox = header and header[CHECKBOX_PREFIX .. section.key]
                if checkbox and checkbox.valid then
                    checkbox.state = settings[section.key]
                end
            end
            local container = section.has_options and section_frame[SECTION_OPTIONS_NAME] or section_frame
            for _, option in ipairs(section.options) do
                local checkbox = container[option.name]
                if checkbox and checkbox.valid then
                    checkbox.state = control_state(settings, option)
                end
            end
        end
    end
end

--- Compose a section header arrow.
--- @param expanded boolean
--- @return string
local function section_arrow(expanded)
    return expanded and " ▾ " or " ▴ "
end

--- Add a dark section. Multi-option sections receive a clickable header and a
--- collapsible options flow; single-option sections use the frame directly.
--- @param scroll LuaGuiElement
--- @param section_data table
--- @return LuaGuiElement container The frame or collapsible options flow
local function add_section(scroll, section_data)
    local section = scroll.add {
        type = "frame",
        name = section_data.name,
        direction = "vertical",
        style = "deep_frame_in_shallow_frame_for_description",
    }
    section.style.horizontally_stretchable = true

    if not section_data.has_options then
        return section
    end

    local header = section.add {
        type = "flow",
        name = SECTION_HEADER_NAME,
        direction = "horizontal",
    }
    header.style.vertical_align = "center"
    header.style.horizontally_stretchable = true

    header.add {
        type = "checkbox",
        name = CHECKBOX_PREFIX .. section_data.key,
        caption = { section_data.caption },
        tooltip = { section_data.tooltip },
        state = false,
    }

    local spacer = header.add { type = "empty-widget" }
    spacer.style.horizontally_stretchable = true

    local arrow = header.add {
        type = "label",
        name = SECTION_ARROW_NAME,
        caption = section_arrow(false),
        tooltip = { section_data.caption .. "-tooltip" },
        style = "semibold_label",
    }
    arrow.style.font_color = LABEL_COLOR

    local options = section.add { type = "flow", name = SECTION_OPTIONS_NAME, direction = "vertical", visible = false }
    options.add { type = "line", direction = "horizontal", style = "tooltip_category_line" }
    return options
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

    -- Subheader
    local subheader = inner.add { type = "frame", direction = "horizontal", style = "subheader_frame" }
    subheader.style.use_header_filler = true
    subheader.style.horizontally_stretchable = true
    local label = subheader.add {
        type = "label",
        caption = { "gui.broom-subheader" },
        style = "subheader_caption_label",
    }
    -- label.style.font_color = LABEL_COLOR
    -- label.style.font = 'default-semibold'

    local spacer = subheader.add { type = "empty-widget" }
    spacer.style.horizontally_stretchable = true

    subheader.add {
        type = "sprite-button",
        name = RESET_BUTTON_NAME,
        sprite = "utility/reset",
        style = "tool_button_red",
        tooltip = { "gui.broom-reset-tooltip" },
    }

    local scroll = inner.add { type = "scroll-pane", name = SCROLL_NAME, direction = "vertical" }
    scroll.style.padding = 12
    local settings = player_settings.get(player.index)

    for _, section in ipairs(SECTIONS) do
        local container = add_section(scroll, section)
        for _, option in ipairs(section.options) do
            local checkbox = container.add {
                type = option.value and "radiobutton" or "checkbox",
                name = option.name,
                caption = { option.caption },
                tooltip = { option.tooltip },
                state = control_state(settings, option),
            }
            if option.indent then
                checkbox.style.left_margin = 16
            end
        end
    end

    -- frame.auto_center = true
    frame.location = { 0, 0 }
    return frame
end

--- @param player LuaPlayer
local function show(player)
    local frame = build_frame(player)
    -- Single-player only: loading a save does not fire on_player_joined_game,
    -- so a frame restored from the save is reset here instead.
    if not game.is_multiplayer() and not session_position_reset[player.index] then
        session_position_reset[player.index] = true
        frame.location = { 0, 0 }
    end
    refresh(frame, player_settings.get(player.index))
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
            local player = game.get_player(event.player_index)
            if player then
                hide(player)
            end
        elseif element.name == RESET_BUTTON_NAME then
            local player = game.get_player(event.player_index)
            local frame = player and get_frame(player)
            if frame then
                refresh(frame, player_settings.reset(event.player_index))
            end
        elseif element.name == PIN_BUTTON_NAME then
            local player = game.get_player(event.player_index)
            if not player then
                return
            end
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
        elseif element.name == SECTION_ARROW_NAME then
            -- The parent guards cover foreign elements whose names happen to
            -- collide with ours; this handler fires for every mod's GUI clicks.
            local header = element.parent -- arrow -> header -> section frame -> options flow
            local section = header and header.parent
            local options = section and section[SECTION_OPTIONS_NAME]
            if options and options.valid then
                options.visible = not options.visible
                element.caption = section_arrow(options.visible)
            end
        end
    end,

    --- @param event EventData.on_gui_checked_state_changed
    [defines.events.on_gui_checked_state_changed] = function(event)
        local element = event.element
        if not (element and element.valid) then
            return
        end
        local control = CONTROL_BY_NAME[element.name]
        if control then
            if control.value and not element.state then
                element.state = true
                return
            end
            local settings = player_settings.get(event.player_index)
            settings[control.key] = control.value or element.state
            local player = game.get_player(event.player_index)
            local frame = player and get_frame(player)
            if frame then
                refresh(frame, settings)
            end
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
        local player = game.get_player(event.player_index)
        if player then
            hide(player)
        end
    end,

    --- Reset a (re)joining player's persisted window position synchronously.
    --- @param event EventData.on_player_joined_game
    [defines.events.on_player_joined_game] = function(event)
        local player = game.get_player(event.player_index)
        if not (player and player.valid) then
            return
        end
        local frame = get_frame(player)
        if frame then
            frame.location = { 0, 0 }
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
