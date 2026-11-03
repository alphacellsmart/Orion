--// ========================================
-- Auth: bloqueia execucao direta sem passar pelo loader
--// ========================================

if not _G.__OrionHub_Auth then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/alphacellsmart/Orion/main/loader.lua"))(...)
    return
end

--// ========================================
