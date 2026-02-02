include("shared.lua")

SWEP.PrintName = "Snowball"
SWEP.Instructions = 
[[
A snowball is a spherical object made from snow, usually created by scooping snow with the hands and pressing the snow together to compact it into a ball.
]]
SWEP.Category = "Weapons - Other"
SWEP.WorldModelReal = "models/mmod/weapons/c_bugbait.mdl"
SWEP.WorldModelExchange = "models/zerochain/props_christmas/snowballswep/zck_w_snowballswep.mdl"
SWEP.basebone = 39
SWEP.weaponPos = Vector(0,-0.5,0)
SWEP.modelscale = 1.1
SWEP.setlh = false
SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_snowball")
SWEP.IconOverride = "vgui/wep_jack_hmcd_snowball"
SWEP.BounceWeaponIcon = false
SWEP.AnimsEvents = {
	["draw"] = {
		[0.1] = function(self)
			self:EmitSound("weapons/m67/handling/m67_armdraw.wav",70)
		end,
	},
	["drawback"] = {
		[0.1] = function(self)
			self:EmitSound("weapons/m67/handling/m67_armdraw.wav",65)
		end,
	}
}