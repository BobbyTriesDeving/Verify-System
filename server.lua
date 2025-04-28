function addRoleToUser(discordId)
    local url = ('https://discord.com/api/guilds/%s/members/%s/roles/%s'):format(Config.GuildId, discordId, Config.RoleId)

    PerformHttpRequest(url, function(statusCode, data, headers)
        if statusCode == 204 then
            print('Role given successfully to Discord ID: ' .. discordId)
        else
            print('Failed to give role. Status Code: ' .. statusCode .. ' for Discord ID: ' .. discordId)
            if data then print('Response data: ' .. data) end
        end
    end, 'PUT', '', {
        ["Authorization"] = "Bot " .. Config.BotToken,
        ["Content-Type"] = "application/json"
    })
end



RegisterCommand('link', function(source)
    local src = source

    local identifiers = GetPlayerIdentifiers(src)
    local license, discord, ip = nil, nil, nil

    for _, id in pairs(identifiers) do
        if string.sub(id, 1, string.len("license:")) == "license:" then
            license = id
        elseif string.sub(id, 1, string.len("discord:")) == "discord:" then
            discord = string.sub(id, 9) -- cut "discord:" part
        elseif string.sub(id, 1, string.len("ip:")) == "ip:" then
            ip = string.sub(id, 4) -- cut "ip:" part
        end
    end

    if not license then
        print('No license found for player: ' .. src)
        return
    end

    local guildId = Config.GuildId
    local roleId = Config.RoleId
    local botToken = Config.BotToken

    local url = ('https://discord.com/api/guilds/%s/members/%s'):format(guildId, discord)

    PerformHttpRequest(url, function(statusCode, data, headers)
        if statusCode == 200 then
            -- Member exists, give role
            addRoleToUser(discord)
        else
            print('Failed to check Discord member. Status Code: ' .. statusCode)
            if data then print('Response data: ' .. data) end
        end
    end, 'GET', '', {
        ["Authorization"] = "Bot " .. botToken,
        ["Content-Type"] = "application/json"
    })



    MySQL.query('SELECT * FROM verify WHERE identifier = ?', {license}, function(result)
        if result[1] then
            TriggerClientEvent('verifysystem:notify', src, 'You are already linked!')
        else
            -- insert into database
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
