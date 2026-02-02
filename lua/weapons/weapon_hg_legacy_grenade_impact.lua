if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_hg_legacy_grenade"
SWEP.PrintName = "Impact Grenade"
SWEP.Instructions = "Explodes on impact."
SWEP.Category = "Weapons - Explosive"
SWEP.Spawnable = false
SWEP.HoldType = "grenade"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/tfa_ins2/w_m67.mdl"
if CLIENT then
    SWEP.WepSelectIcon = Material("vgui/inventory/weapon_stingball")
    SWEP.IconOverride = "vgui/inventory/weapon_stingball"
    SWEP.BounceWeaponIcon = false
end

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 4
SWEP.SlotPos = 1
SWEP.ENT = "ent_hg_grenade_impact"

SWEP.offsetVec = Vector(3, -2, -1)
SWEP.offsetAng = Angle(145, 0, 0)