if SERVER then
	AddCSLuaFile()
elseif CLIENT then
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
	SWEP.Slot = 2
	SWEP.SlotPos = 1

	function SWEP:DrawViewModel()
		return false
	end
end

SWEP.PrintName = "Grappling Hook"
SWEP.Instructions = "This is a heavy steel grappling hook with an attached rope. Use it to reach high/far places or safely descend from high places. \n\nLMB to swing/throw\nLMB to pull rope taut\nLMB to pull rope in\nRMB to let rope out\nR to release rope"

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_grapl")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_grapl"
	SWEP.BounceWeaponIcon = false
end

SWEP.ViewModel = "models/weapons/c_models/c_grappling_hook/c_grappling_hook.mdl"
SWEP.WorldModel = "models/weapons/c_models/c_grappling_hook/c_grappling_hook.mdl"

SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false
SWEP.Category = "ZCity Other"
SWEP.Spawnable = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.HomicideSWEP = true
SWEP.JustThrew = false
SWEP.ThrowAbility = 1.5
SWEP.ThrowChargeSpeed = .15
SWEP.NextThinkTime = 0
SWEP.DrawTime = .5
SWEP.DesiredDist = 1000
SWEP.Tight = false
SWEP.NextSpinWhooshTime = 0
SWEP.ENT = "ent_grapplinghook"
SWEP.WorkWithFake = true
SWEP.weight = 5

function SWEP:SetupDataTables()
	self:NetworkVar("String", 0, "CurrentState")
	self:NetworkVar("Float", 0, "Hidden")
	self:NetworkVar("Float", 1, "Back")
	self:NetworkVar("Float", 2, "ThrowPower")
	self:NetworkVar("Float", 3, "Spin")
	self:NetworkVar("Bool", 0, "ShouldHideWorldModel")
end

function SWEP:Initialize()
	self:SetSpin(0)
	self.NextThinkTime = CurTime() + .01
	self:SetHoldType("normal")
	self:SetCurrentState("Hidden")
	self:SetHidden(100)
	self:SetShouldHideWorldModel(false)
end

function SWEP:OnDrop()
	if self:GetCurrentState() ~= "Nothing" then
		local Ent = ents.Create(self.ENT)
		Ent:SetPos(self:GetPos())
		Ent:SetAngles(self:GetAngles())
		Ent:SetOwner(self:GetOwner())
		Ent:Spawn()
		Ent:Activate()
		Ent:GetPhysicsObject():SetVelocity(self:GetVelocity() / 2)
	end

	if self.Rope and self.Rope.Remove and IsValid(self.Rope) and SERVER then self.Rope:Remove() end
	if self.FakeRope and self.FakeRope.Remove and IsValid(self.FakeRope) and SERVER then self.FakeRope:Remove() end
	if SERVER then self:Remove() end
end

function SWEP:PrimaryAttack()
	if CLIENT then return end
	local owner = self:GetOwner()
	if not IsValid(owner) or not owner:IsPlayer() then return end
	self.NextSpinWho0shTime = CurTime() + 1
	if self:GetCurrentState() == "Nothing" then
		if IsValid(self.GrapplinHook) then
			if not self.Tight then
				self.Tight = true
				self:PullTaut()
			else
				self.DesiredDist = math.Clamp(self.DesiredDist - 20, 50, 5000)
				local Tr = util.QuickTrace(owner:GetShootPos(), owner:GetAimVector() * 60, {owner})
				if Tr.Hit then owner:SetVelocity(-owner:GetAimVector() * 300) end
			end

			if owner.organism then owner.organism.stamina.subadd = 1.5 end
			owner:DoAnimationEvent(ACT_GMOD_GESTURE_MELEE_SHOVE_1HAND)
			owner:ViewPunch(Angle(-1, math.random(-1, 1), math.random(-1, 1)))
		end

		self:SetNextPrimaryFire(CurTime() + .2)
	else
		self:SetCurrentState("Winding")
	end
end

function SWEP:PullTaut()
	local owner = self:GetOwner()
	if not IsValid(owner) or not owner:IsPlayer() then return end
	self.DesiredDist = (owner:GetPos() - self.GrapplinHook:GetPos()):Length() + 50
	self.GrapplinHook:GetPhysicsObject():SetVelocity(owner:GetVelocity())
end

