local EVENT = {}

EVENT.Title = "Farfetched"
EVENT.Description = "The Magneto-stick has greatly extended range and can lift much heavier objects than usual"
EVENT.id = "farfetched"
EVENT.Categories = {"fun", "smallimpact"}

CreateConVar("randomat_farfetched_rangemult", 25, FCVAR_NONE, "The multiplier to use on the magneto-stick's range", 1, 50)
CreateConVar("randomat_farfetched_weightmult", 10, FCVAR_NONE, "The multiplier to use on the magneto-stick's maximum carry weight", 1, 50)

local function SetupWeapon(wep, rangemult, weightmult)
    if not IsValid(wep) then return end
    if wep.OldGetRange or wep.OldThink then return end

    wep.OldGetRange = wep.GetRange
    wep.GetRange = function(this, target)
        local range = this:OldGetRange(target)
        return range * rangemult
    end

    local ent_diff_time = 0
    local stand_time = 0

    wep.OldThink = wep.OldThink
    wep.Think = function(this)
        this.BaseClass.Think(this)
        if not this:CheckValidity() then return end

        if CurTime() > ent_diff_time then
            if this:GetPos():DistToSqr(this.EntHolding:GetPos()) > 40000 * rangemult * rangemult then
                this:Reset()
                return
            end
            ent_diff_time = CurTime() + 1
        end

        if CurTime() > stand_time then
            for _, p in player.Iterator() do
                if p:IsTerror() and p:GetGroundEntity() == this.EntHolding then
                    this:Reset()
                    return
                end
            end
            stand_time = CurTime() + 0.1
        end

        this.CarryHack:SetPos(this:GetOwner():EyePos() + this:GetOwner():GetAimVector() * 70)
        this.CarryHack:SetAngles(this:GetOwner():GetAngles())
        this.EntHolding:PhysWake()
    end
end

local function RevertWeapon(wep)
    if not IsValid(wep) then return end
    if not wep.OldGetRange or not wep.OldThink then return end

    wep.GetRange = wep.OldGetRange
    wep.OldGetRange = nil

    wep.Think = wep.OldThink
    wep.OldThink = nil
end

local forceValue = nil
function EVENT:Begin()
    local rangemult = GetConVar("randomat_farfetched_rangemult"):GetFloat()
    local weightmult = GetConVar("randomat_farfetched_weightmult"):GetFloat()
    if not forceValue then
        local force = GetConVar("ttt_prop_carrying_force")
        forceValue = force:GetFloat()
        -- Set the Magneto-sticks weld force to unlimited so that held objects don't overshoot and instantly kill them
        force:SetFloat(0)
    end

    for _, ply in player.Iterator() do
        local wep = ply:GetWeapon("weapon_zm_carry")
        SetupWeapon(wep, rangemult, weightmult)
    end

    self:AddHook("WeaponEquip", function(wep, owner)
        if not IsValid(wep) then return end

        local class = WEPS.GetClass(wep)
        if class ~= "weapon_zm_carry" then return end

        SetupWeapon(wep, rangemult, weightmult)
    end)

    CARRY_WEIGHT_LIMIT = CARRY_WEIGHT_LIMIT * weightmult
end

function EVENT:End()
    if not forceValue then return end

    GetConVar("ttt_prop_carrying_force"):SetFloat(forceValue)
    forceValue = nil

    for _, ply in player.Iterator() do
        local wep = ply:GetWeapon("weapon_zm_carry")
        RevertWeapon(wep)
    end

    CARRY_WEIGHT_LIMIT = 45
end

function EVENT:Condition()
    return ConVarExists("ttt_prop_carrying_force")
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"rangemult", "weightmult"}) do
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