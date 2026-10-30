if not _G.__OrionPath then
    local ROOT = "Orion-Studios"
    local HS = game:GetService("HttpService")
    _G.__OrionPath = function(sub, name, old)
        pcall(function()
            if type(makefolder) == "function" and type(isfolder) == "function" then
                if not isfolder(ROOT) then makefolder(ROOT) end
                if sub and not isfolder(ROOT .. "/" .. sub) then makefolder(ROOT .. "/" .. sub) end
            end
        end)
        local p = ROOT .. (sub and ("/" .. sub) or "") .. "/" .. name
        if old then
            pcall(function()
                if isfile(old) and not isfile(p) then
                    writefile(p, readfile(old))
                    if type(delfile) == "function" then delfile(old) end
                end
            end)
        end
        return p
    end
    local secCache
    local function secLoad()
        if secCache then return secCache end
        secCache = {}
        pcall(function()
            local f = _G.__OrionPath("Config", "Sections.json")
            if isfile(f) then
                local t = HS:JSONDecode(readfile(f))
                if type(t) == "table" then secCache = t end
            end
        end)
        return secCache
    end
    _G.__OrionSecGet = function(k) return secLoad()[k] end
    _G.__OrionSecSet = function(k, v)
        secLoad()[k] = v
        pcall(function() writefile(_G.__OrionPath("Config", "Sections.json"), HS:JSONEncode(secCache)) end)
    end
end
--[[
  ORION STUDIOS | WINUI REPLACEMENT
  Nueva interfaz completa: ventana compacta con header, sidebar, páginas y cards
  en negro/grafito com detalhes em verde elegante (accent emerald).
  Compatible con el loader: Window, AddTab, AddSection, AddButton, AddToggle,
  FloatBtn, RegisterFloat, MakeNotify y DestroyGui.
]]
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local MarketplaceService = game:GetService("MarketplaceService")

local T = {
    bg = Color3.fromRGB(9, 9, 11),
    header = Color3.fromRGB(15, 15, 18),
    sidebar = Color3.fromRGB(12, 12, 15),
    panel = Color3.fromRGB(18, 18, 22),
    panelHover = Color3.fromRGB(25, 25, 30),
    field = Color3.fromRGB(13, 13, 17),
    silver = Color3.fromRGB(225, 225, 232),
    white = Color3.fromRGB(250, 250, 252),
    muted = Color3.fromRGB(150, 150, 162),
    border = Color3.fromRGB(54, 54, 63),
    darkText = Color3.fromRGB(20, 20, 23),
    silver2 = Color3.fromRGB(177, 177, 188),
    error = Color3.fromRGB(225, 82, 82),
    -- Verde elegante (accent)
    accent = Color3.fromRGB(16, 185, 129),       -- emerald
    accentSoft = Color3.fromRGB(52, 211, 153),   -- soft emerald
    accentDim = Color3.fromRGB(6, 95, 70),       -- deep emerald
}

local Icons = {}
pcall(function()
    local raw = game:HttpGet("https://win-ui-online.vercel.app/Lib/Icons.lua")
    local loader = loadstring(raw)
    if loader then
        local result = loader()
        if type(result) == "table" then Icons = result end
    end
end)
if Icons.house and not Icons.home then Icons.home = Icons.house end
if Icons.home and not Icons.house then Icons.house = Icons.home end
if Icons["gamepad-2"] then Icons.game, Icons.gamer = Icons["gamepad-2"], Icons["gamepad-2"] end
if Icons.play then Icons.run, Icons.exec = Icons.play, Icons.play end
if Icons.x then Icons.close = Icons.x end
if Icons.minus then Icons.minimize = Icons.minus end
local function icon(name)
    if type(name) ~= "string" then return "" end
    if name:find("^rbxassetid://") or name:find("^rbxthumb://") then return name end
    if tonumber(name) then return "rbxassetid://" .. name end
    name = name:lower():gsub("%s+", "-"):gsub("_", "-")
    return Icons[name] or ""
end

local assetCache = {}
local function isValidImageBytes(b)
    if type(b) ~= "string" or #b < 8 then return false end
    if b:sub(1, 4) == "\137PNG" then return true, "png" end
    if b:sub(1, 2) == "\255\216" then return true, "jpg" end
    return false -- webp/html (Cloudflare)/etc. nao renderizam no Roblox
end

local function normalizeUrl(url)
    if type(url) ~= "string" then return "" end
    url = url:match("^%s*(.-)%s*$") or ""
    if url == "" then return "" end
    if url:sub(1, 2) == "//" then return "https:" .. url end
    if url:sub(1, 1) == "/" then return "https://rscripts.net" .. url end
    return url
end

local function downloadBytes(url)
    local bytes
    pcall(function() bytes = game:HttpGet(url, true) end)
    if not bytes or #bytes == 0 then pcall(function() bytes = game:HttpGet(url) end) end
    if not bytes or #bytes == 0 then
        local reqFn = (syn and syn.request) or (http and http.request) or http_request or request
        if reqFn then
            pcall(function()
                local r = reqFn({Url = url, Method = "GET"})
                if r and r.Body and #r.Body > 0 then bytes = r.Body end
            end)
        end
    end
    return bytes
end

-- callback recebe um asset valido (rbxasset/rbxthumb/rbxassetid) ou "" se falhar
local function resolveImage(url, callback)
    url = normalizeUrl(url)
    if url == "" then callback(""); return end
    if url:find("^rbxassetid://") or url:find("^rbxthumb://") or url:find("^rbxasset://") then callback(url); return end
    if assetCache[url] ~= nil then callback(assetCache[url]); return end
    task.spawn(function()
        local result = ""
        pcall(function()
            local assetFn = (type(getcustomasset) == "function" and getcustomasset)
                or (type(getsynasset) == "function" and getsynasset)
            if not (assetFn and type(writefile) == "function" and type(isfile) == "function") then return end
            if type(isfolder) == "function" and type(makefolder) == "function" then
                _G.__OrionPath(".assets", "x")
            end
            -- impede a galeria do celular de indexar as miniaturas salvas
            pcall(function()
                for _, nm in ipairs({"Orion-Studios/.nomedia", "Orion-Studios/.assets/.nomedia"}) do
                    if not isfile(nm) then writefile(nm, "") end
                end
            end)
            local hash = 0
            for i = 1, #url do hash = (hash * 31 + url:byte(i)) % 2147483647 end
            local base = "Orion-Studios/.assets/v2_" .. hash
            local path
            for _, ext in ipairs({"png", "jpg"}) do
                if isfile(base .. "." .. ext) then path = base .. "." .. ext break end
            end
            if not path then
                local candidates = {url}
                local okEnc, enc = pcall(function() return HttpService:UrlEncode(url) end)
                if okEnc and enc then
                    -- o Roblox nao renderiza webp; o proxy converte qualquer formato para png
                    table.insert(candidates, "https://wsrv.nl/?url=" .. enc .. "&w=480&output=png")
                end
                for _, cand in ipairs(candidates) do
                    local bytes = downloadBytes(cand)
                    local okImg, ext = isValidImageBytes(bytes)
                    if okImg then
                        path = base .. "." .. ext
                        writefile(path, bytes)
                        break
                    end
                end
            end
            if path and isfile(path) then
                local ca = assetFn(path)
                if ca and ca ~= "" then result = ca end
            end
        end)
        assetCache[url] = result
        callback(result)
    end)
end

