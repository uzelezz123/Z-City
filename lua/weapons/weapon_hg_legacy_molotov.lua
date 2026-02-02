if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_hg_legacy_grenade"
SWEP.PrintName = "Molotov Cocktail"
SWEP.Instructions = "A handmade molotov cocktail is an incendiary weapon consisting of a frangible container filled with flammable substances and equipped with a fuse."
SWEP.Category = "Weapons - Explosive"
SWEP.Spawnable = false
SWEP.HoldType = "grenade"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/w_models/weapons/w_eq_molotov.mdl"
if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_molotov")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_molotov.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 4
SWEP.SlotPos = 1
SWEP.ENT = "ent_hg_molotov"

SWEP.nofunnyfunctions = true
SWEP.timetothrow = 0.5

SWEP.lefthandmodel = "models/weapons/gleb/w_firematch.mdl"
SWEP.offsetVec2 = Vector(4,-1.2,1)
SWEP.offsetAng2 = Angle(10,0,90)
SWEP.ModelScale2 = 1.5
SWEP.throwsound = "snd_jack_hmcd_lighter.wav"

SWEP.offsetVec = Vector(3, -2, -1)
SWEP.offsetAng = Angle(145, 0, 0)
SWEP.NoTrap = true