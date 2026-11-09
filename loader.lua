--// ========================================
_G.ANTIENVLOGBYNEVERWON1 = 1
getgenv().ANTIENVLOGBYNEVERWON2 = 1
getgenv().ANTIENVLOGBYNEVERWON3 = 69
_G.ifucantseeanyprintthenufailedtobypassthisenvlogger = true
_G.ANTIENVLOGGERmadebyclickdetectoronneverwon = true

local a = getgenv().ANTIENVLOGBYNEVERWON2 + _G.ANTIENVLOGBYNEVERWON1

if _G.ANTIENVLOGBYNEVERWON1 and getgenv().ANTIENVLOGBYNEVERWON2 and _G.ANTIENVLOGBYNEVERWON1 == 1 and getgenv().ANTIENVLOGBYNEVERWON2 == 1 then
    if a and a ~= 1 or a ~= 3 then
        a = a + a
        if a and a ~= a and a == 4 then
        elseif a == a and a ~= 3 then
            task.spawn(function()
                while true do
                    local b = math.random(1, 1000000)
                    getgenv().ANTIENVLOGBYNEVERWON3 = b + 1
                    getgenv().ANTIENVLOGBYNEVERWON2 = getgenv().ANTIENVLOGBYNEVERWON2 + 1
                    _G.ANTIENVLOGBYNEVERWON1 = _G.ANTIENVLOGBYNEVERWON1 + 1
                    task.wait(math.random() / 10)
                end
            end)
        end
    end
end
--// ========================================
local HUB_NAME   = "Orion Hub"
local CONFIG_URL = "https://raw.githubusercontent.com/alphacellsmart/Orion/main/Config/Head.lua"
local CONFIG_URL_FALLBACK = "https://raw.githubusercontent.com/alphacellsmart/Orion/main/Config/Head.lua"
--// ========================================
local INTERNAL_CONFIG = {
    ShortLinks = {
        "https://snet.blog/w8otovu",
        "https://snet.blog/qu35nv1",
        "https://snet.blog/9v32nal",
        "https://snet.blog/jlnznuh",
        "https://snet.blog/akg7v3w",
    },
    DiscordInvite = "https://discord.gg/1552416753491906650",
    DiscordId     = "1552416753491906650",
    MasterKey     = "ORION-MASTER-BARAO-2026",
    FreeKeyHours  = 12, -- validade das keys do encurtador
}
--// ========================================
-- Idioma PT / EN / ES
--// ========================================
local _lang = "pt"
pcall(function()
    local locale = (game:GetService("LocalizationService").RobloxLocaleId or ""):lower()
    if locale:find("es") then _lang = "es"
    elseif locale:find("pt") then _lang = "pt"
    else _lang = "en" end
end)
pcall(function()
    if isfile and isfile("Orion_Hub/Lang.json") and readfile then
        local ok, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile("Orion_Hub/Lang.json"))
        end)
        if ok and data and data.lang then _lang = data.lang end
    end
end)

local function T(pt, en, es)
    if _lang == "es" then return es or en or pt end
    if _lang == "en" then return en or pt end
    return pt
end

local function saveLang(l)
    _lang = l
    pcall(function()
        if not isfolder("Orion_Hub") then makefolder("Orion_Hub") end
        writefile("Orion_Hub/Lang.json", game:GetService("HttpService"):JSONEncode({ lang = l }))
    end)
end

--// ========================================
local HttpService  = (cloneref or function(x) return x end)(game:GetService("HttpService"))
local Players      = game:GetService("Players")
local CoreGui      = game:GetService("CoreGui")
local LocalPlayer  = Players.LocalPlayer
local FOLDER_NAME  = "Orion_Hub"

local RAW_CONFIG = nil

