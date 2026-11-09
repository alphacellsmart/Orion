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
local HUB_NAME = "Orion Hub"
local CONFIG_URL = "https://raw.githubusercontent.com/alphacellsmart/Orion/main/Config/Head.lua"
local UNIVERSAL_URL = "https://raw.githubusercontent.com/alphacellsmart/Orion/main/Games/Universal/Loader.lua"

local MASTER_KEY  = "ORION-MASTER-BARAO-2026"
local PREMIUM_KEY = "ORION-PREMIUM-BARAO-PERM"
local FREE_HOURS  = 12
local FREE_SECONDS = FREE_HOURS * 3600

local INTERNAL_CONFIG = {
    ShortLinks = {
        "https://snet.blog/w8otovu",
        "https://snet.blog/qu35nv1",
        "https://snet.blog/9v32nal",
        "https://snet.blog/jlnznuh",
        "https://snet.blog/akg7v3w",
    },
    DiscordInvite = "https://discord.gg/1552416753491906650",
}

--// idioma
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

local HttpService = (cloneref or function(x) return x end)(game:GetService("HttpService"))
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local FOLDER_NAME = "Orion_Hub"

local function fetchJSON(url)
    local ok, raw = pcall(function() return game:HttpGet(url .. "?t=" .. tostring(os.time()), true) end)
    if not ok or type(raw) ~= "string" or raw == "" then
        ok, raw = pcall(function() return game:HttpGet(url, true) end)
    end
    if not ok or type(raw) ~= "string" or raw == "" then return nil end
    raw = raw:gsub("^\239\187\191", "")
    local dok, data = pcall(function() return HttpService:JSONDecode(raw) end)
    if dok and type(data) == "table" then return data end
    local cleaned = raw:gsub("/%*.-%*/", ""):gsub("\n%s*//[^\n]*", "\n"):gsub("\n%s*%-%-[^\n]*", "\n"):gsub(",%s*([}%]])", "%1")
    dok, data = pcall(function() return HttpService:JSONDecode(cleaned) end)
    if dok and type(data) == "table" then return data end
    return nil
end

local externalConfig = fetchJSON(CONFIG_URL)
local CFG_ICON  = (externalConfig and externalConfig.OpenIcon) or "rbxassetid://7733960981"
local CFG_THEME = (externalConfig and externalConfig.ThemeSelect) or "Carbon"
local CFG_SND   = (externalConfig and externalConfig.SoundId) or ""
local CFG_VOL   = (externalConfig and externalConfig.SoundVolume) or 1

if externalConfig then
    if type(externalConfig.MasterKey) == "string" and externalConfig.MasterKey ~= "" then
        MASTER_KEY = externalConfig.MasterKey
    end
    if type(externalConfig.PremiumKey) == "string" and externalConfig.PremiumKey ~= "" then
        PREMIUM_KEY = externalConfig.PremiumKey
    end
end

local FREE_KEYS = {}
local function addFree(k)
    k = tostring(k or ""):match("^%s*(.-)%s*$")
    if k ~= "" then FREE_KEYS[k] = true end
end
if externalConfig and type(externalConfig.FreeKeys) == "table" then
    for _, k in pairs(externalConfig.FreeKeys) do addFree(k) end
end
if next(FREE_KEYS) == nil then
    for _, k in ipairs({
        "KEY-ALFA-7X-2-B-Z9M4Q",
        "KEY-BETA-3Y-5-C-X7K2V",
        "KEY-GAMA-9Z-8-D-L3P5W",
        "KEY-DELTA-4W-1-E-M8R7T",
        "KEY-OMEGA-6V-3-F-N2S9Y",
    }) do addFree(k) end
end

local DataManager = {}
DataManager.__index = DataManager
function DataManager.new()
    local self = setmetatable({}, DataManager)
    pcall(function() if not isfolder(FOLDER_NAME) then makefolder(FOLDER_NAME) end end)
    return self
end
function DataManager:save(name, data)
    pcall(function() writefile(FOLDER_NAME .. "/" .. name, HttpService:JSONEncode(data)) end)
end
function DataManager:load(name)
    local path = FOLDER_NAME .. "/" .. name
    if not isfile or not isfile(path) then return nil end
    local ok, result = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
    return ok and result or nil
end
local dataManager = DataManager.new()

local function now()
    return os.time()
end

local function cleanKey(s)
    return tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", ""):gsub("[\r\n]", "")
end

-- master / premium / free
local function isValidKey(inputKey)
    local cleaned = cleanKey(inputKey)
    if cleaned == "" then return false, "empty" end

    if cleaned == cleanKey(MASTER_KEY) then
        return true, "master"
    end
    if cleaned == cleanKey(PREMIUM_KEY) then
        return true, "premium"
    end
    if FREE_KEYS[cleaned] then
        local saved = dataManager:load("FreeKeySession.json")
        if saved and cleanKey(saved.key) == cleaned and type(saved.expiresAt) == "number" then
            if now() > saved.expiresAt then
                return false, "expired"
            end
            return true, "free"
        end
        return true, "free_new"
    end
    return false, "invalid"