function SWEP:SecondaryAttack()
	if CLIENT then return end
	local owner = self:GetOwner()
	if not IsValid(owner) or not owner:IsPlayer() then return end
	if self:GetCurrentState() == "Nothing" then
		if IsValid(self.GrapplinHook) then
			self.DesiredDist = math.Clamp(self.DesiredDist + 50, 10, 4000)
			if owner.organism then owner.organism.stamina.subadd = 1 end
			owner:ViewPunch(Angle(-1, 0, 0))
		end

		self:SetNextSecondaryFire(CurTime() + 0.5)
	end
end

function SWEP:Reload()
	if self:GetCurrentState() == "Nothing" then
		self:Deploy()
		self.GrapplinHook = nil
		if self.Rope and self.Rope.Remove and IsValid(self.Rope) and SERVER then self.Rope:Remove() end
		if self.FakeRope and self.FakeRope.Remove and IsValid(self.FakeRope) and SERVER then self.FakeRope:Remove() end
		self.Rope = nil
		self:SetHoldType("normal")
		if SERVER then self:Remove() end
	end
end

function SWEP:Think()
	local Time = CurTime()
	local owner = self:GetOwner()
	if not IsValid(owner) or not owner:IsPlayer() then
		if self.Rope and self.Rope.Remove and IsValid(self.Rope) and SERVER then self.Rope:Remove() end
		if self.FakeRope and self.FakeRope.Remove and IsValid(self.FakeRope) and SERVER then self.FakeRope:Remove() end
		return
	end

	if self.NextThinkTime <= Time then
		self.NextThinkTime = Time + .025
		local State = self:GetCurrentState()
		if not (State == "Nothing") then
			local Sprintin = owner:KeyDown(IN_SPEED)
			local HiddenAmt = self:GetHidden()
			local BackAmt = self:GetBack()
			if State == "Idling" then
				if owner:KeyDown(IN_ATTACK) then self:Windup() end
			elseif State == "Drawing" then
				self:SetHidden(math.Clamp(HiddenAmt - 10 / self.DrawTime, 0, 100))
				if HiddenAmt <= 0 then self:SetCurrentState("Idling") end
			elseif (State == "Winding") and not self.JustThrew then
				self:SetHoldType("Grenade")
				if not owner:KeyDown(IN_ATTACK) then
					if self:GetThrowPower() > 0 then
						self:SetCurrentState("Drawing")
						self:SetHidden(100)
						self:SetBack(0)
						self:Throw()
						return
					end
				end

				self:SetBack(math.Clamp(BackAmt + 15, 0, 100))
				self:SetThrowPower(math.Clamp(self:GetThrowPower() + 5 * self.ThrowChargeSpeed, 1, 130))
				self.ThrowChargeSpeed = (-2.7 + (owner.organism.stamina[1] / 45)) * 0.15
				--print(self.ThrowChargeSpeed)
			end
		end

		self:CustomThink(State, Sprintin, HiddenAmt, BackAmt)
	end

	self:NextThink(Time + .025)
	return true
end

function SWEP:Windup()
	if self:GetCurrentState() == "Winding" then return end
	self:SetCurrentState("Winding")
	self:SetThrowPower(1)
	self.JustThrew = false
	--self:SetHoldType("grenade")
end

function SWEP:Throw()
	local owner = self:GetOwner()
	if not IsValid(owner) or not owner:IsPlayer() then return end

	owner:SetAnimation(PLAYER_ATTACK1)
	if CLIENT then return end

	self.JustThrew = true
	self:SetCurrentState("Nothing")
	self:SetShouldHideWorldModel(true)
	self.DesiredDist = 1500
	self.Tight = false

	local Vec = owner:GetAimVector()
	local Pos = owner:GetShootPos()
	local ThrowPos = Pos + Vec * 30
	local Tr = util.QuickTrace(Pos, Vec * 35, {owner})
	if Tr.Hit then ThrowPos = Pos + Vec * 10 end
	sound.Play("weapons/slam/throw.wav", self:GetPos(), 75, 80)
	sound.Play("weapons/slam/throw.wav", self:GetPos(), 70, 80)
	sound.Play("weapons/slam/throw.wav", self:GetPos(), 65, 80)

	local Gr = ents.Create(self.ENT)
	Gr:SetPos(ThrowPos)
	Gr.Owner = owner
	Gr:SetOwner(self:GetOwner())
	Gr:SetAngles(VectorRand():Angle())
	Gr:Spawn()
	Gr:Activate()
	Gr.Rope = self

	self.GrapplinHook = Gr
	Gr:GetPhysicsObject():SetVelocity(owner:GetVelocity() + Vec * self:GetThrowPower() * 6 * self.ThrowAbility)
	Gr:SetPhysicsAttacker(owner)

	timer.Simple(.5, function()
		if IsValid(self) then
			self:SetHoldType("melee2")
		end
	end)

	if self.Rope and self.Rope.Remove and IsValid(self.Rope) and SERVER then self.Rope:Remove() end
	if self.FakeRope and self.FakeRope.Remove and IsValid(self.FakeRope) and SERVER then self.FakeRope:Remove() end

	self.Rope = self:CollisionlessKeyFrameRope(owner, self.GrapplinHook, Vector(0, 0, 10), Vector(0, 0, 0), 1000, 2, "cable/rope")
