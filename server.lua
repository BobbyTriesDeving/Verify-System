

local lastLinkUsage = {}  -- Store cooldown information per player
local cooldown = 30  -- Cooldown time in seconds

function addRoleToUser(discordId)
    local url = ('https://discord.com/api/guilds/%s/members/%s/roles/%s'):format(Config.GuildId, discordId, Config.RoleId)


    PerformHttpRequest(url, function(statusCode, data, headers)
        if statusCode == 204 then
            print('Role given successfully to Discord ID: ' .. discordId)
        else
            print('Failed to give role. Status Code: ' .. tostring(statusCode) .. ' for Discord ID: ' .. tostring(discordId))
            if data then print('Response data: ' .. tostring(data)) end
        end
    end, 'PUT', '', {
        ["Authorization"] = "Bot " .. Config.BotToken,
        ["Content-Type"] = "application/json"
    })
end

RegisterCommand('link', function(source)
    local src = source
    local now = GetGameTimer()
    local identifiers = GetPlayerIdentifiers(src)
    local license, discord, ip = nil, nil, nil
    local name = GetPlayerName(source)
    local ids = GetPlayerIdentifiersTable(source)

    if lastLinkUsage[source] then
        local timeSinceLastUse = (now - lastLinkUsage[source]) / 1000

        if timeSinceLastUse < cooldown then
            local secondsLeft = cooldown - timeSinceLastUse

            TriggerClientEvent('verifysystem:notifyCooldown', src, math.ceil(secondsLeft))
            return
        end
    end

    local desc = ("**Player Name:** %s\n**Steam ID:** %s\n**Discord ID:**"):format(name, ids.steam, ids.discord)
    sendToDiscord("Link Command Executed! User has been given the role!", desc, 16753920)

    for _, id in pairs(identifiers) do
        if string.sub(id, 1, string.len("license:")) == "license:" then
            license = id
        elseif string.sub(id, 1, string.len("discord:")) == "discord:" then
            discord = string.sub(id, 9)
        elseif string.sub(id, 1, string.len("ip:")) == "ip:" then
            ip = string.sub(id, 4)
        end
    end

    local guildId = Config.GuildId
    local roleId = Config.RoleId
    local botToken = Config.BotToken

    local url = ('https://discord.com/api/guilds/%s/members/%s'):format(guildId, discord)

    PerformHttpRequest(url, function(statusCode, data, headers)
        if statusCode == 200 then
            addRoleToUser(discord)
        else
            if data then print('Response data: ' .. tostring(data)) end
        end
    end, 'GET', '', {
        ["Authorization"] = "Bot " .. botToken,
        ["Content-Type"] = "application/json"
    })

    lastLinkUsage[src] = now

    MySQL.query('SELECT * FROM verify WHERE identifier = ?', {license}, function(result)
        if result[1] then
            TriggerClientEvent('verifysystem:notify', src, 'You are already linked!')
        else
            MySQL.prepare('INSERT INTO verify (identifier, money, discord_id, ip_address) VALUES (?, ?, ?, ?)', {
                license,
                0,
                discord or "Unknown",
                ip or "Unknown"
            })
            TriggerClientEvent('verifysystem:notify', src, 'You have been successfully linked!')
        end
    end)
end)





function GetPlayerIdentifiersTable(source)
    local identifiers = {
        steam = "Not found",
        discord = "Not found"
    }

    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local id = GetPlayerIdentifier(source, i)
        if string.find(id, "steam:") then
            identifiers.steam = id
        elseif string.find(id, "discord:") then
            identifiers.discord = string.gsub(id, "discord:", "")
        end
    end

    return identifiers
end

function sendToDiscord(title, description, color)
    local embed = {{
        ["title"] = title,
        ["description"] = description,
        ["color"] = color,
        ["footer"] = {
            ["text"] = "Changeme"
        }
    }}

    PerformHttpRequest(Config.Webhook, function(err, text, headers)
    end, "POST", json.encode({
        username = "changeme",
        embeds = embed
    }), {
        ["Content-Type"] = "application/json"
    })
end


local flagFile = 'embed_sent.flag'

CreateThread(function()
    local sent = LoadResourceFile(GetCurrentResourceName(), flagFile)

    if not sent then

        local embedData = {
            embeds = {{
                title = "Verification Required",
                description = "Join the ingame FiveM server to verify ingame!\n\n**Server Name:** " .. GetConvar('sv_hostname', 'Unknown'),
                color = 65280
            }}
        }

        PerformHttpRequest(Config.verifywebhook, function(err, text, headers)
            SaveResourceFile(GetCurrentResourceName(), flagFile, "true", -1)
        end, 'POST', json.encode(embedData), {
            ['Content-Type'] = 'application/json'
        })
    end
end)
