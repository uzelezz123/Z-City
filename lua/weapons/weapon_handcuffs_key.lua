if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_base"
SWEP.PrintName = "Handcuffs Key"
SWEP.Instructions = "Keys for handcuffs."
SWEP.Category = "ZCity Other"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/eu_homicide/handcuff_keys.mdl"
if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_handcuffskey")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_handcuffskey"
	SWEP.BounceWeaponIcon = false
end

SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Slot = 3
SWEP.SlotPos = 4
SWEP.WorkWithFake = false
SWEP.offsetVec = Vector(2.5, -1.2, -2.6)
SWEP.offsetAng = Angle(-5, 60, -90)
SWEP.ModelScale = 1

if SERVER then
	function SWEP:OnRemove() end
end

function SWEP:DrawWorldModel()
	if not IsValid(self:GetOwner()) then
		self:DrawModel()
	end
end

function SWEP:DrawWorldModel2()
	self.model = IsValid(self.model) and self.model or ClientsideModel(self.WorldModel)
	local WorldModel = self.model
	local owner = self:GetOwner()
	WorldModel:SetNoDraw(true)
	WorldModel:SetModelScale(self.ModelScale or 1)
	if IsValid(owner) then
		local offsetVec = self.offsetVec
		local offsetAng = self.offsetAng
		local boneid = owner:LookupBone(((owner.organism and owner.organism.rarmamputated) or (owner.zmanipstart ~= nil and owner.zmanipseq == "interact" and not owner.organism.larmamputated)) and "ValveBiped.Bip01_L_Hand" or "ValveBiped.Bip01_R_Hand")
		if not boneid then return end
		//self:SetHandPos()
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

function SWEP:SetHold(value)
	self:SetWeaponHoldType(value)
	self:SetHoldType(value)
	self.holdtype = value
end

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "Holding")
end

local bone, name
function SWEP:BoneSet(lookup_name, vec, ang)
	if IsValid(self:GetOwner()) and !self:GetOwner():IsPlayer() then return end
	hg.bone.Set(self:GetOwner(), lookup_name, vec, ang)
end

local lang1, lang2 = Angle(0, -10, 0), Angle(0, 10, 0)
function SWEP:Animation()
	local hold = self:GetHolding()
	self:BoneSet("r_upperarm", vector_origin, Angle(0, -10 - hold / 1.5, 10))
	self:BoneSet("r_forearm", vector_origin, Angle(0, hold / 1, 0))

	self:BoneSet("l_upperarm", vector_origin, lang1)
	self:BoneSet("l_forearm", vector_origin, lang2)
end

function SWEP:Think()
	self:SetHold(self:GetOwner():GetNetVar("handcuffed") and "normal" or self.HoldType)
	if not self:GetOwner():KeyDown(IN_ATTACK) then
		self:SetHolding(math.max(self:GetHolding() - 5,0))
	end
end

function SWEP:SetHandPos()
	if self:GetOwner():GetNetVar("handcuffed") then
		hg.handcuffedhands(self:GetOwner())
	end
end

SWEP.traceLen = 5

function SWEP:GetEyeTrace()
	return hg.eyeTrace(self:GetOwner())
end

if CLIENT then
	function SWEP:DrawHUD()
		if GetViewEntity() ~= LocalPlayer() then return end
		if LocalPlayer():InVehicle() then return end
		local tr = self:GetEyeTrace()
		local toScreen = tr.HitPos:ToScreen()

		surface.SetDrawColor(255,255,255,155)
		surface.DrawRect(toScreen.x-2.5, toScreen.y-2.5, 5, 5)
	end
end

function SWEP:SecondaryAttack()
end

function SWEP:Initialize()
	self:SetHold(self.HoldType)
end

SWEP.CoolDown = 0
function SWEP:UnTie(ent)
	if self.CoolDown > CurTime() then return end
	self.CoolDown = CurTime() + 2
	local owner = self:GetOwner()
	if IsValid(ent) and IsValid(self) and IsValid(owner) and owner:Alive() and owner:GetPos():Distance(ent:GetPos()) < 500 then
		if IsValid(ent) and (ent:IsRagdoll() or ent:IsPlayer()) then
			if not ( ent.handcuffed or ent:GetNetVar("handcuffed",false) ) then return end

			if ent.handcuffs then
				if IsValid(ent.handcuffs[1]) then ent.handcuffs[1]:Remove() end
				if IsValid(ent.handcuffs[2]) then ent.handcuffs[2]:Remove() end
				ent.handcuffed = false
			end

			ent:EmitSound("weapons/357/357_reload1.wav")

			local ply = hg.RagdollOwner(ent)
			local org = ent.organism
			org.handcuffed = false
			ent:SetNetVar("handcuffed",false)
			if ply then ply:SetNetVar("handcuffed",false) end

			owner:Give("weapon_handcuffs")
		end
	end
end

function SWEP:PrimaryAttack()
	if SERVER then
		local ent = self:GetOwner():GetNetVar("handcuffed") and self:GetOwner() or self:GetEyeTrace().Entity
		self:SetHolding(math.min(self:GetHolding() + 5, 100))
		if self:GetHolding() < 100 then return end
		self:UnTie(ent)
	end
end

function SWEP:Reload()
end