end

function SWEP:CollisionlessKeyFrameRope(Ent1, Ent2, LPos1, LPos2, length, width, material)
	if width <= 0 then return nil end
	width = math.Clamp(width, 1, 100)
	local rope = ents.Create("keyframe_rope")

	rope:SetPos(Ent1:GetPos())
	rope:SetKeyValue("Width", width)
	if material then rope:SetKeyValue("RopeMaterial", material) end

	rope:SetEntity("StartEntity", Ent1)
	rope:SetKeyValue("StartOffset", tostring(LPos1))
	rope:SetKeyValue("StartBone", 0)
	rope:SetEntity("EndEntity", Ent2)
	rope:SetKeyValue("EndOffset", tostring(LPos2))
	rope:SetKeyValue("EndBone", 0)

	local kv = {
		Length = length,
		Collide = 0
	}

	for k, v in pairs(kv) do
		rope:SetKeyValue(k, tostring(v))
	end

	rope:Spawn()
	rope:Activate()
	Ent1:DeleteOnRemove(rope)
	Ent2:DeleteOnRemove(rope)
	return rope
end

function SWEP:OnRemove()
	local owner = self:GetOwner()
	if not IsValid(owner) or not owner:IsPlayer() then return end

	if self.Rope and self.Rope.Remove and IsValid(self.Rope) and SERVER then self.Rope:Remove() end
	if self.FakeRope and self.FakeRope.Remove and IsValid(self.FakeRope) and SERVER then self.FakeRope:Remove() end
	if owner and IsValid(owner) and owner.SelectWeapon then owner:SelectWeapon("wep_jack_hmcd_hands") end
end

function SWEP:Holster()
	local owner = self:GetOwner()
	if not IsValid(owner) or not owner:IsPlayer() then return end

	if (self:GetCurrentState() == "Idling") or (self:GetCurrentState() == "Hidden") or IsValid(owner.FakeRagdoll) then
		return true
	else
		return false
	end
end

function SWEP:Deploy()
	local owner = self:GetOwner()
	if not IsValid(owner) or not owner:IsPlayer() then return end

	self:SetHidden(100)
	self:SetNextPrimaryFire(CurTime() + 0.5)
	self:SetNextSecondaryFire(CurTime() + 0.5)
	self:SetShouldHideWorldModel(false)
end

function SWEP:Fail()
	local owner = self:GetOwner()
	if not IsValid(owner) or not owner:IsPlayer() then return end

	sound.Play("weapons/slam/throw.wav", self:GetPos(), 75, 110)
	sound.Play("weapons/slam/throw.wav", self:GetPos(), 70, 110)
	sound.Play("weapons/slam/throw.wav", self:GetPos(), 65, 110)
	owner:ViewPunch(VectorRand():Angle())
	self:Reload()
end

