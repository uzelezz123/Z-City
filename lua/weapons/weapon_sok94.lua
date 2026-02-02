SWEP.Base = "weapon_akm"
SWEP.Primary.Automatic = false

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.PrintName = "Vepr SOK-94-03"
SWEP.Author = "Vyatskiye Polyany Machine-Building Plant"
SWEP.Instructions = "SOK-94 carbine is based on a manual Kalashnikov machine gun and is designed for commercial and amateur hunting of average and large animals. Сhambered in .366 TKM."
SWEP.Category = "Weapons - Carbines"
SWEP.ShockMultiplier = 1.5
SWEP.Ergonomics = 0.85
SWEP.Penetration = 3
SWEP.Primary.Force = 30

SWEP.CustomShell = "366tkm"

SWEP.MagModel = "models/weapons/arc9/darsu_eft/mods/mag_ak_custom_sawed_off_762x39_10.mdl"

SWEP.AnimList = {
	["idle"] = "idle",
	["reload"] = "reload_308",
	["reload_empty"] = "reload_308_empty",
}

SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.FakeBodyGroups = "09600074240000"
SWEP.Primary.Wait = 0.098

SWEP.ZoomPos = Vector(0, -0.0054, 4.6688)

SWEP.AnimList = {
	["idle"] = "idle",
	["reload"] = "reload_308",
	["reload_empty"] = "reload_308_empty",
}

SWEP.WepSelectIcon2 = Material("pwb/sprites/akm.png")
SWEP.IconOverride = "entities/rpk.png" --"entities/tfa_ins2_akm_r.png"

SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 10
SWEP.Primary.Ammo = ".366 TKM"