end

local function hasSavedKey()
    local prem = dataManager:load("PremiumKey.json")
    if prem and cleanKey(prem.key) == cleanKey(PREMIUM_KEY) then
        return true, "premium"
    end
    local free = dataManager:load("FreeKeySession.json")
    if free and FREE_KEYS[cleanKey(free.key)] and type(free.expiresAt) == "number" and now() <= free.expiresAt then
        return true, "free"
    end
    return false
end

local function executarScript()
    _G.__OrionHub_Auth = true
    local ok, err = pcall(function()
        local src = game:HttpGet(UNIVERSAL_URL, true)
        assert(type(src) == "string" and #src > 100, "Universal vazio")
        local fn, cerr = loadstring(src)
        assert(fn, tostring(cerr))
        fn()
    end)
    if not ok then
        warn("[Orion Hub] Erro ao carregar Universal:", err)
    end
    return ok, err
end

do
    local okS, kindS = hasSavedKey()
    if okS then
        if kindS == "premium" then
            _G.__OrionSession = { type = "premium", label = "Premium", expiresAt = nil }
        else
            local free = dataManager:load("FreeKeySession.json")
            _G.__OrionSession = { type = "free", label = "Free", expiresAt = free and free.expiresAt }
        end
        executarScript()
        return
    end
end

local function getExecutorName()
    if identifyexecutor then
        local ok, name = pcall(identifyexecutor)
        if ok and name and name ~= "" then return name end
    end
    return "Unknown"
end

local OrionLib = loadstring(game:HttpGet("https://win-ui-online.vercel.app/Lib/Src.lua"))()

local function Notify(content, delay, color)
    return OrionLib:MakeNotify({
        Title = HUB_NAME,
        Content = content or "",
        Color = color or Color3.fromRGB(255, 255, 255),
        Delay = delay or 4,
    })
end

local gameName = ""
pcall(function()
    gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or ""
end)

local Window = OrionLib:Window({
    Title = HUB_NAME .. (gameName ~= "" and (" | " .. gameName) or "") .. " | " .. getExecutorName(),
    Color = Color3.fromRGB(16, 185, 129),
    Version = 1,
    ThemePreset = CFG_THEME,
})

pcall(function()
    local Float = OrionLib:FloatBtn({
        Icon = CFG_ICON,
        Color = Color3.fromRGB(16, 185, 129),
        ColorDark = Color3.fromRGB(10, 10, 12),
        Size = 46,
        MainHolder = Window._holder,
    })
    Window:RegisterFloat(Float)
end)

local TabAcesso = Window:AddTab({
    Name = T("Acesso", "Access", "Acceso"),
    Icon = "rbxassetid://7733965118",
})
local TabFree = Window:AddTab({
    Name = T("Key Free", "Key Free", "Key Free"),
    Icon = "rbxassetid://7743878857",
})
local TabPrem = Window:AddTab({
    Name = T("Key Premium", "Key Premium", "Key Premium"),
    Icon = "rbxassetid://127843403295538",
})
local TabConfig = Window:AddTab({
    Name = T("Config", "Config", "Config"),
    Icon = "rbxassetid://7734053495",
})

local _opened = false
local function liberarAcesso()
    if _opened then return end
    _opened = true
    pcall(function() Window:DestroyGui() end)
    pcall(function() if Window._holder then Window._holder:Destroy() end end)
    pcall(function()
        for _, gui in ipairs(CoreGui:GetChildren()) do
            if gui.Name:find("WinUI") or gui.Name:find("Orion") then pcall(function() gui:Destroy() end) end
        end
    end)
    task.wait(0.15)
    if CFG_SND ~= "" then
        task.spawn(function()
            local s = Instance.new("Sound")
            s.SoundId = CFG_SND
            s.Volume = CFG_VOL
            s.Parent = game:GetService("SoundService")
            pcall(function() if not s.IsLoaded then s.Loaded:Wait() end end)
            s:Play()
            game:GetService("Debris"):AddItem(s, 15)
        end)
    end
    local ok, err = executarScript()
    if not ok then
        Notify(T("Erro ao abrir o hub: ", "Error opening hub: ", "Error al abrir el hub: ") .. tostring(err), 6, Color3.fromRGB(255, 80, 80))
        _opened = false
    end
end

local _shortIdx = 0
local function copyShortLink()
    local links = INTERNAL_CONFIG.ShortLinks
    _shortIdx = (_shortIdx % #links) + 1
    setclipboard(links[_shortIdx])
    Notify(T("Link da Key Free copiado!", "Free key link copied!", "¡Enlace Key Free copiado!"), 4, Color3.fromRGB(16, 185, 129))
end

local function copyDiscord()
    setclipboard(INTERNAL_CONFIG.DiscordInvite)
    Notify(T("Discord copiado!", "Discord copied!", "¡Discord copiado!"), 4, Color3.fromRGB(16, 185, 129))
end

-- ===== ACESSO (digitar qualquer key) =====
local SecA = TabAcesso:AddSection(T("Entrar no Orion Hub", "Enter Orion Hub", "Entrar a Orion Hub"), true)
local inputKey = ""
SecA:AddInput({
    Title = T("Senha", "Password", "Contraseña"),
    Content = T("Master, Premium ou Free", "Master, Premium or Free", "Master, Premium o Free"),
    Default = "",
    Callback = function(v) inputKey = v end,
})
SecA:AddButton({
    Title = T("Confirmar", "Confirm", "Confirmar"),
    Callback = function()
        local typed = cleanKey(inputKey)
        if typed == "" then
            Notify(T("Digite a senha", "Enter the password", "Ingresa la contraseña"), 3, Color3.fromRGB(255, 150, 80))
            return
        end
        local ok, kind = isValidKey(typed)
        if not ok then
            if kind == "expired" then
                Notify(T("Key Free expirada. Pegue outra na aba Key Free.", "Free key expired. Get another in Key Free tab.", "Key Free expirada."), 4, Color3.fromRGB(255, 80, 80))
            else
                Notify(T("Senha incorreta", "Wrong password", "Contraseña incorrecta") .. " [" .. typed:sub(1, 12) .. "]", 4, Color3.fromRGB(255, 80, 80))
            end
            return
        end
        if kind == "master" then
            _G.__OrionSession = { type = "master", label = "Master", expiresAt = nil }
            Notify(T("Master OK", "Master OK", "Master OK"), 2, Color3.fromRGB(16, 185, 129))
        elseif kind == "premium" then
            dataManager:save("PremiumKey.json", { key = typed, permanent = true })
            pcall(function()
                if isfile(FOLDER_NAME .. "/FreeKeySession.json") then delfile(FOLDER_NAME .. "/FreeKeySession.json") end
            end)
            _G.__OrionSession = { type = "premium", label = "Premium", expiresAt = nil }
            Notify(T("Premium ativado", "Premium activated", "Premium activado"), 2, Color3.fromRGB(16, 185, 129))
        else
            local session = dataManager:load("FreeKeySession.json")
            local expiresAt
            if session and cleanKey(session.key) == typed and type(session.expiresAt) == "number" and now() <= session.expiresAt then
                expiresAt = session.expiresAt
            else
                expiresAt = now() + FREE_SECONDS
            end
            dataManager:save("FreeKeySession.json", { key = typed, startedAt = now(), expiresAt = expiresAt, hours = FREE_HOURS })
            _G.__OrionSession = { type = "free", label = "Free", expiresAt = expiresAt }
            Notify(T("Acesso liberado", "Access granted", "Acceso liberado"), 2, Color3.fromRGB(16, 185, 129))
        end
        task.wait(0.5)
        liberarAcesso()
    end,
})

-- ===== KEY FREE =====
local SecF = TabFree:AddSection(T("Key Free", "Key Free", "Key Free"), true)
SecF:AddButton({
    Title = T("Obter Key Free", "Get Free Key", "Obtener Key Free"),
    Callback = copyShortLink,
})

-- ===== KEY PREMIUM =====
local SecP = TabPrem:AddSection(T("Key Premium", "Key Premium", "Key Premium"), true)
SecP:AddButton({
    Title = T("Falar no Discord", "Talk on Discord", "Hablar en Discord"),
    Callback = copyDiscord,
})

-- ===== CONFIG / IDIOMA =====
local SecC = TabConfig:AddSection(T("Idioma", "Language", "Idioma"), true)
local function pickLang(code, label)
    saveLang(code)
    Notify(T("Idioma: ", "Language: ", "Idioma: ") .. label .. T(" — reabra o script para aplicar tudo", " — reopen script to apply fully", " — reabre el script para aplicar todo"), 4, Color3.fromRGB(16, 185, 129))
end
SecC:AddButton({
    Title = "🇧🇷  Português",
    Callback = function() pickLang("pt", "Português") end,
})
SecC:AddButton({
    Title = "🇺🇸  English",
    Callback = function() pickLang("en", "English") end,
})
SecC:AddButton({
    Title = "🇪🇸  Español",
    Callback = function() pickLang("es", "Español") end,
})

_G.Window = Window
_G.Notify = Notify
_G.CFG_THEME = CFG_THEME

task.delay(0.4, function()
    Notify(T("Digite sua key na aba Acesso", "Enter your key in Access tab", "Ingresa tu key en Acceso"), 4, Color3.fromRGB(100, 220, 180))
end)
