-- Registro de mensajes en el chat
AddEventHandler('chatMessage', function(src, author, message)
    if not message or message == '' then return end
    
    if string.sub(message, 1, 1) == '/' then return end
    
    local playerName = GetPlayerName(src) or 'Desconocido'
    local license = GetPlayerIdentifierByType(src, 'license') or GetPlayerIdentifierByType(src, 'license2') or 'Desconocido'
    local discord = GetPlayerIdentifierByType(src, 'discord') or 'No vinculado'
    local steam = GetPlayerIdentifierByType(src, 'steam') or 'No vinculado'
    
    local longitudMensaje = string.len(message)
    
    exports[GetCurrentResourceName()]:CreateLog({
        category = 'chat',
        title = 'Registros de Chat',
        action = 'Mensaje enviado',
        color = 'grey',
        players = {
            { id = src, role = 'Emisor' }
        },
        info = {
            { name = 'Nombre del jugador', value = playerName },
            { name = 'Mensaje', value = message },
            { name = 'Longitud del mensaje', value = longitudMensaje .. ' caracteres' },
        },
        takeScreenshot = false
    })
end)

-- Registro de comandos en el chat
AddEventHandler('chatMessage', function(src, author, message)
    if not message or message == '' then return end
    
    if string.sub(message, 1, 1) ~= '/' then return end
    
    local playerName = GetPlayerName(src) or 'Desconocido'
    local comando = string.match(message, "^/(%S+)")
    local argumentos = string.match(message, "^/%S+%s(.+)") or "Sin argumentos"
    
    exports[GetCurrentResourceName()]:CreateLog({
        category = 'chat',
        title = 'Registros de Chat',
        action = 'Comando ejecutado',
        color = 'blue',
        players = {
            { id = src, role = 'Ejecutor' }
        },
        info = {
            { name = 'Nombre del jugador', value = playerName },
            { name = 'Comando', value = '/' .. (comando or 'desconocido') },
        },
        extra = {
            {
                title = "Detalles del comando",
                data = {
                    { name = 'Mensaje completo', value = message },
                    { name = 'Argumentos', value = argumentos },
                    { name = 'Fecha y hora', value = os.date('%Y-%m-%d %H:%M:%S') },
                }
            }
        },
        takeScreenshot = false
    })
end)

-- Detección de spam en el chat
local chatSpamTracker = {}
local SPAM_THRESHOLD = 5
local SPAM_TIME_WINDOW = 10 

AddEventHandler('chatMessage', function(src, author, message)
    if not message or message == '' then return end
    if string.sub(message, 1, 1) == '/' then return end
    
    local currentTime = os.time()
    
    if not chatSpamTracker[src] then
        chatSpamTracker[src] = {
            messages = {},
            lastWarning = 0
        }
    end
    
    table.insert(chatSpamTracker[src].messages, {
        message = message,
        time = currentTime
    })
    
    for i = #chatSpamTracker[src].messages, 1, -1 do
        if currentTime - chatSpamTracker[src].messages[i].time > SPAM_TIME_WINDOW then
            table.remove(chatSpamTracker[src].messages, i)
        end
    end
    
    if #chatSpamTracker[src].messages >= SPAM_THRESHOLD then
        if currentTime - chatSpamTracker[src].lastWarning > 30 then
            local playerName = GetPlayerName(src) or 'Desconocido'
            
            exports[GetCurrentResourceName()]:CreateLog({
                category = 'chat',
                title = 'Registros de Chat',
                action = 'Spam detectado',
                color = 'red',
                players = {
                    { id = src, role = 'Spammer' }
                },
                info = {
                    { name = 'Nombre del jugador', value = playerName },
                    { name = 'Mensajes enviados', value = #chatSpamTracker[src].messages .. ' mensajes en ' .. SPAM_TIME_WINDOW .. ' segundos' },
                },
                extra = {
                    {
                        title = "Mensajes recientes",
                        data = {
                            { name = 'Último mensaje', value = message },
                            { name = 'Hora de detección', value = os.date('%Y-%m-%d %H:%M:%S') },
                        }
                    }
                },
                takeScreenshot = true
            })
            
            chatSpamTracker[src].lastWarning = currentTime
        end
    end
end)

-- Registros de comandos F8 / RCON
local criticalCommands = {
    ['restart'] = true,
    ['stop'] = true,
    ['refresh'] = true,
    ['ensure'] = true,
    ['start'] = true,
    ['exec'] = true,
    ['quit'] = true,
    ['sv_password'] = true,
    ['remove_principal'] = true,
    ['add_principal'] = true,
    ['add_ace'] = true,
    ['remove_ace'] = true,
}

local dangerousCommands = {
    ['quit'] = true,
    ['sv_password'] = true,
    ['remove_principal'] = true,
}

AddEventHandler('rconCommand', function(commandName, args)
    local commandLower = string.lower(commandName)
    local argsString = table.concat(args, ' ')
    
    local isCritical = criticalCommands[commandLower] or false
    local isDangerous = dangerousCommands[commandLower] or false
    
    local logColor = "blue"
    local dangerLevel = "🟢 NORMAL"
    
    if isDangerous then
        logColor = "darkred"
        dangerLevel = "🔴 PELIGROSO"
    elseif isCritical then
        logColor = "orange"
        dangerLevel = "🟠 CRÍTICO"
    end
    
    local serverName = GetConvar('sv_hostname', 'Desconocido')
    local maxPlayers = GetConvar('sv_maxclients', '32')
    local playersOnline = #GetPlayers()
    
    exports[GetCurrentResourceName()]:CreateLog({
        category = "chat",
        title = "Registros RCON",
        action = "Comando RCON ejecutado",
        color = logColor,
        info = {
            { name = "Comando", value = commandName },
            { name = "Nivel de peligro", value = dangerLevel },
            { name = "Fecha y hora", value = os.date('%Y-%m-%d %H:%M:%S') },
        },
        extra = {
            {
                title = "Detalles del comando",
                data = {
                    { name = "Comando completo", value = commandName .. (argsString ~= "" and " " .. argsString or "") },
                    { name = "Argumentos", value = argsString ~= "" and argsString or "Sin argumentos" },
                    { name = "Cantidad de argumentos", value = #args },
                }
            },
            {
                title = "Información del servidor",
                data = {
                    { name = "Nombre del servidor", value = serverName },
                    { name = "Jugadores conectados", value = playersOnline .. " / " .. maxPlayers },
                    { name = "Hora de ejecución", value = os.date('%H:%M:%S') },
                }
            },
            isDangerous and {
                title = "⚠️ Alerta de seguridad",
                data = {
                    { name = "Advertencia", value = "🚨 COMANDO PELIGROSO EJECUTADO" },
                    { name = "Nivel de riesgo", value = "ALTO - Posible impacto en el servidor" },
                    { name = "Recomendación", value = "Revisar esta acción inmediatamente" },
                }
            } or nil
        },
        takeScreenshot = isDangerous or isCritical
    })
end)

-- Limpiar tracker de spam al desconectarse
AddEventHandler('playerDropped', function(reason)
    local src = source
    if chatSpamTracker[src] then
        chatSpamTracker[src] = nil
    end
end)