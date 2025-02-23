AddCSLuaFile()

if CLIENT then
    SWEP.PrintName = "Rocked Launcher"
    SWEP.Slot = 9
end

SWEP.Base = "weapon_tttbase"
SWEP.Category = WEAPON_CATEGORY_ROLE
SWEP.HoldType = "rpg"
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Weight = 5

SWEP.Primary.Ammo = "rpg_round"
SWEP.Primary.Delay = 1
SWEP.Primary.Recoil = 50
SWEP.Primary.Damage = 0
SWEP.Primary.Automatic = true
SWEP.Primary.ClipSize = 1
SWEP.Primary.ClipMax = -1
SWEP.Primary.DefaultClip = 1

SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 55
SWEP.ViewModel = Model("models/weapons/v_rpg.mdl")
SWEP.WorldModel = Model("models/weapons/w_rocket_launcher.mdl")

SWEP.Kind = WEAPON_NADE + WEAPON_HEAVY + WEAPON_EQUIP1 + WEAPON_EQUIP2
SWEP.AutoSpawnable = false
SWEP.AmmoEnt = "none"
SWEP.AllowDrop = false
SWEP.IsSilent = false
SWEP.NoSights = true

local ShootSound = Sound("weapons/grenade_launcher1.wav")

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
end

function SWEP:PrimaryAttack()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:EmitSound(ShootSound)

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    if SERVER then
        -- Spawn a missile and give it forward velocity like it was just shot out of the gun
        local missile = ents.Create("rpg_missile")
        -- Set a fixed damage because the explosion radius is hardcoded to 2xDamage
        -- The actual damage will be handled in a hook in the event code
        missile:SetSaveValue("m_flDamage", 100)
        missile.Launcher = self
        missile:SetOwner(owner)
        missile:AddEffects(EF_NOSHADOW)

		local ang = owner:EyeAngles()
        missile:SetPos(owner:GetShootPos() + ang:Forward() * 50 + ang:Right() * 1 - ang:Up() * 1)
        missile:SetAngles(ang)
        missile:Spawn()
        missile:Activate()
        -- Activate immediately, removing the delay before it ignites
        missile:NextThink(CurTime())
    end

    if owner:IsNPC() or (not owner.ViewPunch) then return end
    owner:ViewPunch(Angle(util.SharedRandom(self:GetClass(), -0.2, -0.1, 0) * self.Primary.Recoil, util.SharedRandom(self:GetClass(),  -0.1, 0.1, 1) * self.Primary.Recoil, 0))
end

function SWEP:SecondaryAttack()
	-- Do nothing
end

function SWEP:OnDrop()
    self:Remove()
end