ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Deployed Riot Shield"
ENT.Author = "Dennid"
ENT.Spawnable = false
ENT.AdminSpawnable = false


function ENT:SetupDataTables()
    self:NetworkVar("Float", 0, "ShieldHealth") 
end


if SERVER then
    -- Initialize the deployed shield
    function ENT:Initialize()
        self:SetModel("models/weapons/arccw_go/v_shield.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_NONE)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
        self:SetShieldHealth(100) // health of shield, set low for demonstration can be adjusted

        
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(false) // makes shielf static when deployed
            phys:Wake()
        end

        // stops it clipping into the ground
        self:SetPos(self:GetPos() + Vector(0, 0, 1))
    end

    
    function ENT:OnTakeDamage(dmginfo)
        local newHealth = self:GetShieldHealth() - dmginfo:GetDamage()
        self:SetShieldHealth(newHealth)

        // this is to destroy the shield when health runs hits 0
        if newHealth <= 0 then
            self:SpawnDebris() // spawns the prop debris
            self:Remove() // Removes the shield model
        end
    end

    // function for spawning the prop debris when shield is destroyed
    function ENT:SpawnDebris()
        local debrisModels = {
            "models/props_combine/combine_explosivepanel_shard01a.mdl",
            "models/props_combine/combine_explosivepanel_shard01a.mdl",
            "models/props_combine/combine_explosivepanel_shard01a.mdl",
            "models/props_combine/combine_explosivepanel_shard01a.mdl",
        }

        // Create debris pieces, changes the size of the props to fit the shield etc.
        for _, model in ipairs(debrisModels) do
            local debris = ents.Create("prop_physics")
            if IsValid(debris) then
                debris:SetModel(model)
                debris:SetColor(Color(0, 0, 0))
                debris:SetModelScale(math.random(0.5, 0.8), 0)
                debris:SetPos(self:GetPos() + Vector(math.random(-10, 10), math.random(-10, 10), math.random(0, 10)))
                debris:Spawn()

                
                local phys = debris:GetPhysicsObject()
                if IsValid(phys) then
                    phys:ApplyForceCenter(Vector(math.random(-500, 500), math.random(-500, 500), math.random(200, 500)))
                end
            end
        end
    end

    // allows player to pick the shield back up
    function ENT:Use(activator, caller)
        if IsValid(activator) and activator:IsPlayer() then

            if not activator:HasWeapon("weapon_riotshield") then
                activator:Give("weapon_riotshield")
            end
            
            activator:SelectWeapon("weapon_riotshield")
         
            self:Remove()
        end
    end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end
