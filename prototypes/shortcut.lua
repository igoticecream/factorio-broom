data:extend({
    {
        type = "shortcut",
        name = "broom-get-selection-tool",
        order = "d[tools]-c[broom]",
        icon = "__broom__/graphics/shortcut-x32-black.png",
        icon_size = 32,
        small_icon = "__broom__/graphics/shortcut-x24-black.png",
        small_icon_size = 24,
        action = "spawn-item",
        item_to_spawn = "broom-selection-tool",
        associated_control_input = "broom-get-selection-tool",
        style = "default"
    },
})
