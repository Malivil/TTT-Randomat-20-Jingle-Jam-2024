local EVENT = {}

EVENT.Title = "Farfetched"
EVENT.Description = "The Magneto-stick has unlimited range and can lift much heavier objects than usual"
EVENT.id = "farfetched"
EVENT.Categories = {"fun", "smallimpact"}

CreateConVar("randomat_farfetched_rangemult", 2.5, FCVAR_NONE, "The multiplier to use on the magneto-stick's range", 1, 10)
CreateConVar("randomat_farfetched_forcemult", 2.5, FCVAR_NONE, "The multiplier to use on the magneto-stick's lift force", 1, 10)

local function SetupWeapon(wep, rangemult)
    if not IsValid(wep) then return end
    if wep.OldGetRange then return end

    wep.OldGetRange = wep.GetRange
    wep.GetRange = function(this, target)
        local range = this:OldGetRange(target)
        return range * rangemult
    end
end

local function RevertWeapon(wep)
    if not IsValid(wep) then return end
    if not wep.OldGetRange then return end

    wep.GetRange = wep.OldGetRange
    wep.OldGetRange = nil
end

local forceValue = nil
function EVENT:Begin()
    local rangemult = GetConVar("randomat_farfetched_rangemult"):GetFloat()
    local forcemult = GetConVar("randomat_farfetched_forcemult"):GetFloat()
    if not forceValue then
        local force = GetConVar("ttt_prop_carrying_force")
        forceValue = force:GetFloat()
        force:SetFloat(forceValue * forcemult)
    end

    for _, ply in player.Iterator() do
        local wep = ply:GetWeapon("weapon_zm_carry")
        SetupWeapon(wep, rangemult)
    end

    self:AddHook("WeaponEquip", function(wep, owner)
        if not IsValid(wep) then return end

        local class = WEPS.GetClass(wep)
        if class ~= "weapon_zm_carry" then return end

        SetupWeapon(wep, rangemult)
    end)
end

function EVENT:End()
    if not forceValue then return end

    GetConVar("ttt_prop_carrying_force"):SetFloat(forceValue)
    forceValue = nil

    for _, ply in player.Iterator() do
        local wep = ply:GetWeapon("weapon_zm_carry")
        RevertWeapon(wep)
    end
end

function EVENT:Condition()
    return ConVarExists("ttt_prop_carrying_force")
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"rangemult", "forcemult"}) do
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