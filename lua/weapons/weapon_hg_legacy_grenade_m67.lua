if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_hg_legacy_grenade"
SWEP.PrintName = "M67"
SWEP.Instructions = "M67 fragmentation grenade is used by many countries around the world since 1968. It has a pyrotechnic delay of 4-5.5 seconds."
SWEP.Category = "Weapons - Explosive"
SWEP.Spawnable = false
SWEP.HoldType = "grenade"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/tfa_ins2/w_m67.mdl"
if CLIENT then
    SWEP.WepSelectIcon = Material("vgui/hud/tfa_ins2_m67")
    SWEP.IconOverride = "vgui/hud/tfa_ins2_m67.png"
    SWEP.BounceWeaponIcon = false
end

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 4
SWEP.SlotPos = 1
SWEP.ENT = "ent_hg_grenade_m67"

SWEP.offsetVec = Vector(3, -2, -1)
SWEP.offsetAng = Angle(145, 0, 0)