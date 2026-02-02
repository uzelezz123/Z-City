if SERVER then AddCSLuaFile() end
SWEP.PrintName = "Folding box"
SWEP.Instructions = "A handy folding box in which you can hide from enemies"
SWEP.Category = "ZCity Other"
SWEP.Spawnable = true
SWEP.Slot = 1
if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/inventory/perk_quick_reload")
	SWEP.IconOverride = "spawnicons/models/props_junk/wood_crate001a.png"
	SWEP.BounceWeaponIcon = false
end

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
SWEP.WorldModel = "models/props_junk/wood_crate001a.mdl"
SWEP.ViewModel = "models/props_junk/wood_crate001a.mdl"
SWEP.HoldType = "normal"

function SWEP:SetHold(value)
	self:SetWeaponHoldType(value)
	self:SetHoldType(value)
	self.holdtype = value
end

SWEP.offsetVec = Vector(2, 10, 0)
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
		newAng.x = 0
		newAng.z = 0
		if owner:GetVelocity():Length() > 0 or not owner:Crouching() then
			owner:DrawShadow(false)
			WorldModel:SetAngles(newAng)
			WorldModel:SetPos(newPos)
		else
			owner:DrawShadow(true)
		end
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

function SWEP:Holster()
	self:DrawShadow(true)
	if IsValid(self:GetOwner()) then
		self:GetOwner():SetNoDraw(false)
	end
	return true
end

SWEP.Hidden = false
local dmgmdl1, dmgmdl2 = "models/props_junk/wood_crate001a_damaged.mdl", "models/props_junk/wood_crate001a_damagedmax.mdl"
function SWEP:Think() -- вообще вместо манипуляций с ворлдмоделькой я бы мог тут создавать проп и парентить к игроку но эээ
	self:SetHold(self.HoldType)

	local owner = self:GetOwner()
	if not owner:Crouching() then
		self:DrawShadow(true)
		owner:SetNoDraw(false)
		self.Hidden = false
	else
		self:DrawShadow(true)
		owner:DrawShadow(false)
		owner:SetNoDraw(true)
		self.Hidden = true
	end

	local maxhp, hp = owner:GetMaxHealth(), owner:Health()
	if IsValid(self.model) then
		if hp < (maxhp / 2) and hp > (maxhp / 4) and self.model:GetModel() ~= dmgmdl1 then
			self.model:SetModel(dmgmdl1)
		elseif hp < (maxhp / 4) and self.model:GetModel() ~= dmgmdl2 then
			self.model:SetModel(dmgmdl2)
		end
	end
end

if CLIENT then
	local vignetteMat = Material( "effects/shaders/zb_vignette" )
	local lerp = 0
	function SWEP:DrawHUD()
		if GetViewEntity() ~= LocalPlayer() then return end
		if LocalPlayer():InVehicle() then return end

        lerp = Lerp(FrameTime() * 5, lerp, self.Hidden and 8 or 0)
		render.UpdateScreenEffectTexture()

		vignetteMat:SetFloat("$c2_x", CurTime() + 10000)
		vignetteMat:SetFloat("$c0_z", lerp / 3 )
		vignetteMat:SetFloat("$c1_y", lerp / 12 )

		render.SetMaterial(vignetteMat)
		render.DrawScreenQuad()
	end
end