-- Jugador baneado
AddEventHandler('txAdmin:events:playerBanned', function(data)
    if data.targetNetId then
        exports[GetCurrentResourceName()]:CreateLog({
            category = "ban",
            title = "Registros txAdmin",
            action = "Jugador baneado",
            color = "red",
            players = {
                { id = data.targetNetId, role = "Objetivo" }
            },
            info = {
                { name = "ID de acción", value = data.actionId },
                { name = "Nombre del administrador", value = data.author },
                { name = "Nombre del objetivo", value = data.targetName },
                { name = "Motivo", value = data.reason },
            },
            extra = {
                {
                    title = "Duración del ban y expiración",
                    data = {
                        { name = "Duración", value = data.durationInput or "Permanente" },
                        { name = "Expiración", value = data.expiration and os.date("%Y-%m-%d %H:%M:%S", data.expiration) or "Permanente" },
                        { name = "Duración traducida", value = data.durationTranslated or "N/A" },
                    }
                },
                {
                    title = "Identificadores del objetivo",
                    data = {
                        { name = "IDs del objetivo", value = table.concat(data.targetIds or {}, ", ") },
                        { name = "\nHWIDs del objetivo", value = table.concat(data.targetHwids or {}, ", ") or "Ninguno" },
                    }
                }
            },
            takeScreenshot = true,
        })
    else
        exports[GetCurrentResourceName()]:CreateLog({
            category = "ban",
            title = "Registros txAdmin",
            action = "Identificadores baneados",
            color = "red",
            info = {
                { name = "ID de acción", value = data.actionId },
                { name = "Nombre del administrador", value = data.author },
                { name = "Motivo", value = data.reason },
            },
            extra = {
                {
                    title = "Detalles del ban",
                    data = {
                        { name = "Mensaje de expulsión", value = data.kickMessage or "N/A" },
                        { name = "Duración", value = data.durationInput or "Permanente" },
                        { name = "Expiración", value = data.expiration and os.date("%Y-%m-%d %H:%M:%S", data.expiration) or "Permanente" },
                    }
                },
                {
                    title = "Identificadores baneados",
                    data = {
                        { name = "IDs del objetivo", value = table.concat(data.targetIds or {}, ", ") },
                        { name = "\nHWIDs del objetivo", value = table.concat(data.targetHwids or {}, ", ") or "Ninguno" },
                    }
                }
            },
        })
    end
end)

-- Jugador expulsado (kick)
AddEventHandler('txAdmin:events:playerKicked', function(data)
    if data.target == -1 then
        exports[GetCurrentResourceName()]:CreateLog({
            category = "kick",
            title = "Registros txAdmin",
            action = "Expulsión masiva - Todos los jugadores",
            color = "orange",
            info = {
                { name = "Nombre del administrador", value = data.author },
                { name = "Motivo", value = data.reason },
            },
            extra = {
                {
                    title = "Detalles de la expulsión",
                    data = {
                        { name = "Mensaje de desconexión", value = data.dropMessage or "N/A" },
                        { name = "Objetivo", value = "Todos los jugadores" },
                    }
                }
            },
        })
    else
        exports[GetCurrentResourceName()]:CreateLog({
            category = "kick",
            title = "Registros txAdmin",
            action = "Jugador expulsado",
            color = "orange",
            players = {
                { id = data.target, role = "Objetivo" },
            },
            info = {
                { name = "Nombre del administrador", value = data.author },
                { name = "Motivo", value = data.reason },
            },
            extra = {
                {
                    title = "Detalles de la expulsión",
                    data = {
                        { name = "Mensaje de desconexión", value = data.dropMessage or "N/A" },
                    }
                }
            },
            takeScreenshot = true,
        })
    end
end)

