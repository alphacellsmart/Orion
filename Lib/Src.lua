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
  ORION HUB | WINUI REPLACEMENT
  Nueva interfaz completa: ventana compacta con header, sidebar, páginas y cards
  en negro/grafito/prata, inspirada en el panel Orion Hub.
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
    accent = Color3.fromRGB(16, 185, 129),
    accentSoft = Color3.fromRGB(52, 211, 153),
    accentDim = Color3.fromRGB(6, 95, 70),
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
            io.Changed:Connect(function()
                if io.UserInputState == Enum.UserInputState.End then
                    held = false
                    if target.Name == "MainHolder" then
                        task.delay(.1, function()
                            pcall(function()
                                local fl = _G.__OrionFloatFrame
                                if not (fl and fl.Parent and target.Parent) then return end
                                local inset = game:GetService("GuiService"):GetGuiInset()
                                local ts, fs, fp = target.AbsoluteSize, fl.AbsoluteSize, fl.AbsolutePosition
                                for _, dy in ipairs({inset.Y, 0}) do
                                    local tp = target.AbsolutePosition + Vector2.new(0, dy)
                                    if fp.X < tp.X + ts.X and fp.X + fs.X > tp.X and fp.Y < tp.Y + ts.Y and fp.Y + fs.Y > tp.Y then
                                        game:GetService("TweenService"):Create(target, TweenInfo.new(.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(.5, 0, .5, 0)}):Play()
                                        return
                                    end
                                end
                            end)
                        end)
                    end
                    task.defer(function()
                        pcall(function()
                            local sg = target:FindFirstAncestorOfClass("ScreenGui")
                            if not sg or target.Name == "FloatButton" then return end
                            local vp, ap, sz, m = sg.AbsoluteSize, target.AbsolutePosition, target.AbsoluteSize, 6
                            local cx = math.clamp(ap.X, m, math.max(m, vp.X - sz.X - m))
                            local cy = math.clamp(ap.Y, m, math.max(m, vp.Y - sz.Y - m))
                            if math.abs(cx - ap.X) > .5 or math.abs(cy - ap.Y) > .5 then
                                local p = target.Position
                                game:GetService("TweenService"):Create(target, TweenInfo.new(.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                                    {Position = UDim2.new(p.X.Scale, p.X.Offset + (cx - ap.X), p.Y.Scale, p.Y.Offset + (cy - ap.Y))}):Play()
                            end
                        end)
                    end)
                end
            end)
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

-- efeito de clique: camada escura por cima do botao + contorno branco (ou verde se o botao esta verde) que segue o estado em tempo real.
-- Nao mexe na cor real do botao nem na espessura do contorno original, entao nao tem como "ficar preto" ou grosso.
local function pressFx(btn)
    local GREEN_C = Color3.fromRGB(46, 204, 113)
    local ov = Instance.new("Frame")
    ov.Name = "PressFx"; ov.Size = UDim2.new(1, 0, 1, 0); ov.BackgroundColor3 = Color3.new(0, 0, 0)
    ov.BackgroundTransparency = 1; ov.BorderSizePixel = 0; ov.Active = false; ov.ZIndex = btn.ZIndex; ov.Parent = btn
    local cr = btn:FindFirstChildOfClass("UICorner")
    local oc = Instance.new("UICorner"); oc.CornerRadius = cr and cr.CornerRadius or UDim.new(0, 8); oc.Parent = ov
    local ovs = Instance.new("UIStroke")
    ovs.Thickness = 1; ovs.Transparency = 1; ovs.Color = Color3.new(1, 1, 1)
    ovs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; ovs.Parent = ov
    local down, running, tw1, tw2 = false, false, nil, nil
    local function stateColor()
        local c = btn.BackgroundColor3
        if c.G > c.R + .2 and c.G > c.B + .2 then return GREEN_C end
        return Color3.new(1, 1, 1)
    end
    local function loop()
        if running then return end
        running = true
        task.spawn(function()
            while btn.Parent and (down or ovs.Transparency < .99) do
                ovs.Color = stateColor(); task.wait()
            end
            running = false
        end)
    end
    local function press()
        if down then return end
        down = true
        if tw1 then tw1:Cancel() end; if tw2 then tw2:Cancel() end
        ovs.Color = stateColor(); ovs.Transparency = 0
        tw1 = TweenService:Create(ov, TweenInfo.new(.08), {BackgroundTransparency = .68}); tw1:Play()
        loop()
    end
    local function release()
        if not down then return end
        down = false
        task.delay(.12, function()
            if down or not btn.Parent then return end
            tw1 = TweenService:Create(ov, TweenInfo.new(.2), {BackgroundTransparency = 1}); tw1:Play()
            tw2 = TweenService:Create(ovs, TweenInfo.new(.2), {Transparency = 1}); tw2:Play()
        end)
    end
    btn.MouseButton1Down:Connect(press)
    btn.MouseButton1Up:Connect(release)
    btn.MouseLeave:Connect(release)
    UserInputService.InputEnded:Connect(function(io)
        if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then release() end
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

-- bolinha desliza para o lado com "quique" (passa um pouco do ponto e volta), ao ligar e ao desligar
local function slideTo(obj, target)
    pcall(function()
        TweenService:Create(obj, TweenInfo.new(.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = target}):Play()
    end)
end

local OrionLib = { Icons = Icons, GetIcon = icon, Copy = copyText, BindTap = bindTap }
-- ocultar nome do jogador (olho): estado compartilhado entre o perfil da sidebar e o Home
OrionLib._nameCbs = {}
OrionLib._toggles = {}
OrionLib.HideName = false
pcall(function() OrionLib.HideName = (_G.__OrionSecGet("__hideName") == true) end)
OrionLib.MaskText = function(t, maxLen)
    t = tostring(t or "")
    return string.rep("\226\128\162", math.clamp(utf8.len(t) or #t, 4, maxLen or 12))
end
OrionLib.SetHideName = function(v)
    OrionLib.HideName = v and true or false
    pcall(function() _G.__OrionSecSet("__hideName", OrionLib.HideName) end)
    for _, f in ipairs(OrionLib._nameCbs) do pcall(f, OrionLib.HideName) end
end
-- registra um TextLabel cujo texto fica "borrado" quando o nome esta oculto
OrionLib.BindNameLabel = function(lbl, prefix, maxLen)
    prefix = prefix or ""
    local real = lbl.Text
    local trunc = lbl.TextTruncate
    local function apply(h)
        if not lbl.Parent then return end
        -- oculto: sem "..." (so as bolinhas); visivel: volta o truncamento normal
        lbl.TextTruncate = h and Enum.TextTruncate.None or trunc
        lbl.ClipsDescendants = h and true or false
        lbl.Text = h and (prefix .. OrionLib.MaskText(real:sub(#prefix + 1), maxLen)) or real
    end
    table.insert(OrionLib._nameCbs, apply)
    apply(OrionLib.HideName)
end

-- ===== PROTECAO: o jogo nao consegue remover/esconder a interface nem os efeitos do hub =====
do
    local genv = (type(getgenv) == "function" and getgenv()) or _G
    local reg = genv.__OrionProt
    if not reg then reg = setmetatable({}, {__mode = "k"}); genv.__OrionProt = reg end
    OrionLib.Protect = function(inst) if inst then reg[inst] = true end return inst end
    if not genv.__OrionHooked and hookmetamethod and checkcaller and getnamecallmethod and newcclosure then
        local okH = pcall(function()
            local function isProt(o)
                if typeof(o) ~= "Instance" then return false end
                for _ = 1, 20 do
                    if reg[o] then return true end
                    o = o.Parent
                    if not o then return false end
                end
                return false
            end
            local oldNC
            oldNC = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                local m = getnamecallmethod()
                if (m == "Destroy" or m == "Remove" or m == "ClearAllChildren") and not checkcaller() then
                    if m ~= "ClearAllChildren" then
                        if isProt(self) then return end
                    else
                        local ok, kids = pcall(function() return self:GetChildren() end)
                        local has = false
                        if ok then for _, c in ipairs(kids) do if reg[c] then has = true; break end end end
                        if has then
                            for _, c in ipairs(kids) do if not reg[c] then pcall(function() c:Destroy() end) end end
                            return
                        end
                        setnamecallmethod(m)
                    end
                end
                return oldNC(self, ...)
            end))
            local oldNI
            oldNI = hookmetamethod(game, "__newindex", newcclosure(function(self, k, v)
                if reg[self] and not checkcaller() then
                    if k == "Parent" or ((k == "Enabled" or k == "Disabled") and (v == false or v == true) and ((k == "Enabled" and v == false) or (k == "Disabled" and v == true))) then
                        return
                    end
                end
                return oldNI(self, k, v)
            end))
        end)
        genv.__OrionHooked = okH and true or nil
    end
end

function OrionLib.KillBlur()
    pcall(function()
        for _, o in ipairs(game:GetService("Lighting"):GetChildren()) do
            if o.Name == "OrionStudios_Blur" then o:Destroy() end
        end
    end)
end
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
    local titleText = cfg.Title or "Orion Hub"
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
    OrionLib.Protect(screen)
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
    -- VIGIA: impede a interface de sumir (jogo/anti-cheat/limpeza do executor)
    task.spawn(function()
        while true do
            task.wait(0.5)
            if screen:GetAttribute("OrionClosing") then break end
            pcall(function()
                if not screen.Enabled then screen.Enabled = true end
                if screen.DisplayOrder ~= 2147483646 then screen.DisplayOrder = 2147483646 end
                local want = (gethui and gethui()) or CoreGui
                if screen.Parent == nil or (screen.Parent ~= want and screen.Parent ~= Players.LocalPlayer:FindFirstChild("PlayerGui")) then
                    local ok = pcall(function() screen.Parent = want end)
                    if not ok or not screen.Parent then
                        pcall(function() screen.Parent = Players.LocalPlayer:WaitForChild("PlayerGui", 3) end)
                    end
                end
            end)
        end
    end)

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
            blur = Instance.new("BlurEffect"); blur.Name = "OrionStudios_Blur"; OrionLib.Protect(blur); blur.Size = 0; blur.Parent = Lighting
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
                if not screen.Parent then break end
                pcall(function()
                    local L = game:GetService("Lighting")
                    local fix = false
                    if not blur or not blur.Parent then
                        blur = Instance.new("BlurEffect"); blur.Name = "OrionStudios_Blur"; OrionLib.Protect(blur); blur.Size = 0; blur.Parent = L; fix = true
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
    local outline = stroke(holder, T.accent, 0.55, 1.2)
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
    stroke(logoFrame, T.accent, 0.4, 1)
    local logo = Instance.new("ImageLabel")
    logo.Size = UDim2.new(1, -6, 1, -6)
    logo.Position = UDim2.new(0, 3, 0, 3)
    logo.BackgroundTransparency = 1
    logo.Image = "rbxassetid://7733960981"
    logo.ScaleType = Enum.ScaleType.Fit
    logo.Parent = logoFrame

    local title = label(header, titleText, 14, T.white, Enum.Font.GothamBold)
    title.Name = "WindowTitle"
    title.Position = UDim2.new(0, 56, 0, 6)
    title.Size = UDim2.new(1, -190, 0, 20)
    title.TextTruncate = Enum.TextTruncate.AtEnd
    local brand = label(header, "ORION HUB", 9, T.muted, Enum.Font.GothamBold)
    brand.Position = UDim2.new(0, 57, 0, 27)
    brand.Size = UDim2.new(0, 210, 0, 14)
    brand.TextXAlignment = Enum.TextXAlignment.Left

    -- destaque durante o clique: escurece o fundo e mantem o botao claro (usado em minimizar e na seta)
    local function pressDim(btn, pos)
        btn.InputBegan:Connect(function(io)
            if io.UserInputType ~= Enum.UserInputType.MouseButton1 and io.UserInputType ~= Enum.UserInputType.Touch then return end
            if holder:FindFirstChild("PressDim") or holder:FindFirstChild("CloseConfirm") then return end
            local src
            for _, d in ipairs(btn:GetDescendants()) do if d:IsA("ImageLabel") then src = d; break end end
            local ov = Instance.new("Frame"); ov.Name = "PressDim"; ov.Size = UDim2.new(1, 0, 1, 0); ov.BackgroundColor3 = Color3.new(0, 0, 0)
            ov.BackgroundTransparency = 1; ov.BorderSizePixel = 0; ov.ZIndex = 190; ov.Active = false; ov.Parent = holder; corner(ov, 14)
            TweenService:Create(ov, TweenInfo.new(.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = .3}):Play()
            local cp = Instance.new("Frame"); cp.Size = UDim2.new(0, 28, 0, 28); cp.Position = pos; cp.BackgroundColor3 = T.panel
            cp.BorderSizePixel = 0; cp.ZIndex = 191; cp.Active = false; cp.Parent = ov; corner(cp, 8); stroke(cp, T.silver2, .15, 1.2)
            if src then
                local im = Instance.new("ImageLabel"); im.Size = UDim2.new(0, 14, 0, 14); im.AnchorPoint = Vector2.new(.5, .5)
                im.Position = UDim2.new(.5, 0, .5, 0); im.BackgroundTransparency = 1; im.Image = src.Image; im.Rotation = src.Rotation
                im.ImageColor3 = T.white; im.ZIndex = 192; im.Parent = cp
            end
            local done = false
            local function release()
                if done then return end; done = true
                local tw = TweenService:Create(ov, TweenInfo.new(.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
                tw.Completed:Connect(function() pcall(function() ov:Destroy() end) end); tw:Play()
                cp.Visible = false
            end
            io.Changed:Connect(function() if io.UserInputState == Enum.UserInputState.End then release() end end)
            task.delay(4, release)
        end)
    end

    local minimize = button(header, "Minimize", UDim2.new(0, 28, 0, 28), UDim2.new(1, -72, 0, 12), T.panel)
    corner(minimize, 8); stroke(minimize, T.border, 0, 1)
    pressDim(minimize, UDim2.new(1, -72, 0, 12))
    local minIcon = Instance.new("ImageLabel")
    minIcon.Size = UDim2.new(0, 14, 0, 14); minIcon.AnchorPoint = Vector2.new(.5,.5)
    minIcon.Position = UDim2.new(.5,0,.5,0); minIcon.BackgroundTransparency = 1
    minIcon.Image = icon("minus"); minIcon.ImageColor3 = T.silver; minIcon.Parent = minimize
    local close = button(header, "Close", UDim2.new(0, 28, 0, 28), UDim2.new(1, -38, 0, 12), T.panel)
    corner(close, 8); stroke(close, T.border, 0, 1)
    pressDim(close, UDim2.new(1, -38, 0, 12))
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
        do -- botao X destacado (sem escurecer) para clicar e voltar
            local xc = button(ov, "XCopy", UDim2.new(0, 28, 0, 28), UDim2.new(1, -38, 0, 12), T.panel)
            xc.Text = ""; xc.ZIndex = 220; corner(xc, 8); stroke(xc, T.silver2, .15, 1.2)
            local xi = Instance.new("ImageLabel"); xi.Size = UDim2.new(0, 14, 0, 14); xi.AnchorPoint = Vector2.new(.5, .5)
            xi.Position = UDim2.new(.5, 0, .5, 0); xi.BackgroundTransparency = 1; xi.Image = icon("x"); xi.ImageColor3 = T.white; xi.ZIndex = 221; xi.Parent = xc
            bindTap(xc, function() ov:Destroy() end)
        end
        local cw = math.min(300, winW - 30)
        local card = Instance.new("Frame"); card.Name = "Card"
        card.AnchorPoint = Vector2.new(.5, .5); card.Position = UDim2.new(.5, 0, .5, 0)
        card.Size = UDim2.new(0, cw, 0, 150)
        card.BackgroundColor3 = Color3.fromRGB(14, 14, 18); card.BorderSizePixel = 0; card.ZIndex = 202; card.Parent = ov
        corner(card, 10); stroke(card, T.silver2, .45, 1.2)
        local cover = Instance.new("Frame"); cover.Name = "FadeCover"; cover.Size = UDim2.new(1, 0, 1, 0)
        cover.BackgroundColor3 = Color3.fromRGB(14, 14, 18); cover.BorderSizePixel = 0; cover.ZIndex = 210; cover.Active = false; cover.Parent = card
        corner(cover, 10)
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
            -- ao fechar a lib: desativa todos os toggles (ESP ... Configuracoes)
            for _, ctl in ipairs(OrionLib._toggles or {}) do
                pcall(function() if ctl.GetValue() then ctl:Set(false, true) end end)
            end
            pcall(function() if closeHooks.float and closeHooks.float.Destroy then closeHooks.float:Destroy() end end)
            pcall(function()
                local fl = screen.Parent and screen.Parent:FindFirstChild("OrionStudios_Float")
                if fl then fl:Destroy() end
            end)
            pcall(function() screen:SetAttribute("OrionClosing", true) end)
            screen:Destroy()
            OrionLib.KillBlur(); task.delay(.3, OrionLib.KillBlur); task.delay(1, OrionLib.KillBlur)
        end)
    end)
    -- sino de notificacoes (fica a esquerda do botao minimizar)
    do
        local bell = button(header, "Bell", UDim2.new(0, 28, 0, 28), UDim2.new(1, -106, 0, 12), T.panel)
        corner(bell, 8); stroke(bell, T.border, 0, 1)
        pressDim(bell, UDim2.new(1, -106, 0, 12))
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
        corner(pop, 10); stroke(pop, T.silver2, .45, 1.2)
        do -- fundo escurecido (igual ao do X) + contorno prateado com brilho girando
            local ls = Instance.new("UIStroke"); ls.Thickness = 1.6; ls.Color = Color3.new(1, 1, 1)
            ls.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; ls.Parent = pop
            local lg = Instance.new("UIGradient")
            lg.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(.30, 1), NumberSequenceKeypoint.new(.42, .35),
                NumberSequenceKeypoint.new(.50, 0), NumberSequenceKeypoint.new(.58, .35), NumberSequenceKeypoint.new(.70, 1),
                NumberSequenceKeypoint.new(1, 1),
            })
            lg.Parent = ls; lightGrads[#lightGrads + 1] = lg
            local dim = Instance.new("TextButton"); dim.Name = "NotifDim"; dim.Text = ""; dim.AutoButtonColor = false
            dim.Size = UDim2.new(1, 0, 1, 0); dim.BackgroundColor3 = Color3.new(0, 0, 0); dim.BackgroundTransparency = 1
            dim.BorderSizePixel = 0; dim.ZIndex = 49; dim.Visible = false; dim.Parent = holder; corner(dim, 14)
            dim.Activated:Connect(function() pop.Visible = false end)
            do -- sino destacado (sem escurecer) para clicar e voltar
                local bc = button(dim, "BellCopy", UDim2.new(0, 28, 0, 28), UDim2.new(1, -106, 0, 12), T.panel)
                bc.Text = ""; bc.ZIndex = 5; corner(bc, 8); stroke(bc, T.silver2, .15, 1.2)
                local bi2 = Instance.new("ImageLabel"); bi2.Size = UDim2.new(0, 14, 0, 14); bi2.AnchorPoint = Vector2.new(.5, .5)
                bi2.Position = UDim2.new(.5, 0, .5, 0); bi2.BackgroundTransparency = 1; bi2.Image = icon("bell"); bi2.ImageColor3 = T.white; bi2.ZIndex = 6; bi2.Parent = bc
                bindTap(bc, function() pop.Visible = false end)
            end
            pop:GetPropertyChangedSignal("Visible"):Connect(function()
                if pop.Visible then
                    dim.Visible = true
                    TweenService:Create(dim, TweenInfo.new(.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = .3}):Play()
                else
                    dim.BackgroundTransparency = 1; dim.Visible = false
                end
            end)
        end
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
                sl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() task.defer(function() if scroll.Parent then scroll.CanvasPosition = Vector2.new(0, 1e6) end end) end)
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
                -- linha divisoria: ao marcar como lida ela se desenha da esquerda para a direita
                local dl = Instance.new("Frame"); dl.Name = "DivLine"; dl.BorderSizePixel = 0; dl.BackgroundColor3 = T.silver2; dl.BackgroundTransparency = .55
                dl.Position = UDim2.new(0, -14, 0, -6); dl.Size = Bell.animDiv and UDim2.new(0, 0, 0, 1) or UDim2.new(1, 28, 0, 1); dl.Parent = h
                if Bell.animDiv then
                    Bell.animDiv = false
                    TweenService:Create(dl, TweenInfo.new(.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 28, 0, 1)}):Play()
                end
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
                    local dot = Instance.new("Frame"); dot.Name = "UnreadDot"; dot.Size = UDim2.new(0, 8, 0, 8); dot.AnchorPoint = Vector2.new(1, .5)
                    dot.Position = UDim2.new(1, -12, .5, 0); dot.BackgroundColor3 = col; dot.BorderSizePixel = 0; dot.Parent = row; corner(dot, 4)
                end
                local hit = button(row, "Hit", UDim2.new(1, 0, 1, 0), UDim2.new(), Color3.new()); hit.BackgroundTransparency = 1; hit.Text = ""
                bindTap(hit, function() if n.read then return end n.read = true; Bell.animDiv = true; render() end)
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
        bindTap(readAll, function() for _, n in ipairs(Bell.items) do n.read = true end Bell.animDiv = true render() end)
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
        pill.BackgroundColor3 = T.silver2; pill.BackgroundTransparency = .25; pill.BorderSizePixel = 0; pill.ZIndex = 60; pill.Active = false; pill.Parent = mv; corner(pill, 3)
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
            bar.BackgroundColor3 = T.silver2; bar.BackgroundTransparency = .35; bar.BorderSizePixel = 0; bar.ZIndex = 61
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
    tabList.Size = UDim2.new(1, -14, 1, -100)
    tabList.Position = UDim2.new(0, 7, 0, 42)
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
    local SB = {W = 64, H = 38, HC = 56}
    local function iconPos() return collapsed and UDim2.new(.5, -14, 0, 5) or UDim2.new(0, 7, .5, -14) end
    function SB.labelPos(on)
        if collapsed then return UDim2.new(0, 2, 0, 36) end
        return UDim2.new(0, 40, 0, 0) -- mesma linha/posicao em todas as abas
    end
    do -- barra "Filtrar" acima da primeira aba
        local sf = Instance.new("Frame"); sf.Name = "TabFilter"
        sf.Size = UDim2.new(1, -14, 0, 28); sf.Position = UDim2.new(0, 7, 0, 8)
        sf.BackgroundColor3 = T.panel; sf.BorderSizePixel = 0; sf.Parent = sidebar
        corner(sf, 8); local sst = stroke(sf, T.border, .1, 1)
        local sx = 8
        local sImg = icon("search")
        if sImg ~= "" then
            local si = Instance.new("ImageLabel"); si.BackgroundTransparency = 1; si.Size = UDim2.new(0, 14, 0, 14)
            si.Position = UDim2.new(0, 8, .5, -7); si.Image = sImg; si.ImageColor3 = T.muted; si.Parent = sf
            sx = 28
        end
        local box = Instance.new("TextBox"); box.Name = "FilterBox"; box.BackgroundTransparency = 1
        box.Position = UDim2.new(0, sx, 0, 0); box.Size = UDim2.new(1, -(sx + 6), 1, 0)
        box.ClearTextOnFocus = false; box.Text = ""; box.PlaceholderText = (OrionLib.IsPT == false) and "Search" or "Pesquisar"
        box.PlaceholderColor3 = T.muted; box.TextColor3 = T.white; box.Font = Enum.Font.Gotham; box.TextSize = 12
        box.TextXAlignment = Enum.TextXAlignment.Left; box.ClipsDescendants = true; box.Parent = sf
        box.Focused:Connect(function() sst.Color = T.silver2 end)
        box.FocusLost:Connect(function() sst.Color = T.border end)
        SB.search, SB.box = sf, box
        function SB.applyFilter()
            local q = (box.Text or ""):lower():match("^%s*(.-)%s*$") or ""
            for _, tab in ipairs(tabs) do
                tab.button.Visible = (q == "") or (tostring(tab.Name):lower():find(q, 1, true) ~= nil)
            end
        end
        box:GetPropertyChangedSignal("Text"):Connect(SB.applyFilter)
    end
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
            TweenService:Create(tab.label, quick, {Position = SB.labelPos(on)}):Play()
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
        local pst = stroke(pf, T.silver2, .55, 1.2) -- contorno prateado igual ao da janela
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
        OrionLib.BindNameLabel(nm, nil, 7)
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
        pressDim(arrow, UDim2.new(1, -140, 0, 12))
        local arrowIco = Instance.new("ImageLabel"); arrowIco.Size = UDim2.new(0, 14, 0, 14); arrowIco.AnchorPoint = Vector2.new(.5, .5)
        arrowIco.Position = UDim2.new(.5, 0, .5, 0); arrowIco.BackgroundTransparency = 1; arrowIco.ImageColor3 = T.silver; arrowIco.Parent = arrow
        local function arrowSkin(c)
            local img = icon(c and "panel-left-open" or "panel-left-close")
            if img == "" then img = icon(c and "chevron-right" or "chevron-left") end
            arrowIco.Image = img
            if img == "" then arrow.Text = c and "\u{203A}" or "\u{2039}"; arrow.TextColor3 = T.silver; arrow.Font = Enum.Font.GothamBold; arrow.TextSize = 20 end
        end
        arrowSkin(false)
        local function applyCollapse(c, instant)
            collapsed = c
            local w = collapsed and SB.W or tabWidth
            local ti = TweenInfo.new(instant and 0 or .25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            TweenService:Create(sidebar, ti, {Size = UDim2.new(0, w, 1, -52)}):Play()
            TweenService:Create(content, ti, {Size = UDim2.new(1, -w, 1, -52), Position = UDim2.new(0, w, 0, 52)}):Play()
            arrowSkin(collapsed); profileSet(collapsed, ti)
            if collapsed then pcall(function() SB.box.Text = "" end) end
            pcall(function() SB.search.Visible = not collapsed end)
            TweenService:Create(tabList, ti, {
                Position = collapsed and UDim2.new(0, 7, 0, 10) or UDim2.new(0, 7, 0, 42),
                Size = collapsed and UDim2.new(1, -14, 1, -68) or UDim2.new(1, -14, 1, -100),
            }):Play()
            OrionLib.SidebarCollapsed = collapsed
            for _, f in ipairs(OrionLib._collapseCbs or {}) do pcall(f, collapsed) end
            for _, tab in ipairs(tabs) do
                if tab.relayout then tab.relayout(ti) end
            end
        end
        bindTap(arrow, function()
            applyCollapse(not collapsed)
            pcall(function() _G.__OrionSecSet("__sidebar", collapsed) end) -- salva o estado
        end)
        do -- restaura o estado salvo (icones com nome embaixo)
            local saved
            pcall(function() saved = _G.__OrionSecGet("__sidebar") end)
            if saved == true then applyCollapse(true, true) end
        end
    end

    function window:SelectTab(i) local it = tabs[i]; if it then pcall(setActive, it) end end
    function window:AddTab(tabCfg)
        tabCfg = tabCfg or {}
        local name = tabCfg.Name or ("Tab " .. (#tabs + 1))
        local item = { Name = name, IconName = tabCfg.Icon or "home" }
        local nav = button(tabList, "Nav_" .. name, UDim2.new(1, 0, 0, collapsed and SB.HC or SB.H), UDim2.new(), T.sidebar)
        nav.LayoutOrder = #tabs + 1
        corner(nav, 8)
        local navStroke = stroke(nav, T.silver2, .75, 1)
        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, 3, 0, 20); indicator.Position = UDim2.new(0, 2, .5, -10)
        indicator.BackgroundColor3 = T.white; indicator.BorderSizePixel = 0; indicator.Visible = false; indicator.Parent = nav
        corner(indicator, 2)
        local navIcon = Instance.new("ImageLabel")
        local tile = Instance.new("Frame"); tile.Name = "IconTile"
        tile.Size = UDim2.new(0, 28, 0, 28); tile.Position = iconPos()
        tile.BackgroundColor3 = Color3.fromRGB(5, 5, 7); tile.BorderSizePixel = 0; tile.Parent = nav
        corner(tile, 8); stroke(tile, T.silver2, .55, 1)
        navIcon.Size = UDim2.new(0, 16, 0, 16); navIcon.AnchorPoint = Vector2.new(.5, .5); navIcon.Position = UDim2.new(.5, 0, .5, 0)
        navIcon.BackgroundTransparency = 1; navIcon.Image = icon(tabCfg.Icon or "home"); navIcon.ImageColor3 = T.muted; navIcon.Parent = tile
        local navLabel = label(nav, name, 12, T.muted, Enum.Font.GothamMedium)
        navLabel.Position = UDim2.new(0, 40, 0, 0); navLabel.Size = UDim2.new(1, -46, 1, 0); navLabel.TextXAlignment = Enum.TextXAlignment.Left
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

        -- ===== efeito prateado (fundo cinza + contorno) em todos os cards da aba =====
        if tabCfg.Silver then
            local function dark(c) return c.R < .17 and c.G < .17 and c.B < .17 end
            local function style(o)
                if not o.Parent or o:GetAttribute("SilverFx") then return end
                if not (o:IsA("Frame") or o:IsA("TextButton") or o:IsA("ImageButton")) then return end
                if o.BackgroundTransparency > .5 or o.AbsoluteSize.Y < 22 or o.AbsoluteSize.X < 40 then return end
                if not o:FindFirstChildOfClass("UICorner") then return end
                if tabCfg.SilverSections then
                    local okS = false
                    for _, sn in ipairs(tabCfg.SilverSections) do if o.Name == "Section_" .. tostring(sn) then okS = true end end
                    if not okS then return end
                elseif not (o.Name:find("^Section_") or o.Name == "ScriptCard") then return end
                if o.Name == "BorderLight" or o.Name:find("Scroll") or o.Name == "Thumb" then return end
                o:SetAttribute("SilverFx", true)
                local c = o.BackgroundColor3
                if dark(c) then
                    local nc = Color3.fromRGB(math.floor(c.R * 255) + 10, math.floor(c.G * 255) + 10, math.floor(c.B * 255) + 12)
                    o.BackgroundColor3 = nc
                end
                local st
                for _, ch in ipairs(o:GetChildren()) do
                    if ch:IsA("UIStroke") and ch.Name ~= "BorderLight" and not ch:FindFirstChildOfClass("UIGradient") then st = ch; break end
                end
                if st then
                    st.Color = Color3.fromRGB(150, 150, 162); st.Transparency = math.min(st.Transparency, .45)
                    if st.Thickness < 1 then st.Thickness = 1 end
                elseif not o:FindFirstChildOfClass("UIStroke") then
                    local ns = Instance.new("UIStroke"); ns.Name = "SilverStroke"; ns.Thickness = 1; ns.Color = Color3.fromRGB(150, 150, 162)
                    ns.Transparency = .45; ns.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; ns.Parent = o
                end
            end
            local function queue(o) task.delay(.15, function() pcall(style, o) end) end
            page.DescendantAdded:Connect(queue)
            for _, o in ipairs(page:GetDescendants()) do queue(o) end
        end

        -- barra de rolagem propria: tamanho fixo (nao encolhe) e arrastavel (move rapido como no PC)
        do
            local THUMB = 46
            local track = Instance.new("Frame")
            track.Name = "ScrollTrack_" .. name; track.Size = UDim2.new(0, 8, 1, -46); track.Position = UDim2.new(1, -11, 0, 12)
            track.BackgroundColor3 = T.border; track.BackgroundTransparency = .55; track.BorderSizePixel = 0
            track.ZIndex = 40; track.Visible = false; track.Parent = content; corner(track, 4)
            local thumb = Instance.new("TextButton")
            thumb.Name = "Thumb"; thumb.Text = ""; thumb.AutoButtonColor = false; thumb.Size = UDim2.new(1, 0, 0, THUMB)
            thumb.BackgroundColor3 = T.silver2; thumb.BackgroundTransparency = .1; thumb.BorderSizePixel = 0; thumb.ZIndex = 41; thumb.Parent = track; corner(thumb, 4)
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
        item.relayout = function(ti)
            local on = (activeTab == item)
            if collapsed then
                navLabel.TextXAlignment = Enum.TextXAlignment.Center
                navLabel.TextSize = 9
                navLabel.Size = UDim2.new(1, -4, 0, 16)
            else
                navLabel.TextXAlignment = Enum.TextXAlignment.Left
                navLabel.TextSize = 12
                navLabel.Size = UDim2.new(1, -46, 1, 0)
            end
            TweenService:Create(nav, ti, {Size = UDim2.new(1, 0, 0, collapsed and SB.HC or SB.H)}):Play()
            TweenService:Create(navLabel, ti, {Position = SB.labelPos(on)}):Play()
            TweenService:Create(tile, ti, {Position = iconPos()}):Play()
        end
        if collapsed then item.relayout(TweenInfo.new(0)) end

        -- ===== efeitos da aba: hover, clique (squish), brilho e icone animado =====
        do
            nav.ClipsDescendants = true
            local navScale = Instance.new("UIScale"); navScale.Parent = nav
            local iconScale = Instance.new("UIScale"); iconScale.Parent = navIcon
            local shine = Instance.new("Frame")
            shine.Name = "Shine"; shine.Size = UDim2.new(0.35, 0, 1, 0); shine.Position = UDim2.new(-0.4, 0, 0, 0)
            shine.BackgroundColor3 = T.accent; shine.BackgroundTransparency = 0.8
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
        pcall(SB.applyFilter)
        bindTap(nav, function() setActive(item) end)
        if #tabs == 1 then setActive(item) end

        function item:BuildHome(cfg)
            cfg = cfg or {}
            -- ===== sub-abas lado a lado: Dashboard | Youtube =====
            local hostPage, dash = page, nil
            local SUB = {}
            do
            local subTabs = cfg.SubTabs or {"Dashboard", "Suporte"}
            local bar = Instance.new("Frame")
            bar.Size = UDim2.new(1, 0, 0, 38); bar.BackgroundColor3 = Color3.fromRGB(24, 24, 29); bar.BorderSizePixel = 0
            bar.LayoutOrder = -50; bar.Parent = hostPage; SUB.bar = bar
            corner(bar, 11); stroke(bar, T.border, .3, 1)
            local barPad = Instance.new("UIPadding"); barPad.PaddingTop = UDim.new(0, 4); barPad.PaddingBottom = UDim.new(0, 4)
            barPad.PaddingLeft = UDim.new(0, 4); barPad.PaddingRight = UDim.new(0, 4); barPad.Parent = bar
            local slider = Instance.new("Frame")
            slider.Size = UDim2.new(.5, 0, 1, 0); slider.BackgroundColor3 = Color3.fromRGB(44, 44, 52); slider.BorderSizePixel = 0; slider.Parent = bar
            corner(slider, 8); stroke(slider, T.silver2, .35, 1); SUB.slider = slider
            local function mkPage(order, vis)
                local f = Instance.new("Frame")
                f.Size = UDim2.new(1, 0, 0, 0); f.AutomaticSize = Enum.AutomaticSize.Y; f.BackgroundTransparency = 1
                f.BorderSizePixel = 0; f.LayoutOrder = order; f.Visible = vis; f.Parent = hostPage
                local l = Instance.new("UIListLayout"); l.Padding = UDim.new(0, 12); l.SortOrder = Enum.SortOrder.LayoutOrder; l.Parent = f
                return f
            end
            local ytPage
            dash, ytPage = mkPage(1, true), mkPage(2, false)
            local pagesBy = {dash, ytPage}
            local subBtns = {}
            local function selectSub(i)
                for k, b in ipairs(subBtns) do
                    pagesBy[k].Visible = (k == i)
                    local c = (k == i) and T.white or T.muted
                    TweenService:Create(b.lb, TweenInfo.new(.2), {TextColor3 = c}):Play()
                    if b.ic then TweenService:Create(b.ic, TweenInfo.new(.2), {ImageColor3 = c}):Play() end
                end
                TweenService:Create(slider, TweenInfo.new(.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new((i - 1) * .5, 0, 0, 0)}):Play()
            end
            local SUBICON = {{"layout-dashboard", "layout-grid", "home"}, {"headset", "life-buoy", "message-circle", "circle-help"}}
            for i, nm in ipairs(subTabs) do
                local b = Instance.new("TextButton")
                b.Size = UDim2.new(.5, 0, 1, 0); b.Position = UDim2.new((i - 1) * .5, 0, 0, 0); b.BackgroundTransparency = 1
                b.Text = ""; b.AutoButtonColor = false; b.ZIndex = 2; b.Parent = bar
                local col = (i == 1) and T.white or T.muted
                local row = Instance.new("Frame"); row.BackgroundTransparency = 1; row.AnchorPoint = Vector2.new(.5, .5)
                row.Position = UDim2.new(.5, 0, .5, 0); row.Size = UDim2.new(0, 0, 1, 0); row.AutomaticSize = Enum.AutomaticSize.X; row.ZIndex = 3; row.Parent = b
                local rl = Instance.new("UIListLayout"); rl.FillDirection = Enum.FillDirection.Horizontal; rl.Padding = UDim.new(0, 7)
                rl.VerticalAlignment = Enum.VerticalAlignment.Center; rl.SortOrder = Enum.SortOrder.LayoutOrder; rl.Parent = row
                local img
                for _, n in ipairs(SUBICON[i] or {}) do local ic = icon(n); if ic ~= "" then img = ic; break end end
                local icl
                if img then
                    icl = Instance.new("ImageLabel"); icl.Size = UDim2.new(0, 16, 0, 16); icl.BackgroundTransparency = 1; icl.Image = img
                    icl.ImageColor3 = col; icl.LayoutOrder = 1; icl.ZIndex = 3; icl.Parent = row
                end
                local lb = Instance.new("TextLabel"); lb.BackgroundTransparency = 1; lb.Text = nm; lb.Font = Enum.Font.GothamBold; lb.TextSize = 13
                lb.TextColor3 = col; lb.Size = UDim2.new(0, 0, 0, 16); lb.AutomaticSize = Enum.AutomaticSize.X; lb.LayoutOrder = 2; lb.ZIndex = 3; lb.Parent = row
                pcall(function() -- reflexo prateado no nome da sub-aba (Dashboard / Youtube)
                    local sg = Instance.new("UIGradient")
                    sg.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(150,150,162)),
                        ColorSequenceKeypoint.new(.5, Color3.fromRGB(255,255,255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(150,150,162))})
                    sg.Rotation = 20; sg.Offset = Vector2.new(-1,0); sg.Parent = lb
                    lightSheens[#lightSheens + 1] = sg
                end)
                b.Activated:Connect(function() selectSub(i) end)
                subBtns[i] = {btn = b, ic = icl, lb = lb}
            end
            -- ===== Chat de suporte com IA (dentro da sub-aba Suporte) =====
            do
                local ask = cfg.SupportFn
                local PANEL = Color3.fromRGB(23, 23, 28)
                local GRAY, GRAY_IC = Color3.fromRGB(58, 58, 66), Color3.fromRGB(120, 120, 132)
                local chat = Instance.new("Frame")
                chat.Name = "SupportChat"; chat.Size = UDim2.new(1, 0, 0, 410); chat.BackgroundColor3 = PANEL
                chat.BorderSizePixel = 0; chat.LayoutOrder = 1; chat.Parent = ytPage
                corner(chat, 14); stroke(chat, T.border, .3, 1)
                local head = label(chat, "Suporte com Inteligência Artificial", 14, T.white, Enum.Font.GothamBold)
                head.Position = UDim2.new(0, 40, 0, 10); head.Size = UDim2.new(1, -56, 0, 20)
                do
                    local aiI = ""
                    for _, n in ipairs({"sparkles", "bot", "brain", "message-circle"}) do local i0 = icon(n); if i0 ~= "" then aiI = i0; break end end
                    if aiI ~= "" then
                        local im = Instance.new("ImageLabel"); im.Size = UDim2.new(0, 18, 0, 18); im.Position = UDim2.new(0, 16, 0, 11)
                        im.BackgroundTransparency = 1; im.Image = aiI; im.ImageColor3 = T.white; im.Parent = chat
                    else
                        head.Position = UDim2.new(0, 16, 0, 10); head.Size = UDim2.new(1, -32, 0, 20)
                    end
                end
                local HSUB = "Olá! Seja muito bem-vindo! Estou aqui para ajudar e esclarecer qualquer dúvida que você tenha sobre os recursos, funcionalidades, utilização e planos disponíveis do script. Fique à vontade para perguntar!"
                local hsub = label(chat, HSUB, 11, T.muted, Enum.Font.Gotham)
                hsub.Position = UDim2.new(0, 16, 0, 32); hsub.Size = UDim2.new(1, -32, 0, 46); hsub.TextWrapped = true; hsub.TextYAlignment = Enum.TextYAlignment.Top

                local scroll = Instance.new("ScrollingFrame")
                scroll.Position = UDim2.new(0, 10, 0, 84); scroll.Size = UDim2.new(1, -20, 1, -142)
                scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 3
                scroll.ScrollBarImageColor3 = T.silver2; scroll.CanvasSize = UDim2.new(); scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; scroll.ElasticBehavior = Enum.ElasticBehavior.Never; scroll.ScrollingDirection = Enum.ScrollingDirection.Y
                scroll.Parent = chat
                -- quebra natural: segue a largura atual da skin; altura do texto se ajusta e a lista desce junto
                do
                    local TS = game:GetService("TextService")
                    local function fit()
                        local avail = chat.AbsoluteSize.X - 32
                        if avail < 60 then return end
                        local ok, v = pcall(function() return TS:GetTextSize(HSUB, hsub.TextSize, Enum.Font.Gotham, Vector2.new(avail, 10000)) end)
                        local h = (ok and v.Y or 46) + 2
                        hsub.Size = UDim2.new(1, -32, 0, h)
                        local top = 32 + h + 6
                        scroll.Position = UDim2.new(0, 10, 0, top)
                        scroll.Size = UDim2.new(1, -20, 1, -(top + 58))
                    end
                    chat:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
                    task.defer(fit)
                end
                local sl = Instance.new("UIListLayout"); sl.Padding = UDim.new(0, 8); sl.SortOrder = Enum.SortOrder.LayoutOrder; sl.Parent = scroll
                local msgN = 0
                local TextSvc = game:GetService("TextService")
                local shown, measures = {}, {}
                scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() for _, m in ipairs(measures) do pcall(m) end end)
local function mdConv(t)
                    t = tostring(t or ""):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
                    t = t:gsub("\n#+%s*([^\n]+)", "\n**%1**"):gsub("^#+%s*([^\n]+)", "**%1**")
                    t = t:gsub("\n%s*[%-%*]%s+", "\n• "):gsub("^%s*[%-%*]%s+", "• ")
                    t = t:gsub("%*%*(.-)%*%*", '<b><font color="#FFFFFF">%1</font></b>')
                    t = t:gsub("__(.-)__", "<u>%1</u>"):gsub("~~(.-)~~", "<s>%1</s>")
                    t = t:gsub("`([^`\n]+)`", '<font color="#8FD0FF">%1</font>')
                    t = t:gsub("%*([^%*\n]+)%*", "<i>%1</i>")
                    local plain = t:gsub("<[^>]+>", ""):gsub("&lt;", "<"):gsub("&gt;", ">"):gsub("&amp;", "&")
                    return t, plain
                end
                local function addMsg(text, isUser)
                    msgN = msgN + 1
                    local holder = Instance.new("Frame"); holder.Size = UDim2.new(1, -6, 0, 0); holder.AutomaticSize = Enum.AutomaticSize.Y
                    holder.BackgroundTransparency = 1; holder.BorderSizePixel = 0; holder.LayoutOrder = msgN; holder.Parent = scroll
                    local bub = Instance.new("Frame"); bub.Size = UDim2.new(.86, 0, 0, 0); bub.AutomaticSize = Enum.AutomaticSize.Y
                    bub.AnchorPoint = Vector2.new(isUser and 1 or 0, 0); bub.Position = UDim2.new(isUser and 1 or 0, 0, 0, 0)
                    bub.BackgroundColor3 = isUser and Color3.fromRGB(52, 52, 60) or Color3.fromRGB(32, 32, 38); bub.BorderSizePixel = 0; bub.Parent = holder
                    corner(bub, 10)
                    local pd = Instance.new("UIPadding"); pd.PaddingTop = UDim.new(0, 7); pd.PaddingBottom = UDim.new(0, 7)
                    pd.PaddingLeft = UDim.new(0, 11); pd.PaddingRight = UDim.new(0, 11); pd.Parent = bub
                    local tl = Instance.new("TextLabel"); tl.BackgroundTransparency = 1; tl.AutomaticSize = Enum.AutomaticSize.Y
                    tl.Size = UDim2.new(1, 0, 0, 0); tl.Font = Enum.Font.Gotham; tl.TextSize = 12
                    tl.TextColor3 = isUser and T.white or T.silver; tl.TextWrapped = true; tl.RichText = not isUser
                    tl.TextXAlignment = Enum.TextXAlignment.Left; tl.TextYAlignment = Enum.TextYAlignment.Top
                    local plainTxt, converting, lastRich = tostring(text or ""), false, nil
                    if not isUser then local r, pl = mdConv(text); lastRich = r; tl.Text = r; plainTxt = pl else tl.Text = plainTxt end
                    tl.Parent = bub
                    local function measure()
                        local avail = scroll.AbsoluteSize.X
                        if avail <= 0 then avail = 300 end
                        local maxW = math.max(120, math.floor((avail - 6) * .86) - 22)
                        local okb, sz = pcall(function() return TextSvc:GetTextSize(plainTxt, 12, Enum.Font.Gotham, Vector2.new(100000, 100000)) end)
                        if okb and sz.X + 14 < maxW and not plainTxt:find("\n") then bub.Size = UDim2.new(0, math.ceil(sz.X) + 14 + 22, 0, 0)
                        else bub.Size = UDim2.new(.86, 0, 0, 0) end
                    end
                    measure(); measures[#measures + 1] = measure
                    tl:GetPropertyChangedSignal("Text"):Connect(function()
                        if not isUser then
                            if tl.Text == lastRich then return end -- texto ja convertido (evita escapar &amp; de novo)
                            local r, pl = mdConv(tl.Text); lastRich = r; plainTxt = pl; tl.Text = r
                        else plainTxt = tl.Text end
                        measure()
                        task.defer(function() if scroll.Parent then scroll.CanvasPosition = Vector2.new(0, 1e6) end end)
                    end)
                    -- mantem poucas mensagens desenhadas para o scroll ficar leve
                    shown[#shown + 1] = holder
                    while #shown > 40 do local old = table.remove(shown, 1); table.remove(measures, 1); pcall(function() old:Destroy() end) end
                    task.defer(function() if scroll.Parent then scroll.CanvasPosition = Vector2.new(0, 1e6) end end)
                    return tl
                end
                -- ao abrir o chat, vai direto para a ultima mensagem
                task.spawn(function()
                    local was = false
                    while chat.Parent do
                        local shownNow, a = true, chat
                        while a and a:IsA("GuiObject") do if not a.Visible then shownNow = false end a = a.Parent end
                        if a and a:IsA("ScreenGui") and not a.Enabled then shownNow = false end
                        if shownNow and not was then
                            for _, d in ipairs({0, .05, .2, .5}) do
                                task.delay(d, function() if scroll.Parent then scroll.CanvasPosition = Vector2.new(0, 1e6) end end)
                            end
                        end
                        was = shownNow
                        task.wait(.3)
                    end
                end)
                local HSv = game:GetService("HttpService")
                local SAVE
                pcall(function() SAVE = _G.__OrionPath("Chat", "Support.json") end)
                local log = {}
                pcall(function()
                    if SAVE and isfile and isfile(SAVE) then
                        local d = HSv:JSONDecode(readfile(SAVE))
                        if type(d) == "table" then log = d end
                    end
                end)
                local function persist()
                    pcall(function()
                        while #log > 60 do table.remove(log, 1) end
                        if SAVE and writefile then writefile(SAVE, HSv:JSONEncode(log)) end
                    end)
                end
                if #log == 0 then
                    addMsg("Olá! Me chamo , sou o criador do Orion Hub e esta é uma réplica da minha mente. Posso ajudá-lo com algo?", false)
                else
                    for _, m in ipairs(log) do if type(m) == "table" and type(m.t) == "string" then addMsg(m.t, m.u == true) end end
                end

                local inRow = Instance.new("Frame"); inRow.AnchorPoint = Vector2.new(0, 1); inRow.Position = UDim2.new(0, 10, 1, -10)
                inRow.Size = UDim2.new(1, -20, 0, 38); inRow.BackgroundColor3 = T.field; inRow.BorderSizePixel = 0; inRow.Parent = chat
                corner(inRow, 10); stroke(inRow, T.border, 0, 1)
                local box = Instance.new("TextBox"); box.BackgroundTransparency = 1; box.Position = UDim2.new(0, 12, 0, 0)
                box.Size = UDim2.new(1, -56, 1, 0); box.Text = ""; box.PlaceholderText = "Escreva uma mensagem..."
                box.PlaceholderColor3 = T.muted; box.TextColor3 = T.white; box.Font = Enum.Font.Gotham; box.TextSize = 12
                box.TextXAlignment = Enum.TextXAlignment.Left; box.ClearTextOnFocus = false; box.Parent = inRow
                local send = Instance.new("TextButton"); send.AnchorPoint = Vector2.new(1, .5); send.Position = UDim2.new(1, -5, .5, 0)
                send.Size = UDim2.new(0, 30, 0, 28); send.BackgroundColor3 = GRAY; send.Text = ""; send.AutoButtonColor = false
                send.BorderSizePixel = 0; send.Parent = inRow; corner(send, 8)
                local sic, sglyph
                local simg = ""
                for _, n in ipairs({"arrow-up", "move-up", "chevron-up"}) do local i0 = icon(n); if i0 ~= "" then simg = i0; break end end
                if simg ~= "" then
                    sic = Instance.new("ImageLabel"); sic.AnchorPoint = Vector2.new(.5, .5); sic.Position = UDim2.new(.5, 0, .5, 0)
                    sic.Size = UDim2.new(0, 14, 0, 14); sic.BackgroundTransparency = 1; sic.Image = simg; sic.ImageColor3 = GRAY_IC; sic.Parent = send
                else
                    sglyph = label(send, "↑", 16, GRAY_IC, Enum.Font.GothamBold); sglyph.Size = UDim2.new(1, 0, 1, 0); sglyph.TextXAlignment = Enum.TextXAlignment.Center
                end
                local busy = false
                local spin = Instance.new("Frame"); spin.AnchorPoint = Vector2.new(.5, .5); spin.Position = UDim2.new(.5, 0, .5, 0)
                spin.Size = UDim2.new(0, 18, 0, 6); spin.BackgroundTransparency = 1; spin.Visible = false; spin.Parent = send
                local dots = {}
                for i = 1, 3 do
                    local d = Instance.new("Frame"); d.Size = UDim2.new(0, 4, 0, 4); d.Position = UDim2.new(0, (i - 1) * 7, .5, -2)
                    d.BackgroundColor3 = T.darkText; d.BorderSizePixel = 0; d.Parent = spin; corner(d, 4); dots[i] = d
                end
                local function hasText() return box.Text:gsub("%s", "") ~= "" end
                local function refresh()
                    local on = hasText() and not busy
                    if sic then sic.Visible = not busy end
                    if sglyph then sglyph.Visible = not busy end
                    if busy and not spin.Visible then
                        spin.Visible = true
                        task.spawn(function()
                            local t0 = os.clock()
                            while busy and spin.Parent do
                                local t = os.clock() - t0
                                for i, d in ipairs(dots) do d.BackgroundTransparency = .75 - .75 * math.max(0, math.sin(t * 7 - i * .9)) end
                                task.wait(1 / 30)
                            end
                            spin.Visible = false
                        end)
                    end
                    TweenService:Create(send, TweenInfo.new(.15), {BackgroundColor3 = (on or busy) and Color3.new(1, 1, 1) or GRAY}):Play()
                    local fg = (on or busy) and T.darkText or GRAY_IC
                    if sic then sic.ImageColor3 = fg end
                    if sglyph then sglyph.TextColor3 = fg end
                end
                box:GetPropertyChangedSignal("Text"):Connect(refresh)

                local history = {}
                for i = math.max(1, #log - 7), #log do
                    local m = log[i]
                    if type(m) == "table" and type(m.t) == "string" then history[#history + 1] = {role = m.u and "user" or "assistant", content = m.t} end
                end
                local reqId, curUser, curWait = 0, nil, nil
                local function cancel()
                    if not busy then return end
                    reqId = reqId + 1
                    for _, tl in ipairs({curUser, curWait}) do
                        if tl and tl.Parent and tl.Parent.Parent then pcall(function() tl.Parent.Parent:Destroy() end) end
                    end
                    curUser, curWait = nil, nil
                    busy = false; refresh()
                end
                local function submit()
                    if busy or not hasText() then return end
                    local q = box.Text:gsub("^%s+", ""):gsub("%s+$", "")
                    if #q > 400 then q = q:sub(1, 400) end
                    box.Text = ""; busy = true; refresh()
                    local userTl = addMsg(q, true)
                    local wait = addMsg("Escrevendo...", false)
                    reqId = reqId + 1; local myId = reqId
                    curUser, curWait = userTl, wait
                    task.spawn(function()
                        local ans, err
                        if type(ask) == "function" then
                            local okc, a, e = pcall(ask, q, history)
                            if okc then ans, err = a, e else err = tostring(a) end
                        else err = "Suporte indisponível." end
                        if myId ~= reqId or not wait.Parent then return end
                        curUser, curWait = nil, nil
                        if type(ans) == "string" and ans:match("%S") then
                            wait.Text = ans
                            history[#history + 1] = {role = "user", content = q}
                            history[#history + 1] = {role = "assistant", content = ans}
                            log[#log + 1] = {t = q, u = true}; log[#log + 1] = {t = ans, u = false}; persist()
                            while #history > 8 do table.remove(history, 1) end
                        else
                            wait.Text = "Não foi possível responder no momento. Por favor, tente novamente em instantes."
                        end
                        task.defer(function() if scroll.Parent then scroll.CanvasPosition = Vector2.new(0, 1e6) end end)
                        busy = false; refresh()
                    end)
                end
                send.Activated:Connect(function() if busy then cancel() else submit() end end)
                -- foco ao clicar (so com borda branca, igual ao sino/minimizar/fechar): apenas na seta com texto ou no carregando
                send.InputBegan:Connect(function(io)
                    if io.UserInputType ~= Enum.UserInputType.MouseButton1 and io.UserInputType ~= Enum.UserInputType.Touch then return end
                    if not (busy or hasText()) then return end
                    local ring = Instance.new("Frame"); ring.Size = UDim2.new(1, 6, 1, 6); ring.AnchorPoint = Vector2.new(.5, .5)
                    ring.Position = UDim2.new(.5, 0, .5, 0); ring.BackgroundTransparency = 1; ring.BorderSizePixel = 0; ring.ZIndex = 50
                    ring.Active = false; ring.Parent = send; corner(ring, 10)
                    local rs = Instance.new("UIStroke"); rs.Color = Color3.new(1, 1, 1); rs.Thickness = 1.5; rs.Transparency = 0
                    rs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; rs.Parent = ring
                    local done = false
                    local function release()
                        if done then return end; done = true
                        local tw = TweenService:Create(rs, TweenInfo.new(.2), {Transparency = 1})
                        tw.Completed:Connect(function() pcall(function() ring:Destroy() end) end); tw:Play()
                    end
                    io.Changed:Connect(function() if io.UserInputState == Enum.UserInputState.End then release() end end)
                    task.delay(.6, release)
                end)
                box.FocusLost:Connect(function(enter) if enter then submit() end end)
            end
            end
            local page = dash -- todo o conteudo antigo do Home agora vive na sub-aba Dashboard
            local LP = Players.LocalPlayer
            local RS = game:GetService("RunService")
            local conns, rotG, sheens = {}, {}, {}
            local function fmt(s)
                s = math.max(0, math.floor(s))
                return string.format("%02d:%02d:%02d", math.floor(s / 3600), math.floor(s / 60) % 60, s % 60)
            end
            local function frame(parent, size, pos, bg, order)
                local f = Instance.new("Frame")
                f.Size = size; f.Position = pos or UDim2.new(); f.BackgroundColor3 = bg or T.panel
                f.BorderSizePixel = 0; f.LayoutOrder = order or 0; f.Parent = parent
                return f
            end
            local function arcStroke(parent, thick)
                local s = Instance.new("UIStroke")
                s.Thickness = math.max(1, (thick or 2) * .55); s.Color = Color3.fromRGB(190, 190, 202); s.Transparency = 0; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = parent
                local g = Instance.new("UIGradient")
                g.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, .62), NumberSequenceKeypoint.new(.35, .62), NumberSequenceKeypoint.new(.5, .05),
                    NumberSequenceKeypoint.new(.65, .62), NumberSequenceKeypoint.new(1, .62)})
                g.Parent = s; rotG[#rotG + 1] = g
                return s
            end
            local function sheen(obj)
                local g = Instance.new("UIGradient")
                g.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 140, 155)),
                    ColorSequenceKeypoint.new(.5, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 140, 155))})
                g.Parent = obj; sheens[#sheens + 1] = g
            end
            local function hover(card)
                local sc = Instance.new("UIScale"); sc.Parent = card
                local ti = TweenInfo.new(.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                card.MouseEnter:Connect(function() TweenService:Create(sc, ti, {Scale = 1.02}):Play() end)
                card.MouseLeave:Connect(function() TweenService:Create(sc, ti, {Scale = 1}):Play() end)
            end

            -- efeito prateado + contorno nas sub-abas e no card do Youtube
            pcall(function()
                arcStroke(SUB.bar, 1.5); arcStroke(SUB.slider, 1.5); 
                
            end)

            -- ===== HERO =====
            local hero = frame(page, UDim2.new(1, 0, 0, 128), nil, Color3.fromRGB(22, 22, 27), 1)
            corner(hero, 14); hero.ClipsDescendants = true
            arcStroke(hero, 2)
            local bgG = Instance.new("UIGradient")
            bgG.Color = ColorSequence.new(Color3.fromRGB(40, 40, 47), Color3.fromRGB(20, 20, 24)); bgG.Rotation = 30; bgG.Parent = hero
            rotG[#rotG + 1] = bgG
            local parts = {}
            for i = 1, 8 do
                local p = frame(hero, UDim2.new(0, math.random(2, 4), 0, math.random(2, 4)), UDim2.new(math.random(), 0, math.random(), 0), Color3.new(1, 1, 1))
                corner(p, 4); p.BackgroundTransparency = .5 + math.random() * .4
                parts[i] = {f = p, x = math.random(), y = math.random(), s = .02 + math.random() * .06}
            end
            local sweep = frame(hero, UDim2.new(1, 0, 1, 0), UDim2.new(), Color3.new(1, 1, 1))
            sweep.BackgroundTransparency = 0; corner(sweep, 14)
            local sg = Instance.new("UIGradient"); sg.Rotation = 20
            sg.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(.4, 1), NumberSequenceKeypoint.new(.5, .96), NumberSequenceKeypoint.new(.6, 1), NumberSequenceKeypoint.new(1, 1)}); sg.Parent = sweep

            local ring = frame(hero, UDim2.new(0, 92, 0, 92), UDim2.new(0, 18, .5, -46), Color3.fromRGB(15, 15, 19))
            corner(ring, 46); arcStroke(ring, 3)
            local av = Instance.new("ImageLabel")
            av.Size = UDim2.new(1, -10, 1, -10); av.Position = UDim2.new(0, 5, 0, 5); av.BackgroundColor3 = T.panel
            av.BorderSizePixel = 0; av.Parent = ring; corner(av, 46)
            task.spawn(function()
                pcall(function()
                    av.Image = Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
                end)
            end)
            local dn = label(hero, LP.DisplayName, 26, T.white, Enum.Font.GothamBold)
            dn.Position = UDim2.new(0, 124, 0, 26); dn.Size = UDim2.new(1, -140, 0, 32); dn.TextTruncate = Enum.TextTruncate.AtEnd
            sheen(dn)
            local qt = label(hero, "", 10, T.muted, Enum.Font.GothamMedium)
            qt.Position = UDim2.new(0, 124, 0, 6); qt.Size = UDim2.new(1, -140, 0, 18); qt.TextTruncate = Enum.TextTruncate.AtEnd
            qt.TextTransparency = 1
            task.spawn(function()
                local day = os.date("%Y-%m-%d")
                local q
                pcall(function()
                    if _G.__OrionSecGet("__quoteDay") == day then q = _G.__OrionSecGet("__quoteTxt") end
                end)
                if (not q or q == "") and type(cfg.QuoteFn) == "function" then
                    local ok, r = pcall(cfg.QuoteFn, day)
                    if ok and type(r) == "string" then
                        r = r:gsub("[\r\n]+", " "):gsub('^%s*["“]+', ""):gsub('["”]+%s*$', ""):gsub("^%s+", ""):gsub("%s+$", "")
                        if #r > 3 and #r < 140 then
                            q = r
                            pcall(function() _G.__OrionSecSet("__quoteDay", day); _G.__OrionSecSet("__quoteTxt", q) end)
                        end
                    end
                end
                if q then
                    local out = {}
                    pcall(function()
                        for _, cp in utf8.codes(q) do
                            if cp <= 0x24F or (cp >= 0x2010 and cp <= 0x2027) then out[#out + 1] = utf8.char(cp) end
                        end
                        q = table.concat(out):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
                    end)
                    if #q < 4 then q = nil end
                end
                q = q or "Cada dia é uma nova chance de evoluir."
                qt.Text = q
                TweenService:Create(qt, TweenInfo.new(.6), {TextTransparency = .15}):Play()
            end)
            local un = label(hero, "@" .. LP.Name, 14, T.muted, Enum.Font.GothamMedium)
            un.Position = UDim2.new(0, 124, 0, 58); un.Size = UDim2.new(1, -140, 0, 20); un.TextTruncate = Enum.TextTruncate.AtEnd
            OrionLib.BindNameLabel(un, "@", 10)
            OrionLib.BindNameLabel(dn, nil, 10)
            dn.Size = UDim2.new(1, -180, 0, 32); qt.Size = UDim2.new(1, -196, 0, 18); qt.Position = UDim2.new(0, 140, 0, 6)
            do -- icone de IA no comeco da frase do dia
                local img = ""
                for _, n in ipairs({"sparkles", "bot", "wand-sparkles"}) do local ic0 = icon(n); if ic0 ~= "" then img = ic0; break end end
                local ai = Instance.new("ImageLabel"); ai.Name = "AIQuoteIcon"; ai.Size = UDim2.new(0, 13, 0, 13)
                ai.Position = UDim2.new(0, 124, 0, 9); ai.BackgroundTransparency = 1; ai.Image = img; ai.ImageColor3 = T.silver
                ai.Visible = img ~= ""; ai.Parent = hero
                if img == "" then qt.Position = UDim2.new(0, 124, 0, 6) end
            end
            do -- olho: oculta/mostra o nome do jogador (Home e sidebar)
                local eb = Instance.new("TextButton"); eb.Name = "HideNameBtn"; eb.Text = ""; eb.AutoButtonColor = false
                eb.Size = UDim2.new(0, 28, 0, 28); eb.AnchorPoint = Vector2.new(1, 0); eb.Position = UDim2.new(1, -10, 0, 10)
                eb.BackgroundColor3 = T.panel; eb.BorderSizePixel = 0; eb.ZIndex = 6; eb.Parent = hero
                corner(eb, 8); stroke(eb, T.border, 0, 1)
                local ei = Instance.new("ImageLabel"); ei.Size = UDim2.new(0, 16, 0, 16); ei.AnchorPoint = Vector2.new(.5, .5)
                ei.Position = UDim2.new(.5, 0, .5, 0); ei.BackgroundTransparency = 1; ei.ImageColor3 = T.silver; ei.ZIndex = 7; ei.Parent = eb
                local function skin(h)
                    local img = icon(h and "eye-off" or "eye")
                    ei.Image = img
                    if img == "" then eb.Text = h and "x" or "o"; eb.Font = Enum.Font.GothamBold; eb.TextSize = 14; eb.TextColor3 = T.silver end
                end
                table.insert(OrionLib._nameCbs, skin); skin(OrionLib.HideName)
                bindTap(eb, function() OrionLib.SetHideName(not OrionLib.HideName) end)
            end
            local dot = frame(ring, UDim2.new(0, 16, 0, 16), UDim2.new(1, -22, 1, -22), Color3.fromRGB(90, 255, 160)); corner(dot, 8); dot.ZIndex = 5
            do local ds = Instance.new("UIStroke"); ds.Color = Color3.fromRGB(22, 22, 27); ds.Thickness = 2.5; ds.Parent = dot end
            local chip = frame(hero, UDim2.new(1, -142, 0, 38), UDim2.new(0, 124, 0, 82), Color3.fromRGB(15, 15, 19))
            corner(chip, 10); arcStroke(chip, 1.5); chip.ClipsDescendants = true
            local chShine = frame(chip, UDim2.new(1, 0, 1, 0), UDim2.new(), Color3.new(1, 1, 1)); corner(chShine, 10)
            local chG = Instance.new("UIGradient"); chG.Rotation = 20
            chG.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(.4, 1), NumberSequenceKeypoint.new(.5, .88), NumberSequenceKeypoint.new(.6, 1), NumberSequenceKeypoint.new(1, 1)}); chG.Parent = chShine
            local chTrack = frame(chip, UDim2.new(1, -24, 0, 3), UDim2.new(0, 12, 1, -8), Color3.fromRGB(34, 34, 40)); corner(chTrack, 2)
            local chBar = frame(chTrack, UDim2.new(0, 0, 1, 0), UDim2.new(), Color3.new(1, 1, 1)); corner(chBar, 2)
            do local g = Instance.new("UIGradient"); g.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, .8), NumberSequenceKeypoint.new(1, 0)}); g.Parent = chBar end
            local chDot = frame(chip, UDim2.new(0, 7, 0, 7), UDim2.new(1, -17, 0, 12), Color3.fromRGB(90, 255, 160)); corner(chDot, 4)
            local chTag = label(chip, "TEMPO DE SEÇÃO", 10, T.muted, Enum.Font.GothamBold)
            chTag.Position = UDim2.new(0, 12, 0, 0); chTag.Size = UDim2.new(0, 96, 0, 30)
            local chSep = frame(chip, UDim2.new(0, 1, 0, 16), UDim2.new(0, 110, 0, 7), T.border)
            local st = label(chip, "00:00:00", 15, T.white, Enum.Font.GothamBold)
            st.Position = UDim2.new(0, 120, 0, 0); st.Size = UDim2.new(1, -140, 0, 30); sheen(st)

            -- ===== STATS =====
            local row = frame(page, UDim2.new(1, 0, 0, 84), nil, T.bg, 2); row.BackgroundTransparency = 1
            local function statCard(i, title, ico)
                local c = frame(row, UDim2.new(1 / 3, -8, 1, 0), UDim2.new((i - 1) / 3, (i - 1) * 4, 0, 0), Color3.fromRGB(24, 24, 29))
                corner(c, 12); arcStroke(c, 1.5)
                local t = label(c, title, 11, T.muted, Enum.Font.GothamMedium)
                t.Position = UDim2.new(0, 12, 0, 8); t.Size = UDim2.new(1, -24, 0, 16)
                local v = label(c, "--", 24, T.white, Enum.Font.GothamBold)
                v.Position = UDim2.new(0, 12, 0, 30); v.Size = UDim2.new(1, -24, 0, 34); sheen(v)
                v.TextTruncate = Enum.TextTruncate.AtEnd
                return v
            end
            local fpsV = statCard(1, "FPS")
            local pingV = statCard(2, "PING")
            local sesV = statCard(3, "EXECUÇÕES")
            do
                local n = 0
                pcall(function() n = tonumber(_G.__OrionSecGet("__execCount")) or 0 end)
                n = n + 1
                pcall(function() _G.__OrionSecSet("__execCount", n) end)
                sesV.Text = tostring(n)
            end

            -- ===== EXECUTOR =====
            -- {chave, site, key(true/false/"paid"), {características}}
            -- fast=rápido  simple=simples  safe=seguro  mobile=celular  premium=pago
            local EXE = {
                {"delta", "deltaexploits.gg", true, {"mobile", "simple", "safe"}},
                {"fluxus", "fluxus.team", true, {"simple", "safe"}},
                {"krnl", "krnl.cat", true, {"mobile", "fast"}},
                {"arceus", "spdmteam.com", true, {"mobile", "simple"}},
                {"hydrogen", "hydrogen.lat", true, {"mobile", "simple"}},
                {"codex", "codex.lol", true, {"mobile", "fast", "simple"}},
                {"wave", "getwave.gg", true, {"fast", "safe"}},
                {"volcano", "volcano.wtf", true, {"fast", "simple"}},
                {"velocity", "getvelocity.lol", true, {"fast", "simple"}},
                {"swift", "getswift.xyz", true, {"fast", "safe"}},
                {"cryptic", "getcryptic.net", true, {"mobile", "fast"}},
                {"xeno", "xeno.now", false, {"fast", "simple", "safe"}},
                {"solara", "getsolara.dev", false, {"simple", "safe"}},
                {"bunni", "bunni.fun", false, {"fast", "simple"}},
                {"seliware", "seliware.com", false, {"fast"}},
                {"potassium", "potassium.pro", false, {"fast", "simple"}},
                {"synapse", "synapse.do", "paid", {"safe", "premium"}},
                {"script-ware", "script-ware.com", "paid", {"safe", "premium"}},
                {"sirhurt", "sirhurt.net", "paid", {"fast", "premium"}},
                {"awp", "awp.gg", "paid", {"fast", "premium"}},
                {"macsploit", "macsploit.com", "paid", {"safe", "premium"}},
            }
            -- lista de executores (dados do rscripts.net/executors, 31/10/2026): {nome, slug, sUNC, preco, plataforma, status, chave, dominio}
            local EXL = {
                {"Volt", "volt", 100, "$5.99/wk", "Windows", "working", nil, nil, "logo_1771164194166_eq2kzcwm.webp", "thumb_1771164199216_4NwW4gHA.webp"},
                {"Potassium", "potassium", 100, "$22.99 lifetime", "Windows", "working", nil, "potassium.pro", "1753031129605_YugmbXMfSG.webp", "thumb_1771164977294_1429hufQ.webp"},
                {"Wave", "wave", 100, "$4.99/wk", "Windows", "working", nil, "getwave.gg", "WaveLogo.webp", "thumb_1771163508160_SDjKycmb.webp"},
                {"Matcha", "matcha", nil, "$9.99 lifetime", "Windows", "working", nil, nil, "logo_1791495941030_1Jn61VF9.webp", "thumb_1791495945874_S7VoFkUw.webp"},
                {"OpiumWare", "opiumware", 100, "Free", "Mac", "working", "keyless", nil, "logo_1777507660667_kTXmLGRq.webp", "thumb_1777507662817_TgJqKiRF.webp"},
                {"Real", "real", 100, "Free", "Windows", "working", "key", nil, "logo_1783722468799_WNCyjZ9x.webp", "thumb_1783722436875_htZh2WAc.webp"},
                {"Synapse Z", "synapsez", 98, "$3.99/wk", "Windows", "outdated", nil, nil, "SynapsezLogo.webp", "thumb_1772999654705_88kHipZx.webp"},
                {"Delta", "delta", 98, "Free", "Android", "outdated", "key", "deltaexploits.gg", "DeltaLogo.png", "DeltaThumbnail1.png"},
                {"Codex", "codex", nil, "Free", "Android", "unknown", nil, "codex.lol", "CodexLogo.jpg", "CodexThumbnail1.jpg"},
                {"Seliware", "seliware", nil, "$9.99", "Windows", "unknown", nil, "seliware.com", "1760048695891_OlNWTHsSSM.webp", "1760048817433_qeXsv0xO39.webp"},
            }
            local function exFeats(e) -- caracteristicas: fast=rapido simple=simples safe=seguro mobile=celular premium=pago
                local f = {}
                if (e[3] or 0) >= 100 then f[#f + 1] = "fast" end
                if e[6] == "working" then f[#f + 1] = "safe" end
                if e[5] == "Android" or e[5] == "iOS" then f[#f + 1] = "mobile" end
                if e[4] ~= "Free" then f[#f + 1] = "premium" elseif e[7] ~= "key" then f[#f + 1] = "simple" end
                return f
            end
            local exName, exVer = nil, nil
            pcall(function() if identifyexecutor then exName, exVer = identifyexecutor() end end)
            if not exName then pcall(function() if getexecutorname then exName = getexecutorname() end end) end
            exName = tostring(exName or "Desconhecido")
            local exInfo
            for _, e in ipairs(EXE) do if string.find(string.lower(exName), e[1], 1, true) then exInfo = e; break end end
            local exRow
            for _, e in ipairs(EXL) do
                local ln = string.lower(exName)
                if string.find(ln, string.lower(e[1]), 1, true) or string.find(ln, e[2], 1, true) then exRow = e; break end
            end
            if exRow and not exInfo then exInfo = {exRow[2], exRow[8], exRow[7] == "key", exFeats(exRow)} end
            local exWrap = Instance.new("Frame"); exWrap.BackgroundTransparency = 1; exWrap.BorderSizePixel = 0
            exWrap.BackgroundTransparency = 0; exWrap.BackgroundColor3 = Color3.fromRGB(23, 23, 28); exWrap.ClipsDescendants = true
            corner(exWrap, 14); arcStroke(exWrap, 1.6)
            exWrap.AutomaticSize = Enum.AutomaticSize.Y; exWrap.Size = UDim2.new(1, 0, 0, 0); exWrap.LayoutOrder = 3; exWrap.Parent = page
            do local wl = Instance.new("UIListLayout"); wl.Padding = UDim.new(0, 0); wl.SortOrder = Enum.SortOrder.LayoutOrder; wl.Parent = exWrap end
            local exc = frame(exWrap, UDim2.new(1, 0, 0, 76), nil, Color3.fromRGB(23, 23, 28), 1)
            exc.BackgroundTransparency = 1; exc.ClipsDescendants = true
            local exF = frame(exc, UDim2.new(1, 0, 1, 0), UDim2.new(), Color3.new(1, 1, 1)); corner(exF, 14)
            local exG = Instance.new("UIGradient"); exG.Rotation = 20
            exG.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(.4, 1), NumberSequenceKeypoint.new(.5, .9), NumberSequenceKeypoint.new(.6, 1), NumberSequenceKeypoint.new(1, 1)}); exG.Parent = exF
            local exIco = Instance.new("ImageLabel")
            exIco.Size = UDim2.new(0, 48, 0, 48); exIco.Position = UDim2.new(0, 14, .5, -24); exIco.BackgroundColor3 = Color3.fromRGB(15, 15, 19)
            exIco.BorderSizePixel = 0; exIco.ScaleType = Enum.ScaleType.Fit; exIco.Parent = exc; corner(exIco, 12); stroke(exIco, T.border, .3, 1); arcStroke(exIco, 1.2)
            local exLet = label(exIco, string.upper(string.sub(exName, 1, 1)), 22, T.white, Enum.Font.GothamBold)
            exLet.Size = UDim2.new(1, 0, 1, 0); exLet.TextXAlignment = Enum.TextXAlignment.Center
            local exTag = label(exc, "EXECUTOR", 11, T.muted, Enum.Font.GothamMedium)
            exTag.Position = UDim2.new(0, 74, 0, 14); exTag.Size = UDim2.new(1, -210, 0, 14)
            local exNm = label(exc, exName, 20, T.white, Enum.Font.GothamBold)
            exNm.Position = UDim2.new(0, 74, 0, 30); exNm.Size = UDim2.new(1, -210, 0, 26); exNm.TextTruncate = Enum.TextTruncate.AtEnd; sheen(exNm)
            do
                local FEAT = {
                    key = {"key", {"key"}, Color3.fromRGB(255, 208, 60)},
                    fast = {"zap", {"zap", "gauge"}}, simple = {"sparkles", {"sparkles", "mouse-pointer-click", "smile"}},
                    safe = {"shield-check", {"shield-check", "shield"}}, mobile = {"smartphone", {"smartphone", "tablet-smartphone"}},
                    premium = {"crown", {"crown", "star"}},
                }
                local list = {}
                                                local n = 0
                for _, f in ipairs(list) do
                    local def = FEAT[f]
                    local img
                    if def then for _, nm in ipairs(def[2]) do local ic = icon(nm); if ic ~= "" then img = ic; break end end end
                    if img and n < 4 then
                        local isKey = (f == "key")
                        local kt = frame(exc, UDim2.new(0, 30, 0, 30), UDim2.new(1, -86 - n * 34, .5, -15), Color3.fromRGB(20, 20, 25))
                        corner(kt, 8); arcStroke(kt, 1.2); stroke(kt, T.border, .2, 1)
                        local im = Instance.new("ImageLabel"); im.Size = UDim2.new(0, 16, 0, 16); im.AnchorPoint = Vector2.new(.5, .5)
                        im.Position = UDim2.new(.5, 0, .5, 0); im.BackgroundTransparency = 1; im.Image = img
                        im.ImageColor3 = T.silver; im.Parent = kt
                        n = n + 1
                    end
                end
                local w = -(124 + n * 34)
                exTag.Size = UDim2.new(1, w, 0, 14); exNm.Size = UDim2.new(1, w, 0, 26)
            end
            -- botao de abrir + card com todos os executores
            local exList
            do
                local arrowBtn = Instance.new("TextButton")
                arrowBtn.Size = UDim2.new(0, 34, 0, 34); arrowBtn.Position = UDim2.new(1, -48, .5, -17); arrowBtn.BackgroundColor3 = T.panel
                arrowBtn.Text = ""; arrowBtn.AutoButtonColor = false; arrowBtn.BorderSizePixel = 0; arrowBtn.ZIndex = 5; arrowBtn.Parent = exc
                corner(arrowBtn, 9); stroke(arrowBtn, T.border, 0, 1)
                local ai = Instance.new("ImageLabel"); ai.Size = UDim2.new(0, 20, 0, 20); ai.AnchorPoint = Vector2.new(.5, .5)
                ai.Position = UDim2.new(.5, 0, .5, 0); ai.BackgroundTransparency = 1; ai.Image = icon("chevron-down"); ai.ImageColor3 = T.silver; ai.ZIndex = 6; ai.Parent = arrowBtn

                exList = frame(exWrap, UDim2.new(1, 0, 0, 0), nil, Color3.fromRGB(23, 23, 28), 2)
                exList.AutomaticSize = Enum.AutomaticSize.Y; exList.Visible = false
                exList.BackgroundTransparency = 1
                do -- divisor fino entre o executor atual e a lista (so aparece aberto)
                    local sep = Instance.new("Frame"); sep.Size = UDim2.new(1, -28, 0, 1); sep.Position = UDim2.new(0, 14, 1, -1)
                    sep.BackgroundColor3 = T.border; sep.BackgroundTransparency = .35; sep.BorderSizePixel = 0; sep.Visible = exList.Visible; sep.ZIndex = 5; sep.Parent = exc
                    exList:GetPropertyChangedSignal("Visible"):Connect(function() sep.Visible = exList.Visible end)
                end
                local lp = Instance.new("UIPadding"); lp.PaddingTop = UDim.new(0, 10); lp.PaddingBottom = UDim.new(0, 10)
                lp.PaddingLeft = UDim.new(0, 10); lp.PaddingRight = UDim.new(0, 10); lp.Parent = exList
                local ll = Instance.new("UIListLayout"); ll.Padding = UDim.new(0, 8); ll.SortOrder = Enum.SortOrder.LayoutOrder; ll.Parent = exList

                local FEATI = {
                    fast = {"zap", "gauge"}, simple = {"sparkles", "smile"}, safe = {"shield-check", "shield"},
                    mobile = {"smartphone", "tablet-smartphone"}, premium = {"crown", "star"},
                }
                local STC = {working = Color3.fromRGB(46, 204, 113), outdated = Color3.fromRGB(225, 82, 82), unknown = Color3.fromRGB(140, 140, 150)}
                local STT = {working = "Online", outdated = "Offline", unknown = "Inactive"}
                local order = {}
                for _, e in ipairs(EXL) do order[#order + 1] = e end
                table.sort(order, function(a, b) return (a == exRow and 1 or 0) > (b == exRow and 1 or 0) end)
                local GREEN2, RED2 = Color3.fromRGB(46, 204, 113), Color3.fromRGB(225, 82, 82)
                local function loadImg(target, letter, files, onFail)
                    local urls = {}
                    for _, f in ipairs(files) do
                        if f then
                            urls[#urls + 1] = "https://rscripts.net/api/assets/executors/" .. f
                            urls[#urls + 1] = "https://rscripts.net/_next/image?url=" .. HttpService:UrlEncode("/api/assets/executors/" .. f) .. "&w=640&q=75"
                        end
                    end
                    local i = 0
                    local function try()
                        i = i + 1
                        if not urls[i] then if onFail then onFail() end return end
                        resolveImage(urls[i], function(r)
                            if not target.Parent then return end
                            if r and r ~= "" then
                                target.Image = r; target.ImageColor3 = Color3.new(1, 1, 1)
                                if letter then letter.Visible = false end
                            else try() end
                        end)
                    end
                    try()
                end
                for idx, e in ipairs(order) do
                    local cur = (e == exRow)
                    local row = frame(exList, UDim2.new(1, 0, 0, 114), nil, Color3.fromRGB(18, 18, 22), idx)
                    corner(row, 12); local exStroke = stroke(row, cur and T.silver or T.border, cur and .1 or .3, 1); row.ClipsDescendants = true
                    do -- mesmo efeito dos cards de Scripts: fundo e borda clareiam ao passar/pressionar
                        local hiT = TweenInfo.new(.15)
                        local function exHi(on)
                            TweenService:Create(row, hiT, {BackgroundColor3 = on and T.panelHover or Color3.fromRGB(18, 18, 22)}):Play()
                            TweenService:Create(exStroke, hiT, {Color = on and T.silver2 or (cur and T.silver or T.border), Transparency = on and .05 or (cur and .1 or .3)}):Play()
                        end
                        row.MouseEnter:Connect(function() exHi(true) end)
                        row.MouseLeave:Connect(function() exHi(false) end)
                        UserInputService.InputEnded:Connect(function(io) if io.UserInputType == Enum.UserInputType.Touch then task.delay(.08, function() exHi(false) end) end end)
                    end
                    -- thumbnail grande (estilo YouTube)
                    local th = Instance.new("ImageLabel"); th.Size = UDim2.new(0, 150, 0, 94); th.Position = UDim2.new(0, 8, 0, 10)
                    th.BackgroundColor3 = Color3.fromRGB(14, 14, 18); th.BorderSizePixel = 0; th.ScaleType = Enum.ScaleType.Fit; th.Parent = row
                    local thLet = label(th, string.upper(string.sub(e[1], 1, 1)), 34, T.muted, Enum.Font.GothamBold)
                    thLet.Size = UDim2.new(1, 0, 1, 0); thLet.TextXAlignment = Enum.TextXAlignment.Center
                    loadImg(th, thLet, {e[10]}, nil)
                    -- logotipo (avatar redondo)
                    local lg = Instance.new("ImageLabel"); lg.Size = UDim2.new(0, 26, 0, 26); lg.Position = UDim2.new(0, 170, 0, 9)
                    lg.BackgroundColor3 = Color3.fromRGB(15, 15, 19); lg.BorderSizePixel = 0; lg.ScaleType = Enum.ScaleType.Crop; lg.Parent = row
                    corner(lg, 13); stroke(lg, T.border, .2, 1)
                    local lgLet = label(lg, string.upper(string.sub(e[1], 1, 1)), 13, T.white, Enum.Font.GothamBold)
                    lgLet.Size = UDim2.new(1, 0, 1, 0); lgLet.TextXAlignment = Enum.TextXAlignment.Center
                    loadImg(lg, lgLet, {e[9]}, function()
                        if cur and lg.Parent then
                            task.spawn(function()
                                for _ = 1, 20 do
                                    if exIco.Image ~= "" then lg.Image = exIco.Image; lgLet.Visible = false; return end
                                    task.wait(.5)
                                end
                            end)
                        end
                    end)
                    local dotc = frame(row, UDim2.new(0, 9, 0, 9), UDim2.new(0, 187, 0, 26), STC[e[6]] or STC.unknown); corner(dotc, 5); dotc.ZIndex = 3
                    do local ds = Instance.new("UIStroke"); ds.Color = Color3.fromRGB(18, 18, 22); ds.Thickness = 2; ds.Parent = dotc end
                    if cur then
                        local pill = frame(row, UDim2.new(0, 58, 0, 18), UDim2.new(0, 14, 0, 16), Color3.fromRGB(46, 204, 113)); corner(pill, 9); pill.ZIndex = 3
                        local pl = label(pill, "Em uso", 10, T.darkText, Enum.Font.GothamBold)
                        pl.Size = UDim2.new(1, 0, 1, 0); pl.TextXAlignment = Enum.TextXAlignment.Center; pl.ZIndex = 4
                    end
                    local nm = label(row, e[1], 15, T.white, Enum.Font.GothamBold)
                    nm.Position = UDim2.new(0, 204, 0, 12); nm.Size = UDim2.new(1, -214, 0, 20); nm.TextTruncate = Enum.TextTruncate.AtEnd
                    -- chips arredondados e coloridos: status, sUNC, plataforma e preco
                    local function chip(parent, txt, col, order, dot)
                        local c = Instance.new("Frame"); c.Size = UDim2.new(0.5, -4, 0, 24)
                        c.BackgroundColor3 = col; c.BackgroundTransparency = .8; c.BorderSizePixel = 0; c.LayoutOrder = order; c.Parent = parent
                        corner(c, 5); stroke(c, col, .3, 1)
                        if dot then
                            local d = Instance.new("Frame"); d.Size = UDim2.new(0, 7, 0, 7); d.Position = UDim2.new(0, 8, .5, -3)
                            d.BackgroundColor3 = col; d.BorderSizePixel = 0; d.Parent = c; corner(d, 4)
                        end
                        local lb = Instance.new("TextLabel"); lb.BackgroundTransparency = 1; lb.Text = txt; lb.Font = Enum.Font.GothamBold
                        lb.TextSize = 11; lb.TextColor3 = col; lb.TextTruncate = Enum.TextTruncate.AtEnd
                        lb.Position = UDim2.new(0, dot and 20 or 6, 0, 0); lb.Size = UDim2.new(1, dot and -24 or -12, 1, 0)
                        lb.TextXAlignment = dot and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center; lb.Parent = c
                        return c
                    end
                    local function chipLine(y)
                        local ln = Instance.new("Frame"); ln.BackgroundTransparency = 1; ln.Size = UDim2.new(1, -180, 0, 24)
                        ln.Position = UDim2.new(0, 170, 0, y); ln.Parent = row
                        local ll2 = Instance.new("UIListLayout"); ll2.FillDirection = Enum.FillDirection.Horizontal; ll2.Padding = UDim.new(0, 8)
                        ll2.SortOrder = Enum.SortOrder.LayoutOrder; ll2.VerticalAlignment = Enum.VerticalAlignment.Top
                        ll2.Parent = ln
                        return ln
                    end
                    local PLAT = {Windows = Color3.fromRGB(80, 170, 255), Mac = Color3.fromRGB(200, 200, 212), Android = Color3.fromRGB(120, 220, 140), iOS = Color3.fromRGB(255, 150, 200)}
                    local l1 = chipLine(42)
                    chip(l1, STT[e[6]] or "Inactive", STC[e[6]] or STC.unknown, 1, true)
                    chip(l1, e[5], PLAT[e[5]] or T.silver, 2)
                    local fl = {}
                    if e[7] == "key" then fl[#fl + 1] = "key" end
                    for _, f in ipairs(exFeats(e)) do fl[#fl + 1] = f end
                    local tc = Instance.new("Frame"); tc.BackgroundTransparency = 1; tc.Size = UDim2.new(1, -266, 0, 24)
                    tc.Position = UDim2.new(0, 170, 0, 78); tc.Parent = row
                    do local tll = Instance.new("UIListLayout"); tll.FillDirection = Enum.FillDirection.Horizontal; tll.Padding = UDim.new(0, 6)
                        tll.SortOrder = Enum.SortOrder.LayoutOrder; tll.Parent = tc end
                    local tiles = {}
                    for _, f in ipairs(fl) do
                        local names = (f == "key") and {"key"} or FEATI[f]
                        local img
                        for _, n in ipairs(names or {}) do local ic = icon(n); if ic ~= "" then img = ic; break end end
                        if img then
                            local tl = frame(tc, UDim2.new(0, 24, 0, 24), nil, Color3.fromRGB(20, 20, 25))
                            tl.LayoutOrder = #tiles + 1
                            corner(tl, 7); stroke(tl, T.border, .2, 1)
                            local im = Instance.new("ImageLabel"); im.Size = UDim2.new(0, 14, 0, 14); im.AnchorPoint = Vector2.new(.5, .5)
                            im.Position = UDim2.new(.5, 0, .5, 0); im.BackgroundTransparency = 1; im.Image = img
                            im.ImageColor3 = T.silver; im.Parent = tl
                            tiles[#tiles + 1] = tl
                        end
                    end
                    local function fitTiles()
                        for _, tl in ipairs(tiles) do
                            tl.Visible = (tl.AbsolutePosition.X - tc.AbsolutePosition.X) + tl.AbsoluteSize.X <= tc.AbsoluteSize.X + 1
                        end
                    end
                    tc:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() pcall(fitTiles) end)
                    task.defer(function() pcall(fitTiles) end)
                    -- Pegar: copia o link do executor (so a cor muda: branco -> verde)
                    local gb = Instance.new("TextButton")
                    local tw0 = (#tiles > 0) and (#tiles * 30 - 6) or 0
                    gb.Size = UDim2.new(1, -(170 + tw0 + 18), 0, 28); gb.AnchorPoint = Vector2.new(1, 1); gb.Position = UDim2.new(1, -10, 1, -8)
                    gb.BackgroundColor3 = T.silver; gb.Text = ""; gb.AutoButtonColor = false; gb.BorderSizePixel = 0; gb.ZIndex = 3; gb.Parent = row; corner(gb, 8)
                    pressFx(gb)
                    do local sc = Instance.new("UISizeConstraint"); sc.MinSize = Vector2.new(80, 28); sc.Parent = gb end
                    local gl = label(gb, "Pegar", 12, T.darkText, Enum.Font.GothamBold)
                    gl.Size = UDim2.new(1, 0, 1, 0); gl.TextXAlignment = Enum.TextXAlignment.Center; gl.TextYAlignment = Enum.TextYAlignment.Center; gl.ZIndex = 4
                    local gIc
                    do
                        local gi = ""
                        for _, n in ipairs({"arrow-right", "arrow-right-to-line", "chevron-right", "log-in"}) do local ic0 = icon(n); if ic0 ~= "" then gi = ic0; break end end
                        if gi ~= "" then
                            gIc = Instance.new("ImageLabel"); gIc.Size = UDim2.new(0, 12, 0, 12); gIc.Position = UDim2.new(0, 11, .5, -6)
                            gIc.BackgroundTransparency = 1; gIc.Image = gi; gIc.ImageColor3 = T.darkText; gIc.ScaleType = Enum.ScaleType.Fit; gIc.ZIndex = 4; gIc.Parent = gb
                            gl.Position = UDim2.new(0, 26, 0, 0); gl.Size = UDim2.new(1, -32, 1, 0)
                        end
                    end
                    -- brilho branco horizontal passando ao clicar (igual ao botao Executar)
                    local gSweep = Instance.new("Frame")
                    gSweep.Name = "Sweep"; gSweep.Size = UDim2.new(1, 0, 1, 0); gSweep.BackgroundColor3 = Color3.new(1, 1, 1)
                    gSweep.BorderSizePixel = 0; gSweep.ZIndex = 6; gSweep.Active = false; gSweep.Visible = false; gSweep.Parent = gb
                    corner(gSweep, 8)
                    local gSweepG = Instance.new("UIGradient")
                    gSweepG.Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(.35, 1),
                        NumberSequenceKeypoint.new(.5, .3), NumberSequenceKeypoint.new(.65, 1), NumberSequenceKeypoint.new(1, 1)
                    })
                    gSweepG.Rotation = 20; gSweepG.Offset = Vector2.new(-1, 0); gSweepG.Parent = gSweep
                    local gSweeping = false
                    local function gPlaySweep(dur)
                        if gSweeping or not gb.Parent then return end
                        gSweeping = true
                        gSweepG.Offset = Vector2.new(-1, 0); gSweep.Visible = true
                        TweenService:Create(gSweepG, TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Offset = Vector2.new(1, 0)}):Play()
                        task.delay(dur + .05, function() gSweeping = false; gSweep.Visible = false end)
                    end
                    local tok = 0
                    gb.Activated:Connect(function()
                        gPlaySweep(.6)
                        local link = "https://rscripts.net/executors/" .. e[2]
                        local ok = false
                        pcall(function() ok = copyText(link) end)
                        tok = tok + 1; local my = tok
                        local fg = ok and T.darkText or Color3.new(1, 1, 1)
                        TweenService:Create(gb, TweenInfo.new(.15), {BackgroundColor3 = ok and GREEN2 or RED2}):Play()
                        gl.TextColor3 = fg
                        if gIc then gIc.ImageColor3 = fg end
                        task.delay(1.6, function()
                            if my == tok and gb.Parent then
                                TweenService:Create(gb, TweenInfo.new(.15), {BackgroundColor3 = T.silver}):Play()
                                gl.TextColor3 = T.darkText
                                if gIc then gIc.ImageColor3 = T.darkText end
                            end
                        end)
                    end)
                end
                local open, busy = false, false
                pcall(function() open = (_G.__OrionSecGet("__execList") == true) end)
                exList.Visible = open; ai.Rotation = open and 0 or -90
                local tiA = TweenInfo.new(.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                bindTap(arrowBtn, function()
                    if busy then return end
                    busy = true; open = not open
                    pcall(function() _G.__OrionSecSet("__execList", open) end)
                    TweenService:Create(ai, tiA, {Rotation = open and 0 or -90}):Play()
                    if open then
                        exList.AutomaticSize = Enum.AutomaticSize.None
                        exList.ClipsDescendants = true
                        exList.Size = UDim2.new(1, 0, 0, 0)
                        exList.Visible = true
                        local h = ll.AbsoluteContentSize.Y + 20
                        local tw = TweenService:Create(exList, tiA, {Size = UDim2.new(1, 0, 0, h)})
                        tw.Completed:Connect(function()
                            exList.AutomaticSize = Enum.AutomaticSize.Y; exList.ClipsDescendants = false; busy = false
                        end)
                        tw:Play()
                    else
                        local h = exList.AbsoluteSize.Y
                        exList.AutomaticSize = Enum.AutomaticSize.None
                        exList.ClipsDescendants = true
                        exList.Size = UDim2.new(1, 0, 0, h)
                        local tw = TweenService:Create(exList, tiA, {Size = UDim2.new(1, 0, 0, 0)})
                        tw.Completed:Connect(function() exList.Visible = false; busy = false end)
                        tw:Play()
                    end
                end)
            end

            -- foto do executor: favicon do site oficial (API de favicon do Google), baixada e usada como imagem local
            if exInfo and exInfo[2] and getcustomasset and writefile then
                task.spawn(function()
                    pcall(function()
                        local f = _G.__OrionPath("Config", "exec_" .. exInfo[1] .. ".png")
                        if not (isfile and isfile(f)) then
                            local raw = game:HttpGet("https://www.google.com/s2/favicons?domain=" .. exInfo[2] .. "&sz=128")
                            if raw and #raw > 100 then writefile(f, raw) end
                        end
                        if isfile(f) then exIco.Image = getcustomasset(f); exLet.Visible = false end
                    end)
                end)
            end

            -- ===== GRAFICO FPS =====
            local gc = frame(page, UDim2.new(1, 0, 0, 170), nil, Color3.fromRGB(23, 23, 28), 4)
            corner(gc, 14); arcStroke(gc, 1.6); gc.ClipsDescendants = true
            local gcF = frame(gc, UDim2.new(1, 0, 1, 0), UDim2.new(), Color3.new(1, 1, 1)); corner(gcF, 14)
            local gcG = Instance.new("UIGradient"); gcG.Rotation = 20
            gcG.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(.4, 1), NumberSequenceKeypoint.new(.5, .9), NumberSequenceKeypoint.new(.6, 1), NumberSequenceKeypoint.new(1, 1)}); gcG.Parent = gcF
            local gt = label(gc, "FPS em tempo real", 14, T.silver, Enum.Font.GothamBold)
            gt.Position = UDim2.new(0, 14, 0, 10); gt.Size = UDim2.new(.5, 0, 0, 20)
            local gv = label(gc, "0", 22, T.white, Enum.Font.GothamBold)
            gv.Position = UDim2.new(.5, 0, 0, 8); gv.Size = UDim2.new(.5, -14, 0, 26); gv.TextXAlignment = Enum.TextXAlignment.Right; sheen(gv)
            local area = frame(gc, UDim2.new(1, -28, 1, -78), UDim2.new(0, 14, 0, 40), Color3.fromRGB(16, 16, 20)); corner(area, 8); arcStroke(area, 1.2)
            for k = 1, 3 do
                local ln = frame(area, UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, k / 4, 0), T.border); ln.BackgroundTransparency = .6
            end
            local N, bars, hist = 48, {}, {}
            for i = 1, N do
                local b = frame(area, UDim2.new(1 / N, -2, 0, 0), UDim2.new((i - 1) / N, 1, 1, 0), Color3.new(1, 1, 1))
                b.AnchorPoint = Vector2.new(0, 1); corner(b, 2); bars[i] = b; hist[i] = 0
            end
            local mm = label(gc, "mín --  -  média --  -  máx --", 11, T.muted, Enum.Font.GothamMedium)
            mm.Position = UDim2.new(0, 14, 1, -28); mm.Size = UDim2.new(1, -28, 0, 20)

            -- ===== LOOP =====
            local saved = tonumber((function() local ok, v = pcall(function() return _G.__OrionSecGet("__sessionTotal") end); return ok and v end)()) or 0
            local t0, acc, frames, rot, ph, lastSave, lastTick = os.clock(), 0, 0, 0, 0, os.clock(), 0
            local fps, shown = 60, 0
            local function save()
                pcall(function() _G.__OrionSecSet("__sessionTotal", saved + (os.clock() - t0)) end)
            end
            conns[#conns + 1] = RS.Heartbeat:Connect(function(dt)
                if not hostPage.Visible then return end
                rot = (rot + dt * 35) % 360; ph = ph + dt * .35
                for _, g in ipairs(rotG) do pcall(function() g.Rotation = rot end) end
                for _, g in ipairs(sheens) do pcall(function() g.Offset = Vector2.new(math.sin(ph * 2) * .3, 0) end) end
                sg.Offset = Vector2.new(-1 + (ph % 1.6) / 1.6 * 2, 0)
                gcG.Offset = Vector2.new(-1 + ((ph + .8) % 1.6) / 1.6 * 2, 0)
                exG.Offset = Vector2.new(-1 + ((ph + .4) % 1.6) / 1.6 * 2, 0)
                for _, p in ipairs(parts) do
                    p.y = p.y - p.s * dt; p.x = p.x + math.sin(ph * 4 + p.s * 90) * .0007
                    if p.y < -.05 then p.y = 1.05; p.x = math.random() end
                    p.f.Position = UDim2.new(p.x, 0, p.y, 0)
                end
                acc = acc + dt; frames = frames + 1
                if acc >= .25 then
                    fps = frames / acc; acc, frames = 0, 0
                    table.remove(hist, 1); hist[N] = fps
                    local mn, mx, sum, cnt = 1e9, 0, 0, 0
                    for _, v in ipairs(hist) do if v > 0 then mn = math.min(mn, v); mx = math.max(mx, v); sum = sum + v; cnt = cnt + 1 end end
                    local top = math.max(60, mx)
                    for i = 1, N do
                        local v = hist[i]
                        local col = v >= 55 and Color3.fromRGB(235, 235, 245) or (v >= 30 and Color3.fromRGB(255, 205, 90) or Color3.fromRGB(255, 90, 90))
                        TweenService:Create(bars[i], TweenInfo.new(.2), {Size = UDim2.new(1 / N, -2, math.clamp(v / top, 0, 1), 0), BackgroundColor3 = col}):Play()
                    end
                    if cnt > 0 then mm.Text = string.format("mín %d  -  média %d  -  máx %d", mn, sum / cnt, mx) end
                    local ping = 0
                    pcall(function() ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() end)
                    pingV.Text = string.format("%d ms", ping)
                end
                shown = shown + (fps - shown) * math.min(1, dt * 8)
                local fr = math.floor(shown + .5)
                fpsV.Text = tostring(fr); gv.Text = fr .. " FPS"
                local cur = os.clock() - t0
                local total = saved + cur
                st.Text = fmt(total)
                chBar.Size = UDim2.new((total % 3600) / 3600, 0, 1, 0)
                chG.Offset = Vector2.new(-1 + (ph % 1.4) / 1.4 * 2, 0)
                if os.clock() - lastSave > 10 then lastSave = os.clock(); save() end
            end)
            hostPage.Destroying:Connect(function() save(); for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end end)
            pcall(function() game:BindToClose(save) end)
            -- entrada animada
            for i, o in ipairs({hero, row, exc, gc}) do
                local sc2 = Instance.new("UIScale"); sc2.Scale = .9; sc2.Parent = o
                task.delay(i * .08, function() TweenService:Create(sc2, TweenInfo.new(.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play() end)
            end
        end

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
                arrowBtn.ZIndex = 5; corner(arrowBtn, 9); stroke(arrowBtn, T.border, 0, 1)
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

                    -- Copiar / Executar: MESMO efeito do botao Pegar (pressFx + reflexo branco horizontal ao clicar + cor de resultado)
                    local function addSweep(btn)
                        local sw = Instance.new("Frame")
                        sw.Name = "Sweep"; sw.Size = UDim2.new(1, 0, 1, 0); sw.BackgroundColor3 = Color3.new(1, 1, 1)
                        sw.BorderSizePixel = 0; sw.ZIndex = 16; sw.Active = false; sw.Visible = false; sw.Parent = btn
                        corner(sw, 7)
                        local sg = Instance.new("UIGradient")
                        sg.Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(.35, 1),
                            NumberSequenceKeypoint.new(.5, .3), NumberSequenceKeypoint.new(.65, 1), NumberSequenceKeypoint.new(1, 1)
                        })
                        sg.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(.35,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(.65,Color3.fromRGB(46,204,113)),ColorSequenceKeypoint.new(1,Color3.fromRGB(46,204,113))}); sg.Rotation = 20; sg.Offset = Vector2.new(-1, 0); sg.Parent = sw
                        local busy = false
                        return function(dur)
                            if busy or not btn.Parent then return end
                            busy = true
                            sg.Offset = Vector2.new(-1, 0); sw.Visible = true
                            TweenService:Create(sg, TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Offset = Vector2.new(1, 0)}):Play()
                            task.delay(dur + .05, function() busy = false; sw.Visible = false end)
                        end
                    end

                    local copyBtn, applyCopy = makeActionButton("Copy", copyW, 2, T.silver, "copy", "\240\159\147\139", copyLabel, T.darkText)
                    pressFx(copyBtn)
                    local copyPlaySweep = addSweep(copyBtn)
                    local runBtn, applyRun = makeActionButton("Execute", runW, 3, T.silver, "play", "\226\150\182", runLabel, T.darkText)
                    pressFx(runBtn)
                    local runPlaySweep = addSweep(runBtn)

                    local copyToken = 0
                    copyBtn.Activated:Connect(function()
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
                        if copied then copyPlaySweep(.6); applyCopy(GREEN, T.darkText, copyLabel) else applyCopy(RED, WHITE, copyLabel) end
                        task.delay(1.6, function()
                            if my == copyToken and copyBtn.Parent then applyCopy(T.silver, T.darkText, copyLabel) end
                        end)
                    end)

                    local runToken = 0
                    runBtn.Activated:Connect(function()
                        runToken = runToken + 1
                        local my = runToken
                        task.spawn(function()
                            local okCb, res = pcall(callback)
                            local success = okCb and res ~= false
                            if not okCb then warn("[Orion Lib] Erro no callback: " .. tostring(res)) end
                            if my ~= runToken or not runBtn.Parent then return end
                            if success then runPlaySweep(.6); applyRun(GREEN, T.darkText, runLabel) else applyRun(RED, WHITE, runLabel) end
                            task.delay(1.8, function()
                                if my == runToken and runBtn.Parent then applyRun(T.silver, T.darkText, runLabel) end
                            end)
                        end)
                    end)
                    local function cardOff()
                        TweenService:Create(row,TweenInfo.new(.15),{BackgroundColor3=T.panel}):Play()
                        TweenService:Create(rowStroke,TweenInfo.new(.15),{Color=T.border,Transparency=.1}):Play()
                    end
                    row.MouseEnter:Connect(function()
                        TweenService:Create(row,TweenInfo.new(.15),{BackgroundColor3=T.panelHover}):Play()
                        TweenService:Create(rowStroke,TweenInfo.new(.15),{Color=T.silver2,Transparency=.05}):Play()
                    end)
                    row.MouseLeave:Connect(cardOff)
                    UserInputService.InputEnded:Connect(function(io) if io.UserInputType == Enum.UserInputType.Touch then task.delay(.08, cardOff) end end)
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
                local function set(v, fire) state=not not v; slideTo(dot, state and UDim2.new(1,-16,.5,-6.5) or UDim2.new(0,3,.5,-6.5)); TweenService:Create(dot,TweenInfo.new(.15),{BackgroundColor3=state and T.darkText or T.silver}):Play(); TweenService:Create(track,TweenInfo.new(.15),{BackgroundColor3=state and T.silver or T.field}):Play();  if fire~=false then pcall(callback,state) end end
                bindTap(hit, function() set(not state,true) end)
                                local ctl = {Set=function(_,v,fire) set(v,fire) end,GetValue=function() return state end,SetSubtitle=function(_,v) if subLbl then subLbl.Text=tostring(v) end end}
                table.insert(OrionLib._toggles, ctl)
                return ctl
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
                local function shine(f, r) local sh = Instance.new("Frame"); sh.Size = UDim2.new(1,0,1,0); sh.BackgroundColor3 = T.accent; sh.BackgroundTransparency = 1
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
                    local ctl = {Set = function(_, v, fr) set(v, fr) end, GetValue = function() return state end}; table.insert(OrionLib._toggles, ctl); return ctl
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
                    slideTo(hd, hs and UDim2.new(1,-15,.5,0) or UDim2.new(0,3,.5,0)); tw(hd, {BackgroundColor3 = hs and T.darkText or T.silver2})
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

                local function shine(f, r) local sh = Instance.new("Frame"); sh.Size = UDim2.new(1,0,1,0); sh.BackgroundColor3 = T.accent; sh.BackgroundTransparency = 1
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
                    local ctl = {Set = function(_, v, fr) set(v, fr) end, GetValue = function() return state end}; table.insert(OrionLib._toggles, ctl); return ctl
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
                    slideTo(hd, hs and UDim2.new(1,-15,.5,0) or UDim2.new(0,3,.5,0)); tw(hd, {BackgroundColor3 = hs and T.darkText or T.silver2})
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
                    if sc.ResetValue ~= nil then
                        tl.Size = UDim2.new(1,-86,0,14)
                        local rb = Instance.new("TextButton"); rb.Name = "ResetBtn"; rb.Text = ""; rb.AutoButtonColor = false
                        rb.Size = UDim2.new(0,18,0,16); rb.AnchorPoint = Vector2.new(1,0); rb.Position = UDim2.new(1,-54,0,2)
                        rb.BackgroundColor3 = T.field; rb.BorderSizePixel = 0; rb.ZIndex = 5; rb.Parent = row; corner(rb,5); stroke(rb, T.border, 0, 1)
                        local ri = icon("rotate-ccw"); if ri == "" then ri = icon("undo-2") end
                        if ri ~= "" then
                            local im = Instance.new("ImageLabel"); im.BackgroundTransparency = 1; im.Size = UDim2.new(0,11,0,11)
                            im.AnchorPoint = Vector2.new(.5,.5); im.Position = UDim2.new(.5,0,.5,0); im.Image = ri; im.ImageColor3 = T.silver; im.ZIndex = 6; im.Parent = rb
                        else
                            rb.Text = "↺"; rb.Font = Enum.Font.GothamBold; rb.TextSize = 12; rb.TextColor3 = T.silver
                        end
                        bindTap(rb, function() set(sc.ResetValue, true) end)
                    end
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
                            local tl=label(card,tostring(v.name or "Script"),12,T.white,Enum.Font.GothamBold); tl.Position=UDim2.new(0,72,0,7); tl.Size=UDim2.new(1,-84,0,16); tl.TextTruncate=Enum.TextTruncate.AtEnd
                            local dtxt=(tostring(v.description or ""):gsub("%s+"," "))
                            local dl=label(card,dtxt,10,T.muted); dl.Position=UDim2.new(0,72,0,24); dl.Size=UDim2.new(1,-84,0,16); dl.TextTruncate=Enum.TextTruncate.AtEnd
                            if dc.OnItemClick then
                                local hitc=button(card,"RemoveHit",UDim2.new(1,0,1,0),UDim2.new(),Color3.new()); hitc.BackgroundTransparency=1; hitc.ZIndex=10
                                card.MouseEnter:Connect(function() card.BackgroundColor3=Color3.fromRGB(54,24,25) end)
                                card.MouseLeave:Connect(function() card.BackgroundColor3=T.field end)
                                bindTap(hitc, function() pcall(dc.OnItemClick, v) end)
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
                rebuild(values); bindTap(hit, function() if dc.Display then if #values==0 then pcall(Bell.push,"error","Orion Hub",(OrionLib.IsPT~=false) and "Nenhum script selecionado para a execução automática." or "No script selected for auto-execute.") end return end menu.Visible=not menu.Visible; arrow.Rotation=menu.Visible and 180 or 0 end)
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
    function window:DestroyGui() if screen then pcall(function() screen:SetAttribute("OrionClosing", true) end); screen:Destroy() end OrionLib.KillBlur(); task.delay(.5, OrionLib.KillBlur) end
    function window:SetTheme() end
    function window:GetThemes() return {"Orion Hub"} end
    function window:GetThemeColor() return T.bg end
    function window:SetAccentColor() end
    function window:SetTransparency() end
    function window:LibSettings() end

    -- Keep the familiar API's configuration version and neutral accent.
    return window
end

function OrionLib:FloatBtn(cfg)
    pcall(function()
        for _, g in ipairs(game:GetService("CoreGui"):GetChildren()) do
            if g.Name == "OrionStudios_Float" or g.Name == "WinUIFloatBtn" or (type(g.Name)=="string" and g.Name:find("Float")) then g:Destroy() end
        end
    end)

    cfg=cfg or {}
    local screen=Instance.new("ScreenGui"); screen.Name="OrionStudios_Float"; OrionLib.Protect(screen); screen.ResetOnSpawn=false; screen.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; pcall(function() screen.DisplayOrder=2147483647; screen.IgnoreGuiInset=true end)
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(screen) end; screen.Parent=(gethui and gethui()) or CoreGui end)
    if not screen.Parent then pcall(function() screen.Parent=Players.LocalPlayer:WaitForChild("PlayerGui") end) end
    local destroyedByUser=false
    task.spawn(function()
        while not destroyedByUser do
            task.wait(0.5)
            pcall(function()
                if not screen.Enabled then screen.Enabled=true end
                if screen.DisplayOrder~=2147483647 then screen.DisplayOrder=2147483647 end
                local want=(gethui and gethui()) or CoreGui
                if screen.Parent==nil or (screen.Parent~=want and screen.Parent~=Players.LocalPlayer:FindFirstChild("PlayerGui")) then
                    local ok=pcall(function() screen.Parent=want end)
                    if not ok or not screen.Parent then pcall(function() screen.Parent=Players.LocalPlayer:WaitForChild("PlayerGui",3) end) end
                end
            end)
        end
    end)
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
    -- rosto do botao principal: fica na frente dos atalhos, que nascem/somem por tras dele
    frame.BackgroundTransparency=1
    local face=Instance.new("Frame"); face.Name="Face"; face.Size=UDim2.new(1,0,1,0); face.BackgroundColor3=T.bg; face.BorderSizePixel=0; face.ZIndex=4; face.Parent=frame; corner(face,13)
    image.ZIndex=6
    -- efeito de "pressionado": ao passar o dedo/mouse por cima e ao tocar, o fundo do icone clareia
    do
        local TS = game:GetService("TweenService")
        local hov, prs = false, false
        local function paint()
            local ti = TweenInfo.new(.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            TS:Create(face, ti, {BackgroundColor3 = (prs or hov) and T.panelHover or T.bg}):Play()
        end
        hit.MouseEnter:Connect(function() hov = true; paint() end)
        hit.MouseLeave:Connect(function() hov = false; prs = false; paint() end)
        hit.InputBegan:Connect(function(io)
            if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then prs = true; paint() end
        end)
        UserInputService.InputEnded:Connect(function(io)
            if (io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch) and prs then
                prs = false
                if io.UserInputType == Enum.UserInputType.Touch then hov = false end
                paint()
            end
        end)
    end
    -- o botao de hit cobre o frame, entao o arrasto precisa ser ligado nele
    local spawnPos = frame.Position -- posicao de nascimento (ao lado da interface)
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
        if io.UserInputType==Enum.UserInputType.MouseButton1 or io.UserInputType==Enum.UserInputType.Touch then
            local wasDrag = startPos ~= nil
            local wasMoved = dragged
            startPos=nil
            if wasDrag then task.spawn(function()
                task.wait(.12)
                pcall(function()
                    -- solto em cima da interface: volta pra posicao de spawn
                    if main and main.Parent and main.Visible and main.AbsoluteSize.X > 0 then
                        local sg = main:FindFirstAncestorOfClass("ScreenGui")
                        if not sg or sg.Enabled then
                            local inset = game:GetService("GuiService"):GetGuiInset()
                            local ms, fp = main.AbsoluteSize, frame.AbsolutePosition
                            local function over(dy)
                                local mp = main.AbsolutePosition + Vector2.new(0, dy)
                                return fp.X < mp.X + ms.X and fp.X + sz > mp.X and fp.Y < mp.Y + ms.Y and fp.Y + sz > mp.Y
                            end
                            if over(inset.Y) or over(0) then
                                game:GetService("TweenService"):Create(frame, TweenInfo.new(.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = spawnPos}):Play()
                                return
                            end
                        end
                    end
                    local vp, ap, m = screen.AbsoluteSize, frame.AbsolutePosition, 8
                    local cx = math.clamp(ap.X, m, math.max(m, vp.X - sz - m))
                    local cy = math.clamp(ap.Y, m, math.max(m, vp.Y - sz - m))
                    if math.abs(cx-ap.X) > .5 or math.abs(cy-ap.Y) > .5 then
                        local p = frame.Position
                        game:GetService("TweenService"):Create(frame, TweenInfo.new(.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                            {Position = UDim2.new(p.X.Scale, p.X.Offset + (cx-ap.X), p.Y.Scale, p.Y.Offset + (cy-ap.Y))}):Play()
                    end
                end)
            end) end
        end
    end)
    pcall(function() _G.__OrionFloatFrame = frame end)
    draggable(hit,frame)
    hit.ZIndex = 7
    -- atalhos animados (so no 1o uso depois que entrou no jogo): 1o clique abre Home/Scripts, 2o clique abre a interface
    local function getShortcuts()
        if type(cfg.Shortcuts) == "function" then
            local ok, r = pcall(cfg.Shortcuts)
            return (ok and type(r) == "table") and r or {}
        end
        return cfg.Shortcuts or {}
    end
    local scDone, scOpen, scBtns = false, false, {}
    local function scClose(animate)
        scOpen = false
        local list = scBtns; scBtns = {}
        for _, b in ipairs(list) do
            if animate and b.Parent then
                local tw = game:GetService("TweenService"):Create(b, TweenInfo.new(.22, Enum.EasingStyle.Back, Enum.EasingDirection.In),
                    {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0, sz / 2, 0, sz / 2)})
                tw.Completed:Connect(function() pcall(function() b:Destroy() end) end); tw:Play()
            else pcall(function() b:Destroy() end) end
        end
    end
    local function scOpenShortcuts()
        scOpen = true
        local shortcuts = getShortcuts()
        local ms = 34
        -- posiciona TODOS os atalhos em aneis ao redor do botao, so em pontos visiveis na tela
        local n = #shortcuts
        local vp = screen.AbsoluteSize
        local ap = frame.AbsolutePosition
        local cx, cy = ap.X + sz / 2, ap.Y + sz / 2
        local mg = ms / 2 + 4
        local function onScreen(a, R)
            local px, py = cx + R * math.cos(a), cy + R * math.sin(a)
            return px >= mg and px <= vp.X - mg and py >= mg and py <= vp.Y - mg
        end
        -- circulo organizado: angulos iguais; raio cresce ate ninguem encostar em ninguem
        local spots, minStep = {}, 0
        local R = math.max(sz / 2 + ms / 2 + 12, (ms + 10) * n / (2 * math.pi))
        for _ = 1, 10 do
            minStep = (ms + 10) / R
            local SAMPLES = 120
            local valid, allOk = {}, true
            for j = 0, SAMPLES - 1 do
                valid[j] = onScreen(-math.pi / 2 + 2 * math.pi * j / SAMPLES, R)
                if not valid[j] then allOk = false end
            end
            if allOk then
                for k = 0, n - 1 do spots[#spots + 1] = -math.pi / 2 + 2 * math.pi * k / n end
                break
            end
            -- maior arco continuo visivel (circular)
            local bestStart, bestLen, j = 0, 0, 0
            while j < SAMPLES do
                if valid[j] then
                    local len = 0
                    while len < SAMPLES and valid[(j + len) % SAMPLES] do len = len + 1 end
                    if len > bestLen then bestStart, bestLen = j, len end
                    j = j + len + 1
                else j = j + 1 end
            end
            local span = (bestLen - 1) * 2 * math.pi / SAMPLES
            if bestLen > 0 and (n <= 1 or span >= (n - 1) * minStep) then
                local a0 = -math.pi / 2 + 2 * math.pi * bestStart / SAMPLES
                local step = (n <= 1) and 0 or span / (n - 1)
                if n > 1 then step = math.min(step, minStep * 1.6) end
                local used = step * (n - 1)
                a0 = a0 + (span - used) / 2 -- centraliza no arco livre
                for k = 0, n - 1 do spots[#spots + 1] = a0 + step * k end
                break
            end
            R = R + 12
        end
        for k, a in ipairs(spots) do
            spots[k] = {sz / 2 + R * math.cos(a) - ms / 2, sz / 2 + R * math.sin(a) - ms / 2}
        end
        for i, sc in ipairs(shortcuts) do
            local b = Instance.new("TextButton"); b.Text = ""; b.AutoButtonColor = false; b.BorderSizePixel = 0
            b.BackgroundColor3 = T.bg; b.AnchorPoint = Vector2.new(0, 0); b.ZIndex = 2
            b.Size = UDim2.new(0, 0, 0, 0); b.Position = UDim2.new(0, sz / 2, 0, sz / 2); b.Parent = frame
            corner(b, 11); stroke(b, T.silver2, .15, 1.5)
            local im = Instance.new("ImageLabel"); im.Size = UDim2.new(0, 18, 0, 18); im.AnchorPoint = Vector2.new(.5, .5)
            im.Position = UDim2.new(.5, 0, .5, 0); im.BackgroundTransparency = 1; im.ZIndex = 3
            local ic = icon(sc.Icon); im.Image = (ic ~= "") and ic or ""; im.ImageColor3 = T.silver; im.Parent = b
            scBtns[#scBtns + 1] = b
            do -- clareia ao passar o dedo/mouse por cima e ao tocar (igual ao botao principal)
                local hov, prs = false, false
                local function paint()
                    game:GetService("TweenService"):Create(b, TweenInfo.new(.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        {BackgroundColor3 = (hov or prs) and T.panelHover or T.bg}):Play()
                end
                b.MouseEnter:Connect(function() hov = true; paint() end)
                b.MouseLeave:Connect(function() hov = false; prs = false; paint() end)
                b.InputBegan:Connect(function(io)
                    if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then prs = true; paint() end
                end)
                b.InputEnded:Connect(function(io)
                    if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
                        prs = false
                        if io.UserInputType == Enum.UserInputType.Touch then hov = false end
                        paint()
                    end
                end)
            end
            local sp = spots[i] or spots[1]
            task.delay((i - 1) * .07, function()
                if b.Parent then
                    game:GetService("TweenService"):Create(b, TweenInfo.new(.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                        {Size = UDim2.new(0, ms, 0, ms), Position = UDim2.new(0, sp[1], 0, sp[2])}):Play()
                end
            end)
            bindTap(b, function()
                if not scOpen then return end
                scClose(true)
                task.delay(.28, function() -- primeiro a animacao, depois a interface
                    if main and main.Parent then main.Visible = true end
                    if sc.Callback then pcall(sc.Callback) end
                end)
            end)
        end
    end
    local homePos = frame.Position -- posicao original (encostado na lateral da interface)
    local function avoidMain()
        pcall(function()
            if not (main and main.Parent and main.Visible and frame.Parent) then return end
            local inset = Vector2.new(0, 0)
            pcall(function() inset = game:GetService("GuiService"):GetGuiInset() end)
            local mp = Vector2.new(main.AbsolutePosition.X, main.AbsolutePosition.Y + inset.Y)
            local ms = main.AbsoluteSize
            local function hits(p) return p.X < mp.X + ms.X and p.X + sz > mp.X and p.Y < mp.Y + ms.Y and p.Y + sz > mp.Y end
            if not hits(frame.AbsolutePosition) then return end -- ja esta fora da interface
            local vp = screen.AbsoluteSize
            local target = homePos
            local abs = Vector2.new(vp.X * homePos.X.Scale + homePos.X.Offset, vp.Y * homePos.Y.Scale + homePos.Y.Offset)
            if hits(abs) then -- a posicao original tambem ficou embaixo da interface: usa a lateral dela
                local x = math.max(8, mp.X - sz - 10)
                target = UDim2.new(0, x, 0, math.clamp(mp.Y + ms.Y / 2 - sz / 2, 8, math.max(8, vp.Y - sz - 8)))
            end
            game:GetService("TweenService"):Create(frame, TweenInfo.new(.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = target}):Play()
        end)
    end
    pcall(function()
        if main then main:GetPropertyChangedSignal("Visible"):Connect(function()
            if main.Visible then
                if scOpen then scClose(true) end
                task.delay(.06, avoidMain) -- se o botao ficou em cima da interface, volta pro lugar original
            end
        end) end
    end)
    bindTap(hit, function()
        if dragged then dragged=false; return end
        -- sempre que a interface estiver fechada, o clique abre os atalhos; clicar de novo abre a interface
        if #getShortcuts() > 0 and main and main.Parent and (scOpen or not main.Visible) then
            if not scOpen then scOpenShortcuts(); return end
            scClose(true)
            task.delay(.28, function() if main and main.Parent then main.Visible = true end end)
            return
        end
        if main and main.Parent then main.Visible=not main.Visible elseif cfg.Callback then pcall(cfg.Callback) end
    end)
    return {Destroy=function() destroyedByUser=true; screen:Destroy() end,SetIcon=function(_,v) image.Image=icon(v)~="" and icon(v) or v end,SetColor=function(_,v) local st=frame:FindFirstChildOfClass("UIStroke"); if st then st.Color=v end end}
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
    Bell.push(t, cfg.Title or "Orion Hub", cfg.Content or cfg.Description or cfg.Text or "")
    return { Close = function() end }
end

OrionLib.LibVersion = 14
_G.OrionLib=OrionLib
_G.WinUILib=OrionLib
_G.LucideIcons=Icons
if type(shared)=="table" then shared.OrionLib=OrionLib end
return OrionLib
