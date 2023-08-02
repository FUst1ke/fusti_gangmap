function notify(target, title, description, type, icon, position)
    TriggerClientEvent('ox_lib:notify', target, {
        title = title,
        description = description,
        type = type or 'inform',
        icon = icon or nil,
        position = position or 'top'
    })
end

RegisterServerEvent('esx:onPlayerDeath')
AddEventHandler('esx:onPlayerDeath', function(data)
    local xVictim = ESX.GetPlayerFromId(source)
    local xKiller = ESX.GetPlayerFromId(data.killerServerId)
    local killer = {name = xKiller.getName(), job = xKiller.getJob().label}
    local victim = {name = xVictim.getName(), job = xVictim.getJob().label}
    local zone = xVictim.getMeta('raidZone')
    local locale = Config.Locales
    TriggerEvent('fusti_gangmap:server:refreshPlayerList', zone, 'exit', source)
    notify(data.killerServerId, locale['information'], locale['you_killed']:format(victim.name, victim.job))
end)