-- Jugador advertido (warn)
AddEventHandler('txAdmin:events:playerWarned', function(data)
    local targetId = data.targetNetId

    if targetId then
        -- Advertencia a jugador conectado
        exports[GetCurrentResourceName()]:CreateLog({
            category = "warn",
            title = "Registros txAdmin",
            action = "Jugador advertido (Conectado)",
            color = "yellow",
            players = {
                { id = targetId, role = "Objetivo" },
            },
            info = {
                { name = "ID de acción", value = data.actionId },
                { name = "Nombre del administrador", value = data.author },
                { name = "Nombre del objetivo", value = data.targetName },
                { name = "Motivo", value = data.reason },
            },
            extra = {
                {
                    title = "Identificadores del objetivo",
                    data = {
                        { name = "IDs del objetivo", value = table.concat(data.targetIds or {}, ", ") },
                    }
                }
            },
            takeScreenshot = true,
        })
    else
        -- Advertencia a jugador desconectado
        exports[GetCurrentResourceName()]:CreateLog({
            category = "warn",
            title = "Registros txAdmin",
            action = "Jugador advertido (Desconectado)",
            color = "yellow",
            info = {
                { name = "ID de acción", value = data.actionId },
                { name = "Nombre del administrador", value = data.author },
                { name = "Nombre del objetivo", value = data.targetName },
                { name = "Motivo", value = data.reason },
            },
            extra = {
                {
                    title = "Identificadores del objetivo",
                    data = {
                        { name = "IDs del objetivo", value = table.concat(data.targetIds or {}, ", ") },
                    }
                }
            },
        })
    end
end)

-- Anuncio del servidor
AddEventHandler('txAdmin:events:announcement', function(data)
    exports[GetCurrentResourceName()]:CreateLog({
        category = "txadmin",
        title = "Registros txAdmin",
        action = "Anuncio",
        color = "blue",
        info = {
            { name = "Nombre del administrador", value = data.author },
            { name = "Mensaje", value = data.message },
        },
    })
end)

-- Apagado del servidor
AddEventHandler('txAdmin:events:serverShuttingDown', function(data)
    exports[GetCurrentResourceName()]:CreateLog({
        category = "txadmin",
        title = "Registros txAdmin",
        action = "Servidor apagándose",
        color = "red",
        info = {
            { name = "Activado por", value = data.author },
            { name = "Tipo", value = data.author == "txAdmin" and "Automático" or "Manual" },
        },
        extra = {
            {
                title = "Detalles del apagado",
                data = {
                    { name = "Mensaje", value = data.message },
                    { name = "Retraso", value = data.delay .. " ms" },
                }
            }
        },
    })
end)

-- Reinicio programado (advertencia)
AddEventHandler('txAdmin:events:scheduledRestart', function(data)
    local minutes = math.floor(data.secondsRemaining / 60)

    exports[GetCurrentResourceName()]:CreateLog({
        category = "txadmin",
        title = "Registros txAdmin",
        action = "Advertencia de reinicio programado",
        color = "orange",
        info = {
            { name = "Tiempo restante", value = minutes .. " minuto(s)" },
            { name = "Segundos restantes", value = data.secondsRemaining .. " segundos" },
        },
        extra = {
            {
                title = "Mensaje de reinicio",
                data = {
                    { name = "Mensaje", value = data.translatedMessage },
                }
            }
        },
    })
end)

-- Reinicio programado omitido
AddEventHandler('txAdmin:events:scheduledRestartSkipped', function(data)
    exports[GetCurrentResourceName()]:CreateLog({
        category = "txadmin",
        title = "Registros txAdmin",
        action = "Reinicio programado omitido",
        color = "green",
        info = {
            { name = "Nombre del administrador", value = data.author },
            { name = "Programado para", value = math.floor(data.secondsRemaining / 60) .. " minuto(s)" },
        },
        extra = {
            {
                title = "Detalles de la omisión",
                data = {
                    { name = "Tipo", value = data.temporary and "Temporal" or "Configurado" },
                    { name = "Segundos restantes", value = data.secondsRemaining .. " segundos" },
                }
            }
        },
    })
end)

-- Jugador en lista blanca
AddEventHandler('txAdmin:events:whitelistPlayer', function(data)
    local actionColor = data.action == "added" and "green" or "red"
    local actionTitle = data.action == "added" and "Jugador añadido a lista blanca" or "Jugador eliminado de lista blanca"

    exports[GetCurrentResourceName()]:CreateLog({
        category = "txadmin",
        title = "Registros txAdmin",
        action = actionTitle,
        color = actionColor,
        info = {
            { name = "Acción", value = string.upper(data.action) },
            { name = "Nombre del administrador", value = data.adminName },
            { name = "Nombre del jugador", value = data.playerName },
        },
        extra = {
            {
                title = "Identificadores del jugador",
                data = {
                    { name = "Licencia", value = data.license },
                }
            }
        },
    })
end)

