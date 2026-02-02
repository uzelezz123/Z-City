include("shared.lua")

SWEP.PrintName = "'Bugbait' Pheropod"
SWEP.Instructions = 
[[
Pheropods are naturally found inside the bodies of Antlion Guards, allowing them to exert control over lesser Antlions. They can be extracted and used by an individual to command Antlions in a similar fashion.
]]
SWEP.Category = "Weapons - Other"
SWEP.WorldModelReal = "models/mmod/weapons/c_bugbait.mdl"
SWEP.WorldModelExchange = false
SWEP.setlh = false
SWEP.WepSelectIcon = Material("entities/zcity/bugbait.png")
SWEP.IconOverride = "entities/zcity/bugbait.png"
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

function SWEP:Reload()
	local time = CurTime()
	if self.SqueezeCD > time then return end

	self:PlayAnim("special", 0.6)
	self:EmitSound("weapons/mmod/bugbait/bugbait_squeeze1.wav",75)
	self.SqueezeCD = time + 2
end