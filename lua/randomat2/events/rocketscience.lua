local EVENT = {}

EVENT.Title = "Rocket Science"
EVENT.Description = "Everyone gets a Rocket Launcher with boosted Rocket Jump capabilities"
EVENT.id = "rocketscience"
EVENT.Type = EVENT_TYPE_WEAPON_OVERRIDE
EVENT.Categories = {"fun", "moderateimpact", "item", "rolechange"}

CreateConVar("randomat_rocketscience_damage", 50, FCVAR_NONE, "The amount of damage the rocket launcher should do to other players", 1, 150)
CreateConVar("randomat_rocketscience_selfdamage", 15, FCVAR_NONE, "The amount of damage the rocket launcher should do to the owner", 0, 100)
CreateConVar("randomat_rocketscience_forceboost", 250, FCVAR_NONE, "The amount of extra upwards force to apply when a player gets hit by explosion damage", 0, 1000)

function EVENT:HandleRoleWeapons(ply)
    local updated = false
    local changing_teams = Randomat:IsMonsterTeam(ply) or Randomat:IsIndependentTeam(ply)
    -- Convert all bad guys to traitors so we don't have to worry about fighting with special weapon replacement logic
    if (Randomat:IsTraitorTeam(ply) and ply:GetRole() ~= ROLE_TRAITOR) or changing_teams then
        Randomat:SetRole(ply, ROLE_TRAITOR)
        updated = true
    elseif Randomat:IsJesterTeam(ply) then
        Randomat:SetRole(ply, ROLE_INNOCENT)
        updated = true
    end

    -- Remove role weapons from anyone whose role was changed
    if updated then
        self:StripRoleWeapons(ply)
    end
    return updated, changing_teams
end

function EVENT:Begin()
    local new_traitors = {}
    for _, ply in ipairs(self:GetAlivePlayers()) do
        local _, new_traitor = self:HandleRoleWeapons(ply)
        Randomat:RemovePhdFlopper(ply)

        if new_traitor then
            table.insert(new_traitors, ply)
        end

        -- Strip all non-default, non-role weapons
        for _, wep in ipairs(ply:GetWeapons()) do
            if wep.Category == WEAPON_CATEGORY_ROLE then continue end

            local weaponclass = WEPS.GetClass(wep)
            if weaponclass == "weapon_zm_improvised" then continue end
            if weaponclass == "weapon_zm_carry" then continue end
            if weaponclass == "weapon_ttt_unarmed" then continue end

            ply:StripWeapon(weaponclass)
        end

        ply:Give("weapon_ttt_rdmtrocketsciencelauncher")
    end
    SendFullStateUpdate()

    self:NotifyTeamChange(new_traitors, ROLE_TEAM_TRAITOR)

    -- No other weapons
    self:AddHook("PlayerCanPickupWeapon", function(ply, wep)
        if wep.Category == WEAPON_CATEGORY_ROLE then return end

        local weaponclass = WEPS.GetClass(wep)
        if weaponclass == "weapon_zm_improvised" then return end
        if weaponclass == "weapon_zm_carry" then return end
        if weaponclass == "weapon_ttt_unarmed" then return end
        if weaponclass == "weapon_ttt_rdmtrocketsciencelauncher" then return end
        return false
    end)

    -- Give any player who spawns the rocket launcher too
    self:AddHook("PlayerSpawn", function(ply)
        -- "PlayerSpawn" also gets called when a player is moved to AFK
        if not IsPlayer(ply) or not ply:Alive() or ply:IsSpec() then return end
        ply:Give("weapon_ttt_rdmtrocketsciencelauncher")
    end)

    local damage = GetConVar("randomat_rocketscience_damage"):GetInt()
    local selfdamage = GetConVar("randomat_rocketscience_selfdamage"):GetInt()
    local forceboost = GetConVar("randomat_rocketscience_forceboost"):GetInt()
    self:AddHook("EntityTakeDamage", function(ent, dmginfo)
        if not IsPlayer(ent) then return end

        -- Disable fall damage
        if dmginfo:IsFallDamage() then
            return true
        end

        local infl = dmginfo:GetInflictor()
        if not IsValid(infl) then return end

        local att = dmginfo:GetAttacker()
        if not IsValid(att) then return end

        if infl:GetClass() == "rpg_missile" and IsValid(infl.Launcher) and WEPS.GetClass(infl.Launcher) == "weapon_ttt_rdmtrocketsciencelauncher" then
            -- Scale this by the maximum possible damage that can be done to account for damage falloff over distance
            -- The rocket is set to 100, but for some reason it does double that maximum
            local scaledDamage = dmginfo:GetDamage() / 200
            -- Take the damage ratio and apply the maximum configured damage to it to calculate
            -- the final adjusted damage
            if ent == att then
                scaledDamage = scaledDamage * selfdamage
            else
                scaledDamage = scaledDamage * damage
            end
            dmginfo:SetDamage(scaledDamage)

            -- Boost the upwards force of the hit player if its enabled and they are moving
            if forceboost == 0 then return end

            local vel = ent:GetVelocity()
            if vel.z == 0 then return end

            ent:SetVelocity(vel + Vector(0, 0, forceboost))
        end
    end)

    self:AddHook("TTTCanOrderEquipment", function(ply, id, is_item)
        if not IsValid(ply) then return end
        if id == "hoff_perk_phd" or (is_item and is_item == EQUIP_PHD) then
            ply:ChatPrint("PHD Floppers are disabled while '" .. Randomat:GetEventTitle(EVENT) .. "' is active!\nYour purchase has been refunded.")
            return false
        end
    end)
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"damage", "selfdamage", "forceboost"}) do
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
    return sliders
end

Randomat:register(EVENT)