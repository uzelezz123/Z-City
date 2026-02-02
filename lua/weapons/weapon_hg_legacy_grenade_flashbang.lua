if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_hg_legacy_grenade"
SWEP.PrintName = "Flashbang"
SWEP.Instructions = "Flashbang is a non-lethal stun device, used by SWAT."
SWEP.Category = "Weapons - Explosive"
SWEP.Spawnable = false
SWEP.HoldType = "grenade"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/jmod/explosives/grenades/flashbang/flashbang.mdl"
if CLIENT then
    SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_flashbang")
    SWEP.IconOverride = "vgui/wep_jack_hmcd_flashbang"
    SWEP.BounceWeaponIcon = false
end

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 4
SWEP.SlotPos = 1
SWEP.ENT = "ent_hg_grenade_flashbang"

SWEP.offsetVec = Vector(3, -2.5, -1)
SWEP.offsetAng = Angle(160, 0, 0)
SWEP.ModelScale = 0.8
SWEP.spoon = "models/weapons/arc9/darsu_eft/skobas/m18_skoba.mdl"