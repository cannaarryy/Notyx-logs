Config = {}

Config.FrameWork = {
    Type = "qbx",                          -- Tipo de framework: "qb", "qbx", "esx"
    ResourceName = "qbx_core",             -- Nombre del recurso del framework: "qb-core", "qbx_core", "es_extended"
    Language = "en",                       -- Puedes añadir más idiomas en Shared/Locales, solo copia en.json y renómbralo/tradúcelo
}

Config.Logs = {
    UseScreenShot = true,                  -- Activar si quieres capturas de pantalla en los mensajes de log
    ServerName = "NOTYX Network",          -- Nombre de tu servidor que aparecerá en los logs
    ServerLogo = "https://r2.fivemanage.com/RwsYoPrGvmv96ZP9gRuEe/c1189fc637f22427a124c6ad273340fc.jpg",
    Identifiers = {                        -- Identificadores que se mostrarán en los logs
        name = true,
        source = true,
        steam = true,
        license = true,
        discord = true,
        characterName = true,
        citizenId = true
    },
}

Config.Colors = {
    ["default"]    = 16711680,
    ["blue"]       = 25087,
    ["green"]      = 762640,
    ["white"]      = 16777215,
    ["black"]      = 0,
    ["orange"]     = 16743168,
    ["lightgreen"] = 65309,
    ["yellow"]     = 15335168,
    ["turqois"]    = 62207,
    ["pink"]       = 16711900,
    ["red"]        = 16711680,
}