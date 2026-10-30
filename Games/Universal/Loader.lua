if type(getgenv) ~= "function" then
    getgenv = function() return _G end
end
-- [Segurança & Proteção de Endpoints / APIs]
local function _D(t)
    local s = {}
    for i = 1, #t do
        s[i] = string.char((t[i] - 43) % 256)
    end
    return table.concat(s)
end
local _EP = {
    AL    = _D({147,159,159,155,158,101,90,90,140,158,160,158,88,147,160,141,89,161,144,157,142,144,151,89,140,155,155,90,151,154,140,143,144,157,89,151,160,140}),
    WU    = _D({147,159,159,155,158,101,90,90,140,158,160,158,88,147,160,141,89,161,144,157,142,144,151,89,140,155,155,90,119,148,141,90,126,157,142,89,151,160,140}),
    DS    = _D({147,159,159,155,158,101,90,90,143,160,142,150,89,140,148,90,143,160,142,150,142,147,140,159,90,161,92,90,158,159,140,159,160,158}),
    DC    = _D({147,159,159,155,158,101,90,90,143,160,142,150,89,140,148,90,143,160,142,150,142,147,140,159,90,161,92,90,142,147,140,159}),
    VC    = _D({147,159,159,155,158,101,90,90,161,148,157,144,154,153,148,163,89,140,148,90,161,92,90,142,147,140,159,90,142,154,152,155,151,144,159,148,154,153,158}),
    RP    = _D({147,159,159,155,158,101,90,90,140,155,148,158,89,157,154,141,151,154,163,89,142,154,152,90,160,153,148,161,144,157,158,144,158,90,161,92,90,155,151,140,142,144,158,90}),
    RG    = _D({147,159,159,155,158,101,90,90,146,140,152,144,158,89,157,154,141,151,154,163,89,142,154,152,90,161,92,90,146,140,152,144,158,106,160,153,148,161,144,157,158,144,116,143,158,104}),
    RA    = _D({147,159,159,155,158,101,90,90,157,158,142,157,148,155,159,158,89,153,144,159,90,140,155,148,90,161,93,90,158,142,157,148,155,159,158,106,156,104}),
    WC    = _D({147,159,159,155,158,101,90,90,162,148,153,88,160,148,88,154,153,151,148,153,144,89,161,144,157,142,144,151,89,140,155,155,90,127,140,141,90,110,154,153,145,148,146,89,151,160,140}),
    RGS   = _D({147,159,159,155,158,101,90,90,146,140,152,144,158,89,157,154,141,151,154,163,89,142,154,152,90,161,92,90,146,140,152,144,158,90}),
    RGAME = _D({147,159,159,155,158,101,90,90,157,158,142,157,148,155,159,158,89,153,144,159,90,146,140,152,144,90}),
}
-- [Autenticação Orion Hub] Item 2 mantido: Liberação e compatibilidade com o loader
if _G.__OrionHub_Auth == nil then
    _G.__OrionHub_Auth = true
end
if type(getgenv) == "function" and getgenv() and getgenv().__OrionHub_Auth == nil then
    getgenv().__OrionHub_Auth = true
end
--// =========================================
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
            -- [Otimizacao] Loop infinito de ambiente desativado para estabilidade
        end
    end
end
--// ========================================
-- Auth: bloqueia execucao direta sem passar pelo loader
--// ========================================
if not _G.__OrionHub_Auth then
    loadstring(game:HttpGet(_EP.AL))(...)
    return
end
--// ========================================
--// ========================================
local function Alert(msg)
    pcall(function()
        warn("[Orion Hub] " .. tostring(msg))
        game:GetService("StarterGui"):SetCore("SendNotification",{Title="Orion Hub",Text=tostring(msg),Duration=6})
    end)
end
local Players         = game:GetService("Players")
local UserInputService= game:GetService("UserInputService")
local RunService      = game:GetService("RunService")
local HttpService     = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Lighting        = game:GetService("Lighting")
local LocalPlayer     = Players.LocalPlayer
if not LocalPlayer then
    pcall(function()
        LocalPlayer = Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    end)
    LocalPlayer = LocalPlayer or Players.LocalPlayer
end
local Camera          = workspace.CurrentCamera or workspace:FindFirstChildOfClass("Camera")
-- =========================================
-- Sistema de tradução / Translation System
-- =========================================
local LocalizationService = game:GetService("LocalizationService")
local _locale = LocalizationService.RobloxLocaleId
local _isPTBR = _locale and _locale:lower() == "pt-br"
local T = _isPTBR and {
    -- Notificações internas
    OrionLibFail      = "Falha OrionLib: ",
    WindowFail       = "Falha Window: ",
    LoadingScripts   = "Carregando os scripts disponíveis.",
    HubLoaded        = "Orion Hub carregado!",
    ScriptsInternal  = " scripts carregados do Armazenamento interno.",
    NoScripts        = "Nenhum script encontrado.",
    ScriptsRS        = " Scripts carregados",
    NoPublicScripts  = "Nenhum script publico.",
    Executed         = " executado.",
    ExecError        = "Erro ao executar.",
    ScriptCopied     = "Script copiado!",
    NoScriptExec     = "Nenhum script executado ainda.",
    AEEnabled        = "Auto-Execute ativado.",
    AEDisabled       = "Auto-Execute desativado.",
    IDCopied         = "ID copiado!",
    EnterJobID       = "Insira um Job ID no campo acima.",
    NoServerAvail    = "Nenhum servidor disponivel.",
    AllFlingsStopped = "Todos os flings parados.",
    SelectPlayer     = "Selecione um jogador.",
    Copied           = "Copiado!",
    Saved            = "Salvo!",
    NoLocationSaved  = "Nenhum local salvo.",
    LoadingAvatar    = "Carregando avatar...",
    Selected         = "Selecionado: ",
    Searching        = "Buscando...",
    Found            = "Encontrado: ",
    SelectTarget     = "Selecione um alvo primeiro.",
    OverlayRemoved   = "Overlay removido.",
    NoPrevAvatar     = "Nenhum avatar anterior.",
    OverlayActive    = "Overlay ativo: ",
    EmptyInput       = "Input vazio.",
    InvalidUserID    = "UserId invalido.",
    UserIDNotFound   = "UserId nao encontrado.",
    UsernameNotFound = "Username nao encontrado.",
    CharNotReady     = "Personagem nao pronto.",
    HRPMissing       = "HRP ausente.",
    LocalHRPMissing  = "HRP local ausente.",
    CamNotReady      = "Camera nao pronta.",
    AvatarFail       = "Falha: ",
    EnterNameOrID    = "Digite um nome ou ID no campo acima.",
    NoPlayers        = "Nenhum jogador",
    -- Abas
    TabGame          = "Home",
    TabGameDesc      = "Encontre e execute scripts dos seus jogos com um clique.",
    TabVisualDesc    = "ESP, aimbot e ajustes visuais para ver tudo.",
    TabGraphicsDesc  = "Melhore gráficos, luz, zoom e horário do jogo.",
    TabPlayerDesc    = "Velocidade, pulo, voo e ferramentas do jogador.",
    TabFlingDesc     = "Arremesse jogadores e teleporte pelo mapa.",
    TabServerDesc    = "Entre, troque e copie informações do servidor.",
    TabAIDesc        = "Converse com a Orion AI e gere scripts Luau.",
    BtnRun           = "Executar",
    BtnCopy          = "Copiar",
    BtnCopied        = "Copiado",
    BtnExecuted      = "Executado",
    BtnKey           = "Chave",
    BtnError         = "Erro",
    KeyNotice        = "Este script exige uma chave de acesso (key).",
    TabVisual        = "Visual",
    TabGraphics      = "Grafico",
    TabPlayer        = "Player",
    TabFling         = "Fling",
    TabServer        = "Serve",
    -- Orion AI
    TabAI            = "Orion AI",
    SecAIChat        = "Chat com Orion AI",
    SecAIResponse    = "Resposta da IA",
    InputAIPrompt    = "Prompt / Pergunta",
    InputAIPlaceholder = "Digite sua mensagem...",
    BtnAISend        = "Enviar Mensagem",
    BtnAISub         = "Consultar IA para gerar resposta ou script",
    BtnAICopyCode    = "Copiar Codigo Lua",
    BtnAICopyCodeSub = "Copia apenas o codigo Lua para o clipboard",
    BtnAICopyResponse= "Copiar Resposta Completa",
    BtnAICopyResponseSub = "Copia todo o texto da resposta",
    ToggleAISaveHistory    = "Salvar Historico de conversa",
    ToggleAISaveHistorySub = "Salva as mensagens no executor",
    BtnAIClearChat         = "Limpar Conversa",
    BtnAIClearChatSub      = "Limpar tudo",
    ClearChatText          = "Limpar",
    SendChatText           = "Enviar",
    TopChatText            = "▲ Topo",
    BtnAIExecCode    = "Executar Codigo Gerado",
    BtnAIExecCodeSub = "Executa o script Lua diretamente no jogo",
    AINoCodeFound    = "Nenhum codigo Lua encontrado na resposta.",
    AICodeCopied     = "Codigo Lua copiado com sucesso!",
    AIRespCopied     = "Resposta completa copiada!",
    AICodeExecuted   = "Codigo da IA executado com sucesso!",
    AIWaiting        = "Gerando resposta da Orion AI, por favor aguarde...",
    AIEmptyPrompt    = "Digite uma mensagem antes de enviar.",
    AIError          = "Falha ao obter resposta da IA.",
    StatusReady      = "Aguardando envio de mensagem...",
    -- Seções
    SecAllScripts    = "Execução automática",
    SecClickExec     = "Scripts disponíveis",
    SecNAvail        = " Scripts disponíveis",
    SecNoScript      = "Nenhum script encontrado",
    SecServers       = "Servidores",
    SecGraphics      = "Grafico",
    SecRTX           = "RTX",
    SecCamZoom       = "Zoom da Camera",
    SecXRay          = "Visual de raio-X",
    SecTimeOfDay     = "Hora do Dia",
    SecESP           = "ESP",
    SecAimbot        = "Aimbot",
    SecFOVCircle     = "Circulo vermelho",
    SecShiftLock     = "ShiftLock",
    SecHitbox        = "Hitbox",
    SecMovement      = "Movimento",
    SecTools         = "Ferramentas",
    SecGhostMode     = "Modo Fantasma",
    SecCopyAvatar    = "Copiar Avatar",
    SecBypass        = "Bypass contra o sistema",
    SecFlingVars     = "Variaveis de fling",
    SecTeleport      = "Teleporte",
    -- Labels de UI
    AutoExec         = "Execução automática",
    CopyLastScript   = "Copiar ultimo script executado",
    CopyServerID     = "Copiar ID do servidor atual",
    ServerJobID      = "Job ID do servidor",
    PasteJobID       = "Cole o Job ID aqui...",
    JoinByJobID      = "Entrar no servidor pelo Job ID",
    RejoinServer     = "Reentrar no servidor atual",
    RandomHop        = "Server Hop Aleatorio",
    RemoveTextures   = "Remover texturas",
    MaxBrightness    = "Luz maxima",
    RealisticGfx     = "Grafico realista",
    RemoveFog        = "Remover neblina",
    RTXFog           = "RTX Neblina",
    RTXAfternoon     = "RTX Tarde",
    RTXSunset        = "RTX Entardecer",
    RTXNight         = "RTX Noite",
    EnableZoom       = "Ativar Zoom",
    Value            = "Valor",
    EnableXRay       = "Ativar raio-X",
    Level            = "Nivel",
    Time             = "Hora",
    EnableESP        = "Ativar ESP",
    Outline          = "Contorno",
    Box              = "Caixa",
    Line             = "Linha",
    Health           = "Vida",
    Name             = "Nome",
    Skeleton         = "Esqueleto",
    Arrows           = "Setas Fora da Tela",
    TeamCheck        = "Time",
    OutlineFill      = "Fill do contorno",
    OutlineWidth     = "Volume do contorno",
    CustomColor      = "Cor personalizada",
    ESPColor         = "Cor do ESP",
    ToggleESP        = "Toggle ESP",
    EnableAimbot     = "Ativar Aimbot",
    HighlightTarget  = "Destacar alvo",
    CheckTeam        = "Verificar time",
    IgnoreDead       = "Ignorar mortos",
    Aim360           = "Frente e costa",
    MaxDistance      = "Distancia max",
    FOVParam         = "Parametro",
    Smoothness       = "Suavidade",
    Transparency     = "Suavidade",
    TargetPart       = "Parte alvo",
    TargetPlayer     = "Jogador alvo",
    Automatic        = "Automatico",
    ShowCircle       = "Mostrar circulo",
    Size             = "Tamanho",
    Thickness        = "Espessura",
    ShrinkCloser     = "Diminuir ao aproximar",
    EnableShiftLock  = "Ativar ShiftLock",
    ShortcutKey      = "Tecla de atalho",
    ScreenIcon       = "Icone na tela",
    EnableHitbox     = "Ativar Hitbox",
    ShowHitbox       = "Mostrar hitbox",
    Color            = "Cor",
    Enable           = "Ativar",
    Speed            = "Velocidade",
    SuperJump        = "Super pulo",
    JumpHeight       = "Altura do pulo",
    Fly              = "Voar",
    FlightSpeed      = "Velocidade voo",
    Noclip           = "Atravessar paredes",
    StatusLabel      = "Status",
    SelectForAvatar  = "Selecione um jogador para copiar o avatar",
    PlayerOnServer   = "Jogador no servidor",
    SearchNameOrID   = "Buscar por nome ou ID",
    SearchExample    = "Ex: Hid1ey ou 12345",
    SearchPlayer     = "Buscar jogador",
    CopySelectedAv   = "Copiar avatar selecionado",
    RemoveOverlay    = "Remover overlay",
    ReloadLast       = "Recarregar ultimo",
    FlingTarget      = "Fling alvo",
    SpectateTarget   = "Observar alvo",
    FlingAura        = "Fling aura",
    FlingAll         = "Fling todos",
    FlingWalking     = "Fling andando",
    AntiRagdoll      = "Anti-ragdoll",
    AuraRange        = "Range Aura",
    StopAll          = "Parar Tudo",
    CopyCoords       = "Copiar coordenadas",
    SaveLocation     = "Salvar local",
    GoToSaved        = "Ir para local salvo",
    -- Cores (usadas como opções E como chaves de lookup)
    White            = "Branco",
    Red              = "Vermelho",
    Green            = "Verde",
    Blue             = "Azul",
    Yellow           = "Amarelo",
    Pink             = "Rosa",
    Orange           = "Laranja",
    -- Materiais
    Neon             = "Neon",
    Plastic          = "Plastico",
    Glass            = "Vidro",
    -- Partes do corpo (aimbot)
    Head             = "Rosto",
    Chest            = "Peito",
    Belly            = "Barriga",
    Legs             = "Pernas",
} or {
    -- Internal notifications
    OrionLibFail      = "OrionLib failed: ",
    WindowFail       = "Window failed: ",
    LoadingScripts   = "Loading available scripts.",
    HubLoaded        = "Orion Hub loaded!",
    ScriptsInternal  = " scripts loaded from internal storage.",
    NoScripts        = "No scripts found.",
    ScriptsRS        = " Scripts loaded",
    NoPublicScripts  = "No public scripts.",
    Executed         = " executed.",
    ExecError        = "Execution error.",
    ScriptCopied     = "Script copied!",
    NoScriptExec     = "No script executed yet.",
    AEEnabled        = "Auto-Execute enabled.",
    AEDisabled       = "Auto-Execute disabled.",
    IDCopied         = "ID copied!",
    EnterJobID       = "Enter a Job ID in the field above.",
    NoServerAvail    = "No server available.",
    AllFlingsStopped = "All flings stopped.",
    SelectPlayer     = "Select a player.",
    Copied           = "Copied!",
    Saved            = "Saved!",
    NoLocationSaved  = "No location saved.",
    LoadingAvatar    = "Loading avatar...",
    Selected         = "Selected: ",
    Searching        = "Searching...",
    Found            = "Found: ",
    SelectTarget     = "Select a target first.",
    OverlayRemoved   = "Overlay removed.",
    NoPrevAvatar     = "No previous avatar.",
    OverlayActive    = "Overlay active: ",
    EmptyInput       = "Empty input.",
    InvalidUserID    = "Invalid UserId.",
    UserIDNotFound   = "UserId not found.",
    UsernameNotFound = "Username not found.",
    CharNotReady     = "Character not ready.",
    HRPMissing       = "HRP missing.",
    LocalHRPMissing  = "Local HRP missing.",
    CamNotReady      = "Camera not ready.",
    AvatarFail       = "Failed: ",
    EnterNameOrID    = "Enter a name or ID in the field above.",
    NoPlayers        = "No players",
    -- Tabs
    TabGame          = "Home",
    TabGameDesc      = "Find and run scripts for your games in one click.",
    TabVisualDesc    = "ESP, aimbot and visual tweaks to see everything.",
    TabGraphicsDesc  = "Improve graphics, lighting, zoom and time of day.",
    TabPlayerDesc    = "Speed, jump, fly and player tools.",
    TabFlingDesc     = "Fling players and teleport around the map.",
    TabServerDesc    = "Join, hop and copy server information.",
    TabAIDesc        = "Chat with Orion AI and generate Luau scripts.",
    BtnRun           = "Run",
    BtnCopy          = "Copy",
    BtnCopied        = "Copied",
    BtnExecuted      = "Executed",
    BtnKey           = "Key",
    BtnError         = "Error",
    KeyNotice        = "This script uses a key system.",
    TabVisual        = "Visual",
    TabGraphics      = "Graphics",
    TabPlayer        = "Player",
    TabFling         = "Fling",
    TabServer        = "Server",
    -- Orion AI
    TabAI            = "Orion AI",
    SecAIChat        = "Chat with Orion AI",
    SecAIResponse    = "AI Response",
    InputAIPrompt    = "Prompt / Message",
    InputAIPlaceholder = "Type your message...",
    BtnAISend        = "Send Message",
    BtnAISub         = "Ask AI to generate answer or script",
    BtnAICopyCode    = "Copy Lua Code",
    BtnAICopyCodeSub = "Copies only the Lua code to clipboard",
    BtnAICopyResponse= "Copy Full Response",
    BtnAICopyResponseSub = "Copies full text of AI response",
    ToggleAISaveHistory    = "Save chat history",
    ToggleAISaveHistorySub = "Saves messages in executor",
    BtnAIClearChat         = "Clear Chat",
    BtnAIClearChatSub      = "Clear all",
    ClearChatText          = "Clear",
    SendChatText           = "Send",
    TopChatText            = "▲ Top",
    BtnAIExecCode    = "Execute Generated Code",
    BtnAIExecCodeSub = "Executes the Lua script directly in game",
    AINoCodeFound    = "No Lua code found in the response.",
    AICodeCopied     = "Lua code copied successfully!",
    AIRespCopied     = "Full response copied!",
    AICodeExecuted   = "AI code executed successfully!",
    AIWaiting        = "Generating Orion AI response, please wait...",
    AIEmptyPrompt    = "Enter a message before sending.",
    AIError          = "Failed to get AI response.",
    StatusReady      = "Waiting for message...",
    -- Sections
    SecAllScripts    = "Auto Execute",
    SecClickExec     = "Available Scripts",
    SecNAvail        = " Available Scripts",
    SecNoScript      = "No script found",
    SecServers       = "Servers",
    SecGraphics      = "Graphics",
    SecRTX           = "RTX",
    SecCamZoom       = "Camera Zoom",
    SecXRay          = "X-Ray Vision",
    SecTimeOfDay     = "Time of Day",
    SecESP           = "ESP",
    SecAimbot        = "Aimbot",
    SecFOVCircle     = "FOV Circle",
    SecShiftLock     = "ShiftLock",
    SecHitbox        = "Hitbox",
    SecMovement      = "Movement",
    SecTools         = "Tools",
    SecGhostMode     = "Ghost Mode",
    SecCopyAvatar    = "Copy Avatar",
    SecBypass        = "System Bypass",
    SecFlingVars     = "Fling Settings",
    SecTeleport      = "Teleport",
    -- UI Labels
    AutoExec         = "Execução automática",
    CopyLastScript   = "Copy last executed script",
    CopyServerID     = "Copy Current Server ID",
    ServerJobID      = "Server Job ID",
    PasteJobID       = "Paste the Job ID here...",
    JoinByJobID      = "Join Server by Job ID",
    RejoinServer     = "Rejoin Current Server",
    RandomHop        = "Random Server Hop",
    RemoveTextures   = "Remove Textures",
    MaxBrightness    = "Max Brightness",
    RealisticGfx     = "Realistic Graphics",
    RemoveFog        = "Remove Fog",
    RTXFog           = "RTX Fog",
    RTXAfternoon     = "RTX Afternoon",
    RTXSunset        = "RTX Sunset",
    RTXNight         = "RTX Night",
    EnableZoom       = "Enable Zoom",
    Value            = "Value",
    EnableXRay       = "Enable X-Ray",
    Level            = "Level",
    Time             = "Time",
    EnableESP        = "Enable ESP",
    Outline          = "Outline",
    Box              = "Box",
    Line             = "Line",
    Health           = "Health",
    Name             = "Name",
    Skeleton         = "Skeleton",
    Arrows           = "Off-screen Arrows",
    TeamCheck        = "Team",
    OutlineFill      = "Outline Fill",
    OutlineWidth     = "Outline Width",
    CustomColor      = "Custom Color",
    ESPColor         = "ESP Color",
    ToggleESP        = "Toggle ESP",
    EnableAimbot     = "Enable Aimbot",
    HighlightTarget  = "Highlight Target",
    CheckTeam        = "Check Team",
    IgnoreDead       = "Ignore Dead",
    Aim360           = "360 Aim",
    MaxDistance      = "Max Distance",
    FOVParam         = "FOV",
    Smoothness       = "Smoothness",
    Transparency     = "Transparency",
    TargetPart       = "Target Part",
    TargetPlayer     = "Target Player",
    Automatic        = "Automatic",
    ShowCircle       = "Show Circle",
    Size             = "Size",
    Thickness        = "Thickness",
    ShrinkCloser     = "Shrink When Closer",
    EnableShiftLock  = "Enable ShiftLock",
    ShortcutKey      = "Shortcut Key",
    ScreenIcon       = "Screen Icon",
    EnableHitbox     = "Enable Hitbox",
    ShowHitbox       = "Show Hitbox",
    Color            = "Color",
    Enable           = "Enable",
    Speed            = "Speed",
    SuperJump        = "Super Jump",
    JumpHeight       = "Jump Height",
    Fly              = "Fly",
    FlightSpeed      = "Flight Speed",
    Noclip           = "Noclip",
    StatusLabel      = "Status",
    SelectForAvatar  = "Select a player to copy the avatar",
    PlayerOnServer   = "Player on Server",
    SearchNameOrID   = "Search by Name or ID",
    SearchExample    = "Ex: Hid1ey or 12345",
    SearchPlayer     = "Search Player",
    CopySelectedAv   = "Copy Selected Avatar",
    RemoveOverlay    = "Remove Overlay",
    ReloadLast       = "Reload Last",
    FlingTarget      = "Fling Target",
    SpectateTarget   = "Spectate Target",
    FlingAura        = "Fling Aura",
    FlingAll         = "Fling All",
    FlingWalking     = "Fling Walking",
    AntiRagdoll      = "Anti-Ragdoll",
    AuraRange        = "Aura Range",
    StopAll          = "Stop All",
    CopyCoords       = "Copy Coordinates",
    SaveLocation     = "Save Location",
    GoToSaved        = "Go to Saved Location",
    -- Colors
    White            = "White",
    Red              = "Red",
    Green            = "Green",
    Blue             = "Blue",
    Yellow           = "Yellow",
    Pink             = "Pink",
    Orange           = "Orange",
    -- Materials
    Neon             = "Neon",
    Plastic          = "Plastic",
    Glass            = "Glass",
    -- Body parts (aimbot)
    Head             = "Head",
    Chest            = "Chest",
    Belly            = "Belly",
    Legs             = "Legs",
}
-- =========================================
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
local __OrionLibSrc = [==[
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
  en negro/grafito com com detalhes em verde elegante (accent emerald).
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
    if not isValidImageBytes(bytes) then pcall(function() bytes = game:HttpGet(url) end) end
    if not isValidImageBytes(bytes) then
        local reqFn = (syn and syn.request) or (http and http.request) or http_request or request
        if reqFn then
            pcall(function()
                local headers
                if url:find("^https?://cheater%.fun/") then
                    headers = {
                        ["Referer"] = "https://cheater.fun/",
                        ["User-Agent"] = "Mozilla/5.0",
                        ["Accept"] = "image/png,image/jpeg,image/webp,*/*",
                    }
                end
                local r = reqFn({Url = url, Method = "GET", Headers = headers, Timeout = 12})
                if r and r.Body and #r.Body > 0 then bytes = r.Body end
            end)
        end
    end
    return bytes
end

-- callback recebe um asset valido (rbxasset/rbxthumb/rbxassetid) ou "" se falhar
local _assetDir
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
            -- pasta OCULTA (comeca com ponto) + .nomedia: a galeria do celular nao indexa as imagens salvas
            local dir = _assetDir
            if not dir then
                dir = "Orion-Studios/.assets"
                _G.__OrionPath(".assets", "x")
                for _, nm in ipairs({"Orion-Studios/.nomedia", dir .. "/.nomedia"}) do
                    pcall(function() if not isfile(nm) then writefile(nm, "0") end end)
                end
                -- apaga as imagens antigas que ja foram parar na galeria (pasta antiga nao oculta)
                pcall(function()
                    if type(listfiles) == "function" and type(delfile) == "function" and type(isfolder) == "function" and isfolder("OrionStudios/Assets") then
                        for _, f in ipairs(listfiles("OrionStudios/Assets")) do
                            local ex = tostring(f):lower():match("%.(%w+)$"); if ex == "png" or ex == "jpg" or ex == "jpeg" or ex == "webp" then pcall(delfile, f) end
                        end
                    end
                end)
                _assetDir = dir
            end
            local hash = 0
            for i = 1, #url do hash = (hash * 31 + url:byte(i)) % 2147483647 end
            local base = dir .. "/v3_" .. hash
            local path
            for _, ext in ipairs({"png", "jpg"}) do
                if isfile(base .. "." .. ext) then path = base .. "." .. ext break end
            end
            if not path then
                local candidates = {url}
                local bare = url:gsub("^https?://", "")
                -- Photon retorna JPEG para as fotos WebP do Cheatfun.
                local photon = "https://i0.wp.com/" .. bare .. (bare:find("?", 1, true) and "&" or "?") .. "w=480&ssl=1"
                if url:lower():find("%.webp") then
                    table.insert(candidates, 1, photon)
                else
                    table.insert(candidates, photon)
                end
                local okEnc, enc = pcall(function() return HttpService:UrlEncode(url) end)
                if okEnc and enc then
                    -- o Roblox nao renderiza webp; o proxy converte qualquer formato para png
                    table.insert(candidates, "https://wsrv.nl/?url=" .. enc .. "&w=480&output=png")
                    table.insert(candidates, "https://wsrv.nl/?url=" .. enc .. "&w=480&output=jpg")
                    local bare = url:gsub("^https?://", "")
                    local encBare = HttpService:UrlEncode(bare)
                    table.insert(candidates, "https://wsrv.nl/?url=" .. encBare .. "&w=480&output=png")
                    table.insert(candidates, "https://images.weserv.nl/?url=" .. encBare .. "&w=480&output=jpg")
                    table.insert(candidates, "https://cdn.statically.io/img/" .. bare:gsub("^([^/]+)/", "%1/f=jpg,w=480/"))
                    table.insert(candidates, "https://imagecdn.app/v2/image/" .. enc .. "?width=480&format=png")
                    table.insert(candidates, "https://images.weserv.nl/?url=" .. enc .. "&w=480&output=png")
                end
                for _, cand in ipairs(candidates) do
                    local bytes = downloadBytes(cand)
                    local okImg, ext = isValidImageBytes(bytes)
                    if not okImg then warn("[Orion Hub] miniatura falhou (" .. tostring(bytes and #bytes or 0) .. " bytes): " .. cand) end
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
        -- Nao grava falhas: uma tentativa posterior pode carregar a foto.
        if result ~= "" then assetCache[url] = result end
        callback(result)
    end)
end

-- Foto propria tem prioridade, mesmo quando a miniatura baixa depois.
local function setScriptThumbnail(thumb, image, fallback)
    local ownLoaded = false
    thumb.Image = ""
    thumb.ImageColor3 = Color3.new(1, 1, 1)
    if type(fallback) == "string" and fallback ~= "" then
        resolveImage(fallback, function(r)
            if thumb.Parent and not ownLoaded and r and r ~= "" then thumb.Image = r end
        end)
    end
    if type(image) == "string" and image ~= "" then
        resolveImage(image, function(r)
            if thumb.Parent and r and r ~= "" then
                ownLoaded = true
                thumb.Image = r
            end
        end)
    end
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
                -- quebra forcada: palavras longas sem espaco ganham pontos de quebra (zero-width space)
                main = tostring(main):gsub("%S+", function(w) if #w > 14 then return (w:gsub(utf8.charpattern, function(c) return c .. "\226\128\139" end)) end end)
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
                    setScriptThumbnail(thumb, image, bc.FallbackImage)
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
                    if descText == "" and type(bc.PendingDesc) == "string" and bc.PendingDesc ~= "" then descText = bc.PendingDesc end
                    local hasDesc = descText ~= ""
                    local descRef
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
                    local function makeDesc(txt)
                        if descRef then descRef.Text = txt; return end
                        titleMax.MaxSize = Vector2.new(math.huge, 30)
                        local descLabel = label(row, txt, 10, Color3.fromRGB(128,128,141), Enum.Font.Gotham)
                        descLabel.Name = "Description"; descRef = descLabel
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
                    if hasDesc then makeDesc(descText) end
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
                    return {SetDescription=function(_,v) v=tostring(v or ""); if v=="" then if descRef then descRef.Text="" end else pcall(makeDesc, v) end end, SetSelected=function(_,v) if selObj then selObj(v) end end, SetTitle=function(_,v) titleLabel.Text=tostring(v) end, SetImage=function(_,v) resolveImage(v,function(r) if thumb and thumb.Parent and r ~= "" then thumb.Image=r; thumb.ImageColor3=Color3.new(1,1,1) end end) end}
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

]==]
local OrionLib
do
    local function okLib(l) return type(l) == "table" and (tonumber(l.LibVersion) or 0) >= 8 end
    local ok,r = pcall(function()
        -- 1) lib online (so vale se for a versao nova)
        local okWeb, webLib = pcall(function() return loadstring(game:HttpGet(_EP.WU))() end)
        if okWeb and okLib(webLib) then return webLib end
        warn("[Orion Hub] Lib online desatualizada/indisponivel, usando a embutida.")
        -- 2) lib embutida (sempre compativel com este loader)
        local okIn, inLib = pcall(function() return loadstring(__OrionLibSrc)() end)
        if okIn and type(inLib) == "table" then return inLib end
        warn("[Orion Hub] Lib embutida falhou: " .. tostring(inLib))
        if okWeb and type(webLib) == "table" then return webLib end
        return nil
    end)
    if not ok or not r then
        Alert((T and T.OrionLibFail or "Falha OrionLib: ") .. tostring(r))
        warn("[Orion Hub] Falha ao carregar OrionLib:", r)
        return
    end
    OrionLib = r
    _G.OrionLib = r
    pcall(function() OrionLib.IsPT = _isPTBR and true or false end)
