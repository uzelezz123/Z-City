if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_hg_legacy_grenade"
SWEP.PrintName = "Empty Mag"
SWEP.Instructions = "A great thing to distract someone with sound."
SWEP.Category = "Weapons - Other"
SWEP.Spawnable = true
SWEP.HoldType = "grenade"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/kali/weapons/black_ops/magazines/30rd galil magazine.mdl"
if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/inventory/magazine_extended_akseries_45rd")
	SWEP.IconOverride = "vgui/inventory/magazine_extended_akseries_45rd"
	SWEP.BounceWeaponIcon = false
end

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 4
SWEP.SlotPos = 1
SWEP.ENT = "ent_hg_emptymag"

SWEP.nofunnyfunctions = true
SWEP.timetothrow = 0.1

SWEP.throwsound = ""

SWEP.offsetVec = Vector(3, -2, -1)
SWEP.offsetAng = Angle(145, 0, 0)
SWEP.NoTrap = true
SWEP.FixedBG = false

function SWEP:Initialize()
	self:SetHold(self.HoldType)
	hg.weapons2[ #hg.weapons2 + 1 ] = self
	self.count = 1

	self:SetBodygroup(1, 1)
	if IsValid(self.model) then
		self.model:SetBodygroup(1, 1)
	end
	self.FixedBG = false
end

function SWEP:Deploy()
	self:SetBodygroup(1, 1)
	if IsValid(self.model) then
		self.model:SetBodygroup(1, 1)
	end
	self.FixedBG = false
end

function SWEP:SetHold(value)
	self:SetWeaponHoldType(value)
	self:SetHoldType(value)
	self.holdtype = value

	if not self.FixedBG then
		self:SetBodygroup(1, 1)
		if IsValid(self.model) then
			self.model:SetBodygroup(1, 1)
		end
		self.FixedBG = true
	end
end

function SWEP:SetFakeGun(ent)
	self:SetNWEntity("fakeGun", ent)
	self.fakeGun = ent
	self.fakeGun:SetBodygroup(1, 1)
end