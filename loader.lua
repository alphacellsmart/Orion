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

    -- Master: acesso total, NUNCA salva sessao (sempre pede de novo)
    if MASTER_KEY and cleaned == tostring(MASTER_KEY) then
        return true, "master"
    end

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
    ColorDark  = Color3.fromRGB(10, 10, 12),
    Size       = 46,
    MainHolder = Window._holder,
})
Window:RegisterFloat(Float)

local TabKey = Window:AddTab({
    Name = T("Acesso", "Access", "Acceso"),
    Icon = "rbxassetid://7733965118",
})

-- Idioma compacto (canto / topo da aba)
local SecLang = TabKey:AddSection(T("Idioma", "Language", "Idioma"), true)
SecLang:AddButton({
    Title = "🇧🇷 PT",
    Callback = function()
        saveLang("pt")
        Notify("Português", 2, Color3.fromRGB(16, 185, 129))
    end,
})
SecLang:AddButton({
    Title = "🇺🇸 EN",
    Callback = function()
        saveLang("en")
        Notify("English", 2, Color3.fromRGB(16, 185, 129))
    end,
})
SecLang:AddButton({
    Title = "🇪🇸 ES",
    Callback = function()
        saveLang("es")
        Notify("Español", 2, Color3.fromRGB(16, 185, 129))
    end,
})

local SecKeys = TabKey:AddSection(T("Keys", "Keys", "Keys"), true)

SecKeys:AddButton({
    Title = T("Key Free", "Key Free", "Key Free"),
    Callback = copyShortLink,
})

SecKeys:AddButton({
    Title = T("Key Premium", "Key Premium", "Key Premium"),
    Callback = copyDiscord,
})

local inputKey = ""
SecKeys:AddInput({
    Title = T("Senha", "Password", "Contraseña"),
    Content = T("Cole a key aqui", "Paste key here", "Pega la key aquí"),
    Default = "",
    Callback = function(value) inputKey = value end,
})

SecKeys:AddButton({
    Title = T("Confirmar", "Confirm", "Confirmar"),
    Callback = function()
        if not inputKey or inputKey == "" then
            Notify(T("Digite uma senha", "Enter a password", "Ingresa una contraseña"), 3, Color3.fromRGB(255, 150, 80))
            return
        end
        local ok, kind = isValidKey(inputKey)
        if not ok then
            local msg
            if kind == "expired" then
                msg = T("Key Free expirada. Pegue outra.", "Free key expired. Get a new one.", "Key Free expirada.")
            else
                msg = T("Senha incorreta", "Wrong password", "Contraseña incorrecta")
            end
            Notify(msg, 4, Color3.fromRGB(255, 80, 80))
            return
        end
        local cleaned = tostring(inputKey):match("^%s*(.-)%s*$")
        if kind == "master" then
            _G.__OrionSession = { type = "master", label = "Master", expiresAt = nil }
            Notify(T("Master OK (pede de novo na próxima)", "Master OK (asks again next time)", "Master OK"), 3, Color3.fromRGB(16, 185, 129))
        elseif kind == "premium" then
            dataManager:save("PremiumKey.json", { key = cleaned, permanent = true })
            pcall(function()
                if isfile(FOLDER_NAME .. "/FreeKeySession.json") then delfile(FOLDER_NAME .. "/FreeKeySession.json") end
            end)
            _G.__OrionSession = { type = "premium", label = "Premium", expiresAt = nil }
            Notify(T("Premium ativado", "Premium activated", "Premium activado"), 3, Color3.fromRGB(16, 185, 129))
        else
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
            _G.__OrionSession = { type = "free", label = "Free", expiresAt = expiresAt }
            Notify(T("Acesso liberado", "Access granted", "Acceso liberado"), 3, Color3.fromRGB(16, 185, 129))
        end
        task.wait(0.8)
        liberarAcesso()
    end,
})

_G.Window = Window
_G.Notify = Notify
_G.CFG_THEME = CFG_THEME
