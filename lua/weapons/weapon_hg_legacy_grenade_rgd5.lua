if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_hg_legacy_grenade"
SWEP.PrintName = "RGD-5"
SWEP.Instructions = "RGD-5 is an iconic post-WWII soviet anti-personnel grenade designed in the early 1950s. It's widely exported and used even to this day. It has a pyrotechnic delay of 3.2-4.2 seconds"
SWEP.Category = "Weapons - Explosive"
SWEP.Spawnable = false
SWEP.HoldType = "grenade"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/pwb/weapons/w_rgd5.mdl"
if CLIENT then
    SWEP.WepSelectIcon = Material("vgui/hud/tfa_nam_rgd5")
    SWEP.IconOverride = "vgui/hud/tfa_nam_rgd5"
    SWEP.BounceWeaponIcon = false
end

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 4
SWEP.SlotPos = 10
SWEP.ENT = "ent_hg_grenade_rgd5"