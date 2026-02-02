if SERVER then AddCSLuaFile() end

SWEP.PrintName = "Door Wedge"
SWEP.Category = "ZCity Other"
SWEP.Instructions = "This is a heavy-duty commercial door wedge. It can be kicked into place to stop a door from moving.\n\nLeft click to jam a door.\nPress E to pick up wedge again."
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.HoldType = "slam"
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 4
SWEP.SlotPos = 4
SWEP.ModelScale = 0.4

SWEP.WorldModel = "models/props_junk/wood_pallet001a_chunka1.mdl"
SWEP.ViewModel = ""

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_jam")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_jam"
	SWEP.BounceWeaponIcon = false
end

SWEP.offsetVec = Vector(4, -1.6, -3)
SWEP.offsetAng = Angle(0, -90, 130)

local doors = {
	["prop_door"] = true,
	["prop_door_rotating"] = true,
	["func_door"] = true,
	["func_door_rotating"] = true,
	["func_breakable"] = true,
}

local JamPlacementRadius = 100
function SWEP:DrawWorldModel()
	self.model = IsValid(self.model) and self.model or ClientsideModel(self.WorldModel)
	local WorldModel = self.model
	local owner = self:GetOwner()

	if not IsValid(WorldModel) then return end

	WorldModel:SetNoDraw(true)
	WorldModel:SetModelScale(self.ModelScale or 0.4)
	WorldModel:SetModel(self:GetModel())
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

	WorldModel:DrawModel()
end

function SWEP:PlaceSLAM(pos, ang, tr)
	ang:RotateAroundAxis(ang:Right(), -90)
	ang:RotateAroundAxis(ang:Up(), -90)
	ang:RotateAroundAxis(ang:Forward(), 90)

	local Doors = {tr.Entity}

	for _, spent in ipairs(ents.FindInSphere(tr.HitPos, 65)) do
		if (IsValid(spent) and doors[spent:GetClass()]) then
			table.insert(Doors, spent)
		end
	end

	local ent = ents.Create("ent_hg_jam")
	ent:SetAngles(ang)
	ent:SetPos(pos)
	ent:Spawn()
	ent:Activate()
	ent:Block(Doors)

	constraint.Weld(ent, tr.Entity, 0, tr.PhysicsBone or 0, 100, true, false)
	self:SetPlaced(true)
	self:SetSLAM(ent)
	ent.owner = self:GetOwner()

	self:GetOwner():SelectWeapon("weapon_hands_sh")
	self:Remove()
end

function SWEP:Initialize()
	self:SetHoldType("slam")
	self.WorldModel = "models/props_junk/wood_pallet001a_chunka1.mdl"
end

function SWEP:Think()
	self:SetHoldType("slam")
	if not self:GetOwner():KeyDown(IN_ATTACK) then
		self:SetHolding(math.max(self:GetHolding() - 3, 0))
	end
end

local bone, name
function SWEP:BoneSet(lookup_name, vec, ang)
	if IsValid(self:GetOwner()) and !self:GetOwner():IsPlayer() then return end
	hg.bone.Set(self:GetOwner(), lookup_name, vec, ang)
end

function SWEP:Animation()
	if (self:GetOwner().zmanipstart ~= nil and not self:GetOwner().organism.larmamputated) then return end
	local hold = self:GetHolding()
	self:BoneSet("r_upperarm", vector_origin, Angle(20,-hold/2 - 20,0))
	self:BoneSet("r_forearm", vector_origin, Angle(0,hold,0))
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "Placed")
	self:NetworkVar("Float", 0, "Holding")
	self:NetworkVar("Entity", 0, "SLAM")
	self:NetworkVarNotify("Placed", self.OnVarChanged)
end

function SWEP:OnVarChanged(name, old, new)
	if not new then return end
	self.WorldModel = "models/props_junk/wood_pallet001a_chunka1.mdl"
	self.offsetVec = Vector(1.5, -12, -1)
	self.offsetAng = Angle(180, 80, 30)
end

local function InPlacementRadius(ply, tr)
	return tr.HitPos:DistToSqr(ply:GetPos()) <= JamPlacementRadius * JamPlacementRadius
end

if CLIENT then
	local csent = ClientsideModel(SWEP.WorldModel)
	csent:SetNoDraw(true)
	
	function SWEP:DrawHUD()
		if self:GetPlaced() then return end
		if not IsValid(csent) then
			csent = ClientsideModel(self.WorldModel)
			csent:SetNoDraw(true)
		end
		local ply = self:GetOwner()
		local tr = ply:GetEyeTrace()

		if not tr.Hit or tr.HitSky or not tr.HitPos or not InPlacementRadius(ply, tr) then return end
		if tr.Entity and tr.Entity:IsPlayer() or not (IsValid(tr.Entity) and doors[tr.Entity:GetClass()]) then return end

		local pos, ang = tr.HitPos, tr.HitNormal:Angle()
		ang:RotateAroundAxis(ang:Right(), -90)
		ang:RotateAroundAxis(ang:Up(), -90)
		ang:RotateAroundAxis(ang:Forward(), 90)

		cam.Start3D()
			csent:SetPos(pos)
			csent:SetAngles(ang)
			csent:SetMaterial("models/wireframe")
			csent:DrawModel()
			csent:SetModelScale(self.ModelScale or 0.4)
		cam.End3D()
	end
end

function SWEP:PrimaryAttack()
	local ply = self:GetOwner()
	
	if not self:GetPlaced() then
		local tr = ply:GetEyeTrace()
		if not tr.Hit or tr.HitSky or not InPlacementRadius(ply, tr) or not (IsValid(tr.Entity) and doors[tr.Entity:GetClass()]) then return end

		self:SetHolding(math.min(self:GetHolding() + 5, 100))

		if self:GetHolding() < 100 then return end
		if CLIENT then return end
		local pos, ang = tr.HitPos, tr.HitNormal:Angle()
		pos = pos + ang:Forward() * 2
		
		self:PlaceSLAM(pos, ang, tr)
	end
end

function SWEP:SecondaryAttack()
end