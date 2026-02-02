if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_hg_legacy_grenade"
SWEP.PrintName = "Stielhandgranate"
SWEP.Instructions = "A working replica of a WWII nazi-germany offensive grenade. It has a pyrotechnic delay of 5-8 seconds"
SWEP.Category = "Weapons - Explosive"
SWEP.Spawnable = false
SWEP.HoldType = "grenade"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/jmod/explosives/grenades/sticknade/stick_grenade.mdl"
if CLIENT then
    SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_smokebomb")
    SWEP.IconOverride = "entities/ent_jack_gmod_ezsticknade.png"
    SWEP.BounceWeaponIcon = false
end

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.ENT = "ent_hg_grenade_shg"

SWEP.nofunnyfunctions = true
SWEP.timetothrow = 0.5
SWEP.throwsound = "weapons/m67/m67_pullpin.wav"
SWEP.offsetVec = Vector(3, -2, -1)
SWEP.offsetAng = Angle(145, 0, 0)

SWEP.spoon = "models/jmod/explosives/grenades/sticknade/stick_grenade_cap.mdl"
SWEP.NoTrap = true