-- The following callback should return true or false and determine whether the player is allowed to delete their character
lib.callback.register("av_multicharacter:canDelete", function(source)
    local permission = true -- change to false and add your own check
    local identifier = GetPlayerIdentifierByType(source, Config.Identifier)

    -- Is on you to run your own check :)

    return permission
end)