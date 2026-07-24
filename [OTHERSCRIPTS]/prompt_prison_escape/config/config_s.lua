return {
    debug = false,

    -- Når denne er true, bliver spilleren fjernet fra tk_jail efter en vellykket flugt.
    -- teleport = false betyder, at tk_jail ikke teleporterer spilleren væk fra flugtstedet.
    tkJail = {
        enabled = true,
        releaseOnEscape = true,
        teleportOnRelease = false
    },

    isPlayerInPrion = function(source)
        if GetResourceState('tk_jail') == 'started' then
            local success, sentence = pcall(function()
                return exports.tk_jail:getSentence(source)
            end)

            if not success then
                lib.print.error(('[TK Jail] Kunne ikke hente fængselsdom for spiller %s: %s'):format(source, sentence))
                return false
            end

            return (tonumber(sentence) or 0) > 0
        elseif GetResourceState('rcore_prison') == 'started' then
            return exports.rcore_prison:IsPrisoner(source)
        elseif GetResourceState('dynyx_prison') == 'started' then
            return exports.dynyx_prison:IsActivePrisoner(source)
        end

        -- Bevarer scriptets oprindelige fallback, hvis intet understøttet fængselssystem kører.
        return true
    end,

    onPlayerEscaped = function(source, settings)
        if GetResourceState('tk_jail') ~= 'started' then
            return true
        end

        if not settings.tkJail.enabled or not settings.tkJail.releaseOnEscape then
            return true
        end

        local success, result = pcall(function()
            return exports.tk_jail:unjail(tostring(source), settings.tkJail.teleportOnRelease == true)
        end)

        if not success then
            lib.print.error(('[TK Jail] Kunne ikke løslade spiller %s efter flugt: %s'):format(source, result))
            return false
        end

        lib.print.info(('[TK Jail] Spiller %s er fjernet fra fængsel efter en vellykket flugt.'):format(source))
        return true
    end
}