local function fetchOne(url)
    local ok, raw = pcall(function() return game:HttpGet(url .. "?t=" .. tostring(os.time()), true) end)
    if not ok or type(raw) ~= "string" or raw == "" then
        ok, raw = pcall(function() return game:HttpGet(url, true) end)
        if not ok or type(raw) ~= "string" or raw == "" then return nil end
    end
    raw = raw:gsub("^\239\187\191", "")
    RAW_CONFIG = raw
    local dok, data = pcall(function() return HttpService:JSONDecode(raw) end)
    if dok and type(data) == "table" then return data end
    local cleaned = raw
        :gsub("/%*.-%*/", "")
        :gsub("\n%s*//[^\n]*", "\n")
        :gsub("\n%s*%-%-[^\n]*", "\n")
        :gsub(",%s*([}%]])", "%1")
    dok, data = pcall(function() return HttpService:JSONDecode(cleaned) end)
    if dok and type(data) == "table" then return data end
    return nil
end

local function fetchJSON(...)
    for _, url in ipairs({...}) do
        local data = fetchOne(url)
        if data then return data end
    end
    return nil
end

local externalConfig = fetchJSON(CONFIG_URL, CONFIG_URL_FALLBACK)

local CFG_ICON  = (externalConfig and externalConfig["OpenIcon"]) or "rbxassetid://7733960981"
local CFG_THEME = (externalConfig and externalConfig["ThemeSelect"]) or "darker"
local CFG_SND   = (externalConfig and externalConfig["SoundId"]) or ""
local CFG_VOL   = (externalConfig and externalConfig["SoundVolume"]) or 1

-- Keys: free (12h) + 1 premium permanente
local CFG_FREE = {}
local CFG_PREMIUM = nil
local CFG_KEYS_COUNT = 0
local FREE_SECONDS = (INTERNAL_CONFIG.FreeKeyHours or 12) * 3600

local function addFree(k)
    k = tostring(k or ""):match("^%s*(.-)%s*$")
    if k ~= "" and not CFG_FREE[k] then
        CFG_FREE[k] = true
        CFG_KEYS_COUNT = CFG_KEYS_COUNT + 1
    end
end

if type(externalConfig) == "table" then
    if externalConfig.PremiumKey then
        CFG_PREMIUM = tostring(externalConfig.PremiumKey):match("^%s*(.-)%s*$")
        CFG_KEYS_COUNT = CFG_KEYS_COUNT + 1
    end
    if type(externalConfig.FreeKeys) == "table" then
        for _, k in pairs(externalConfig.FreeKeys) do addFree(k) end
    end
    if type(externalConfig.Keys) == "table" then
        for _, k in pairs(externalConfig.Keys) do addFree(k) end
    end
end
if not CFG_PREMIUM then
    CFG_PREMIUM = "ORION-PREMIUM-BARAO-PERM"
    CFG_KEYS_COUNT = CFG_KEYS_COUNT + 1
end

-- fallback free keys se Head nao tiver
if next(CFG_FREE) == nil then
    for _, k in ipairs({
        "KEY-ALFA-7X-2-B-Z9M4Q",
        "KEY-BETA-3Y-5-C-X7K2V",
        "KEY-GAMA-9Z-8-D-L3P5W",
        "KEY-DELTA-4W-1-E-M8R7T",
        "KEY-OMEGA-6V-3-F-N2S9Y",
    }) do addFree(k) end
end

local MASTER_KEY = INTERNAL_CONFIG.MasterKey
if externalConfig and externalConfig.MasterKey then
    MASTER_KEY = tostring(externalConfig.MasterKey)
end

--// Data
local DataManager = {}
DataManager.__index = DataManager
function DataManager.new()
    local self = setmetatable({}, DataManager)
    if not isfolder(FOLDER_NAME) then makefolder(FOLDER_NAME) end
    return self
end
function DataManager:save(fileName, data)
    pcall(function()
        writefile(FOLDER_NAME .. "/" .. fileName, HttpService:JSONEncode(data))
    end)