end
local HUB_NAME  = "Orion Hub"
local CFG_THEME = "darker"
local function Notify(msg, delay, color)
    pcall(function()
        OrionLib:MakeNotify({Title=HUB_NAME, Content=msg or "", Color=color or Color3.fromRGB(255,255,255), Delay=delay or 4})
    end)
end
local function getExec()
    if identifyexecutor then local ok,n=pcall(identifyexecutor); if ok and n and n~="" then return n end end
    if getexecutorname  then local ok,n=pcall(getexecutorname);  if ok and n and n~="" then return n end end
    return "Unknown"
end
local function Clean(s)
    s = tostring(s or ""):gsub("%b[]",""):gsub("%b()",""):gsub("[^%w%s]", " "):gsub("%s+", " ")
    return s:match("^%s*(.-)%s*$") or ""
end
local function Norm(s)
    s = tostring(s or ""):lower():gsub("%b[]",""):gsub("%b()",""):gsub("[^%w%s]", " "):gsub("%s+", " ")
    return s:match("^%s*(.-)%s*$") or ""
end
local function MakeSlug(s)
    local c = Norm(s)
    c = c:gsub("%s+", "-"):gsub("%-+", "-")
    return c
end
-- Função centralizada de IA compatível com Claude Haiku 4.5 e Vireonix fallback
local function callAICompletion(promptText, systemPrompt, historyTable)
    local reqFn = (syn and syn.request) or (http and http.request) or http_request or request
    if not reqFn then return nil, "No request function available" end
    -- 1. Tentativa DuckChat API (Claude Haiku 4.5 via JSON HTTP Spy)
    local duckOk, duckRes = pcall(function()
        local vqd = nil
        pcall(function()
            local sRes = reqFn({
                Url = _EP.DS,
                Method = "GET",
                Headers = {
                    ["x-vqd-accept"] = "1",
                    ["User-Agent"] = "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Mobile Safari/537.36",
                    ["accept"] = "*/*"
                }
            })
            if sRes and sRes.Headers then
                vqd = sRes.Headers["x-vqd-4"] or sRes.Headers["X-Vqd-4"] or sRes.Headers["x-vqd-hash-1"] or sRes.Headers["X-Vqd-Hash-1"]
            end
        end)
        local fullPrompt = systemPrompt and (systemPrompt .. "\n\n" .. promptText) or promptText
        local payload = HttpService:JSONEncode({
            model = "claude-haiku-4-5",
            metadata = {},
            messages = {
                {
                    role = "user",
                    content = {
                        {
                            type = "text",
                            text = fullPrompt
                        }
                    }
                }
            }
        })
        local reqHeaders = {
            ["Content-Type"] = "application/json",
            ["User-Agent"] = "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Mobile Safari/537.36",
            ["sec-ch-ua"] = [["Chromium";v="139", "Not;A=Brand";v="99"]],
            ["sec-ch-ua-platform"] = [["Android"]],
            ["sec-ch-ua-mobile"] = "?1",
            ["accept"] = "text/event-stream"
        }
        if vqd then
            reqHeaders["x-vqd-4"] = vqd
            reqHeaders["X-Vqd-Hash-1"] = vqd
        end
        return reqFn({
            Url = _EP.DC,
            Method = "POST",
            Headers = reqHeaders,
            Body = payload
        })
    end)
    if duckOk and duckRes and (duckRes.StatusCode == 200 or duckRes.Status == 200) and duckRes.Body and duckRes.Body ~= "" then
        local fullText = ""
        for line in duckRes.Body:gmatch("[^\r\n]+") do
            if line:sub(1, 6) == "data: " then
                local chunkJson = line:sub(7)
                if chunkJson ~= "[DONE]" then
                    local okD, d = pcall(function() return HttpService:JSONDecode(chunkJson) end)
                    if okD and d then
                        if d.message then
                            fullText = fullText .. d.message
                        elseif d.content then
                            fullText = fullText .. d.content
                        end
                    end
                end
            end
        end
        if fullText ~= "" then
            return fullText, nil
        end
    end
    -- 2. Fallback Vireonix OpenAI-compatible
    local okV, resV = pcall(function()
        local messagesPayload = {}
        if systemPrompt and systemPrompt ~= "" then
            table.insert(messagesPayload, { role = "system", content = systemPrompt })
        end
        if historyTable and type(historyTable) == "table" then
            for _, m in ipairs(historyTable) do
                table.insert(messagesPayload, { role = m.role, content = m.content })
            end
        end
        table.insert(messagesPayload, { role = "user", content = promptText })
        local payload = HttpService:JSONEncode({
            model = "auto",
            messages = messagesPayload
        })
        return reqFn({
            Url = _EP.VC,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
            },
            Body = payload
        })
    end)
    if okV and resV and (resV.StatusCode == 200 or resV.Status == 200) and resV.Body then
        local decodeOk, data = pcall(function() return HttpService:JSONDecode(resV.Body) end)
        if decodeOk and data and data.choices and data.choices[1] and data.choices[1].message then
            local content = data.choices[1].message.content
            if content and content ~= "" then
                return content, nil
            end
        end
    end
    return nil, "AI request failed"
end
local function L(pt, en) return _isPTBR and pt or en end
local function _preview(v, n)
    v = tostring(v or ""):gsub("%s+", " ")
    n = n or 60
    if #v > n then return v:sub(1, n) .. "..." end
    return v
end
local RED_N, GREEN_N, YEL_N = Color3.fromRGB(255,120,120), Color3.fromRGB(150,255,180), Color3.fromRGB(255,220,120)
-- Clipboard compativel com varios executores mobile; retorna true somente se copiou de verdade
local function copyToClipboard(text)
    if OrionLib and type(OrionLib.Copy) == "function" then
        local ok, res = pcall(OrionLib.Copy, text)
        if ok and res then return true end
    end
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
        if pcall(fn, text) then return true end
    end
    return false
end
local gameName = ""
pcall(function()
    gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or ""
end)
if gameName == "" then
    pcall(function()
        gameName = tostring(game.Name or "")
    end)
end
local Window
do
    local ok,r=pcall(function()
        return OrionLib:Window({
            Title=HUB_NAME..(gameName~="" and (" | "..gameName) or "").." | "..getExec(),
            Color=Color3.fromRGB(255,255,255), Version=1, ThemePreset=CFG_THEME,
        })
    end)
    if not ok or not r then
        Alert((T and T.WindowFail or "Falha Window: ") .. tostring(r))
        warn("[Orion Hub] Falha ao criar Window:", r)
        return
    end
    Window=r
end
do
    local ok,r=pcall(function()
        return OrionLib:FloatBtn({
            Icon="rbxassetid://106423297301247",
            Color=Color3.fromRGB(255,255,255),
            ColorDark=Color3.fromRGB(35,35,35),
            Size=46,
            MainHolder=Window._holder,
        })
    end)
    if ok and r then pcall(function() Window:RegisterFloat(r) end) end
end
-- [Aba Única: Home com Ícone Lucide Home]
local TabGame = Window:AddTab({ Name = T.TabGame, Icon = "home", Description = T.TabGameDesc })
Notify(T.LoadingScripts, 8, Color3.fromRGB(180, 200, 255))
local function _dismissLoading()
    -- (aviso de carregamento concluído removido)
end
local AE_FILE = _G.__OrionPath("Config", "AutoExec.json", "OrionHub_AutoExec.json")
local _hwf = type(writefile) == "function"
local _hrf = type(readfile)  == "function"
local _hdf = type(delfile)   == "function"
local _gameKey = (game.GameId and game.GameId ~= 0) and tostring(game.GameId) or tostring(game.PlaceId)
local _aeData = {enabled = false, games = {}}
do
    if _hrf then
        local okR, d = pcall(readfile, AE_FILE)
        if okR and type(d) == "string" and d ~= "" then
            local okJ, t = pcall(function() return HttpService:JSONDecode(d) end)
            if okJ and type(t) == "table" then
                _aeData.enabled = t.enabled == true
                _aeData.games = type(t.games) == "table" and t.games or {}
            end
        end
    end
end
local function AE_Write()
    if _hwf then pcall(function() writefile(AE_FILE, HttpService:JSONEncode(_aeData)) end) end
end
local function _aeList()
    local l = _aeData.games[_gameKey]
    if type(l) ~= "table" then l = {}; _aeData.games[_gameKey] = l end
    return l
end
local function _aeIsSel(url)
    for _, e in ipairs(_aeList()) do if type(e) == "table" and e.url == url then return true end end
    return false
end
local _scriptReg = {}
local function _aeNames()
    local out = {}
    for _, e in ipairs(_aeList()) do
        if type(e) == "table" and e.name then
            local r = e.url and _scriptReg[e.url]
            if r then
                if not e.image then e.image = r.image end
                if not e.fallback then e.fallback = r.fallback end
                if not e.description then e.description = r.description end
            end
            table.insert(out, e)
        end
    end
    return out
end
local function _aeSubtitle()
    local l, names = _aeList(), {}
    for _, e in ipairs(l) do if type(e) == "table" and e.name then table.insert(names, tostring(e.name)) end end
    if #names == 0 then
        return L("Nenhum script selecionado. Toque no círculo de um script para escolher.", "No script selected. Tap the circle on a script to choose.")
    end
    return #names .. L(#names == 1 and " selecionado: " or " selecionados: ", " selected: ") .. table.concat(names, ", ") .. "."
end
local _aeToggle, _aeDrop
local _scriptObjByUrl = {}
local function _aeSetSel(sc, v)
    local l = _aeList()
    for k = #l, 1, -1 do if type(l[k]) == "table" and l[k].url == sc.url then table.remove(l, k) end end
    if v then table.insert(l, {name = sc.name or "Script", url = sc.url, image = sc.image, fallback = sc.fallback, description = sc.description, keySystem = sc.keySystem == true}) end
    AE_Write()
    if _aeDrop then pcall(function() _aeDrop.SetValues(_aeNames()) end) end
end
local function ExtractBaseGameName(s)
    if not s or s == "" then return "" end
    s = tostring(s)
    s = s:gsub("%b[]", ""):gsub("%b()", "")
    local base = s:match("^%s*([^|:•/—–%-]+)")
    if base and #base:gsub("%s+", "") >= 3 then
        s = base
    end
    s = s:gsub("[^%w%s]", " "):gsub("%s+", " ")
    return s:match("^%s*(.-)%s*$") or ""
end
local _aeState   = _aeData.enabled
local _lastExUrl = nil
local _lastExLs  = nil
local _scriptBtns = {}
local SecGame = TabGame:AddSection(T.SecAllScripts, true, "shredder", true)
local function _looksLikeCode(b)
    if type(b) ~= "string" or #b < 5 then return false end
    if b:match("^%s*<") then return false end
    if b:find("Just a moment...", 1, true) then return false end
    if b:match('^%s*{%s*"') or b:match("^%s*%[%s*{") then return false end
    return true
end
local function _fetchCode(url)
    local lastErr = "?"
    local reqFn = (syn and syn.request) or (http and http.request) or http_request or request
    if reqFn then
        local okR, r = pcall(reqFn, {
            Url = url, Method = "GET",
            Headers = {["User-Agent"] = "Mozilla/5.0", ["Accept"] = "text/plain,*/*"},
        })
        if okR and type(r) == "table" then
            local st = tostring(r.StatusCode or r.Status or "?")
            if _looksLikeCode(r.Body) then return r.Body, "request " .. st end
            lastErr = "request " .. st
        else
            lastErr = L("request falhou: ", "request failed: ") .. _preview(r, 60)
        end
    end
    local ok1, r1 = pcall(function() return game:HttpGet(url, true) end)
    if ok1 and _looksLikeCode(r1) then return r1, "HttpGet" end
    local ok2, r2 = pcall(function() return game:HttpGet(url) end)
    if ok2 and _looksLikeCode(r2) then return r2, "HttpGet" end
    local ok3, r3 = pcall(function() return game:HttpGetAsync(url) end)
    if ok3 and _looksLikeCode(r3) then return r3, "HttpGetAsync" end
    if ok2 and (r2 == nil or r2 == "") then
        return nil, L("resposta vazia do servidor (link morto ou bloqueado) / ", "empty response (dead or blocked link) / ") .. lastErr
    end
    return nil, L("não retornou código (bloqueio/HTML): ", "did not return code (block/HTML): ") .. lastErr
end
-- Pega o codigo do script: usa o conteudo vindo da API; se nao tiver, baixa do link.
local function _getScriptCode(sc)
    if sc.ls and sc.ls ~= "" and _looksLikeCode(sc.ls) and not sc.ls:match("^%s*https?://%S+%s*$") then
        return sc.ls, "API"
    end
    local u = sc.url
    if (not u or u == "") and sc.ls and sc.ls:match("^%s*https?://%S+%s*$") then u = sc.ls:match("https?://%S+") end
    if u and u ~= "" then return _fetchCode(u) end
    return nil, L("a API não enviou link nem código", "API sent no link or code")
end
-- Retorna true se o script foi baixado/compilado e iniciado; senao false + motivo detalhado.
local function _executeScriptInner(sc)
    if not sc then return false, L("Sem dados do script", "No script data") end
    Notify(L("Obtendo o código do script.", "Retrieving the script code."), 2, Color3.fromRGB(180,200,255))
    local code, how = _getScriptCode(sc)
    if not code then
        return false, L("Falha ao baixar o script: ", "Failed to download script: ") .. tostring(how)
    end
    if code:sub(1, 3) == string.char(239, 187, 191) then code = code:sub(4) end
    code = code:gsub("^%s*```lua%s*", ""):gsub("^%s*```%s*", ""):gsub("%s*```%s*$", "")
    if code:match("^%s*<") then
        return false, L("Resposta é HTML (bloqueio/Cloudflare), não código: ", "Response is HTML (block/Cloudflare), not code: ") .. _preview(code, 50)
    end
    if code:match('^%s*{%s*"') or code:match("^%s*%[%s*{") then
        return false, L("Resposta é JSON, não código: ", "Response is JSON, not code: ") .. _preview(code, 60)
    end
    if #code < 5 then
        return false, L("Código vazio/curto demais (", "Code empty/too short (") .. #code .. " bytes)"
    end
    local fn, compileErr = loadstring(code)
    if not fn then
        return false, L("Erro de compilação: ", "Compile error: ") .. _preview(compileErr, 90)
    end
    Notify(L("Executando o script.", "Running the script."), 2, Color3.fromRGB(180,200,255))
    task.spawn(function()
        local okRun, runErr = xpcall(fn, function(m) return tostring(m) end)
        if not okRun then
            warn("[Orion Hub] Erro dentro do script: " .. tostring(runErr))
            Notify(L("Erro durante a execução do script: ", "Error while running the script: ") .. _preview(runErr, 100), 7, RED_N)
        end
    end)
    return true
end
local function _executeScript(sc)
    local okP, a, b = pcall(_executeScriptInner, sc)
    if not okP then return false, tostring(a) end
    return a, b
end
local okTg, errTg = pcall(function()
    _aeToggle = SecGame:AddToggle({Title=T.AutoExec, Default=_aeState,
        Callback=function(v)
            _aeState = v
            _aeData.enabled = v
            AE_Write()
            Notify(v and T.AEEnabled or T.AEDisabled, 2)
        end})
end)
if not okTg then warn("[Orion Hub] Falha ao criar toggle: " .. tostring(errTg)) end
local okCp, errCp = pcall(function()
    _aeDrop = SecGame:AddDropdown({Title=L("Scripts selecionados para execução automática", "Scripts selected for auto-execute"), Display=true, Values=_aeNames(), Callback=function() end,
        OnItemClick=function(v) pcall(function() _aeSetSel(v, false); local o = _scriptObjByUrl[v.url]; if o and o.SetSelected then o:SetSelected(false) end end) end})
end)
if not okCp then warn("[Orion Hub] Falha ao criar botao: " .. tostring(errCp)) end
local SecScripts = TabGame:AddSection(T.SecClickExec, true, "scroll-text")
pcall(function() SecScripts:AddSearch({Placeholder = L("Pesquisar scripts específicos", "Search specific scripts")}) end)
local function _clearScriptBtns()
    _scriptBtns = {}
