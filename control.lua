-- Import the event handler module from the core Lua libraries
local handler = require("__core__.lualib.event_handler")

-- Add libraries for various cleaning tasks to the event handler
handler.add_libraries({
    require("scripts.clean-decoratives"),
    require("scripts.clean-biter-creep"),
    require("scripts.clean-corpses"),
    require("scripts.clean-nuclear"),
    require("scripts.clean-resources"),
    require("scripts.clean-rocks"),
    require("scripts.clean-trees"),
    require("scripts.clean-cliffs"),
    require("scripts.regenerate"),
})