end
function DataManager:load(fileName)
    local filePath = FOLDER_NAME .. "/" .. fileName
    if not isfile(filePath) then return nil end
    local ok, result = pcall(function() return HttpService:JSONDecode(readfile(filePath)) end)
    return ok and result or nil
end
local dataManager = DataManager.new()

local function now()
    return os.time()
end

-- valida key
-- premium = permanente
-- free = 12 horas a partir do primeiro uso salvo localmente
local function isValidKey(inputKey)
    if not inputKey then return false, "empty" end
    local cleaned = tostring(inputKey):match("^%s*(.-)%s*$")
    if cleaned == "" then return false, "empty" end

    if CFG_PREMIUM and cleaned == CFG_PREMIUM then
        return true, "premium"
    end

    if CFG_FREE[cleaned] then
        local saved = dataManager:load("FreeKeySession.json")
        if saved and saved.key == cleaned and type(saved.expiresAt) == "number" then
            if now() > saved.expiresAt then
                return false, "expired"
            end
            return true, "free"
        end
        -- primeira vez: ok (sera gravado no confirm)
        return true, "free_new"
    end

    return false, "invalid"
end

local function hasSavedKey()
    -- premium salvo
    local prem = dataManager:load("PremiumKey.json")
    if prem and prem.key and prem.key == CFG_PREMIUM then
        return true, "premium"
    end
    -- free com sessao valida
    local free = dataManager:load("FreeKeySession.json")
    if free and free.key and CFG_FREE[free.key] and type(free.expiresAt) == "number" then
        if now() <= free.expiresAt then
            return true, "free"
        end
    end
    return false
end

local UNIVERSAL_URL = "https://raw.githubusercontent.com/alphacellsmart/Orion/main/Games/Universal/Loader.lua"

local function executarScript()
    _G.__OrionHub_Auth = true
    loadstring(game:HttpGet(UNIVERSAL_URL, true))()
end

if hasSavedKey() then
    executarScript()
    return
end

--// UI lib
local function getExecutorName()
    if identifyexecutor then
        local ok, name = pcall(identifyexecutor)
        if ok and name and name ~= "" then return name end
    end
    if getexecutorname then
        local ok, name = pcall(getexecutorname)
        if ok and name and name ~= "" then return name end
    end
    return "Unknown"
end

local OrionLib = loadstring(game:HttpGet("https://win-ui-online.vercel.app/Lib/Src.lua"))()

local function Notify(content, delay, color)
    return OrionLib:MakeNotify({
        Title   = HUB_NAME,
        Content = content or "",
        Color   = color or Color3.fromRGB(255, 255, 255),
        Delay   = delay or 4,
    })
end

local gameName = ""
pcall(function()
    gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or ""
end)

local Window = OrionLib:Window({
    Title       = HUB_NAME .. (gameName ~= "" and (" | " .. gameName) or "") .. " | " .. getExecutorName(),
    Color       = Color3.fromRGB(16, 185, 129),
    Version     = 1,
    ThemePreset = CFG_THEME,
})

local Float = OrionLib:FloatBtn({
    Icon       = CFG_ICON,
    Color      = Color3.fromRGB(16, 185, 129),
    ColorDark  = Color3.fromRGB(10, 40, 30),
    Size       = 46,
    MainHolder = Window._holder,
})
Window:RegisterFloat(Float)

local TabVerificar = Window:AddTab({
    Name = T("Verificar", "Verify", "Verificar"),
    Icon = "rbxassetid://7733965118",
})
local TabPremium = Window:AddTab({
    Name = T("Premium", "Premium", "Premium"),
    Icon = "rbxassetid://127843403295538",
})
local TabAdmin = Window:AddTab({
    Name = T("Admin", "Admin", "Admin"),
    Icon = "rbxassetid://7734053495",
})

