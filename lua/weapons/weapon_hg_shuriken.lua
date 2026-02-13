if SERVER then AddCSLuaFile() end
SWEP.PrintName = "Shuriken"
SWEP.Category = "ZCity Other"
SWEP.Instructions = "Shuriken, also called throwing stars, or ninja stars, are a Japanese concealed weapon used by samurai or ninja or in martial arts as a hidden dagger to distract or misdirect."
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.HoldType = "grenade"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/jaanus/shuriken_small.mdl"

SWEP.ScrappersSlot = "Other"

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_shuriken")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_shuriken"
	SWEP.BounceWeaponIcon = false
end

SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Slot = 2
SWEP.SlotPos = 1

function SWEP:GetEyeTrace()
	return hg.eyeTrace(self:GetOwner())
end

SWEP.offsetVec = Vector(4,-3,1)
SWEP.offsetAng = Angle(90, 0, 0)
SWEP.ModelScale = 1

function SWEP:DrawWorldModel()
	self.model = IsValid(self.model) and self.model or ClientsideModel(self.WorldModel)
	local WorldModel = self.model
	local owner = self:GetOwner()
	WorldModel:SetNoDraw(true)
	WorldModel:SetModelScale(self.ModelScale)
	if IsValid(owner) then
		local offsetVec = self.offsetVec
		local offsetAng = self.offsetAng
		local boneid = owner:LookupBone(((owner.organism and owner.organism.rarmamputated) or (owner.zmanipstart ~= nil and owner.zmanipseq == "interact" and not owner.organism.larmamputated)) and "ValveBiped.Bip01_L_Hand" or "ValveBiped.Bip01_R_Hand")
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
	if not self:GetNWBool("PlacedLOVUSHKA",false) then
		WorldModel:DrawModel()
	end

	if self.lefthandmodel then
		self.model2 = IsValid(self.model2) and self.model2 or ClientsideModel(self.lefthandmodel)
		local WorldModel = self.model2
		local owner = self:GetOwner()
		WorldModel:SetNoDraw(true)
		WorldModel:SetModelScale(1)
		if IsValid(owner) then
			local offsetVec = self.offsetVec2
			local offsetAng = self.offsetAng2
			local boneid = owner:LookupBone("ValveBiped.Bip01_L_Hand")
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
			WorldModel:DrawModel()
		end
	
		if IsValid(owner.FakeRagdoll) or not IsValid(owner) or (IsValid(owner:GetActiveWeapon()) and owner:GetActiveWeapon() ~= self) then return end
		WorldModel:DrawModel()
	end
end

function SWEP:Initialize()
	self:SetHold(self.HoldType)

	if self:GetOwner():IsNPC() then
		self.HoldType = "melee"
		self:SetHold(self.HoldType)
	end

	hg.weapons2[self] = true
	self.count = 1
end

local bone, name
function SWEP:BoneSet(layerID, lookup_name, vec, ang)
	hg.bone.Set(self:GetOwner(), layerID, lookup_name, vec, ang)
end

function SWEP:BoneGet(lookup_name)
	return hg.bone.Get(self:GetOwner(), lookup_name)
end

function SWEP:Animation()
	self:SetHold(self.HoldType)

	if not (CLIENT and LocalPlayer() == self:GetOwner() and LocalPlayer() == GetViewEntity()) then return end
	if (self:GetOwner().zmanipstart ~= nil and not self:GetOwner().organism.larmamputated) then return end

	self:BoneSet("r_upperarm", Vector(0,0,0), Angle(-90,0,-60))

	if self.startedattack then
		local animpos = math.max((self.startedattack + 0.5) - CurTime(),0) * 2
		
		self:BoneSet("l_upperarm", Vector(0,0,0), Angle(-90 * animpos,-60 * animpos,0))
		self:BoneSet("r_upperarm", Vector(0,0,0), Angle(-20 * animpos,-40 * animpos,0))
	end

	if self.starthold then
		local animpos = math.max((self.starthold + 0.5) - CurTime(),0) * 2

		self:BoneSet("r_finger0", Vector(0,0,0), Angle(70 * animpos,-10 * animpos,0))
		--self:BoneSet("r_hand", Vector(0,0,0), Angle(20 * animpos,0,0))
	end
end

function SWEP:SetHold(value)
	self:SetWeaponHoldType(value)
	self:SetHoldType(value)
	self.holdtype = value
end

local veczero = Vector(0, 0, 0)
function SWEP:PrimaryAttack()
	if CLIENT then return end
	local time = CurTime()
	local ent = ents.Create("ent_throwable")

	local ply = self:GetOwner()
	if not ply:IsNPC() then
		ent:SetPos(select(1, hg.eye(ply,60,hg.GetCurrentCharacter(ply))) - ply:GetAimVector() * 2)
	else
		ent:SetPos(ply:EyePos() + ply:EyeAngles():Forward() * 2)
	end

	ent:SetAngles(ply:EyeAngles())
	ent:Spawn()
	ent.wep = self:GetClass()
	ent.owner = ply
	ent.localshit = veczero
	ent.poisoned2 = self.poisoned2
	
	if self.bombowner then
		ent.bombowner = self.bombowner
		ent.bombowner.HaveTheBomb = ent
	end

	ent.damage = 15
	ent.AttackHitFlesh = "snd_jack_hmcd_knifestab.wav"
	ent.AttackHit = "snd_jack_hmcd_knifehit.wav"
	ent.dont_account_for_placement = true
	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetVelocity(ply:GetAimVector() * ent.MaxSpeed)
		phys:AddAngleVelocity(Vector(0,0, -ent.MaxSpeed) )
	end
	ply:EmitSound("weapons/slam/throw.wav",50,math.random(95,105))

	if not ply:IsNPC() then
		ply:SelectWeapon("weapon_hands_sh")
		self:Remove()
	end
end

function SWEP:SecondaryAttack()
end

function SWEP:CanBePickedUpByNPCs()
	return true -- why not lol
end

function SWEP:GetNPCRestTimes()
	return 0.5, 1
end