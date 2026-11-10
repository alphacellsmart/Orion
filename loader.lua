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

local TweenService = game:GetService("TweenService")
local CoreGuiSvc = game:GetService("CoreGui")

local GREEN = Color3.fromRGB(16, 185, 129)
local GREEN_SOFT = Color3.fromRGB(52, 211, 153)
local CARD = Color3.fromRGB(18, 18, 22)
local CARD2 = Color3.fromRGB(24, 24, 30)
local TEXT = Color3.fromRGB(235, 235, 240)
local MUTED = Color3.fromRGB(140, 140, 150)
local STROKE = Color3.fromRGB(40, 40, 48)

local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 12)
    c.Parent = p
    return c
end

local function stroke(p, color, t, thick)
    local s = Instance.new("UIStroke")
    s.Color = color or STROKE
    s.Transparency = t or 0
    s.Thickness = thick or 1
    s.Parent = p
    return s
end

local function makeLabel(parent, text, size, color, font)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text = text or ""
    l.TextColor3 = color or TEXT
    l.TextSize = size or 14
    l.Font = font or Enum.Font.GothamMedium
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Center
    l.Parent = parent
    return l
end

local function addShine(parent, radius)
    local clip = Instance.new("Frame")
    clip.Name = "ShineClip"
    clip.BackgroundTransparency = 1
    clip.ClipsDescendants = true
    clip.Size = UDim2.fromScale(1, 1)
    clip.ZIndex = (parent.ZIndex or 1) + 3
    clip.Parent = parent
    corner(clip, radius or 14)

    local sh = Instance.new("Frame")
    sh.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
    sh.BackgroundTransparency = 0.75
    sh.BorderSizePixel = 0
    sh.Size = UDim2.new(0.28, 0, 1.5, 0)
    sh.Position = UDim2.new(-0.5, 0, -0.25, 0)
    sh.Rotation = 20
    sh.ZIndex = clip.ZIndex
    sh.Parent = clip
    local g = Instance.new("UIGradient")
    g.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0.2),
        NumberSequenceKeypoint.new(1, 1),
    })
    g.Parent = sh

    task.spawn(function()
        while clip.Parent do
            sh.Position = UDim2.new(-0.6, 0, -0.25, 0)
            local tw = TweenService:Create(sh, TweenInfo.new(2.0, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
                Position = UDim2.new(1.2, 0, -0.25, 0)
            })
            tw:Play()
            tw.Completed:Wait()
            task.wait(2.5)
        end
    end)
end

local gui = Instance.new("ScreenGui")
gui.Name = "OrionHub_Login"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 1000
pcall(function()
    if syn and syn.protect_gui then syn.protect_gui(gui) end
end)
gui.Parent = (gethui and gethui()) or CoreGuiSvc

local dim = Instance.new("Frame")
dim.Size = UDim2.fromScale(1, 1)
dim.BackgroundColor3 = Color3.new(0, 0, 0)
dim.BackgroundTransparency = 0.4
dim.BorderSizePixel = 0
dim.Parent = gui

local main = Instance.new("Frame")
main.Name = "Card"
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.fromScale(0.5, 0.5)
main.Size = UDim2.fromOffset(400, 300)
main.BackgroundColor3 = CARD
main.BorderSizePixel = 0
main.Parent = gui
corner(main, 18)
stroke(main, GREEN, 0.5, 1.6)
addShine(main, 18)

local accent = Instance.new("Frame")
accent.Size = UDim2.new(1, 0, 0, 2)
accent.BackgroundColor3 = GREEN
accent.BorderSizePixel = 0
accent.Parent = main

local header = Instance.new("Frame")
header.BackgroundTransparency = 1
header.Size = UDim2.new(1, -32, 0, 50)
header.Position = UDim2.fromOffset(16, 12)
header.Parent = main

local logoBox = Instance.new("Frame")
logoBox.Size = UDim2.fromOffset(36, 36)
logoBox.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
logoBox.BorderSizePixel = 0
logoBox.Parent = header
corner(logoBox, 12)
stroke(logoBox, GREEN, 0.2, 1.4)

local logoTxt = Instance.new("ImageLabel")
logoTxt.BackgroundTransparency = 1
logoTxt.Size = UDim2.fromScale(1, 1)
logoTxt.ScaleType = Enum.ScaleType.Fit
logoTxt.Parent = logoBox
pcall(function()
    local url = "https://raw.githubusercontent.com/alphacellsmart/Orion/main/assets/orion-logo.png"
    local ok, bytes = pcall(function() return game:HttpGet(url, true) end)
    if ok and type(bytes) == "string" and #bytes > 100 and writefile then
        pcall(function()
            if isfolder and not isfolder("Orion_Hub") and makefolder then makefolder("Orion_Hub") end
            writefile("Orion_Hub/orion-logo.png", bytes)
        end)
        local assetFn = (type(getcustomasset) == "function" and getcustomasset) or (type(getsynasset) == "function" and getsynasset)
        if assetFn then
            local ok2, asset = pcall(assetFn, "Orion_Hub/orion-logo.png")
            if ok2 and asset then logoTxt.Image = asset; return end
        end
    end
    logoTxt.Image = url
end)

