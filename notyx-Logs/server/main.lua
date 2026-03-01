-- Tabla de colores para embeds de Discord (nombres en inglés porque son claves)
local colors = {
    ['default'] = 0,
    ['aqua'] = 1752220,
    ['darkaqua'] = 1146986,
    ['green'] = 5763719,
    ['darkgreen'] = 2067276,
    ['blue'] = 3447003,
    ['darkblue'] = 2123412,
    ['purple'] = 10181046,
    ['darkpurple'] = 7419530,
    ['luminousvividpink'] = 15277667,
    ['darkvividpink'] = 11342935,
    ['gold'] = 15844367,
    ['darkgold'] = 12745742,
    ['orange'] = 15105570,
    ['darkorange'] = 11027200,
    ['red'] = 15548997,
    ['darkred'] = 10038562,
    ['grey'] = 9807270,
    ['darkgrey'] = 9936031,
    ['darkergrey'] = 8359053,
    ['lightgrey'] = 12370112,
    ['navy'] = 3426654,
    ['darknavy'] = 2899536,
    ['yellow'] = 16776960
}

Webhooks = {
    ["default"] = "https://discord.com/api/webhooks/",
    ["screenshots"] = "https://discord.com/api/webhooks/",
            ["txadmin"] = "https://discord.com/api/webhooks/",
        ["chat"] = "https://discord.com/api/webhooks/",
        ["join/leave"] = "https://discord.com/api/webhooks/",
        ["resources"] = "https://discord.com/api/webhooks/",
    ["explosions"] = "https://discord.com/api/webhooks/",
}

