-- Import necessary modules for custom inputs, items, and shortcuts
require("prototypes.custom-input")
require("prototypes.item")
require("prototypes.shortcut")

-- Check if the broom-atomic-bomb setting is enabled
if settings.startup["broom-atomic-bomb"].value then
    -- Remove specific target effects from the atomic rocket projectile
    table.remove(data.raw["projectile"]["atomic-rocket"].action.action_delivery.target_effects, 11) -- Remove effect at index 11 create-decorative:nuclear-ground-patch
    table.remove(data.raw["projectile"]["atomic-rocket"].action.action_delivery.target_effects, 10) -- Remove effect at index 10 destroy-decoratives
    table.remove(data.raw["projectile"]["atomic-rocket"].action.action_delivery.target_effects, 8)  -- Remove effect at index 08 create-entity:huge-scorchmark
    table.remove(data.raw["projectile"]["atomic-rocket"].action.action_delivery.target_effects, 1)  -- Remove effect at index 01 set-tile:nuclear-ground
end