end
local function _addScriptButton(sc)
    if type(sc) == "table" and sc.url then _scriptReg[sc.url] = sc; if _aeDrop then task.defer(function() pcall(function() _aeDrop.SetValues(_aeNames()) end) end) end end
    local okBtn, errBtn = pcall(function()
        local function executeCardScript()
            Notify(L("Executando ", "Running ") .. (sc.name or "Script") .. ".", 2, Color3.fromRGB(200,200,255))
            local ok, err = _executeScript(sc)
            if ok then
                if sc.url then
                    _lastExUrl = sc.url
                    _lastExLs  = nil
                elseif sc.ls then
                    _lastExLs  = sc.ls
                    _lastExUrl = nil
                end
                Notify((sc.name or "Script")..T.Executed, 4, Color3.fromRGB(220,220,220))
                return true
            else
                Notify(T.ExecError .. " " .. _preview(err, 110), 7, RED_N)
                warn("[Orion Hub] Erro ao executar script: " .. tostring(err))
                return false
            end
        end
        local btnObj = SecScripts:AddButton({
            Title       = sc.name,
            Image       = sc.image,
            FallbackImage = sc.fallback,
            HasKey      = sc.keySystem == true,
            Description = sc.description,
            PendingDesc = sc.pendingDesc,
            Card        = true,
            Selectable  = type(sc.url) == "string" and sc.url ~= "",
            Selected    = _aeIsSel(sc.url),
            OnSelect    = function(v)
                if v then
                    local n = 0
                    for _, e in ipairs(_aeList()) do if type(e) == "table" and e.url ~= sc.url then n = n + 1 end end
                    if n >= 10 then
                        Notify(L("Limite de 10 scripts selecionados para a execução automática.", "Limit of 10 scripts selected for auto-execute."), 3, Color3.fromRGB(255,86,48))
                        task.defer(function() local o = _scriptObjByUrl[sc.url]; if o and o.SetSelected then o:SetSelected(false) end end)
                        return
                    end
                end
                _aeSetSel(sc, v)
            end,
            CopyCallback = function()
                local content = _getScriptCode(sc)
                if not content then
                    -- sem acesso ao codigo: copia o loadstring do link
                    if sc.url and sc.url ~= "" then
                        content = 'loadstring(game:HttpGet("' .. sc.url .. '"))()'
                    end
                end
                if not content then
                    Notify(L("Não há conteúdo disponível para copiar.", "There is no content available to copy."), 5, RED_N)
                    return false
                end
                local copied = copyToClipboard(content)
                if copied then
                    Notify(T.ScriptCopied, 4, GREEN_N)
                else
                    Notify(L("Não foi possível copiar: o executor não oferece suporte à área de transferência.", "Unable to copy: the executor does not support the clipboard."), 6, RED_N)
                end
                return copied
            end,
            RunText     = T.BtnRun,
            CopyText    = T.BtnCopy,
            CopiedText  = T.BtnCopied,
            ExecutedText = T.BtnExecuted,
            KeyText     = T.BtnKey,
            ErrorText   = T.BtnError,
            KeyCallback = function() Notify(T.KeyNotice, 3, Color3.fromRGB(255,220,120)) end,
            ScriptUrl   = sc.url,
            Callback    = executeCardScript,
            SubCallback = executeCardScript,
        })
        if btnObj then
            sc.btnObj = btnObj
            table.insert(_scriptBtns, btnObj)
            if sc.url then _scriptObjByUrl[sc.url] = btnObj end
        end
    end)
    if not okBtn then warn("[Orion Hub] Falha ao criar card '" .. tostring(sc and sc.name) .. "': " .. tostring(errBtn)) end
end
local function _applyScripts(list)
    if #list == 0 then
        pcall(function() SecScripts:AddButton({Title=T.SecNoScript, Callback=function() end}) end)
        return
    end
    for _,s in ipairs(list) do _addScriptButton(s) end
