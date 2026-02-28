-- Jugador entrando
AddEventHandler('playerJoining', function(oldId)
    local src = source
    local playerName = GetPlayerName(src) or 'Desconocido'
    local playersOnline = #GetPlayers()
    
    exports[GetCurrentResourceName()]:CreateLog({
        category = "entrada/salida",
        title = "Registros de Entrada/Salida",
        action = "Jugador entrando",
        color = "green",
        players = {
            { id = src, role = "Jugador" },
        },
        info = {
            { name = "Nombre del jugador", value = playerName },
            { name = "Jugadores conectados", value = playersOnline },
            { name = "Hora de entrada", value = os.date('%Y-%m-%d %H:%M:%S') },
        },
        takeScreenshot = false
    })
end)

-- Jugador saliendo
AddEventHandler('playerDropped', function(reason)
    local src = source
    local playerName = GetPlayerName(src) or 'Desconocido'
    local playersOnline = #GetPlayers() - 1
    
    local license = GetPlayerIdentifierByType(src, 'license') or GetPlayerIdentifierByType(src, 'license2') or 'Desconocido'
    local discord = GetPlayerIdentifierByType(src, 'discord') or 'No vinculado'
    local steam = GetPlayerIdentifierByType(src, 'steam') or 'No vinculado'
    
    local tiempoSesion = "Desconocido"
    local playerJoinTime = GetPlayerJoinTime and GetPlayerJoinTime(src)
    if playerJoinTime then
        local sessionTime = os.time() - playerJoinTime
        local hours = math.floor(sessionTime / 3600)
        local minutes = math.floor((sessionTime % 3600) / 60)
        local seconds = sessionTime % 60
        tiempoSesion = string.format("%02d:%02d:%02d", hours, minutes, seconds)
    end
    
    exports[GetCurrentResourceName()]:CreateLog({
        category = "entrada/salida",
        title = "Registros de Entrada/Salida",
        action = "Jugador saliendo",
        color = "red",
        players = {
            { id = src, role = "Jugador" },
        },
        info = {
            { name = "Nombre del jugador", value = playerName },
            { name = "Motivo", value = reason },
            { name = "Jugadores restantes", value = playersOnline },
        },
        extra = {
            {
                title = "Información de la sesión",
                data = {
                    { name = "Duración de la sesión", value = tiempoSesion },
                    { name = "Hora de salida", value = os.date('%Y-%m-%d %H:%M:%S') },
                }
            }
        },
        takeScreenshot = false
    })
end)

-- Recurso iniciado
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then return end
    
    local autorRecurso = GetResourceMetadata(resourceName, 'author', 0) or 'Desconocido'
    local versionRecurso = GetResourceMetadata(resourceName, 'version', 0) or 'Desconocida'
    local descripcionRecurso = GetResourceMetadata(resourceName, 'description', 0) or 'Sin descripción'
    
    exports[GetCurrentResourceName()]:CreateLog({
        category = "recursos",
        title = "Registros de Recursos",
        action = "Recurso iniciado",
        color = "green",
        info = {
            { name = "Nombre del recurso", value = resourceName },
            { name = "Iniciado por", value = "Servidor" },
            { name = "Hora de inicio", value = os.date('%Y-%m-%d %H:%M:%S') },
        },
        extra = {
            {
                title = "Información del recurso",
                data = {
                    { name = "Autor", value = autorRecurso },
                    { name = "Versión", value = versionRecurso },
                    { name = "Descripción", value = descripcionRecurso },
                }
            }
        },
    })
end)

-- Recurso detenido
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then return end
    
    local autorRecurso = GetResourceMetadata(resourceName, 'author', 0) or 'Desconocido'
    local versionRecurso = GetResourceMetadata(resourceName, 'version', 0) or 'Desconocida'
    
    exports[GetCurrentResourceName()]:CreateLog({
        category = "recursos",
        title = "Registros de Recursos",
        action = "Recurso detenido",
        color = "red",
        info = {
            { name = "Nombre del recurso", value = resourceName },
            { name = "Detenido por", value = "Servidor" },
            { name = "Hora de detención", value = os.date('%Y-%m-%d %H:%M:%S') },
        },
        extra = {
            {
                title = "Información del recurso",
                data = {
                    { name = "Autor", value = autorRecurso },
                    { name = "Versión", value = versionRecurso },
                }
            }
        },
    })
end)

-- Detección de recurso reiniciado
local resourceRestartTracker = {}

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then return end
    resourceRestartTracker[resourceName] = os.time()
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then return end
    
    if resourceRestartTracker[resourceName] and (os.time() - resourceRestartTracker[resourceName]) < 2 then
        local autorRecurso = GetResourceMetadata(resourceName, 'author', 0) or 'Desconocido'
        local versionRecurso = GetResourceMetadata(resourceName, 'version', 0) or 'Desconocida'
        
        exports[GetCurrentResourceName()]:CreateLog({
            category = "recursos",
            title = "Registros de Recursos",
            action = "Recurso reiniciado",
            color = "orange",
            info = {
                { name = "Nombre del recurso", value = resourceName },
                { name = "Hora de reinicio", value = os.date('%Y-%m-%d %H:%M:%S') },
            },
            extra = {
                {
                    title = "Información del recurso",
                    data = {
                        { name = "Autor", value = autorRecurso },
                        { name = "Versión", value = versionRecurso },
                    }
                }
            },
        })
        
        resourceRestartTracker[resourceName] = nil
    end
end)

-- Servidor iniciado
AddEventHandler('onServerResourceStart', function(resourceName)
    if resourceName == 'sessionmanager' or resourceName == 'mapmanager' then
        exports[GetCurrentResourceName()]:CreateLog({
            category = "recursos",
            title = "Registros del Servidor",
            action = "Servidor iniciado",
            color = "blue",
            info = {
                { name = "Estado", value = "El servidor se ha iniciado correctamente" },
                { name = "Hora de inicio", value = os.date('%Y-%m-%d %H:%M:%S') },
            },
            extra = {
                {
                    title = "Información del servidor",
                    data = {
                        { name = "Nombre del servidor", value = GetConvar('sv_hostname', 'Desconocido') },
                        { name = "Máximo de jugadores", value = GetConvar('sv_maxclients', '32') },
                    }
                }
            },
        })
    end
end)