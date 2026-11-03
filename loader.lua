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
}
--// ========================================

--// ========================================
-- Detecção de idioma por localização
--// ========================================
local _isBR = false
pcall(function()
    local locale = game:GetService("LocalizationService").RobloxLocaleId or ""
    _isBR = (locale == "pt-BR" or locale == "pt_BR" or locale:sub(1,2) == "pt")
end)

local function T(ptBR, en)
    return _isBR and ptBR or en
end

--// ========================================
local HttpService  = (cloneref or function(x) return x end)(game:GetService("HttpService"))
local Players      = game:GetService("Players")
local CoreGui      = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer  = Players.LocalPlayer
local FOLDER_NAME  = HUB_NAME:gsub("%s+", "_")

local RAW_CONFIG = nil

local function fetchOne(url)
    local ok, raw = pcall(function() return game:HttpGet(url .. "?t=" .. tostring(os.time()), true) end)
    if not ok or type(raw) ~= "string" or raw == "" then
        ok, raw = pcall(function() return game:HttpGet(url, true) end)
        if not ok or type(raw) ~= "string" or raw == "" then return nil end
    end
    raw = raw:gsub("^\239\187\191", "") -- remove BOM
    RAW_CONFIG = raw

    local dok, data = pcall(function() return HttpService:JSONDecode(raw) end)
    if dok and type(data) == "table" then return data end

    -- tolera comentarios e virgulas sobrando
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

local CFG_ICON       = (externalConfig and externalConfig["OpenIcon"])    or "rbxassetid://7733960981"
local CFG_THEME      = (externalConfig and externalConfig["ThemeSelect"]) or "darker"
local CFG_SND        = (externalConfig and externalConfig["SoundId"])     or ""
local CFG_VOL        = (externalConfig and externalConfig["SoundVolume"]) or 1
-- Keys vêm SOMENTE do Head.json: "PremiumKey": "abc" e/ou "Keys": ["abc","def"]
local CFG_KEYS = {}
local CFG_KEYS_COUNT = 0
local function addKey(k)
    if type(k) ~= "string" and type(k) ~= "number" then return end
    k = tostring(k):match("^%s*(.-)%s*$")
    if k ~= "" and not CFG_KEYS[k] then
        CFG_KEYS[k] = true
        CFG_KEYS_COUNT = CFG_KEYS_COUNT + 1
    end
end

local function isKeyField(name)
    name = tostring(name):lower()
    return name:find("key", 1, true) or name:find("senha", 1, true)
        or name:find("pass", 1, true) or name:find("password", 1, true)
end

if type(externalConfig) == "table" then
    for name, value in pairs(externalConfig) do
        if isKeyField(name) then
            if type(value) == "table" then
                for k, v in pairs(value) do
                    addKey(v)
                    if type(k) == "string" and type(v) ~= "table" then addKey(k) end
                end
            else
                addKey(value)
            end
        end
    end
elseif RAW_CONFIG then
    -- ultimo recurso: le direto do texto
    for name, value in RAW_CONFIG:gmatch('"([^"]+)"%s*[:=]%s*"([^"]*)"') do
        if isKeyField(name) then addKey(value) end
    end
end

local _themeList     = (externalConfig and externalConfig["_themes_available"]) or {
    "darker","dark","carbon","obsidian","midnight","navy","ocean","teal","slate",
    "grape","rose","crimson","bronze","forest","ash","void","aurora","ember",
    "lilac","storm","rust","pine"
}

--// ========================================
-- Sistema de arquivos
--// ========================================
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

--// ========================================
-- Funcoes de validacao (sem depender da lib)
--// ========================================
local function isValidKey(inputKey)
    if not inputKey then return false end
    local cleaned = tostring(inputKey):match("^%s*(.-)%s*$")
    return cleaned ~= "" and CFG_KEYS[cleaned] == true
end

local function hasSavedKey()
    local saved = dataManager:load("PremiumKey.json")
    if not saved or not saved.key then return false end
    return isValidKey(saved.key) -- revalida no Head.json a cada execucao
end

local UNIVERSAL_URL = "https://raw.githubusercontent.com/alphacellsmart/Orion/main/Games/Universal/Loader.lua"
--// ========================================

local function executarScript()
    _G.__OrionHub_Auth = true
    loadstring(game:HttpGet(UNIVERSAL_URL, true))()
end

--// ========================================
-- Bypass rapido: verifica ANTES de carregar qualquer interface
--// ========================================
if hasSavedKey() then
    executarScript()
    return
end

--// ========================================
-- So chega aqui se realmente precisar mostrar o painel de senha
--// ========================================

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

local OrionLib = loadstring(game:HttpGet(
    "https://win-ui-online.vercel.app/Lib/Src.lua"
))()

local function Notify(content, delay, color)
    return OrionLib:MakeNotify({
        Title   = HUB_NAME,
        Content = content or "",
        Color   = color   or Color3.fromRGB(255, 255, 255),
        Delay   = delay   or 4,
    })
end

local function getScrollTab(window)
    return window._holder:FindFirstChild("ScrollTab", true)
end

local function setTabVisible(window, layoutOrder, visible)
    local scrollTab = getScrollTab(window)
    if not scrollTab then return end
    for _, child in scrollTab:GetChildren() do
        if child:IsA("Frame") and child.LayoutOrder == layoutOrder then
            child.Visible = visible
        end
    end
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

--// ========================================
local TabVerificar = Window:AddTab({
    Name = T("Verificar", "Verify"),
    Icon = "rbxassetid://7733965118"
})
local TabPremium = Window:AddTab({
    Name = T("Premium", "Premium"),
    Icon = "rbxassetid://127843403295538"
})