-- Función principal para crear y enviar logs a Discord
local function CreateLog(resource, data)
    if not data then return end

    local log_type = "general"
    local fields = {}

    -- Construye bloque de identificadores del jugador
    local function buildIdentifierBlock(playerId)
        local src = playerId
        local name = GetPlayerName(src) or ("Desconocido [" .. tostring(src) .. "]")

        local characterName, citizenId = GetPlayerData(src)

        local license = GetPlayerIdentifierByType(src, 'license') or 'license: Desconocido'
        local license2 = GetPlayerIdentifierByType(src, 'license2') or 'license2: Desconocido'
        local discord = GetPlayerIdentifierByType(src, 'discord') or 'No vinculado'
        local steam = GetPlayerIdentifierByType(src, 'steam') or 'No vinculado'

        local lines = {}
        if Config.Logs.Identifiers.name then
            lines[#lines+1] = string.format("Nombre: %s", name)
        end
        if Config.Logs.Identifiers.steam then
            lines[#lines+1] = string.format("Steam: %s", steam)
        end
        if Config.Logs.Identifiers.license then
            lines[#lines+1] = string.format(license)
            lines[#lines+1] = string.format(license2)
        end
        if Config.Logs.Identifiers.discord then
            lines[#lines+1] = string.format(discord)
        end

        local identifierBlock = table.concat(lines, "\n")

        local charLines = {}
        if Config.Logs.Identifiers.characterName then
            charLines[#charLines+1] = string.format("Nombre del personaje: %s", characterName or name)
        end
        if Config.Logs.Identifiers.citizenId then
            charLines[#charLines+1] = string.format("ID de ciudadano: %s", citizenId or 'N/A')
        end
        if Config.Logs.Identifiers.source then
            charLines[#charLines+1] = string.format("Fuente: %s", tostring(src))
        end

        local characterBlock = table.concat(charLines, "\n")

        return identifierBlock, characterBlock
    end

    if data.players and type(data.players) == "table" then
        if #data.players == 1 then
            log_type = "singleplayer"
        elseif #data.players > 1 then
            log_type = "multiplayer"
        end

        for _, v in ipairs(data.players) do
            local pid = v.id
            local role = v.role or "Jugador"

            if pid and GetPlayerName(pid) then
                local identifierBlock, characterBlock = buildIdentifierBlock(pid)

                if identifierBlock ~= "" then
                    fields[#fields+1] = {
                        name = string.format("%s - Información de identificadores", role),
                        value = "```"..identifierBlock.."```",
                        inline = false,
                    }
                end

                if characterBlock ~= "" then
                    fields[#fields+1] = {
                        name = string.format("%s - Información del personaje", role),
                        value = "```"..characterBlock.."```",
                        inline = false,
                    }
                end
            else
                fields[#fields+1] = {
                    name = string.format("%s Información", role),
                    value = "```"..tostring(pid).."```",
                    inline = false,
                }
            end
        end
    end

    if not data.category then
        DebugPrint("Falta la categoría. Recurso: " .. (resource or GetCurrentResourceName()))
        return
    end

    if not Webhooks[data.category] then
        DebugPrint("No existe webhook para la categoría: " .. data.category .. " → Enviando al webhook por defecto.")
        Webhooks[data.category] = Webhooks["default"]
    end

    if not data.title then
        DebugPrint("Falta el título. Categoría: " .. data.category)
        return
    end

    local extraInfoText = ""
    if data.info and type(data.info) == "table" then
        for i = 1, #data.info do
            local entry = data.info[i]
            if entry.value then
                local value
                if type(entry.value) == "table" then
                    value = DumpTable(entry.value)
                else
                    value = tostring(entry.value)
                end
                extraInfoText = extraInfoText .. string.format("\n%s: %s", entry.name or "Información", value)
            end
        end
    end

    if extraInfoText ~= "" then
        fields[#fields+1] = {
            name = data.action and (data.action .. " - Información") or "Información del log",
            value = "```"..extraInfoText.."```",
            inline = false,
        }
    end

    if data.extra and type(data.extra) == "table" then
        for extraIndex, extraSection in ipairs(data.extra) do
            if type(extraSection) == "table" then
                local extraText = ""
                local sectionTitle = extraSection.title or ("Información extra " .. extraIndex)
                local sectionData = extraSection.data or extraSection

                local dataToProcess = sectionData

                if type(dataToProcess) == "table" then
                    for i = 1, #dataToProcess do
                        local entry = dataToProcess[i]
                        if entry and entry.value then
                            local value
                            if type(entry.value) == "table" then
                                value = DumpTable(entry.value)
                            else
                                value = tostring(entry.value)
                            end
                            extraText = extraText .. string.format("\n%s: %s", entry.name or "Información", value)
                        end
                    end

                    if extraText ~= "" then
                        fields[#fields+1] = {
                            name = sectionTitle,
                            value = "```"..extraText.."```",
                            inline = false,
                        }
                    end
                end
            end
        end
    end

    -- Footer del embed
    local footerText = (Config.Logs.ServerName or "Servidor") .. " - " .. os.date("%c") .. " (Hora del servidor)"
    if resource then
        footerText = footerText .. " | Registro generado por: " .. resource
    end

    local embed = {
        ["color"] = colors[string.lower(data.color or "")] or colors["default"],
        ["title"] = data.action and (data.title .. " (" .. data.action .. ")") or data.title,
        ["description"] = "",
        ["fields"] = fields,
        ["footer"] = {
            ["text"] = footerText,
        },
    }

    -- Captura de pantalla (solo si está activada y hay jugador objetivo)
    if Config.Logs.UseScreenShot and GetResourceState("screenshot-basic") == "started" and data.takeScreenshot then
        if (log_type == "singleplayer" or log_type == "multiplayer") then
            local target = data.screenshotTargetId or (data.players and data.players[1] and data.players[1].id)
            if target and GetPlayerName(target) then
                local ready = false
                local okPing, pingResult = pcall(function()
                    return lib.callback.await('DiscordLogs:Client:CB:Ping', target)
                end)
                if okPing and pingResult then
                    ready = true
                end

                if ready then
                    local ok, screenshot = pcall(function()
                        return lib.callback.await("notyx-Logs:client:GetScreenshot", target, Webhooks["screenshots"])
                    end)

                    if ok and screenshot then
                        embed["image"] = {
                            ["url"] = screenshot
                        }
                    else
                        DebugPrint("Fallo al obtener captura vía callback del cliente para " .. GetPlayerName(target) .. " [" .. target .. "] - intentando fallback del servidor")

                        local hasFallback = false
                        local okCheck = pcall(function()
                            return exports['screenshot-basic'] and exports['screenshot-basic'].requestClientScreenshotUpload ~= nil
                        end)
                        if okCheck then hasFallback = true end

                        if hasFallback then
                            local function tryServerUpload(fieldName)
                                local done, url = false, nil
                                local timeout, maxTimeout = 0, 120
                                local okCall = pcall(function()
                                    exports['screenshot-basic']:requestClientScreenshotUpload(target, Webhooks["screenshots"], {
                                        fileField = fieldName,
                                        encoding = 'webp',
                                        quality = 80,
                                    }, function(data)
                                        local success, result = pcall(function()
                                            local decoded = json.decode(data)
                                            return decoded and decoded.attachments and decoded.attachments[1] and decoded.attachments[1].url
                                        end)
                                        if success and result then
                                            url = result
                                        else
                                            print(string.format("[notyx-logs] Fallo al decodificar fallback del servidor (campo=%s). Respuesta cruda: %s", tostring(fieldName), tostring(data)))
                                        end
                                        done = true
                                    end)
                                end)
                                if not okCall then
                                    print("[notyx-logs] Export de fallback del servidor no disponible en screenshot-basic")
                                    return nil
                                end

                                while not done and timeout < maxTimeout do
                                    Wait(500)
                                    timeout = timeout + 1
                                end

                                if not done then
                                    print(string.format("[notyx-logs] Fallback del servidor caducó (campo=%s)", tostring(fieldName)))
                                    return nil
                                end

                                return url
                            end

                            local url = tryServerUpload('files[]') or tryServerUpload('file')
                            if url then
                                embed["image"] = { ["url"] = url }
                            else
                                DebugPrint("No se pudo tomar captura de " .. GetPlayerName(target) .. " [" .. target .. "]")
                            end
                        else
                            DebugPrint("No se encontró export de fallback del servidor en screenshot-basic; omitiendo fallback")
                        end
                    end
                else
                    DebugPrint("Cliente no listo para captura: " .. GetPlayerName(target) .. " [" .. target .. "]")
                end
            else
                DebugPrint("Fallo al tomar captura: ID de jugador inválido o desconectado [" .. tostring(target) .. "]")
            end
        end
    end

    -- Envío final al webhook
    PerformHttpRequest(
        Webhooks[data.category],
        function(err, text, headers) end,
        'POST',
        json.encode({ 
            ["username"] = Config.Logs.ServerName, 
            ["avatar_url"] = Config.Logs.ServerLogo, 
            ["embeds"] = { embed } 
        }),
        { ['Content-Type'] = 'application/json' }
    )
end

-- Export público
exports("CreateLog", function(data)
    CreateLog(GetInvokingResource() ~= GetCurrentResourceName() and GetInvokingResource() or nil, data)

end)
