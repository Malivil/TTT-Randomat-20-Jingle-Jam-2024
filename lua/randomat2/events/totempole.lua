local math = math

local MathMin = math.min

local EVENT = {}

EVENT.Title = "Totem Pole"
EVENT.Description = "When standing on another player's head you deal increased damage and heal over time"
EVENT.id = "totempole"
EVENT.Categories = {"smallimpact"}

CreateConVar("randomat_totempole_heal", "1", FCVAR_ARCHIVE, "The amount to heal the totem player per second", 1, 10)
CreateConVar("randomat_totempole_damage_mult", "1.5", FCVAR_ARCHIVE, "The multiplier for damage the totem player does (1.5 = 150% damage)", 1, 5)

function EVENT:Begin()
    local heal = GetConVar("randomat_totempole_heal"):GetInt()
    timer.Create("RdmtTotemPoleHealTimer", 1, 0, function()
        for _, ply in ipairs(self:GetAlivePlayers()) do
            if not IsPlayer(ply:GetGroundEntity()) then continue end

            local health = ply:Health()
            local maxHealth = ply:GetMaxHealth()
            if health == maxHealth then continue end

            local newHealth = MathMin(health + heal, maxHealth)
            ply:SetHealth(newHealth)
        end
    end)

    local damage_mult = GetConVar("randomat_totempole_damage_mult"):GetFloat()
    self:AddHook("ScalePlayerDamage", function(ply, hitgroup, dmginfo)
        local att = dmginfo:GetAttacker()
        if not IsPlayer(att) then return end
        if not IsPlayer(att:GetGroundEntity()) then return end

        dmginfo:ScaleDamage(damage_mult)
    end)
end

function EVENT:End()
    timer.Remove("RdmtTotemPoleHealTimer")
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"heal"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 0
            })
        end
    end

    for _, v in ipairs({"damage_mult"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 2
            })
        end
    end
    return sliders
end

Randomat:register(EVENT)