local this = {}
local name = "broom-hidden-surface"

function this.create_hidden_surface(settings)
    -- Create the hidden surface if it doesn't exist
    if not game.surfaces[name] then
        game.create_surface(name, settings)
    end

    -- Return the hidden surface
    return game.surfaces[name]
end

function this.delete_hidden_surface()
    -- Delete the hidden surface
    game.delete_surface(name)
end

function this.with_hidden_surface(settings, execute)
    local hidden_surface = this.create_hidden_surface(settings)

    -- Run the provided function within a protected call
    local status, err = pcall(execute(hidden_surface))

    this.delete_hidden_surface()
end

return this