end
task.spawn(function()
    task.wait(1)
    if _aeData.enabled then
        local queue = {}
        for _, e in ipairs(_aeList()) do
            if type(e) == "table" and type(e.url) == "string" then table.insert(queue, e) end
        end
        for _, e in ipairs(queue) do
            task.wait(0.5)
            local okA = _executeScript({url = e.url, name = e.name})
            if okA then Notify(L("Execução automática: ", "Automatic execution: ") .. tostring(e.name or "Script"), 3, Color3.fromRGB(200,255,200)) end
        end
    end
    local currentPlaceId = tostring(game.PlaceId or "")
    local targetGameId   = (game.GameId and game.GameId ~= 0) and tostring(game.GameId) or ""
    local rootPlaceId    = ""
    local canonicalSlug  = ""
    local rawGameName    = gameName
    -- Resolução não-bloqueante de sub-places (ex: Blox Fruits Sea 2 e Sea 3)
    pcall(function()
        local reqFn = (syn and syn.request) or (http and http.request) or http_request or request
        if (targetGameId == "" or targetGameId == "0") and reqFn then
            local uRes = reqFn({
                Url = _EP.RP .. currentPlaceId .. "/universe",
                Method = "GET"
            })
            if uRes and uRes.Body then
                local uData = HttpService:JSONDecode(uRes.Body)
                if uData and uData.universeId then
                    targetGameId = tostring(uData.universeId)
                end
            end
        end
        if targetGameId ~= "" and targetGameId ~= "0" and reqFn then
            local gRes = reqFn({
                Url = _EP.RG .. targetGameId,
                Method = "GET",
                Headers = {
                    ["Accept-Language"] = "en-US,en;q=0.9",
                    ["User-Agent"] = "Mozilla/5.0"
                }
            })
            if gRes and gRes.Body then
                local gData = HttpService:JSONDecode(gRes.Body)
                if gData and gData.data and gData.data[1] then
                    local gInfo = gData.data[1]
                    if gInfo.rootPlaceId then
                        rootPlaceId = tostring(gInfo.rootPlaceId)
                    end
                    if gInfo.name and gInfo.name ~= "" then
                        rawGameName = gInfo.name
                    end
                    if gInfo.canonicalUrlPath and type(gInfo.canonicalUrlPath) == "string" then
                        local slug = gInfo.canonicalUrlPath:match("/games/%d+/([%w%-]+)")
                        if slug and slug ~= "" then
                            canonicalSlug = slug:lower()
                        end
                    end
                end
            end
        end
    end)
    if rootPlaceId == "" then
        rootPlaceId = currentPlaceId
    end
    local baseName     = ExtractBaseGameName(rawGameName ~= "" and rawGameName or gameName)
    local cleanName    = Clean(baseName ~= "" and baseName or gameName)
    local normTarget   = Norm(gameName)
    local normBase     = Norm(cleanName)
    local gameSlug     = (canonicalSlug ~= "" and canonicalSlug) or MakeSlug(cleanName)
    local function httpGetSafe(url)
        local ok, body = pcall(function() return game:HttpGetAsync(url) end)
        if not ok or not body or body == "" then
            ok, body = pcall(function() return game:HttpGet(url, true) end)
        end
        if not ok or not body or body == "" then
            local reqFn = (syn and syn.request) or (http and http.request) or http_request or request
            if reqFn then
                pcall(function()
                    local r = reqFn({Url = url, Method = "GET"})
                    if r and r.Body and r.Body ~= "" then body = r.Body; ok = true end
                end)
            end
        end
        if ok and body and body ~= "" then return body end
        return nil
    end
    local function isScriptForCurrentGame(s, extraInfo)
        if not s or type(s) ~= "table" then return false end
        local g = s.game
        if type(g) == "table" then
            if gameSlug ~= "" and type(g.slug) == "string" and g.slug:lower() == gameSlug then return true end
            local pId = g.placeId and tostring(g.placeId)
            if pId and pId ~= "" then
                if pId == currentPlaceId or (rootPlaceId ~= "" and pId == rootPlaceId) or (targetGameId ~= "" and pId == targetGameId) then
                    return true
                end
                if extraInfo and extraInfo.aiRootId and extraInfo.aiRootId ~= "" and pId == extraInfo.aiRootId then
                    return true
                end
            end
            local gTitle = g.title and Norm(g.title)
            if gTitle and gTitle ~= "" then
                if normTarget ~= "" and (gTitle == normTarget or gTitle:find(normTarget, 1, true) or normTarget:find(gTitle, 1, true)) then
                    return true
                end
                if normBase ~= "" and (gTitle == normBase or gTitle:find(normBase, 1, true) or normBase:find(gTitle, 1, true)) then
                    return true
                end
                if extraInfo and extraInfo.aiNameNorm and extraInfo.aiNameNorm ~= "" and (gTitle == extraInfo.aiNameNorm or gTitle:find(extraInfo.aiNameNorm, 1, true) or extraInfo.aiNameNorm:find(gTitle, 1, true)) then
                    return true
                end
            end
            if g.gameLink and type(g.gameLink) == "string" then
                if (currentPlaceId ~= "" and g.gameLink:find(currentPlaceId, 1, true))
                   or (rootPlaceId ~= "" and g.gameLink:find(rootPlaceId, 1, true))
                   or (targetGameId ~= "" and g.gameLink:find(targetGameId, 1, true)) then
                    return true
                end
                if extraInfo and extraInfo.aiRootId and extraInfo.aiRootId ~= "" and g.gameLink:find(extraInfo.aiRootId, 1, true) then
                    return true
                end
            end
        end
        local sTitle = s.title and Norm(s.title) or ""
        if normBase ~= "" and #normBase >= 4 and sTitle:find(normBase, 1, true) then
            local gName = (type(g) == "table" and g.title and Norm(g.title)) or ""
            if gName == "" or gName == normBase or normBase:find(gName, 1, true) or gName:find(normBase, 1, true) then
                return true
            end
        end
        if extraInfo and extraInfo.aiNameNorm and #extraInfo.aiNameNorm >= 4 and sTitle:find(extraInfo.aiNameNorm, 1, true) then
            return true
        end
        return false
    end
    local list = {}
    local seen = {}
    local _cfId = tostring(game.GameId ~= 0 and game.GameId or game.PlaceId)
    local _cacheFile = _G.__OrionPath("Cache", "ScriptCache_" .. _cfId .. ".json", "OrionStudios/ScriptCacheL_" .. _cfId .. ".json")
    local function _updateCount()
        pcall(function()
            local n = #list
            local title
            if n == 1 then
                title = L("1 script disponível", "1 script available")
            else
                title = n .. L(" scripts disponíveis", " scripts available")
            end
            SecScripts:SetTitle(title)
        end)
    end
    local function scriptKey(url, ls, title)
        if url and url ~= "" then
            local id = url:match("/raw/([^/%?#]+)")
            if id then return "raw:" .. id:lower() end
            return "url:" .. (url:lower():gsub("[%?#].*$", ""))
        end
        if ls and ls ~= "" then return "ls:" .. #ls .. ":" .. ls:sub(1, 80) end
        return "t:" .. tostring(title)
    end
    -- Adiciona 1 vez só (dedupe por ID do /raw/) e cria o botão na hora
    local function normalizeImg(img)
        if type(img) ~= "string" then return nil end
        img = img:match("^%s*(.-)%s*$") or ""
        if img == "" then return nil end
        if img:sub(1, 2) == "//" then return "https:" .. img end
        if img:sub(1, 1) == "/" then return "https://rscripts.net" .. img end
        return img
    end
    -- Miniatura (thumbnail) do jogo atual, via UNIVERSE id
    local _gameThumb
    local function gameIconFallback()
        if _gameThumb then return _gameThumb end
        pcall(function()
            local uid = (targetGameId ~= "" and targetGameId ~= "0") and targetGameId
                or ((game.GameId and game.GameId ~= 0) and tostring(game.GameId) or "")
            if uid == "" then
                for _, host in ipairs({"apis.roblox.com", "apis.roproxy.com"}) do
                    local body = httpGetSafe("https://" .. host .. "/universes/v1/places/" .. tostring(game.PlaceId) .. "/universe")
                    local okJ, j = pcall(function() return HttpService:JSONDecode(body or "") end)
                    if okJ and j and j.universeId then uid = tostring(j.universeId); break end
                end
            end
            if uid == "" then return end
            for _, host in ipairs({"thumbnails.roblox.com", "thumbnails.roproxy.com"}) do
                local body = httpGetSafe("https://" .. host .. "/v1/games/multiget/thumbnails?universeIds=" .. uid .. "&countPerUniverse=1&defaults=true&size=768x432&format=Png&isCircular=false")
                local okJ, j = pcall(function() return HttpService:JSONDecode(body or "") end)
                local d = okJ and j and j.data and j.data[1]
                local u = d and d.thumbnails and d.thumbnails[1] and d.thumbnails[1].imageUrl
                if type(u) == "string" and u ~= "" then _gameThumb = u; return end
            end
        end)
        return _gameThumb or ""
    end
    -- Imagem do jogo atual (a mesma que os cards do Rscripts usam), buscada 1 vez
    local _gameImgDone, _gameImg = false, nil
    local function getGameImg()
        if _gameImgDone and _gameImg then return _gameImg end
        _gameImgDone = true
        pcall(function()
            local q = (cleanName ~= "" and cleanName) or gameName
            local body = httpGetSafe(_EP.RA .. HttpService:UrlEncode(q) .. "&page=1&orderBy=likes&sort=desc")
            local okJ, sd = pcall(function() return HttpService:JSONDecode(body or "") end)
            if okJ and type(sd) == "table" and type(sd.scripts) == "table" then
                for _, sc in ipairs(sd.scripts) do
                    if type(sc.game) == "table" and type(sc.game.imgurl) == "string" and sc.game.imgurl ~= "" and isScriptForCurrentGame(sc) then
                        _gameImg = normalizeImg(sc.game.imgurl); break
                    end
                end
            end
        end)
        return _gameImg
    end
    -- Adiciona 1 vez so (dedupe por ID do /raw/) e cria o botao na hora
    local function addScriptRaw(title, url, ls, image, gameTitle, description, pId, keySystem, pendingDesc)
        if not title or title == "" then title = "Script" end
        if (not url or url == "") and (not ls or ls == "") then return false end
        local key = scriptKey(url, ls, title)
        if seen[key] then return false end
        seen[key] = true
        local _img = normalizeImg(image)
        -- sem imagem propria (ou capa do cheater.fun, inclusive vinda do cache): usa a imagem do jogo
        if _img == nil or _img == "" or tostring(_img):find("cheater.fun", 1, true) then
            _img = getGameImg() or _img
            if _img == nil or _img == "" or tostring(_img):find("cheater.fun", 1, true) then
                local gt = gameIconFallback()
                if gt and gt ~= "" then _img = gt end
            end
        end
        local entry = {
            name = tostring(title), image = _img, fallback = gameIconFallback(),
            gameTitle = gameTitle, description = description, keySystem = keySystem == true, pendingDesc = pendingDesc,
        }
        if url and url ~= "" then entry.url = url end
        if ls and ls ~= "" then entry.ls = ls end
        table.insert(list, entry)
        _addScriptButton(entry)
        _updateCount()
        task.wait(0.03) -- aparece um por vez e o contador sobe junto
        return true, entry
    end
    -- Intercala: antes de cada script do Rscripts entra 1 do Cheatfun (ate acabar os do Cheatfun)
    local cfQueue = {}
    local function cfFlushOne()
        local job = table.remove(cfQueue, 1)
        if job then pcall(job) end
    end
    -- 1 Rscripts primeiro -> espera ate 10s por um do Cheatfun -> se chegar, intercala (CF/RS) ate o fim
    -- do Cheatfun; se nao chegar, segue so com Rscripts (o que chegar tarde entra no final)
    local cfState, cfWaitStart = "off", nil   -- first | wait | mix | off
    local cfDone = false
    local function addScript(title, url, ls, ...)
        local t = (title and title ~= "") and title or "Script"
        local isNew = ((url and url ~= "") or (ls and ls ~= "")) and not seen[scriptKey(url, ls, t)]
        if isNew then
            if cfState == "wait" then
                while #cfQueue == 0 and not cfDone and (os.clock() - cfWaitStart) < 10 do task.wait(0.1) end
                cfState = (#cfQueue > 0) and "mix" or "off"
            end
            if cfState == "mix" then cfFlushOne() end
        end
        local r1, r2 = addScriptRaw(title, url, ls, ...)
        if isNew and r1 and cfState == "first" then cfState = "wait"; cfWaitStart = os.clock() end
        return r1, r2
    end
    -- Selecionados (execucao automatica) salvos SEMPRE primeiro, antes da ordem por likes
    pcall(function()
        for _, e in ipairs(_aeList()) do
            if type(e) == "table" and e.name and e.url and e.url ~= "" then
                addScript(e.name, e.url, nil, e.image, nil, e.description, nil, e.keySystem)
            end
        end
    end)
    -- Arsenal salvo: carrega direto os scripts ja conhecidos deste jogo
    local _cachedCount = 0
    pcall(function()
        if type(isfile) == "function" and type(readfile) == "function" and isfile(_cacheFile) then
            local data = HttpService:JSONDecode(readfile(_cacheFile))
            -- cache antigo (sem marcador v=2) tinha a ordem errada: ignora e sera refeito
            if type(data) == "table" and type(data[1]) == "table" and data[1].v == 2 then
                -- selecionados (execucao automatica) primeiro
                local sel, rest = {}, {}
                for _, e in ipairs(data) do
                    if type(e) == "table" then table.insert((e.url and _aeIsSel(e.url)) and sel or rest, e) end
                end
                data = {}
                for _, e in ipairs(sel) do data[#data+1] = e end
                -- resto: intercala 1 Cheatfun / 1 Rscripts
                local cfL, rsL = {}, {}
                for _, e in ipairs(rest) do table.insert(e.cf and cfL or rsL, e) end
                local ci, ri = 1, 1
                while ci <= #cfL or ri <= #rsL do
                    if cfL[ci] then data[#data+1] = cfL[ci]; ci = ci + 1 end
                    if rsL[ri] then data[#data+1] = rsL[ri]; ri = ri + 1 end
                end
                for _, e in ipairs(data) do
                    if type(e) == "table" and e.name and not (type(e.image) == "string" and e.image:find("/uploads/mini/", 1, true)) then
                        local okC, entC = addScriptRaw(e.name, e.url, e.ls, e.image, e.gameTitle, e.description, nil, e.keySystem)
                        if okC then _cachedCount = _cachedCount + 1; if entC then entC.cf = e.cf end end
                    end
                end
            end
        end
    end)
    local function apiUrl(q, page)
        return _EP.RA .. HttpService:UrlEncode(q) .. "&page=" .. page .. "&orderBy=likes&sort=desc"
    end
    local function processBody(body, extraInfo)
        if not body then return nil end
        local dok, sd = pcall(function() return HttpService:JSONDecode(body) end)
        if not dok or type(sd) ~= "table" or type(sd.scripts) ~= "table" then return nil end
        for _, s in ipairs(sd.scripts) do
            if isScriptForCurrentGame(s, extraInfo) then
                addScript(s.title or "Script", s.rawScript, s.script, (s.image ~= nil and s.image ~= "" and s.image) or (type(s.game) == "table" and s.game.imgurl) or nil, type(s.game) == "table" and s.game.title or nil, s.description, type(s.game) == "table" and s.game.placeId or nil, s.keySystem == true)
            end
        end
        return sd
    end
    -- [Rscripts Paginado de 10 em 10] Carregamento progressivo suave até o final das páginas sem kick
    local function fetchAllPages(query, extraInfo)
        local firstUrl = apiUrl(query, 1)
        local sd = processBody(httpGetSafe(firstUrl), extraInfo)
        if not sd then return end
        local maxPages = 1
        if type(sd.info) == "table" and tonumber(sd.info.maxPages) then
            maxPages = math.min(tonumber(sd.info.maxPages), 100)
        end
        if maxPages <= 1 then return end
        -- Carrega de página em página (~10-16 scripts por página) com pausa suave
        for p = 2, maxPages do
            task.wait(0.2) -- Intervalo cadenciado para não sobrecarregar a fila HTTP nem causar kick
            local body = httpGetSafe(apiUrl(query, p))
            if body then
                local res = processBody(body, extraInfo)
                -- Se a página não trouxe scripts, encerra esta query
                if not res or type(res.scripts) ~= "table" or #res.scripts == 0 then
                    break
                end
            else
                break
            end
        end
    end
    -- 0. [cheater.fun] roda em PARALELO com o Rscripts (nao trava o carregamento) e entra intercalado
    task.spawn(function()
    pcall(function()
        local CF = "https://cheater.fun"
        local rsImg = nil -- addScript resolve a imagem do jogo sozinho
        local function dec(t)
            t = tostring(t or ""):gsub("<[^>]->", "")
            t = t:gsub("&nbsp;", " "):gsub("&quot;", '"'):gsub("&#039;", "'"):gsub("&#39;", "'")
                 :gsub("&lt;", "<"):gsub("&gt;", ">"):gsub("&amp;", "&")
            return (t:match("^%s*(.-)%s*$")) or ""
        end
        local reqFn = (syn and syn.request) or (http and http.request) or http_request or request
        local HDR = {
            ["User-Agent"] = "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Mobile Safari/537.36",
            ["Accept"] = "text/html,application/xhtml+xml,*/*;q=0.8",
            ["Referer"] = CF .. "/",
        }
        local function cfReq(url, post)
            if reqFn then
                local h = {}
                for k, v in pairs(HDR) do h[k] = v end
                if post then h["Content-Type"] = "application/x-www-form-urlencoded" end
                local ok, r = pcall(reqFn, {Url = url, Method = post and "POST" or "GET", Headers = h, Body = post})
                if ok and type(r) == "table" and type(r.Body) == "string" and r.Body ~= "" and not r.Body:find("Just a moment...", 1, true) then
                    return r.Body
                end
            end
            if not post then
                local b = httpGetSafe(url)
                if b and not b:find("Just a moment...", 1, true) then return b end
                -- Metodo alternativo: proxies publicos (contornam bloqueio/Cloudflare)
                local enc = HttpService:UrlEncode(url)
                for _, px in ipairs({
                    "https://api.allorigins.win/raw?url=" .. enc,
                    "https://corsproxy.io/?url=" .. enc,
                    "https://api.codetabs.com/v1/proxy/?quest=" .. enc,
                }) do
                    local pb = httpGetSafe(px)
                    if pb and #pb > 500 and not pb:find("Just a moment...", 1, true) then return pb end
                end
            end
            return nil
        end
        local function parseCards(sHtml)
            local out = {}
            for art in sHtml:gmatch("<article.-</article>") do
                local href, ttl = art:match('<a href="([^"]-/hacks_roblox/[^"]-%.html)"[^>]-class="card%-title%-link"[^>]*>%s*<h2>(.-)</h2>')
                if not href then
                    href = art:match('href="([^"]-/hacks_roblox/%d+[^"]-%.html)"')
                    ttl = art:match("<h2[^>]*>(.-)</h2>")
                end
                if href then
                    if href:sub(1, 1) == "/" then href = CF .. href end
                    out[#out+1] = {href = href, title = dec(ttl or ""), thumb = art:match('<img[^>]-src="([^"]+)"')}
                end
            end
            return out
        end
        local qs, qseen = {}, {}
        -- Mesmo metodo do Rscripts: universe id -> nome ORIGINAL do jogo (rawGameName) vem primeiro
        for _, v in ipairs({rawGameName, baseName, cleanName, gameName, gameSlug ~= "" and gameSlug:gsub("%-", " ") or nil}) do
            if type(v) == "string" and v ~= "" and not qseen[v:lower()] then qseen[v:lower()] = true; qs[#qs+1] = v end
        end
        local pageUrl, pageTitle, thumb
        for _, q in ipairs(qs) do
            local enc = HttpService:UrlEncode(q)
            local sHtml = cfReq(CF .. "/index.php?do=search&subaction=search&story=" .. enc)
            local cards = sHtml and parseCards(sHtml) or {}
            if #cards == 0 then
                sHtml = cfReq(CF .. "/index.php?do=search", "do=search&subaction=search&search_start=0&full_search=0&result_from=1&story=" .. enc)
                cards = sHtml and parseCards(sHtml) or {}
            end
            local nq = Norm(q)
            local short = nq:match("^(%S+%s+%S+)") or nq
            for _, c in ipairs(cards) do
                if Norm(c.title):find(nq, 1, true) then pageUrl, pageTitle, thumb = c.href, c.title, c.thumb; break end
            end
            if not pageUrl then
                for _, c in ipairs(cards) do
                    if Norm(c.title):find(short, 1, true) then pageUrl, pageTitle, thumb = c.href, c.title, c.thumb; break end
                end
            end
            if pageUrl then break end
        end
        if not pageUrl then warn("[Orion Hub] cheater.fun: jogo nao encontrado"); Notify(L("cheater.fun: jogo não encontrado.", "cheater.fun: game not found."), 4, Color3.fromRGB(255,200,100)); return end
        local html = cfReq(pageUrl)
        if not html then warn("[Orion Hub] cheater.fun: pagina bloqueada"); Notify(L("cheater.fun: página bloqueada.", "cheater.fun: page blocked."), 4, Color3.fromRGB(255,200,100)); return end
        local ev = {}
        local hs = html:gsub("\\/", "/")
        for p, t in hs:gmatch("()<h[23][^>]*>(.-)</h[23]>") do ev[#ev+1] = {p=p, k="h", v=dec(t)} end
        for p, tag in hs:gmatch("()(<img%s[^>]*>)") do
            local u = tag:match('data%-src=["\']([^"\']+)')
                or tag:match('data%-original=["\']([^"\']+)')
                or tag:match('%ssrc=["\']([^"\']+)')
            if u and (u:find("/uploads/posts/", 1, true) or u:find("/uploads/mini/shortstory/", 1, true)) then
                u = u:gsub("&amp;", "&")
                local ext = u:lower():gsub("[%?#].*$", ""):match("%.(%w+)$")
                if ext == "webp" or ext == "jpg" or ext == "jpeg" or ext == "png" then ev[#ev+1] = {p=p, k="i", v=u} end
            end
        end
        for p, c in hs:gmatch("()<pre[^>]*>%s*<code[^>]*>(.-)</code>") do ev[#ev+1] = {p=p, k="c", v=dec(c)} end
        table.sort(ev, function(a, b) return a.p < b.p end)
        local title, img, n, labeled = nil, nil, 0, false
        local ogImg = html:match('property=["\']og:image["\'][^>]-content=["\']([^"\']+)') or html:match('content=["\']([^"\']+)["\'][^>]-property=["\']og:image')
        local function fname(u) return tostring(u or ""):match("([^/]+)$") end
        local function isCover(u) return ogImg ~= nil and fname(u) == fname(ogImg) end
        local lastImg = nil
        local aiJobs = {}
        -- descricao imediata com base no titulo + palavras-chave do codigo (a IA refina depois)
        local KW = {
            {"auto farm","Auto Farm"},{"autofarm","Auto Farm"},{"auto-farm","Auto Farm"},{"esp","ESP"},{"aimbot","Aimbot"},{"teleport","Teleport"},
            {"fly","Fly"},{"speed","Speed"},{"noclip","Noclip"},{"infinite jump","Infinite Jump"},{"god mode","God Mode"},
            {"kill aura","Kill Aura"},{"auto collect","Auto Collect"},{"auto buy","Auto Buy"},{"auto sell","Auto Sell"},
            {"auto hatch","Auto Hatch"},{"auto quest","Auto Quest"},{"silent aim","Silent Aim"},{"walkspeed","WalkSpeed"},
            {"auto raid","Auto Raid"},{"auto boss","Auto Boss"},{"fruit","Fruits"},{"gui","GUI"},
        }
        local function quickDesc(name, code)
            local lc = (tostring(name or "") .. " " .. tostring(code or ""):sub(1, 6000)):lower()
            local feats, seenF = {}, {}
            for _, p in ipairs(KW) do
                if lc:find(p[1], 1, true) and not seenF[p[2]] then seenF[p[2]] = true; feats[#feats+1] = p[2] end
                if #feats >= 6 then break end
            end
            local d = tostring(name or ""):gsub("%s*[|%-–]%s*[Nn]o [Kk]ey.*$", ""):gsub("^%s+", ""):gsub("%s+$", "")
            return d
        end
        for i, e in ipairs(ev) do
            if e.k == "h" then title = e.v
            elseif e.k == "i" then if not isCover(e.v) then lastImg = e.v end
            elseif e.k == "c" and e.v ~= "" and n < 80 then
                img = lastImg
                if not img then
                    for j = i + 1, #ev do
                        if ev[j].k == "c" then break end
                        if ev[j].k == "i" and not isCover(ev[j].v) then img = ev[j].v; break end
                    end
                end
                lastImg = nil
                local nm = (title and title ~= "") and title or pageTitle
                local u = e.v:match('HttpGet%w*%s*%(?%s*["\']([^"\']+)["\']')
                local isSimple = u and #e.v < 400 and not e.v:find("\n.-\n.-\n")
                local lower = nm:lower()
                local key = (lower:find("key", 1, true) and not lower:find("no key", 1, true)) or e.v:lower():find("get key", 1, true) ~= nil
                img = img or ogImg or thumb
                local image = img and ((img:find("^https?:") and img) or (img:sub(1,2) == "//" and ("https:" .. img)) or (CF .. "/" .. img:gsub("^/", ""))) or nil
                -- cheater.fun: ignora as capas do site; usa a imagem do jogo igual ao Rscripts
                n = n + 1
                cfQueue[#cfQueue+1] = function()
                    local qd = quickDesc(nm, e.v)
                    local okAdd, ent = addScriptRaw(nm, isSimple and u or nil, (not isSimple) and e.v or nil, rsImg, pageTitle, qd, nil, key and true or false)
                    if okAdd then
                    else
                        -- ja veio do cache: se ainda esta sem descricao, gera tambem
                        ent = nil
                        for _, e2 in ipairs(list) do
                            if e2.name == nm and (e2.url == (isSimple and u or nil)) and (not e2.description or e2.description == "") and e2.btnObj then ent = e2; break end
                        end
                    end
                    if ent then
                        ent.cf = true
                        if not okAdd then
                            ent.description = qd
                            pcall(function() ent.btnObj:SetDescription(qd) end)
                        end
                        aiJobs[#aiJobs+1] = {entry = ent, name = nm, code = e.v}
                    end
                end
            end
        end
        if n == 0 then warn("[Orion Hub] cheater.fun: nenhum bloco de codigo lido em " .. pageUrl) end
    end)
    cfDone = true
    end)
    -- 1. API v2 com queries prioritárias e deduplicadas (carregando até o final)
    local queries, qSeen = {}, {}
    local function addQuery(q)
        if not q or q == "" then return end
        local k = q:lower()
        if qSeen[k] then return end
        qSeen[k] = true
        table.insert(queries, q)
    end
    addQuery(cleanName ~= "" and cleanName or gameName)
    if gameSlug ~= "" then addQuery(gameSlug:gsub("%-", " ")) end
    if #list < 15 and rawGameName ~= gameName and rawGameName ~= cleanName then
        addQuery(rawGameName)
    end
    for _, q in ipairs(queries) do
        pcall(fetchAllPages, q)
        task.wait(0.15)
    end
    -- 2. Fallback na página do jogo caso tenha encontrado poucos scripts
    if #list < 10 and gameSlug ~= "" then
        pcall(function()
            for p = 1, 15 do
                local pageUrl = _EP.RGAME .. gameSlug .. "?sort=most-likes" .. (p > 1 and ("&page=" .. p) or "")
                local pageHtml = httpGetSafe(pageUrl)
                if not pageHtml or pageHtml:find("Just a moment...", 1, true) then break end
                pageHtml = pageHtml:gsub("\\/", "/")
                local added = 0
                for rawUrl in pageHtml:gmatch('https?://rscripts%.net/raw/[%w%_%-%.]+') do
                    if addScript((cleanName ~= "" and cleanName or "Game") .. " Script #" .. (#list + 1), rawUrl, nil) then
                        added = added + 1
                    end
                end
                if added == 0 then break end
                task.wait(0.2)
            end
        end)
    end
    -- 3. Fallback com o RootPlaceId se nenhum script foi encontrado
    if #list == 0 and rootPlaceId ~= "" and rootPlaceId ~= currentPlaceId then
        for page = 1, 3 do
            local apiUrl = _EP.RA .. HttpService:UrlEncode(rootPlaceId) .. "&page=" .. page .. "&orderBy=likes&sort=desc"
            local body = httpGetSafe(apiUrl)
            if not body then break end
            local dok, sd = pcall(function() return HttpService:JSONDecode(body) end)
            if not dok or type(sd) ~= "table" or type(sd.scripts) ~= "table" or #sd.scripts == 0 then break end
            for _, s in ipairs(sd.scripts) do
                if isScriptForCurrentGame(s) or (s.title and Norm(s.title):find(normBase, 1, true)) then
                    addScript(s.title or "Script", s.rawScript, s.script, (s.image ~= nil and s.image ~= "" and s.image) or (type(s.game) == "table" and s.game.imgurl) or nil, type(s.game) == "table" and s.game.title or nil, s.description, type(s.game) == "table" and s.game.placeId or nil, s.keySystem == true)
                end
            end
            if #sd.scripts < 16 then break end
        end
    end
    -- 4. Fallback com o PlaceId atual se ainda nenhum script foi encontrado
    if #list == 0 and currentPlaceId ~= "" then
        for page = 1, 3 do
            local apiUrl = _EP.RA .. HttpService:UrlEncode(currentPlaceId) .. "&page=" .. page .. "&orderBy=likes&sort=desc"
            local body = httpGetSafe(apiUrl)
            if not body then break end
            local dok, sd = pcall(function() return HttpService:JSONDecode(body) end)
            if not dok or type(sd) ~= "table" or type(sd.scripts) ~= "table" or #sd.scripts == 0 then break end
            for _, s in ipairs(sd.scripts) do
                if isScriptForCurrentGame(s) or (s.title and Norm(s.title):find(normBase, 1, true)) then
                    addScript(s.title or "Script", s.rawScript, s.script, (s.image ~= nil and s.image ~= "" and s.image) or (type(s.game) == "table" and s.game.imgurl) or nil, type(s.game) == "table" and s.game.title or nil, s.description, type(s.game) == "table" and s.game.placeId or nil, s.keySystem == true)
                end
            end
            if #sd.scripts < 16 then break end
        end
    end
    -- 5. Fallback com Orion AI no rscripts caso nenhum script tenha sido encontrado
    if #list == 0 then
        pcall(function()
            local promptAI = "The player is in a Roblox game, but 0 scripts were found on rscripts.net.\n" ..
                "Current PlaceId: " .. currentPlaceId .. "\n" ..
                "Root PlaceId: " .. rootPlaceId .. "\n" ..
                "UniverseId: " .. targetGameId .. "\n" ..
                "Game Title: " .. tostring(gameName ~= "" and gameName or rawGameName) .. "\n\n" ..
                "The title may be translated to Portuguese (e.g. 'Fuga da Prisão' = Jailbreak, 'Portas' = Doors, 'Torre do Inferno' = Tower of Hell, 'Terceiro Mar' = Sea 3) or refer to a sub-place.\n" ..
                "Identify the canonical English game name, its exact rscripts.net slug, and main root PlaceId.\n" ..
                "Respond ONLY in this exact format:\n" ..
                "SLUG: <slug>\n" ..
                "NAME: <canonical_english_name>\n" ..
                "ROOT_ID: <main_place_id>"
            local sysPrompt = "You are an expert on Roblox games and rscripts.net directory. Return ONLY the requested format with the original English game name, rscripts slug, and root place ID."
            local aiResp, aiErr = callAICompletion(promptAI, sysPrompt)
            if aiResp and aiResp ~= "" then
                local aiSlug = aiResp:match("SLUG:%s*([%w%-%_]+)")
                local aiName = aiResp:match("NAME:%s*([^\r\n]+)")
                local aiRoot = aiResp:match("ROOT_ID:%s*(%d+)")
                if aiName then aiName = aiName:match("^%s*(.-)%s*$") end
                if aiSlug then aiSlug = aiSlug:lower():match("^%s*(.-)%s*$") end
                local extraInfo = {
                    aiRootId = aiRoot,
                    aiNameNorm = aiName and Norm(aiName) or nil
                }
                -- Tenta puxar a página do jogo diretamente do rscripts.net usando o slug retornado pela IA
                if aiSlug and aiSlug ~= "" then
                    pcall(function()
                        local pageUrl = _EP.RGAME .. aiSlug
                        local pageHtml = httpGetSafe(pageUrl)
                        if pageHtml and not pageHtml:find("Just a moment...", 1, true) then
                            for rawUrl in pageHtml:gmatch('https?://rscripts%.net/raw/[%w%_%-%./]+') do
                                addScript((aiName or cleanName) .. " Script", rawUrl, nil)
                            end
                        end
                    end)
                end
                -- Busca na API v2 com o nome resolvido pela IA
                if aiName and aiName ~= "" and Norm(aiName) ~= normTarget then
                    local aiUrl = _EP.RA .. HttpService:UrlEncode(aiName) .. "&page=1"
                    local aiBody = httpGetSafe(aiUrl)
                    if aiBody then
                        local dok, sd = pcall(function() return HttpService:JSONDecode(aiBody) end)
                        if dok and type(sd) == "table" and type(sd.scripts) == "table" then
                            for _, s in ipairs(sd.scripts) do
                                if isScriptForCurrentGame(s, extraInfo) then
                                    addScript(s.title or "Script", s.rawScript, s.script, (s.image ~= nil and s.image ~= "" and s.image) or (type(s.game) == "table" and s.game.imgurl) or nil, type(s.game) == "table" and s.game.title or nil, s.description, type(s.game) == "table" and s.game.placeId or nil, s.keySystem == true)
                                end
                            end
                        end
                    end
                end
                -- Se a IA identificou um Root Place ID diferente, busca por ele também
                if aiRoot and aiRoot ~= "" and aiRoot ~= currentPlaceId and aiRoot ~= rootPlaceId then
                    local rUrl = _EP.RA .. HttpService:UrlEncode(aiRoot) .. "&page=1"
                    local rBody = httpGetSafe(rUrl)
                    if rBody then
                        local dok, sd = pcall(function() return HttpService:JSONDecode(rBody) end)
                        if dok and type(sd) == "table" and type(sd.scripts) == "table" then
                            for _, s in ipairs(sd.scripts) do
                                if isScriptForCurrentGame(s, extraInfo) then
                                    addScript(s.title or "Script", s.rawScript, s.script, (s.image ~= nil and s.image ~= "" and s.image) or (type(s.game) == "table" and s.game.imgurl) or nil, type(s.game) == "table" and s.game.title or nil, s.description, type(s.game) == "table" and s.game.placeId or nil, s.keySystem == true)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
    do -- espera o Cheatfun terminar (max ~20s) e despeja o que sobrou da fila
        local waited = 0
        while not cfDone and waited < 20 do task.wait(0.1); waited = waited + 0.1 end
    end
    while #cfQueue > 0 do cfFlushOne(); task.wait(0.03) end
    if #list == 0 then _applyScripts(list) end
    pcall(function()
        if #list > 0 and type(writefile) == "function" then
            if type(isfolder) == "function" and type(makefolder) == "function" and not isfolder("Orion-Studios/Cache") then _G.__OrionPath("Cache","x") end
            local out = {}
            for _, e in ipairs(list) do
                out[#out+1] = {name = e.name, url = e.url, ls = (e.ls and #e.ls < 30000) and e.ls or nil, image = e.image,
                    gameTitle = e.gameTitle, description = e.description, keySystem = e.keySystem, cf = e.cf, v = 2}
            end
            writefile(_cacheFile, HttpService:JSONEncode(out))
        end
    end)
    if #list > 0 then
        Notify(#list .. T.ScriptsRS, 4, GREEN_N)
    else
        Notify(T.NoPublicScripts, 5, Color3.fromRGB(255, 200, 100))
    end
    _dismissLoading()
end)
local CFG={
    ESP=false,HL=true,Box=false,Line=false,HP=false,ShowName=false,TeamCheck=false,Skel=false,Arrows=false,Bag=false,Hi=false,TeamSel={},RoleSel={},
    HLFill=0.7,HLOut=0.54,HLThick=0.10,ShowDist=false,UseColor=false,Color=Color3.fromRGB(255,255,255),
    Key=Enum.KeyCode.RightShift,
    Aim=false,AimHL=true,AimTeam=true,AimAlive=true,AimDist=500,
    AimPart="Head",AimTarget=nil,Aim360=false,FOV=80,Smooth=0.5,
    FOVRing=false,FOVShrink=false,FOVMin=30,
    Hitbox=false,HBSize=10,HBTrans=0.5,HBVis=true,
    HBColor=Color3.fromRGB(255,0,0),HBMat=Enum.Material.Neon,
    SL=false,
}
local FOVGui=Instance.new("ScreenGui"); FOVGui.Name="OrionHubFOV"; FOVGui.ResetOnSpawn=false; FOVGui.Enabled=false
pcall(function() FOVGui.IgnoreGuiInset=true end); FOVGui.Parent=LocalPlayer:WaitForChild("PlayerGui")
local FOVFrm=Instance.new("Frame",FOVGui); FOVFrm.BackgroundTransparency=1; FOVFrm.BorderSizePixel=0
FOVFrm.AnchorPoint=Vector2.new(0.5,0.5); FOVFrm.Position=UDim2.fromScale(0.5,0.5); FOVFrm.Size=UDim2.fromOffset(160,160)
Instance.new("UICorner",FOVFrm).CornerRadius=UDim.new(1,0)
local FOVStr=Instance.new("UIStroke",FOVFrm); FOVStr.Color=Color3.fromRGB(255,255,255); FOVStr.Thickness=2; FOVStr.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
local function setFR(r) FOVFrm.Size=UDim2.fromOffset(r*2,r*2) end
local HLMap={}; local _aHL=nil; local ESPCache={}
local IsMM2=(game.GameId==66654135) or (table.find({142823291,335132309,636649648},game.PlaceId)~=nil)
local RoleMem={}
local function RoleOf(p)
    local c=p.Character; local m=RoleMem[p]
    if not m or m.char~=c then m={char=c,k=false,g=false,t=0,r="Innocent"}; RoleMem[p]=m end -- respawn (nova rodada) zera o papel
    local now=os.clock()
    if now-m.t>0.3 then
        m.t=now
        local function chk(par) if par then
            if par:FindFirstChild("Knife") then m.k=true end
            if par:FindFirstChild("Gun") or par:FindFirstChild("Revolver") then m.g=true end
        end end
        pcall(chk,c); pcall(function() chk(p:FindFirstChildOfClass("Backpack")) end)
        m.r=m.k and "Murderer" or (m.g and "Sheriff" or "Innocent")
    end
    return m.r
end
local RoleCol={Murderer=Color3.fromRGB(255,60,60),Sheriff=Color3.fromRGB(70,140,255),Innocent=Color3.fromRGB(80,220,120)}
local function RoleLabel(p) local r=RoleOf(p); return r=="Murderer" and L("Assassino","Murderer") or (r=="Sheriff" and L("Xerife","Sheriff") or L("Inocente","Innocent")) end
local function PCol(p) if CFG.UseColor then return CFG.Color end; if IsMM2 then return RoleCol[RoleOf(p)] end; if p.Team then return p.Team.TeamColor.Color end; return Color3.fromRGB(255,255,255) end
local function Alive(c) local h=c and c:FindFirstChild("Humanoid"); return h and h.Health>0 end
local function Enemy(p) if p==LocalPlayer then return false end; if CFG.AimTeam and p.Team and LocalPlayer.Team and p.Team==LocalPlayer.Team then return false end; return true end
local function AnySel(t) for _,v in pairs(t) do if v then return true end end return false end
local function EnemyESP(p)
    if p==LocalPlayer then return false end
    if IsMM2 then return (not AnySel(CFG.RoleSel)) or CFG.RoleSel[RoleOf(p)]==true end
    if not CFG.TeamCheck and p.Team and LocalPlayer.Team and p.Team==LocalPlayer.Team then return false end -- Time desligado: esconde seu time; ligado: mostra
    if AnySel(CFG.TeamSel) and CFG.TeamSel[p.Team and p.Team.Name or "Sem time"]~=true then return false end
    return true
end
local function Visible(part,char)
    local rp=RaycastParams.new(); rp.FilterType=Enum.RaycastFilterType.Blacklist
    rp.FilterDescendantsInstances={LocalPlayer.Character,char}; rp.IgnoreWater=true
    return workspace:Raycast(Camera.CFrame.Position,part.Position-Camera.CFrame.Position,rp)==nil
end
local function Closest()
    if CFG.AimTarget then local p=Players:FindFirstChild(CFG.AimTarget); if p and Enemy(p) then local c=p.Character; if c and (not CFG.AimAlive or Alive(c)) and c:FindFirstChild(CFG.AimPart) then return p end end; return nil end
    local best,bd=nil,CFG.Aim360 and math.huge or CFG.FOV
    local ctr=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
    local mr=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    for _,p in pairs(Players:GetPlayers()) do
        if not Enemy(p) then continue end; local c=p.Character; if not c then continue end
        if CFG.AimAlive and not Alive(c) then continue end
        local part=c:FindFirstChild(CFG.AimPart); if not part then continue end
        if not Visible(part,c) then continue end
        if mr and (part.Position-mr.Position).Magnitude>CFG.AimDist then continue end
        if CFG.Aim360 then local d=(part.Position-(mr and mr.Position or Vector3.zero)).Magnitude; if d<bd then bd=d;best=p end
        else local sp,onS=Camera:WorldToViewportPoint(part.Position); if not onS then continue end; local d=(Vector2.new(sp.X,sp.Y)-ctr).Magnitude; if d<bd then bd=d;best=p end end
    end; return best
end
local function AHL(p)
    if p==LocalPlayer then return end; local c=p.Character; if not c then return end
    local old=HLMap[p]; if old and old.Parent then old:Destroy() end
    local col=PCol(p); local hl=Instance.new("Highlight"); hl.Adornee=c; hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillColor=col; hl.OutlineColor=col; hl.FillTransparency=CFG.HLFill; hl.OutlineTransparency=CFG.HLOut
    hl.Enabled=CFG.ESP and CFG.HL
    hl.Parent=c; HLMap[p]=hl
end
local function RHL(p) local h=HLMap[p]; if h and h.Parent then h:Destroy() end; HLMap[p]=nil end
local SKR15={{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},
    {"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}}
local SKR6={{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}
local HPSeen=setmetatable({},{__mode="k"})
local ESP_UPPER=false -- texto do ESP em CAIXA ALTA (visual terminal); false = normal
local ESP_FONT=2; pcall(function() if Drawing.Fonts then ESP_FONT=Drawing.Fonts.Plex or 2 end end) -- fonte Plex
local function DrawSkel(d,c,col)
    local map=(c:FindFirstChild("UpperTorso") and SKR15) or SKR6
    for i=1,15 do
        local ln=d["S"..i]; local pr=map[i]; local ok=false
        if pr then
            local a,b=c:FindFirstChild(pr[1]),c:FindFirstChild(pr[2])
            if a and b then
                local pa,oa=Camera:WorldToViewportPoint(a.Position); local pb,ob=Camera:WorldToViewportPoint(b.Position)
                if oa and ob then ln.From=Vector2.new(pa.X,pa.Y); ln.To=Vector2.new(pb.X,pb.Y); ln.Color=col; ok=true end
            end
        end
        ln.Visible=ok
    end
end
local function HideSkel(d) for i=1,15 do d["S"..i].Visible=false end end
local function HideD(d) for _,v in pairs(d) do v.Visible=false end end
local function MakeESP(p)
    if p==LocalPlayer then return end
    local d={BS=Drawing.new("Square"),Box=Drawing.new("Square"),L=Drawing.new("Line"),HBG=Drawing.new("Line"),HB=Drawing.new("Line"),N=Drawing.new("Text")}
    d.BS.Filled=false;d.BS.Color=Color3.new(0,0,0);d.BS.Transparency=0.45;d.BS.Thickness=3
    d.Box.Filled=false;d.Box.Thickness=1.5;d.L.Thickness=2
    d.HBG.Color=Color3.fromRGB(30,30,30);d.HBG.Thickness=4;d.HB.Thickness=3
    d.N.Font=ESP_FONT;d.N.Size=13;d.N.Center=true;d.N.Outline=true
    for i=1,15 do local sl=Drawing.new("Line"); sl.Thickness=1.5; sl.Visible=false; d["S"..i]=sl end -- esqueleto
    d.AR=Drawing.new("Triangle"); d.AR.Filled=true; d.AR.Thickness=1; d.AR.Visible=false -- seta fora da tela
    d.AT=Drawing.new("Text"); d.AT.Font=ESP_FONT; d.AT.Size=12; d.AT.Center=true; d.AT.Outline=true; d.AT.Visible=false
    ESPCache[p]=d; AHL(p)
    p.CharacterAdded:Connect(function() task.wait(0.1); AHL(p) end)
    p.CharacterRemoving:Connect(function() RHL(p) end)
end
local function DelESP(p) RHL(p); if ESPCache[p] then for _,v in pairs(ESPCache[p]) do pcall(function() v:Remove() end) end; ESPCache[p]=nil end; RHL(p) end
for _,p in pairs(Players:GetPlayers()) do MakeESP(p) end
Players.PlayerAdded:Connect(MakeESP); Players.PlayerRemoving:Connect(DelESP)
-- Mochila: icones reais dos itens (Tool) acima da cabeca (equipado + Backpack)
local BAG_MAX,BAG_S,BAG_UP=16,18,46
local BagGui={}
local function BagParent()
    local ok,r=pcall(function() return (gethui and gethui()) or game:GetService("CoreGui") end)
    if ok and r then return r end
    return LocalPlayer:WaitForChild("PlayerGui")
end
local BagMem={}
local function BagItems(p)
    local c=p.Character
    local m=BagMem[p]
    if not m or m.char~=c then m={char=c,list={},map={}}; BagMem[p]=m end -- respawn limpa a memoria
    -- remove itens que foram largados no mapa
    for i=#m.list,1,-1 do
        local e=m.list[i]; local r=e.ref
        if r and r.Parent and not (r:IsDescendantOf(p) or (c and r:IsDescendantOf(c))) then
            table.remove(m.list,i); m.map[e.n]=nil
        end
    end
    local function see(t)
        if not t:IsA("Tool") then return end
        local e=m.map[t.Name]
        if not e then
            if #m.list>=BAG_MAX then return end
            e={n=t.Name}
            m.list[#m.list+1]=e; m.map[t.Name]=e
        end
        e.ref=t; e.tex=t.TextureId
        if not e.h and e.tex=="" then pcall(function() local h=t:FindFirstChild("Handle"); if h and h:IsA("BasePart") then e.h=h:Clone() end end) end
    end
    if c then for _,t in ipairs(c:GetChildren()) do see(t) end end
    local bp=p:FindFirstChildOfClass("Backpack")
    if bp then for _,t in ipairs(bp:GetChildren()) do see(t) end end
    -- varredura completa (inventarios em outras pastas do jogador), espacada para nao pesar
    local now=os.clock()
    if now-(m.scan or 0)>2 then
        m.scan=now
        for _,t in ipairs(p:GetDescendants()) do if t:IsA("Tool") then see(t) end end
    end
    local eq=c and c:FindFirstChildOfClass("Tool")
    local out={}
    for _,e in ipairs(m.list) do out[#out+1]={n=e.n,tex=e.tex or "",h=e.h,e=(eq~=nil and e.n==eq.Name)} end
    return out
end
local function BagIcon(slot,it)
    local tex=it.tex
    if tex and tex~="" then
        local im=Instance.new("ImageLabel"); im.BackgroundTransparency=1; im.Size=UDim2.new(1,-4,1,-4); im.Position=UDim2.new(0,2,0,2)
        im.ScaleType=Enum.ScaleType.Fit; im.Image=tex; im.Parent=slot; return
    end
    local ok=pcall(function()
        assert(it.h and it.e) -- viewport so no item equipado (leve)
        local vf=Instance.new("ViewportFrame"); vf.BackgroundTransparency=1; vf.Size=UDim2.new(1,-2,1,-2); vf.Position=UDim2.new(0,1,0,1)
        local cl=it.h:Clone(); cl.Anchored=true; cl.CFrame=CFrame.new(); cl.Parent=vf
        local cam=Instance.new("Camera"); cam.Parent=vf; vf.CurrentCamera=cam
        local r=math.max(cl.Size.Magnitude,0.5)
        cam.CFrame=CFrame.lookAt(Vector3.new(1,.7,1).Unit*r*1.15,Vector3.zero)
        vf.Parent=slot
    end)
    if not ok then
        local tl=Instance.new("TextLabel"); tl.BackgroundTransparency=1; tl.Size=UDim2.new(1,0,1,0); tl.Font=Enum.Font.GothamBold
        tl.TextSize=11; tl.TextColor3=Color3.new(1,1,1); tl.Text=it.n:sub(1,1):upper(); tl.Parent=slot
    end
end
local BagScreen
local function BagRoot()
    if BagScreen and BagScreen.Parent then return BagScreen end
    local sg=Instance.new("ScreenGui"); sg.Name="BagESP"; sg.ResetOnSpawn=false; sg.IgnoreGuiInset=true; sg.DisplayOrder=5
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(sg) end end)
    sg.Parent=BagParent(); BagScreen=sg; return sg
end
local BAG_ROW=6
local function UpdateBag(p,on)
    local g=BagGui[p]
    local c=p.Character
    if not (on and c) then if g then g.show=false end; return end
    if not g then
        local fr=Instance.new("Frame"); fr.Name=p.Name; fr.BackgroundTransparency=1; fr.AnchorPoint=Vector2.new(.5,1)
        fr.Size=UDim2.new(0,BAG_ROW*(BAG_S+7),0,0); fr.AutomaticSize=Enum.AutomaticSize.Y; fr.Visible=false
        local ll=Instance.new("UIListLayout"); ll.SortOrder=Enum.SortOrder.LayoutOrder; ll.Padding=UDim.new(0,2)
        ll.HorizontalAlignment=Enum.HorizontalAlignment.Center; ll.Parent=fr
        fr.Parent=BagRoot()
        g={frame=fr,sig="",t=0,n=0,show=false}; BagGui[p]=g
    end
    local now=os.clock()
    if now-g.t>0.25 then
        g.t=now
        local list=BagItems(p); local col=PCol(p)
        local parts={tostring(col),tostring(CFG.Hi)}
        for _,it in ipairs(list) do parts[#parts+1]=it.n..(it.e and "*" or "")..tostring(it.tex) end
        local sig=table.concat(parts,"|")
        if sig~=g.sig then
            g.sig=sig; g.n=#list
            for _,ch in ipairs(g.frame:GetChildren()) do if not ch:IsA("UIListLayout") then ch:Destroy() end end
            local rows={}
            for i,it in ipairs(list) do
                pcall(function()
                    local r=math.ceil(i/BAG_ROW)
                    if not rows[r] then -- linha 1 fica embaixo (perto do nome); novas linhas crescem para cima
                        local rf=Instance.new("Frame"); rf.BackgroundTransparency=1; rf.Size=UDim2.new(1,0,0,BAG_S+4); rf.LayoutOrder=-r
                        local rl=Instance.new("UIListLayout"); rl.FillDirection=Enum.FillDirection.Horizontal; rl.Padding=UDim.new(0,3)
                        rl.HorizontalAlignment=Enum.HorizontalAlignment.Center; rl.VerticalAlignment=Enum.VerticalAlignment.Bottom
                        rl.SortOrder=Enum.SortOrder.LayoutOrder; rl.Parent=rf; rf.Parent=g.frame; rows[r]=rf
                    end
                    local hi=it.e and CFG.Hi
                    local z=hi and BAG_S+4 or BAG_S
                    local slot=Instance.new("Frame"); slot.LayoutOrder=i; slot.Size=UDim2.new(0,z,0,z)
                    slot.BackgroundColor3=hi and col or Color3.new(0,0,0); slot.BackgroundTransparency=hi and .45 or .35; slot.BorderSizePixel=0; slot.Parent=rows[r]
                    local uc=Instance.new("UICorner"); uc.CornerRadius=UDim.new(0,4); uc.Parent=slot
                    local us=Instance.new("UIStroke"); us.Thickness=hi and 2.2 or 1; us.Color=hi and Color3.new(1,1,1) or col; us.Parent=slot
                    BagIcon(slot,it)
                end)
            end
        end
    end
    g.show=g.n>0
end
-- posicao a cada frame: travada em pixels logo acima do nome (nao muda com a distancia)
RunService.RenderStepped:Connect(function()
    if not next(BagGui) then return end
    local ft=math.tan(math.rad(Camera.FieldOfView*0.5))*2
    for p,g in pairs(BagGui) do
        local fr=g.frame; local vis=false
        if g.show and CFG.ESP and CFG.Bag then
            local c=p.Character; local root=c and c:FindFirstChild("HumanoidRootPart")
            if root then
                local pos,onS=Camera:WorldToViewportPoint(root.Position)
                if onS and pos.Z>0 then
                    local sc=math.max(1/(pos.Z*ft)*100,0.6) -- mesmo minimo da caixa: distancia fixa acima do nome
                    local m=math.clamp(1+(CFG.HLThick-0.10)*3,0.5,3.6); local fs=math.clamp(math.floor(13*m^0.7+.5),9,26)
                    fr.Position=UDim2.fromOffset(math.floor(pos.X),math.floor(pos.Y-21*sc-fs-8)); vis=true
                end
            end
        end
        fr.Visible=vis
    end
end)
local BAG_DIST=1000
task.spawn(function()
    while true do
        task.wait(0.4)
        local lc=LocalPlayer.Character; local lr=lc and lc:FindFirstChild("HumanoidRootPart")
        for p in pairs(ESPCache) do
            local on=CFG.ESP and CFG.Bag and lr~=nil and EnemyESP(p)
            if on then
                local r=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                on=r~=nil and (r.Position-lr.Position).Magnitude<=BAG_DIST
            end
            pcall(UpdateBag,p,on)
        end
        for p,g in pairs(BagGui) do if not ESPCache[p] then pcall(function() g.frame:Destroy() end); BagGui[p]=nil; BagMem[p]=nil end end
    end
end)
RunService.RenderStepped:Connect(function()
    if CFG.FOVRing then
        local t=Closest(); if t then FOVStr.Color=Color3.fromRGB(255,0,0)
            if CFG.FOVShrink then local c=t.Character; local pt=c and c:FindFirstChild(CFG.AimPart)
                if pt then local sp=Camera:WorldToViewportPoint(pt.Position); local cv=Camera.ViewportSize/2
                    setFR(CFG.FOVMin+(CFG.FOV-CFG.FOVMin)*math.clamp((Vector2.new(sp.X,sp.Y)-cv).Magnitude/CFG.FOV,0,1)) end
            else setFR(CFG.FOV) end
        else FOVStr.Color=Color3.fromRGB(255,255,255); setFR(CFG.FOV) end
    end
    local at=CFG.Aim and Closest() or nil
    if CFG.AimHL and at and at.Character then
        if not _aHL or not _aHL.Parent or _aHL.Adornee~=at.Character then
            if _aHL and _aHL.Parent then _aHL:Destroy() end
            _aHL=Instance.new("Highlight"); _aHL.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
            _aHL.FillColor=Color3.fromRGB(255,50,50); _aHL.OutlineColor=Color3.fromRGB(255,255,255)
            _aHL.FillTransparency=0.45; _aHL.OutlineTransparency=0; _aHL.Adornee=at.Character; _aHL.Parent=at.Character
        end
    else if _aHL and _aHL.Parent then _aHL:Destroy(); _aHL=nil end end
    if CFG.Aim and at and at.Character then
        local pt=at.Character:FindFirstChild(CFG.AimPart)
        if pt then Camera.CFrame=Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position,pt.Position),CFG.Smooth) end
    end
    if CFG.Hitbox then local s=CFG.HBSize
        for _,p in pairs(Players:GetPlayers()) do if not Enemy(p) then continue end
            pcall(function() local c=p.Character; if not c then return end
                local hrp=c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
                hrp.Size=Vector3.new(s,s,s); hrp.Transparency=CFG.HBVis and CFG.HBTrans or 1
                hrp.Color=CFG.HBColor; hrp.Material=CFG.HBMat; hrp.CanCollide=false
            end)
        end
    end
    if CFG.ESP and CFG.HL then -- garante contorno para todo mundo que o filtro do ESP permite (independe do Aimbot)
        for p in pairs(ESPCache) do
            local h=HLMap[p]
            if p~=LocalPlayer and p.Character and not (h and h.Parent) and EnemyESP(p) then AHL(p) end
        end
    end
    for p,hl in pairs(HLMap) do if hl and hl.Parent then
        if not EnemyESP(p) then hl.Enabled=false; continue end
        local c=p.Character; local isA=CFG.AimHL and CFG.Aim and _aHL and _aHL.Parent and c and _aHL.Adornee==c
        hl.Enabled=CFG.ESP and CFG.HL; hl.FillColor=isA and Color3.fromRGB(255,0,0) or PCol(p)
        hl.OutlineColor=hl.FillColor; hl.FillTransparency=CFG.HLFill; hl.OutlineTransparency=CFG.HLOut
    end end
    if not CFG.ESP then for _,e in pairs(ESPCache) do HideD(e) end; return end
    local vp=Camera.ViewportSize; local hw=vp.X/2; local ft=math.tan(math.rad(Camera.FieldOfView*0.5))*2
    -- slider "contorno" tambem controla a espessura/fonte do ESP (padrao 0.10 = tamanho original)
    local m=math.clamp(1+(CFG.HLThick-0.10)*3,0.5,3.6); local fs=math.clamp(math.floor(13*m^0.7+.5),9,26)
    for p,d in pairs(ESPCache) do
        if not EnemyESP(p) then HideD(d); continue end
        d.Box.Thickness=1.5*m; d.BS.Thickness=1.5*m+1.5; d.L.Thickness=2*m
        d.HB.Thickness=3*m; d.HBG.Thickness=3*m+1; d.N.Size=fs; d.AT.Size=math.max(9,fs-1); d.AR.Thickness=math.max(1,m)
        for i=1,15 do local sl=d["S"..i]; if sl then sl.Thickness=1.5*m end end
        local c=p.Character; local lc=LocalPlayer.Character
        local root=c and c:FindFirstChild("HumanoidRootPart"); local hum=c and c:FindFirstChild("Humanoid")
        local lr=lc and lc:FindFirstChild("HumanoidRootPart")
        if not(root and hum and lr) then HideD(d); continue end
        local pos,onS=Camera:WorldToViewportPoint(root.Position)
        local isA=CFG.AimHL and CFG.Aim and _aHL and _aHL.Parent and _aHL.Adornee==c
        local col=isA and Color3.fromRGB(255,0,0) or PCol(p)
        local dist=(root.Position-lr.Position).Magnitude
        local mh=hum.MaxHealth; local hp
        if mh and mh>0 then hp=hum.Health/mh else hp=1 end
        if hp~=hp then hp=1 end
        if hp>0 then HPSeen[hum]=hp
        elseif not HPSeen[hum] then hp=1 end -- nunca visto com vida >0 (vida nao replicou/custom): mostra cheia; so zera se morrer de fato
        hp=math.clamp(hp,0,1)
        if not onS then
            HideD(d)
            if CFG.Arrows then -- seta na borda da tela apontando para o jogador + distancia em metros
                local rel=Camera.CFrame:PointToObjectSpace(root.Position)
                local dx,dy=rel.X,-rel.Y
                if math.abs(dx)<1e-3 and math.abs(dy)<1e-3 then dy=1 end
                local m=math.sqrt(dx*dx+dy*dy); dx,dy=dx/m,dy/m
                local R=math.min(vp.X,vp.Y)*0.5-40
                local ax,ay=hw+dx*R,vp.Y/2+dy*R
                local tip=Vector2.new(ax+dx*14,ay+dy*14)
                local bs=Vector2.new(ax-dx*8,ay-dy*8)
                d.AR.PointA=tip; d.AR.PointB=bs+Vector2.new(-dy,dx)*9; d.AR.PointC=bs+Vector2.new(dy,-dx)*9
                d.AR.Color=col; d.AR.Visible=true
                d.AT.Color=col; d.AT.Position=Vector2.new(ax-dx*30,ay-dy*30-6); d.AT.Text=("%dm"):format(math.floor(dist)); d.AT.Font=ESP_FONT; d.AT.Visible=CFG.ShowDist==true
            end
            continue
        end
        d.AR.Visible=false; d.AT.Visible=false
        if CFG.Skel then DrawSkel(d,c,col) else HideSkel(d) end
        local sc=math.max(1/(pos.Z*ft)*100,0.6); local w,h=28*sc,42*sc; -- tamanho minimo: nao encolhe com a distancia
         local cx,cy=pos.X,pos.Y; local bx,by=cx-w/2,cy-h/2
        d.BS.Position=Vector2.new(bx-1,by-1);d.BS.Size=Vector2.new(w+2,h+2);d.BS.Visible=CFG.Box
        d.Box.Color=col;d.Box.Position=Vector2.new(bx,by);d.Box.Size=Vector2.new(w,h);d.Box.Visible=CFG.Box
        d.L.Color=col;d.L.From=Vector2.new(hw,vp.Y);d.L.To=Vector2.new(cx,cy);d.L.Visible=CFG.Line
        d.N.Color=col;d.N.Position=Vector2.new(cx,by-fs-2);do local m=math.floor(dist)
            if CFG.ShowName and CFG.ShowDist then d.N.Text=("[%s - %dm]"):format(p.DisplayName,m)
            elseif CFG.ShowName then d.N.Text=("[%s]"):format(p.DisplayName)
            else d.N.Text=("[%dm]"):format(m) end
            if IsMM2 and (CFG.ShowName or CFG.ShowDist) then d.N.Text=d.N.Text.." - "..RoleLabel(p)
            elseif (not IsMM2) and (CFG.ShowName or CFG.ShowDist) and AnySel(CFG.TeamSel) then d.N.Text=d.N.Text.." - "..(p.Team and p.Team.Name or L("Sem time","No team")) end end
        if ESP_UPPER then d.N.Text=string.upper(d.N.Text) end; d.N.Font=ESP_FONT
        d.N.Visible=CFG.ShowName or CFG.ShowDist
        local bX=bx-6;local bB=cy+h/2
        d.HBG.From=Vector2.new(bX,bB);d.HBG.To=Vector2.new(bX,cy-h/2);d.HBG.Visible=CFG.HP
        d.HB.From=Vector2.new(bX,bB);d.HB.To=Vector2.new(bX,bB-h*hp)
        d.HB.Color=Color3.fromRGB(math.floor(255-255*hp),math.floor(255*hp),0);d.HB.Visible=CFG.HP
    end
end)
local TabV=Window:AddTab({Name=T.TabVisual,Icon="eye",Description=T.TabVisualDesc})
local V1=TabV:AddSection(T.SecESP,true,"eye")
if V1.AddESPPanel then
    local COL={[T.White]=Color3.fromRGB(255,255,255),[T.Red]=Color3.fromRGB(255,0,0),[T.Green]=Color3.fromRGB(0,255,0),[T.Blue]=Color3.fromRGB(0,100,255),[T.Yellow]=Color3.fromRGB(255,255,0),[T.Pink]=Color3.fromRGB(255,0,200),[T.Orange]=Color3.fromRGB(255,140,0)}
    CFG.Color=COL[T.Blue]
    local names={T.White,T.Red,T.Green,T.Blue,T.Yellow,T.Pink,T.Orange}; local sopts={}
    for i,n in ipairs(names) do sopts[i]={n,COL[n]} end
    -- ===== config do ESP salva em arquivo (volta ativa ao executar de novo) =====
    local ESP_FILE=_G.__OrionPath("Config","ESP.json","OrionHub_ESP.json")
    local ESP_BOOL={"ESP","Box","Line","HP","ShowName","ShowDist","Skel","Arrows","TeamCheck","Bag","Hi","UseColor"}
    local ESP_NUM={"HLFill","HLThick"}
    local function espSnapshot()
        local t={}
        for _,k in ipairs(ESP_BOOL) do t[k]=CFG[k]==true end
        for _,k in ipairs(ESP_NUM) do t[k]=CFG[k] end
        t.CR,t.CG,t.CB=CFG.Color.R,CFG.Color.G,CFG.Color.B
        return game:GetService("HttpService"):JSONEncode(t)
    end
    pcall(function()
        if type(isfile)=="function" and type(readfile)=="function" and isfile(ESP_FILE) then
            local d=game:GetService("HttpService"):JSONDecode(readfile(ESP_FILE))
            for _,k in ipairs(ESP_BOOL) do if type(d[k])=="boolean" then CFG[k]=d[k] end end
            for _,k in ipairs(ESP_NUM) do if type(d[k])=="number" then CFG[k]=d[k] end end
            CFG.HLOut=.6*(1-CFG.HLThick)
            if type(d.CR)=="number" and type(d.CG)=="number" and type(d.CB)=="number" then CFG.Color=Color3.new(d.CR,d.CG,d.CB) end
        end
    end)
    local _swIdx=4
    for i,o in ipairs(sopts) do if o[2]==CFG.Color then _swIdx=i end end
    task.spawn(function()
        local last=espSnapshot()
        while true do
            task.wait(2)
            local ok,cur=pcall(espSnapshot)
            if ok and cur~=last and type(writefile)=="function" then last=cur; pcall(writefile,ESP_FILE,cur) end
        end
    end)
    V1:AddESPPanel({
        Get=function() return {On=CFG.ESP,Box=CFG.Box,Line=CFG.Line,HP=CFG.HP,Name=CFG.ShowName,Skel=CFG.Skel,Arrows=CFG.Arrows,HL=CFG.HL,HLFill=CFG.HLFill,HLOut=CFG.HLOut,Thick=CFG.HLThick,Dist=CFG.ShowDist,Color=PCol(LocalPlayer)} end,
        Hero={Title=T.EnableESP,Default=CFG.ESP,Callback=function(v) CFG.ESP=v end},
        Tiles=(function() local t={
            {Title=L("Distância","Distance"),Default=CFG.ShowDist,Callback=function(v) CFG.ShowDist=v end},
            {Title=T.Box,Default=CFG.Box,Callback=function(v) CFG.Box=v end},
            {Title=T.Line,Default=CFG.Line,Callback=function(v) CFG.Line=v end},
            {Title=T.Health,Default=CFG.HP,Callback=function(v) CFG.HP=v end},
            {Title=T.Name,Default=CFG.ShowName,Callback=function(v) CFG.ShowName=v end},
            {Title=T.Skeleton,Default=CFG.Skel,Callback=function(v) CFG.Skel=v end},
            {Title=L("Alerta","Alert"),Default=CFG.Arrows,Callback=function(v) CFG.Arrows=v end},
            {Title=T.TeamCheck,Default=CFG.TeamCheck,Callback=function(v) CFG.TeamCheck=v end},
            {Title=L("Mochila","Backpack"),Default=CFG.Bag,Callback=function(v) CFG.Bag=v end},
            {Title=L("Destaque","Highlight"),Default=CFG.Hi,Callback=function(v) CFG.Hi=v; for _,g in pairs(BagGui) do g.sig="" end end},
        }; for i,v in ipairs(t) do v._i=i end; table.sort(t,function(x,y) local lx,ly=utf8.len(x.Title) or #x.Title,utf8.len(y.Title) or #y.Title; if lx~=ly then return lx<ly end; return x._i<y._i end); return t end)(),
        Sliders={
            {Title=T.OutlineFill,Min=0,Max=99,Default=math.floor(CFG.HLFill*100+.5),Suffix="%",Callback=function(v) CFG.HLFill=v/100 end},
            {Title=T.OutlineWidth,Min=0,Max=100,Default=math.floor(CFG.HLThick*100+.5),Suffix="%",Callback=function(v) CFG.HLThick=v/100; CFG.HLOut=.6*(1-v/100) end},
        },
        Custom={Title=T.CustomColor,Default=CFG.UseColor,Callback=function(v) CFG.UseColor=v end},
        Swatches={Options=sopts,Default=_swIdx,Callback=function(n,c) CFG.Color=c end},
    })
else
V1:AddToggle({Title=T.EnableESP,         Default=CFG.ESP,Callback=function(v) CFG.ESP=v end})
V1:AddToggle({Title=T.Box,              Default=CFG.Box,Callback=function(v) CFG.Box=v end})
V1:AddToggle({Title=T.Line,              Default=CFG.Line,Callback=function(v) CFG.Line=v end})
V1:AddToggle({Title=T.Health,               Default=CFG.HP,Callback=function(v) CFG.HP=v end})
V1:AddToggle({Title=T.Name,               Default=CFG.ShowName,Callback=function(v) CFG.ShowName=v end})
V1:AddToggle({Title=T.Skeleton,           Default=CFG.Skel,Callback=function(v) CFG.Skel=v end})
V1:AddToggle({Title=T.Arrows,             Default=CFG.Arrows,Callback=function(v) CFG.Arrows=v end})
V1:AddToggle({Title=T.TeamCheck,     Default=CFG.TeamCheck,Callback=function(v) CFG.TeamCheck=v end})
V1:AddToggle({Title=L("Mochila","Backpack"), Default=CFG.Bag,Callback=function(v) CFG.Bag=v end})
V1:AddToggle({Title=L("Destaque","Highlight"), Default=CFG.Hi,Callback=function(v) CFG.Hi=v; for _,g in pairs(BagGui) do g.sig="" end end})
V1:AddSlider({Title=T.OutlineFill,     Min=0,Max=99,Default=70,Increment=1,Callback=function(v) CFG.HLFill=v/100 end})
V1:AddSlider({Title=T.OutlineWidth, Min=0,Max=100,Default=10,Increment=1,Callback=function(v) CFG.HLThick=v/100; CFG.HLOut=.6*(1-v/100) end})
CFG.Color=Color3.fromRGB(0,100,255)
V1:AddToggle({Title=T.CustomColor,  Default=CFG.UseColor,Callback=function(v) CFG.UseColor=v end})
V1:AddDropdown({Title=T.ESPColor,Multi=false,
    Options={T.White,T.Red,T.Green,T.Blue,T.Yellow,T.Pink,T.Orange},
    Default  = T.Blue,
    Callback=function(v)
        local c={[T.White]=Color3.fromRGB(255,255,255),[T.Red]=Color3.fromRGB(255,0,0),[T.Green]=Color3.fromRGB(0,255,0),
                 [T.Blue]=Color3.fromRGB(0,100,255),[T.Yellow]=Color3.fromRGB(255,255,0),[T.Pink]=Color3.fromRGB(255,0,200),[T.Orange]=Color3.fromRGB(255,140,0)}
        CFG.Color=c[v] or Color3.fromRGB(255,255,255)
    end})
end
-- filtro de times/papeis: dentro da secao ESP, logo abaixo do painel
if IsMM2 then
    V1:AddChipPanel({Title=L("Filtrar times","Filter teams"),Columns=3,Chips={
        {Title=L("Assassino","Murderer"),Default=false,Callback=function(v) CFG.RoleSel.Murderer=v end,Color=RoleCol.Murderer},
        {Title=L("Xerife","Sheriff"),Default=false,Callback=function(v) CFG.RoleSel.Sheriff=v end,Color=RoleCol.Sheriff},
        {Title=L("Inocentes","Innocents"),Default=false,Callback=function(v) CFG.RoleSel.Innocent=v end,Color=RoleCol.Innocent}}})
else
    local TeamsSvc=game:GetService("Teams")
    local tp -- o painel so e criado se o jogo tiver times
    local function addTeam(t)
        if not tp then tp=V1:AddChipPanel({Title=L("Filtrar times","Filter teams"),Columns=2}) end
        tp:AddChip(t.Name,false,function(v) CFG.TeamSel[t.Name]=v end,t.TeamColor.Color)
    end
    for _,t in ipairs(TeamsSvc:GetTeams()) do addTeam(t) end
    TeamsSvc.ChildAdded:Connect(function(t) if t:IsA("Team") then pcall(addTeam,t) end end)
end
local V2=TabV:AddSection(T.SecAimbot,true)
V2:AddToggle({Title=T.EnableAimbot,  Default=false,Callback=function(v) CFG.Aim=v; if not v and _aHL and _aHL.Parent then _aHL:Destroy();_aHL=nil end end})
V2:AddToggle({Title=T.HighlightTarget,  Default=true, Callback=function(v) CFG.AimHL=v; if not v and _aHL and _aHL.Parent then _aHL:Destroy();_aHL=nil end end})
V2:AddToggle({Title=T.CheckTeam, Default=true, Callback=function(v) CFG.AimTeam=v end})
V2:AddToggle({Title=T.IgnoreDead, Default=true, Callback=function(v) CFG.AimAlive=v end})
V2:AddToggle({Title=T.Aim360,      Default=false,Callback=function(v) CFG.Aim360=v end})
V2:AddSlider({Title=T.MaxDistance,  Min=50,Max=2000,Default=500,Increment=10,Callback=function(v) CFG.AimDist=v end})
V2:AddSlider({Title=T.FOVParam,            Min=30,Max=400,Default=80, Increment=5, Callback=function(v) CFG.FOV=v; setFR(v) end})
V2:AddSlider({Title=T.Smoothness,      Min=1, Max=100,Default=50, Increment=1, Callback=function(v) CFG.Smooth=v/100 end})
V2:AddDropdown({Title=T.TargetPart,Multi=false,Default=T.Head,Options={T.Head,T.Chest,T.Belly,T.Legs},
    Callback=function(v) local m={[T.Head]="Head",[T.Chest]="UpperTorso",[T.Belly]="LowerTorso",[T.Legs]="HumanoidRootPart"}; CFG.AimPart=m[v] or "Head" end})
do
    local function opts() local o={T.Automatic}; for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer then table.insert(o,p.Name) end end; return o end
    local dd=V2:AddDropdown({Title=T.TargetPlayer,Multi=false,Default=T.Automatic,Options=opts(),Callback=function(v) CFG.AimTarget=v==T.Automatic and nil or v end})
    Players.PlayerAdded:Connect(function() pcall(function() dd:SetOptions(opts()) end) end)
    Players.PlayerRemoving:Connect(function(p) if CFG.AimTarget==p.Name then CFG.AimTarget=nil end; pcall(function() dd:SetOptions(opts()) end) end)
end
local V3=TabV:AddSection(T.SecFOVCircle,true)
V3:AddToggle({Title=T.ShowCircle,     Default=false,Callback=function(v) CFG.FOVRing=v; FOVGui.Enabled=v end})
V3:AddSlider({Title=T.Size,              Min=10,Max=400,Default=60,Increment=5, Callback=function(v) CFG.FOV=v; setFR(v) end})
V3:AddSlider({Title=T.Thickness,            Min=1, Max=10, Default=2, Increment=1, Callback=function(v) FOVStr.Thickness=v end})
V3:AddSlider({Title=T.Transparency,        Min=0, Max=99, Default=0, Increment=1, Callback=function(v) FOVStr.Transparency=v/100 end})
V3:AddToggle({Title=T.ShrinkCloser,Default=false,Callback=function(v) CFG.FOVShrink=v; if not v then setFR(CFG.FOV) end end})
local SL_gui=nil; local SL_rc=nil; local SL_ar=nil
local function SL_on()
    CFG.SL=true; UserInputService.MouseBehavior=Enum.MouseBehavior.LockCenter
    local c=LocalPlayer.Character; if not c then return end
    local h=c:FindFirstChildOfClass("Humanoid"); if not h then return end
    if SL_ar==nil then SL_ar=h.AutoRotate end; h.AutoRotate=false
    if SL_rc then SL_rc:Disconnect() end
    SL_rc=RunService.RenderStepped:Connect(function()
        if not CFG.SL then return end
        local c2=LocalPlayer.Character; if not c2 then return end
        local r=c2:FindFirstChild("HumanoidRootPart"); if not r then return end
        local lv=workspace.CurrentCamera.CFrame.LookVector
        r.CFrame=CFrame.new(r.Position,r.Position+Vector3.new(lv.X,0,lv.Z))
    end)
    if not SL_gui or not SL_gui.Parent then
        SL_gui=Instance.new("ScreenGui",LocalPlayer.PlayerGui); SL_gui.Name="SL_Gui"; SL_gui.ResetOnSpawn=false
        SL_gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
        local ic=Instance.new("ImageLabel",SL_gui); ic.Size=UDim2.fromOffset(32,32)
        ic.Position=UDim2.new(0.5,-16,1,-80); ic.BackgroundTransparency=1
        ic.Image="rbxasset://textures/ui/mouseLock_on.png"
    end
end
local function SL_off()
    CFG.SL=false; UserInputService.MouseBehavior=Enum.MouseBehavior.Default
    if SL_rc then SL_rc:Disconnect(); SL_rc=nil end
    if SL_ar~=nil then local c=LocalPlayer.Character; if c then local h=c:FindFirstChildOfClass("Humanoid"); if h then h.AutoRotate=SL_ar end end; SL_ar=nil end
    if SL_gui then SL_gui:Destroy(); SL_gui=nil end
end
LocalPlayer.CharacterAdded:Connect(function() if CFG.SL then task.wait(0.2); SL_on() end end)
local SL_key = Enum.KeyCode.LeftShift
UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == SL_key then if CFG.SL then SL_off() else SL_on() end end
end)
local V4=TabV:AddSection(T.SecShiftLock,true)
V4:AddToggle({Title=T.EnableShiftLock, Default=false,
    Callback=function(v) if v then SL_on() else SL_off() end end})
V4:AddKeybind({Title=T.ShortcutKey, Default=Enum.KeyCode.LeftShift,
    Callback=function(kc) SL_key=kc end})
V4:AddToggle({Title=T.ScreenIcon, Default=true,
    Callback=function(v)
        if SL_gui and SL_gui.Parent then
            local ic=SL_gui:FindFirstChildOfClass("ImageLabel")
            if ic then ic.Visible=v end
        end
    end})
local V5=TabV:AddSection(T.SecHitbox,true)
V5:AddToggle({Title=T.EnableHitbox,Default=false,
    Callback=function(v) CFG.Hitbox=v
        if not v then for _,p in pairs(Players:GetPlayers()) do local c=p.Character; if not c then continue end
            local hrp=c:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
            hrp.Size=Vector3.new(2,2,1); hrp.Transparency=1; hrp.Material=Enum.Material.SmoothPlastic; hrp.CanCollide=true end end
    end})
V5:AddSlider({Title=T.Size,       Min=2,Max=30,Default=10,Increment=1,Callback=function(v) CFG.HBSize=v end})
V5:AddSlider({Title=T.Transparency, Min=0,Max=99,Default=50,Increment=1,Callback=function(v) CFG.HBTrans=v/100 end})
V5:AddToggle({Title=T.ShowHitbox,Default=true,Callback=function(v) CFG.HBVis=v end})
V5:AddDropdown({Title=T.Color,Multi=false,Default=T.Red,
    Options={T.Red,T.Orange,T.Yellow,T.Green,T.Blue,T.Pink,T.White},
    Callback=function(v)
        local c={[T.Red]=Color3.fromRGB(255,0,0),[T.Orange]=Color3.fromRGB(255,140,0),[T.Yellow]=Color3.fromRGB(255,255,0),
                 [T.Green]=Color3.fromRGB(0,255,0),[T.Blue]=Color3.fromRGB(0,100,255),[T.Pink]=Color3.fromRGB(255,0,200),[T.White]=Color3.fromRGB(255,255,255)}
        CFG.HBColor=c[v] or Color3.fromRGB(255,0,0)
    end})
V5:AddDropdown({Title=T.Material,Multi=false,Default=T.Neon,Options={T.Neon,T.Plastic,T.Glass},
    Callback=function(v)
        local m={[T.Neon]=Enum.Material.Neon,[T.Plastic]=Enum.Material.SmoothPlastic,[T.Glass]=Enum.Material.Glass}
        CFG.HBMat=m[v] or Enum.Material.Neon
    end})
local TabG=Window:AddTab({Name=T.TabGraphics,Icon="sun-moon",Description=T.TabGraphicsDesc})
local Terrain=workspace.Terrain
local og={WS=Terrain.WaterWaveSize,WW=Terrain.WaterWaveSpeed,WR=Terrain.WaterReflectance,WT=Terrain.WaterTransparency,
    GS=Lighting.GlobalShadows,FE=Lighting.FogEnd,FS=Lighting.FogStart,BR=Lighting.Brightness,
    AM=Lighting.Ambient,OA=Lighting.OutdoorAmbient,CB=Lighting.ColorShift_Bottom,CT=Lighting.ColorShift_Top,
    CK=Lighting.ClockTime,GL=Lighting.GeographicLatitude,QL=settings().Rendering.QualityLevel}
local ogFX={}
for _,e in pairs(Lighting:GetChildren()) do
    if (e:IsA("BlurEffect") and e.Name~="OrionStudios_Blur") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then ogFX[e]=e.Enabled end
end
local ogPts={}; local rCloud=nil
local function apAL()
    Terrain.WaterWaveSize=0;Terrain.WaterWaveSpeed=0;Terrain.WaterReflectance=0;Terrain.WaterTransparency=0
    Lighting.GlobalShadows=false;Lighting.FogEnd=9e9;Lighting.Brightness=0;settings().Rendering.QualityLevel="Level01"
    for _,v in pairs(game:GetDescendants()) do pcall(function()
        if v:IsA("BasePart") then if not ogPts[v] then ogPts[v]={k="p",M=v.Material,R=v.Reflectance} end; v.Material=Enum.Material.Plastic;v.Reflectance=0
        elseif v:IsA("Decal") or v:IsA("Texture") then if not ogPts[v] then ogPts[v]={k="d",T=v.Transparency} end; v.Transparency=1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then if not ogPts[v] then ogPts[v]={k="r",L=v.Lifetime} end; v.Lifetime=NumberRange.new(0)
        elseif v:IsA("Fire") or v:IsA("Smoke") or v:IsA("SpotLight") then if not ogPts[v] then ogPts[v]={k="e",E=v.Enabled} end; v.Enabled=false end
    end) end
    for _,e in pairs(Lighting:GetChildren()) do if (e:IsA("BlurEffect") and e.Name~="OrionStudios_Blur") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then e.Enabled=false end end
end
local function rmAL()
    Terrain.WaterWaveSize=og.WS;Terrain.WaterWaveSpeed=og.WW;Terrain.WaterReflectance=og.WR;Terrain.WaterTransparency=og.WT
    Lighting.GlobalShadows=og.GS;Lighting.FogEnd=og.FE;Lighting.Brightness=og.BR;settings().Rendering.QualityLevel=og.QL
    for fx,st in pairs(ogFX) do if fx and fx.Parent then fx.Enabled=st end end
    for i,d in pairs(ogPts) do if i and i.Parent then pcall(function()
        if d.k=="p" then i.Material=d.M;i.Reflectance=d.R elseif d.k=="d" then i.Transparency=d.T
        elseif d.k=="r" then i.Lifetime=d.L elseif d.k=="e" then i.Enabled=d.E end end) end end; ogPts={}
end
local function apFB()
    Lighting.Brightness=2;Lighting.GlobalShadows=false;Lighting.Ambient=Color3.fromRGB(178,178,178)
    Lighting.OutdoorAmbient=Color3.fromRGB(178,178,178);Lighting.ClockTime=14;Lighting.FogEnd=9e9
    for _,e in pairs(Lighting:GetChildren()) do if (e:IsA("BlurEffect") and e.Name~="OrionStudios_Blur") or e:IsA("ColorCorrectionEffect") or e:IsA("DepthOfFieldEffect") then e.Enabled=false end end
end
local function rmFB()
    Lighting.Brightness=og.BR;Lighting.GlobalShadows=og.GS;Lighting.Ambient=og.AM
    Lighting.OutdoorAmbient=og.OA;Lighting.ClockTime=og.CK;Lighting.FogEnd=og.FE
    for fx,st in pairs(ogFX) do if fx and fx.Parent then fx.Enabled=st end end
end
local function apRL()
    if rCloud then rCloud:Destroy() end; rCloud=Instance.new("Clouds",Terrain); rCloud.Cover=0.662;rCloud.Density=0.7;rCloud.Color=Color3.fromRGB(8,8,8)
    Lighting.Ambient=Color3.new(0,0,0);Lighting.ColorShift_Bottom=Color3.new(0,0,0);Lighting.ColorShift_Top=Color3.new(0,0,0)
    Lighting.OutdoorAmbient=Color3.fromRGB(77,77,77);Lighting.ClockTime=6.2;Lighting.GeographicLatitude=272;Lighting.FogEnd=1e8
    pcall(function() Lighting.LightingStyle=Enum.LightingStyle.Realistic end)
end
local function rmRL()
    if rCloud then rCloud:Destroy();rCloud=nil end
    Lighting.Ambient=og.AM;Lighting.ColorShift_Bottom=og.CB;Lighting.ColorShift_Top=og.CT
    Lighting.OutdoorAmbient=og.OA;Lighting.ClockTime=og.CK;Lighting.GeographicLatitude=og.GL;Lighting.FogEnd=og.FE
    for fx,st in pairs(ogFX) do if fx and fx.Parent then pcall(function() fx.Enabled=st end) end end
end
local function apRTX(p)
    for _,c in pairs(Lighting:GetChildren()) do if c.Name~="OrionStudios_Blur" then c:Destroy() end end
    local function sky() local S=Instance.new("Sky",Lighting)
        S.SkyboxBk="http://www.roblox.com/asset/?id=151165214";S.SkyboxDn="http://www.roblox.com/asset/?id=151165197"
        S.SkyboxFt="http://www.roblox.com/asset/?id=151165224";S.SkyboxLf="http://www.roblox.com/asset/?id=151165191"
        S.SkyboxRt="http://www.roblox.com/asset/?id=151165206";S.SkyboxUp="http://www.roblox.com/asset/?id=151165227"
    end
    if p=="neblina" then
        local B=Instance.new("BloomEffect",Lighting);B.Intensity=0.2;B.Size=12;B.Threshold=0.9
        local SR=Instance.new("SunRaysEffect",Lighting);SR.Intensity=0.05;SR.Spread=0.5
        local CC=Instance.new("ColorCorrectionEffect",Lighting);CC.Saturation=-0.2;CC.TintColor=Color3.fromRGB(200,220,255)
        sky();Lighting.Brightness=1.5;Lighting.ClockTime=10;Lighting.GlobalShadows=true;Lighting.Ambient=Color3.fromRGB(180,200,220)
    elseif p=="tarde" then
        local B=Instance.new("BloomEffect",Lighting);B.Intensity=0.3;B.Size=10;B.Threshold=0.8
        local SR=Instance.new("SunRaysEffect",Lighting);SR.Intensity=0.1;SR.Spread=0.8
        local CC=Instance.new("ColorCorrectionEffect",Lighting);CC.Saturation=0.4;CC.TintColor=Color3.fromRGB(255,235,203)
        sky();Lighting.Brightness=2.5;Lighting.ClockTime=14;Lighting.GlobalShadows=true;Lighting.Ambient=Color3.fromRGB(255,200,150)
    elseif p=="entardecer" then
        local B=Instance.new("BloomEffect",Lighting);B.Intensity=0.5;B.Size=14;B.Threshold=0.7
        local SR=Instance.new("SunRaysEffect",Lighting);SR.Intensity=0.15;SR.Spread=1
        local CC=Instance.new("ColorCorrectionEffect",Lighting);CC.Saturation=0.5;CC.TintColor=Color3.fromRGB(255,160,100)
        sky();Lighting.Brightness=1.8;Lighting.ClockTime=18;Lighting.GlobalShadows=true;Lighting.Ambient=Color3.fromRGB(255,120,80)
    elseif p=="noite" then
        local B=Instance.new("BloomEffect",Lighting);B.Intensity=0.8;B.Size=16;B.Threshold=0.5
        local SR=Instance.new("SunRaysEffect",Lighting);SR.Intensity=0.02;SR.Spread=0.3
        local CC=Instance.new("ColorCorrectionEffect",Lighting);CC.Saturation=0.1;CC.TintColor=Color3.fromRGB(130,150,210)
        sky();Lighting.Brightness=0.5;Lighting.ClockTime=23;Lighting.GlobalShadows=true;Lighting.Ambient=Color3.fromRGB(10,10,40)
    end
end
local G1=TabG:AddSection(T.SecGraphics,true)
G1:AddToggle({Title=T.RemoveTextures,Default=false,Callback=function(v) if v then apAL() else rmAL() end end})
G1:AddToggle({Title=T.MaxBrightness,       Default=false,Callback=function(v) if v then apFB() else rmFB() end end})
G1:AddToggle({Title=T.RealisticGfx, Default=false,Callback=function(v) if v then apRL() else rmRL() end end})
G1:AddToggle({Title=T.RemoveFog,  Default=false,Callback=function(v) if v then Lighting.FogEnd=9e9;Lighting.FogStart=9e9 else Lighting.FogEnd=og.FE;Lighting.FogStart=og.FS end end})
local G2=TabG:AddSection(T.SecRTX,true)
G2:AddButton({Title=T.RTXFog,    Callback=function() apRTX("neblina")    end})
G2:AddButton({Title=T.RTXAfternoon,      Callback=function() apRTX("tarde")      end})
G2:AddButton({Title=T.RTXSunset, Callback=function() apRTX("entardecer") end})
G2:AddButton({Title=T.RTXNight,      Callback=function() apRTX("noite")      end})
local G3=TabG:AddSection(T.SecCamZoom,true)
local zOn=false;local zVal=50
G3:AddToggle({Title=T.EnableZoom,Default=false,Callback=function(v) zOn=v; workspace.CurrentCamera.FieldOfView=v and zVal or 70 end})
G3:AddSlider({Title=T.Value,Min=1,Max=120,Default=50,Increment=1,Callback=function(v) zVal=v; if zOn then workspace.CurrentCamera.FieldOfView=v end end})
local G4=TabG:AddSection(T.SecXRay,true)
local xOn=false;local xOrig={}
G4:AddToggle({Title=T.EnableXRay,Default=false,
    Callback=function(v) xOn=v
        if v then for _,p in pairs(workspace:GetDescendants()) do if p:IsA("BasePart") then if not xOrig[p] then xOrig[p]=p.Transparency end; p.Transparency=0.4 end end
        else for p,t in pairs(xOrig) do if p and p.Parent then p.Transparency=t end end; xOrig={} end
    end})
G4:AddSlider({Title=T.Level,Min=0,Max=95,Default=40,Increment=1,Callback=function(v) if xOn then for p in pairs(xOrig) do if p and p.Parent then p.Transparency=v/100 end end end end})
local G5=TabG:AddSection(T.SecTimeOfDay,true)
local ckConn=nil;local ckLock=nil
G5:AddSlider({Title=T.Time,Min=0,Max=24,Default=math.floor(og.CK),Increment=1,
    Callback=function(v) ckLock=v; Lighting.ClockTime=v
        if not ckConn then ckConn=RunService.Heartbeat:Connect(function() if ckLock then Lighting.ClockTime=ckLock end end) end
    end})
local TabP=Window:AddTab({Name=T.TabPlayer,Icon="users-round",Description=T.TabPlayerDesc})
do
    local mouse=LocalPlayer:GetMouse()
    local MV={SpV=100,JpV=100,SpOn=false,JpOn=false,FlyOn=false,FlySpd=50}
    local function gH() local c=LocalPlayer.Character; return c and c:FindFirstChildOfClass("Humanoid") end
    local function gR() local c=LocalPlayer.Character; return c and c:FindFirstChild("HumanoidRootPart") end
    LocalPlayer.CharacterAdded:Connect(function(c) task.wait(0.5); local h=c:FindFirstChildOfClass("Humanoid"); if not h then return end
        if MV.SpOn then h.WalkSpeed=MV.SpV end; if MV.JpOn then h.JumpPower=MV.JpV end end)
    local SC; local function setSp(v) MV.SpOn=v; if SC then SC:Disconnect();SC=nil end
        if v then SC=RunService.Heartbeat:Connect(function() local h=gH(); if h then h.WalkSpeed=MV.SpV end end) else local h=gH(); if h then h.WalkSpeed=16 end end end
    local JC; local function setJp(v) MV.JpOn=v; if JC then JC:Disconnect();JC=nil end
        if v then JC=RunService.Heartbeat:Connect(function() local h=gH(); if h then h.JumpPower=MV.JpV end end) else local h=gH(); if h then h.JumpPower=50 end end end
    local bv,bg2,fC,fly=nil,nil,nil,false
    local function _flyUpdate()
        local r2=gR(); if not fly or not bv or not bg2 or not r2 then return end
        local cam=workspace.CurrentCamera; local mv=Vector3.zero
        if UserInputService.TouchEnabled then
            pcall(function()
                local ok2,ctrl=pcall(function()
                    return require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
                end)
                if ok2 and ctrl and ctrl.GetMoveVector then
                    local dir=ctrl:GetMoveVector()
                    mv+=cam.CFrame.RightVector*dir.X; mv+=cam.CFrame.LookVector*-dir.Z
                end
            end)
        end
        if UserInputService.KeyboardEnabled then
            local function k(kc) return UserInputService:IsKeyDown(kc) end
            if k(Enum.KeyCode.W) then mv+=cam.CFrame.LookVector end; if k(Enum.KeyCode.S) then mv-=cam.CFrame.LookVector end
            if k(Enum.KeyCode.A) then mv-=cam.CFrame.RightVector end; if k(Enum.KeyCode.D) then mv+=cam.CFrame.RightVector end
            if k(Enum.KeyCode.Space) then mv+=Vector3.new(0,1,0) end; if k(Enum.KeyCode.LeftShift) then mv+=Vector3.new(0,-1,0) end
        end
        bv.Velocity=mv*MV.FlySpd; bg2.CFrame=CFrame.new(r2.Position,r2.Position+cam.CFrame.LookVector)
    end
    local function startFly()
        local r=gR(); local h=gH(); if fly or not r then return end; fly=true
        bv=Instance.new("BodyVelocity"); bv.MaxForce=Vector3.new(1e5,1e5,1e5); bv.Velocity=Vector3.zero; bv.Parent=r
        bg2=Instance.new("BodyGyro"); bg2.MaxTorque=Vector3.new(1e5,1e5,1e5); bg2.P=3000; bg2.D=500; bg2.CFrame=r.CFrame; bg2.Parent=r
        if h then h.PlatformStand=true end
        if fC then fC:Disconnect() end; fC=RunService.Heartbeat:Connect(_flyUpdate)
    end
    local function stopFly()
        if not fly then return end; fly=false
        if bv then bv:Destroy();bv=nil end; if bg2 then bg2:Destroy();bg2=nil end
        if fC then fC:Disconnect();fC=nil end; local h=gH(); if h then h.PlatformStand=false end
    end
    LocalPlayer.CharacterAdded:Connect(function(c) c:WaitForChild("HumanoidRootPart"); if fly then task.wait(0.3);startFly() end end)
    local P1=TabP:AddSection(T.SecMovement,true)
    P1:AddToggle({Title=T.Speed,     Default=false,Callback=function(v) setSp(v) end})
    P1:AddSlider({Title=T.Value,          Min=16,Max=500,Default=100,Increment=1,Callback=function(v) MV.SpV=v; if MV.SpOn then local h=gH(); if h then h.WalkSpeed=v end end end})
    P1:AddToggle({Title=T.SuperJump,     Default=false,Callback=function(v) setJp(v) end})
    P1:AddSlider({Title=T.JumpHeight, Min=50,Max=500,Default=100,Increment=5,Callback=function(v) MV.JpV=v; if MV.JpOn then local h=gH(); if h then h.JumpPower=v end end end})
    P1:AddToggle({Title=T.Fly,           Default=false,Callback=function(v) MV.FlyOn=v; if v then startFly() else stopFly() end end})
    P1:AddSlider({Title=T.FlightSpeed, Min=1,Max=200,Default=50,Increment=1,Callback=function(v) MV.FlySpd=v end})
    local nCC=nil; local noclipOn=false; local nOrigCC={}
    P1:AddToggle({Title=T.Noclip,Default=false,
        Callback=function(v)
            noclipOn=v
            if v then
                local c=LocalPlayer.Character; if not c then return end
                table.clear(nOrigCC)
                for _,p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then nOrigCC[p]=p.CanCollide end end
                if nCC then nCC:Disconnect() end
                nCC=RunService.Stepped:Connect(function()
                    local ch=LocalPlayer.Character; if not ch then return end
                    for _,p in pairs(ch:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
                end)
            else
                if nCC then nCC:Disconnect(); nCC=nil end
                local c=LocalPlayer.Character; if c then
                    for _,p in pairs(c:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = nOrigCC[p] ~= nil and nOrigCC[p] or (p.Name~="HumanoidRootPart") end
                    end
                end
                table.clear(nOrigCC)
            end
        end})
    LocalPlayer.CharacterAdded:Connect(function()
        if nCC then nCC:Disconnect(); nCC=nil end
        table.clear(nOrigCC)
        if noclipOn then
            task.wait(0.3)
            local c=LocalPlayer.Character; if not c then return end
            for _,p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then nOrigCC[p]=p.CanCollide end end
            nCC=RunService.Stepped:Connect(function()
                local ch=LocalPlayer.Character; if not ch then return end
                for _,p in pairs(ch:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
            end)
        end
    end)
    local P2=TabP:AddSection(T.SecTools,true)
    local tpT=nil
    P2:AddToggle({Title="TP Tool",Default=false,
        Callback=function(v) if v then if tpT then return end; local bp=LocalPlayer:FindFirstChild("Backpack"); if not bp then return end
            tpT=Instance.new("Tool"); tpT.RequiresHandle=false; tpT.Name="TP Tool"; tpT.Parent=bp
            tpT.Activated:Connect(function() local r=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if r and mouse.Hit then r.CFrame=CFrame.new(mouse.Hit.Position+Vector3.new(0,2.5,0)) end end)
        else if tpT then tpT:Destroy();tpT=nil end end end})
    local ghOn=false;local ghC=nil;local ghM={};local ghT=0.75
    local function ghA(c,val)
        for _,i in ipairs(c:GetDescendants()) do
            if i:IsA("BasePart") and i.Name~="HumanoidRootPart" then
                if val==nil then if ghM[i] then i.LocalTransparencyModifier=ghM[i] end
                else if ghM[i]==nil then ghM[i]=i.LocalTransparencyModifier end; i.LocalTransparencyModifier=val end
            end
            if i:IsA("Decal") or i:IsA("Texture") then
                if val==nil then if ghM[i] then i.Transparency=ghM[i] end
                else if ghM[i]==nil then ghM[i]=i.Transparency end; i.Transparency=val end end
        end
    end
    local function ghE() local c=LocalPlayer.Character; if not c or not c:FindFirstChild("HumanoidRootPart") then return end
        table.clear(ghM); ghA(c,ghT); if ghC then ghC:Disconnect() end
        ghC=RunService.Stepped:Connect(function() local c2=LocalPlayer.Character; if not c2 then return end
            for _,p in ipairs(c2:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end); ghOn=true
    end
    local function ghD() ghOn=false; if ghC then ghC:Disconnect();ghC=nil end
        local c=LocalPlayer.Character; if c then ghA(c,nil); for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end end; table.clear(ghM)
    end
    LocalPlayer.CharacterAdded:Connect(function() ghOn=false; if ghC then ghC:Disconnect();ghC=nil end; table.clear(ghM) end)
    local P3=TabP:AddSection(T.SecGhostMode,true)
    P3:AddToggle({Title=T.Enable,Default=false,Callback=function(v) if v then ghE() else ghD() end end})
    P3:AddSlider({Title=T.Transparency,Min=10,Max=100,Default=75,Increment=1,
        Callback=function(v) ghT=v/100; if ghOn then for i in pairs(ghM) do if i and i.Parent then
            if i:IsA("BasePart") and i.Name~="HumanoidRootPart" then i.LocalTransparencyModifier=ghT
            elseif i:IsA("Decal") or i:IsA("Texture") then i.Transparency=ghT end end end end end})
end
do
    local AV={model=nil,hrp=nil,weld=nil,renderConn=nil,motorPairs={},
        hideSelf=false,hiddenParts={},hideConn=nil,hideEnfConn=nil,
        lastUserId=nil,lastUsername=nil,selectedUserId=nil,selectedUsername=nil}
    local AV_FOLDER="_OrionHub_AvatarOverlay"
    local function av_getFolder()
        local cam=workspace.CurrentCamera; if not cam then return nil end
        local f=cam:FindFirstChild(AV_FOLDER)
        if not f then f=Instance.new("Folder"); f.Name=AV_FOLDER; f.Parent=cam end; return f
    end
    local function av_stopHide()
        if AV.hideConn then AV.hideConn:Disconnect(); AV.hideConn=nil end
        if AV.hideEnfConn then AV.hideEnfConn:Disconnect(); AV.hideEnfConn=nil end
    end
    local function av_setHide(enabled)
        AV.hideSelf=enabled; local char=LocalPlayer.Character; av_stopHide()
        for inst,prev in pairs(AV.hiddenParts) do if inst and inst.Parent then
            if inst:IsA("BasePart") then inst.LocalTransparencyModifier=prev
            elseif inst:IsA("Decal") or inst:IsA("Texture") then inst.Transparency=prev end
        end end
        table.clear(AV.hiddenParts)
        if not enabled or not char then return end
        for _,inst in ipairs(char:GetDescendants()) do
            if inst:IsA("BasePart") then AV.hiddenParts[inst]=inst.LocalTransparencyModifier; inst.LocalTransparencyModifier=1
            elseif inst:IsA("Decal") or inst:IsA("Texture") then AV.hiddenParts[inst]=inst.Transparency; inst.Transparency=1 end
        end
        AV.hideConn=char.DescendantAdded:Connect(function(inst)
            if not AV.hideSelf then return end
            if inst:IsA("BasePart") then if AV.hiddenParts[inst]==nil then AV.hiddenParts[inst]=inst.LocalTransparencyModifier end; inst.LocalTransparencyModifier=1
            elseif inst:IsA("Decal") or inst:IsA("Texture") then if AV.hiddenParts[inst]==nil then AV.hiddenParts[inst]=inst.Transparency end; inst.Transparency=1 end
        end)
        local acc=0
        AV.hideEnfConn=RunService.RenderStepped:Connect(function(dt)
            if not AV.hideSelf then return end; acc+=dt; if acc<0.12 then return end; acc=0
            for inst in pairs(AV.hiddenParts) do if inst and inst.Parent then
                if inst:IsA("BasePart") and inst.LocalTransparencyModifier~=1 then inst.LocalTransparencyModifier=1
                elseif (inst:IsA("Decal") or inst:IsA("Texture")) and inst.Transparency~=1 then inst.Transparency=1 end
            end end
        end)
    end
    local function av_motorKey(m)
        return m.Name.."|"..((m.Part0 and m.Part0.Name) or "nil")..">"..(( m.Part1 and m.Part1.Name) or "nil")
    end
    local function av_buildMotors(srcChar,tgtModel)
        table.clear(AV.motorPairs); local srcMap={}
        for _,d in ipairs(srcChar:GetDescendants()) do if d:IsA("Motor6D") then srcMap[av_motorKey(d)]=d end end
        for _,d in ipairs(tgtModel:GetDescendants()) do if d:IsA("Motor6D") then
            local src=srcMap[av_motorKey(d)]; if src then table.insert(AV.motorPairs,{src=src,tgt=d}) end
        end end
    end
    local function av_destroy()
        if AV.renderConn then AV.renderConn:Disconnect(); AV.renderConn=nil end
        table.clear(AV.motorPairs)
        if AV.model then pcall(function() AV.model:Destroy() end) end
        AV.model=nil; AV.hrp=nil; AV.weld=nil; av_setHide(false)
        pcall(function() local char=LocalPlayer.Character; local hum=char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.Viewer; hum.NameDisplayDistance=100
                hum.HealthDisplayType=Enum.HumanoidHealthDisplayType.DisplayWhenDamaged; hum.HealthDisplayDistance=100 end end)
    end
    local function av_resolveTarget(text)
        text=tostring(text or ""):gsub("^%s+",""):gsub("%s+$",""); if text=="" then return false,T.EmptyInput end
        local asNum=tonumber(text)
        if asNum then local uid=math.floor(asNum); if uid<=0 then return false,T.InvalidUserID end
            local ok,uname=pcall(function() return Players:GetNameFromUserIdAsync(uid) end)
            if not ok or not uname then return false,T.UserIDNotFound end; return true,uid,uname end
        local ok,uid=pcall(function() return Players:GetUserIdFromNameAsync(text) end)
        if not ok or not uid or uid==0 then return false,T.UsernameNotFound end
        return true,uid,text
    end
    local function av_spawn(userId,username,setStatus)
        setStatus(T.LoadingAvatar); av_destroy()
        local okM,modelOrErr=pcall(function() return Players:CreateHumanoidModelFromUserIdAsync(userId) end)
        if not okM or typeof(modelOrErr)~="Instance" then setStatus(T.AvatarFail..tostring(modelOrErr)); return false end
        local model=modelOrErr; model.Name=("AVOverlay_%d"):format(userId)
        local folder=av_getFolder(); if not folder then model:Destroy(); setStatus(T.CamNotReady); return false end
        model.Parent=folder
        for _,d in ipairs(model:GetDescendants()) do
            if d:IsA("Script") or d:IsA("LocalScript") then d.Disabled=true end
            if d:IsA("BasePart") then d.CanCollide=false; d.CanTouch=false; d.Massless=true end
        end
        local hum=model:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand=true; hum.AutoRotate=false
            pcall(function() hum.EvaluateStateMachine=false end)
            hum.WalkSpeed=0; hum.JumpPower=0; hum.JumpHeight=0
            pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Jumping,false) end)
            pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Freefall,false) end)
            pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Landed,false) end)
            pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Running,false) end)
            pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp,false) end)
        end
        local ohrp=model:FindFirstChild("HumanoidRootPart"); if not ohrp then model:Destroy(); setStatus(T.HRPMissing); return false end
        ohrp.Anchored=true
        local myChar=LocalPlayer.Character; if not myChar then model:Destroy(); setStatus(T.CharNotReady); return false end
        local myHRP=myChar:FindFirstChild("HumanoidRootPart"); if not myHRP then model:Destroy(); setStatus(T.LocalHRPMissing); return false end
        model:PivotTo(myHRP.CFrame)
        AV.model=model; AV.hrp=ohrp; AV.weld=nil; AV.lastUserId=userId; AV.lastUsername=username
        av_buildMotors(myChar,model)
        AV.renderConn=RunService.RenderStepped:Connect(function()
            if not AV.model or not AV.hrp then return end
            local f=av_getFolder(); if f and AV.model.Parent~=f then AV.model.Parent=f end
            local mHRP=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if mHRP then AV.hrp.CFrame=mHRP.CFrame end
            for _,pair in ipairs(AV.motorPairs) do local s,t=pair.src,pair.tgt
                if s and t and s.Parent and t.Parent then t.Transform=s.Transform end end
        end)
        av_setHide(true)
        pcall(function() local char=LocalPlayer.Character; local hum=char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None; hum.NameDisplayDistance=0
                hum.HealthDisplayType=Enum.HumanoidHealthDisplayType.AlwaysOff; hum.HealthDisplayDistance=0 end end)
        setStatus((T.OverlayActive.."%s (%d)"):format(username,userId)); return true
    end
    LocalPlayer.CharacterAdded:Connect(function() task.wait(0.3)
        if AV.hideSelf then av_setHide(true) end
        if AV.lastUserId then av_spawn(AV.lastUserId,AV.lastUsername or tostring(AV.lastUserId),function() end) end
    end)
    local _avStatus = T.SelectForAvatar
    local avStatusLabel = nil
    local PAv=TabP:AddSection(T.SecCopyAvatar,true)
    avStatusLabel = PAv:AddParagraph({Title=T.StatusLabel, Content=_avStatus})
    local function avSetStatus(msg)
        _avStatus=msg
        pcall(function() if avStatusLabel and avStatusLabel.SetContent then avStatusLabel:SetContent(msg) end end)
        Notify(msg,3,Color3.fromRGB(200,220,255))
    end
    local function avPlayerOpts()
        local o={}; for _,p in pairs(Players:GetPlayers()) do if p~=LocalPlayer then table.insert(o,p.Name) end end
        if #o==0 then table.insert(o,T.NoPlayers) end; return o
    end
    local avDd=PAv:AddDropdown({Title=T.PlayerOnServer,Multi=false,Options=avPlayerOpts(),Default=avPlayerOpts()[1],
        Callback=function(v) if v==T.NoPlayers then return end
            local p=Players:FindFirstChild(v); if p then AV.selectedUserId=p.UserId; AV.selectedUsername=p.Name
                avSetStatus(T.Selected..p.Name.." (ID: "..p.UserId..")") end end})
    Players.PlayerAdded:Connect(function()   pcall(function() avDd:SetOptions(avPlayerOpts()) end) end)
    Players.PlayerRemoving:Connect(function(p) if AV.selectedUsername==p.Name then AV.selectedUserId=nil; AV.selectedUsername=nil end
        pcall(function() avDd:SetOptions(avPlayerOpts()) end) end)
    local _avInput=""
    PAv:AddInput({Title=T.SearchNameOrID, Content=T.SearchExample, Default="",
        Callback=function(v) _avInput=v or "" end})
    PAv:AddButton({Title=T.SearchPlayer, SubTitle=T.CopySelectedAv,
        Callback=function()
            if _avInput=="" then avSetStatus(T.EnterNameOrID); return end
            task.spawn(function()
                avSetStatus(T.Searching)
                local ok,uid,uname=av_resolveTarget(_avInput)
                if ok then AV.selectedUserId=uid; AV.selectedUsername=uname; avSetStatus(T.Found..uname.." (ID: "..uid..")")
                else avSetStatus("Erro: "..tostring(uid)) end
            end)
        end,
        SubCallback=function()
            if not AV.selectedUserId then avSetStatus(T.SelectTarget); return end
            task.spawn(function() av_spawn(AV.selectedUserId,AV.selectedUsername or tostring(AV.selectedUserId),avSetStatus) end)
        end})
    PAv:AddButton({Title=T.RemoveOverlay, SubTitle=T.ReloadLast,
        Callback=function() av_destroy(); avSetStatus(T.OverlayRemoved) end,
        SubCallback=function()
            if not AV.lastUserId then avSetStatus(T.NoPrevAvatar); return end
            task.spawn(function() av_spawn(AV.lastUserId,AV.lastUsername or tostring(AV.lastUserId),avSetStatus) end)
        end})
    local P4=TabP:AddSection(T.SecBypass,true)
    P4:AddToggle({Title="Anti-Kick",Default=false,
        Callback=function(v)
            if not v then return end
            pcall(function()
                local mt = getrawmetatable(game)
                if mt and setreadonly then
                    setreadonly(mt, false)
                    local oldNC = mt.__namecall
                    mt.__namecall = newcclosure(function(self, ...)
                        local method = getnamecallmethod()
                        if tostring(method):lower() == "kick" and self == LocalPlayer then
                            return nil
                        end
                        return oldNC(self, ...)
                    end)
                    setreadonly(mt, true)
                end
            end)
        end})
    P4:AddToggle({Title="Anti-Ban",Default=false,
        Callback=function(v) end})
    P4:AddToggle({Title="Anti-AFK",Default=true,
        Callback=function(v) getgenv().AntiAFK=v
            if v then LocalPlayer.Idled:Connect(function() if not getgenv().AntiAFK then return end
                local VU=game:GetService("VirtualUser")
                VU:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame); task.wait(1); VU:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame) end) end
        end})
end
local TabF=Window:AddTab({Name=T.TabFling,Icon="zap",Description=T.TabFlingDesc})
do
    local FLSel     = nil
    local FL_TpOn   = false
    local FL_AuraOn = false
    local FL_InstOn = false
    local FL_WalkOn = false
    local FL_TpConn = nil
    local FL_ViewC  = nil
    local ARG_on=false; local ARG_char=nil; local ARG_hum=nil
    local function ARG_update()
        task.spawn(function()
            ARG_char=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            ARG_hum=ARG_char:WaitForChild("Humanoid")
        end)
    end
    if LocalPlayer.Character then ARG_update() end
    LocalPlayer.CharacterAdded:Connect(function() task.wait(0.2); ARG_update() end)
    RunService.Heartbeat:Connect(function()
        if not ARG_on or not ARG_char or not ARG_hum then return end
        local root=ARG_char:FindFirstChild("HumanoidRootPart"); if not root then return end
        local hasC=false
        for _,x in ipairs(ARG_char:GetDescendants()) do if x:IsA("BallSocketConstraint") or x:IsA("HingeConstraint") then hasC=true; break end end
        if hasC then ARG_hum.PlatformStand=true; root.Anchored=true
            task.delay(0.5,function() if ARG_hum then ARG_hum.PlatformStand=false end; if root then root.Anchored=false end end) end
    end)
    local function fHRP() local c=LocalPlayer.Character; return c and c:FindFirstChild("HumanoidRootPart") end
    local function nexorFling(targetHRP)
        local c=LocalPlayer.Character; if not c then return end
        local hrp=c:FindFirstChild("HumanoidRootPart"); if not hrp or not targetHRP then return end
        local origCF=hrp.CFrame
        local vel=hrp.Velocity; local movel=0.1
        hrp.CFrame=targetHRP.CFrame
        hrp.Velocity=vel*100000000+Vector3.new(0,10000,0)
        RunService.RenderStepped:Wait()
        hrp.Velocity=vel
        RunService.Stepped:Wait()
        hrp.Velocity=vel+Vector3.new(0,movel,0)
        task.delay(1,function()
            local hrp2=fHRP(); if hrp2 then hrp2.CFrame=origCF end
        end)
    end
    local function enableAura()
        local Char2,HRP2,OrigCF2,DidBack2=nil,nil,nil,false
        task.spawn(function()
            while FL_AuraOn do
                Char2=LocalPlayer.Character; HRP2=Char2 and Char2:FindFirstChild("HumanoidRootPart")
                if HRP2 and OrigCF2 and not DidBack2 and HRP2.Velocity.Magnitude>1 then
                    HRP2.CFrame=OrigCF2; DidBack2=true
                end
                task.wait(0.1)
            end
        end)
        task.spawn(function()
            while FL_AuraOn do
                RunService.Heartbeat:Wait()
                Char2=LocalPlayer.Character; HRP2=Char2 and Char2:FindFirstChild("HumanoidRootPart")
                if HRP2 then
                    local best,bd=nil,getgenv().NexorRange or 1000000
                    for _,p in pairs(Players:GetPlayers()) do if p~=LocalPlayer and p.Character then
                        local tr=p.Character:FindFirstChild("HumanoidRootPart")
                        if tr then local d=(HRP2.Position-tr.Position).Magnitude; if d<bd then bd=d;best=tr end end
                    end end
                    if best then
                        OrigCF2=HRP2.CFrame; DidBack2=false; HRP2.CFrame=best.CFrame
                        local ov=HRP2.Velocity; HRP2.Velocity=ov*10000+Vector3.new(0,10000,0)
                        RunService.RenderStepped:Wait(); HRP2.Velocity=ov
                        RunService.Stepped:Wait(); HRP2.Velocity=ov+Vector3.new(0,1,0)
                        task.delay(0.5,function() if FL_AuraOn and OrigCF2 and not DidBack2 then HRP2.CFrame=OrigCF2 end end)
                    end
                end
            end
        end)
    end
    local function enableWalk()
        task.spawn(function()
            local movel=0.1
            while FL_WalkOn do
                RunService.Heartbeat:Wait()
                local c=LocalPlayer.Character; local r=c and c:FindFirstChild("HumanoidRootPart")
                if r then local vel=r.Velocity; r.Velocity=vel*100000+Vector3.new(0,10000,0)
                    RunService.RenderStepped:Wait(); r.Velocity=vel
                    RunService.Stepped:Wait(); r.Velocity=vel+Vector3.new(0,movel,0); movel=-movel end
            end
        end)
    end
    local function enableInst()
        task.spawn(function()
            local movel=0.1
            while FL_InstOn do
                RunService.Heartbeat:Wait()
                local c=LocalPlayer.Character; local hrp=c and c:FindFirstChild("HumanoidRootPart")
                if hrp then local vel=hrp.Velocity; hrp.Velocity=vel*100000000+Vector3.new(0,10000,0)
                    RunService.RenderStepped:Wait(); hrp.Velocity=vel
                    RunService.Stepped:Wait(); hrp.Velocity=vel+Vector3.new(0,movel,0); movel=-movel end
            end
        end)
    end
    local function fStopAll()
        FL_TpOn=false; FL_AuraOn=false; FL_InstOn=false; FL_WalkOn=false
        if FL_TpConn then FL_TpConn:Disconnect(); FL_TpConn=nil end
        if FL_ViewC  then FL_ViewC:Disconnect();  FL_ViewC=nil end
        workspace.CurrentCamera.CameraSubject=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        Notify(T.AllFlingsStopped,2,Color3.fromRGB(200,255,200))
    end
    local function names()
        local n={}; for _,p in pairs(Players:GetPlayers()) do if p~=LocalPlayer then table.insert(n,p.Name) end end
        if #n==0 then table.insert(n,T.NoPlayers) end; return n
    end
    local F1=TabF:AddSection(T.SecFlingVars,true)
    local fDd=F1:AddDropdown({Title=T.TargetPlayer,Multi=false,Options=names(),Default=names()[1],
        Callback=function(v) FLSel=Players:FindFirstChild(v) end})
    FLSel=Players:FindFirstChild(names()[1])
    Players.PlayerAdded:Connect(function()    pcall(function() fDd:SetOptions(names()) end) end)
    Players.PlayerRemoving:Connect(function(p) if FLSel==p then FLSel=nil end; pcall(function() fDd:SetOptions(names()) end) end)
    F1:AddToggle({Title=T.FlingTarget,Default=false,
        Callback=function(v)
            FL_TpOn=v
            if v then
                if not FLSel or not FLSel.Parent then Notify(T.SelectPlayer,3,Color3.fromRGB(255,200,200)); FL_TpOn=false; return end
                local hrp0=fHRP(); local origCF0=hrp0 and hrp0.CFrame
                FL_TpConn=RunService.Heartbeat:Connect(function()
                    if not FL_TpOn then return end
                    local tC=FLSel and FLSel.Character; if not tC then return end
                    local tHRP=tC:FindFirstChild("HumanoidRootPart"); if not tHRP then return end
                    nexorFling(tHRP)
                end)
                task.delay(3, function()
                    FL_TpOn=false
                    if FL_TpConn then FL_TpConn:Disconnect(); FL_TpConn=nil end
                    local hrp2=fHRP()
                    if hrp2 and origCF0 then hrp2.CFrame=origCF0 end
                end)
            else
                if FL_TpConn then FL_TpConn:Disconnect(); FL_TpConn=nil end
            end
        end})
F1:AddToggle({Title=T.SpectateTarget,Default=false,
        Callback=function(v)
            if not v then if FL_ViewC then FL_ViewC:Disconnect();FL_ViewC=nil end
                workspace.CurrentCamera.CameraSubject=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            else local t=FLSel; if not t or not t.Parent then return end
                FL_ViewC=RunService.RenderStepped:Connect(function()
                    if t.Character and t.Character:FindFirstChild("Humanoid") then workspace.CurrentCamera.CameraSubject=t.Character.Humanoid end
                end) end end})
    getgenv().NexorRange=1000000
    F1:AddToggle({Title=T.FlingAura,Default=false,
        Callback=function(v) FL_AuraOn=v; if v then enableAura() end end})
    local FL_AllOn=false; local FL_AllConn=nil
    F1:AddToggle({Title=T.FlingAll,Default=false,
        Callback=function(v)
            FL_AllOn=v
            if v then
                task.spawn(function()
                    while FL_AllOn do
                        for _,p in pairs(Players:GetPlayers()) do
                            if not FL_AllOn then break end
                            if p~=LocalPlayer and p.Character then
                                local tHRP=p.Character:FindFirstChild("HumanoidRootPart")
                                if tHRP then
                                    local conn; conn=RunService.Heartbeat:Connect(function()
                                        if not FL_AllOn then conn:Disconnect(); return end
                                        local c=p.Character; local hr=c and c:FindFirstChild("HumanoidRootPart")
                                        if hr then nexorFling(hr) end
                                    end)
                                    task.wait(3)
                                    conn:Disconnect()
                                end
                            end
                            if not FL_AllOn then break end
                        end
                    end
                end)
            else
                FL_AllOn=false
            end
        end})
    F1:AddToggle({Title=T.FlingWalking,Default=false,
        Callback=function(v) FL_WalkOn=v; if v then enableWalk() end end})
    F1:AddToggle({Title=T.AntiRagdoll,Default=false,Callback=function(v) ARG_on=v end})
    F1:AddSlider({Title=T.AuraRange,Min=10,Max=500,Default=200,Increment=10,
        Callback=function(v) getgenv().NexorRange=v end})
    F1:AddButton({Title=T.StopAll,Callback=fStopAll})
    local F2=TabF:AddSection(T.SecTeleport,true)
    F2:AddButton({Title=T.CopyCoords,
        Callback=function() local r=fHRP(); if not r then return end; local p=r.CFrame.Position
            pcall(setclipboard,("hrp.CFrame=CFrame.new(%g,%g,%g)"):format(p.X,p.Y,p.Z))
            Notify(T.Copied,2,Color3.fromRGB(200,255,200)) end})
    local svFL=nil
    F2:AddButton({Title=T.SaveLocation,Callback=function() local r=fHRP(); if r then svFL=r.CFrame; Notify(T.Saved,2,Color3.fromRGB(200,255,200)) end end})
    F2:AddButton({Title=T.GoToSaved,
        Callback=function() if not svFL then Notify(T.NoLocationSaved,3,Color3.fromRGB(255,200,200)); return end
            local r=fHRP(); if r then r.CFrame=svFL end end})
end
local TabS=Window:AddTab({Name=T.TabServer,Icon="earth",Description=T.TabServerDesc})
do
    local pid=game.PlaceId; local inputJobId=""
    local function getSrvs(cur)
        local url=_EP.RGS..pid.."/servers/Public?sortOrder=Desc&limit=100"
        if cur then url=url.."&cursor="..cur end
        local ok,body=pcall(game.HttpGet,game,url,true); if not ok or not body then return nil end
        local ok2,d=pcall(function() return HttpService:JSONDecode(body) end)
        if ok2 and d and d.data then return d end; return nil
    end
    local T1=TabS:AddSection(T.SecServers,true)
    T1:AddButton({Title=T.CopyServerID,
        Callback=function() local j=game.JobId; if j~="" then pcall(setclipboard,j); Notify(T.IDCopied,2,Color3.fromRGB(200,255,200)) end end})
    T1:AddInput({
        Title   = T.ServerJobID,
        Content = T.PasteJobID,
        Default = "",
        Callback= function(v) inputJobId = v or "" end,
    })
    T1:AddButton({Title=T.JoinByJobID,
        Callback=function()
            if not inputJobId or inputJobId=="" then Notify(T.EnterJobID,3,Color3.fromRGB(255,200,200)); return end
            pcall(function() TeleportService:TeleportToPlaceInstance(pid,inputJobId,LocalPlayer) end)
        end})
    T1:AddButton({Title=T.RejoinServer,
        Callback=function() pcall(function() TeleportService:TeleportToPlaceInstance(pid,game.JobId,LocalPlayer) end) end})
    T1:AddButton({Title=T.RandomHop,
        Callback=function() task.spawn(function()
            local list={}; local cur=nil
            repeat local d=getSrvs(cur); if d then for _,sv in ipairs(d.data) do if sv.playing<sv.maxPlayers and sv.id~=game.JobId then table.insert(list,sv.id) end end; cur=d.nextPageCursor else cur=nil end
            until not cur
            if #list>0 then pcall(function() TeleportService:TeleportToPlaceInstance(pid,list[math.random(1,#list)],LocalPlayer) end)
            else Notify(T.NoServerAvail,4,Color3.fromRGB(255,200,200)) end
        end) end})
end
-- =========================================
-- TAB: Orion AI (Chat de IA Integrado)
-- =========================================
do
    local TabAI = Window:AddTab({Name=T.TabAI or "Orion AI", Icon="bot", Description=T.TabAIDesc})
    local conversationHistory = {}
    -- Parser Robusto de Resposta da IA: Separa o texto da explicacao de todos os blocos de codigo e parametros
    local function parseAIContent(text)
        if not text or text == "" then return "", nil end
        local codeBlocks = {}
        local remainingText = ""
        local lastPos = 1
        while true do
            local sStart, sEnd = text:find("```", lastPos, true)
            if not sStart then
                remainingText = remainingText .. text:sub(lastPos)
                break
            end
            remainingText = remainingText .. text:sub(lastPos, sStart - 1)
            -- Pula possivel especificador de linguagem como ```lua
            local nextNL = text:find("\n", sStart, true)
            local codeStart = (nextNL and nextNL < sStart + 15) and (nextNL + 1) or (sStart + 3)
            local cStart, cEnd = text:find("```", codeStart, true)
            if not cStart then
                local codeSnippet = text:sub(codeStart)
                codeSnippet = codeSnippet:gsub("^%s+", ""):gsub("%s+$", "")
                if codeSnippet ~= "" then
                    table.insert(codeBlocks, codeSnippet)
                end
                break
            else
                local codeSnippet = text:sub(codeStart, cStart - 1)
                codeSnippet = codeSnippet:gsub("^%s+", ""):gsub("%s+$", "")
                if codeSnippet ~= "" then
                    table.insert(codeBlocks, codeSnippet)
                end
                lastPos = cEnd + 1
            end
        end
        local finalCode = nil
        if #codeBlocks > 0 then
            finalCode = table.concat(codeBlocks, "\n\n")
        elseif (text:find("game:") or text:find("GetService") or text:find("Players%.LocalPlayer")) and not text:find("\n%s*\n") then
            finalCode = text:gsub("^%s+", ""):gsub("%s+$", "")
            remainingText = _isPTBR and "Script Luau:" or "Luau Script:"
        end
        remainingText = remainingText:gsub("```", "")
        remainingText = remainingText:gsub("^%s+", ""):gsub("%s+$", "")
        if remainingText == "" and finalCode then
            remainingText = _isPTBR and "Aqui esta o seu script Luau:" or "Here is your Luau script:"
        end
        return remainingText, finalCode
    end
    local function requestAI(promptText)
        local reqFn = (syn and syn.request) or (http and http.request) or http_request or request
        if not reqFn then return nil, _isPTBR and "Seu executor nao suporta requisicoes HTTP (request)." or "Your executor does not support HTTP requests." end
        table.insert(conversationHistory, {role = "user", content = promptText})
        while #conversationHistory > 12 do table.remove(conversationHistory, 1) end
        -- Mesmo prompt base da Orion AI da extensao + regras Luau
        local sysPrompt = (_isPTBR
            and "Voce e a Orion AI, a assistente do painel Orion Studios. Responda no mesmo idioma do usuario (padrao: portugues do Brasil), de forma clara e direta. Voce e especialista senior em Luau e scripts para Roblox, mas ajuda com qualquer assunto. Converse de forma natural e descontraida, como um amigo; em conversa casual responda em 1 a 4 frases. Primeira linha ja e a resposta, sem introducao. REGRAS PARA SCRIPTS LUAU: gere codigo Luau correto e funcional para executores Roblox; use game:GetService; use task.wait/task.spawn/task.delay (nunca wait/spawn); proteja o personagem com CharacterAdded; declare os parametros editaveis no topo do script; entregue TODO o codigo em UM unico bloco ```lua ... ``` e fora dele apenas uma explicacao curta."
            or "You are Orion AI, the assistant of the Orion Studios panel. Reply in the user's language, clearly and directly. You are a senior Luau and Roblox scripting expert but help with anything. Talk naturally and casually like a friend; for casual chat answer in 1 to 4 sentences. The first line is already the answer, no intro. LUAU RULES: write correct, working Luau for Roblox executors; use game:GetService; use task.wait/task.spawn/task.delay (never wait/spawn); guard the character with CharacterAdded; declare editable settings at the top; deliver ALL code in ONE ```lua ... ``` block with only a short explanation outside it.")
        local function okStatus(r) return r and (r.StatusCode == 200 or r.Status == 200) and type(r.Body) == "string" and r.Body ~= "" end
        local function done(text)
            table.insert(conversationHistory, {role = "assistant", content = text})
            return text, nil
        end
        local function fromChoices(body)
            local dOk, d = pcall(function() return HttpService:JSONDecode(body) end)
            local c = dOk and type(d) == "table" and d.choices and d.choices[1] and d.choices[1].message and d.choices[1].message.content
            if type(c) == "string" and c:match("%S") then return c end
            return nil
        end
        local errs = {}
        -- 1) duck.ai (claude-haiku-4-5, SSE) - igual a extensao
        do
            local ok, text = pcall(function()
                local vqd
                pcall(function()
                    local sRes = reqFn({Url = _EP.DS, Method = "GET", Headers = {["x-vqd-accept"] = "1", ["accept"] = "*/*"}})
                    if sRes and sRes.Headers then
                        for k, v in pairs(sRes.Headers) do
                            local lk = tostring(k):lower()
                            if lk == "x-vqd-4" or (lk == "x-vqd-hash-1" and not vqd) then vqd = v end
                        end
                    end
                end)
                local msgs = {}
                for i, m in ipairs(conversationHistory) do
                    if m.role == "user" then
                        table.insert(msgs, {role = "user", content = {{type = "text", text = (i == 1 and (sysPrompt .. "\n\n") or "") .. m.content}}})
                    else
                        table.insert(msgs, {role = "assistant", content = m.content})
                    end
                end
                local headers = {["Content-Type"] = "application/json", ["accept"] = "text/event-stream"}
                if vqd then headers["x-vqd-4"] = vqd; headers["x-vqd-hash-1"] = vqd end
                local r = reqFn({Url = _EP.DC, Method = "POST", Headers = headers,
                    Body = HttpService:JSONEncode({model = "claude-haiku-4-5", metadata = {}, messages = msgs})})
                if not okStatus(r) then error("duck " .. tostring(r and (r.StatusCode or r.Status))) end
                local full = ""
                for line in r.Body:gmatch("[^\r\n]+") do
                    local j = line:match("^data:%s*(.*)$")
                    if j and j ~= "" and j ~= "[DONE]" then
                        local okD, d = pcall(function() return HttpService:JSONDecode(j) end)
                        if okD and type(d) == "table" then
                            local piece = d.message or d.content
                            if type(piece) == "string" then full = full .. piece end
                        end
                    end
                end
                if full == "" then error("duck vazio") end
                return full
            end)
            if ok and text then return done(text) end
            table.insert(errs, tostring(text))
        end
        -- 2) vireonix (OpenAI-compativel) - igual a extensao
        do
            local ok, text = pcall(function()
                local msgs = {{role = "system", content = sysPrompt}}
                for _, m in ipairs(conversationHistory) do table.insert(msgs, {role = m.role, content = m.content}) end
                local r = reqFn({Url = _EP.VC, Method = "POST", Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode({model = "auto", messages = msgs})})
                if not okStatus(r) then error("vireonix " .. tostring(r and (r.StatusCode or r.Status))) end
                local c = fromChoices(r.Body)
                if not c then error("vireonix vazio") end
                return c
            end)
            if ok and text then return done(text) end
            table.insert(errs, tostring(text))
        end
        -- 3) pollinations (OpenAI-compativel, sem chave) - igual a extensao
        do
            local ok, text = pcall(function()
                local msgs = {{role = "system", content = sysPrompt}}
                for _, m in ipairs(conversationHistory) do table.insert(msgs, {role = m.role, content = m.content}) end
                local r = reqFn({Url = "https://text.pollinations.ai/openai", Method = "POST", Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode({model = "openai", messages = msgs})})
                if not okStatus(r) then error("pollinations " .. tostring(r and (r.StatusCode or r.Status))) end
                local c = fromChoices(r.Body)
                if not c then error("pollinations vazio") end
                return c
            end)
            if ok and text then return done(text) end
            table.insert(errs, tostring(text))
        end
        -- falhou tudo: remove a pergunta do historico e devolve o motivo
        table.remove(conversationHistory)
        return nil, (_isPTBR and "Nenhuma IA respondeu. " or "No AI responded. ") .. table.concat(errs, " | ")
    end
    local SecChat = TabAI:AddSection(T.SecAIChat or "Chat com Orion AI", true)
    -- Verifica suporte ao novo componente AddChat na WinUI
    if SecChat.AddChat then
        local ChatUI = nil
        local _savedFileExists = false
        if type(isfile) == "function" then
            pcall(function()
                _savedFileExists = isfile(_G.__OrionPath("Chat","History.json","OrionHub_AI_Chat.json"))
            end)
        end
        local ToggleSave = SecChat:AddToggle({
            Title = T.ToggleAISaveHistory or (_isPTBR and "Salvar Historico de conversa" or "Save chat history"),
            SubTitle = T.ToggleAISaveHistorySub or (_isPTBR and "Salva as mensagens no executor" or "Saves messages in executor"),
            Content = T.ToggleAISaveHistorySub or (_isPTBR and "Salva as mensagens no executor" or "Saves messages in executor"),
            Default = _savedFileExists,
            Callback = function(val)
                if ChatUI and ChatUI.SetSaveHistory then
                    ChatUI:SetSaveHistory(val)
                end
            end
        })
        SecChat:AddButton({
            Title = T.BtnAIClearChat or (_isPTBR and "Limpar Conversa" or "Clear Chat"),
            SubTitle = T.BtnAIClearChatSub or (_isPTBR and "Limpar tudo" or "Clear all"),
            Icon = "trash",
            Callback = function()
                conversationHistory = {}
                if ChatUI and ChatUI.Clear then
                    ChatUI:Clear()
                end
                Notify(_isPTBR and "Historico da Orion AI limpo!" or "Orion AI chat history cleared!", 3, Color3.fromRGB(100, 220, 140))
            end
        })
        ChatUI = SecChat:AddChat({
            Title = "Orion AI",
            SubTitle = _isPTBR and "Assistente Inteligente & Gerador de Scripts" or "Intelligent Assistant & Script Generator",
            Placeholder = T.InputAIPlaceholder or (_isPTBR and "Digite sua mensagem..." or "Type your message..."),
            SendText = T.SendChatText or (_isPTBR and "Enviar" or "Send"),
            Height = 360,
            WelcomeMessage = _isPTBR and "Ola! Sou a Orion AI integrada ao Orion Hub. Pergunte o que quiser ou peca para eu gerar scripts Luau para voce!" or "Hello! I am Orion AI integrated into Orion Hub. Ask anything or ask me to generate Luau scripts for you!",
            SaveHistory = _savedFileExists or (ToggleSave and ToggleSave.Value == true),
            OnExecute = function(code)
                if not code or code == "" then
                    Notify(T.AINoCodeFound or (_isPTBR and "Nenhum codigo Lua encontrado para executar." or "No Lua code found to execute."), 3, Color3.fromRGB(255, 180, 100))
                    return
                end
                local fn, compileErr = loadstring(code)
                if not fn then
                    Notify((_isPTBR and "Erro de sintaxe no codigo: " or "Syntax error in code: ") .. tostring(compileErr), 5, Color3.fromRGB(255, 120, 120))
                    return
                end
                task.spawn(function()
                    local runOk, runErr = pcall(fn)
                    if runOk then
                        Notify(T.AICodeExecuted or (_isPTBR and "Codigo da IA executado com sucesso!" or "AI code executed successfully!"), 3, Color3.fromRGB(120, 255, 150))
                    else
                        Notify((_isPTBR and "Erro na execucao: " or "Execution error: ") .. tostring(runErr), 5, Color3.fromRGB(255, 150, 150))
                    end
                end)
            end,
            OnSend = function(userPrompt, chatCtrl)
                Notify(_isPTBR and "Consultando Orion AI..." or "Querying Orion AI...", 3, Color3.fromRGB(180, 200, 255))
                local answer, err = requestAI(userPrompt)
                if answer and answer ~= "" then
                    local cleanText, extractedCode = parseAIContent(answer)
                    chatCtrl:AddAIMessage(cleanText, extractedCode)
                    Notify(_isPTBR and "Resposta da Orion AI recebida!" or "Orion AI response received!", 3, Color3.fromRGB(150, 255, 180))
                else
                    chatCtrl:AddAIMessage((_isPTBR and "❌ Falha ao obter resposta da Orion AI:\n" or "❌ Failed to get response from Orion AI:\n") .. tostring(err or "Unknown error"), nil)
                    Notify(T.AIError or (_isPTBR and "Falha ao consultar Orion AI." or "Failed to query Orion AI."), 4, Color3.fromRGB(255, 140, 140))
                end
            end
        })
        if (_savedFileExists or (ToggleSave and ToggleSave.Value == true)) and ChatUI and ChatUI.SetSaveHistory then
            ChatUI:SetSaveHistory(true)
        end
    else
        -- Fallback seguro para versões anteriores da biblioteca
        local _aiPrompt = ""
        local _lastAIResponse = ""
        local _lastAICode = ""
        local _isAILoading = false
        SecChat:AddInput({
            Title = T.InputAIPrompt or "Prompt / Mensagem",
            Content = T.InputAIPlaceholder or "Ex: Crie um script de velocidade...",
            Default = "",
            Callback = function(v) _aiPrompt = v or "" end
        })
        local RespPara = SecChat:AddParagraph({
            Title = "Orion AI",
            Content = T.StatusReady or "Aguardando envio de mensagem...",
            Icon = "bot"
        })
        SecChat:AddButton({
            Title = T.BtnAISend or "Enviar Mensagem",
            SubTitle = T.BtnAISub or "Consultar IA para gerar resposta ou script",
            Callback = function()
                if _isAILoading then
                    Notify(T.AIAlreadyLoading or "Aguarde a resposta atual...", 3, Color3.fromRGB(255, 200, 100))
                    return
                end
                if not _aiPrompt or _aiPrompt:match("^%s*$") then
                    Notify(T.AIEmptyPrompt or "Digite uma mensagem antes de enviar.", 3, Color3.fromRGB(255, 120, 120))
                    return
                end
                _isAILoading = true
                RespPara:SetContent(T.AIWaiting or "Gerando resposta da Orion AI, por favor aguarde...")
                Notify("Consultando Orion AI...", 3, Color3.fromRGB(180, 200, 255))
                task.spawn(function()
                    local answer, err = requestAI(_aiPrompt)
                    _isAILoading = false
                    if answer and answer ~= "" then
                        local cleanText, extractedCode = parseAIContent(answer)
                        _lastAIResponse = cleanText
                        _lastAICode = extractedCode or ""
                        RespPara:SetContent(cleanText)
                        Notify("Resposta da Orion AI recebida!", 3, Color3.fromRGB(150, 255, 180))
                    else
                        RespPara:SetContent("Erro: " .. tostring(err or "Falha desconhecida."))
                        Notify(T.AIError or "Falha ao consultar Orion AI.", 4, Color3.fromRGB(255, 100, 100))
                    end
                end)
            end
        })
        SecChat:AddButton({
            Title = T.BtnAICopyCode or "Copiar Codigo Lua",
            SubTitle = T.BtnAICopyCodeSub or "Copia apenas o codigo Lua para o clipboard",
            Icon = "clipboard-copy",
            Callback = function()
                if not _lastAICode or _lastAICode == "" then
                    Notify(T.AINoCodeFound or "Nenhum codigo Lua encontrado para copiar.", 3, Color3.fromRGB(255, 180, 100))
                    return
                end
                if type(setclipboard) == "function" then
                    setclipboard(_lastAICode)
                    Notify(T.AICodeCopied or "Codigo Lua copiado para a area de transferencia!", 3, Color3.fromRGB(120, 255, 150))
                elseif type(toclipboard) == "function" then
                    toclipboard(_lastAICode)
                    Notify(T.AICodeCopied or "Codigo Lua copiado para a area de transferencia!", 3, Color3.fromRGB(120, 255, 150))
                else
                    Notify("Executor nao suporta setclipboard.", 4, Color3.fromRGB(255, 120, 120))
                end
            end
        })
        SecChat:AddButton({
            Title = T.BtnAIExecCode or "Executar Codigo Gerado",
            SubTitle = T.BtnAIExecCodeSub or "Executa o script Lua diretamente no jogo",
            Icon = "play",
            Callback = function()
                if not _lastAICode or _lastAICode == "" then
                    Notify(T.AINoCodeFound or "Nenhum codigo Lua encontrado para executar.", 3, Color3.fromRGB(255, 180, 100))
                    return
                end
                local fn, compileErr = loadstring(_lastAICode)
                if not fn then
                    Notify("Erro de sintaxe no codigo: " .. tostring(compileErr), 5, Color3.fromRGB(255, 120, 120))
                    return
                end
                task.spawn(function()
                    local runOk, runErr = pcall(fn)
                    if runOk then
                        Notify(T.AICodeExecuted or "Codigo da IA executado com sucesso!", 3, Color3.fromRGB(120, 255, 150))
                    else
                        Notify("Erro na execucao: " .. tostring(runErr), 5, Color3.fromRGB(255, 150, 150))
                    end
                end)
            end
        })
    end
end
-- =========================================
_G.Window            = Window
_G.Notify            = Notify
_G.CFG_THEME         = CFG_THEME
_G.SaveConfig        = SaveConfig or nil
_G.LoadConfigElements = LoadConfigElements or nil
-- =========================================
local URL = _EP.WC
local success, result = pcall(function()
    return game:HttpGet(URL)
end)
if not success or not result or result == "" then
    warn("Erro ao fazer request:", result)
    return
end
local func, err = loadstring(result)
if not func then
    warn("Erro ao compilar o TabConfig:", err)
    return
end
local ok, execErr = pcall(func)
if not ok then
    warn("Erro ao executar o TabConfig:", execErr)
end
-- =========================================
