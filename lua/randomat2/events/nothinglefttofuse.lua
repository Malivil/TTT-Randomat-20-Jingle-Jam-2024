local EVENT = {}

EVENT.Title = "Nothing Left to Fuse"
EVENT.Description = "When a player dies, any grenades they have activate automatically"
EVENT.id = "nothinglefttofuse"
EVENT.Categories = {"deathtrigger", "entityspawn"}

function EVENT:Begin()
    self:AddHook("DoPlayerDeath", function(victim, attacker, dmg)
        if not IsPlayer(victim) then return end

        for _, wep in ipairs(victim:GetWeapons()) do
            if wep.Base ~= "weapon_tttbasegrenade" then continue end
            if not wep.GetGrenadeName then continue end

            local grenadeName = wep:GetGrenadeName()
            local ent = ents.Create(grenadeName)
            if not IsValid(ent) then continue end

            ent:SetPos(victim:GetPos())
            ent:Spawn()
            ent:SetThrower(victim)
            ent:SetDetonateExact(CurTime())

            local phys = ent:GetPhysicsObject()
            if not IsValid(phys) then
                ent:Remove()
            end

            SafeRemoveEntity(wep)
        end
    end)
end

Randomat:register(EVENT)