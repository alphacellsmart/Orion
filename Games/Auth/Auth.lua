--// ========================================

-- Auth: bloqueia execucao direta sem passar pelo loader

--// ========================================

if not _G.__OrionHub_Auth then
    loadstring(game:HttpGet("https://orion-hub.vercel.app/loader.lua"))(...)
    return
end

--// ========================================