local title = makeLabel(header, "Orion Hub", 20, TEXT, Enum.Font.GothamBold)
title.Position = UDim2.fromOffset(54, 4)
title.Size = UDim2.new(1, -100, 0, 24)

local sub = makeLabel(header, T("Acesso premium", "Premium access", "Acceso premium"), 12, MUTED, Enum.Font.Gotham)
sub.Position = UDim2.fromOffset(54, 30)
sub.Size = UDim2.new(1, -100, 0, 18)

local langBtn = Instance.new("TextButton")
langBtn.Size = UDim2.fromOffset(40, 26)
langBtn.Position = UDim2.new(1, -40, 0, 8)
langBtn.BackgroundColor3 = CARD2
langBtn.Text = (_lang == "en" and "EN") or (_lang == "es" and "ES") or "PT"
langBtn.TextColor3 = GREEN
langBtn.TextSize = 11
langBtn.Font = Enum.Font.GothamBold
langBtn.AutoButtonColor = false
langBtn.Parent = header
corner(langBtn, 8)
stroke(langBtn, GREEN, 0.45, 1)

local langs = { "pt", "en", "es" }
local langLabels = { pt = "PT", en = "EN", es = "ES" }
langBtn.MouseButton1Click:Connect(function()
    local i = 1
    for idx, v in ipairs(langs) do
        if v == _lang then i = idx break end
    end
    local nextL = langs[(i % #langs) + 1]
    saveLang(nextL)
    langBtn.Text = langLabels[nextL]
    sub.Text = T("Acesso premium", "Premium access", "Acceso premium")
end)

local body = Instance.new("Frame")
body.BackgroundTransparency = 1
body.Position = UDim2.fromOffset(16, 72)
body.Size = UDim2.new(1, -32, 1, -96)
body.Parent = main

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 8)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = body

local function notifyCustom(msg, color)
    local n = Instance.new("Frame")
    n.AnchorPoint = Vector2.new(0.5, 0)
    n.Position = UDim2.new(0.5, 0, 0, 20)
    n.Size = UDim2.fromOffset(320, 42)
    n.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    n.BorderSizePixel = 0
    n.Parent = gui
    corner(n, 10)
    stroke(n, color or GREEN, 0.25, 1.2)
    local nl = makeLabel(n, msg, 13, TEXT, Enum.Font.GothamMedium)
    nl.Size = UDim2.fromScale(1, 1)
    nl.TextXAlignment = Enum.TextXAlignment.Center
    task.delay(3, function() pcall(function() n:Destroy() end) end)
end

local function copyShortLink()
    local links = INTERNAL_CONFIG.ShortLinks
    _G.__OrionShortIdx = ((_G.__OrionShortIdx or 0) % #links) + 1
    setclipboard(links[_G.__OrionShortIdx])
    notifyCustom(T("Link Key Free copiado!", "Free key link copied!", "¡Enlace Key Free copiado!"), GREEN)
end

local function copyDiscord()
    setclipboard(INTERNAL_CONFIG.DiscordInvite)
    notifyCustom(T("Discord copiado!", "Discord copied!", "¡Discord copiado!"), GREEN)
end

local function makeActionCard(order, titleText, descText, onClick)
    local f = Instance.new("TextButton")
    f.LayoutOrder = order
    f.Size = UDim2.new(1, 0, 0, 44)
    f.BackgroundColor3 = CARD2
    f.AutoButtonColor = false
    f.Text = ""
    f.Parent = body
    corner(f, 12)
    stroke(f, STROKE, 0.15, 1)
    addShine(f, 12)

    local t = makeLabel(f, titleText, 14, TEXT, Enum.Font.GothamBold)
    t.Position = UDim2.fromOffset(14, 10)
    t.Size = UDim2.new(1, -28, 0, 18)

    local d = makeLabel(f, descText, 11, MUTED, Enum.Font.Gotham)
    d.Position = UDim2.fromOffset(14, 30)
    d.Size = UDim2.new(1, -28, 0, 16)

    f.MouseEnter:Connect(function()
        TweenService:Create(f, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(28, 32, 30) }):Play()
    end)
    f.MouseLeave:Connect(function()
        TweenService:Create(f, TweenInfo.new(0.15), { BackgroundColor3 = CARD2 }):Play()
    end)
    f.MouseButton1Click:Connect(function()
        if onClick then onClick() end
    end)
end

makeActionCard(1,
    T("Key Free", "Key Free", "Key Free"),
    T("Obter senha pelo encurtador", "Get password via shortener", "Obtener contraseña por acortador"),
    copyShortLink
)

makeActionCard(2,
    T("Key Premium", "Key Premium", "Key Premium"),
    T("Acesso permanente — Discord", "Permanent access — Discord", "Acceso permanente — Discord"),
    copyDiscord
)

local passCard = Instance.new("Frame")
passCard.LayoutOrder = 3
passCard.Size = UDim2.new(1, 0, 0, 100)
passCard.BackgroundColor3 = CARD2
passCard.BorderSizePixel = 0
passCard.Parent = body
corner(passCard, 12)
stroke(passCard, STROKE, 0.15, 1)
addShine(passCard, 12)

local passTitle = makeLabel(passCard, T("Digite sua key", "Enter your key", "Ingresa tu key"), 13, TEXT, Enum.Font.GothamBold)
passTitle.Position = UDim2.fromOffset(14, 12)
passTitle.Size = UDim2.new(1, -28, 0, 18)

local inputBox = Instance.new("Frame")
inputBox.Size = UDim2.new(1, -28, 0, 32)
inputBox.Position = UDim2.fromOffset(14, 34)
inputBox.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
inputBox.BorderSizePixel = 0
inputBox.Parent = passCard
corner(inputBox, 10)
stroke(inputBox, GREEN, 0.6, 1)

local input = Instance.new("TextBox")
input.BackgroundTransparency = 1
input.Size = UDim2.new(1, -20, 1, 0)
input.Position = UDim2.fromOffset(10, 0)
input.PlaceholderText = "Master  ·  Premium  ·  Free"
input.PlaceholderColor3 = Color3.fromRGB(90, 90, 100)
input.Text = ""
input.TextColor3 = TEXT
input.TextSize = 13
input.Font = Enum.Font.Gotham
input.ClearTextOnFocus = false
input.TextXAlignment = Enum.TextXAlignment.Left
input.Parent = inputBox

local confirm = Instance.new("TextButton")
confirm.Size = UDim2.new(1, -28, 0, 30)
confirm.Position = UDim2.fromOffset(14, 74)
confirm.BackgroundColor3 = GREEN
confirm.AutoButtonColor = false
confirm.Text = T("Confirmar acesso", "Confirm access", "Confirmar acceso")
confirm.TextColor3 = Color3.fromRGB(6, 30, 20)
confirm.TextSize = 13
confirm.Font = Enum.Font.GothamBold
confirm.Parent = passCard
corner(confirm, 10)

confirm.MouseEnter:Connect(function()
    TweenService:Create(confirm, TweenInfo.new(0.12), { BackgroundColor3 = GREEN_SOFT }):Play()
end)
confirm.MouseLeave:Connect(function()
    TweenService:Create(confirm, TweenInfo.new(0.12), { BackgroundColor3 = GREEN }):Play()
end)

local foot = makeLabel(main, "Orion Hub  ·  " .. getExecutorName(), 10, MUTED, Enum.Font.Gotham)
foot.Position = UDim2.new(0, 20, 1, -24)
foot.Size = UDim2.new(1, -40, 0, 14)
foot.TextXAlignment = Enum.TextXAlignment.Center

local _opened = false
local function liberarAcesso()
    if _opened then return end
    _opened = true
    pcall(function() gui:Destroy() end)
    task.wait(0.12)
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
        _opened = false
        warn("[Orion Hub]", err)
    end
end

local function tryLogin()
    local typed = cleanKey(input.Text)
    if typed == "" then
        notifyCustom(T("Digite a senha", "Enter the password", "Ingresa la contraseña"), Color3.fromRGB(255, 150, 80))
        return
    end
    local ok, kind = isValidKey(typed)
    if not ok then
        if kind == "expired" then
            notifyCustom(T("Key Free expirada", "Free key expired", "Key Free expirada"), Color3.fromRGB(255, 80, 80))
        else
            notifyCustom(T("Senha incorreta", "Wrong password", "Contraseña incorrecta"), Color3.fromRGB(255, 80, 80))
        end
        return
    end
    if kind == "master" then
        _G.__OrionSession = { type = "master", label = "Master", expiresAt = nil }
        notifyCustom("Master OK", GREEN)
    elseif kind == "premium" then
        dataManager:save("PremiumKey.json", { key = typed, permanent = true })
        pcall(function()
            if isfile(FOLDER_NAME .. "/FreeKeySession.json") then delfile(FOLDER_NAME .. "/FreeKeySession.json") end
        end)
        _G.__OrionSession = { type = "premium", label = "Premium", expiresAt = nil }
        notifyCustom(T("Premium ativado", "Premium activated", "Premium activado"), GREEN)
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
        notifyCustom(T("Acesso liberado", "Access granted", "Acceso liberado"), GREEN)
    end
    task.wait(0.4)
    liberarAcesso()
end

confirm.MouseButton1Click:Connect(tryLogin)
input.FocusLost:Connect(function(enter)
    if enter then tryLogin() end
end)

main.Size = UDim2.fromOffset(380, 280)
main.BackgroundTransparency = 0.25
TweenService:Create(main, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
    Size = UDim2.fromOffset(400, 300),
    BackgroundTransparency = 0,
}):Play()