local _acessoJaLiberado = false
local function liberarAcesso()
    if _acessoJaLiberado then return end
    _acessoJaLiberado = true
    pcall(function() Window:DestroyGui() end)
    pcall(function() if Window._holder then Window._holder:Destroy() end end)
    pcall(function()
        local fb = CoreGui:FindFirstChild("WinUIFloatBtn")
        if fb then fb:Destroy() end
    end)
    pcall(function()
        for _, gui in CoreGui:GetChildren() do
            if gui.Name:find("WinUI") or gui.Name:find(HUB_NAME) then gui:Destroy() end
        end
    end)
    task.wait(0.2)
    if CFG_SND ~= "" then
        task.spawn(function()
            local s = Instance.new("Sound")
            s.SoundId = CFG_SND
            s.Volume = CFG_VOL
            s.Parent = game:GetService("SoundService")
            if not s.IsLoaded then s.Loaded:Wait() end
            s:Play()
            game:GetService("Debris"):AddItem(s, 15)
        end)
    end
    task.spawn(function()
        local ok, err = pcall(executarScript)
        if not ok then warn("[" .. HUB_NAME .. "] Erro:", err) end
    end)
end

task.delay(0.5, function()
    Notify(T("Sistema de senha ativo!", "Password system active!", "¡Sistema de contraseña activo!"), 4, Color3.fromRGB(100, 220, 180))
end)

