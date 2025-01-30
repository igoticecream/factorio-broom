data:extend({
    {
        type = "selection-tool",
        name = "broom-selection-tool",
        order = "d[tools]-c[broom]",
        icons = {
            { icon = "__broom__/graphics/black.png",              icon_size = 1,  scale = 64 },
            { icon = "__broom__/graphics/shortcut-x32-white.png", icon_size = 32, mipmap_count = 2 },
        },
        stack_size = 1,
        flags = { "only-in-cursor", "not-stackable", "spawnable" },
        subgroup = "other",
        hidden = true,
        hidden_in_factoriopedia = true,
        select = {
            border_color = { r = 1, g = 0, b = 0 },
            mode = { "nothing" },
            cursor_box_type = "not-allowed",
        },
        alt_select = {
            border_color = { r = 0, g = 1, b = 0 },
            mode = { "nothing" },
            cursor_box_type = "not-allowed",
        },
    },
})
