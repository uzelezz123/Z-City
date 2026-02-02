SWEP.Base = "weapon_akm"
SWEP.Primary.Automatic = false

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.PrintName = "VPO-209"
SWEP.Author = "Vyatskiye Polyany Machine-Building Plant"
SWEP.Instructions = "An AKM version converted for the Russian civilian arms market, without automatic fire capability. Сhambered in .366 TKM."
SWEP.Category = "Weapons - Carbines"
SWEP.ShockMultiplier = 1.5
SWEP.Penetration = 3
SWEP.Primary.Ammo = ".366 TKM"
SWEP.Primary.Force = 30

SWEP.CustomShell = "366tkm"

SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.FakeBodyGroups = "00000000010000"

SWEP.WepSelectIcon2 = Material("pwb/sprites/akm.png")
SWEP.IconOverride = "entities/arc9_eft_vpo209.png"

local mat = "models/weapons/tfa_ins2/ak_pack/ak74n/ak74n_stock"
--function SWEP:ModelCreated(model)
--	local wep = self:GetWeaponEntity()
--	--self:SetSubMaterial(1, mat)
--	--wep:SetSubMaterial(1, mat)
--end