-- Pre-aprobación de lista blanca
AddEventHandler('txAdmin:events:whitelistPreApproval', function(data)
    local actionColor = data.action == "added" and "green" or "red"
    local actionTitle = data.action == "added" and "Pre-aprobación añadida" or "Pre-aprobación eliminada"

    exports[GetCurrentResourceName()]:CreateLog({
        category = "txadmin",
        title = "Registros txAdmin",
        action = actionTitle,
        color = actionColor,
        info = {
            { name = "Acción", value = string.upper(data.action) },
            { name = "Nombre del administrador", value = data.adminName },
        },
        extra = {
            {
                title = "Detalles de pre-aprobación",
                data = {
                    { name = "Identificador", value = data.identifier },
                    { name = "Nombre del jugador", value = data.playerName or "N/A" },
                }
            }
        },
    })
end)

-- Solicitud de lista blanca
AddEventHandler('txAdmin:events:whitelistRequest', function(data)
    local actionColors = {
        requested = "blue",
        approved = "green",
        denied = "red",
        deniedAll = "darkred"
    }

    local actionTitles = {
        requested = "Solicitud de lista blanca",
        approved = "Solicitud de lista blanca aprobada",
        denied = "Solicitud de lista blanca denegada",
        deniedAll = "Todas las solicitudes de lista blanca denegadas"
    }

    if data.action == "deniedAll" then
        exports[GetCurrentResourceName()]:CreateLog({
            category = "txadmin",
            title = "Registros txAdmin",
            action = actionTitles[data.action],
            color = actionColors[data.action],
            info = {
                { name = "Acción", value = "TODAS LAS SOLICITUDES DENEGADAS" },
                { name = "Nombre del administrador", value = data.adminName or "Sistema" },
            },
        })
    else
        exports[GetCurrentResourceName()]:CreateLog({
            category = "txadmin",
            title = "Registros txAdmin",
            action = actionTitles[data.action],
            color = actionColors[data.action],
            info = {
                { name = "Acción", value = string.upper(data.action) },
                { name = "ID de solicitud", value = data.requestId or "N/A" },
                { name = "Nombre del jugador", value = data.playerName or "Desconocido" },
            },
            extra = {
                {
                    title = "Detalles de la solicitud",
                    data = {
                        { name = "Licencia", value = data.license or "N/A" },
                        { name = "Nombre del administrador", value = data.adminName or "N/A" },
                    }
                }
            },
        })
    end
end)

-- Jugador curado (healed)
AddEventHandler('txAdmin:events:playerHealed', function(data)
    if data.target == -1 then
        -- Curar a todos los jugadores
        exports[GetCurrentResourceName()]:CreateLog({
            category = "txadmin",
            title = "Registros txAdmin",
            action = "Todos los jugadores curados",
            color = "green",
            info = {
                { name = "Nombre del administrador", value = data.author },
                { name = "Objetivo", value = "Todos los jugadores" },
            },
        })
    else
        -- Curar a un jugador específico
        exports[GetCurrentResourceName()]:CreateLog({
            category = "txadmin",
            title = "Registros txAdmin",
            action = "Jugador curado",
            color = "green",
            players = {
                { id = data.target, role = "Objetivo" },
            },
            info = {
                { name = "Nombre del administrador", value = data.author },
            },
        })
    end
end)

-- Mensaje directo a jugador
AddEventHandler('txAdmin:events:playerDirectMessage', function(data)
    exports[GetCurrentResourceName()]:CreateLog({
        category = "txadmin",
        title = "Registros txAdmin",
        action = "Mensaje directo enviado",
        color = "blue",
        players = {
            { id = data.target, role = "Destinatario" },
        },
        info = {
            { name = "Nombre del administrador", value = data.author },
        },
        extra = {
            {
                title = "Contenido del mensaje",
                data = {
                    { name = "Mensaje", value = data.message },
                }
            }
        },
    })
end)