SWEP.CreatedFakeRope = false
function SWEP:CustomThink(State, Sprintin, HiddenAmt, BackAmt)
	if CLIENT then return end
	local owner = self:GetOwner()
	if not IsValid(owner) or not owner:IsPlayer() then return end
	if IsValid(self.GrapplinHook) then
		local Vec, Vel = self.GrapplinHook:GetPos() - (owner:GetPos() + Vector(0, 0, -50)), owner:GetVelocity()
		local Dir = Vec:GetNormalized()
		local Dist = Vec:Length()
		local EffDist = Dist - self.DesiredDist
		local RelVel = self.GrapplinHook:GetPhysicsObject():GetVelocity() - Vel
		if EffDist > 0 and not IsValid(owner.FakeRagdoll) then
			local LinearVelocity, Ground = Dir:Dot(Vel) * Dir, owner:IsOnGround()
			owner:SetGroundEntity(nil)
			owner:SetVelocity(Dir * math.Clamp(EffDist * 10, 0, 150) - LinearVelocity / 2)
			self.GrapplinHook:GetPhysicsObject():ApplyForceCenter(-Dir * EffDist * 100 - self.GrapplinHook:GetPhysicsObject():GetVelocity() / 40)
			if (EffDist > 20) and not Ground and (RelVel:Length() > 1200) then
				self:Fail()
				return
			end
		end

		if IsValid(self.Rope) then self.Rope:Fire("SetLength", self.DesiredDist + 10) end

		if not IsValid(owner.FakeRagdoll) and self.CreatedFakeRope then
			self.CreatedFakeRope = false
			if self.FakeRope and self.FakeRope.Remove and IsValid(self.FakeRope) then self.FakeRope:Remove() end
			self.Rope = self:CollisionlessKeyFrameRope(owner, self.GrapplinHook, Vector(0, 0, 10), Vector(0, 0, 0), 1000, 2, "cable/rope")
		end

		if IsValid(owner.FakeRagdoll) and not self.CreatedFakeRope then
			self.GrapplinHook.Locked = true
			self.FakeRope = constraint.Rope(
				self.GrapplinHook, -- ent1
				owner.FakeRagdoll, -- ent2
				0, -- bone1
				0, -- bone2
				vector_origin, -- pos1
				vector_origin, -- pos2
				self.DesiredDist + 5, -- length
				0, -- addlength
				0, -- forcelimit
				2, -- width
				"cable/rope", -- mat
				false, -- rigid
				color_white -- clr
			)
			self.CreatedFakeRope = true
			if self.Rope and self.Rope.Remove and IsValid(self.Rope) then self.Rope:Remove() end
		end
	elseif State == "Nothing" then
		self:Reload()
	elseif State == "Winding" then
		if self.NextSpinWhooshTime < CurTime() then
			local Pow = self:GetThrowPower()
			self.NextSpinWhooshTime = CurTime() + math.Clamp(10 / Pow, .3, 1.25)
			sound.Play("weapons/slam/throw.wav", self:GetPos(), 65, math.Clamp(Pow, 60, 130))
			owner:ViewPunch(Angle(-1, 0, 0))
			if owner.organism then owner.organism.stamina.subadd = 1.5 end
		end

		if SERVER then
			local Spun = self:GetSpin() + 25
			if Spun > 360 then Spun = 0 end
			self:SetSpin(Spun)
		end
	end
end

if CLIENT then
	local TheMat = Material("cable/rope")
	local clr = Color(10, 10, 10, 255)
	function SWEP:DrawWorldModel()
		local owner = self:GetOwner()
		if not IsValid(owner) or not owner:IsPlayer() then return end
		if IsValid(owner.FakeRagdoll) then return end

		if self:GetCurrentState() ~= "Nothing" then
			local Pos, Ang = owner:GetBonePosition(owner:LookupBone("ValveBiped.Bip01_R_Hand"))
			if self.DatWorldModel then
				if Pos and Ang and true then
					local ThePos = Pos + Ang:Forward() * 4 + Ang:Right() - Ang:Up() * 0
					Ang:RotateAroundAxis(Ang:Forward(), 90)
					if self:GetCurrentState() == "Winding" then
						self.Spining = Lerp(FrameTime() * 45, self.Spining or 0, (self.Spining or 0) + (self:GetThrowPower() / 4))
						Ang:RotateAroundAxis(Ang:Forward(), self.Spining)
						ThePos = ThePos + Ang:Up() * 30
						render.SetMaterial(TheMat)
						local Col = render.GetAmbientLightColor(ThePos)
						render.DrawBeam(Pos, ThePos, 2, 1, 0, Color(Col.r * 255, Col.g * 255, Col.b * 255, 255))
					else
						Ang:RotateAroundAxis(Ang:Forward(), 90)
					end

					self.DatWorldModel:SetRenderOrigin(ThePos)
					self.DatWorldModel:SetRenderAngles(Ang)
					--local Mat=Matrix()
					--Mat:Scale(Vector(.9,.4,.9))
					--self.DatWorldModel:EnableMatrix("RenderMultiply",Mat)
					local R, G, B = render.GetColorModulation()
					render.SetColorModulation(.1, .1, .1)
					self.DatWorldModel:DrawModel()
					render.SetColorModulation(R, G, B)
				end
			else
				self.DatWorldModel = ClientsideModel("models/weapons/c_models/c_grappling_hook/c_grappling_hook.mdl")
				self.DatWorldModel:SetMaterial("models/shiny")
				self.DatWorldModel:SetColor(clr)
				self.DatWorldModel:SetModelScale(.8, 0)
				self.DatWorldModel:SetPos(self:GetPos())
				self.DatWorldModel:SetParent(self)
				self.DatWorldModel:SetNoDraw(true)
			end
		end
	end
end