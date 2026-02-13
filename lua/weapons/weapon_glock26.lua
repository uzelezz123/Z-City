SWEP.Base = "weapon_glock17"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Glock 26"
SWEP.Author = "Glock GmbH"
SWEP.Instructions = "Glock is a brand of polymer-framed, short recoil-operated, striker-fired, locked-breech semi-automatic pistols designed and produced by Austrian manufacturer Glock Ges.m.b.H. Thats version of Glock is subcompact 10 rounds chambered in 9x19 ammo."
SWEP.Category = "Weapons - Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10

SWEP.FakeBodyGroups = "2108"
SWEP.FakeBodyGroupsPresets = {
	"2108",
	"2108",
	"2108",
	"2108",
	"2108",
	"2108",
	"2108",
	"2108",
	"2108",
}

SWEP.AnimList = {
	["idle"] = "idle",
	["reload"] = "reload_10",
	["reload_empty"] = "reload_empty_10",
}

function SWEP:InitializePost()
	local Skin = math.random(0,2)
	if math.random(0,100) > 99 then
		Skin = 3
	end
	self:SetGlockSkin(Skin)
	self:SetRandomBodygroups(self.FakeBodyGroupsPresets[math.random(#self.FakeBodyGroupsPresets)] or "2108")
end

SWEP.ReloadTime = 2.8

SWEP.AttachmentPos = Vector(-0.1,-1.2,-6.5)
SWEP.AttachmentAng = Angle(0,0,0)

SWEP.WepSelectIcon2 = Material("vgui/hud/tfa_ins2_glock_p80.png")
SWEP.IconOverride = "entities/weapon_pwb_glock17.png"

SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 10

SWEP.weight = 0.1
SWEP.lengthSub = 20

SWEP.Ergonomics = 2

function SWEP:PostSetupDataTables()
	self:NetworkVar("Int",0,"GlockSkin")
	if ( CLIENT ) then
		self:NetworkVarNotify( "GlockSkin", self.OnVarChanged )
	end
end

function SWEP:OnVarChanged( name, old, new )
	if !IsValid(self:GetWM()) then return end

	self:GetWM():SetSkin(new)
end

function SWEP:InitializePost()
	local Skin = math.random(0,2)
	if math.random(0,100) > 99 then
		Skin = 3
	end
	self:SetGlockSkin(Skin)
end

function SWEP:ModelCreated(model)
	model:ManipulateBoneScale(46, vector_origin)
	model:SetSkin(self:GetGlockSkin())
end
