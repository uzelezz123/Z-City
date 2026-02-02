if true then return end
if SERVER then AddCSLuaFile() end
SWEP.PrintName = "Ballistic shield"
SWEP.Instructions = "A ballistic shield"
SWEP.Category = "ZCity Other"
SWEP.Instructions = ""
SWEP.Spawnable = false
SWEP.AdminOnly = false
SWEP.Slot = 1

SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
--SWEP.WorldModel = "models/bshields/hshield.mdl"
SWEP.WorldModel = "models/bshields/rshield.mdl"
SWEP.ViewModel = "models/bshields/rshield.mdl"
SWEP.HoldType = "normal"

function SWEP:SetHold(value)
    self:SetWeaponHoldType(value)
	self:SetHoldType(value)
	self.holdtype = value
end

SWEP.offsetVec = Vector(2, -2, 0)
SWEP.offsetAng = Angle(180, 90, 90)
function SWEP:DrawWorldModel()
	self.model = IsValid(self.model) and self.model or ClientsideModel(self.WorldModel)
	self.model:SetNoDraw(true)
	local WorldModel = self.model
	local owner = self:GetOwner()
	if not IsValid(WorldModel) then return end
	
	if IsValid(owner) then
		local offsetVec = self.offsetVec
		local offsetAng = self.offsetAng
		local boneid = owner:LookupBone("ValveBiped.Bip01_Spine")
		if not boneid then return end
		local matrix = owner:GetBoneMatrix(boneid)
		if not matrix then return end
		local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())
		WorldModel:SetPos(newPos)
		WorldModel:SetAngles(newAng)
		WorldModel:SetupBones()
	else
		WorldModel:SetPos(self:GetPos())
		WorldModel:SetAngles(self:GetAngles())
	end

	WorldModel:DrawModel()
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:Think()
    self:SetHold(self.HoldType)
end