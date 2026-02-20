if SERVER then AddCSLuaFile() end
SWEP.PrintName = "F1"
SWEP.Category = "Weapons - Explosive"
SWEP.Instructions = "A famous soviet WWII offensive grenade. It's still widely exported and used to this day. It has a pyrotechnic delay of 3.2-4.2 seconds."
SWEP.Spawnable = false
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
SWEP.WorldModel = "models/pwb/weapons/w_f1.mdl"

SWEP.ScrappersSlot = "Other"

if CLIENT then
	SWEP.WepSelectIcon = Material("pwb/sprites/f1.png")
	SWEP.IconOverride = "pwb/sprites/f1.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Slot = 4
SWEP.SlotPos = 1
SWEP.ENT = "ent_hg_grenade"

function SWEP:GetEyeTrace()
	return hg.eyeTrace(self:GetOwner())
end

SWEP.offsetVec = Vector(-7, -3, -3)
SWEP.offsetAng = Angle(145, 0, 0)
SWEP.ModelScale = 1
SWEP.NoTrap = false

SWEP.spoon = "models/weapons/arc9/darsu_eft/skobas/m18_skoba.mdl"

function SWEP:DrawWorldModel()
	self.model = IsValid(self.model) and self.model or ClientsideModel(self.WorldModel)
	local WorldModel = self.model
	WorldModel:SetNoDraw(true)
	local owner = self:GetOwner()
	if not IsValid(WorldModel) then return end
	
	if (not IsValid(owner)) or owner.NotSeen or (not owner.shouldTransmit) then
		WorldModel:SetPos(self:GetPos())
		WorldModel:SetAngles(self:GetAngles())
		WorldModel:SetRenderOrigin(self:GetPos())
		WorldModel:SetRenderAngles(self:GetAngles())
		WorldModel:DrawModel()
		return
	end

	WorldModel:SetModelScale(self.ModelScale or 1)
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
		WorldModel:SetRenderOrigin(newPos)
		WorldModel:SetRenderAngles(newAng)
		WorldModel:SetupBones()
	else
		WorldModel:SetPos(self:GetPos())
		WorldModel:SetAngles(self:GetAngles())
		WorldModel:SetRenderOrigin(self:GetPos())
		WorldModel:SetRenderAngles(self:GetAngles())
	end

	if not self:GetNWBool("PlacedLOVUSHKA",false) then
		WorldModel:DrawModel()
	end

	if self.lefthandmodel then
		if owner.organism and owner.organism.larmamputated then return end
		self.model2 = IsValid(self.model2) and self.model2 or ClientsideModel(self.lefthandmodel)
		local WorldModel = self.model2
		local owner = self:GetOwner()
		if not IsValid(WorldModel) then return end

		WorldModel:SetNoDraw(true)
		WorldModel:SetModelScale(self.ModelScale2 or 1)
		
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
			WorldModel:SetRenderOrigin(newPos)
			WorldModel:SetRenderAngles(newAng)
			WorldModel:SetupBones()
		else
			WorldModel:SetPos(self:GetPos())
			WorldModel:SetAngles(self:GetAngles())
			WorldModel:SetRenderOrigin(self:GetPos())
			WorldModel:SetRenderAngles(self:GetAngles())
		end
		
		if IsValid(owner.FakeRagdoll) or not IsValid(owner) or (IsValid(owner:GetActiveWeapon()) and owner:GetActiveWeapon() ~= self) then return end
		WorldModel:DrawModel()
	end
end

hg.weapons2 = hg.weapons2 or {}

