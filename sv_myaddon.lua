include("autorun/sh_myaddon.lua")


hook.Add("PlayerSpawn", "ResetShieldState", function(ply)
    ply:SetNWBool("IsUsingShield", false)
    ply:SetNWBool("IsBlocking", false)
end)

