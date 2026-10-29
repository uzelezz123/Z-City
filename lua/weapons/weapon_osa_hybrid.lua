-- Deliberately unspawnable developer weapon. Uses the PB-4 Osa presentation,
-- while combining selected handling traits from several heavy weapons.
SWEP.Base = "weapon_osapb"
SWEP.PrintName = "PB-4 'Chimera'"
SWEP.Category = "ZCity - Developer"
SWEP.Spawnable = false
SWEP.AdminOnly = true

-- Osa / King Cobra: compact four-shot revolver-like package.
SWEP.Primary.ClipSize = 4
SWEP.Primary.DefaultClip = 4
SWEP.Primary.Automatic = false
-- AK-74: practical cadence and controllable handling.
SWEP.Primary.Wait = 0.085
SWEP.Ergonomics = 0.72
-- Kord / Combine sniper: power, impulse and penetration.
SWEP.Primary.Ammo = "12.7x108 mm"
SWEP.Primary.Damage = 150
SWEP.Primary.Force = 80
SWEP.Penetration = 60
SWEP.PenetrationMultiplier = 4
-- KS-23: brutal close-range shock and recoil.
SWEP.ShockMultiplier = 4
SWEP.punchmul = 4.5
SWEP.addSprayMul = 2.5
SWEP.ReloadTime = 7
SWEP.Primary.Cone = 0
SWEP.Primary.Sound = {"weapons/darsu_eft/ks23/ks23_fire_outdoor_close.ogg", 90, 88, 96}
SWEP.Instructions = "Unspawnable prototype combining the PB-4 Osa frame with AK-74 cadence, Kord power, revolver handling, KS-23 shock and Combine sniper penetration. Developer use only."
