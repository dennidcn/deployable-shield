AddCSLuaFile()
AddCSLuaFile('entities/ent_deployed_shield.lua')
include('entities/ent_deployed_shield.lua')


SWEP.PrintName = "Deployable Shield"
SWEP.Author = "Dennid"
SWEP.Instructions = "Hold to block incoming damage. Right-click to deploy."
SWEP.Category = "Dennid Weapons"
SWEP.Spawnable = true
SWEP.AdminOnly = false


SWEP.ViewModel = "models/weapons/arccw_go/v_shield.mdl"
SWEP.WorldModel = "models/weapons/arccw_go/v_shield.mdl"
SWEP.UseHands = true
SWEP.HoldType = "melee"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"


function SWEP:Initialize()
    self:SetHoldType("melee")
end


function SWEP:PrimaryAttack()
    
end

// Deployable shield functionality
function SWEP:SecondaryAttack()
    if SERVER then
        local ply = self:GetOwner()
        if not IsValid(ply) then return end

        
        local eyeAng = ply:EyeAngles()
        local forward = eyeAng:Forward()
        local startPos = ply:GetShootPos() + forward * 40

        local tr = util.TraceLine({
            start = startPos,
            endpos = startPos - Vector(0, 0, 80),
            filter = ply
        })

        
        if tr.Hit then
            local shield = ents.Create("ent_deployed_shield")
            if not IsValid(shield) then return end

            // shield position and direction
            local spawnAng = Angle(0, eyeAng.y, 0)
            shield:SetPos(tr.HitPos + Vector(0, 15, 40))
            shield:SetAngles(spawnAng)
            shield:Spawn()
            shield:Activate()
            shield.Owner = ply

            // removes the shield from players inv
            ply:StripWeapon(self:GetClass())
        end
    end
end

function SWEP:Deploy()
    self:SetHoldType("melee")
    if SERVER then
        self:SetModel(self.WorldModel)
    end
    
    if IsValid(self:GetOwner()) then
        self:GetOwner():SetNWBool("deployableShieldEquipped", true)
    end
end

function SWEP:Holster()
    if IsValid(self:GetOwner()) then
        self:GetOwner():SetNWBool("deployableShieldEquipped", false)
    end
    return true
end

if SERVER then
    // hook for no damage
    hook.Add("EntityTakeDamage", "ShieldImmuneDamage", function(target, dmginfo)
        
        if target:IsPlayer() and target:GetNWBool("deployableShieldEquipped", false) then
            local attacker = dmginfo:GetAttacker()
            if not IsValid(attacker) then return end

            local shield = target:GetActiveWeapon()
            if not IsValid(shield) or shield:GetClass() ~= "weapon_deployableshield" then return end

            
            local targetForward = target:GetForward()
            local attackerPos = attacker:GetPos() + attacker:OBBCenter()
            local targetPos = target:GetPos() + target:OBBCenter()
            local directionToAttacker = (attackerPos - targetPos):GetNormalized()
            local dotProduct = directionToAttacker:Dot(targetForward)

            
            if dotProduct > 0.5 then
                dmginfo:SetDamage(0)
                dmginfo:ScaleDamage(0)
                return true
            end
        end

        // Handle damage to deployed shields
        if target:GetClass() == "ent_deployed_shield" then
            // Trace to check if damage actually hits the shield model
            local tr = util.TraceLine({
                start = dmginfo:GetAttacker():GetPos() + dmginfo:GetAttacker():OBBCenter(),
                endpos = target:GetPos() + target:OBBCenter(),
                filter = {dmginfo:GetAttacker(), target},
                mask = MASK_SHOT
            })

            -- Block damage if trace hits the shield
            if tr.Hit and tr.Entity == target then
                dmginfo:SetDamage(0)
                dmginfo:ScaleDamage(0)
                return true
            end
        end
    end)
end


if CLIENT then
    hook.Add("PrePlayerDraw", "DrawShield", function(ply)
        if ply:GetNWBool("deployableShieldEquipped", false) then
            local wep = ply:GetActiveWeapon()
            if IsValid(wep) and wep:GetClass() == "weapon_deployableshield" then
                -- Create and draw clientside shield model
                local shieldModel = ClientsideModel(wep.WorldModel, RENDERGROUP_OPAQUE)
                shieldModel:SetPos(ply:GetPos() + Vector(0, 0, 35))
                shieldModel:SetAngles(ply:EyeAngles())
                shieldModel:DrawModel()
                shieldModel:Remove()
            end
        end
    end)
end
