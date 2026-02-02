if SERVER then
	AddCSLuaFile()
elseif CLIENT then
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
	SWEP.Slot = 4
	SWEP.SlotPos = 2
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_breachcharge")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_breachcharge"
	SWEP.BounceWeaponIcon = false
end

SWEP.ViewModel = ""
SWEP.WorldModel = "models/props_combine/combine_mine01.mdl"

SWEP.PrintName = "Breach Charge"
SWEP.Instructions = "This is an explosive device used to force open closed and/or locked doors.\n\nLeft click to place on a door."
SWEP.Category = "Weapons - Explosive"
SWEP.Spawnable = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.Offset = {
	Pos = Vector(2, 7.5, 0),
	Ang = Angle(60, -40, 90),
	Size = 0.42
}

function SWEP:SetupDataTables()
	self:NetworkVar("Float",0,"Holding")
end

local bone, name
function SWEP:BoneSet(lookup_name, vec, ang)
	if IsValid(self:GetOwner()) and !self:GetOwner():IsPlayer() then return end
	hg.bone.Set(self:GetOwner(), lookup_name, vec, ang)
end

function SWEP:Animation()
	local hold = self:GetHolding()
	self:BoneSet("r_upperarm", vector_origin, Angle(hold/6,-hold/1.2,0))
	self:BoneSet("r_forearm", vector_origin, Angle(0,hold/2,0))
	self.Offset.Ang[3] = 90 + hold / 100 * -110
	self.Offset.Ang[1] = 60 + hold / 100 * 75
	self.Offset.Pos[1] = 2 + hold / 100 * 4
end

function SWEP:Initialize()
	self:SetHoldType("slam")
	self.Thrown = false
end

function SWEP:Think()
	if not self:GetOwner():KeyDown(IN_ATTACK) then
		self:SetHolding(math.max(self:GetHolding() - 3, 0))
	end
end

local function InPlacementRadius(ply, tr)
	return tr.HitPos:DistToSqr(ply:GetPos()) <= 65 * 65
end

local allowed = {
	"func_door_rotating",
	"prop_door_rotating",
	"func_door",
	"func_physbox",
	"prop_physics"
}

function SWEP:PrimaryAttack()
	local owner = self:GetOwner()
	local Tr = util.QuickTrace(owner:GetShootPos(), owner:GetAimVector() * 65, {owner})
	if not IsValid(Tr.Entity) or not InPlacementRadius(owner, Tr) then return end
	if not table.HasValue(allowed, Tr.Entity:GetClass()) then return end

	self:SetHolding(math.min(self:GetHolding() + 4, 100))

	if self:GetHolding() < 100 then return end
	if CLIENT then return end
		
	self:SetCharge(Tr)
end

function SWEP:Deploy()
	self:SetNextPrimaryFire(CurTime() + 1)
	self:SetNextSecondaryFire(CurTime() + 1)

	return true
end

function SWEP:SetCharge(Tr)
	if CLIENT then return end
	local owner = self:GetOwner()
	if IsValid(Tr.Entity) then
		local charge = ents.Create("ent_hg_breachcharge")
		local ang = Tr.HitNormal:Angle()
		ang:RotateAroundAxis(ang:Forward(), 90)
		ang:RotateAroundAxis(ang:Right(), -90)
		charge:SetAngles(ang)
		charge:SetPos(Tr.HitPos + Tr.HitNormal * -1)
		charge:SetParent(Tr.Entity)
		charge:SetOwner(self:GetOwner())
		charge.Rigged = true
		charge:Spawn()
		charge:Activate()

		timer.Simple(.2, function()
			if IsValid(self) then
				self:Remove()
			end
		end)
	end
end

function SWEP:SecondaryAttack()
	return false
end

function SWEP:Reload()
	return false
end

function SWEP:FireAnimationEvent(pos, ang, event, name)
	return true
end

if CLIENT then
	local csent = ClientsideModel(SWEP.WorldModel)
	csent:SetNoDraw(true)
	
	function SWEP:DrawHUD()
		if not IsValid(csent) then
            csent = ClientsideModel(self.WorldModel)
            csent:SetNoDraw(true)
        end

		local ply = self:GetOwner()
		local tr = ply:GetEyeTrace()

		if not tr.Hit or tr.HitSky or not InPlacementRadius(ply, tr) then return end
		if not IsValid(tr.Entity) then return end 
		if tr.Entity and tr.Entity:IsPlayer() then return end
		if not ((tr.Entity:GetClass() == "func_door_rotating") or (tr.Entity:GetClass() == "prop_door_rotating") or (tr.Entity:GetClass() == "func_door") or (tr.Entity:GetClass() == "func_physbox")) then return end
		local pos, ang = tr.HitPos, tr.HitNormal:Angle()
		ang:RotateAroundAxis(ang:Right(), -90)
		ang:RotateAroundAxis(ang:Up(), 180)

		cam.Start3D()
			csent:SetPos(pos)
			csent:SetAngles(ang)
			csent:SetMaterial("models/wireframe")
			csent:SetModelScale(0.42, 0)
			csent:DrawModel()
		cam.End3D()
	end
end

function SWEP:DrawWorldModel()
	local owner = self:GetOwner()
	if IsValid(owner) then
		local boneIndex = owner:LookupBone("ValveBiped.Bip01_R_Hand")
		if boneIndex then
			local pos, ang = owner:GetBonePosition(boneIndex)
			if pos and ang then
				pos = pos + self.Offset.Pos.x * ang:Right() + self.Offset.Pos.y * ang:Forward() + self.Offset.Pos.z * ang:Up()
				ang:RotateAroundAxis(ang:Right(), self.Offset.Ang.p)
				ang:RotateAroundAxis(ang:Up(), self.Offset.Ang.y)
				ang:RotateAroundAxis(ang:Forward(), self.Offset.Ang.r)

				self:SetPos(pos)
				self:SetAngles(ang)
				self:SetupBones()
				self:SetModelScale(self.Offset.Size, 0)
				self:DrawModel()
				return
			end
		end
	end
	self:DrawModel()
end