local _acessoJaLiberado = false

local function liberarAcesso()
    if _acessoJaLiberado then return end
    _acessoJaLiberado = true

    pcall(function() Window:DestroyGui() end)
    pcall(function()
        if Window._holder then Window._holder:Destroy() end
    end)
    pcall(function()
        local fb = game:GetService("CoreGui"):FindFirstChild("WinUIFloatBtn")
        if fb then fb:Destroy() end
    end)
    pcall(function()
        for _, gui in CoreGui:GetChildren() do
            if gui.Name:find("WinUI") or gui.Name:find(HUB_NAME) then
                gui:Destroy()
            end
        end
    end)

    task.wait(0.2)

    if CFG_SND ~= "" then
        task.spawn(function()
            local s = Instance.new("Sound")
            s.SoundId = CFG_SND
            s.Volume  = CFG_VOL
            s.Parent  = game:GetService("SoundService")
            if not s.IsLoaded then s.Loaded:Wait() end
            s:Play()
            game:GetService("Debris"):AddItem(s, 15)
        end)
    end

    task.spawn(function()
        local ok, err = pcall(executarScript)
        if not ok then warn("[" .. HUB_NAME .. "] Erro ao executar o script:", err) end
    end)
end

task.delay(0.5, function()
    Notify(
        T("Sistema de senha ativo!", "Password system active!"),
        4,
        Color3.fromRGB(100, 220, 180)
    )
end)

local _shortIdx = 0
local function copyShortLink()
    local links = INTERNAL_CONFIG.ShortLinks or {}
    if #links == 0 then return end
    _shortIdx = (_shortIdx % #links) + 1
    setclipboard(links[_shortIdx])
    Notify(
        T("Link do encurtador copiado! Cole no navegador.", "Shortener link copied! Paste in browser."),
        5,
        Color3.fromRGB(16, 185, 129)
    )
end

local function copyDiscord()
    setclipboard(INTERNAL_CONFIG.DiscordInvite or "")
    Notify(
        T("Link do Discord copiado!", "Discord link copied!"),
        4,
        Color3.fromRGB(16, 185, 129)
    )
end

--// ========================================
-- Aba de verificacao de senha
--// ========================================
local SecEntrada = TabVerificar:AddSection(
    T("Obtenha acesso ao Orion Hub", "Get access to Orion Hub"),
    true
)

SecEntrada:AddParagraph({
    Title   = T("Como obter a senha", "How to get the password"),
    Content = T(
        "1) Clique no botão e passe pelo encurtador\n2) Pegue a key que aparecer\n3) Cole a key no campo e confirme\n\nPrecisa de ajuda? Entre no Discord!",
        "1) Click the button and go through the shortener\n2) Get the key that appears\n3) Paste the key and confirm\n\nNeed help? Join the Discord!"
    ),
})

SecEntrada:AddButton({
    Title    = T("Obter Key via Encurtador", "Get Key via Shortener"),
    Callback = copyShortLink,
})

SecEntrada:AddButton({
    Title    = T("Entrar no Discord", "Join Discord"),
    Callback = copyDiscord,
})

local inputKey = ""
SecEntrada:AddInput({
    Title    = T("Digite a senha:", "Enter the password:"),
    Content  = T("Senha de Acesso / Key", "Access Password / Key"),
    Default  = "",
    Callback = function(value) inputKey = value end,
})

SecEntrada:AddButton({
    Title    = T("Confirmar Senha", "Confirm Password"),
    Callback = function()
        if inputKey == "" then
            Notify(
                T("Por favor, digite uma senha", "Please enter a password"),
                3,
                Color3.fromRGB(255, 150, 80)
            )
            return
        end

        if CFG_KEYS_COUNT == 0 then
            Notify(
                T("Head.json nao carregou ou nao tem senha. Tente novamente.", "Head.json failed to load or has no password. Try again."),
                4,
                Color3.fromRGB(255, 100, 100)
            )
            return
        end

        if isValidKey(inputKey) then
            dataManager:save("PremiumKey.json", { key = tostring(inputKey):match("^%s*(.-)%s*$") })
            Notify(
                T("Acesso liberado com sucesso!", "Access granted successfully!"),
                3,
                Color3.fromRGB(16, 185, 129)
            )
            task.wait(1)
            liberarAcesso()
        else
            Notify(
                T("Senha incorreta, tente novamente", "Wrong password, try again")
                    .. " [" .. tostring(CFG_KEYS_COUNT) .. "]",
                4,
                Color3.fromRGB(255, 80, 80)
            )
        end
    end,
})

--// ========================================
-- Aba Premium / Discord
--// ========================================
local SecPremium = TabPremium:AddSection(
    T("Acesso e Suporte", "Access and Support"),
    true
)

SecPremium:AddParagraph({
    Title   = T("Como entrar", "How to get in"),
    Content = T(
        "- Passe pelo encurtador para obter sua key\n- Keys válidas e atualizadas\n- Suporte no Discord",
        "- Go through the shortener to get your key\n- Valid and updated keys\n- Support on Discord"
    ),
})

SecPremium:AddButton({
    Title    = T("Copiar link do Encurtador", "Copy Shortener link"),
    Callback = copyShortLink,
})

SecPremium:AddButton({
    Title    = T("Entrar no Discord", "Join Discord"),
    Callback = copyDiscord,
})

-- =========================================

_G.Window             = Window
_G.Notify             = Notify
_G.CFG_THEME          = CFG_THEME
_G.SaveConfig         = SaveConfig or nil
_G.LoadConfigElements = LoadConfigElements or nil

-- =========================================

-- TabConfig externo desativado (sem créditos / desenvolvedor)

-- =========================================