local _shortIdx = 0
local function copyShortLink()
    local links = INTERNAL_CONFIG.ShortLinks or {}
    if #links == 0 then return end
    _shortIdx = (_shortIdx % #links) + 1
    setclipboard(links[_shortIdx])
    Notify(
        T("Link copiado! Abra no navegador para pegar sua senha (válida 12h).", "Link copied! Open in browser (valid 12h).", "¡Enlace copiado! Válido 12h."),
        5,
        Color3.fromRGB(16, 185, 129)
    )
end

local function copyDiscord()
    setclipboard(INTERNAL_CONFIG.DiscordInvite or "")
    Notify(T("Link do Discord copiado!", "Discord link copied!", "¡Enlace de Discord copiado!"), 4, Color3.fromRGB(16, 185, 129))
end

--// Idioma
local SecLang = TabVerificar:AddSection(T("Idioma", "Language", "Idioma"), true)
SecLang:AddButton({
    Title = "🇧🇷  Português (BR)",
    Callback = function()
        saveLang("pt")
        Notify("Idioma: Português (reabra o hub para aplicar tudo)", 4, Color3.fromRGB(16, 185, 129))
    end,
})
SecLang:AddButton({
    Title = "🇺🇸  English",
    Callback = function()
        saveLang("en")
        Notify("Language: English (reopen hub to apply fully)", 4, Color3.fromRGB(16, 185, 129))
    end,
})
SecLang:AddButton({
    Title = "🇪🇸  Español",
    Callback = function()
        saveLang("es")
        Notify("Idioma: Español (reabre el hub para aplicar todo)", 4, Color3.fromRGB(16, 185, 129))
    end,
})

--// Verificar
local SecEntrada = TabVerificar:AddSection(T("Acesso ao Orion Hub", "Orion Hub Access", "Acceso a Orion Hub"), true)
SecEntrada:AddParagraph({
    Title = T("Como entrar", "How to enter", "Cómo entrar"),
    Content = T(
        "• Senha gratuita: válida por 12 horas\n• Premium: acesso permanente\n• Precisa de ajuda? Entre no Discord",
        "• Free password: valid for 12 hours\n• Premium: permanent access\n• Need help? Join Discord",
        "• Contraseña gratis: válida 12 horas\n• Premium: acceso permanente\n• ¿Ayuda? Entra al Discord"
    ),
})
SecEntrada:AddButton({
    Title = T("Obter Senha Gratuita (12h)", "Get Free Password (12h)", "Obtener Contraseña Gratis (12h)"),
    Callback = copyShortLink,
})
SecEntrada:AddButton({
    Title = T("Entrar no Discord", "Join Discord", "Entrar al Discord"),
    Callback = copyDiscord,
})

local inputKey = ""
SecEntrada:AddInput({
    Title = T("Digite a senha:", "Enter the password:", "Ingresa la contraseña:"),
    Content = T("Cole sua senha aqui", "Paste your password here", "Pega tu contraseña aquí"),
    Default = "",
    Callback = function(value) inputKey = value end,
})
SecEntrada:AddButton({
    Title = T("Confirmar Senha", "Confirm Password", "Confirmar Contraseña"),
    Callback = function()
        if not inputKey or inputKey == "" then
            Notify(T("Por favor, digite uma senha", "Please enter a password", "Por favor ingresa una contraseña"), 3, Color3.fromRGB(255, 150, 80))
            return
        end
        local ok, kind = isValidKey(inputKey)
        if not ok then
            local msg
            if kind == "expired" then
                msg = T(
                    "Senha gratuita expirada (12h). Pegue uma nova.",
                    "Free password expired (12h). Get a new one.",
                    "Contraseña gratis expirada (12h). Obtén una nueva."
                )
            else
                msg = T("Senha incorreta, tente novamente", "Wrong password, try again", "Contraseña incorrecta")
            end
            Notify(msg, 4, Color3.fromRGB(255, 80, 80))
            return
        end
        local cleaned = tostring(inputKey):match("^%s*(.-)%s*$")
        if kind == "premium" then
            dataManager:save("PremiumKey.json", { key = cleaned, permanent = true })
            -- limpa sessao free antiga
            pcall(function()
                if isfile(FOLDER_NAME .. "/FreeKeySession.json") then delfile(FOLDER_NAME .. "/FreeKeySession.json") end
            end)
            Notify(T("Premium ativado — acesso permanente!", "Premium activated — permanent access!", "¡Premium activado — acceso permanente!"), 3, Color3.fromRGB(16, 185, 129))
        else
            -- free: grava sessao 12h (se ja existe e valida, reusa; se nova, inicia timer)
            local session = dataManager:load("FreeKeySession.json")
            local expiresAt
            if session and session.key == cleaned and type(session.expiresAt) == "number" and now() <= session.expiresAt then
                expiresAt = session.expiresAt
            else
                expiresAt = now() + FREE_SECONDS
            end
            dataManager:save("FreeKeySession.json", {
                key = cleaned,
                startedAt = now(),
                expiresAt = expiresAt,
                hours = INTERNAL_CONFIG.FreeKeyHours or 12,
            })
            Notify(
                T("Acesso liberado por 12 horas!", "Access granted for 12 hours!", "¡Acceso liberado por 12 horas!"),
                3,
                Color3.fromRGB(16, 185, 129)
            )
        end
        task.wait(1)
        liberarAcesso()
    end,
})

--// Premium tab
local SecPrem = TabPremium:AddSection(T("Acesso Premium", "Premium Access", "Acceso Premium"), true)
SecPrem:AddParagraph({
    Title = T("Premium permanente", "Permanent Premium", "Premium permanente"),
    Content = T(
        "A key Premium libera o hub para sempre neste dispositivo.\nAs senhas do encurtador valem apenas 12 horas.\nFale no Discord para adquirir o Premium.",
        "Premium key unlocks the hub permanently on this device.\nShortener passwords last only 12 hours.\nTalk on Discord to get Premium.",
        "La key Premium libera el hub para siempre.\nLas del acortador duran solo 12 horas.\nHabla en Discord para adquirir Premium."
    ),
})
SecPrem:AddButton({
    Title = T("Entrar no Discord", "Join Discord", "Entrar al Discord"),
    Callback = copyDiscord,
})

--// Admin (sempre pede master)
local _adminUnlocked = false
local _adminInput = ""
local SecAdminLock = TabAdmin:AddSection(T("Área restrita", "Restricted area", "Área restringida"), true)
SecAdminLock:AddParagraph({
    Title = T("Acesso Admin", "Admin Access", "Acceso Admin"),
    Content = T(
        "Digite a senha master toda vez para acessar.",
        "Enter the master password every time to access.",
        "Ingresa la contraseña master cada vez."
    ),
})
SecAdminLock:AddInput({
    Title = T("Senha Master", "Master Password", "Contraseña Master"),
    Content = T("Somente o dono", "Owner only", "Solo el dueño"),
    Default = "",
    Callback = function(v) _adminInput = v end,
})
SecAdminLock:AddButton({
    Title = T("Desbloquear Admin", "Unlock Admin", "Desbloquear Admin"),
    Callback = function()
        local typed = tostring(_adminInput or ""):match("^%s*(.-)%s*$")
        if typed ~= "" and typed == tostring(MASTER_KEY) then
            _adminUnlocked = true
            Notify(T("Admin desbloqueado.", "Admin unlocked.", "Admin desbloqueado."), 3, Color3.fromRGB(16, 185, 129))
        else
            _adminUnlocked = false
            Notify(T("Senha master incorreta.", "Wrong master password.", "Contraseña master incorrecta."), 3, Color3.fromRGB(255, 80, 80))
        end
    end,
})

local SecAdmin = TabAdmin:AddSection(T("Painel Admin", "Admin Panel", "Panel Admin"), true)
local function requireAdmin(fn)
    return function(...)
        if not _adminUnlocked then
            Notify(T("Desbloqueie com a senha master.", "Unlock with master password.", "Desbloquea con la master."), 3, Color3.fromRGB(255, 150, 80))
            return
        end
        return fn(...)
    end
end

SecAdmin:AddButton({
    Title = T("Copiar key Premium", "Copy Premium key", "Copiar key Premium"),
    Callback = requireAdmin(function()
        setclipboard(tostring(CFG_PREMIUM))
        Notify(T("Premium copiada.", "Premium copied.", "Premium copiada."), 3, Color3.fromRGB(16, 185, 129))
    end),
})
SecAdmin:AddButton({
    Title = T("Copiar meu UserId", "Copy my UserId", "Copiar mi UserId"),
    Callback = requireAdmin(function()
        local id = tostring(LocalPlayer and LocalPlayer.UserId or 0)
        setclipboard(id)
        Notify("UserId: " .. id, 3, Color3.fromRGB(16, 185, 129))
    end),
})
SecAdmin:AddButton({
    Title = T("Ver status da sessão", "Session status", "Estado de sesión"),
    Callback = requireAdmin(function()
        local prem = dataManager:load("PremiumKey.json")
        local free = dataManager:load("FreeKeySession.json")
        local msg
        if prem and prem.key then
            msg = T("Premium ativo (permanente)", "Premium active (permanent)", "Premium activo (permanente)")
        elseif free and free.expiresAt then
            local left = math.max(0, free.expiresAt - now())
            local h = math.floor(left / 3600)
            local m = math.floor((left % 3600) / 60)
            msg = T("Free restante: ", "Free remaining: ", "Free restante: ") .. h .. "h " .. m .. "m"
        else
            msg = T("Nenhuma sessão ativa", "No active session", "Sin sesión activa")
        end
        Notify(msg, 5, Color3.fromRGB(16, 185, 129))
    end),
})
SecAdmin:AddParagraph({
    Title = T("Regras", "Rules", "Reglas"),
    Content = T(
        "• Premium = permanente\n• Encurtador = 12 horas\n• Master pede toda vez na aba Admin",
        "• Premium = permanent\n• Shortener = 12 hours\n• Master asked every time in Admin",
        "• Premium = permanente\n• Acortador = 12 horas\n• Master se pide siempre en Admin"
    ),
})

_G.Window = Window
_G.Notify = Notify
_G.CFG_THEME = CFG_THEME
