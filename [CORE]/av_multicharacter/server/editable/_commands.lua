if Config.EditorCommand then
    lib.addCommand(Config.EditorCommand, {
        help = 'AV Multicharacter Editor',
        params = {},
        restricted = Config.AdminGroup
    }, function(source, args, raw)
        Editor(source)
    end)
end

if Config.RelogCommand then
    lib.addCommand(Config.RelogCommand, {
        help = 'Relog Command',
        params = {},
        restricted = Config.RelogGroups
    }, function(source, args, raw)
        Relog(source)
    end)
end