local function corner(inst, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = inst
    return c
end
local function stroke(inst, color, transparency, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or T.border
    s.Transparency = transparency or 0
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = inst
    return s
end
local function label(parent, text, size, color, font)
    local x = Instance.new("TextLabel")
    x.BackgroundTransparency = 1
    x.Text = tostring(text or "")
    x.Font = font or Enum.Font.Gotham
    x.TextSize = size or 13
    x.TextColor3 = color or T.white
    x.TextXAlignment = Enum.TextXAlignment.Left
    x.TextYAlignment = Enum.TextYAlignment.Center
    x.Parent = parent
    return x
end
local function button(parent, name, size, pos, bg)
    local b = Instance.new("TextButton")
    b.Name = name or "Button"
    b.Size = size
    b.Position = pos
    b.BackgroundColor3 = bg or T.panel
    b.BorderSizePixel = 0
    b.Text = ""
    b.AutoButtonColor = false
    b.Parent = parent
    return b
end
local function draggable(handle, target)
    local held, input, start, origin = false, nil, nil, nil
    handle.InputBegan:Connect(function(io)
        if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
            held, start, origin = true, io.Position, target.Position
            io.Changed:Connect(function() if io.UserInputState == Enum.UserInputState.End then held = false end end)
        end
    end)
    handle.InputChanged:Connect(function(io)
        if io.UserInputType == Enum.UserInputType.MouseMovement or io.UserInputType == Enum.UserInputType.Touch then input = io end
    end)
    UserInputService.InputChanged:Connect(function(io)
        if held and io == input then
            local d = io.Position - start
            local us = target:FindFirstChildOfClass("UIScale"); local k = (us and us.Scale > 0) and us.Scale or 1
            target.Position = UDim2.new(origin.X.Scale, origin.X.Offset + d.X / k, origin.Y.Scale, origin.Y.Offset + d.Y / k)
        end
    end)
end

-- elementos decorativos nunca devem capturar clique/toque (deixa passar para o botao embaixo)
local function noSink(inst)
    pcall(function() inst.Active = false end)
    pcall(function()
        for _, d in ipairs(inst:GetDescendants()) do
            pcall(function() d.Active = false end)
        end
    end)
end

-- ===== Toque confiavel (mobile) =====
-- Causas conhecidas de "botao nao responde no celular":
--  * Frame com Active=true dentro/sobre o botao bloqueia o toque (no mouse nao bloqueia);
--  * ScrollingFrame transforma o toque em scroll (dedo mexe alguns pixels);
--  * ZIndex do botao igual ao do pai dentro de ScrollingFrame.
-- Solucao em 3 camadas: Activated/MouseButton1Click + tap manual no proprio botao +
-- fallback GLOBAL (UserInputService) que testa se o toque caiu em cima de um botao registrado.
local GuiService = game:GetService("GuiService")
local TAP_MAX_MOVE = 14
local tapRegistry = {}      -- [botao] = funcao fire
local lastFire = 0
local inputOffset = Vector2.new(0, 0)
local calibrated = false
local fallbackHooked = false

local function pointInGui(gui, p)
    local a, sz = gui.AbsolutePosition, gui.AbsoluteSize
    return p.X >= a.X and p.X <= a.X + sz.X and p.Y >= a.Y and p.Y <= a.Y + sz.Y
end

local function reallyVisible(btn, p)
    local obj = btn
    while obj and not obj:IsA("LayerCollector") do
        if obj:IsA("GuiObject") then
            if not obj.Visible then return false end
            if obj ~= btn and (obj.ClipsDescendants or obj:IsA("ScrollingFrame")) and not pointInGui(obj, p) then
                return false
            end
        end
        obj = obj.Parent
    end
    if not obj then return false end
    if obj:IsA("ScreenGui") and not obj.Enabled then return false end
    return true
end

local function hookFallback()
    if fallbackHooked then return end
    fallbackHooked = true
    local began = nil -- {pos=Vector2, t=tick()} do ultimo toque iniciado
    UserInputService.InputBegan:Connect(function(io)
        if io.UserInputType == Enum.UserInputType.Touch or io.UserInputType == Enum.UserInputType.MouseButton1 then
            began = { pos = Vector2.new(io.Position.X, io.Position.Y), t = tick() }
        end
    end)
    UserInputService.InputEnded:Connect(function(io)
        if io.UserInputType ~= Enum.UserInputType.Touch and io.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        local b0 = began
        began = nil
        if not b0 then return end
        local e0 = Vector2.new(io.Position.X, io.Position.Y)
        if (e0 - b0.pos).Magnitude > TAP_MAX_MOVE then return end -- foi scroll/arrasto
        local tEnd = tick()
        task.delay(0.1, function()
            if lastFire >= tEnd - 0.05 then return end -- o evento normal do botao ja tratou
            -- testa a coordenada calibrada; se ainda nao calibrou, tenta tambem com o inset da barra superior
            local offsets = { inputOffset }
            if not calibrated then
                local okI, inset = pcall(function() return GuiService:GetGuiInset() end)
                if okI and inset then
                    table.insert(offsets, inset)
                    table.insert(offsets, -inset)
                end
            end
            for _, off in ipairs(offsets) do
                local p = e0 + off
                for btn, fire in pairs(tapRegistry) do
                    if not btn.Parent then
                        tapRegistry[btn] = nil
                    elseif pointInGui(btn, p) and reallyVisible(btn, p) then
                        if _G.OrionDebug then print("[Orion Lib] fallback global acionou: " .. tostring(btn.Name)) end
                        fire()
                        return
                    end
                end
            end
        end)
    end)
end

local function bindTap(btn, fn)
    -- Clique simples e direto (igual a lib que funciona no mobile): MouseButton1Click + Activated
    local last = 0
    pcall(function() btn.Active = true end)
    local function fire()
        local now = tick()
        if now - last < 0.3 then return end -- evita disparo duplo (Click + Activated)
        last = now
        lastFire = now
        pcall(function()
            local orig = btn.BackgroundTransparency
            if orig < 0.5 then
                btn.BackgroundTransparency = 0.45
                task.delay(0.12, function() if btn.Parent then btn.BackgroundTransparency = orig end end)
            end
        end)
        task.spawn(function()
            local ok, err = pcall(fn)
            if not ok then warn("[Orion Lib] Erro no botao: " .. tostring(err)) end
        end)
    end
    btn.MouseButton1Click:Connect(fire)
    btn.Activated:Connect(fire)
end

-- ===== Clipboard compativel com varios executores (retorna true/false de verdade) =====
local function copyText(text)
    text = tostring(text or "")
    local candidates = {}
    if type(setclipboard) == "function" then table.insert(candidates, setclipboard) end
    if type(toclipboard) == "function" then table.insert(candidates, toclipboard) end
    if type(set_clipboard) == "function" then table.insert(candidates, set_clipboard) end
    if type(Clipboard) == "table" and type(Clipboard.set) == "function" then
        table.insert(candidates, function(t) return Clipboard.set(t) end)
    end
    if type(syn) == "table" and type(syn.write_clipboard) == "function" then
        table.insert(candidates, syn.write_clipboard)
    end
    for _, fn in ipairs(candidates) do
        local ok = pcall(fn, text)
        if ok then return true end
    end
    return false
end

local OrionLib = { Icons = Icons, GetIcon = icon, Copy = copyText, BindTap = bindTap }

local Bell = { items = {}, render = nil,
    COL = { success = Color3.fromRGB(34,197,94), warning = Color3.fromRGB(255,171,0), error = Color3.fromRGB(255,86,48) },
    ICON = { success = {"circle-check","check-circle-2","check-circle","check"}, warning = {"triangle-alert","alert-triangle","clock","info"}, error = {"circle-x","x-circle","circle-alert","alert-circle","x"} } }
function Bell.icon(t)
    for _, n in ipairs(Bell.ICON[t] or Bell.ICON.warning) do
        local ok, r = pcall(icon, n)
        if ok and type(r) == "string" and r ~= "" then return r end
    end
    return ""
end
function Bell.ago(ts, pt)
    local s = math.max(0, os.time() - ts)
    if s < 60 then return pt and "há menos de um minuto" or "less than a minute ago" end
    local m = math.floor(s / 60)
    if m < 60 then return pt and ("há " .. m .. (m == 1 and " minuto" or " minutos")) or (m .. " min ago") end
    local h = math.floor(m / 60)
    if h < 24 then return pt and ("há " .. h .. (h == 1 and " hora" or " horas")) or (h .. " h ago") end
    local d = math.floor(h / 24)
    return pt and ("há " .. d .. (d == 1 and " dia" or " dias")) or (d .. " d ago")
end
function Bell.push(t, title, text)
    table.insert(Bell.items, 1, { type = t, title = title, text = text, ts = os.time(), read = false })
    while #Bell.items > 50 do table.remove(Bell.items) end
    if Bell.render then pcall(Bell.render) end
end

function OrionLib:Window(cfg)
    cfg = cfg or {}
    local titleText = cfg.Title or "Orion Studios"
    local camera = workspace.CurrentCamera
    local function viewport()
        local ok, v = pcall(function() return camera.ViewportSize end)
        return (ok and v and v.X > 0) and v or Vector2.new(1280, 720)
    end
    local vp0 = viewport()
    local winW = math.min(530, math.max(300, vp0.X - 24))
    local winH = math.min(311, math.max(230, vp0.Y - 60))
    local compact = winW < 620
    local tabWidth = tonumber(cfg["Tab Width"] or cfg.TabWidth) or (compact and 104 or 146)
    local playerGui
    local screen = Instance.new("ScreenGui")
    screen.Name = "OrionStudios_WinUI"
    screen.ResetOnSpawn = false
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() screen.DisplayOrder = 2147483646 end) -- logo abaixo do botao flutuante
    pcall(function()
        if syn and syn.protect_gui then syn.protect_gui(screen) end
        screen.Parent = (gethui and gethui()) or CoreGui
    end)
    if not screen.Parent then
        pcall(function() screen.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end)
    end

    local holder = Instance.new("Frame")
    holder.Name = "MainHolder"
    holder.AnchorPoint = Vector2.new(0.5, 0.5)
    holder.Position = UDim2.new(0.5, 0, 0.5, 0)
    holder.Size = UDim2.new(0, winW, 0, winH)
    holder.BackgroundColor3 = T.bg
    holder.BorderSizePixel = 0
    holder.ClipsDescendants = true
    holder.Parent = screen
    corner(holder, 14)
    -- luz lenta circulando na borda da interface (velocidade unica, compartilhada com o perfil)
    local lightGrads, lightSheens = {}, {}
    local closeHooks = {}
    do
        local bl = Instance.new("UIStroke"); bl.Name = "WindowLight"; bl.Thickness = 2; bl.Color = T.accent
        bl.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; bl.Parent = holder
        local bg = Instance.new("UIGradient")
        bg.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(.30, 1), NumberSequenceKeypoint.new(.42, .35),
            NumberSequenceKeypoint.new(.50, 0), NumberSequenceKeypoint.new(.58, .35), NumberSequenceKeypoint.new(.70, 1),
            NumberSequenceKeypoint.new(1, 1),
        })
        bg.Parent = bl
        lightGrads[#lightGrads + 1] = bg
        local rot, conn = 0, nil
        conn = game:GetService("RunService").Heartbeat:Connect(function(dt)
            if not holder.Parent then conn:Disconnect() return end
            rot = (rot + dt * 360 / 10) % 360 -- 10s por volta (velocidade original das secoes)
            for i = #lightGrads, 1, -1 do
                local g = lightGrads[i]
                if g.Parent then g.Rotation = rot else table.remove(lightGrads, i) end
            end
            local ox = math.sin(math.rad(rot)) -- reflexos: 1 ciclo por volta, mesmo relogio
            for i = #lightSheens, 1, -1 do
                local g = lightSheens[i]
                if g.Parent then g.Offset = Vector2.new(ox, 0) else table.remove(lightSheens, i) end
            end
        end)
    end

    -- desfoque forte no fundo do jogo enquanto a interface estiver aberta
    do
        local blur
        pcall(function()
            local Lighting = game:GetService("Lighting")
            for _, old in ipairs(Lighting:GetChildren()) do
                if old.Name == "OrionStudios_Blur" then old:Destroy() end
            end
            blur = Instance.new("BlurEffect"); blur.Name = "OrionStudios_Blur"; blur.Size = 0; blur.Parent = Lighting
        end)
        local function setBlur(on)
            if not blur or not blur.Parent then return end
            pcall(function()
                TweenService:Create(blur, TweenInfo.new(.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = on and 14 or 0 }):Play()
            end)
        end
        setBlur(true)
        holder:GetPropertyChangedSignal("Visible"):Connect(function() setBlur(holder.Visible) end)
        -- vigia: recria/reativa o desfoque se o jogo ou o hub o removerem/desativarem
        task.spawn(function()
            while screen.Parent do
                task.wait(0.4)
                pcall(function()
                    local L = game:GetService("Lighting")
                    local fix = false
                    if not blur or not blur.Parent then
                        blur = Instance.new("BlurEffect"); blur.Name = "OrionStudios_Blur"; blur.Size = 0; blur.Parent = L; fix = true
                    end
                    if blur.Parent ~= L then blur.Parent = L; fix = true end
                    if not blur.Enabled then blur.Enabled = true; fix = true end
                    if holder.Visible and (fix or blur.Size < 1) then setBlur(true) end
                end)
            end
        end)
        screen.AncestryChanged:Connect(function(_, parent)
            if not parent and blur then pcall(function() blur:Destroy() end); blur = nil end
        end)
    end
    local outline = stroke(holder, T.accent, 0.45, 1.2)
    pcall(function()
        if camera then
            camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
                local vp = viewport()
                if not holder:GetAttribute("UserSized") then
                    holder.Size = UDim2.new(0, math.min(530, math.max(300, vp.X - 24)), 0, math.min(311, math.max(230, vp.Y - 60))) -- mesmo tamanho inicial (antes crescia sozinho)
                end
            end)
        end
    end)

    local header = Instance.new("Frame")
    header.Name = "OrionHeader"
    header.Size = UDim2.new(1, 0, 0, 52)
    header.BackgroundColor3 = T.header
    header.BorderSizePixel = 0
    header.Parent = holder
    corner(header, 14) -- cantos arredondados em cima tambem
    do
        local fill = Instance.new("Frame") -- deixa a parte de baixo do header reta
        fill.Name = "HeaderSquare"; fill.Size = UDim2.new(1, 0, 0, 16); fill.Position = UDim2.new(0, 0, 1, -16)
        fill.BackgroundColor3 = T.header; fill.BorderSizePixel = 0; fill.Parent = header
    end
    local topRule = Instance.new("Frame")
    topRule.Size = UDim2.new(1, -28, 0, 1)
    topRule.Position = UDim2.new(0, 14, 1, -1)
    topRule.BackgroundColor3 = T.border
    topRule.BorderSizePixel = 0
    topRule.Parent = header

    local logoFrame = Instance.new("Frame")
    logoFrame.Size = UDim2.new(0, 32, 0, 32)
    logoFrame.Position = UDim2.new(0, 14, 0, 10)
    logoFrame.BackgroundColor3 = T.panel
    logoFrame.BorderSizePixel = 0
    logoFrame.Parent = header
    corner(logoFrame, 10)
    stroke(logoFrame, T.accent, 0.35, 1)
    local logo = Instance.new("ImageLabel")
    logo.Size = UDim2.new(1, -6, 1, -6)
    logo.Position = UDim2.new(0, 3, 0, 3)
    logo.BackgroundTransparency = 1
    logo.Image = "rbxassetid://106423297301247"
    logo.ScaleType = Enum.ScaleType.Fit
    logo.Parent = logoFrame

    local title = label(header, titleText, 14, T.white, Enum.Font.GothamBold)
    title.Name = "WindowTitle"
    title.Position = UDim2.new(0, 56, 0, 6)
    title.Size = UDim2.new(1, -190, 0, 20)
    title.TextTruncate = Enum.TextTruncate.AtEnd
    local brand = label(header, "ORION STUDIOS", 9, T.accent, Enum.Font.GothamBold)
    brand.Position = UDim2.new(0, 57, 0, 27)
    brand.Size = UDim2.new(0, 210, 0, 14)
    brand.TextXAlignment = Enum.TextXAlignment.Left

    local minimize = button(header, "Minimize", UDim2.new(0, 28, 0, 28), UDim2.new(1, -72, 0, 12), T.panel)
    corner(minimize, 8); stroke(minimize, T.border, 0, 1)
    local minIcon = Instance.new("ImageLabel")
    minIcon.Size = UDim2.new(0, 14, 0, 14); minIcon.AnchorPoint = Vector2.new(.5,.5)
    minIcon.Position = UDim2.new(.5,0,.5,0); minIcon.BackgroundTransparency = 1
    minIcon.Image = icon("minus"); minIcon.ImageColor3 = T.silver; minIcon.Parent = minimize
    local close = button(header, "Close", UDim2.new(0, 28, 0, 28), UDim2.new(1, -38, 0, 12), T.panel)
    corner(close, 8); stroke(close, T.border, 0, 1)
    local closeIcon = Instance.new("ImageLabel")
    closeIcon.Size = UDim2.new(0, 14, 0, 14); closeIcon.AnchorPoint = Vector2.new(.5,.5)
    closeIcon.Position = UDim2.new(.5,0,.5,0); closeIcon.BackgroundTransparency = 1
    closeIcon.Image = icon("x"); closeIcon.ImageColor3 = T.silver; closeIcon.Parent = close
    close.MouseEnter:Connect(function() close.BackgroundColor3 = Color3.fromRGB(54, 24, 25); closeIcon.ImageColor3 = T.error end)
    close.MouseLeave:Connect(function() close.BackgroundColor3 = T.panel; closeIcon.ImageColor3 = T.silver end)
    bindTap(close, function()
        if holder:FindFirstChild("CloseConfirm") then return end
        local ov = Instance.new("Frame"); ov.Name = "CloseConfirm"
        ov.Size = UDim2.new(1, 0, 1, 0); ov.BackgroundColor3 = Color3.new(0, 0, 0); ov.BackgroundTransparency = 1
        ov.BorderSizePixel = 0; ov.ZIndex = 200; ov.Active = true; ov.Parent = holder
        corner(ov, 14)
        local cw = math.min(300, winW - 30)
        local card = Instance.new("Frame"); card.Name = "Card"
        card.AnchorPoint = Vector2.new(.5, .5); card.Position = UDim2.new(.5, 0, .5, 0)
        card.Size = UDim2.new(0, cw, 0, 150)
        card.BackgroundColor3 = Color3.fromRGB(14, 14, 18); card.BorderSizePixel = 0; card.ZIndex = 202; card.Parent = ov
        corner(card, 10); stroke(card, T.silver2, .45, 1.2)
        local cover = Instance.new("Frame"); cover.Name = "FadeCover"; cover.Size = UDim2.new(1, 0, 1, 0)
        cover.BackgroundColor3 = Color3.fromRGB(14, 14, 18); cover.BorderSizePixel = 0; cover.ZIndex = 210; cover.Active = false; cover.Parent = card
        corner(cover, 10)
        -- brilho atras do cartao (mesmo estilo da outra lib), girando no relogio unico de luz
        local glow = Instance.new("Frame"); glow.Name = "Glow"; glow.AnchorPoint = Vector2.new(.5, .5)
        glow.Position = UDim2.new(.5, 0, .5, 0); glow.Size = UDim2.new(0, cw + 10, 0, 160)
        glow.BackgroundColor3 = Color3.new(1, 1, 1); glow.BackgroundTransparency = .78; glow.BorderSizePixel = 0; glow.ZIndex = 201; glow.Parent = ov
        corner(glow, 12)
        local gg = Instance.new("UIGradient")
        gg.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(.25, Color3.fromRGB(150, 150, 162)),
            ColorSequenceKeypoint.new(.5, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(.75, Color3.fromRGB(150, 150, 162)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
        })
        gg.Parent = glow; lightGrads[#lightGrads + 1] = gg
        local ls = Instance.new("UIStroke"); ls.Thickness = 1.6; ls.Color = Color3.new(1, 1, 1)
        ls.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; ls.Parent = card
        local lg = Instance.new("UIGradient")
        lg.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(.30, 1), NumberSequenceKeypoint.new(.42, .35),
            NumberSequenceKeypoint.new(.50, 0), NumberSequenceKeypoint.new(.58, .35), NumberSequenceKeypoint.new(.70, 1),
            NumberSequenceKeypoint.new(1, 1),
        })
        lg.Parent = ls; lightGrads[#lightGrads + 1] = lg

        local ttl = label(card, "Fechar Interface", 20, T.white, Enum.Font.GothamBold)
        ttl.Position = UDim2.new(0, 0, 0, 10); ttl.Size = UDim2.new(1, 0, 0, 30)
        ttl.TextXAlignment = Enum.TextXAlignment.Center; ttl.ZIndex = 203
        local msg = label(card, "Você deseja fechar a interface?\nO ícone flutuante também será removido.", 13, Color3.fromRGB(200, 200, 200), Enum.Font.Gotham)
        msg.Position = UDim2.new(0, 10, 0, 42); msg.Size = UDim2.new(1, -20, 0, 44)
        msg.TextXAlignment = Enum.TextXAlignment.Center; msg.TextWrapped = true; msg.ZIndex = 203

        local function mk(txt, icn, x, off)
            local b = Instance.new("TextButton"); b.Name = txt; b.Text = ""; b.AutoButtonColor = false
            b.Size = UDim2.new(.45, -10, 0, 36); b.Position = UDim2.new(x, off, 1, -52)
            b.BackgroundColor3 = Color3.new(1, 1, 1); b.BackgroundTransparency = .935; b.BorderSizePixel = 0
            b.ClipsDescendants = true; b.ZIndex = 203; b.Parent = card
            corner(b, 6); stroke(b, T.silver2, .7, 1)
            local row = Instance.new("Frame"); row.BackgroundTransparency = 1; row.Size = UDim2.new(1, 0, 1, 0); row.ZIndex = 204; row.Parent = b
            local ll = Instance.new("UIListLayout"); ll.FillDirection = Enum.FillDirection.Horizontal
            ll.HorizontalAlignment = Enum.HorizontalAlignment.Center; ll.VerticalAlignment = Enum.VerticalAlignment.Center
            ll.Padding = UDim.new(0, 7); ll.SortOrder = Enum.SortOrder.LayoutOrder; ll.Parent = row
            local ic = Instance.new("ImageLabel"); ic.Size = UDim2.new(0, 17, 0, 17); ic.BackgroundTransparency = 1
            ic.Image = icon(icn); ic.ImageColor3 = T.white; ic.ImageTransparency = .2; ic.LayoutOrder = 1; ic.ZIndex = 205; ic.Parent = row
            local tx = label(row, txt, 14, T.white, Enum.Font.GothamBold)
            tx.AutomaticSize = Enum.AutomaticSize.X; tx.Size = UDim2.new(0, 0, 1, 0); tx.TextTransparency = .2; tx.LayoutOrder = 2; tx.ZIndex = 205
            local fast = TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            b.MouseEnter:Connect(function()
                TweenService:Create(b, fast, {BackgroundTransparency = .85}):Play()
                TweenService:Create(ic, fast, {ImageTransparency = 0}):Play(); TweenService:Create(tx, fast, {TextTransparency = 0}):Play()
            end)
            b.MouseLeave:Connect(function()
                TweenService:Create(b, fast, {BackgroundTransparency = .935}):Play()
                TweenService:Create(ic, fast, {ImageTransparency = .2}):Play(); TweenService:Create(tx, fast, {TextTransparency = .2}):Play()
            end)
            -- ondulacao no ponto do clique
            b.InputBegan:Connect(function(io)
                if io.UserInputType ~= Enum.UserInputType.MouseButton1 and io.UserInputType ~= Enum.UserInputType.Touch then return end
                pcall(function()
                    local w = b.AbsoluteSize.X
                    local r = Instance.new("Frame"); r.AnchorPoint = Vector2.new(.5, .5); r.Size = UDim2.new(0, 0, 0, 0)
                    r.Position = UDim2.new(0, math.clamp(io.Position.X - b.AbsolutePosition.X, 0, w), 0, math.clamp(io.Position.Y - b.AbsolutePosition.Y, 0, b.AbsoluteSize.Y))
                    r.BackgroundColor3 = Color3.new(1, 1, 1); r.BackgroundTransparency = .7; r.BorderSizePixel = 0; r.ZIndex = 204
                    local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(1, 0); rc.Parent = r; r.Parent = b
                    TweenService:Create(r, TweenInfo.new(.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, w * 2.4, 0, w * 2.4), BackgroundTransparency = 1}):Play()
                    task.delay(.5, function() r:Destroy() end)
                end)
            end)
            return b
        end
        local yes = mk("Confirmar", "frown", .05, 0)
        local no = mk("Cancelar", "smile", .5, 10)

        local fi = TweenInfo.new(.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        TweenService:Create(ov, fi, {BackgroundTransparency = .3}):Play()
        TweenService:Create(cover, fi, {BackgroundTransparency = 1}):Play()
        bindTap(no, function() ov:Destroy() end) -- some na hora, sem animacao
        bindTap(yes, function()
            pcall(function() if closeHooks.float and closeHooks.float.Destroy then closeHooks.float:Destroy() end end)
            pcall(function()
                local fl = screen.Parent and screen.Parent:FindFirstChild("OrionStudios_Float")
                if fl then fl:Destroy() end
            end)
            screen:Destroy()
        end)
    end)
    -- sino de notificacoes (fica a esquerda do botao minimizar)
    do
        local bell = button(header, "Bell", UDim2.new(0, 28, 0, 28), UDim2.new(1, -106, 0, 12), T.panel)
        corner(bell, 8); stroke(bell, T.border, 0, 1)
        local bellIco = Instance.new("ImageLabel")
        bellIco.Size = UDim2.new(0, 14, 0, 14); bellIco.AnchorPoint = Vector2.new(.5,.5)
        bellIco.Position = UDim2.new(.5,0,.5,0); bellIco.BackgroundTransparency = 1
        bellIco.Image = icon("bell"); bellIco.ImageColor3 = T.silver; bellIco.Parent = bell
        local badge = Instance.new("Frame")
        badge.Name = "Badge"; badge.Size = UDim2.new(0, 9, 0, 9); badge.AnchorPoint = Vector2.new(1, 0)
        badge.Position = UDim2.new(1, -1, 0, 1); badge.BorderSizePixel = 0; badge.Visible = false
        badge.BackgroundColor3 = Bell.COL.success; badge.ZIndex = 3; badge.Parent = bell
        corner(badge, 5); stroke(badge, T.header, 0, 2)

        local pop = Instance.new("Frame")
        pop.Name = "NotifPanel"; pop.AnchorPoint = Vector2.new(1, 0); pop.Position = UDim2.new(1, -60, 0, 58)
        pop.Size = UDim2.new(0, 300, 0, 300); pop.BackgroundColor3 = T.panel; pop.BorderSizePixel = 0
        pop.Visible = false; pop.ZIndex = 50; pop.Parent = holder
        corner(pop, 10); stroke(pop, T.border, 0, 1)
        local ptitle = label(pop, "Notificações", 14, T.white, Enum.Font.GothamBold)
        ptitle.Position = UDim2.new(0, 38, 0, 8); ptitle.Size = UDim2.new(1, -52, 0, 18)
        do
            local bi = Instance.new("ImageLabel")
            bi.Size = UDim2.new(0, 18, 0, 18); bi.Position = UDim2.new(0, 14, 0, 8); bi.BackgroundTransparency = 1
            local okI, imgI = pcall(icon, "bell-ring")
            if not okI or imgI == "" then okI, imgI = pcall(icon, "bell") end
            bi.Image = (okI and imgI) or ""; bi.ImageColor3 = T.silver; bi.Parent = pop
        end
        local psub = label(pop, "", 11, T.muted)
        psub.Position = UDim2.new(0, 14, 0, 28); psub.Size = UDim2.new(1, -28, 0, 16)
        local sep1 = Instance.new("Frame"); sep1.Size = UDim2.new(1, 0, 0, 1); sep1.Position = UDim2.new(0, 0, 0, 52)
        sep1.BackgroundColor3 = T.border; sep1.BorderSizePixel = 0; sep1.Parent = pop
        local scroll = Instance.new("ScrollingFrame")
        scroll.Name = "List"; scroll.Position = UDim2.new(0, 0, 0, 53); scroll.Size = UDim2.new(1, 0, 1, -94)
        scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 3
        scroll.ScrollBarImageColor3 = T.silver2; scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; scroll.ScrollingDirection = Enum.ScrollingDirection.Y; scroll.Parent = pop
        local sl = Instance.new("UIListLayout"); sl.SortOrder = Enum.SortOrder.LayoutOrder; sl.Parent = scroll
        local sep2 = Instance.new("Frame"); sep2.Size = UDim2.new(1, 0, 0, 1); sep2.Position = UDim2.new(0, 0, 1, -41)
        sep2.BackgroundColor3 = T.border; sep2.BorderSizePixel = 0; sep2.Parent = pop
        local readAll = button(pop, "ReadAll", UDim2.new(1, -16, 0, 28), UDim2.new(0, 8, 1, -35), T.header)
        corner(readAll, 7)
        readAll.Font = Enum.Font.GothamBold; readAll.TextSize = 11; readAll.TextColor3 = T.silver
        readAll.Text = ""
        local raRow = Instance.new("Frame")
        raRow.Name = "Row"; raRow.BackgroundTransparency = 1; raRow.AnchorPoint = Vector2.new(.5, .5)
        raRow.Position = UDim2.new(.5, 0, .5, 0); raRow.Size = UDim2.new(0, 0, 1, 0); raRow.AutomaticSize = Enum.AutomaticSize.X; raRow.Parent = readAll
        local raLay = Instance.new("UIListLayout")
        raLay.FillDirection = Enum.FillDirection.Horizontal; raLay.VerticalAlignment = Enum.VerticalAlignment.Center
        raLay.HorizontalAlignment = Enum.HorizontalAlignment.Center; raLay.SortOrder = Enum.SortOrder.LayoutOrder; raLay.Padding = UDim.new(0, 6); raLay.Parent = raRow
        local raIco = Instance.new("ImageLabel")
        raIco.Size = UDim2.new(0, 16, 0, 16); raIco.BackgroundTransparency = 1; raIco.ImageColor3 = T.silver; raIco.LayoutOrder = 1; raIco.Parent = raRow
        do
            local okC, imgC = pcall(icon, "check-check")
            raIco.Image = (okC and imgC) or ""
        end
        local raLbl = label(raRow, "", 11, T.silver, Enum.Font.GothamBold)
        raLbl.Size = UDim2.new(0, 0, 1, 0); raLbl.AutomaticSize = Enum.AutomaticSize.X; raLbl.LayoutOrder = 2
        raLbl.TextXAlignment = Enum.TextXAlignment.Left
        pcall(function() noSink(raRow) end)

        local function render()
            local pt = OrionLib.IsPT ~= false
            for _, x in ipairs(scroll:GetChildren()) do
                if not x:IsA("UIListLayout") then x:Destroy() end
            end
            local unread = 0
            for _, n in ipairs(Bell.items) do if not n.read then unread = unread + 1 end end
            ptitle.Text = pt and "Notificações" or "Notifications"
            raLbl.Text = pt and "Marcar todas como lidas" or "Mark all as read"
            if pt then
                psub.Text = "Você possui " .. unread .. (unread == 1 and " mensagem não lida" or " mensagens não lidas")
            else
                psub.Text = "You have " .. unread .. " unread " .. (unread == 1 and "message" or "messages")
            end
            local top
            for _, n in ipairs(Bell.items) do if not n.read then top = n.type break end end
            badge.Visible = top ~= nil
            if top then badge.BackgroundColor3 = Bell.COL[top] end
            local order = 0
            local function header2(txt)
                order = order + 1
                local h = label(scroll, txt, 10, T.muted, Enum.Font.GothamBold)
                h.LayoutOrder = order; h.Size = UDim2.new(1, 0, 0, 26)
                local hp = Instance.new("UIPadding"); hp.PaddingLeft = UDim.new(0, 14); hp.PaddingTop = UDim.new(0, 6); hp.Parent = h
            end
            local function addRow(n)
                order = order + 1
                local col = Bell.COL[n.type] or Bell.COL.warning
                local row = Instance.new("Frame"); row.Name = "Item"; row.LayoutOrder = order
                row.Size = UDim2.new(1, 0, 0, 46); row.BackgroundTransparency = 1; row.BorderSizePixel = 0; row.Parent = scroll
                local av = Instance.new("Frame"); av.Size = UDim2.new(0, 34, 0, 34); av.Position = UDim2.new(0, 12, .5, -17)
                av.BackgroundColor3 = T.silver2; av.BackgroundTransparency = .85; av.BorderSizePixel = 0; av.Parent = row; corner(av, 17)
                local ai = Instance.new("ImageLabel"); ai.Size = UDim2.new(0, 20, 0, 20); ai.AnchorPoint = Vector2.new(.5,.5)
                ai.Position = UDim2.new(.5, 0, .5, 0); ai.BackgroundTransparency = 1; ai.Image = Bell.icon(n.type); ai.ImageColor3 = T.silver2; ai.Parent = av
                local main = (n.text and n.text ~= "") and n.text or n.title
                -- quebra forcada: palavras longas sem espaco sao cortadas em linhas (quebra de linha comum)
                main = tostring(main):gsub("%S+", function(w)
                    if #w <= 26 then return w end
                    local parts, chars = {}, {}
                    for c in w:gmatch(utf8.charpattern) do
                        chars[#chars+1] = c
                        if #chars == 26 then parts[#parts+1] = table.concat(chars); chars = {} end
                    end
                    if #chars > 0 then parts[#parts+1] = table.concat(chars) end
                    return table.concat(parts, "\n")
                end)
                row.AutomaticSize = Enum.AutomaticSize.Y; row.Size = UDim2.new(1, 0, 0, 48)
                local cbox = Instance.new("Frame"); cbox.Name = "Content"; cbox.BackgroundTransparency = 1; cbox.BorderSizePixel = 0
                cbox.Position = UDim2.new(0, 54, 0, 0); cbox.Size = UDim2.new(1, -76, 0, 0); cbox.AutomaticSize = Enum.AutomaticSize.Y; cbox.Parent = row
                local cp = Instance.new("UIPadding"); cp.PaddingTop = UDim.new(0, 8); cp.PaddingBottom = UDim.new(0, 8); cp.Parent = cbox
                local cl = Instance.new("UIListLayout"); cl.SortOrder = Enum.SortOrder.LayoutOrder; cl.Padding = UDim.new(0, 0); cl.Parent = cbox
                local l1 = label(cbox, main, 12, n.read and T.muted or T.white, Enum.Font.GothamBold)
                l1.LayoutOrder = 1; l1.Size = UDim2.new(1, 0, 0, 0); l1.AutomaticSize = Enum.AutomaticSize.Y
                l1.TextWrapped = true; l1.TextYAlignment = Enum.TextYAlignment.Top; l1.TextTruncate = Enum.TextTruncate.None
                local l2 = label(cbox, Bell.ago(n.ts, pt), 12, T.muted)
                l2.LayoutOrder = 2; l2.Size = UDim2.new(1, 0, 0, 14); l2.TextYAlignment = Enum.TextYAlignment.Top
                if not n.read then
                    local dot = Instance.new("Frame"); dot.Size = UDim2.new(0, 8, 0, 8); dot.AnchorPoint = Vector2.new(1, .5)
                    dot.Position = UDim2.new(1, -12, .5, 0); dot.BackgroundColor3 = col; dot.BorderSizePixel = 0; dot.Parent = row; corner(dot, 4)
                end
                local hit = button(row, "Hit", UDim2.new(1, 0, 1, 0), UDim2.new(), Color3.new()); hit.BackgroundTransparency = 1; hit.Text = ""
                bindTap(hit, function() n.read = true; render() end)
            end
            if #Bell.items == 0 then
                local e = label(scroll, pt and "Nenhuma notificação ainda." or "No notifications yet.", 11, T.muted)
                e.Size = UDim2.new(1, 0, 0, 60); e.TextXAlignment = Enum.TextXAlignment.Center; e.LayoutOrder = 1
                return
            end
            local newer, older = {}, {}
            for _, n in ipairs(Bell.items) do table.insert(n.read and older or newer, n) end
            for _, n in ipairs(newer) do addRow(n) end
            if #older > 0 then header2(pt and "ANTERIORES" or "EARLIER"); for _, n in ipairs(older) do addRow(n) end end
        end
        Bell.render = render
        bindTap(readAll, function() for _, n in ipairs(Bell.items) do n.read = true end render() end)
        bindTap(bell, function()
            if not pop.Visible then
                local hh = holder.AbsoluteSize.Y
                pop.Size = UDim2.new(0, math.min(340, math.max(240, holder.AbsoluteSize.X - 80)), 0, math.max(200, math.min(400, hh - 90)))
                render()
            end
            pop.Visible = not pop.Visible
        end)
        render()
    end
    local collapsed = false
    bindTap(minimize, function()
        collapsed = not collapsed
        holder.Visible = not collapsed
    end)
    draggable(header, holder)

    -- barrinha para mover a interface (fica na base da janela)
    do
        local mv = button(holder.Parent, "OrionMoveBar", UDim2.new(0, 160, 0, 22), UDim2.new(), T.bg)
        mv.AnchorPoint = Vector2.new(.5, 0); mv.BackgroundTransparency = 1; mv.Text = ""; mv.ZIndex = 59
        do
            local conn
            conn = game:GetService("RunService").Heartbeat:Connect(function()
                if not holder.Parent then mv:Destroy(); conn:Disconnect() return end
                mv.Visible = holder.Visible
                local p, sz = holder.AbsolutePosition, holder.AbsoluteSize
                mv.Position = UDim2.fromOffset(p.X + sz.X / 2, p.Y + sz.Y - 5)
            end)
        end
        holder:GetPropertyChangedSignal("Visible"):Connect(function() mv.Visible = holder.Visible end) -- abre/fecha junto, no mesmo instante
        local pill = Instance.new("Frame")
        pill.Name = "Pill"; pill.Size = UDim2.new(0, 100, 0, 3); pill.AnchorPoint = Vector2.new(.5, .5); pill.Position = UDim2.new(.5, 0, .5, 0)
        pill.BackgroundColor3 = T.accent; pill.BackgroundTransparency = .25; pill.BorderSizePixel = 0; pill.ZIndex = 60; pill.Active = false; pill.Parent = mv; corner(pill, 3)
        draggable(mv, holder)
    end

    -- barrinha de redimensionamento (canto inferior direito): muda largura/altura e escala os elementos
    do
        local uiScale = Instance.new("UIScale"); uiScale.Name = "WindowScale"; uiScale.Scale = 1; uiScale.Parent = holder
        local baseW, baseH = winW, winH
        local grip = button(holder, "ResizeGrip", UDim2.new(0, 30, 0, 30), UDim2.new(1, 0, 1, 0), T.bg)
        grip.AnchorPoint = Vector2.new(1, 1); grip.BackgroundTransparency = 1; grip.Text = ""; grip.ZIndex = 60
        for _, spec in ipairs({ {16, -15}, {8, -9} }) do
            local bar = Instance.new("Frame")
            bar.Size = UDim2.new(0, spec[1], 0, 3); bar.AnchorPoint = Vector2.new(.5, .5)
            bar.Position = UDim2.new(1, spec[2], 1, spec[2]); bar.Rotation = -45
            bar.BackgroundColor3 = T.accent; bar.BackgroundTransparency = .35; bar.BorderSizePixel = 0; bar.ZIndex = 61
            bar.Parent = grip; corner(bar, 2)
        end
        local held, lastInput, startMouse, startSize, startTL, startOff, startScale = false, nil, nil, nil, nil, nil, 1
        grip.InputBegan:Connect(function(io)
            if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
                held = true
                startMouse = io.Position; startSize = holder.AbsoluteSize; startTL = holder.AbsolutePosition
                startOff = holder.Position; startScale = uiScale.Scale
                io.Changed:Connect(function() if io.UserInputState == Enum.UserInputState.End then held = false end end)
            end
        end)
        grip.InputChanged:Connect(function(io)
            if io.UserInputType == Enum.UserInputType.MouseMovement or io.UserInputType == Enum.UserInputType.Touch then lastInput = io end
        end)
        UserInputService.InputChanged:Connect(function(io)
            if not held or io ~= lastInput then return end
            local vp = viewport()
            local dW = math.clamp(startSize.X + (io.Position.X - startMouse.X), baseW, math.max(baseW, vp.X - 10))
            local dH = math.clamp(startSize.Y + (io.Position.Y - startMouse.Y), baseH, math.max(baseH, vp.Y - 10))
            local s = math.clamp(math.min(dW / baseW, dH / baseH), 1, 1.4)
            -- mantem o canto superior esquerdo fixo enquanto redimensiona
            local dcx = (startTL.X + dW / 2) - (startTL.X + startSize.X / 2)
            local dcy = (startTL.Y + dH / 2) - (startTL.Y + startSize.Y / 2)
            uiScale.Scale = s
            holder.Size = UDim2.new(0, dW / s, 0, dH / s)
            holder.Position = UDim2.new(startOff.X.Scale, (startOff.X.Offset * startScale + dcx) / s, startOff.Y.Scale, (startOff.Y.Offset * startScale + dcy) / s)
            holder:SetAttribute("UserSized", true)
        end)
    end

    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, tabWidth, 1, -52)
    sidebar.Position = UDim2.new(0, 0, 0, 52)
    sidebar.BackgroundColor3 = T.sidebar
    sidebar.BorderSizePixel = 0
    sidebar.Parent = holder
    corner(sidebar, 14) -- arredonda o canto de baixo (esquerda)
    do
        local fTop = Instance.new("Frame"); fTop.Name = "SquareTop"; fTop.Size = UDim2.new(1, 0, 0, 16)
        fTop.BackgroundColor3 = T.sidebar; fTop.BorderSizePixel = 0; fTop.Parent = sidebar
        local fRight = Instance.new("Frame"); fRight.Name = "SquareRight"; fRight.Size = UDim2.new(0, 16, 1, 0); fRight.Position = UDim2.new(1, -16, 0, 0)
        fRight.BackgroundColor3 = T.sidebar; fRight.BorderSizePixel = 0; fRight.Parent = sidebar
    end
    local sideRule = Instance.new("Frame")
    sideRule.Size = UDim2.new(0, 1, 1, -20)
    sideRule.Position = UDim2.new(1, -1, 0, 10)
    sideRule.BackgroundColor3 = T.border
    sideRule.BorderSizePixel = 0
    sideRule.Parent = sidebar
    local tabList = Instance.new("ScrollingFrame")
    tabList.Name = "Navigation"
    tabList.Size = UDim2.new(1, -14, 1, -68)
    tabList.Position = UDim2.new(0, 7, 0, 10)
    tabList.BackgroundTransparency = 1
    tabList.BorderSizePixel = 0
    tabList.ScrollBarThickness = 0
    tabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabList.CanvasSize = UDim2.new(0,0,0,0)
    tabList.Parent = sidebar
    local navLayout = Instance.new("UIListLayout")
    navLayout.Padding = UDim.new(0, 6); navLayout.SortOrder = Enum.SortOrder.LayoutOrder; navLayout.Parent = tabList
    local navPad = Instance.new("UIPadding")
    navPad.PaddingLeft = UDim.new(0, 3); navPad.PaddingRight = UDim.new(0, 3); navPad.PaddingTop = UDim.new(0, 3); navPad.PaddingBottom = UDim.new(0, 3); navPad.Parent = tabList

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -tabWidth, 1, -52)
    content.Position = UDim2.new(0, tabWidth, 0, 52)
    content.BackgroundColor3 = T.bg
    content.BorderSizePixel = 0
    content.ClipsDescendants = true
    content.Parent = holder
    corner(content, 14) -- arredonda o canto de baixo (direita)
    do
        local cTop = Instance.new("Frame"); cTop.Name = "SquareTop"; cTop.Size = UDim2.new(1, 0, 0, 16)
        cTop.BackgroundColor3 = T.bg; cTop.BorderSizePixel = 0; cTop.Parent = content
        local cLeft = Instance.new("Frame"); cLeft.Name = "SquareLeft"; cLeft.Size = UDim2.new(0, 16, 1, 0)
        cLeft.BackgroundColor3 = T.bg; cLeft.BorderSizePixel = 0; cLeft.Parent = content
    end

    local tabs, activeTab = {}, nil
    local collapsed = false
    local function iconPos() return collapsed and UDim2.new(.5, -14, .5, -14) or UDim2.new(0, 7, .5, -14) end
    local fadeCover = Instance.new("Frame"); fadeCover.Name = "FadeCover"
    fadeCover.Size = UDim2.new(1, 0, 1, 0); fadeCover.BackgroundColor3 = T.bg; fadeCover.BackgroundTransparency = 1
    fadeCover.BorderSizePixel = 0; fadeCover.ZIndex = 30; fadeCover.Active = false; fadeCover.Parent = content
    local function fadeIn()
        fadeCover.BackgroundTransparency = 0
        TweenService:Create(fadeCover, TweenInfo.new(.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
    end
    local window = { _holder = holder, _screen = screen, _tabs = tabs }

    local function setActive(entry)
        activeTab = entry
        for _, tab in ipairs(tabs) do
            local on = tab == entry
            local was = tab.page.Visible
            local quick = TweenInfo.new(.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            TweenService:Create(tab.button, quick, {
                BackgroundColor3 = on and Color3.fromRGB(31,31,37) or T.sidebar,
                BackgroundTransparency = on and 0 or 1
            }):Play()
            tab.label.TextColor3 = on and T.white or T.muted
            tab.icon.ImageColor3 = on and T.silver or T.muted
            TweenService:Create(tab.outline, quick, {Transparency = on and .45 or .75}):Play()
            if tab.activeLight then TweenService:Create(tab.activeLight, quick, {Transparency = on and 0 or 1}):Play() end
            TweenService:Create(tab.label, quick, {Position = UDim2.new(0, on and 48 or 44, 0, 0)}):Play()
            TweenService:Create(tab.tile, quick, {Position = iconPos()}):Play()
            if on then
                tab.indicator.Visible = true
                tab.page.Visible = true
                if not was then fadeIn() end
            else
                tab.indicator.Visible = false
                tab.page.Visible = false
            end
        end
    end

    -- perfil do jogador (foto em circulo + nome, com efeitos)
    local profileSet
    do
        local lp = Players.LocalPlayer
        local pf = Instance.new("Frame"); pf.Name = "Profile"
        pf.Size = UDim2.new(1, -14, 0, 44); pf.Position = UDim2.new(0, 7, 1, -52)
        pf.BackgroundColor3 = T.panel; pf.BorderSizePixel = 0; pf.Parent = sidebar
        corner(pf, 10)
        local pst = stroke(pf, T.accent, .45, 1.2) -- contorno verde elegante
        local av = Instance.new("ImageLabel"); av.Name = "Avatar"
        av.Size = UDim2.new(0, 30, 0, 30); av.Position = UDim2.new(0, 7, .5, -15)
        av.BackgroundColor3 = T.sidebar; av.BorderSizePixel = 0
        av.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(lp and lp.UserId or 0) .. "&w=150&h=150"
        av.Parent = pf
        local avc = Instance.new("UICorner"); avc.CornerRadius = UDim.new(1, 0); avc.Parent = av
        local avScale = Instance.new("UIScale"); avScale.Parent = av
        -- anel de luz girando em volta da foto
        local ring = stroke(av, Color3.new(1, 1, 1), 0, 2)
        local rg = Instance.new("UIGradient")
        rg.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(.35, .9), NumberSequenceKeypoint.new(.5, 0),
            NumberSequenceKeypoint.new(.65, .9), NumberSequenceKeypoint.new(1, 1),
        })
        rg.Parent = ring
        lightGrads[#lightGrads + 1] = rg
        -- mesma luz na borda do cartao de perfil, sincronizada
        do
            local pl = Instance.new("UIStroke"); pl.Name = "ProfileLight"; pl.Thickness = 1.5; pl.Color = Color3.new(1, 1, 1)
            pl.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; pl.Parent = pf
            local pg = Instance.new("UIGradient"); pg.Transparency = rg.Transparency; pg.Parent = pl
            lightGrads[#lightGrads + 1] = pg
        end
        -- ponto "online" fixo
        local dot = Instance.new("Frame"); dot.Name = "OnlineDot"
        dot.Size = UDim2.new(0, 8, 0, 8); dot.AnchorPoint = Vector2.new(1, 1); dot.Position = UDim2.new(1, 1, 1, 1)
        dot.BackgroundColor3 = Bell.COL.success; dot.BorderSizePixel = 0; dot.ZIndex = 3; dot.Parent = av
        corner(dot, 4); stroke(dot, T.panel, 0, 1.5)
        local nm = label(pf, lp and lp.DisplayName or "Player", 12, T.white, Enum.Font.GothamBold)
        nm.Position = UDim2.new(0, 46, 0, 0); nm.Size = UDim2.new(1, -52, 1, 0); nm.TextTruncate = Enum.TextTruncate.AtEnd
        -- hover: fundo acende, foto cresce e nome brilha
        local hi = TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        pf.MouseEnter:Connect(function()
            TweenService:Create(pf, hi, {BackgroundColor3 = Color3.fromRGB(31, 31, 37)}):Play()
            TweenService:Create(pst, hi, {Transparency = .2}):Play()
            TweenService:Create(avScale, TweenInfo.new(.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1.12}):Play()
        end)
        pf.MouseLeave:Connect(function()
            TweenService:Create(pf, hi, {BackgroundColor3 = T.panel}):Play()
            TweenService:Create(pst, hi, {Transparency = .55}):Play()
            TweenService:Create(avScale, hi, {Scale = 1}):Play()
        end)
        -- entrada: desliza de baixo e aparece
        do
            local tp, ts = pf.Position, pf.Size
            pf.Position = tp + UDim2.new(0, 0, 0, 14); pf.BackgroundTransparency = 1; nm.TextTransparency = 1; av.ImageTransparency = 1
            local ent = TweenInfo.new(.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            task.delay(.15, function()
                TweenService:Create(pf, ent, {Position = tp, BackgroundTransparency = 0}):Play()
                TweenService:Create(nm, ent, {TextTransparency = 0}):Play()
                TweenService:Create(av, ent, {ImageTransparency = 0}):Play()
            end)
        end
        function profileSet(c, ti)
            nm.Visible = not c
            TweenService:Create(pf, ti, {
                Size = UDim2.new(1, -14, 0, c and 40 or 44), Position = UDim2.new(0, 7, 1, c and -48 or -52)
            }):Play()
            TweenService:Create(av, ti, {Position = c and UDim2.new(.5, -15, .5, -15) or UDim2.new(0, 7, .5, -15)}):Play()
        end
    end

    -- seta para minimizar a barra lateral (somente icones)
    do
        local arrow = button(header, "CollapseBtn", UDim2.new(0, 28, 0, 28), UDim2.new(1, -140, 0, 12), T.panel)
        corner(arrow, 8); stroke(arrow, T.border, 0, 1)
        local arrowIco = Instance.new("ImageLabel"); arrowIco.Size = UDim2.new(0, 14, 0, 14); arrowIco.AnchorPoint = Vector2.new(.5, .5)
        arrowIco.Position = UDim2.new(.5, 0, .5, 0); arrowIco.BackgroundTransparency = 1; arrowIco.ImageColor3 = T.silver; arrowIco.Parent = arrow
        local function arrowSkin(c)
            local img = icon(c and "panel-left-open" or "panel-left-close")
            if img == "" then img = icon(c and "chevron-right" or "chevron-left") end
            arrowIco.Image = img
            if img == "" then arrow.Text = c and "\u{203A}" or "\u{2039}"; arrow.TextColor3 = T.silver; arrow.Font = Enum.Font.GothamBold; arrow.TextSize = 20 end
        end
        arrowSkin(false)
        bindTap(arrow, function()
            collapsed = not collapsed
            local w = collapsed and 54 or tabWidth
            local ti = TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            TweenService:Create(sidebar, ti, {Size = UDim2.new(0, w, 1, -52)}):Play()
            TweenService:Create(content, ti, {Size = UDim2.new(1, -w, 1, -52), Position = UDim2.new(0, w, 0, 52)}):Play()
            arrowSkin(collapsed); profileSet(collapsed, ti)
            OrionLib.SidebarCollapsed = collapsed
            for _, f in ipairs(OrionLib._collapseCbs or {}) do pcall(f, collapsed) end
            for _, tab in ipairs(tabs) do
                tab.label.Visible = not collapsed
                TweenService:Create(tab.tile, ti, {Position = iconPos()}):Play()
            end
        end)
    end

    function window:AddTab(tabCfg)
        tabCfg = tabCfg or {}
        local name = tabCfg.Name or ("Tab " .. (#tabs + 1))
        local item = { Name = name }
        local nav = button(tabList, "Nav_" .. name, UDim2.new(1, 0, 0, 38), UDim2.new(), T.sidebar)
        nav.LayoutOrder = #tabs + 1
        corner(nav, 8)
        local navStroke = stroke(nav, T.accent, .55, 1)
        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, 3, 0, 20); indicator.Position = UDim2.new(0, 2, .5, -10)
        indicator.BackgroundColor3 = T.white; indicator.BorderSizePixel = 0; indicator.Visible = false; indicator.Parent = nav
        corner(indicator, 2)
        local navIcon = Instance.new("ImageLabel")
        local tile = Instance.new("Frame"); tile.Name = "IconTile"
        tile.Size = UDim2.new(0, 28, 0, 28); tile.Position = iconPos()
        tile.BackgroundColor3 = Color3.fromRGB(5, 5, 7); tile.BorderSizePixel = 0; tile.Parent = nav
        corner(tile, 8); stroke(tile, T.accent, .4, 1)
        navIcon.Size = UDim2.new(0, 16, 0, 16); navIcon.AnchorPoint = Vector2.new(.5, .5); navIcon.Position = UDim2.new(.5, 0, .5, 0)
        navIcon.BackgroundTransparency = 1; navIcon.Image = icon(tabCfg.Icon or "home"); navIcon.ImageColor3 = T.muted; navIcon.Parent = tile
        local navLabel = label(nav, name, 12, T.muted, Enum.Font.GothamMedium)
        navLabel.Position = UDim2.new(0, 44, 0, 0); navLabel.Size = UDim2.new(1, -50, 1, 0)
        navLabel.TextTruncate = Enum.TextTruncate.AtEnd

        local page = Instance.new("ScrollingFrame")
        page.Name = "Page_" .. name
        page.Size = UDim2.new(1, -24, 1, -20)
        page.Position = UDim2.new(0, 12, 0, 10)
        page.BackgroundTransparency = 1; page.BorderSizePixel = 0
        page.ScrollBarThickness = 0; page.ScrollBarImageColor3 = T.silver2; page.ScrollBarImageTransparency = 1
        pcall(function() page.TopImage = ""; page.MidImage = ""; page.BottomImage = "" end)
        pcall(function() page.VerticalScrollBarInset = Enum.ScrollBarInset.None end)
        page:GetPropertyChangedSignal("ScrollBarThickness"):Connect(function() if page.ScrollBarThickness ~= 0 then page.ScrollBarThickness = 0 end end)
        page.CanvasSize = UDim2.new(0,0,0,0); page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.ScrollingDirection = Enum.ScrollingDirection.Y; page.ScrollingEnabled = true
        page.Visible = false; page.Parent = content
        local pageLayout = Instance.new("UIListLayout")
        pageLayout.Padding = UDim.new(0, 12); pageLayout.SortOrder = Enum.SortOrder.LayoutOrder; pageLayout.Parent = page
        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 8); pad.PaddingBottom = UDim.new(0, 16); pad.PaddingLeft = UDim.new(0, 8); pad.PaddingRight = UDim.new(0, 12); pad.Parent = page

        -- barra de rolagem propria: tamanho fixo (nao encolhe) e arrastavel (move rapido como no PC)
        do
            local THUMB = 46
            local track = Instance.new("Frame")
            track.Name = "ScrollTrack_" .. name; track.Size = UDim2.new(0, 8, 1, -46); track.Position = UDim2.new(1, -11, 0, 12)
            track.BackgroundColor3 = T.border; track.BackgroundTransparency = .55; track.BorderSizePixel = 0
            track.ZIndex = 40; track.Visible = false; track.Parent = content; corner(track, 4)
            local thumb = Instance.new("TextButton")
            thumb.Name = "Thumb"; thumb.Text = ""; thumb.AutoButtonColor = false; thumb.Size = UDim2.new(1, 0, 0, THUMB)
            thumb.BackgroundColor3 = T.accent; thumb.BackgroundTransparency = .1; thumb.BorderSizePixel = 0; thumb.ZIndex = 41; thumb.Parent = track; corner(thumb, 4)
            local function maxScroll() return math.max(0, page.AbsoluteCanvasSize.Y - page.AbsoluteSize.Y) end
            local function room() return math.max(1, track.AbsoluteSize.Y - THUMB) end
            local function refresh()
                local ms = maxScroll()
                track.Visible = page.Visible and ms > 1
                if ms <= 1 then return end
                local r = math.clamp(page.CanvasPosition.Y / ms, 0, 1)
                thumb.Position = UDim2.new(0, 0, 0, math.floor(r * room()))
            end
            page:GetPropertyChangedSignal("CanvasPosition"):Connect(refresh)
            page:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(refresh)
            page:GetPropertyChangedSignal("AbsoluteSize"):Connect(refresh)
            page:GetPropertyChangedSignal("Visible"):Connect(refresh)
            local held, lastIn, startY, startPos = false, nil, 0, 0
            thumb.InputBegan:Connect(function(io)
                if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
                    held, startY, startPos = true, io.Position.Y, page.CanvasPosition.Y
                    io.Changed:Connect(function() if io.UserInputState == Enum.UserInputState.End then held = false end end)
                end
            end)
            thumb.InputChanged:Connect(function(io)
                if io.UserInputType == Enum.UserInputType.MouseMovement or io.UserInputType == Enum.UserInputType.Touch then lastIn = io end
            end)
            UserInputService.InputChanged:Connect(function(io)
                if held and io == lastIn then
                    local ms = maxScroll()
                    local dy = (io.Position.Y - startY) / room() * ms
                    page.CanvasPosition = Vector2.new(0, math.clamp(startPos + dy, 0, ms))
                end
            end)
            task.defer(refresh)
        end
        -- cabecalho da aba: icone + nome grande + descricao
        do
            local head = Instance.new("Frame")
            head.Name = "TabHeader"; head.Size = UDim2.new(1,0,0,0); head.AutomaticSize = Enum.AutomaticSize.Y
            head.BackgroundTransparency = 1; head.LayoutOrder = -100; head.Parent = page
            local hl = Instance.new("UIListLayout")
            hl.Padding = UDim.new(0,6); hl.SortOrder = Enum.SortOrder.LayoutOrder; hl.Parent = head
            local hp = Instance.new("UIPadding"); hp.PaddingBottom = UDim.new(0,4); hp.Parent = head
            local row1 = Instance.new("Frame")
            row1.Size = UDim2.new(1,0,0,32); row1.BackgroundTransparency = 1; row1.LayoutOrder = 1; row1.Parent = head
            local hIcon = Instance.new("ImageLabel")
            hIcon.Size = UDim2.new(0,26,0,26); hIcon.Position = UDim2.new(0,0,.5,-13)
            hIcon.BackgroundTransparency = 1; hIcon.Image = icon(tabCfg.Icon or "home"); hIcon.ImageColor3 = T.white; hIcon.Parent = row1
            local hTitle = label(row1, tabCfg.Title or name, 24, T.white, Enum.Font.GothamBold)
            hTitle.Position = UDim2.new(0,36,0,0); hTitle.Size = UDim2.new(1,-36,1,0)
            hTitle.TextXAlignment = Enum.TextXAlignment.Left; hTitle.TextTruncate = Enum.TextTruncate.AtEnd
            -- reflexo prateado passando no icone e no nome da aba
            for _, obj in ipairs({hIcon, hTitle}) do
                pcall(function()
                    local sg = Instance.new("UIGradient")
                    sg.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(150,150,162)),
                        ColorSequenceKeypoint.new(.5, Color3.fromRGB(255,255,255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(150,150,162))
                    })
                    sg.Rotation = 20; sg.Offset = Vector2.new(-1,0); sg.Parent = obj
                    lightSheens[#lightSheens + 1] = sg
                end)
            end
            -- linha de luz animada sob o titulo
            do
                local track = Instance.new("Frame")
                track.Size = UDim2.new(1,0,0,2); track.BackgroundColor3 = T.border; track.BorderSizePixel = 0
                track.LayoutOrder = 3; track.ClipsDescendants = true; track.Parent = head; corner(track, 1)
                local glow = Instance.new("Frame")
                glow.Size = UDim2.new(1,0,1,0); glow.BackgroundColor3 = Color3.new(1,1,1); glow.BorderSizePixel = 0; glow.Parent = track
                local gg = Instance.new("UIGradient")
                gg.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(.4,1),
                    NumberSequenceKeypoint.new(.5,0), NumberSequenceKeypoint.new(.6,1), NumberSequenceKeypoint.new(1,1)
                })
                gg.Offset = Vector2.new(-1,0); gg.Parent = glow
                pcall(function()
                    lightSheens[#lightSheens + 1] = gg
                end)
            end
            if tabCfg.Description and tabCfg.Description ~= "" then
                local hDesc = label(head, tabCfg.Description, 14, T.muted, Enum.Font.Gotham)
                hDesc.Size = UDim2.new(1,0,0,0); hDesc.AutomaticSize = Enum.AutomaticSize.Y
                hDesc.TextWrapped = true; hDesc.TextXAlignment = Enum.TextXAlignment.Left
                hDesc.TextYAlignment = Enum.TextYAlignment.Top; hDesc.LayoutOrder = 2
            end
        end

        item.button, item.indicator, item.icon, item.label, item.outline, item.page = nav, indicator, navIcon, navLabel, navStroke, page
        item.tile = tile

        -- ===== efeitos da aba: hover, clique (squish), brilho e icone animado =====
        do
            nav.ClipsDescendants = true
            local navScale = Instance.new("UIScale"); navScale.Parent = nav
            local iconScale = Instance.new("UIScale"); iconScale.Parent = navIcon
            local shine = Instance.new("Frame")
            shine.Name = "Shine"; shine.Size = UDim2.new(0.35, 0, 1, 0); shine.Position = UDim2.new(-0.4, 0, 0, 0)
            shine.BackgroundColor3 = Color3.new(1, 1, 1); shine.BackgroundTransparency = 0.8
            shine.BorderSizePixel = 0; shine.Visible = false; shine.Parent = nav
            local sg = Instance.new("UIGradient")
            sg.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(.5, 0), NumberSequenceKeypoint.new(1, 1)
            })
            sg.Parent = shine
            item.iconScale, item.shine = iconScale, shine
            -- luz giratoria na borda da aba ativa
            local aLight = Instance.new("UIStroke")
            aLight.Name = "ActiveLight"; aLight.Thickness = 1.4; aLight.Color = Color3.new(1, 1, 1)
            aLight.Transparency = 1; aLight.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; aLight.Parent = nav
            local ag = Instance.new("UIGradient")
            ag.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(.30, 1), NumberSequenceKeypoint.new(.45, .3),
                NumberSequenceKeypoint.new(.50, 0), NumberSequenceKeypoint.new(.55, .3), NumberSequenceKeypoint.new(.70, 1),
                NumberSequenceKeypoint.new(1, 1),
            })
            ag.Parent = aLight
            pcall(function()
                lightGrads[#lightGrads + 1] = ag
                -- indicador "respirando"
                TweenService:Create(indicator, TweenInfo.new(1.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true, 0), {BackgroundTransparency = .5}):Play()
            end)
            item.activeLight = aLight

            local fast = TweenInfo.new(.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            nav.MouseEnter:Connect(function()
                if activeTab == item then return end
                TweenService:Create(nav, fast, {BackgroundColor3 = Color3.fromRGB(24,24,29), BackgroundTransparency = .35}):Play()
                TweenService:Create(navStroke, fast, {Transparency = .55}):Play()
                TweenService:Create(navIcon, fast, {ImageColor3 = T.silver}):Play()
                navLabel.TextColor3 = T.silver
            end)
            nav.MouseLeave:Connect(function()
                TweenService:Create(navScale, fast, {Scale = 1}):Play()
                if activeTab == item then return end
                TweenService:Create(nav, fast, {BackgroundTransparency = 1}):Play()
                TweenService:Create(navStroke, fast, {Transparency = .75}):Play()
                TweenService:Create(navIcon, fast, {ImageColor3 = T.muted}):Play()
                navLabel.TextColor3 = T.muted
            end)
        end

        table.insert(tabs, item)
        bindTap(nav, function() setActive(item) end)
        if #tabs == 1 then setActive(item) end

        function item:AddSection(sectionTitle, collapsible, sectionIcon, startClosed)
            local section = {}
            local wrap = Instance.new("Frame")
            wrap.Name = "Section_" .. tostring(sectionTitle)
            wrap.Size = UDim2.new(1, 0, 0, 0)
            wrap.AutomaticSize = Enum.AutomaticSize.Y
            wrap.BackgroundColor3 = Color3.fromRGB(12,12,15)
            wrap.BorderSizePixel = 0
            wrap.Parent = page
            corner(wrap, 10); stroke(wrap, Color3.fromRGB(40,40,47), .25, 1)
            -- luz que circula pelas bordas da secao
            do
                local glow = Instance.new("UIStroke")
                glow.Name = "BorderLight"
                glow.Color = Color3.new(1, 1, 1)
                glow.Thickness = 1.6
                glow.Transparency = 0
                glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                glow.Parent = wrap
                local gg = Instance.new("UIGradient")
                gg.Color = ColorSequence.new(Color3.fromRGB(255,255,255))
                gg.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0,   1),
                    NumberSequenceKeypoint.new(.30, 1),
                    NumberSequenceKeypoint.new(.42, .35),
                    NumberSequenceKeypoint.new(.50, 0),
                    NumberSequenceKeypoint.new(.58, .35),
                    NumberSequenceKeypoint.new(.70, 1),
                    NumberSequenceKeypoint.new(1,   1),
                })
                gg.Rotation = 0
                gg.Parent = glow
                lightGrads[#lightGrads + 1] = gg
            end
            local secLayout = Instance.new("UIListLayout")
            secLayout.Padding = UDim.new(0, 8); secLayout.SortOrder = Enum.SortOrder.LayoutOrder; secLayout.Parent = wrap
            local padding = Instance.new("UIPadding")
            padding.PaddingLeft = UDim.new(0, 11); padding.PaddingRight = UDim.new(0, 11)
            padding.PaddingTop = UDim.new(0, 10); padding.PaddingBottom = UDim.new(0, 11); padding.Parent = wrap
            local head = Instance.new("Frame")
            head.Name = "SectionHeader"; head.Size = UDim2.new(1,0,0,40)
            head.BackgroundColor3 = Color3.fromRGB(24,24,30); head.BorderSizePixel = 0; head.LayoutOrder = 0; head.Parent = wrap
            corner(head, 8); stroke(head, Color3.fromRGB(52,52,60), 0.2, 1)
            do
                local tl = tostring(sectionTitle):lower()
                local cands = {}
                if sectionIcon then cands[#cands+1] = sectionIcon end
                if tl:find("dispon") or tl:find("available") or tl:find("rscripts") then
                    for _, n in ipairs({"layout-grid","library","layers","list"}) do cands[#cands+1] = n end
                else
                    for _, n in ipairs({"gamepad-2","gamepad","play","settings"}) do cands[#cands+1] = n end
                end
                local img = ""
                for _, n in ipairs(cands) do
                    local ok, r = pcall(icon, n)
                    if ok and type(r) == "string" and r ~= "" then img = r; break end
                end
                local ic = Instance.new("ImageLabel")
                ic.Name = "SectionIcon"; ic.BackgroundTransparency = 1; ic.Size = UDim2.new(0,22,0,22)
                ic.AnchorPoint = Vector2.new(0,.5); ic.Position = UDim2.new(0,12,.5,0)
                ic.Image = img; ic.ImageColor3 = T.silver; ic.Parent = head
            end
            local line = Instance.new("Frame")
            line.Name = "Divider"; line.Size = UDim2.new(0,2,0,22); line.AnchorPoint = Vector2.new(0,.5); line.Position = UDim2.new(0,44,.5,0)
            line.BackgroundColor3 = T.silver2; line.BorderSizePixel = 0; line.Parent = head; corner(line, 1)
            local secLabel = label(head, sectionTitle, 16, T.white, Enum.Font.GothamBold)
            secLabel.Position = UDim2.new(0,56,0,0); secLabel.Size = UDim2.new(1,-100,1,0)
            -- efeitos passivos no cabecalho da secao ESP (icone de olho + nome)
            if true then
                pcall(function()
                    local RS = game:GetService("RunService")
                    local WH = Color3.new(1,1,1)
                    local ic0 = head:FindFirstChild("SectionIcon")
                    local hst0 = head:FindFirstChildOfClass("UIStroke")
                    local sh = Instance.new("Frame"); sh.Name = "EspShimmer"; sh.Size = UDim2.new(1,0,1,0)
                    sh.BackgroundColor3 = WH; sh.BorderSizePixel = 0; sh.Parent = head; corner(sh, 8)
                    local sg = Instance.new("UIGradient"); sg.Rotation = 20
                    sg.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.38,1),NumberSequenceKeypoint.new(.5,.86),NumberSequenceKeypoint.new(.62,1),NumberSequenceKeypoint.new(1,1)})
                    sg.Parent = sh
                    local lg = Instance.new("UIGradient")
                    lg.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(150,150,162)),ColorSequenceKeypoint.new(.5,WH),ColorSequenceKeypoint.new(1,Color3.fromRGB(150,150,162))})
                    lg.Parent = secLabel
                    local t0 = os.clock(); local conn
                    conn = RS.Heartbeat:Connect(function()
                        if not head.Parent then conn:Disconnect(); return end
                        if not page.Visible then return end
                        local t = os.clock() - t0
                        local b = (math.sin(t * 2.2) + 1) / 2
                        sg.Offset = Vector2.new(-1.2 + ((t % 3.4) / 3.4) * 2.4, 0)
                        lg.Offset = Vector2.new(-1 + ((t % 4) / 4) * 2, 0)
                        if ic0 then
                            local s = 22
                            local ph = t % 4.5; local y = 1
                            if ph < 0.2 then y = 1 - math.sin(ph / 0.2 * math.pi) * 0.85 end
                            ic0.Size = UDim2.new(0, s, 0, s * y)
                            ic0.ImageColor3 = T.silver:Lerp(WH, b)
                        end
                        if hst0 then hst0.Color = Color3.fromRGB(52,52,60):Lerp(WH, b * 0.75) end
                        line.BackgroundColor3 = T.silver2:Lerp(WH, b)
                    end)
                end)
            end
            local items = Instance.new("Frame")
            items.Name = "Items"; items.Size = UDim2.new(1,0,0,0); items.AutomaticSize = Enum.AutomaticSize.Y
            items.BackgroundTransparency = 1; items.LayoutOrder = 1; items.Parent = wrap
            local itemsLayout = Instance.new("UIListLayout")
            itemsLayout.Padding = UDim.new(0, 7); itemsLayout.SortOrder = Enum.SortOrder.LayoutOrder; itemsLayout.Parent = items
            -- seta para minimizar/expandir a secao (com animacao)
            do
                local open, busy = true, false
                local arrowBtn = button(head, "CollapseSection", UDim2.new(0,26,0,26), UDim2.new(1,-34,.5,-13), T.panel)
                arrowBtn.ZIndex = 5; corner(arrowBtn, 7); stroke(arrowBtn, T.border, 0, 1)
                local arrowImg = Instance.new("ImageLabel")
                arrowImg.Size = UDim2.new(0,14,0,14); arrowImg.AnchorPoint = Vector2.new(.5,.5); arrowImg.Position = UDim2.new(.5,0,.5,0)
                arrowImg.BackgroundTransparency = 1; arrowImg.ImageColor3 = T.silver; arrowImg.ZIndex = 6
                arrowImg.Image = icon("chevron-down"); arrowImg.Parent = arrowBtn
                if arrowImg.Image == "" then
                    arrowImg.Visible = false; arrowBtn.Text = "v"; arrowBtn.Font = Enum.Font.GothamBold; arrowBtn.TextSize = 14; arrowBtn.TextColor3 = T.silver
                end
                local ti = TweenInfo.new(.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                do local _sv = _G.__OrionSecGet(sectionTitle); if _sv ~= nil then startClosed = (_sv == false) end end
                if startClosed then
                    open = false
                    arrowImg.Rotation = -90
                    items.AutomaticSize = Enum.AutomaticSize.None
                    items.ClipsDescendants = true
                    items.Size = UDim2.new(1,0,0,0)
                    items.Visible = false
                end
                bindTap(arrowBtn, function()
                    if busy then return end
                    busy = true; open = not open
                    pcall(_G.__OrionSecSet, sectionTitle, open)
                    TweenService:Create(arrowImg, ti, {Rotation = open and 0 or -90}):Play()
                    if not open then
                        local h = itemsLayout.AbsoluteContentSize.Y
                        items.AutomaticSize = Enum.AutomaticSize.None
                        items.ClipsDescendants = true
                        items.Size = UDim2.new(1,0,0,h)
                        local tw = TweenService:Create(items, ti, {Size = UDim2.new(1,0,0,0)})
                        tw.Completed:Connect(function() if not open then items.Visible = false end busy = false end)
                        tw:Play()
                    else
                        items.Visible = true
                        items.ClipsDescendants = true
                        items.Size = UDim2.new(1,0,0,0)
                        local tw = TweenService:Create(items, ti, {Size = UDim2.new(1,0,0,itemsLayout.AbsoluteContentSize.Y)})
                        tw.Completed:Connect(function()
                            items.AutomaticSize = Enum.AutomaticSize.Y
                            items.Size = UDim2.new(1,0,0,0)
                            items.ClipsDescendants = false
                            busy = false
                        end)
                        tw:Play()
                    end
                end)
            end
            local seq = 0
            local function order(obj) seq = seq + 1; obj.LayoutOrder = seq end

            function section:SetTitle(t) pcall(function() secLabel.Text = tostring(t) end) end
            function section:AddSearch(sc)
                sc = sc or {}
                local row = Instance.new("Frame")
                row.Name = "SearchRow"; row.Size = UDim2.new(1,0,0,44); row.BackgroundColor3 = T.panel; row.BorderSizePixel = 0; row.Parent = items; order(row)
                corner(row, 7); local st = stroke(row, T.border, .1, 1)
                local img = ""
                for _, n in ipairs({"search","magnifying-glass","scan-search"}) do
                    local ok, r = pcall(icon, n)
                    if ok and type(r) == "string" and r ~= "" then img = r; break end
                end
                if img ~= "" then
                    local ic = Instance.new("ImageLabel")
                    ic.Name = "SearchIcon"; ic.BackgroundTransparency = 1; ic.Size = UDim2.new(0,22,0,22)
                    ic.AnchorPoint = Vector2.new(0,.5); ic.Position = UDim2.new(0,10,.5,0); ic.Image = img; ic.ImageColor3 = T.silver; ic.Parent = row
                else
                    local ic = label(row, "🔍", 14, T.silver, Enum.Font.Gotham)
                    ic.Name = "SearchIcon"; ic.Position = UDim2.new(0,10,0,0); ic.Size = UDim2.new(0,20,1,0)
                end
                local box = Instance.new("TextBox")
                box.Name = "SearchBox"; box.Size = UDim2.new(1,-48,1,0); box.Position = UDim2.new(0,40,0,0); box.BackgroundTransparency = 1
                box.ClearTextOnFocus = false; box.Text = ""; box.PlaceholderText = sc.Placeholder or "Pesquisar scripts específicos"
                box.PlaceholderColor3 = T.muted; box.TextColor3 = T.white; box.Font = Enum.Font.Gotham; box.TextSize = 15
                box.TextXAlignment = Enum.TextXAlignment.Left; box.Parent = row
                box.Focused:Connect(function() st.Color = T.silver2 end)
                box.FocusLost:Connect(function() st.Color = T.border end)
                local function apply()
                    local q = (box.Text or ""):lower():match("^%s*(.-)%s*$") or ""
                    for _, ch in ipairs(items:GetChildren()) do
                        if ch.Name == "ScriptCard" then
                            local hay = ch:GetAttribute("SearchText") or ""
                            ch.Visible = (q == "") or (hay:find(q, 1, true) ~= nil)
                        end
                    end
                end
                box:GetPropertyChangedSignal("Text"):Connect(apply)
                items.ChildAdded:Connect(function(ch) if ch.Name == "ScriptCard" then task.defer(apply) end end)
                return {Set=function(_,v) box.Text = tostring(v) end, Get=function() return box.Text end}
            end

            function section:AddButton(bc)
                bc = bc or {}
                local text = bc.Title or "Executar"
                local image = bc.Image
                local isCard = (type(image) == "string" and image ~= "") or bc.Card == true
                local callback = bc.SubCallback or bc.Callback or function() end
                local row = Instance.new("Frame")
                row.Name = isCard and "ScriptCard" or "ActionRow"
                pcall(function() row:SetAttribute("SearchText", (tostring(text).." "..tostring(bc.GameTitle or "")):lower()) end)
                row.Size = UDim2.new(1,0,0,isCard and 120 or 44)
                row.BackgroundColor3 = T.panel; row.BorderSizePixel = 0; row.Parent = items; order(row)
                corner(row, isCard and 9 or 7)
                local rowStroke = stroke(row, T.border, .1, 1)

                if isCard then
                    row.ClipsDescendants = true
                    local thumbBack = Instance.new("Frame")
                    thumbBack.Name = "ThumbContainer"
                    local thW, thH = (compact and 112 or 150), (compact and 63 or 84)
                    thumbBack.Size = UDim2.new(0,thW,0,thH); thumbBack.Position = UDim2.new(0,6,.5,-thH/2)
                    thumbBack.BackgroundColor3 = Color3.fromRGB(29,29,35); thumbBack.BorderSizePixel = 0; thumbBack.ZIndex = 2; thumbBack.Parent = row
                    corner(thumbBack, 8); stroke(thumbBack, T.border, .15, 1)
                    local thumb = Instance.new("ImageLabel")
                    thumb.Name = "ScriptThumbnail"; thumb.Size = UDim2.new(1,-2,1,-2); thumb.Position = UDim2.new(0,1,0,1)
                    thumb.BackgroundTransparency = 1; thumb.ScaleType = Enum.ScaleType.Fit; thumb.ZIndex = 3; thumb.Parent = thumbBack; corner(thumb, 7)
                    local fallbackImg = (type(bc.FallbackImage) == "string" and bc.FallbackImage) or ""
                    local function showFallback()
                        if fallbackImg ~= "" then
                            thumb.Image = fallbackImg; thumb.ImageColor3 = Color3.new(1, 1, 1)
                        else
                            thumb.Image = icon("gamepad-2"); thumb.ImageColor3 = T.silver2
                        end
                    end
                    showFallback() -- mostra algo imediatamente enquanto a imagem real baixa
                    if type(image) == "string" and image ~= "" then
                        resolveImage(image, function(r)
                            if thumb and thumb.Parent and r and r ~= "" then
                                thumb.Image = r; thumb.ImageColor3 = Color3.new(1, 1, 1)
                            end
                        end)
                    end
                    noSink(thumbBack)
                    local textX = compact and 128 or 166
                    local titleLabel = label(row, text, 12, T.white, Enum.Font.GothamBold)
                    -- descricao: so o inicio, sem quebras de linha
                    local descText = ""
                    if type(bc.Description) == "string" then
                        -- respeita as quebras de linha; so limpa espacos e linhas em branco repetidas
                        local d = bc.Description
                        d = d:gsub("\r\n", "\n")
                        d = d:gsub("\r", "\n")
                        d = d:gsub("[ \t]+", " ")
                        d = d:gsub(" ?\n ?", "\n")
                        d = d:gsub("\n\n+", "\n")
                        descText = d:match("^%s*(.-)%s*$") or ""
                        pcall(function()
                            local cut = utf8.offset(descText, 321)
                            if cut then descText = descText:sub(1, cut - 1) end
                        end)
                    end
                    local hasDesc = descText ~= ""
                    -- titulo + descricao num bloco so: a descricao cola logo abaixo do titulo
                    local textBlock = Instance.new("Frame")
                    textBlock.Name = "TextBlock"; textBlock.BackgroundTransparency = 1
                    textBlock.Position = UDim2.new(0,textX,0,10); textBlock.Size = UDim2.new(1,-(textX+10),0,0)
                    textBlock.AutomaticSize = Enum.AutomaticSize.Y; textBlock.ZIndex = 2; textBlock.Parent = row
                    local blockLayout = Instance.new("UIListLayout")
                    blockLayout.Padding = UDim.new(0,1); blockLayout.SortOrder = Enum.SortOrder.LayoutOrder; blockLayout.Parent = textBlock
                    titleLabel.Parent = textBlock; titleLabel.LayoutOrder = 1
                    titleLabel.Position = UDim2.new(); titleLabel.Size = UDim2.new(1,0,0,0)
                    titleLabel.AutomaticSize = Enum.AutomaticSize.Y
                    titleLabel.TextWrapped = true; titleLabel.TextYAlignment = Enum.TextYAlignment.Top
                    titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
                    titleLabel.ZIndex = 2
                    local titleMax = Instance.new("UISizeConstraint")
                    titleMax.MaxSize = Vector2.new(math.huge, hasDesc and 30 or 46); titleMax.Parent = titleLabel
                    if hasDesc then
                        local descLabel = label(row, descText, 10, Color3.fromRGB(128,128,141), Enum.Font.Gotham)
                        descLabel.Name = "Description"
                        descLabel.Parent = textBlock; descLabel.LayoutOrder = 2
                        descLabel.Position = UDim2.new(); descLabel.Size = UDim2.new(1,0,0,37)
                        -- a descricao vai ate colar nos botoes (y=78) e o degrade termina ali
                        local function fitDesc()
                            local h = math.max(14, 67 - titleLabel.AbsoluteSize.Y)
                            descLabel.Size = UDim2.new(1,0,0,h)
                        end
                        titleLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitDesc)
                        task.defer(fitDesc)
                        descLabel.TextTruncate = Enum.TextTruncate.AtEnd
                        descLabel.TextWrapped = true; descLabel.TextYAlignment = Enum.TextYAlignment.Top
                        descLabel.ZIndex = 2
                        -- degrade: o texto vai sumindo de cima para baixo
                        local fade = Instance.new("UIGradient")
                        fade.Rotation = 90
                        fade.Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0.1),
                            NumberSequenceKeypoint.new(0.6, 0.2),
                            NumberSequenceKeypoint.new(0.85, 0.65),
                            NumberSequenceKeypoint.new(1, 1),
                        })
                        fade.Parent = descLabel
                    end
                    noSink(textBlock) -- titulo/descricao nunca bloqueiam os botoes
                    if bc.Tag and bc.Tag ~= "" then
                        local badge = Instance.new("Frame")
                        badge.Size = UDim2.new(0,65,0,17); badge.Position = UDim2.new(0,textX,0,56)
                        badge.BackgroundColor3 = Color3.fromRGB(28,28,34); badge.BorderSizePixel = 0; badge.ZIndex = 2; badge.Parent = row
                        corner(badge, 9); stroke(badge,T.border,.2,1)
                        local badgeText = label(badge, bc.Tag, 8, T.muted, Enum.Font.GothamBold)
                        badgeText.Size = UDim2.new(1,0,1,0); badgeText.TextXAlignment = Enum.TextXAlignment.Center
                        badgeText.ZIndex = 3
                    end
                    -- botoes com icone + nome (Chave / Copiar / Executar)
                    local runLabel  = bc.RunText  or "Executar"
                    local copyLabel = bc.CopyText or "Copiar"
                    local keyLabel  = bc.KeyText  or "Chave"
                    local WHITE = Color3.fromRGB(255,255,255)
                    local GREEN = Color3.fromRGB(46,204,113)
                    local RED   = Color3.fromRGB(225,82,82)
                    local GOLD  = Color3.fromRGB(255,196,70)

                    local onPress = bindTap

                    -- circulo de selecao (auto execute daquele jogo)
                    local selObj
                    if bc.Selectable == true and type(bc.OnSelect) == "function" then
                        textBlock.Size = UDim2.new(1,-(textX+40),0,0)
                        local selected = bc.Selected == true
                        local circ = button(row, "SelectCircle", UDim2.new(0,22,0,22), UDim2.new(1,-8,0,8), T.field)
                        circ.AnchorPoint = Vector2.new(1,0); circ.ZIndex = 14; corner(circ, 11)
                        local cStroke = stroke(circ, T.silver2, 0, 1.5)
                        local fill = Instance.new("ImageLabel")
                        fill.AnchorPoint = Vector2.new(.5,.5); fill.Position = UDim2.new(.5,0,.5,0)
                        fill.Size = UDim2.new(0,0,0,0); fill.BackgroundTransparency = 1
                        local _ck = icon("circle-check"); if _ck == "" then _ck = icon("check") end
                        fill.Image = _ck; fill.ImageColor3 = T.white; fill.ImageTransparency = 1
                        fill.ZIndex = 15; fill.Parent = circ
                        local function paint(v, anim)
                            local ti = TweenInfo.new(anim and .22 or 0, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                            TweenService:Create(fill, ti, {Size = v and UDim2.new(0,16,0,16) or UDim2.new(0,0,0,0), ImageTransparency = v and 0 or 1}):Play()
                            TweenService:Create(cStroke, ti, {Color = v and T.white or T.silver2}):Play()
                            TweenService:Create(circ, ti, {BackgroundColor3 = v and Color3.fromRGB(52,52,60) or T.field}):Play()
                        end
                        paint(selected, false)
                        onPress(circ, function()
                            selected = not selected
                            paint(selected, true)
                            pcall(bc.OnSelect, selected)
                        end)
                        selObj = function(v) selected = v and true or false; paint(selected, true) end
                    end

                    -- barra com layout horizontal: os botoes nunca se sobrepoem, em qualquer tela
                    local btnBar = Instance.new("Frame")
                    btnBar.Name = "ButtonBar"; btnBar.BackgroundTransparency = 1; btnBar.BorderSizePixel = 0
                    btnBar.Position = UDim2.new(0,textX,0,79); btnBar.Size = UDim2.new(1,-(textX+6),0,34)
                    btnBar.ZIndex = 10; btnBar.Parent = row
                    local barLayout = Instance.new("UIListLayout")
                    barLayout.FillDirection = Enum.FillDirection.Horizontal
                    barLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
                    barLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                    barLayout.Padding = UDim.new(0,6); barLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    barLayout.Parent = btnBar
                    local keyW, copyW, runW = (compact and 66 or 84), (compact and 80 or 88), (compact and 88 or 96)

                    local function makeActionButton(name, width, order, bg, iconName, glyph, text, color)
                        local nB = 2
                        local btn = button(btnBar, name, UDim2.new(1/nB, -math.ceil(6*(nB-1)/nB), 0, 34), UDim2.new(), bg)
                        local szc = Instance.new("UISizeConstraint"); szc.MaxSize = Vector2.new(170, 34); szc.Parent = btn
                        btn.LayoutOrder = order; btn.ZIndex = 12; btn.Active = true
                        corner(btn,7)
                        local img = icon(iconName)
                        local ic, lbl
                        if img ~= "" then
                            ic = Instance.new("ImageLabel")
                            ic.Size = UDim2.new(0,14,0,14); ic.Position = UDim2.new(0,10,.5,-7)
                            ic.BackgroundTransparency = 1; ic.Image = img; ic.ImageColor3 = color; ic.ZIndex = 13; ic.Parent = btn
                            lbl = label(btn, text, 11, color, Enum.Font.GothamBold)
                            lbl.Position = UDim2.new(0,30,0,0); lbl.Size = UDim2.new(1,-36,1,0)
                        else
                            lbl = label(btn, text, 11, color, Enum.Font.GothamBold)
                            lbl.Position = UDim2.new(0,6,0,0); lbl.Size = UDim2.new(1,-12,1,0)
                            lbl.TextXAlignment = Enum.TextXAlignment.Center
                        end
                        lbl.ZIndex = 13
                        lbl.TextScaled = true
                        local tsc = Instance.new("UITextSizeConstraint"); tsc.MaxTextSize = 11; tsc.MinTextSize = 6; tsc.Parent = lbl
                        if ic then noSink(ic) end
                        noSink(lbl)
                        -- muda cor de fundo / cor do conteudo / texto
                        local function apply(newBg, newFg, newText)
                            TweenService:Create(btn, TweenInfo.new(.15), {BackgroundColor3 = newBg}):Play()
                            lbl.TextColor3 = newFg
                            if ic then ic.ImageColor3 = newFg end
                            lbl.Text = newText
                        end
                        return btn, apply
                    end

                    -- icone de CHAVE no canto inferior direito da miniatura (so quando o script usa key)
                    if bc.HasKey == true then
                        local keyBadge = button(thumbBack, "KeyBadge", UDim2.new(0,24,0,24), UDim2.new(1,-8,1,-7), Color3.fromRGB(255,208,60))
                        keyBadge.AnchorPoint = Vector2.new(1, 1); keyBadge.ZIndex = 8
                        corner(keyBadge, 12)
                        local keyIc = Instance.new("ImageLabel")
                        keyIc.BackgroundTransparency = 1; keyIc.Image = icon("key"); keyIc.ImageColor3 = T.darkText
                        keyIc.AnchorPoint = Vector2.new(.5, .5); keyIc.Position = UDim2.new(.5, 0, .5, 0)
                        keyIc.Size = UDim2.new(0, 15, 0, 15); keyIc.ZIndex = 9; keyIc.Parent = keyBadge
                        onPress(keyBadge, function()
                            if bc.KeyCallback then pcall(bc.KeyCallback) end
                        end)
                    end

                    local copyBtn, applyCopy = makeActionButton("Copy", copyW, 2, T.field, "copy", "\240\159\147\139", copyLabel, T.silver)
                    local copyStroke = stroke(copyBtn, T.border, 0, 1)
                    local runBtn, applyRun = makeActionButton("Execute", runW, 3, Color3.new(1,1,1), "play", "\226\150\182", runLabel, T.darkText)
                    local runGradient = Instance.new("UIGradient")
                    runGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(.5,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,255))})
                    runGradient.Rotation=35; runGradient.Parent=runBtn
                    -- brilho branco passando (igual aos botoes da extensao Orion), respeita as bordas arredondadas
                    do
                        local sweep = Instance.new("Frame")
                        sweep.Name = "Sweep"; sweep.Size = UDim2.new(1,0,1,0)
                        sweep.BackgroundColor3 = Color3.new(1,1,1); sweep.BorderSizePixel = 0
                        sweep.ZIndex = 12; sweep.Active = false; sweep.Visible = false; sweep.Parent = runBtn
                        corner(sweep, 7)
                        local sweepG = Instance.new("UIGradient")
                        sweepG.Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(.35,1),
                            NumberSequenceKeypoint.new(.5,.3), NumberSequenceKeypoint.new(.65,1), NumberSequenceKeypoint.new(1,1)
                        })
                        sweepG.Rotation = 20; sweepG.Offset = Vector2.new(-1,0); sweepG.Parent = sweep
                        local sweeping = false
                        local function playSweep(dur)
                            if sweeping or not runBtn.Parent or not runGradient.Enabled then return end
                            sweeping = true
                            sweepG.Offset = Vector2.new(-1,0); sweep.Visible = true
                            local tw = TweenService:Create(sweepG, TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Offset = Vector2.new(1,0)})
                            tw.Completed:Connect(function() sweeping = false; sweep.Visible = false end)
                            tw:Play()
                        end
                        task.spawn(function()
                            task.wait(1)
                            while runBtn.Parent do
                                playSweep(.9)
                                task.wait(6)
                            end
                        end)
                        runBtn.MouseEnter:Connect(function() playSweep(.6) end)
                    end

                    local copyToken = 0
                    local function doCopy()
                        local copied = false
                        if bc.CopyCallback then
                            local okc, res = pcall(bc.CopyCallback)
                            copied = okc and res ~= false
                        else
                            local content = bc.CopyContent
                            if not content then
                                if bc.ScriptUrl and bc.ScriptUrl ~= "" then
                                    content = 'loadstring(game:HttpGet("'..tostring(bc.ScriptUrl)..'"))()'
                                else
                                    content = text
                                end
                            end
                            copied = copyText(content)
                        end
                        copyToken = copyToken + 1
                        local my = copyToken
                        if copied then
                            copyStroke.Color = WHITE
                            applyCopy(WHITE, T.darkText, bc.CopiedText or "Copiado")   -- fica branco
                        else
                            applyCopy(RED, WHITE, bc.ErrorText or "Erro")
                        end
                        task.delay(1.6, function()
                            if my == copyToken and copyBtn.Parent then
                                copyStroke.Color = T.border
                                applyCopy(T.field, T.silver, copyLabel)
                            end
                        end)
                    end
                    onPress(copyBtn, doCopy)

                    local runToken = 0
                    local function doExec()
                        runToken = runToken + 1
                        local my = runToken
                        task.spawn(function()
                            local okCb, res = pcall(callback)
                            local success = okCb and res ~= false
                            if not okCb then warn("[Orion Lib] Erro no callback: " .. tostring(res)) end
                            if my ~= runToken or not runBtn.Parent then return end
                            runGradient.Enabled = false -- senao o degrade mistura com a cor
                            if success then
                                applyRun(GREEN, T.darkText, bc.ExecutedText or "Executado") -- sucesso: fica verde
                            else
                                applyRun(RED, WHITE, bc.ExecutedText or "Executado") -- erro: fica vermelho
                            end
                            task.delay(1.8, function()
                                if my == runToken and runBtn.Parent then
                                    runGradient.Enabled = true
                                    applyRun(Color3.new(1,1,1), T.darkText, runLabel)
                                end
                            end)
                        end)
                    end
                    onPress(runBtn, doExec)
                    row.MouseEnter:Connect(function()
                        TweenService:Create(row,TweenInfo.new(.15),{BackgroundColor3=T.panelHover}):Play()
                        TweenService:Create(rowStroke,TweenInfo.new(.15),{Color=T.silver2,Transparency=.05}):Play()
                    end)
                    row.MouseLeave:Connect(function()
                        TweenService:Create(row,TweenInfo.new(.15),{BackgroundColor3=T.panel}):Play()
                        TweenService:Create(rowStroke,TweenInfo.new(.15),{Color=T.border,Transparency=.1}):Play()
                    end)
                    return {SetSelected=function(_,v) if selObj then selObj(v) end end, SetTitle=function(_,v) titleLabel.Text=tostring(v) end, SetImage=function(_,v) resolveImage(v,function(r) if thumb and thumb.Parent and r ~= "" then thumb.Image=r; thumb.ImageColor3=Color3.new(1,1,1) end end) end}
                else
                    local txt = label(row,text,15,T.white,Enum.Font.GothamMedium)
                    txt.Position=UDim2.new(0,12,0,0); txt.Size=UDim2.new(1,-44,1,0); txt.TextTruncate=Enum.TextTruncate.AtEnd
                    local ico=Instance.new("ImageLabel")
                    ico.Size=UDim2.new(0,15,0,15); ico.AnchorPoint=Vector2.new(1,.5); ico.Position=UDim2.new(1,-12,.5,0)
                    ico.BackgroundTransparency=1; ico.Image=icon("chevron-right"); ico.ImageColor3=T.muted; ico.Parent=row
                    local hit=button(row,"HitArea",UDim2.new(1,0,1,0),UDim2.new(),Color3.new(0,0,0)); hit.BackgroundTransparency=1
                    bindTap(hit, function() callback() end)
                    row.MouseEnter:Connect(function() row.BackgroundColor3=T.panelHover; rowStroke.Color=T.silver2; ico.ImageColor3=T.white end)
                    row.MouseLeave:Connect(function() row.BackgroundColor3=T.panel; rowStroke.Color=T.border; ico.ImageColor3=T.muted end)
                    return {SetTitle=function(_,v) txt.Text=tostring(v) end}
                end
            end

            function section:AddToggle(tc)
                tc=tc or {}; local state=tc.Default==true; local callback=tc.Callback or function() end
                local row=Instance.new("Frame"); row.Size=UDim2.new(1,0,0,46); row.BackgroundColor3=T.panel; row.BorderSizePixel=0; row.Parent=items; order(row)
                corner(row,7); stroke(row,T.border,.1,1)
                local txt=label(row,tc.Title or "Toggle",15,T.white,Enum.Font.GothamMedium); txt.Position=UDim2.new(0,12,0,0); txt.Size=UDim2.new(1,-62,1,0)
                local subLbl
                if (tc.Subtitle or tc.SubTitle) ~= nil then
                    row.Size = UDim2.new(1,0,0,56)
                    txt.Position = UDim2.new(0,12,0,8); txt.Size = UDim2.new(1,-62,0,16)
                    subLbl = label(row, tostring(tc.Subtitle or tc.SubTitle), 10, T.muted, Enum.Font.Gotham)
                    subLbl.Position = UDim2.new(0,12,0,26); subLbl.Size = UDim2.new(1,-62,0,24)
                    subLbl.TextWrapped = true; subLbl.TextYAlignment = Enum.TextYAlignment.Top
                    subLbl.TextTruncate = Enum.TextTruncate.AtEnd
                end
                local track=Instance.new("Frame"); track.Size=UDim2.new(0,36,0,19); track.AnchorPoint=Vector2.new(1,.5); track.Position=UDim2.new(1,-12,.5,0)
                track.BackgroundColor3=state and T.silver or T.field; track.BorderSizePixel=0; track.Parent=row; corner(track,10); local trackStroke=stroke(track,T.border,0,1)
                local dot=Instance.new("Frame"); dot.Size=UDim2.new(0,13,0,13); dot.Position=state and UDim2.new(1,-16,.5,-6.5) or UDim2.new(0,3,.5,-6.5)
                dot.BackgroundColor3=state and T.darkText or T.silver; dot.BorderSizePixel=0; dot.Parent=track; corner(dot,8)
                local hit=button(row,"ToggleHit",UDim2.new(1,0,1,0),UDim2.new(),Color3.new()); hit.BackgroundTransparency=1
                local function set(v, fire) state=not not v; TweenService:Create(dot,TweenInfo.new(.15),{Position=state and UDim2.new(1,-16,.5,-6.5) or UDim2.new(0,3,.5,-6.5),BackgroundColor3=state and T.darkText or T.silver}):Play(); TweenService:Create(track,TweenInfo.new(.15),{BackgroundColor3=state and T.silver or T.field}):Play();  if fire~=false then pcall(callback,state) end end
                bindTap(hit, function() set(not state,true) end)
                                return {Set=function(_,v,fire) set(v,fire) end,GetValue=function() return state end,SetSubtitle=function(_,v) if subLbl then subLbl.Text=tostring(v) end end}
            end

            function section:AddLabel(c)
                c=c or {}; local txt=label(items,c.Text or c.Title or "",12,T.muted,Enum.Font.Gotham); txt.Size=UDim2.new(1,0,0,22); order(txt)
                return {Set=function(_,v) txt.Text=tostring(v) end}
            end
            function section:AddParagraph(c)
                c=c or {}; local box=Instance.new("Frame"); box.Size=UDim2.new(1,0,0,0); box.AutomaticSize=Enum.AutomaticSize.Y; box.BackgroundColor3=T.panel; box.BorderSizePixel=0; box.Parent=items; order(box); corner(box,8); stroke(box,T.border,.1,1)
                local pad=Instance.new("UIPadding"); pad.PaddingLeft=UDim.new(0,11); pad.PaddingRight=UDim.new(0,11); pad.PaddingTop=UDim.new(0,9); pad.PaddingBottom=UDim.new(0,9); pad.Parent=box
                local lay=Instance.new("UIListLayout"); lay.Padding=UDim.new(0,5); lay.Parent=box
                local h=label(box,c.Title or "",12,T.silver,Enum.Font.GothamBold); h.Size=UDim2.new(1,0,0,17)
                local body=label(box,c.Content or "",11,T.muted); body.Size=UDim2.new(1,0,0,0); body.AutomaticSize=Enum.AutomaticSize.Y; body.TextWrapped=true; body.TextYAlignment=Enum.TextYAlignment.Top
                return {SetContent=function(_,v) body.Text=tostring(v) end,SetTitle=function(_,v) h.Text=tostring(v) end}
            end
            function section:AddDivider()
                local d=Instance.new("Frame"); d.Size=UDim2.new(1,0,0,1); d.BackgroundColor3=T.border; d.BorderSizePixel=0; d.Parent=items; order(d); return d
            end

            -- Pre-visualizacao do ESP (premium): espelha o seu personagem ao vivo
            function section:AddESPPreview(pc)
                pc = pc or {}; local get = pc.Get or function() return {} end
                local K = pc.Compact == true; local LP = Players.LocalPlayer; local RS = game:GetService("RunService")
                local frame = Instance.new("Frame"); frame.Size = pc.Size or UDim2.new(1,0,0,340); frame.BackgroundColor3 = Color3.fromRGB(10,10,12)
                frame.BorderSizePixel = 0; frame.ClipsDescendants = true; frame.Parent = pc.Parent or items; if not pc.Parent then order(frame) end; if pc.Position then frame.Position = pc.Position end; corner(frame,10)
                local fs = stroke(frame, Color3.fromRGB(70,70,90), .2, 1)
                -- fundo com gradiente animado
                local bgG = Instance.new("UIGradient"); bgG.Rotation = 90
                bgG.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(18,18,21)),ColorSequenceKeypoint.new(.55,Color3.fromRGB(26,26,31)),ColorSequenceKeypoint.new(1,Color3.fromRGB(8,8,10))})
                bgG.Parent = frame
                local ov0 = Instance.new("Frame"); ov0.Size = UDim2.new(1,0,1,0); ov0.BackgroundTransparency = 1; ov0.ZIndex = 1; ov0.Parent = frame
                local vp = Instance.new("ViewportFrame"); vp.Size = UDim2.new(1,0,1,0); vp.BackgroundTransparency = 1; vp.BorderSizePixel = 0
                vp.ZIndex = 3; vp.Ambient = Color3.fromRGB(150,150,170); vp.LightColor = Color3.new(1,1,1); vp.LightDirection = Vector3.new(-.4,-.6,.8); vp.Parent = frame
                local cam = Instance.new("Camera"); cam.FieldOfView = 50; cam.Parent = vp; vp.CurrentCamera = cam
                local ov = Instance.new("Frame"); ov.Size = UDim2.new(1,0,1,0); ov.BackgroundTransparency = 1; ov.ZIndex = 5; ov.Parent = frame
                local function mk(cls, z, par) local f = Instance.new(cls); f.BorderSizePixel = 0; f.ZIndex = z or 6; f.Parent = par or ov; return f end
                local function round(f) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1,0); c.Parent = f end

                -- personagem clonado + pares (real -> clone) para espelhar movimento
                local camD = 10
                local shellModel, shells, hlInst = nil, {}, nil
                local model, pairsL, body, parts, orig, hrpR, cf, sz, feetY = nil, {}, {}, {}, {}, nil, CFrame.new(), Vector3.new(4,6,1), -3
                local function build()
                    if model then pcall(function() model:Destroy() end) end
                    model = nil; pairsL, body, parts, orig, shells = {}, {}, {}, {}, {}
                    local ch = LP.Character; hrpR = ch and ch:FindFirstChild("HumanoidRootPart")
                    pcall(function() local a = ch.Archivable; ch.Archivable = true; model = ch:Clone(); ch.Archivable = a end)
                    if not model then pcall(function() model = Players:CreateHumanoidModelFromUserId(LP.UserId) end) end
                    if not model then return end
                    if ch and model.Name == ch.Name then
                        local rl, cl = {}, {}
                        for _, d in ipairs(ch:GetDescendants()) do if d:IsA("BasePart") then rl[#rl+1] = d end end
                        for _, d in ipairs(model:GetDescendants()) do if d:IsA("BasePart") then cl[#cl+1] = d end end
                        if #rl == #cl then for i = 1, #rl do pairsL[#pairsL+1] = {rl[i], cl[i]} end end
                    end
                    for _, d in ipairs(model:GetDescendants()) do
                        if d:IsA("BaseScript") or d:IsA("Highlight") or d:IsA("Sound") or d:IsA("ForceField") then pcall(function() d:Destroy() end) end
                    end
                    for _, d in ipairs(model:GetDescendants()) do
                        if d:IsA("BasePart") then d.Anchored = true; d.CanCollide = false; parts[#parts+1] = d; orig[d] = d.Color; if d.Parent == model then body[#body+1] = d end end
                    end
                    pcall(function() local hm = model:FindFirstChildOfClass("Humanoid"); if hm then hm.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None; hm.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff end end)
                    local h = model:FindFirstChild("HumanoidRootPart")
                    if h then model.PrimaryPart = h; model:PivotTo(CFrame.new(0,0,0)) end
                    model.Parent = vp
                    if shellModel then pcall(function() shellModel:Destroy() end) end
                    shellModel = Instance.new("Model"); shellModel.Name = "Outline"
                    for _, p in ipairs(body) do
                        if false then
                            local sh; pcall(function() sh = p:Clone() end)
                            if sh then
                                for _, c in ipairs(sh:GetChildren()) do if not c:IsA("SpecialMesh") then pcall(function() c:Destroy() end) end end
                                pcall(function() sh.TextureID = "" end)
                                sh.Anchored = true; sh.CanCollide = false; sh.Material = Enum.Material.Neon; sh.CastShadow = false
                                sh.Size = p.Size + Vector3.new(.16,.16,.16); sh.Transparency = 1; sh.Parent = shellModel; shells[#shells+1] = {p, sh}
                            end
                        end
                    end
                    shellModel.Parent = vp
                    pcall(function() hlInst = Instance.new("Highlight"); hlInst.Adornee = model; hlInst.FillTransparency = 1; hlInst.OutlineTransparency = 1
                        hlInst.DepthMode = Enum.HighlightDepthMode.Occluded; hlInst.Parent = model end)
                    pcall(function() cf, sz = model:GetBoundingBox() end)
                    feetY = cf.Position.Y - sz.Y/2
                    local d = (sz.Y/2)/math.tan(math.rad(cam.FieldOfView/2))*1.6; camD = d
                    cam.CFrame = CFrame.lookAt(Vector3.new(0, cf.Position.Y, -d), Vector3.new(0, cf.Position.Y, 0))
                end
                local Lighting = game:GetService("Lighting")
                local sceneModel, sceneOrigin, lastScene = nil, Vector3.zero, 0
                local function buildScene()
                    if sceneModel then pcall(function() sceneModel:Destroy() end) end
                    sceneModel = Instance.new("Model"); sceneModel.Name = "Scene"; lastScene = tick()
                    local hrp = hrpR
                    if hrp and hrp.Parent then
                        sceneOrigin = hrp.Position
                        local ok, found = false, nil
                        local n = 0
                        if ok and found then
                            pcall(function() table.sort(found, function(x, y) return (x.Position - hrp.Position).Magnitude < (y.Position - hrp.Position).Magnitude end) end)
                            for _, p in ipairs(found) do
                                if n >= 800 then break end
                                if p:IsA("BasePart") and p.ClassName ~= "Terrain" and p.Transparency < .95 and ((p.Position - hrp.Position).Magnitude <= 45 or p.Size.Magnitude > 6) then
                                    local isChar = false; local m = p:FindFirstAncestorWhichIsA("Model")
                                    while m do if m:FindFirstChildOfClass("Humanoid") then isChar = true; break end; m = m:FindFirstAncestorWhichIsA("Model") end
                                    if not isChar then
                                        local c; pcall(function() c = p:Clone() end)
                                        if c then
                                            for _, ch in ipairs(c:GetChildren()) do
                                                if not (ch:IsA("DataModelMesh") or ch:IsA("Decal") or ch:IsA("Texture") or ch:IsA("SurfaceAppearance")) then pcall(function() ch:Destroy() end) end
                                            end
                                            c.Anchored = true; c.CanCollide = false; c.CFrame = p.CFrame - sceneOrigin; c.Parent = sceneModel; n = n + 1
                                        end
                                    end
                                end
                            end
                        end
                    end
                    sceneModel.Parent = vp
                    pcall(function()
                        vp.Ambient = Lighting.Ambient:Lerp(Color3.new(1,1,1), .4); vp.LightColor = Color3.new(1,1,1); vp.LightDirection = -Lighting:GetSunDirection()
                    end)
                end
                build(); buildScene()
                LP.CharacterAdded:Connect(function() task.wait(1); pcall(build); pcall(buildScene) end)

                local function proj(p, W, H)
                    local r = cam.CFrame:PointToObjectSpace(p); local dp = -r.Z; if dp < .1 then dp = .1 end
                    local t = math.tan(math.rad(cam.FieldOfView/2))
                    return Vector2.new((.5 + r.X/(dp*t*(W/H))/2)*W, (.5 - r.Y/(dp*t)/2)*H)
                end

                -- decoracao premium: plataforma, particulas, scanline, cantos, badge
                local plat1 = mk("Frame", 6); plat1.BackgroundTransparency = 1; plat1.AnchorPoint = Vector2.new(.5,.5); round(plat1)
                local pS1 = Instance.new("UIStroke"); pS1.Thickness = 2; pS1.Parent = plat1
                local plat2 = mk("Frame", 6); plat2.BackgroundTransparency = 1; plat2.AnchorPoint = Vector2.new(.5,.5); round(plat2)
                local pS2 = Instance.new("UIStroke"); pS2.Thickness = 1; pS2.Parent = plat2
                local platGlow = mk("Frame", 2, ov0); platGlow.AnchorPoint = Vector2.new(.5,.5); round(platGlow); platGlow.BackgroundTransparency = .85
                plat1.Visible = false; plat2.Visible = false; platGlow.Visible = false
                local parts2 = {}
                for i = 1, 16 do
                    local f = mk("Frame", 2, ov0); local s = math.random(2,4); f.Size = UDim2.new(0,s,0,s); round(f)
                    parts2[i] = {f = f, x = math.random(), y = math.random(), sp = .03 + math.random()*.06, ph = math.random()*6}
                end
                local scan = mk("Frame", 4, ov0); scan.Size = UDim2.new(1,0,0,36); scan.BackgroundColor3 = Color3.new(1,1,1)
                local scG = Instance.new("UIGradient"); scG.Rotation = 90
                scG.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.5,.93),NumberSequenceKeypoint.new(1,1)}); scG.Parent = scan
                local brk = {}
                for i = 1, 4 do
                    local rx, ry = (i == 2 or i == 4) and 1 or 0, (i >= 3) and 1 or 0
                    for k = 1, 2 do
                        local b = mk("Frame", 7); b.AnchorPoint = Vector2.new(rx, ry)
                        b.Size = k == 1 and UDim2.new(0,16,0,2) or UDim2.new(0,2,0,16)
                        b.Position = UDim2.new(rx, rx == 1 and -(K and 4 or 8) or (K and 4 or 8), ry, ry == 1 and -(K and 4 or 8) or (K and 4 or 8)); brk[#brk+1] = b
                    end
                end
                local cap = label(ov, K and "PREVIEW" or "PRÉ-VISUALIZAÇÃO", K and 9 or 10, T.muted, Enum.Font.GothamBold); cap.Position = K and UDim2.new(0,8,0,6) or UDim2.new(0,22,0,16); cap.Size = UDim2.new(0,160,0,14); cap.ZIndex = 8
                local badge = mk("Frame", 8); badge.AnchorPoint = Vector2.new(1,0); badge.Position = K and UDim2.new(1,-6,0,5) or UDim2.new(1,-20,0,14); badge.Size = K and UDim2.new(0,46,0,16) or UDim2.new(0,74,0,20)
                badge.BackgroundColor3 = Color3.fromRGB(20,20,28); round(badge)
                badge.Visible = false; local bS = Instance.new("UIStroke"); bS.Thickness = 1; bS.Parent = badge
                local dot = mk("Frame", 9, badge); dot.Size = UDim2.new(0,7,0,7); dot.AnchorPoint = Vector2.new(0,.5); dot.Position = UDim2.new(0,K and 6 or 9,.5,0); round(dot)
                local bTxt = label(badge, K and "LIVE" or "AO VIVO", K and 9 or 10, T.white, Enum.Font.GothamBold); bTxt.Position = UDim2.new(0,K and 16 or 22,0,0); bTxt.Size = UDim2.new(1,-24,1,0); bTxt.ZIndex = 9
                local chip = label(ov, "ESP DESLIGADO", K and 9 or 10, T.muted, Enum.Font.GothamBold); chip.AnchorPoint = Vector2.new(0,1)
                chip.Position = K and UDim2.new(0,8,1,-6) or UDim2.new(0,22,1,-14); chip.Size = UDim2.new(0,180,0,14); chip.ZIndex = 8

                -- elementos do ESP
                local boxGlow = mk("Frame", 6); boxGlow.BackgroundTransparency = 1
                local bgS = Instance.new("UIStroke"); bgS.Thickness = 2; bgS.Parent = boxGlow
                local boxF = mk("Frame", 7); boxF.BackgroundTransparency = 1
                local boxS = Instance.new("UIStroke"); boxS.Thickness = 1; boxS.Parent = boxF
                local nameL = mk("TextLabel", 8); nameL.BackgroundTransparency = 1; nameL.Font = Enum.Font.GothamBold; nameL.TextSize = K and 10 or 12
                nameL.Size = UDim2.new(0,220,0,14); nameL.AnchorPoint = Vector2.new(.5,1); nameL.TextStrokeTransparency = 0
                local hpBG = mk("Frame", 7); hpBG.BackgroundColor3 = Color3.fromRGB(25,25,25); hpBG.AnchorPoint = Vector2.new(1,0)
                local hpF = mk("Frame", 8); hpF.AnchorPoint = Vector2.new(1,1)
                local function mkLine() local l = mk("Frame", 7); l.AnchorPoint = Vector2.new(.5,.5); l.Visible = false; return l end
                local tracer = mkLine(); local skel = {}; for i = 1, 15 do skel[i] = mkLine() end
                local arrow = mk("TextLabel", 8); arrow.BackgroundTransparency = 1; arrow.Font = Enum.Font.GothamBold; arrow.TextSize = 13
                arrow.Text = "^ 25m"; arrow.AnchorPoint = Vector2.new(.5,0); arrow.Size = UDim2.new(0,80,0,16); arrow.TextStrokeTransparency = 0
                local function setLine(l, a, b, th, col, al)
                    local d = b - a; l.Size = UDim2.new(0, d.Magnitude, 0, th); l.Position = UDim2.new(0,(a.X+b.X)/2,0,(a.Y+b.Y)/2)
                    l.Rotation = math.deg(math.atan2(d.Y, d.X)); l.BackgroundColor3 = col; l.BackgroundTransparency = 1 - al; l.Visible = true
                end
                local R15 = {{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}}
                local R6 = {{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}
                local al = {}
                local function fd(k, tgt, dt) local v = al[k] or 0; v = v + (tgt - v)*math.min(1, dt*10); al[k] = v; return v end

                local t0 = 0
                local conn
                conn = RS.RenderStepped:Connect(function(dt)
                    if not frame.Parent then conn:Disconnect(); return end
                    local okv = true; pcall(function() okv = frame.Visible and page.Visible end)
                    local uis = 1; do local an = frame.Parent; while an do local u = an:FindFirstChildOfClass("UIScale"); if u and u.Scale > 0 then uis = uis * u.Scale end; an = an.Parent end end
                    local W, H = vp.AbsoluteSize.X/uis, vp.AbsoluteSize.Y/uis
                    if not okv or W < 40 or H < 40 or not model then return end
                    t0 = t0 + dt; local t = t0
                    local s = get() or {}; local col = s.Color or Color3.new(1,1,1); local on = s.On == true
                    local accent = on and Color3.fromRGB(240,240,245) or Color3.fromRGB(170,170,185)
                    -- espelha o movimento do personagem real
                    local hrp = hrpR; local off = Vector3.zero
                    if hrp and hrp.Parent then
                        sceneOrigin = hrp.Position
                        for i = 1, #pairsL do local p = pairsL[i]; if p[1].Parent then p[2].CFrame = p[1].CFrame - sceneOrigin end end
                        if #pairsL > 0 then off = hrp.Position - sceneOrigin end
                        pcall(function()
                            local rc = workspace.CurrentCamera; local look = rc.CFrame.LookVector
                            local ratio = math.clamp((rc.CFrame.Position - hrp.Position).Magnitude/10, .55, 1.7)
                            local tgt = off + Vector3.new(0, .3, 0)
                            cam.CFrame = CFrame.lookAt(tgt - look*camD*ratio, tgt)
                        end)
                    else
                        local ch = LP.Character; hrpR = ch and ch:FindFirstChild("HumanoidRootPart")
                    end
                    -- animacao de fundo / decoracao
                    bgG.Rotation = 90 + math.sin(t*.4)*25
                    fs.Color = fs.Color:Lerp(accent, .1)
                    scan.Position = UDim2.new(0,0,0,((t*.25)%1)*(H+72)-72); scG.Rotation = 90
                    scan.BackgroundColor3 = accent
                    for _, p in ipairs(parts2) do
                        p.y = p.y - p.sp*dt; if p.y < -.05 then p.y = 1.05; p.x = math.random() end
                        p.f.Position = UDim2.new(p.x,0,p.y,0); p.f.BackgroundColor3 = accent
                        p.f.BackgroundTransparency = .45 + .45*(.5+.5*math.sin(t*2+p.ph))
                    end
                    for _, b in ipairs(brk) do b.BackgroundColor3 = accent end
                    local pulse = .5 + .5*math.sin(t*3)
                    dot.BackgroundColor3 = on and Color3.fromRGB(240,240,245) or Color3.fromRGB(110,110,120); dot.BackgroundTransparency = .5*pulse
                    bS.Color = accent; bS.Transparency = .3
                    chip.Text = on and "ESP ATIVO" or "ESP DESLIGADO"; chip.TextColor3 = on and accent or T.muted
                    -- caixa delimitadora dinamica
                    local mn, mx = Vector2.new(1e9,1e9), Vector2.new(-1e9,-1e9)
                    for i = 1, #body do
                        local p = body[i]; local c, z = p.CFrame, p.Size
                        for x = -1, 1, 2 do for y = -1, 1, 2 do for zz = -1, 1, 2 do
                            local q = proj(c * Vector3.new(z.X/2*x, z.Y/2*y, z.Z/2*zz), W, H)
                            if q.X < mn.X then mn = Vector2.new(q.X, mn.Y) end; if q.Y < mn.Y then mn = Vector2.new(mn.X, q.Y) end
                            if q.X > mx.X then mx = Vector2.new(q.X, mx.Y) end; if q.Y > mx.Y then mx = Vector2.new(mx.X, q.Y) end
                        end end end
                    end
                    if mn.X > mx.X then return end
                    mn = mn - Vector2.new(4,4); mx = mx + Vector2.new(4,4)
                    local bw, bh = mx.X - mn.X, mx.Y - mn.Y; local cx, cy = (mn.X+mx.X)/2, (mn.Y+mx.Y)/2
                    -- plataforma sob os pes
                    local fp = proj(off + Vector3.new(0, feetY, 0), W, H)
                    plat1.Position = UDim2.new(0,fp.X,0,fp.Y); plat1.Size = UDim2.new(0,bw*1.5+pulse*8,0,bw*.38+pulse*3)
                    plat2.Position = plat1.Position; plat2.Size = UDim2.new(0,bw*2.1,0,bw*.55)
                    platGlow.Position = plat1.Position; platGlow.Size = UDim2.new(0,bw*1.5,0,bw*.38); platGlow.BackgroundColor3 = accent
                    pS1.Color = accent; pS1.Transparency = .15 + .3*pulse; pS2.Color = accent; pS2.Transparency = .65
                    -- box
                    local a = fd("box", (on and s.Box == true) and 1 or 0, dt)
                    boxF.Visible = a > .02; boxGlow.Visible = boxF.Visible
                    boxF.Position = UDim2.new(0,mn.X,0,mn.Y); boxF.Size = UDim2.new(0,bw,0,bh); boxS.Color = col; boxS.Transparency = 1 - a
                    boxGlow.Position = boxF.Position; boxGlow.Size = boxF.Size; bgS.Color = col; bgS.Transparency = 1 - a*.25
                    -- nome
                    a = fd("name", (on and (s.Name == true or s.Dist == true)) and 1 or 0, dt)
                    nameL.Visible = a > .02; nameL.TextColor3 = col; nameL.TextTransparency = 1 - a; nameL.TextStrokeTransparency = 1 - a
                    nameL.Position = UDim2.new(0,cx,0,mn.Y-4 - (1-a)*6); do local dm = 10 + math.floor(pulse*4)
                        if s.Name == true and s.Dist == true then nameL.Text = "[" .. tostring(LP.DisplayName) .. " - " .. dm .. "m]"
                        elseif s.Name == true then nameL.Text = "[" .. tostring(LP.DisplayName) .. "]"
                        else nameL.Text = "[" .. dm .. "m]" end end
                    -- vida (usa a vida real)
                    a = fd("hp", (on and s.HP == true) and 1 or 0, dt)
                    local ratio = 1
                    pcall(function() local h = LP.Character:FindFirstChildOfClass("Humanoid"); ratio = math.clamp(h.Health/h.MaxHealth, 0, 1) end)
                    hpBG.Visible = a > .02; hpF.Visible = hpBG.Visible
                    hpBG.Position = UDim2.new(0,mn.X-6,0,mn.Y); hpBG.Size = UDim2.new(0,4,0,bh); hpBG.BackgroundTransparency = 1 - a*.7
                    hpF.Position = UDim2.new(0,mn.X-6,0,mn.Y+bh); hpF.Size = UDim2.new(0,4,0,bh*ratio)
                    hpF.BackgroundColor3 = Color3.fromRGB(255*(1-ratio), 255*ratio, 0); hpF.BackgroundTransparency = 1 - a
                    -- linha
                    a = fd("line", (on and s.Line == true) and 1 or 0, dt)
                    if a > .02 then setLine(tracer, Vector2.new(W/2, H), Vector2.new(cx, mx.Y), 2, col, a*.9) else tracer.Visible = false end
                    -- seta
                    a = fd("arrow", (on and s.Arrows == true) and 1 or 0, dt)
                    arrow.Visible = false; arrow.TextColor3 = col; arrow.TextTransparency = 1 - a; arrow.TextStrokeTransparency = 1 - a
                    arrow.Position = UDim2.new(.5,0,0,(K and 20 or 40) + math.sin(t*3)*3)
                    -- esqueleto
                    a = fd("skel", (on and s.Skel == true) and 1 or 0, dt)
                    local map = model:FindFirstChild("UpperTorso") and R15 or R6
                    for i = 1, 15 do
                        local pr = map[i]; local p1 = pr and model:FindFirstChild(pr[1]); local p2 = pr and model:FindFirstChild(pr[2])
                        if a > .02 and p1 and p2 then setLine(skel[i], proj(p1.Position,W,H), proj(p2.Position,W,H), 1.8, col, a) else skel[i].Visible = false end
                    end
                    -- highlight: tinge o personagem (com leve pulso)
                    a = fd("hl", (on and s.HL == true) and 1 or 0, dt)
                    local k = 0
                    for i = 1, #parts do local p = parts[i]; p.Color = orig[p]:Lerp(col, k) end
                    pcall(function() if hlInst and hlInst.Parent then hlInst.OutlineColor = col; hlInst.OutlineTransparency = 1 - a*(1 - (s.HLOut or .5)) end end)
                    for i = 1, #shells do local pr = shells[i]; local e = .10 + (s.Thick or .15)*.35; pr[2].Size = pr[1].Size + Vector3.new(e,e,e); pr[2].CFrame = pr[1].CFrame; pr[2].Color = col; pr[2].Transparency = 1 - a*(1 - (s.HLOut or .5))*.75 end
                end)
                return {}
            end

            -- ===== Painel ESP compacto (preto / branco / prata), cabe inteiro na janela padrao =====
            function section:AddChipPanel(pc)
                pc = pc or {}
                local SIL, SIL2, ACTBG = Color3.fromRGB(235,235,240), Color3.fromRGB(140,140,152), Color3.fromRGB(32,32,38)
                local function tw(o, p, d) pcall(function() TweenService:Create(o, TweenInfo.new(d or .16, Enum.EasingStyle.Quad), p):Play() end) end
                local function rnd(f) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1,0); c.Parent = f end
                local function shine(f, r) local sh = Instance.new("Frame"); sh.Size = UDim2.new(1,0,1,0); sh.BackgroundColor3 = Color3.new(1,1,1); sh.BackgroundTransparency = 1
                    sh.BorderSizePixel = 0; sh.Parent = f; corner(sh, r); local g = Instance.new("UIGradient"); g.Color = ColorSequence.new(SIL, SIL2); g.Rotation = 30; g.Parent = sh; return sh end
                local panel = Instance.new("Frame"); panel.Size = UDim2.new(1,0,0,0); panel.AutomaticSize = Enum.AutomaticSize.Y; panel.BackgroundTransparency = 1; panel.Parent = items; order(panel)
                local pl = Instance.new("UIListLayout"); pl.SortOrder = Enum.SortOrder.LayoutOrder; pl.Padding = UDim.new(0,6); pl.Parent = panel
                local chips = {}
                local function chip(parent, title, def, cb, dotCol)
                    local state = def ~= false; cb = cb or function() end
                    local f = Instance.new("Frame"); f.Size = UDim2.new(1,0,1,0); f.BackgroundColor3 = T.panel; f.BorderSizePixel = 0; f.Parent = parent; corner(f,6)
                    local st = stroke(f, T.border, .1, 1); local sh = shine(f, 6)
                    local dot = Instance.new("Frame"); dot.Size = UDim2.new(0,6,0,6); dot.Position = UDim2.new(0,9,.5,-3); dot.BackgroundColor3 = T.border; dot.BorderSizePixel = 0; dot.Parent = f; rnd(dot)
                    local tl = label(f, title, 11, T.muted, Enum.Font.GothamMedium); tl.Position = UDim2.new(0,22,0,0); tl.Size = UDim2.new(1,-26,1,0); tl.TextTruncate = Enum.TextTruncate.AtEnd
                    local function paint()
                        tw(f, {BackgroundColor3 = state and ACTBG or T.panel}); tw(sh, {BackgroundTransparency = state and .9 or 1}); tw(st, {Color = state and SIL or T.border})
                        tw(dot, {BackgroundColor3 = dotCol or (state and SIL or T.border)}); tw(tl, {TextColor3 = state and T.white or T.muted})
                    end
                    paint()
                    local hit = button(f, "ChipHit", UDim2.new(1,0,1,0), UDim2.new(), Color3.new()); hit.BackgroundTransparency = 1; hit.ZIndex = 5
                    local function set(v, fire) state = not not v; paint(); if fire ~= false then pcall(cb, state) end end
                    bindTap(hit, function() set(not state, true) end)
                    return {Set = function(_, v, fr) set(v, fr) end, GetValue = function() return state end}
                end
                -- card principal (liga/desliga todos)
                local hs = false
                local hero = Instance.new("Frame"); hero.Size = UDim2.new(1,0,0,30); hero.LayoutOrder = 1; hero.BackgroundColor3 = T.panel; hero.BorderSizePixel = 0; hero.Parent = panel; corner(hero,8)
                local hst = stroke(hero, T.border, .1, 1.2); local hsh = shine(hero, 8)
                local ht = label(hero, pc.Title or "", 12, T.white, Enum.Font.GothamBold); ht.Visible = (pc.Title or "") ~= ""; ht.Position = UDim2.new(0,12,0,0); ht.Size = UDim2.new(1,-62,1,0); ht.TextTruncate = Enum.TextTruncate.AtEnd
                local trk = Instance.new("Frame"); trk.Size = UDim2.new(0,34,0,18); trk.AnchorPoint = Vector2.new(1,.5); trk.Position = UDim2.new(1,-10,.5,0); trk.BackgroundColor3 = T.field; trk.BorderSizePixel = 0; trk.Parent = hero; rnd(trk); stroke(trk, T.border, 0, 1)
                local hd = Instance.new("Frame"); hd.Size = UDim2.new(0,12,0,12); hd.AnchorPoint = Vector2.new(0,.5); hd.Position = UDim2.new(0,3,.5,0); hd.BackgroundColor3 = T.silver2; hd.BorderSizePixel = 0; hd.Parent = trk; rnd(hd)
                local function hpaint()
                    tw(hsh, {BackgroundTransparency = hs and .88 or 1}); tw(hst, {Color = hs and SIL or T.border}); tw(trk, {BackgroundColor3 = hs and SIL or T.field})
                    tw(hd, {Position = hs and UDim2.new(1,-15,.5,0) or UDim2.new(0,3,.5,0), BackgroundColor3 = hs and T.darkText or T.silver2})
                end
                hpaint()
                local hhit = button(hero, "HeroHit", UDim2.new(1,0,1,0), UDim2.new(), Color3.new()); hhit.BackgroundTransparency = 1; hhit.ZIndex = 5
                bindTap(hhit, function() hs = not hs; hpaint(); for _, c in ipairs(chips) do c:Set(hs, true) end end)
                -- grade de chips
                local cols = math.max(1, tonumber(pc.Columns) or 2)
                local grid = Instance.new("Frame"); grid.Size = UDim2.new(1,0,0,0); grid.AutomaticSize = Enum.AutomaticSize.Y; grid.LayoutOrder = 2; grid.BackgroundTransparency = 1; grid.Parent = panel
                grid.AutomaticSize = Enum.AutomaticSize.None
                local holders = {}
                local function relayout()
                    local n = #holders; local rows = math.ceil(n / cols)
                    grid.Size = UDim2.new(1,0,0,rows > 0 and (rows*30 - 4) or 0)
                    for i, h in ipairs(holders) do
                        local r, c = math.floor((i-1)/cols), (i-1) % cols
                        local alone = (i == n) and (n % cols == 1) and cols > 1
                        if alone then
                            h.Size = UDim2.new(1,0,0,26); h.Position = UDim2.new(0,0,0,r*30)
                        else
                            h.Size = UDim2.new(1/cols, -(4*(cols-1))/cols, 0, 26)
                            h.Position = UDim2.new(c/cols, c*4 - c*(4*(cols-1))/cols, 0, r*30)
                        end
                    end
                end
                local obj = {}
                function obj:AddChip(title, def, cb, dotCol)
                    local holder = Instance.new("Frame"); holder.BackgroundTransparency = 1; holder.LayoutOrder = #chips + 1; holder.Parent = grid
                    holders[#holders + 1] = holder; relayout()
                    local c = chip(holder, title, def, cb, dotCol); chips[#chips + 1] = c; return c
                end
                for _, tcfg in ipairs(pc.Chips or {}) do obj:AddChip(tcfg.Title, tcfg.Default, tcfg.Callback, tcfg.Color) end
                return obj
            end
            function section:AddESPPanel(pc)
                pc = pc or {}
                local SIL, SIL2, ACTBG = Color3.fromRGB(235,235,240), Color3.fromRGB(140,140,152), Color3.fromRGB(32,32,38)
                local function tw(o, p, d) pcall(function() TweenService:Create(o, TweenInfo.new(d or .16, Enum.EasingStyle.Quad), p):Play() end) end
                local function rnd(f) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1,0); c.Parent = f end
                local panel = Instance.new("Frame"); panel.Size = UDim2.new(1,0,0,200); panel.BackgroundTransparency = 1; panel.Parent = items; order(panel)
                section:AddESPPreview({Get = pc.Get, Parent = panel, Size = UDim2.new(0,150,0,124), Position = UDim2.new(0,0,0,0), Compact = true})

                local function shine(f, r) local sh = Instance.new("Frame"); sh.Size = UDim2.new(1,0,1,0); sh.BackgroundColor3 = Color3.new(1,1,1); sh.BackgroundTransparency = 1
                    sh.BorderSizePixel = 0; sh.Parent = f; corner(sh, r); local g = Instance.new("UIGradient"); g.Color = ColorSequence.new(SIL, SIL2); g.Rotation = 30; g.Parent = sh; return sh end
                local repaints = {}
                local function chip(parent, title, def, cb, size, pos, dotFn)
                    local state = def == true; cb = cb or function() end
                    local f = Instance.new("Frame"); f.Size = size; f.Position = pos or UDim2.new(); f.BackgroundColor3 = T.panel; f.BorderSizePixel = 0; f.Parent = parent; corner(f,6)
                    local st = stroke(f, T.border, .1, 1); local sh = shine(f, 6)
                    local dot = Instance.new("Frame"); dot.Size = UDim2.new(0,6,0,6); dot.Position = UDim2.new(0,8,.5,-3); dot.BackgroundColor3 = T.border; dot.BorderSizePixel = 0; dot.Parent = f; rnd(dot)
                    local tl = label(f, title, 10, T.muted, Enum.Font.GothamMedium); tl.Position = UDim2.new(0,20,0,0); tl.Size = UDim2.new(1,-24,1,0); tl.TextTruncate = Enum.TextTruncate.AtEnd
                    local function paint()
                        tw(f, {BackgroundColor3 = state and ACTBG or T.panel}); tw(sh, {BackgroundTransparency = state and .9 or 1}); tw(st, {Color = state and SIL or T.border})
                        if dotFn then repaints[paint] = true end; tw(dot, {BackgroundColor3 = state and (dotFn and dotFn() or SIL) or T.border}); tw(tl, {TextColor3 = state and T.white or T.muted})
                    end
                    paint()
                    local hit = button(f, "ChipHit", UDim2.new(1,0,1,0), UDim2.new(), Color3.new()); hit.BackgroundTransparency = 1; hit.ZIndex = 5
                    local function set(v, fire) state = not not v; paint(); if fire ~= false then pcall(cb, state) end end
                    bindTap(hit, function() set(not state, true) end)
                    return {Set = function(_, v, fr) set(v, fr) end, GetValue = function() return state end}
                end

                local right = Instance.new("Frame"); right.Position = UDim2.new(0,158,0,0); right.Size = UDim2.new(1,-158,0,124); right.BackgroundTransparency = 1; right.Parent = panel
                -- card principal
                local H = pc.Hero or {}; local hs = H.Default == true
                local hero = Instance.new("Frame"); hero.Size = UDim2.new(1,0,0,30); hero.BackgroundColor3 = T.panel; hero.BorderSizePixel = 0; hero.Parent = right; corner(hero,8)
                local hst = stroke(hero, T.border, .1, 1.2); local hsh = shine(hero, 8)
                local ht = label(hero, H.Title or "ESP", 12, T.white, Enum.Font.GothamBold); ht.Position = UDim2.new(0,12,0,0); ht.Size = UDim2.new(1,-62,1,0); ht.TextTruncate = Enum.TextTruncate.AtEnd
                local trk = Instance.new("Frame"); trk.Size = UDim2.new(0,34,0,18); trk.AnchorPoint = Vector2.new(1,.5); trk.Position = UDim2.new(1,-10,.5,0); trk.BackgroundColor3 = T.field; trk.BorderSizePixel = 0; trk.Parent = hero; rnd(trk); stroke(trk, T.border, 0, 1)
                local hd = Instance.new("Frame"); hd.Size = UDim2.new(0,12,0,12); hd.AnchorPoint = Vector2.new(0,.5); hd.Position = UDim2.new(0,3,.5,0); hd.BackgroundColor3 = T.silver2; hd.BorderSizePixel = 0; hd.Parent = trk; rnd(hd)
                local function hpaint()
                    tw(hsh, {BackgroundTransparency = hs and .88 or 1}); tw(hst, {Color = hs and SIL or T.border}); tw(trk, {BackgroundColor3 = hs and SIL or T.field})
                    tw(hd, {Position = hs and UDim2.new(1,-15,.5,0) or UDim2.new(0,3,.5,0), BackgroundColor3 = hs and T.darkText or T.silver2})
                end
                hpaint()
                local hhit = button(hero, "HeroHit", UDim2.new(1,0,1,0), UDim2.new(), Color3.new()); hhit.BackgroundTransparency = 1; hhit.ZIndex = 5
                bindTap(hhit, function() hs = not hs; hpaint(); if H.Callback then pcall(H.Callback, hs) end end)
                -- grade de opcoes
                local grid = Instance.new("Frame"); grid.Position = UDim2.new(0,0,0,36); grid.Size = UDim2.new(1,0,0,88); grid.BackgroundTransparency = 1; grid.Parent = right
                local gl = Instance.new("UIGridLayout"); gl.CellSize = UDim2.new(.5,-2,0,16); gl.CellPadding = UDim2.new(0,4,0,2); gl.SortOrder = Enum.SortOrder.LayoutOrder; gl.Parent = grid
                for i, tcfg in ipairs(pc.Tiles or {}) do
                    local holder = Instance.new("Frame"); holder.BackgroundTransparency = 1; holder.LayoutOrder = i; holder.Parent = grid
                    chip(holder, tcfg.Title, tcfg.Default, tcfg.Callback, UDim2.new(1,0,1,0))
                end
                -- sliders lado a lado
                local function slider(sc, x0, xs)
                    local min, max = tonumber(sc.Min) or 0, tonumber(sc.Max) or 100; if max <= min then max = min + 1 end
                    local suf = sc.Suffix or ""; local value = math.clamp(tonumber(sc.Default) or min, min, max)
                    local row = Instance.new("Frame"); row.Size = UDim2.new(.5,-3,0,36); row.Position = UDim2.new(x0,xs,0,129); row.BackgroundColor3 = T.panel; row.BorderSizePixel = 0; row.Parent = panel
                    corner(row,8); stroke(row, T.border, .1, 1)
                    local tl = label(row, sc.Title or "", 10, T.white, Enum.Font.GothamMedium); tl.Position = UDim2.new(0,9,0,3); tl.Size = UDim2.new(1,-64,0,14); tl.TextTruncate = Enum.TextTruncate.None; tl.TextScaled = true; local tlc = Instance.new("UITextSizeConstraint"); tlc.MaxTextSize = 10; tlc.MinTextSize = 6; tlc.Parent = tl
                    local vl = Instance.new("TextBox"); vl.Size = UDim2.new(0,44,0,16); vl.AnchorPoint = Vector2.new(1,0); vl.Position = UDim2.new(1,-7,0,2); vl.BackgroundColor3 = T.field; vl.BorderSizePixel = 0
                    vl.Font = Enum.Font.GothamBold; vl.TextSize = 10; vl.TextColor3 = SIL; vl.ClearTextOnFocus = false; vl.Text = ""; vl.Parent = row; corner(vl,5); stroke(vl, T.border, 0, 1)
                    local track = Instance.new("Frame"); track.Size = UDim2.new(1,-18,0,4); track.Position = UDim2.new(0,9,0,25); track.BackgroundColor3 = T.field; track.BorderSizePixel = 0; track.Parent = row; rnd(track)
                    local fill = Instance.new("Frame"); fill.Size = UDim2.new(0,0,1,0); fill.BackgroundColor3 = Color3.new(1,1,1); fill.BorderSizePixel = 0; fill.Parent = track; rnd(fill)
                    local fg = Instance.new("UIGradient"); fg.Color = ColorSequence.new(SIL2, SIL); fg.Parent = fill
                    local knob = Instance.new("Frame"); knob.Size = UDim2.new(0,10,0,10); knob.AnchorPoint = Vector2.new(.5,.5); knob.BackgroundColor3 = Color3.new(1,1,1); knob.BorderSizePixel = 0; knob.ZIndex = 3; knob.Parent = track; rnd(knob)
                    local function set(v, fire)
                        value = math.clamp(math.floor((tonumber(v) or min) + .5), min, max); local r = (value - min)/(max - min)
                        fill.Size = UDim2.new(r,0,1,0); knob.Position = UDim2.new(r,0,.5,0); vl.Text = tostring(value) .. suf
                        if fire ~= false and sc.Callback then pcall(sc.Callback, value) end
                    end
                    set(value, false)
                    vl.Focused:Connect(function() vl.Text = tostring(value) end)
                    vl.FocusLost:Connect(function() local n = tonumber((vl.Text or ""):match("-?%d+%.?%d*")); if n then set(n) else vl.Text = tostring(value) .. suf end end)
                    local sliding = false
                    local function fromX(x) set(min + (max - min)*math.clamp((x - track.AbsolutePosition.X)/math.max(track.AbsoluteSize.X,1), 0, 1)) end
                    local hit = Instance.new("TextButton"); hit.Text = ""; hit.BackgroundTransparency = 1; hit.Size = UDim2.new(1,0,0,22); hit.Position = UDim2.new(0,0,0,14); hit.ZIndex = 4; hit.Parent = row
                    hit.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = true; fromX(i.Position.X) end end)
                    UserInputService.InputChanged:Connect(function(i) if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then fromX(i.Position.X) end end)
                    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = false end end)
                end
                local sl = pc.Sliders or {}
                if sl[1] then slider(sl[1], 0, 0) end
                if sl[2] then slider(sl[2], .5, 3) end
                -- faixa inferior: cor personalizada + cores + tecla
                local bar = Instance.new("Frame"); bar.Size = UDim2.new(1,0,0,30); bar.Position = UDim2.new(0,0,0,170); bar.BackgroundColor3 = T.panel; bar.BorderSizePixel = 0; bar.Parent = panel
                corner(bar,8); stroke(bar, T.border, .1, 1)
                local C = pc.Custom or {}
                local curCol = SIL
                chip(bar, C.Title or "Cor", C.Default, C.Callback, UDim2.new(0,124,0,20), UDim2.new(0,6,.5,-10), function() return curCol end)
                local sw = pc.Swatches or {}; local opts = sw.Options or {}; local cur = sw.Default or 1; local rings, sbs = {}, {}; if opts[cur] then curCol = opts[cur][2] end; for f in pairs(repaints) do f() end
                local function spaint() for i = 1, #rings do tw(rings[i], {Transparency = (i == cur) and 0 or 1}); tw(sbs[i], {Size = (i == cur) and UDim2.new(0,18,0,18) or UDim2.new(0,14,0,14)}) end end
                local sf = Instance.new("Frame"); sf.Size = UDim2.new(1,-150,0,22); sf.Position = UDim2.new(0,144,.5,-11); sf.BackgroundTransparency = 1; sf.Parent = bar
                local holds = {}; local blackIdx = #opts + 1
                local isCol = (OrionLib and OrionLib.SidebarCollapsed) == true
                local function relayoutSw()
                    local n = #opts + (isCol and 1 or 0)
                    for i, h in ipairs(holds) do
                        h.Visible = (i <= n); h.Size = UDim2.new(1/n,0,1,0); h.Position = UDim2.new((i-1)/n,0,0,0)
                    end
                end
                for i, o in ipairs(opts) do
                    local hold = Instance.new("Frame"); hold.Size = UDim2.new(1/#opts,0,1,0); hold.Position = UDim2.new((i-1)/#opts,0,0,0); hold.BackgroundTransparency = 1; hold.Parent = sf; holds[i] = hold
                    local b = button(hold, "Sw", UDim2.new(0,14,0,14), UDim2.new(.5,0,.5,0), o[2]); b.AnchorPoint = Vector2.new(.5,.5); b.Text = ""; rnd(b)
                    local ring = Instance.new("UIStroke"); ring.Color = Color3.new(1,1,1); ring.Thickness = 1.5; ring.Transparency = 1; ring.Parent = b
                    rings[i] = ring; sbs[i] = b
                    bindTap(b, function() cur = i; curCol = o[2]; for f in pairs(repaints) do f() end; spaint(); if sw.Callback then pcall(sw.Callback, o[1], o[2], i) end end)
                end
                do -- bolinha preta extra: so aparece com a sidebar recolhida
                    local i = blackIdx; local blk = Color3.fromRGB(0,225,255)
                    local hold = Instance.new("Frame"); hold.BackgroundTransparency = 1; hold.Parent = sf; holds[i] = hold
                    local b = button(hold, "Sw", UDim2.new(0,14,0,14), UDim2.new(.5,0,.5,0), blk); b.AnchorPoint = Vector2.new(.5,.5); b.Text = ""; rnd(b)
                    local bs = Instance.new("UIStroke"); bs.Color = Color3.fromRGB(180,245,255); bs.Thickness = 1; bs.Transparency = .6; bs.Parent = b
                    local ring = Instance.new("UIStroke"); ring.Color = Color3.new(1,1,1); ring.Thickness = 1.5; ring.Transparency = 1; ring.Parent = b
                    rings[i] = ring; sbs[i] = b
                    bindTap(b, function() cur = i; curCol = blk; for f in pairs(repaints) do f() end; spaint(); if sw.Callback then pcall(sw.Callback, "Ciano", blk, i) end end)
                end
                relayoutSw()
                if OrionLib then
                    OrionLib._collapseCbs = OrionLib._collapseCbs or {}
                    table.insert(OrionLib._collapseCbs, function(c)
                        if not sf.Parent then return end
                        isCol = c; relayoutSw()
                        if not c and cur == blackIdx then cur = 1; if opts[1] then curCol = opts[1][2] end; for f in pairs(repaints) do f() end; if sw.Callback and opts[1] then pcall(sw.Callback, opts[1][1], opts[1][2], 1) end end
                        spaint()
                    end)
                end
                spaint()
                return {}
            end
            function section:AddInput(ic)
                ic=ic or {}; local row=Instance.new("Frame"); row.Size=UDim2.new(1,0,0,40); row.BackgroundColor3=T.panel; row.BorderSizePixel=0; row.Parent=items; order(row); corner(row,7); local st=stroke(row,T.border,.1,1)
                local box=Instance.new("TextBox"); box.Size=UDim2.new(1,-20,1,0); box.Position=UDim2.new(0,10,0,0); box.BackgroundTransparency=1; box.ClearTextOnFocus=false; box.Text=tostring(ic.Default or ""); box.PlaceholderText=ic.Placeholder or ic.Content or ic.Title or "Digite aqui"; box.PlaceholderColor3=T.muted; box.TextColor3=T.white; box.Font=Enum.Font.Gotham; box.TextSize=12; box.TextXAlignment=Enum.TextXAlignment.Left; box.Parent=row
                box.Focused:Connect(function() st.Color=T.silver2 end); box.FocusLost:Connect(function(enter) st.Color=T.border; if ic.Callback then pcall(ic.Callback,box.Text,enter) end end)
                return {Set=function(_,v) box.Text=tostring(v) end,Get=function() return box.Text end}
            end
            function section:AddDropdown(dc)
                dc=dc or {}; local values=dc.Values or dc.Options or {}; local selected=dc.Default or values[1] or ""
                local row=Instance.new("Frame"); row.Size=UDim2.new(1,0,0,40); row.AutomaticSize=Enum.AutomaticSize.Y; row.BackgroundColor3=T.panel; row.BorderSizePixel=0; row.ClipsDescendants=false; row.Parent=items; order(row); corner(row,7); stroke(row,T.border,.1,1)
                local rl=Instance.new("UIListLayout"); rl.SortOrder=Enum.SortOrder.LayoutOrder; rl.Padding=UDim.new(0,0); rl.Parent=row
                local head=Instance.new("Frame"); head.Name="Head"; head.Size=UDim2.new(1,0,0,46); head.BackgroundTransparency=1; head.LayoutOrder=1; head.Parent=row
                local function _name(v) if type(v)=="table" then return tostring(v.name or "Script") end return tostring(v) end
                local function _lbl(v) if dc.Display then local pt=(OrionLib.IsPT~=false); if #values==0 then return pt and "Nenhum script selecionado" or "No script selected" end return pt and "Scripts selecionados" or "Selected scripts" end return (dc.Title or "Selecionar")..": ".._name(v) end
                local txt=label(head,_lbl(selected),15,T.white); txt.Position=UDim2.new(0,11,0,0); txt.Size=UDim2.new(1,-50,1,0); txt.TextTruncate=Enum.TextTruncate.AtEnd; txt.TextXAlignment=Enum.TextXAlignment.Left
                local pill
                if dc.Display then
                    head.Size=UDim2.new(1,0,0,38); txt.TextSize=12; txt.Font=Enum.Font.GothamBold; txt.Position=UDim2.new(0,40,0,0); txt.Size=UDim2.new(1,-84,1,0)
                    local li=Instance.new("ImageLabel"); li.BackgroundTransparency=1; li.Size=UDim2.new(0,20,0,20); li.AnchorPoint=Vector2.new(0,.5); li.Position=UDim2.new(0,12,.5,0)
                    local img=""; for _,n in ipairs({"list-checks","list-todo","check-check","list"}) do local okI,r=pcall(icon,n); if okI and type(r)=="string" and r~="" then img=r break end end
                    li.Image=img; li.ImageColor3=T.silver; li.Parent=head
                    pill=Instance.new("TextLabel"); pill.BackgroundColor3=T.field; pill.BorderSizePixel=0; pill.Size=UDim2.new(0,28,0,20); pill.AnchorPoint=Vector2.new(1,.5)
                    pill.Position=UDim2.new(1,-12,.5,0); pill.Font=Enum.Font.GothamBold; pill.TextSize=12; pill.TextColor3=T.white; pill.Text="0"; pill.Parent=head
                    corner(pill,5); stroke(pill,T.border,.1,1); pill.Size=UDim2.new(0,26,0,18)
                end
                local arrow=Instance.new("ImageLabel"); arrow.BackgroundTransparency=1; arrow.Size=UDim2.new(0,16,0,16); arrow.AnchorPoint=Vector2.new(1,.5); arrow.Position=UDim2.new(1,-11,.5,0); arrow.Image=icon("chevron-down"); arrow.ImageColor3=T.silver; arrow.Parent=head; if dc.Display then arrow.Visible=false end
                local hit=button(head,"DropdownHit",UDim2.new(1,0,1,0),UDim2.new(),Color3.new()); hit.BackgroundTransparency=1
                local menu=Instance.new("Frame"); menu.Name="Menu"; menu.LayoutOrder=2; menu.Size=UDim2.new(1,0,0,0); menu.AutomaticSize=Enum.AutomaticSize.Y; menu.BackgroundTransparency=1; menu.BorderSizePixel=0; menu.Visible=false; menu.Parent=row
                local mp=Instance.new("UIPadding"); mp.PaddingLeft=UDim.new(0,6); mp.PaddingRight=UDim.new(0,6); mp.PaddingBottom=UDim.new(0,6); mp.Parent=menu
                local ml=Instance.new("UIListLayout"); ml.Padding=UDim.new(0,4); ml.SortOrder=Enum.SortOrder.LayoutOrder; ml.Parent=menu
                local function rebuild(vals)
                    for _,x in ipairs(menu:GetChildren()) do if not x:IsA("UIListLayout") and not x:IsA("UIPadding") then x:Destroy() end end
                    values=vals or values
                    if (selected==nil or selected=="") and #values>0 and not dc.Display then selected=values[1] end
                    txt.Text=_lbl(selected)
                    if not dc.Display and #values==0 then
                        local e0=label(menu,OrionLib.IsPT and "Nenhuma opção disponível" or "No options available",12,T.muted); e0.Name="Empty"; e0.Size=UDim2.new(1,0,0,30); e0.LayoutOrder=1; e0.TextXAlignment=Enum.TextXAlignment.Center
                    end
                    if dc.Display then menu.Visible=#values>0; if pill then pill.Text=tostring(#values) end end
                    for i,v in ipairs(values) do
                        if dc.Display and type(v)=="table" then
                            local card=Instance.new("Frame"); card.Name="Item"; card.LayoutOrder=i; card.Size=UDim2.new(1,0,0,48); card.BackgroundColor3=T.field; card.BorderSizePixel=0; card.ClipsDescendants=true; card.Parent=menu; corner(card,8); stroke(card,T.border,.1,1)
                            local tb=Instance.new("Frame"); tb.Size=UDim2.new(0,56,0,34); tb.Position=UDim2.new(0,7,.5,-17); tb.BackgroundColor3=Color3.fromRGB(29,29,35); tb.BorderSizePixel=0; tb.Parent=card; corner(tb,6); stroke(tb,T.border,.15,1)
                            local th=Instance.new("ImageLabel"); th.Size=UDim2.new(1,-2,1,-2); th.Position=UDim2.new(0,1,0,1); th.BackgroundTransparency=1; th.ScaleType=Enum.ScaleType.Fit; th.ZIndex=3; th.Parent=tb; corner(th,5)
                            do local fb=v.fallback; if type(fb)=="string" and fb~="" then th.Image=fb end
                                if type(v.image)=="string" and v.image~="" then resolveImage(v.image,function(r) if th.Parent and r and r~="" then th.Image=r; th.ImageColor3=Color3.new(1,1,1) end end) end end
                            local tl=label(card,tostring(v.name or "Script"),12,T.white,Enum.Font.GothamBold); tl.Position=UDim2.new(0,72,0,7); tl.Size=UDim2.new(1,-116,0,16); tl.TextTruncate=Enum.TextTruncate.AtEnd
                            local dtxt=(tostring(v.description or ""):gsub("%s+"," "))
                            local dl=label(card,dtxt,10,T.muted); dl.Position=UDim2.new(0,72,0,24); dl.Size=UDim2.new(1,-116,0,16); dl.TextTruncate=Enum.TextTruncate.AtEnd
                            if dc.OnItemClick then
                                local rm=button(card,"RemoveHit",UDim2.new(0,26,0,26),UDim2.new(1,-8,.5,0),T.panel); rm.AnchorPoint=Vector2.new(1,.5); rm.ZIndex=10; corner(rm,13)
                                local rs=stroke(rm,T.border,0,1)
                                local xi=Instance.new("ImageLabel"); xi.BackgroundTransparency=1; xi.Size=UDim2.new(0,13,0,13); xi.AnchorPoint=Vector2.new(.5,.5); xi.Position=UDim2.new(.5,0,.5,0); xi.Image=icon("x"); xi.ImageColor3=T.muted; xi.ZIndex=11; xi.Parent=rm
                                rm.MouseEnter:Connect(function() rm.BackgroundColor3=Color3.fromRGB(54,24,25); rs.Color=T.error; xi.ImageColor3=T.error end)
                                rm.MouseLeave:Connect(function() rm.BackgroundColor3=T.panel; rs.Color=T.border; xi.ImageColor3=T.muted end)
                                bindTap(rm, function() pcall(dc.OnItemClick, v) end)
                            end
                        else
                            local isSel=(tostring(_name(v))==tostring(_name(selected)))
                            local b=button(menu,"Option",UDim2.new(1,0,0,32),UDim2.new(),isSel and T.field or T.header); b.LayoutOrder=i; b.Text=_name(v); b.Font=isSel and Enum.Font.GothamBold or Enum.Font.Gotham; b.TextSize=13; b.TextColor3=isSel and T.silver or T.white
                            b.TextXAlignment=Enum.TextXAlignment.Left; b.TextTruncate=Enum.TextTruncate.AtEnd; b.AutoButtonColor=false; corner(b,6)
                            local bpad=Instance.new("UIPadding"); bpad.PaddingLeft=UDim.new(0,10); bpad.PaddingRight=UDim.new(0,8); bpad.Parent=b
                            bindTap(b, function() if dc.Display then menu.Visible=false; arrow.Rotation=0; return end selected=v; txt.Text=_lbl(v); menu.Visible=false; arrow.Rotation=0; for _,o in ipairs(menu:GetChildren()) do if o.Name=="Option" then local on=(o==b); o.BackgroundColor3=on and T.field or T.header; o.TextColor3=on and T.silver or T.white; o.Font=on and Enum.Font.GothamBold or Enum.Font.Gotham end end; if dc.Callback then pcall(dc.Callback,v) end end)
                        end
                    end
                end
                rebuild(values); bindTap(hit, function() if dc.Display then if #values==0 then pcall(Bell.push,"error","Orion Studios",(OrionLib.IsPT~=false) and "Nenhum script selecionado para a execução automática." or "No script selected for auto-execute.") end return end menu.Visible=not menu.Visible; arrow.Rotation=menu.Visible and 180 or 0 end)
                return {Set=function(_,v) selected=v; txt.Text=_lbl(v); if dc.Callback then pcall(dc.Callback,v) end end,SetValues=rebuild,SetOptions=rebuild,GetValue=function() return selected end}
            end
            function section:AddSlider(sc)
                sc=sc or {}; local min,max=tonumber(sc.Min) or 0,tonumber(sc.Max) or 100; if max<=min then max=min+1 end; local value=math.clamp(tonumber(sc.Default) or min,min,max)
                local row=Instance.new("Frame"); row.Size=UDim2.new(1,0,0,54); row.BackgroundColor3=T.panel; row.BorderSizePixel=0; row.Parent=items; order(row); corner(row,7); stroke(row,T.border,.1,1)
                local head=label(row,sc.Title or "Valor",15,T.white); head.Position=UDim2.new(0,11,0,3); head.Size=UDim2.new(.7,0,0,20)
                local val=label(row,tostring(value),14,T.silver,Enum.Font.GothamBold); val.Position=UDim2.new(.7,-5,0,3); val.Size=UDim2.new(.3,-7,0,20); val.TextXAlignment=Enum.TextXAlignment.Right
                local track=Instance.new("Frame"); track.Size=UDim2.new(1,-22,0,5); track.Position=UDim2.new(0,11,0,35); track.BackgroundColor3=T.border; track.BorderSizePixel=0; track.Parent=row; corner(track,4)
                local fill=Instance.new("Frame"); fill.Size=UDim2.new((value-min)/(max-min),0,1,0); fill.BackgroundColor3=T.silver; fill.BorderSizePixel=0; fill.Parent=track; corner(fill,4)
                local function set(v,fire) value=math.clamp(tonumber(v) or min,min,max); fill.Size=UDim2.new((value-min)/(max-min),0,1,0); val.Text=tostring(value); if fire~=false and sc.Callback then pcall(sc.Callback,value) end end
                local sliding=false; track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=true; local r=math.clamp((i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1); set(math.floor(min+(max-min)*r)) end end)
                UserInputService.InputChanged:Connect(function(i) if sliding and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local r=math.clamp((i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1); set(math.floor(min+(max-min)*r)) end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=false end end)
                return {Set=function(_,v) set(v) end,GetValue=function() return value end}
            end
            function section:AddSubSection(v) return section:AddLabel({Text=v}) end
            function section:AddCategory(v) return section:AddSection(v,false) end
            function section:AddPanel(v) return section:AddParagraph(v) end
            function section:AddKeybind(kc)
                kc = kc or {}
                local key = kc.Default
                if type(key) == "string" then key = Enum.KeyCode[key] end
                local row = Instance.new("Frame"); row.Size = UDim2.new(1,0,0,39); row.BackgroundColor3 = T.panel; row.BorderSizePixel = 0; row.Parent = items; order(row)
                corner(row,7); stroke(row,T.border,.1,1)
                local txt = label(row, kc.Title or "Keybind", 15, T.white, Enum.Font.GothamMedium); txt.Position = UDim2.new(0,12,0,0); txt.Size = UDim2.new(1,-110,1,0)
                local kb = button(row, "KeyBtn", UDim2.new(0,80,0,26), UDim2.new(1,-92,.5,-13), T.field)
                corner(kb,6); stroke(kb,T.border,0,1)
                kb.Font = Enum.Font.GothamBold; kb.TextSize = 11; kb.TextColor3 = T.silver
                local function show() kb.Text = key and key.Name or "None" end
                show()
                local listening = false
                bindTap(kb, function()
                    if listening then return end
                    listening = true; kb.Text = "..."
                    local conn
                    conn = UserInputService.InputBegan:Connect(function(io)
                        if io.UserInputType ~= Enum.UserInputType.Keyboard then return end
                        conn:Disconnect(); listening = false
                        if io.KeyCode ~= Enum.KeyCode.Escape then
                            key = io.KeyCode
                            if kc.Callback then pcall(kc.Callback, key) end
                        end
                        show()
                    end)
                end)
                return {Set=function(_,v) if type(v)=="string" then v = Enum.KeyCode[v] end key = v show() end, GetValue=function() return key end}
            end
            function section:AddChat(cc)
                cc = cc or {}
                local isPT = OrionLib.IsPT
                local Plrs = game:GetService("Players")
                local lp = Plrs.LocalPlayer
                local H = math.min(tonumber(cc.Height) or 260, 270)
                local box = Instance.new("Frame"); box.Name = "Chat"; box.Size = UDim2.new(1,0,0,H); box.BackgroundColor3 = T.panel; box.BorderSizePixel = 0; box.Parent = items; order(box)
                corner(box,7); stroke(box,T.border,.1,1)
                local ttl = label(box, cc.Title or "Chat", 13, T.white, Enum.Font.GothamBold); ttl.Position = UDim2.new(0,12,0,6); ttl.Size = UDim2.new(1,-24,0,16)
                local sub = label(box, cc.SubTitle or "", 10, T.muted, Enum.Font.Gotham); sub.Position = UDim2.new(0,12,0,22); sub.Size = UDim2.new(1,-24,0,13); sub.TextTruncate = Enum.TextTruncate.AtEnd
                local scroll = Instance.new("ScrollingFrame"); scroll.Name = "Messages"; scroll.Position = UDim2.new(0,8,0,40); scroll.Size = UDim2.new(1,-16,1,-86)
                scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 3; scroll.ScrollBarImageColor3 = T.silver2
                scroll.CanvasSize = UDim2.new(); scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; scroll.ScrollingDirection = Enum.ScrollingDirection.Y; scroll.Parent = box
                local sl = Instance.new("UIListLayout"); sl.Padding = UDim.new(0,10); sl.SortOrder = Enum.SortOrder.LayoutOrder; sl.Parent = scroll
                local sp = Instance.new("UIPadding"); sp.PaddingLeft = UDim.new(0,8); sp.PaddingRight = UDim.new(0,12); sp.PaddingTop = UDim.new(0,6); sp.PaddingBottom = UDim.new(0,6); sp.Parent = scroll
                local bar = Instance.new("Frame"); bar.Name = "InputBar"; bar.Size = UDim2.new(1,-16,0,34); bar.Position = UDim2.new(0,8,1,-40); bar.BackgroundColor3 = T.field; bar.BorderSizePixel = 0; bar.Parent = box
                corner(bar,8); local barStroke = stroke(bar,T.border,.1,1)
                local input = Instance.new("TextBox"); input.Size = UDim2.new(1,-108,1,0); input.Position = UDim2.new(0,12,0,0); input.BackgroundTransparency = 1; input.ClearTextOnFocus = false
                input.Text = ""; input.PlaceholderText = cc.Placeholder or (isPT and "Digite sua mensagem..." or "Type your message..."); input.PlaceholderColor3 = T.muted
                input.TextColor3 = T.white; input.Font = Enum.Font.Gotham; input.TextSize = 13; input.TextXAlignment = Enum.TextXAlignment.Left; input.ClipsDescendants = true; input.Parent = bar
                input.Focused:Connect(function() barStroke.Color = T.silver2 end)
                -- botao Enviar com icone
                local sendBtn = button(bar, "Send", UDim2.new(0,88,1,-8), UDim2.new(1,-94,0,4), Color3.new(1,1,1))
                corner(sendBtn,6); sendBtn.Text = ""
                local sIco = Instance.new("ImageLabel"); sIco.BackgroundTransparency = 1; sIco.Size = UDim2.new(0,14,0,14); sIco.Position = UDim2.new(0,10,.5,-7); sIco.ImageColor3 = T.darkText; sIco.Parent = sendBtn
                local sTxt = Instance.new("TextLabel"); sTxt.BackgroundTransparency = 1; sTxt.Position = UDim2.new(0,30,0,0); sTxt.Size = UDim2.new(1,-34,1,0); sTxt.Font = Enum.Font.GothamBold; sTxt.TextSize = 12
                sTxt.TextColor3 = T.darkText; sTxt.TextXAlignment = Enum.TextXAlignment.Left; sTxt.Parent = sendBtn
                local lblSend, lblSent = cc.SendText or (isPT and "Enviar" or "Send"), (isPT and "Enviado" or "Sent")
                local function setSendState(sent)
                    local img = icon(sent and "check" or "send")
                    sIco.Image = img; sIco.Visible = img ~= ""
                    local t = sent and lblSent or lblSend
                    sTxt.Text = (img == "") and ((sent and "✓ " or "➤ ") .. t) or t
                    sTxt.Position = UDim2.new(0, img ~= "" and 30 or 10, 0, 0)
                end
                setSendState(false)

                local ctrl, hist, seq, typingWrap, busy = {}, {}, 0, nil, false
                local saveOn = cc.SaveHistory == true
                local FILE = _G.__OrionPath("Chat", "History.json", "OrionHub_AI_Chat.json")
                local userName = (lp and ((lp.DisplayName ~= "" and lp.DisplayName) or lp.Name)) or "Você"
                local userThumb = lp and ("rbxthumb://type=AvatarHeadShot&id=" .. tostring(lp.UserId) .. "&w=100&h=100") or ""
                local function persist()
                    if not saveOn or type(writefile) ~= "function" then return end
                    pcall(function()
                        local out = {}
                        for i = math.max(1, #hist - 39), #hist do out[#out+1] = hist[i] end
                        writefile(FILE, game:GetService("HttpService"):JSONEncode(out))
                    end)
                end
                local function toBottom()
                    task.delay(.06, function() if scroll and scroll.Parent then scroll.CanvasPosition = Vector2.new(0, 1e6) end end)
                end
                local textLimits = {}
                local function maxTextW()
                    local w = scroll.AbsoluteSize.X
                    if w <= 0 then w = 360 end
                    return math.max(90, w - 38 - 20 - 20 - 10)
                end
                scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                    local mw = maxTextW()
                    for i = #textLimits, 1, -1 do
                        local tc = textLimits[i]
                        if tc and tc.Parent then tc.MaxSize = Vector2.new(mw, math.huge) else table.remove(textLimits, i) end
                    end
                end)
                local function bubble(role, text, code)
                    seq = seq + 1
                    local isUser = role == "user"
                    local wrap = Instance.new("Frame"); wrap.Name = "Msg"; wrap.BackgroundTransparency = 1; wrap.Size = UDim2.new(1,0,0,0); wrap.AutomaticSize = Enum.AutomaticSize.Y; wrap.LayoutOrder = seq; wrap.Parent = scroll
                    -- avatar (foto do jogador / icone da IA)
                    local av = Instance.new("Frame"); av.Size = UDim2.new(0,28,0,28); av.BackgroundColor3 = T.field; av.BorderSizePixel = 0; av.ClipsDescendants = true
                    av.AnchorPoint = Vector2.new(isUser and 1 or 0, 0); av.Position = UDim2.new(isUser and 1 or 0, 0, 0, 0); av.Parent = wrap
                    corner(av,14); stroke(av, T.silver2, .5, 1)
                    local avImg = Instance.new("ImageLabel"); avImg.BackgroundTransparency = 1; avImg.BorderSizePixel = 0; avImg.Parent = av
                    if isUser then
                        avImg.Size = UDim2.new(1,0,1,0); avImg.Image = userThumb; avImg.ScaleType = Enum.ScaleType.Crop
                    else
                        avImg.Size = UDim2.new(0,16,0,16); avImg.AnchorPoint = Vector2.new(.5,.5); avImg.Position = UDim2.new(.5,0,.5,0)
                        avImg.Image = icon("bot"); avImg.ImageColor3 = T.silver; avImg.ScaleType = Enum.ScaleType.Fit
                    end
                    local col = Instance.new("Frame"); col.BackgroundTransparency = 1; col.Size = UDim2.new(1,-38,0,0); col.AutomaticSize = Enum.AutomaticSize.Y
                    col.Position = UDim2.new(0, isUser and 0 or 38, 0, 0); col.Parent = wrap
                    local cl = Instance.new("UIListLayout"); cl.Padding = UDim.new(0,3); cl.SortOrder = Enum.SortOrder.LayoutOrder; cl.Parent = col
                    local nm = Instance.new("TextLabel"); nm.BackgroundTransparency = 1; nm.Size = UDim2.new(1,0,0,14); nm.Font = Enum.Font.GothamBold; nm.TextSize = 11
                    nm.TextColor3 = isUser and T.white or T.silver; nm.Text = isUser and userName or "Orion AI"; nm.TextXAlignment = isUser and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left; nm.LayoutOrder = 1; nm.Parent = col
                    local hasCode = code and code ~= ""
                    local holder = Instance.new("Frame"); holder.BackgroundTransparency = 1; holder.Size = UDim2.new(1,0,0,0); holder.AutomaticSize = Enum.AutomaticSize.Y; holder.LayoutOrder = 2; holder.Parent = col
                    local b = Instance.new("Frame"); b.BorderSizePixel = 0; b.Parent = holder
                    b.BackgroundColor3 = isUser and T.field or T.header
                    b.AnchorPoint = Vector2.new(isUser and 1 or 0, 0); b.Position = UDim2.new(isUser and 1 or 0, 0, 0, 0)
                    if hasCode then
                        b.Size = UDim2.new(1,0,0,0); b.AutomaticSize = Enum.AutomaticSize.Y
                    else
                        b.Size = UDim2.new(0,0,0,0); b.AutomaticSize = Enum.AutomaticSize.XY
                    end
                    corner(b,8); stroke(b, isUser and T.silver2 or T.border, .5, 1)
                    local pad = Instance.new("UIPadding"); pad.PaddingTop = UDim.new(0,7); pad.PaddingBottom = UDim.new(0,7); pad.PaddingLeft = UDim.new(0,10); pad.PaddingRight = UDim.new(0,10); pad.Parent = b
                    local bl = Instance.new("UIListLayout"); bl.Padding = UDim.new(0,6); bl.SortOrder = Enum.SortOrder.LayoutOrder; bl.Parent = b
                    local t = Instance.new("TextLabel"); t.Name = "Text"; t.BackgroundTransparency = 1; t.TextWrapped = true
                    if hasCode then t.Size = UDim2.new(1,0,0,0); t.AutomaticSize = Enum.AutomaticSize.Y
                    else
                        t.Size = UDim2.new(0,0,0,0); t.AutomaticSize = Enum.AutomaticSize.XY
                        local tc = Instance.new("UISizeConstraint"); tc.MaxSize = Vector2.new(maxTextW(), math.huge); tc.Parent = t
                        textLimits[#textLimits+1] = tc
                    end
                    t.Font = Enum.Font.Gotham; t.TextSize = 13; t.TextColor3 = T.white; t.TextXAlignment = Enum.TextXAlignment.Left; t.TextYAlignment = Enum.TextYAlignment.Top
                    t.Text = tostring(text or ""); t.LayoutOrder = 1; t.Parent = b
                    if hasCode then
                        local cf = Instance.new("Frame"); cf.Size = UDim2.new(1,0,0,0); cf.AutomaticSize = Enum.AutomaticSize.Y; cf.BackgroundColor3 = Color3.fromRGB(14,14,18); cf.BorderSizePixel = 0; cf.LayoutOrder = 2; cf.Parent = b
                        corner(cf,6); stroke(cf,T.border,.2,1)
                        local cp = Instance.new("UIPadding"); cp.PaddingTop = UDim.new(0,6); cp.PaddingBottom = UDim.new(0,6); cp.PaddingLeft = UDim.new(0,8); cp.PaddingRight = UDim.new(0,8); cp.Parent = cf
                        local ct = Instance.new("TextLabel"); ct.BackgroundTransparency = 1; ct.Size = UDim2.new(1,0,0,0); ct.AutomaticSize = Enum.AutomaticSize.Y; ct.TextWrapped = true
                        ct.Font = Enum.Font.Code; ct.TextSize = 12; ct.TextColor3 = T.silver; ct.TextXAlignment = Enum.TextXAlignment.Left; ct.TextYAlignment = Enum.TextYAlignment.Top
                        local shown = tostring(code); if #shown > 700 then shown = shown:sub(1,700) .. "\n..." end
                        ct.Text = shown; ct.Parent = cf
                        local br = Instance.new("Frame"); br.Size = UDim2.new(1,0,0,28); br.BackgroundTransparency = 1; br.LayoutOrder = 3; br.Parent = b
                        local function mk(txt, x, bg, fg)
                            local btn = button(br, txt, UDim2.new(.5,-3,1,0), UDim2.new(x,x == 0 and 0 or 3,0,0), bg)
                            corner(btn,6); btn.Text = txt; btn.Font = Enum.Font.GothamBold; btn.TextSize = 12; btn.TextColor3 = fg
                            return btn
                        end
                        local cpB = mk(isPT and "Copiar" or "Copy", 0, T.field, T.silver); stroke(cpB,T.border,0,1)
                        local exB = mk(isPT and "Executar" or "Run", .5, Color3.new(1,1,1), T.darkText)
                        bindTap(cpB, function()
                            local ok = copyText(code)
                            cpB.Text = ok and (isPT and "Copiado" or "Copied") or (isPT and "Erro" or "Error")
                            task.delay(1.5, function() if cpB.Parent then cpB.Text = isPT and "Copiar" or "Copy" end end)
                        end)
                        bindTap(exB, function() if cc.OnExecute then task.spawn(cc.OnExecute, code) end end)
                    end
                    toBottom()
                    return wrap, t
                end
                local function removeTyping() if typingWrap then typingWrap:Destroy(); typingWrap = nil end end
                function ctrl:AddUserMessage(text) bubble("user", text); hist[#hist+1] = {role="user", text=tostring(text)}; persist() end
                function ctrl:AddAIMessage(text, code) removeTyping(); bubble("ai", text, code); hist[#hist+1] = {role="ai", text=tostring(text or ""), code=code}; persist() end
                function ctrl:Clear()
                    removeTyping(); hist = {}
                    for _, c in ipairs(scroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
                    if type(delfile) == "function" and type(isfile) == "function" then pcall(function() if isfile(FILE) then delfile(FILE) end end) end
                end
                function ctrl:SetSaveHistory(v)
                    saveOn = v and true or false
                    if saveOn then persist()
                    elseif type(delfile) == "function" and type(isfile) == "function" then pcall(function() if isfile(FILE) then delfile(FILE) end end) end
                end
                local loaded = false
                if saveOn and type(isfile) == "function" and type(readfile) == "function" then
                    pcall(function()
                        if isfile(FILE) then
                            local data = game:GetService("HttpService"):JSONDecode(readfile(FILE))
                            for _, m in ipairs(data) do bubble(m.role, m.text, m.code); hist[#hist+1] = m; loaded = true end
                        end
                    end)
                end
                if not loaded and cc.WelcomeMessage and cc.WelcomeMessage ~= "" then bubble("ai", cc.WelcomeMessage) end
                local function send()
                    local txt = input.Text:match("^%s*(.-)%s*$") or ""
                    if txt == "" or busy then return end
                    input.Text = ""; ctrl:AddUserMessage(txt); busy = true
                    setSendState(true); task.delay(1.2, function() setSendState(false) end)
                    local tw, tt = bubble("ai", isPT and "Pensando." or "Thinking.")
                    typingWrap = tw
                    task.spawn(function()
                        local n = 0
                        while typingWrap == tw and tw.Parent do
                            n = n % 3 + 1
                            tt.Text = (isPT and "Pensando" or "Thinking") .. string.rep(".", n)
                            task.wait(.4)
                        end
                    end)
                    task.spawn(function()
                        local before = #hist
                        local ok, err = true, nil
                        if cc.OnSend then ok, err = pcall(cc.OnSend, txt, ctrl) end
                        if not ok then
                            ctrl:AddAIMessage((isPT and "Erro ao processar: " or "Error: ") .. tostring(err))
                        elseif #hist == before then
                            ctrl:AddAIMessage(isPT and "A IA não retornou resposta. Tente novamente." or "The AI returned no response. Try again.")
                        end
                        removeTyping(); busy = false
                    end)
                end
                input.FocusLost:Connect(function(enter) barStroke.Color = T.border; if enter then send() end end)
                bindTap(sendBtn, send)
                return ctrl
            end
            function section:AddColorPicker(v) return section:AddButton(v) end
            return section
        end
        function item:AddCategory(name) return item:AddSection(name,false) end
        return item
    end
    function window:RegisterFloat(float) window._float=float; closeHooks.float=float end
    function window:DestroyGui() if screen then screen:Destroy() end end
    function window:SetTheme() end
    function window:GetThemes() return {"Orion Studios"} end
    function window:GetThemeColor() return T.bg end
    function window:SetAccentColor() end
    function window:SetTransparency() end
    function window:LibSettings() end

    -- Keep the familiar API's configuration version and neutral accent.
    return window
end

function OrionLib:FloatBtn(cfg)
    cfg=cfg or {}
    local screen=Instance.new("ScreenGui"); screen.Name="OrionStudios_Float"; screen.ResetOnSpawn=false; screen.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; pcall(function() screen.DisplayOrder=2147483647; screen.IgnoreGuiInset=true end)
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(screen) end; screen.Parent=(gethui and gethui()) or CoreGui end)
    if not screen.Parent then pcall(function() screen.Parent=Players.LocalPlayer:WaitForChild("PlayerGui") end) end
    local main=cfg.MainHolder
    local sz=tonumber(cfg.Size) or 46
    local frame=Instance.new("Frame"); frame.Name="FloatButton"; frame.Size=UDim2.new(0,sz,0,sz); frame.Position=UDim2.new(0,18,.5,-sz/2)
    pcall(function() -- nasce encostado na lateral da interface
        if main and main.Parent and main.AbsoluteSize.X > 0 then
            local inset = game:GetService("GuiService"):GetGuiInset()
            local x = math.max(8, main.AbsolutePosition.X - sz - 10)
            frame.Position = UDim2.new(0, x, 0, main.AbsolutePosition.Y + inset.Y + main.AbsoluteSize.Y / 2 - sz / 2)
        end
    end)
    frame.BackgroundColor3=T.bg; frame.BorderSizePixel=0; frame.Parent=screen; corner(frame,13); stroke(frame,T.silver2,.15,1.5)
    local image=Instance.new("ImageLabel"); image.Name="Logo"; image.Size=UDim2.new(1,-10,1,-10); image.Position=UDim2.new(0,5,0,5); image.BackgroundTransparency=1; image.Image=cfg.Icon or "rbxassetid://106423297301247"; image.ScaleType=Enum.ScaleType.Fit; image.Parent=frame
    local hit=button(frame,"FloatHit",UDim2.new(1,0,1,0),UDim2.new(),Color3.new()); hit.BackgroundTransparency=1
    -- o botao de hit cobre o frame, entao o arrasto precisa ser ligado nele
    local startPos, dragged = nil, false
    hit.InputBegan:Connect(function(io)
        if io.UserInputType==Enum.UserInputType.MouseButton1 or io.UserInputType==Enum.UserInputType.Touch then startPos=io.Position; dragged=false end
    end)
    UserInputService.InputChanged:Connect(function(io)
        if startPos and (io.UserInputType==Enum.UserInputType.MouseMovement or io.UserInputType==Enum.UserInputType.Touch) then
            if (io.Position-startPos).Magnitude>6 then dragged=true end
        end
    end)
    UserInputService.InputEnded:Connect(function(io)
        if io.UserInputType==Enum.UserInputType.MouseButton1 or io.UserInputType==Enum.UserInputType.Touch then startPos=nil end
    end)
    draggable(hit,frame)
    hit.ZIndex = 5
    bindTap(hit, function()
        if dragged then dragged=false; return end
        if main and main.Parent then main.Visible=not main.Visible elseif cfg.Callback then pcall(cfg.Callback) end
    end)
    return {Destroy=function() screen:Destroy() end,SetIcon=function(_,v) image.Image=icon(v)~="" and icon(v) or v end,SetColor=function(_,v) local st=frame:FindFirstChildOfClass("UIStroke"); if st then st.Color=v end end}
end

local notifyGui, notifyList
function OrionLib:MakeNotify(cfg)
    cfg = cfg or {}
    local t = tostring(cfg.Type or ""):lower()
    if t == "warn" or t == "info" or t == "loading" then t = "warning" end
    if t == "err" or t == "fail" then t = "error" end
    if t ~= "success" and t ~= "error" and t ~= "warning" then
        local c = cfg.Color
        if typeof(c) == "Color3" then
            local r, g, b = c.R * 255, c.G * 255, c.B * 255
            if r > 200 and g < 150 and b < 150 then t = "error"
            elseif g > r + 15 and g >= b then t = "success"
            elseif math.abs(r - g) < 20 and math.abs(g - b) < 20 then t = "success"
            else t = "warning" end
        else
            t = "warning"
        end
    end
    Bell.push(t, cfg.Title or "Orion Studios", cfg.Content or cfg.Description or cfg.Text or "")
    return { Close = function() end }
end

OrionLib.LibVersion = 8
_G.OrionLib=OrionLib
_G.WinUILib=OrionLib
_G.LucideIcons=Icons
if type(shared)=="table" then shared.OrionLib=OrionLib end
return OrionLib