-- Acción revocada
AddEventHandler('txAdmin:events:actionRevoked', function(data)
    exports[GetCurrentResourceName()]:CreateLog({
        category = "txadmin",
        title = "Registros txAdmin",
        action = "Acción revocada",
        color = "purple",
        info = {
            { name = "ID de acción", value = data.actionId },
            { name = "Tipo de acción", value = string.upper(data.actionType) },
            { name = "Revocada por", value = data.revokedBy },
        },
        extra = {
            {
                title = "Detalles de la acción original",
                data = {
                    { name = "Motivo original", value = data.actionReason },
                    { name = "Autor original", value = data.actionAuthor },
                    { name = "Nombre del jugador", value = data.playerName or "N/A" },
                }
            },
            {
                title = "Identificadores del jugador",
                data = {
                    { name = "IDs del jugador", value = table.concat(data.playerIds or {}, ", ") },
                    { name = "HWIDs del jugador", value = table.concat(data.playerHwids or {}, ", ") or "Ninguno" },
                }
            }
        },
    })
end)

-- Autenticación de administrador
AddEventHandler('txAdmin:events:adminAuth', function(data)
    if data.netid == -1 then
        -- Forzar reautenticación de todos los admins
        exports[GetCurrentResourceName()]:CreateLog({
            category = "txadmin",
            title = "Registros txAdmin",
            action = "Forzar reautenticación de administradores",
            color = "orange",
            info = {
                { name = "Acción", value = "Todos los administradores forzados a reautenticarse" },
            },
        })
    else
        local actionTitle = data.isAdmin and "Administrador autenticado" or "Permiso de administrador revocado"
        local actionColor = data.isAdmin and "green" or "red"

        exports[GetCurrentResourceName()]:CreateLog({
            category = "txadmin",
            title = "Registros txAdmin",
            action = actionTitle,
            color = actionColor,
            players = {
                { id = data.netid, role = "Administrador" },
            },
            info = {
                { name = "Estado", value = data.isAdmin and "Autenticado" or "Revocado" },
            },
            extra = {
                {
                    title = "Detalles del administrador",
                    data = {
                        { name = "Nombre de usuario", value = data.username or "N/A" },
                    }
                }
            },
        })
    end
end)

-- Lista de administradores actualizada
AddEventHandler('txAdmin:events:adminsUpdated', function(data)
    local onlineAdmins = {}
    if data and type(data) == "table" then
        for i, netid in ipairs(data) do
            if GetPlayerName(netid) then
                table.insert(onlineAdmins, GetPlayerName(netid) .. " [" .. netid .. "]")
            end
        end
    end

    exports[GetCurrentResourceName()]:CreateLog({
        category = "txadmin",
        title = "Registros txAdmin",
        action = "Lista de administradores actualizada",
        color = "blue",
        info = {
            { name = "Cantidad de administradores conectados", value = #onlineAdmins },
        },
        extra = {
            {
                title = "Lista de administradores conectados",
                data = {
                    { name = "Administradores", value = table.concat(onlineAdmins, ", ") or "Ninguno" },
                }
            }
        },
    })
end)

-- Configuración cambiada
AddEventHandler('txAdmin:events:configChanged', function(data)
    exports[GetCurrentResourceName()]:CreateLog({
        category = "txadmin",
        title = "Registros txAdmin",
        action = "Configuración cambiada",
        color = "blue",
        info = {
            { name = "Estado", value = "La configuración de txAdmin ha sido actualizada" },
        },
        extra = {
            {
                title = "Detalles del cambio",
                data = {
                    { name = "Nota", value = "Los ajustes en el juego podrían haber cambiado (por ejemplo, idioma)" },
                }
            }
        },
    })
end)

-- Comando ejecutado en consola
AddEventHandler('txAdmin:events:consoleCommand', function(data)
    exports[GetCurrentResourceName()]:CreateLog({
        category = "txadmin",
        title = "Registros txAdmin",
        action = "Comando de consola ejecutado",
        color = "grey",
        info = {
            { name = "Nombre del administrador", value = data.author },
            { name = "Canal", value = string.upper(data.channel) },
        },
        extra = {
            {
                title = "Detalles del comando",
                data = {
                    { name = "Comando", value = data.command },
                }
            }
        },
    })
end)