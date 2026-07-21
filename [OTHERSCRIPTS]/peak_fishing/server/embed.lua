local utils = require 'modules.utils.server'

---@param webhookUrl string
---@param data table
---@return boolean success
local function sendDiscordWebhook(webhookUrl, data)
    if not webhookUrl or webhookUrl == '' then
        utils.debugPrint('Discord webhook URL is not configured')
        return false
    end

    PerformHttpRequest(webhookUrl, function(statusCode, response, headers)
        if statusCode == 204 then
            utils.debugPrint('Discord webhook sent successfully')
        else
            utils.debugPrint(('Discord webhook failed with status code: %d'):format(statusCode))
        end
    end, 'POST', json.encode(data), {
        ['Content-Type'] = 'application/json'
    })

    return true
end

---@param config table
---@param embedData table
---@return table
local function buildDiscordEmbed(config, embedData)
    local embed = {
        title = embedData.title or config.title,
        description = embedData.description or config.description,
        color = embedData.color or config.color,
        fields = {}
    }

    if embedData.fields then
        for fieldName, fieldData in pairs(embedData.fields) do
            if config.fields[fieldName] then
                table.insert(embed.fields, {
                    name = fieldData.name,
                    value = fieldData.value,
                    inline = fieldData.inline or false
                })
            end
        end
    end

    return embed
end

---@param webhookConfig table
---@param announcementConfig table
---@param embedData table
---@return boolean success
local function sendDiscordAnnouncement(webhookConfig, announcementConfig, embedData)
    if not announcementConfig.enabled then
        utils.debugPrint('Discord announcement is disabled')
        return false
    end

    local embed = buildDiscordEmbed(announcementConfig, embedData)

    local data = {
        username = webhookConfig.username,
        avatar_url = webhookConfig.avatar_url,
        embeds = { embed }
    }

    return sendDiscordWebhook(webhookConfig.url, data)
end

---@param webhook table
---@param announcement table
---@param data table
local function announceTournamentStarting(webhook, announcement, data)
    local embedData = {
        fields = {
            location = {
                name = locale('discord.fields.location'),
                value = data.zoneLabel,
                inline = false
            },
            entryFee = {
                name = locale('discord.fields.entryFee'),
                value = ('%s%d'):format(locale('currency_symbol'), data.entryFee),
                inline = false
            },
            timeUntilStart = {
                name = locale('discord.fields.timeUntilStart'), 
                value = ('%d minutes'):format(data.timingAnnounce),
                inline = false
            }
        }
    }

    return sendDiscordAnnouncement(webhook, announcement, embedData)
end

---@param webhook table
---@param announcement table
---@param data table
local function announceTournamentStarted(webhook, announcement, data)
    local embedData = {
        fields = {
            location = {
                name = locale('discord.fields.location'),
                value = data.zoneLabel,
                inline = false
            },
            participants = {
                name = locale('discord.fields.participants'),
                value = tostring(data.totalPlayers),
                inline = false
            },
            duration = {
                name = locale('discord.fields.duration'),
                value = ('%d minutes'):format(data.timingDuration),
                inline = false
            }
        }
    }

    return sendDiscordAnnouncement(webhook, announcement, embedData)
end

---@param webhook table
---@param announcement table
---@param data table
local function announceTournamentEnded(webhook, announcement, data)
    local embedData = {
        fields = {
            location = {
                name = locale('discord.fields.location'),
                value = data.zoneLabel,
                inline = false
            },
            winner = {
                name = locale('discord.fields.winner'),
                value = data.winnerName,
                inline = false
            },
            participants = {
                name = locale('discord.fields.participants'),
                value = tostring(data.totalPlayers),
                inline = false
            },
            totalPrize = {
                name = locale('discord.fields.totalPrize'),
                value = ('%s%d'):format(locale('currency_symbol'), data.totalPrize),
                inline = false
            }
        }
    }

    return sendDiscordAnnouncement(webhook, announcement, embedData)
end

_ENV.embed = {
    sendDiscordWebhook = sendDiscordWebhook,
    buildDiscordEmbed = buildDiscordEmbed,
    sendDiscordAnnouncement = sendDiscordAnnouncement,
    announceTournamentStarting = announceTournamentStarting,
    announceTournamentStarted = announceTournamentStarted,
    announceTournamentEnded = announceTournamentEnded
}
