if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Small Consumable"
SWEP.Instructions = "A snack is always useful, regardless of the situation. Having a snack and waiting and regaining your well-being."
SWEP.Category = "ZCity Anims items"
SWEP.Spawnable = false
SWEP.AdminOnly = false
SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0
SWEP.HoldType = "normal"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/jordfood/canned_burger.mdl"
SWEP.WorldModelReal = "models/weapons/sweps/stalker2/bread/v_item_bread.mdl"
SWEP.WorldModelExchange = "models/jordfood/canned_burger.mdl"
SWEP.weaponPos = Vector(0,0,0)
SWEP.weaponAng = Angle(180,90,90)
SWEP.modelscale = 0.9
SWEP.modelscale2 = 1

SWEP.basebone = 56
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

SWEP.FoodModelsKCNNeutralizers = {
	["models/jorddrink/7upcan01a.mdl"] = 10,
	["models/jorddrink/barqcan1a.mdl"] = 10,
	["models/jorddrink/cozcan01a.mdl"] = 10,
	["models/jorddrink/crucan01a.mdl"] = 10,
	["models/jorddrink/dewcan01a.mdl"] = 10,
	["models/jorddrink/foscan01a.mdl"] = 10,
	["models/jorddrink/heican01a.mdl"] = 10,
	["models/jorddrink/mongcan1a.mdl"] = 10,
	["models/jorddrink/pepcan01a.mdl"] = 10,
	["models/jorddrink/redcan01a.mdl"] = 10,
	["models/jorddrink/sprcan01a.mdl"] = 10,
	["models/foodnhouseholditems/juicesmall.mdl"] = 10,
}

SWEP.FoodModels = {
	"models/jorddrink/7upcan01a.mdl", 
	"models/jorddrink/barqcan1a.mdl",
	"models/jorddrink/cozcan01a.mdl",
	"models/jorddrink/crucan01a.mdl",
	"models/jorddrink/dewcan01a.mdl",
	"models/jorddrink/foscan01a.mdl",
	"models/jorddrink/heican01a.mdl",
	"models/jorddrink/mongcan1a.mdl",
	"models/jorddrink/pepcan01a.mdl",
	"models/jorddrink/redcan01a.mdl",
	"models/jorddrink/sprcan01a.mdl",
	"models/jordfood/atun.mdl",
	"models/foodnhouseholditems/chipsfritos.mdl",
	"models/foodnhouseholditems/chipslays3.mdl",
	"models/foodnhouseholditems/chipslays5.mdl",
	"models/foodnhouseholditems/juicesmall.mdl",
	"models/foodnhouseholditems/mcdburgerbox.mdl"
}

SWEP.WaterModel = {
	["models/jorddrink/7upcan01a.mdl"] = true, 
	["models/jorddrink/barqcan1a.mdl"] = true,
	["models/jorddrink/cozcan01a.mdl"] = true,
	["models/jorddrink/crucan01a.mdl"] = true,
	["models/jorddrink/dewcan01a.mdl"] = true,
	["models/jorddrink/foscan01a.mdl"] = true,
	["models/jorddrink/heican01a.mdl"] = true,
	["models/jorddrink/mongcan1a.mdl"] = true,
	["models/jorddrink/pepcan01a.mdl"] = true,
	["models/jorddrink/redcan01a.mdl"] = true,
	["models/jorddrink/sprcan01a.mdl"] = true,
	["models/foodnhouseholditems/juicesmall.mdl"] = true
}

SWEP.FallSnd = "snd_jack_hmcd_foodbounce.wav"
SWEP.DeploySnd = "snd_jack_hmcd_foodbounce.wav"

function SWEP:SetupDataTables()
	self:NetworkVar( "String", "CurModel" ) 
	self:NetworkVar( "Float", 0, "Holding" )
end

function SWEP:InitAdd()
	self:SetHold(self.HoldType)
	local sharedrand = math.Round(util.SharedRandom("rand"..self:EntIndex()..math.floor(CurTime()),1,#self.FoodModels))
	local model = self.FoodModels[sharedrand]
	self:SetModel( model )
	self:SetCurModel( model )
	self.WorldModel = model
	self.WorldModelExchange = model

	if SERVER then
		self:PhysicsInit(SOLID_VPHYSICS)
		if IsValid(self:GetPhysicsObject()) then
			self:GetPhysicsObject():Wake()
		end
	end
end

SWEP.HoldClampMax = 50
SWEP.HoldClampMin = -50

SWEP.setlh = true
SWEP.setrh = false
SWEP.HoldAng = Angle(0,0,0)
SWEP.AnimList = {
    -- self:PlayAnim( anim,time,cycling,callback,reverse,sendtoclient )
	["deploy"] = { "idle", 1, false },
    ["attack"] = { "use", 5, false, false, function(self)
		if CLIENT then return end
		self:Heal(self:GetOwner())
	end },
	["idle"] = {"idle", 5, true}
}

SWEP.HoldPos = Vector(1,0,2)
SWEP.HoldAng = Angle(0,0,0)

SWEP.CallbackTimeAdjust = 1.8

SWEP.showstats = false

if SERVER then
	function SWEP:PrimaryAttack()
		self:SetNextPrimaryFire(CurTime() + 5)
		self:PlayAnim("attack")
	end

	function SWEP:Heal(ent, mode)
		local org = ent.organism
		if not org then return end
		if ent ~= self:GetOwner() and not ent.organism.otrub then return end
		local owner = self:GetOwner()
		local entOwner = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or owner
		ent:EmitSound( self.WaterModel[self.WorldModel] and "snd_jack_hmcd_drink"..math.random(3)..".wav" or "snd_jack_hmcd_eat"..math.random(4)..".wav", 60, math.random(95, 105))
		org.satiety = org.satiety + 10/5
		owner:SelectWeapon("weapon_hands_sh")
		self:Remove()

		return true
	end
end