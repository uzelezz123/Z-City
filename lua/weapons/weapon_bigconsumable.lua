if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_bandage_sh"
SWEP.PrintName = "Big consumable"
SWEP.Instructions = "A snack is always useful, regardless of the situation. Having a snack and waiting and regaining your well-being."
SWEP.Category = "ZCity Other"
SWEP.Spawnable = true
SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0
SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/jordfood/canned_burger.mdl"
if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_fooddrink")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_fooddrink.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.WorkWithFake = true
SWEP.offsetVec = Vector(3.5, -1.8, -2)
SWEP.offsetAng = Angle(180, 0, 0)
SWEP.showstats = false

SWEP.ofsV = Vector(-2,-10,8)
SWEP.ofsA = Angle(90,-90,90)

SWEP.FoodModelsKCNNeutralizers = {
	["models/foodnhouseholditems/juice.mdl"] = 10,
	["models/foodnhouseholditems/cola.mdl"] = 10,
}

SWEP.FoodModels = {
	"models/jordfood/canned_burger.mdl",
	"models/jorddrink/the_bottle_of_water.mdl",
	"models/foodnhouseholditems/milk.mdl",
	"models/jordfood/can.mdl",
	"models/foodnhouseholditems/juice.mdl",
	"models/foodnhouseholditems/cola.mdl",
	"models/foodnhouseholditems/bagette.mdl",
	"models/jordfood/prongleclosedfilledgreen.mdl",
}

SWEP.DoNotDropModels = {
	["models/foodnhouseholditems/bagette.mdl"] = true,
}

SWEP.WaterModel = {
	["models/foodnhouseholditems/juice.mdl"] = true,
	["models/foodnhouseholditems/cola.mdl"] = true,
	["models/foodnhouseholditems/milk.mdl"] = true,
	["models/jorddrink/the_bottle_of_water.mdl"] = true,
}

SWEP.FallSnd = "snd_jack_hmcd_foodbounce.wav"
SWEP.DeploySnd = "snd_jack_hmcd_foodbounce.wav"
SWEP.Eating = 0
SWEP.CDEating = 0

function SWEP:SetupDataTables()
	self:NetworkVar( "String", "CurModel" ) 
	self:NetworkVar( "Float", 0, "Holding" )
end

function SWEP:DrawWorldModel2()
	self.model = IsValid(self.model) and self.model or ClientsideModel( self:GetCurModel() )
	self.model:SetNoDraw(true)
	local WorldModel = self.model
	local owner = self:GetOwner()
	if WorldModel:GetModel() ~= self:GetCurModel() then WorldModel:Remove() return end
	if not IsValid(WorldModel) then return end

	WorldModel:SetModelScale(self.ModelScale or 1)
	
	if IsValid(owner) then
		local ent = hg.GetCurrentCharacter(owner)
		local offsetVec = self.offsetVec
		local offsetAng = self.offsetAng
		local boneid = owner:LookupBone(((owner.organism and owner.organism.rarmamputated) or (owner.zmanipstart ~= nil and owner.zmanipseq == "interact" and not owner.organism.larmamputated)) and "ValveBiped.Bip01_L_Hand" or "ValveBiped.Bip01_R_Hand")
		if not boneid then return end
		local matrix = ent:GetBoneMatrix(boneid)
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

function SWEP:InitializeAdd()
	self:SetHold(self.HoldType)

	local sharedrand = math.Round(util.SharedRandom("rand"..self:EntIndex()..math.floor(CurTime()),1,#self.FoodModels))
	local model = self.FoodModels[sharedrand]
	self:SetModel( model )
	self:SetCurModel( model )
	self.WorldModel = model
	if SERVER then
		timer.Simple(0, function() 
			self:PhysicsInit(SOLID_VPHYSICS)

			if IsValid(self:GetPhysicsObject()) then
				self:GetPhysicsObject():Wake()
			end
		end)
	end
end

function SWEP:SecondaryAttack()
end

local hg_healanims = ConVarExists("hg_healanims") and GetConVar("hg_healanims") or CreateConVar("hg_healanims", 0, FCVAR_SERVER_CAN_EXECUTE + FCVAR_ARCHIVE, "Toggle heal/food animations", 0, 1)

function SWEP:Think()
	if (not self:GetOwner():KeyDown(IN_ATTACK) or self.CDEating > CurTime()) and hg_healanims:GetBool() then
		self:SetHolding(math.max(self:GetHolding() - 10, 0))
	end
end

local lang1, lang2 = Angle(0, -10, 0), Angle(0, 10, 0)
function SWEP:Animation()
	if (self:GetOwner().zmanipstart ~= nil and not self:GetOwner().organism.larmamputated) then return end
	local hold = self:GetHolding()
    self:BoneSet("r_upperarm", vector_origin, Angle(0, -10 - hold, 10))
    self:BoneSet("r_forearm", vector_origin, Angle(-15, -hold, -hold))

    self:BoneSet("l_upperarm", vector_origin, lang1)
    self:BoneSet("l_forearm", vector_origin, lang2)
end

function SWEP:OwnerChanged()
	local owner = self:GetOwner()
	if IsValid(owner) and owner:IsNPC() then
		if not self.DoNotDropModels[self:GetCurModel()] then
			self:SpawnGarbage(self:GetCurModel())
		end
		self:NPCHeal(owner, 0.2, "snd_jack_hmcd_eat"..math.random(4)..".wav")
	end
end

if SERVER then
	local ang_eat = Angle(6, 0, 0)
	function SWEP:Heal(ent, mode)
		if ent:IsNPC() then
			if not self.DoNotDropModels[self:GetCurModel()] then
				self:SpawnGarbage(self:GetCurModel())
			end
			self:NPCHeal(ent, 0.2, "snd_jack_hmcd_eat"..math.random(4)..".wav")
		end

		local org = ent.organism
		if not org then return end

		if self.CDEating > CurTime() then return end

		local owner = self:GetOwner()
		if ent == hg.GetCurrentCharacter(owner) and hg_healanims:GetBool() then
			self:SetHolding(math.min(self:GetHolding() + 10, 100))

			if self:GetHolding() < 100 then
				return
			end
		end

		org.satiety = org.satiety + 25/5
		owner:ViewPunch(ang_eat)
		
		ent:EmitSound( self.WaterModel[self.WorldModel] and "snd_jack_hmcd_drink"..math.random(3)..".wav" or "snd_jack_hmcd_eat"..math.random(4)..".wav", 60, math.random(95, 105))
		self.CDEating = CurTime() + 0.5
		self.Eating = self.Eating + 1

		if self.Eating > 5 then
			owner:SelectWeapon("weapon_hands_sh")
			if not self.DoNotDropModels[self:GetCurModel()] then
				self:SpawnGarbage(self:GetCurModel())
			end
			self:Remove()
		end
		
		return true
	end
end