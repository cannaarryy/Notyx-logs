lib.callback.register('notyx-Logs:client:GetScreenshot', function(webhook)
    if not webhook then return nil end

    local function tryUpload(fieldName)
        local uploaded = false
        local image
        local timeout = 0
        local maxTimeout = 100

        exports['screenshot-basic']:requestScreenshotUpload(webhook, fieldName, { encoding = 'webp', quality = 80 }, function(data)
            if not data or data == '' then
                print("[notyx-Logs] Respuesta vacía del webhook de Discord (campo="..tostring(fieldName).."). Verifica la URL y permisos.")
                uploaded = true
                return
            end

            local success, result = pcall(function()
                local decoded = json.decode(data)
                if decoded and decoded.message then
                    print("[notyx-Logs] Error en webhook de Discord: "..tostring(decoded.message).." (campo="..tostring(fieldName)..")")
                    return nil
                end
                return decoded and decoded.attachments and decoded.attachments[1] and decoded.attachments[1].url
            end)

            if success and result then
                image = result
                uploaded = true
            else
                print("[notyx-Logs] Fallo al decodificar respuesta de captura (campo="..tostring(fieldName).."). Respuesta cruda: "..tostring(data))
                uploaded = true
            end
        end)

        while not uploaded and timeout < maxTimeout do
            Wait(500)
            timeout = timeout + 1
        end

        if timeout >= maxTimeout then
            print("[notyx-Logs] Subida de captura caducó después de 50 segundos ("..tostring(fieldName)..")")
            return nil
        end

        return image
    end

    local image = tryUpload('files[]')
    if not image then
        image = tryUpload('file')
    end

    return image
end)

lib.callback.register('notyx-Logs:Client:CB:Ping', function()
    return true
end)