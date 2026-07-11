-- Import the event handler module from the core Lua libraries
local handler = require("__core__.lualib.event_handler")

-- Add libraries for various cleaning tasks to the event handler
handler.add_libraries({
    require("scripts.player-settings"),
    require("scripts.selection"),
    require("scripts.gui"),
})