function SWEP:Initialize()
	self:SetHold(self.HoldType)
	hg.weapons2[ #hg.weapons2 + 1 ] = self
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

	self:BoneSet("r_upperarm", vector_origin, Angle(-90,0,-60))

	if self.startedattack then
		local animpos = math.max((self.startedattack + 0.5) - CurTime(),0) * 2
		
		self:BoneSet("l_upperarm", vector_origin, Angle(-90 * animpos,-60 * animpos,0))
		self:BoneSet("r_upperarm", vector_origin, Angle(-20 * animpos,-40 * animpos,0))
	end

	if self.starthold then
		local animpos = math.max((self.starthold + 0.5) - CurTime(),0) * 2

		--self:BoneSet("r_finger0", vector_origin, Angle(70 * animpos,-10 * animpos,0))
		--self:BoneSet("r_hand", vector_origin, Angle(20 * animpos,0,0))
	end
end

function SWEP:SetHold(value)
	self:SetWeaponHoldType(value)
	self:SetHoldType(value)
	self.holdtype = value
end

function SWEP:PrimaryAttack()
	local time = CurTime()
	--// Time to throw!
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	if SERVER and not self.removed then self:Throw(800, time) end
end
if SERVER then
	util.AddNetworkString("hg_started_attack")
	util.AddNetworkString("hg_started_spoon")
else
	net.Receive("hg_started_attack",function()
		net.ReadEntity().startedattack = CurTime()
	end)
	net.Receive("hg_started_spoon",function()
		net.ReadEntity().starthold = CurTime()
	end)
end

local clr = Color(50, 40, 0)
local function createSpoon(self,entownr)
	local entasd
	if not self.spoon then return end
	if IsValid(entownr) then
		local hand = entownr:GetBoneMatrix(entownr:LookupBone("ValveBiped.Bip01_R_Hand"))

		entasd = ents.Create("prop_physics")
		entasd:SetModel(self.spoon)
		entasd:SetPos(hand:GetTranslation())
		entasd:SetAngles(hand:GetAngles())
		entasd:Spawn()
		entasd:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		if self.spoon == "models/weapons/arc9/darsu_eft/skobas/m18_skoba.mdl" then
			entasd:SetMaterial("models/shiny")
			entasd:SetColor(clr)
		end

		entownr:EmitSound("weapons/m67/m67_spooneject.wav",65)
		hg.EmitAISound(hand:GetTranslation(), 96, 5, 8)
	else
		entasd = ents.Create("prop_physics")
		entasd:SetModel(self.spoon)
		entasd:SetPos(self:GetPos())
		entasd:SetAngles(self:GetAngles())
		entasd:Spawn()
		entasd:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		if self.spoon == "models/weapons/arc9/darsu_eft/skobas/m18_skoba.mdl" then
			entasd:SetMaterial("models/shiny")
			entasd:SetColor(clr)
		end

		entasd:EmitSound("weapons/m67/m67_spooneject.wav",65)
		hg.EmitAISound(self:GetPos(), 96, 5, 8)
	end

	return entasd
end

function SWEP:Step1()
	if IsValid(self:GetOwner()) and self:GetOwner():IsNPC() then return end

	if SERVER and self:GetNWBool("PlacedLOVUSHKA",false) and (IsValid(self:GetOwner()) and self:GetOwner():GetActiveWeapon() ~= self or not IsValid(self.lovushka)) then
		if IsValid(self:GetOwner()) then
			self:GetOwner():SelectWeapon("weapon_hands_sh")
		end
		self:Remove()
	end

	if SERVER and not self.removed and not self:GetNWBool("PlacedLOVUSHKA",false) then
		local time = CurTime()
		local ply = self:GetOwner()
		
		self.lastowner = ply:IsPlayer() and ply or self.lastowner

		local entownr
		if IsValid(ply) then
			entownr = hg.GetCurrentCharacter(ply)
		end
		
		if not self.timeToBoom then
			local ent = scripted_ents.GetStored(self.ENT)--scripted_ents.Get("ent_"..string.sub(self:GetClass(),8))
			
			self.timeToBoom = ent.timeToBoom or 5
		end

		if IsValid(entownr) and ply:GetActiveWeapon()==self then
			if ply:KeyDown(IN_ATTACK) and not self.startedattack then
				if self.nofunnyfunctions then
					if not self.throwin then
						ply:EmitSound(self.throwsound or "weapons/m67/m67_throw_01.wav",65)
					end
					self.startedattack = time
					self.throwin = self.throwin or time + self.timetothrow
					net.Start("hg_started_attack")
					net.WriteEntity(self)
					net.Broadcast()
					return
				end
				
				entownr:EmitSound("weapons/m67/m67_pullpin.wav",65)
				self.startedattack = time
				net.Start("hg_started_attack")
				net.WriteEntity(self)
				net.Broadcast()
			end

			if self.nofunnyfunctions then
				if self.throwin and self.throwin < time then
					self:Throw(800, time)
				end
				return
			end
			
			if self.startedattack and ply:KeyDown(IN_ATTACK2) and not self.starthold and entownr == ply then
				self.starthold = time
				net.Start("hg_started_spoon")
				net.WriteEntity(self)
				net.Broadcast()
				createSpoon(self,entownr)
			end

			if self.startedattack and not ply:KeyDown(IN_ATTACK) then
				self.endhold = time
			end

			if self.endhold and not self.starthold then
				self.starthold = self.endhold
				createSpoon(self,entownr)
			end
		else
			if self.nofunnyfunctions then
				if self.startedattack then
					self:EmitSound("weapons/m67/m67_throw_01.wav", 90, math.random(95, 105))
					self:Throw(800, time)
				end
				return
			end
			if self.startedattack then
				if not self.starthold then
					createSpoon(self)
				end
				self.starthold = self.starthold or time
			end
			if self.nofunnyfunctions then
				if self.throwin and self.throwin < time then
					self:Throw(800, time)
				end
				return
			end
		end

		if self.AddStep then self:AddStep() end

		if self.starthold and (((self.timeToBoom - 0.1 + self.starthold) <= CurTime()) or self.endhold) then
			if self.endhold then
				local timeheld = math.max(self.endhold - self.starthold - 0.1,0)
				
				self:Throw(800, time - timeheld)
			else
				self:Throw(0, time - self.timeToBoom,true)
			end
		end
	end
end

function SWEP:OwnerChanged()
	if SERVER and self:GetNWBool("PlacedLOVUSHKA",false) then
		self:Remove()
	end
end

SWEP.lpos = Vector(2,0,0)
SWEP.lang = Angle(0,0,0)

function SWEP:SecondaryAttack()
	if self.NoTrap then return end
	local time = CurTime()
	if IsValid(self:GetNWEntity("fakeGun")) then return end
	if CLIENT then return end
	local ply = self:GetOwner()
	local entownr
	if IsValid(ply) then
		entownr = hg.GetCurrentCharacter(ply)
	end
	
	if ply:KeyDown(IN_WALK) then return end

	if not hg.eyeTrace(ply).Hit then return end

	if not self.startedattack and entownr == ply and not self:GetNWBool("PlacedLOVUSHKA",false) then
		local tr = hg.eyeTrace(ply)
		local ent = ents.Create(self.ENT)
		local pos,ang = LocalToWorld(self.lpos,self.lang,tr.HitPos,tr.HitNormal:Angle())
		ent:SetPos(pos)
		ent:SetAngles(ang)
		ent:Spawn()
		ent.owner = self.lastowner
		ent.owner2 = self.lastowner
		
		ent.cons2 = constraint.Weld(ent,tr.Entity,0,tr.PhysicsBone or 0,200,true,false)
		
		self.lovushka = ent
		
		self:SetNWBool("PlacedLOVUSHKA",true)
	elseif IsValid(self.lovushka) then
		local tr = hg.eyeTrace(ply)

		local tr2 = {}
		tr2.start = self.lovushka:GetPos()
		tr2.endpos = tr.HitPos
		tr2.filter = self.lovushka
		local trace = util.TraceLine(tr2)

		if trace.Hit then return end
		
		local len = tr.HitPos:Distance(self.lovushka:GetPos())
		if len < 200 and len > 10 then
			self.lovushka.ent = tr.Entity
			self.lovushka.lpos = tr.Entity:WorldToLocal(tr.HitPos)
			self.lovushka.origlen = tr.HitPos:Distance(self.lovushka:GetPos())
			local cons = constraint.CreateKeyframeRope(tr.HitPos,0.05,"cable/cable2",nil,self.lovushka.ent,self.lovushka.lpos,tr.PhysicsBone,self.lovushka,vector_origin,0,
			{
				["Slack"] = 50,
				["Collide with world"] = false,
			})
			local ent2 = ents.Create("prop_physics")
			ent2:SetModel("models/props_combine/breendesk.mdl")
			
			ent2:SetMoveType(MOVETYPE_NONE)
			ent2:SetSolid(SOLID_VPHYSICS)
			ent2:Spawn()
			local size = 1
			local pos = self.lovushka:GetPos()
			--local dir = (tr.HitPos - pos):GetNormalized() * 1
			ent2:PhysicsInitConvex({
				Vector( tr.HitPos[1], tr.HitPos[2], tr.HitPos[3] ),
				Vector( tr.HitPos[1], tr.HitPos[2], tr.HitPos[3] + size ),
				Vector( tr.HitPos[1] + size, tr.HitPos[2], tr.HitPos[3] ),
				Vector( tr.HitPos[1] + size, tr.HitPos[2], tr.HitPos[3] + size ),
				Vector( pos[1], pos[2], pos[3] ),
				Vector( pos[1], pos[2], pos[3] + size ),
				Vector( pos[1] + size, pos[2], pos[3] ),
				Vector( pos[1] + size, pos[2], pos[3] + size ),
			})			
			ent2:EnableCustomCollisions( true )

			local phys = ent2:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetMass(1)
			end

			ent2.lovushka = self
			ent2:SetNoDraw(true)
			ent2:AddCallback("PhysicsCollide",function()
				if IsValid(ent2.lovushka) then
					ent2.lovushka:Arm(CurTime() - ent2.lovushka.timeToBoom + 1,Vector(0,0,0))
				end
				timer.Simple(0,function()
					--ent2:Remove()
				end)
			end)
			constraint.NoCollide(self.lovushka,ent2,0,0)
			constraint.Weld(self.lovushka,ent2,0,0,0,true,false)
			constraint.Weld(self.lovushka.ent,ent2,0,0,0,true,false)
		
			self.lovushka.ent2 = ent2
			self.lovushka.cons = cons
			ply:SelectWeapon("weapon_hands_sh")
			self:Remove()
		end
	end
end

function SWEP:GetFakeGun()
	return self:GetNWEntity("fakeGun")
end

local throwang = Angle(7,5,-5)
function SWEP:Throw(mul, time, nosound)
	if not self.ENT then return end
	local owner = self:GetOwner()
	local ent = ents.Create(self.ENT)
	local entOwner = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or IsValid(owner) and owner
	local hand = IsValid(entOwner) and owner:EyePos() - vector_up * 5 or self:GetPos()
	if not nosound and IsValid(entOwner) then
		entOwner:EmitSound(self.throwsound or "weapons/m67/m67_throw_01.wav", 90, math.random(95, 105))
	end

	if IsValid(owner) then
		owner:ViewPunch(throwang)
		owner:AnimRestartGesture(GESTURE_SLOT_GRENADE, ACT_HL2MP_GESTURE_RANGE_ATTACK_GRENADE, true)
	end

	ent:Spawn()
	ent:SetPos(hand + (IsValid(owner) and self:GetAngles():Forward() * 5 or vector_origin))
	ent:SetAngles(IsValid(owner) and owner:EyeAngles() or self:GetAngles())
	local phys = ent:GetPhysicsObject()
	if phys then phys:SetVelocity(IsValid(owner) and (owner:GetAimVector() * mul) + owner:GetVelocity() or Vector(0,0,0)) end
	ent.timer = time
	ent.owner = self.lastowner
	ent.owner2 = self.lastowner

	--self.removed = true
	self.count = self.count - 1
	if self.count < 1 then
		self:Remove()
	end
	self.starthold = nil
	self.endhold = nil
	self.startedattack = nil
	self.throwin = nil
	if IsValid(owner) then
		self:ThrowAdd()
		owner:SelectWeapon("weapon_hands_sh")
		net.Start("grenade throw")
			net.WriteEntity(owner)
		net.Broadcast()
	end
end

function SWEP:ThrowAdd()
end
if SERVER then
	util.AddNetworkString("grenade throw")
else
	net.Receive("grenade throw",function()
		local ent = net.ReadEntity()
		if not IsValid(ent) then return end
		ent:AnimRestartGesture(GESTURE_SLOT_GRENADE, ACT_HL2MP_GESTURE_RANGE_ATTACK_GRENADE, true)
	end)
end

SWEP.WorkWithFake = true
function SWEP:SetFakeGun(ent)
	self:SetNWEntity("fakeGun", ent)
	self.fakeGun = ent
end

function SWEP:RemoveFake()
	if not IsValid(self.fakeGun) then return end
	self.fakeGun:Remove()
	self:SetFakeGun()
end

function SWEP:CreateFake(ragdoll)
	if IsValid(self:GetNWEntity("fakeGun")) then return end
	local ent = ents.Create("prop_physics")

	local rh = ragdoll:GetPhysicsObjectNum(hg.realPhysNum(ragdoll, 7))
	
	local offsetVec = self.offsetVec
	local offsetAng = self.offsetAng

	local newPos, newAng = LocalToWorld(offsetVec, offsetAng, rh:GetPos(), rh:GetAngles())

	ent:SetModel(self.WorldModel)
	ent:Spawn()

	ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	ent:SetOwner(ragdoll)
	ent:GetPhysicsObject():SetMass(0)
	//ent:SetNoDraw(true)
	ent.dontPickup = true
	ent.fakeOwner = self
	ragdoll:DeleteOnRemove(ent)
	ragdoll.fakeGun = ent
	if IsValid(ragdoll.ConsRH) then ragdoll.ConsRH:Remove() end

	ent:SetPos(newPos)
	ent:SetAngles(newAng)
	local weld = constraint.Weld(ent,ragdoll,0,7,0,true,true)

	self:SetFakeGun(ent)
	ent:CallOnRemove("homigrad-swep", self.RemoveFake, self)
end

local shadowControl
function SWEP:RagdollFunc(pos, angles, ragdoll)
	if not (pos and angles and IsValid(ragdoll)) then return end
	shadowControl = shadowControl or hg.ShadowControl
	local fakeGun = ragdoll.fakeGun
	pos:Add(angles:Forward() * 20)
	angles:RotateAroundAxis(angles:Forward(), 180)
	shadowControl(ragdoll, 7, 0.001, angles, 500, 30, pos, 500, 50)
end