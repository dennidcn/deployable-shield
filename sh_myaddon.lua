MYADDON_NAME = "Dennid's Addon"

weapons.Register({
    ClassName = "weapon_deployableshield",
    PrintName = "Deployable Shield",
    Category = "Dennid Weapons",
    Spawnable = true,
    AdminOnly = false
}, "weapon_deployableshield")

if SERVER then
    print("[Deployable Shield] Server-side addon loaded")
elseif CLIENT then
    print("[Deployable Shield] Client-side addon loaded")
end