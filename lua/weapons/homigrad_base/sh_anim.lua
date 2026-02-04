AddCSLuaFile()
--
function SWEP:Initialize_Anim()
	self.Anim_RecoilCameraZoom = Vector(0, 0, 0)
	self.Anim_RecoilCameraZoomSet = Vector(0, 0, 0)
	self.Anim_RecoilLerp = 0
end

function SWEP:SetHold(value)
	self.holdtype = value
	self:SetHoldType(value)
	self:SetWeaponHoldType(value)
end

hook.Add("Bones", "homigrad-weapons-bone", function(ply)
	local wep = ply:GetActiveWeapon()
	local func = wep.Animation
	
	if func then func(wep, ply) end
end)

local vecZero = Vector(0, 0, 0)
local vecZero2 = Vector(0, 0, 0)
local angZero = Angle(0, 0, 0)
local CurTime = CurTime
function SWEP:Animation()
	--local systime = SysTime()
	--print("first",systime)
	local owner = self:GetOwner()
	
	--local bon = owner:LookupBone("ValveBiped.Bip01_Spine")
	--local mat = owner:GetBoneMatrix(bon)
	--mat:SetTranslation(Player(3):GetBoneMatrix(1):GetTranslation())
	--mat:SetAngles(Angle(0,0,0))
	--mat:SetTranslation(Vector(0,0,0))
	--owner:SetBoneMatrix2(bon,mat)

	local dtime = SysTime() - (self.dtimeanim or SysTime())

	if IsValid(owner) and (not owner:IsPlayer() and (owner.InVehicle and owner:InVehicle())) then
		self:SetHoldType(self:IsPistolHoldType() and "pistol" or "smg")
		if IsValid(owner) and owner:IsPlayer() and IsValid(owner:GetVehicle()) and owner:GetVehicle():GetDriver() == owner and owner:GetVehicle():GetClass() ~= "prop_vehicle_prisoner_pod"  then
			return
		end
	end

	if (not IsValid(owner)) or !owner.GetActiveWeapon or (owner:GetActiveWeapon() ~= self) then return end

	self.dtimeanim = SysTime()

	if owner:GetNWBool("suiciding") then
		self:SuicideAnim()
		return
	end

	self:AnimApply_ShootRecoil(self:LastShootTime())
	self:AnimHold()

	self:AnimZoom()

	--print("end",SysTime()-systime)
end

function SWEP:AnimationRender()
	self:AnimationPost()
end

function SWEP:AnimationPost()
end

local bone, name
function SWEP:BoneSet(lookup_name, vec, ang, layer, lerp)
	if self:GetOwner():IsPlayer() then
	
		local bon = hg.bone.client_only[lookup_name]

		if bon then
			local ent = hg.GetCurrentCharacter(self:GetOwner())
			local boneIndex = ent:LookupBone(bon) 
			
			if not boneIndex then return end 
			
			local mat = ent:GetBoneMatrix(boneIndex) 
			if not mat then return end 
			
			local nvec, nang = LocalToWorld(vec or vector_origin, ang or angle_zero, mat:GetTranslation(), mat:GetAngles())
			mat:SetTranslation(nvec)
			mat:SetAngles(nang)
			hg.bone_apply_matrix(ent, bon, mat)
			return
		end

		hg.bone.Set(self:GetOwner(), lookup_name, vec, ang, layer, lerp)
	end
end


function SWEP:AnimHoldPost(model)
end


local angHold1 = Angle(-10, -5, 0)
local angHold2 = Angle(-10, 5, 0)
SWEP.handsAng = Angle(0, 0, 0)
local plyAng, handAng, handPos, addAng, _ = Angle(0, 0, 0), Angle(0, 0, 0), vecZero, Angle(0, 0, 0), vecZero

function SWEP:SuicideAnim()
	self:SetHold("normal")
end

function SWEP:IsPistolHoldType()
	return self.IsPistol or ((self.HoldType == "revolver") or (self.HoldType == "pistol")) 
end

local ang1 = Angle(0, 0, 0)

local funcNil = function() end

hg.postureFunctions = {
	[1] = function(self,ply)
	end,
	[2] = function(self,ply)
	end,
	[3] = function(self,ply)
	end,
	[6] = function(self,ply)
	end,
	[7] = function(self,ply)
		if self.IsPistolHoldType and not self:IsPistolHoldType() then ply.posture = 0 end		
	end,
	[8] = function(self,ply)
		if self.IsPistolHoldType and not self:IsPistolHoldType() then ply.posture = 0 end		
	end,
}

function SWEP:ReadyStance()
	local ply = self:GetOwner()
	return self:IsSprinting() or ply.posture == 4 or ply.posture == 3
end

function SWEP:AnimHold()
	self.rotfuckinghands = self.IsPistolHoldType and not self:IsPistolHoldType()
	local _
	local ply = self:GetOwner()
	
	if not self.attachments then return end
	//self.holdtype = self.attachments.grip and #self.attachments.grip ~= 0 and hg.attachments.grip[self.attachments.grip[1]].holdtype or self.HoldType
	self.holdtype = self.HoldType
	--self.holdtype = self.holster and (self.holster - CurTime()) / (self.CooldownHolster / self.Ergonomics) < 0.5 and "normal" or self.holdtype
	self.holdtype = ((self.deploy and (self.deploy - CurTime()) / (self.CooldownDeploy / self.Ergonomics) > 0.5)) and "normal" or self.holdtype
	self.holdtype = ((self:IsPistolHoldType() or self.CanEpicRun) and ((ply.posture == 7 or ply.posture == 8 or self:IsSprinting()) or (self:IsPistolHoldType() and ply.posture == 9) and not self.reload)) and "slam" or self.holdtype
	self.holdtype = ((ply:IsFlagSet(FL_ANIMDUCKING)) and self.holdtype == "rpg") and "smg" or self.holdtype
	self.holdtype = (self:IsPistolHoldType() and (self:GetButtstockAttack() - CurTime() > -0.5)) and "melee" or self.holdtype
	--self.holdtype = (!self:IsPistolHoldType() and ply.posture == 2 and "revolver" or self.holdtype)
	--self.holdtype = self:ReadyStance() and not self:IsPistolHoldType() and "pistol" or self.holdtype
	self:SetHold(self.holdtype)

	local stam = (ply.organism ~= nil and ply.organism.stamina and ply.organism.stamina[1]) or 180
	local timea = 0.4 * ((math.max(0, (self.weight - 3)) * 0.2) + 1) * (math.Clamp((180 - stam) / 90, 1, 1.5))
	local progress = (1 - math.Clamp(self:GetButtstockAttack() - CurTime() + timea * 2, 0, timea * 2) / timea)
	
	if progress > 0 then
		progress = 1 - progress
		progress = math.ease.InOutSine(progress)
	else
		progress = 1 + progress
		progress = math.ease.OutBack(progress)
	end

	if progress > 0 then
		self:BoneSet("spine1", vecZero, Angle(0, 0, progress * 25), "buttstockattack", 0.0001)
		self:BoneSet("head", vecZero, Angle(0, 0, -progress * 25), "buttstockattack", 0.0001)
	end

	local func = hg.postureFunctions[ply.posture] or funcNil

	func(self,ply)

	if CLIENT then
		ply:SetIK(false)
	end

	if CLIENT then
		--self:AnimHoldPost(self.worldModel)
	end
end

local vecZoom1 = Vector(1, -1, 0)
local angZoom1 = Angle(0, 0, 0)
function SWEP:AnimZoom()
	local owner = self:GetOwner()
	local bon = owner:LookupBone("ValveBiped.Bip01_Head1")
	if not bon then return end
	local pos = owner:GetBonePosition(bon)
	if not pos then return end

	angZoom1[1] = self:IsZoom() and (self.desiredPos - pos):GetNormalized():Dot(owner:EyeAngles():Right()) or 0
	angZoom1[1] = self:IsZoom() and (-angZoom1[1] * 50) or 0
	angZoom1[1] = self:IsZoom() and math.Clamp(angZoom1[1],-20,20) or 0
	
	if !angZoom1:IsEqualTol(angle_zero, 0.01) then
		self:BoneSet("head", vecZero, angZoom1, "aiming", 0.1)
	end
end

local math_max, math_Clamp = math.max, math.Clamp
SWEP.AnimShootMul = 1
SWEP.AnimShootHandMul = 1
function SWEP:GetAnimPos_Shoot(time, timeSpan)
	local timeSpan = timeSpan or 0.2
	return timeSpan - math_Clamp(CurTime() - time, 0, timeSpan)
end

function SWEP:AnimApply_ShootRecoil(time)
	local owner = self:GetOwner()
	local animpos = self:GetAnimPos_Shoot(time, 0.3)
	if animpos > 0 then
		animpos = animpos * ((self:IsZoom() and self.SpreadMulZoom or self.SpreadMul) + math_max(self.Primary.Force / 110 - 1, 0)) * (( not owner:IsNPC() and owner:Crouching() ) and self.CrouchMul or 1) * 0.75
		animpos = animpos * self.AnimShootMul
		animpos = math.ease.InOutSine(animpos)

		//if self.IsPistolHoldType and not self:IsPistolHoldType() then
			if CLIENT and (owner ~= LocalPlayer() or LocalPlayer() ~= GetViewEntity()) then
				self:BoneSet("spine", vecZero, Angle(0, 0, -15 * animpos * self.Primary.Force / 50 * (self.NumBullet and self.NumBullet * 0.5 or 1)))
				self:BoneSet("head", vecZero, Angle(0, -15 * animpos * self.Primary.Force / 50 * (self.NumBullet and self.NumBullet * 0.5 or 1)), 0)
			end
		//end
	end
end

local hullVec = Vector(0, 0, 0)
local angZero = Angle(0, 0, 0)
local vecAsd2 = Vector(-45, 4, 1)
SWEP.lengthSub = 0
function SWEP:CloseAnim(dtime)
	--do return end
	if not self.attachments then return end
	local owner = self:GetOwner()
	if !owner:IsPlayer() then self.lerpaddcloseanim = 0 return 0 end
	if owner:InVehicle() then self.lerpaddcloseanim = 0 return 0 end
	if owner:IsNPC() then self.lerpaddcloseanim = 0 return 0 end
	if owner.suiciding then self.lerpaddcloseanim = 0 return 0 end
	
	//local desiredPos, desiredAng = self:PosAngChanges(owner, nil, nil, true, true)
	
	//if not desiredPos or not desiredAng then return end

	//desiredAng = owner:EyeAngles()

	//local newPos, newAng = LocalToWorld(self.WorldPos, self.WorldAng, desiredPos, desiredAng)
	//newAng:RotateAroundAxis(newAng:Forward(),180)
	
	--print(desiredAng)
	local _, pos, ang = self:GetTrace(nil, nil, nil, true, true)
	
	if !ang or !pos or !self.fuckingfuckangle then return 0 end
	
	local mat = Matrix()
	--mat:SetTranslation(self.CloseAnimAddVec)
	--mat:SetAngles(self.CloseAnimAddAng)
	mat:Invert()

	local pos, ang = LocalToWorld(mat:GetTranslation(), mat:GetAngles(), pos, self.fuckingfuckangle)
	--local pos, ang = LocalToWorld(self.RHPos + (self.AdditionalPos + self.AdditionalPos2) + self.LocalMuzzlePos + self.WorldPos, mat:GetAngles(), self.fuckingfuckpos, self.fuckingfuckangle)

	--local pos2, ang2 = self:GetTrace(true, self.desiredPos, self.desiredAng, true)
	--
	--local lpos, lang = WorldToLocal(pos, ang, owner:EyePos(), owner:EyeAngles())
	--local lpos2, lang2 = WorldToLocal(pos2, ang2, owner:EyePos(), owner:EyeAngles())
--
	--lpos2[3] = lpos[3]
--
	--local pos, ang = LocalToWorld(lpos2, lang, owner:EyePos(), owner:EyeAngles())

	--[[if SERVER then
		local ent = tr.Entity

		if IsValid(ent) and ent:IsNPC() and ((ent:Disposition(owner) == D_LI) or (ent:Disposition(owner) == D_NU)) then
			--self:SetNWFloat("lower_weapon", CurTime() + 2)
		else
			self:SetNWFloat("lower_weapon", 0)
		end
	end--]]
	
	local _, point, dis = util.DistanceToLine(pos, pos - ang:Forward() * 70, owner:EyePos())
	
	--dis = math.ceil(dis)
	
	local tr = util.TraceLine({
		start = point,
		endpos = pos,
		filter = {self, self:GetOwner(), hg.GetCurrentCharacter(self:GetOwner()), self:GetOwner():GetNWEntity("FakeRagdollOld")},
		mask = MASK_PLAYERSOLID,
		collisiongroup = COLLISION_GROUP_PLAYER,
	})
	
	local frac = tr.Fraction
	local dist = 1 - frac
	
	if dtime and isnumber(dtime) then
		local set = math.min(dist, (self:IsPistolHoldType() and 0.71 or 0.4))
		
		self.lerpaddcloseanim = Lerp(self.lerpaddcloseanim > set and hg.lerpFrameTime(0.01, dtime) or hg.lerpFrameTime(0.0000000000001, dtime), self.lerpaddcloseanim, set)
		self.closeanimdis = dis
		self.closeanimtr = tr
	end
	
	return dist, tr
end

local vec3 = Vector(0, 0, 2)
function SWEP:AnimApply_RecoilCameraZoom()
	local vecrand = VectorRand(-0.1, 0.1)
	vecrand[3] = vec3[3]
	--vecrand[1] = vecrand[1] - 0.3
	self.Anim_RecoilCameraZoomSet = vec3
	--self.Anim_RecoilCameraZoom = LerpVector(FrameTime() * 15, self.Anim_RecoilCameraZoom, self.Anim_RecoilCameraZoomSet)
end

local function isMoving(ply)
	return ply:GetVelocity():LengthSqr() > 30*30 and ply:OnGround()
end

local function isCrouching(ply)
	return (hg.KeyDown(ply,IN_DUCK) or ply:Crouching()) and ply:OnGround()
end

local ang1 = Angle(0, -10, -20)
local ang2 = Angle(-30,-20,10)
local ang3 = Angle(0, 20, 0)
local ang4 = Angle(-30, 0, 0)
local ang5 = Angle(10, 0, 10)
local ang6 = Angle(30, 25, 18)
local ang7 = Angle(-10, -10, -10)
local ang8 = Angle(-20, 0, 0)
local ang9 = Angle(30, 0, 0)
local ang10 = Angle(35, 0, 0)
local ang11 = Angle(20, 0, 0)

local post1_ang1, post1_ang2, post1_ang3 = Angle(0, 20, 0), Angle(-18, -17, 0), Angle(18, -55, 0)

local post2_ang1, post2_ang2, post2_ang3, post2_ang4, post2_ang5, post2_ang6 = Angle(3, 15, 0),
Angle(3, 0, 0), Angle(2, -5, 0), Angle(4, -5, 0), Angle(-5, -8, 0), Angle(35, -25, 0)

hook.Add("Bones", "homigrad-lean-bone", function(ply, dtime)
	ply.weightmul = weightmul or hg.CalculateWeight(ply, 140)
	
	local mul = ply.weightmul ^ 2
	local ragdollcombat = hg.RagdollCombatInUse(ply)
	local isragdoll = IsValid(ply.FakeRagdoll) and !IsValid(ply:GetNWEntity("FakeRagdollOld"))
	local left = ((isragdoll and !ragdollcombat and hg.KeyDown(ply, IN_MOVERIGHT)) or hg.KeyDown(ply, IN_ALT2)) and not hg.KeyDown(ply, IN_ALT1)
	local right = ((isragdoll and !ragdollcombat and hg.KeyDown(ply, IN_MOVELEFT)) or hg.KeyDown(ply, IN_ALT1)) and not hg.KeyDown(ply, IN_ALT2)

	ply.lean = Lerp(
		hg.lerpFrameTime( ( left or right ) and 0.045 * ply:GetNetVar("leanSpeedMul",1) or 0.075, dtime), 
		ply.lean or 0,
		hg.IsLocal(ply) and ( (left and right and 0) or (left and 1.3) or (right and -1.3) or 0) or ply:GetNWFloat("PlayerLean", 0)
	)

	if SERVER then
		ply.takeOldLeanStamina = ply.takeOldLeanStamina or 0
		local leanStamina = math.Round(ply.lean,2)

		if ply.takeOldLeanStamina > leanStamina and leanStamina < 0.9 then
			ply.organism.stamina.subadd = 0.85 * math.max(ply.organism.stamina[1]/ply.organism.stamina.range,0.85)
		end

		if ply.takeOldLeanStamina != leanStamina then
			//ply:SetNetVar("leanSpeedMul", ply.organism.stamina[1]/ply.organism.stamina.range)
		end
		if (!ply.SetPlayerLeanCD or ply.SetPlayerLeanCD < CurTime()) and ply.lean != ply:GetNWFloat("PlayerLean",0) then
			ply:SetNWFloat("PlayerLean",ply.lean)
			ply.SetPlayerLeanCD = CurTime() + 0.15
		end

		ply.takeOldLeanStamina = leanStamina
	end

	local amt = 0.7
	local div = 0.33
	local leanspeed = 0.0001
	
	if ply.lean < -0.01 then
		local self = ply:GetActiveWeapon()
		if self.IsPistolHoldType and not self:IsPistolHoldType() then
			hg.bone.Set(ply, "r_upperarm", vecZero, ang1 * -ply.lean * amt, "lean", leanspeed, dtime)
			hg.bone.Set(ply, "spine", vecZero, ang2 * -ply.lean * amt * div, "lean", leanspeed, dtime)
			hg.bone.Set(ply, "spine1", vecZero, ang2 * -ply.lean * amt * div, "lean", leanspeed, dtime)
			hg.bone.Set(ply, "spine2", vecZero, ang2 * -ply.lean * amt * div, "lean", leanspeed, dtime)
			hg.bone.Set(ply, "head", vecZero, ang3 * -ply.lean * amt, "lean", leanspeed, dtime)
		else
			hg.bone.Set(ply, "spine", vecZero, ang4 * -ply.lean * amt * div, "lean", leanspeed, dtime)
			hg.bone.Set(ply, "spine1", vecZero, ang4 * -ply.lean * amt * div, "lean", leanspeed, dtime)
			hg.bone.Set(ply, "spine2", vecZero, ang4 * -ply.lean * amt * div, "lean", leanspeed, dtime)
			hg.bone.Set(ply, "pelvis", vecZero, ang4 * -ply.lean * amt * -div, "lean", leanspeed, dtime)
			hg.bone.Set(ply, "l_upperarm", vecZero, ang8 * -ply.lean * amt, "lean", leanspeed, dtime)
		end
	end

	if CLIENT then
		if (right or left) and not ply.leanHolding then
			if not ply.leanHolding then
				if ply.armors["torso"] ~= nil then
					ply:EmitSound("weapons/universal/uni_crawl_l_0"..math.random(6)..".wav", 40, math.random(100, 110))
				else
					ply:EmitSound("player/clothes_generic_foley_04.wav", 35, math.random(100, 110))
				end
			end
			ply.leanHolding = true
		elseif not (right or left) and ply.leanHolding then
			if ply.leanHolding then
				if ply.armors["torso"] ~= nil then
					ply:EmitSound("weapons/universal/uni_crawl_r_0"..math.random(6)..".wav", 40, math.random(90, 100))
				else
					ply:EmitSound("player/clothes_generic_foley_01.wav", 35, math.random(90, 100))
				end
			end
			ply.leanHolding = false
		end
	end
	
	if ply.lean > 0.01 then
		local self = ply:GetActiveWeapon()
		if self.IsPistolHoldType and not self:IsPistolHoldType() then
			hg.bone.Set(ply, "r_upperarm", vecZero, ang5 * ply.lean * amt, "lean", leanspeed, dtime)
			hg.bone.Set(ply, "spine", vecZero, ang6 * ply.lean * amt * div, "lean", leanspeed, dtime)
			hg.bone.Set(ply, "spine1", vecZero, ang6 * ply.lean * amt * div, "lean", leanspeed, dtime)
			hg.bone.Set(ply, "spine2", vecZero, ang6 * ply.lean * amt * div, "lean", leanspeed, dtime)
			hg.bone.Set(ply, "head", vecZero, ang9 * ply.lean * amt, "lean", leanspeed, dtime)
		else
			hg.bone.Set(ply, "spine", vecZero, ang10 * ply.lean * amt * div, "lean", leanspeed, dtime)
			hg.bone.Set(ply, "spine1", vecZero, ang10 * ply.lean * amt * div, "lean", leanspeed, dtime)
			hg.bone.Set(ply, "spine2", vecZero, ang10 * ply.lean * amt * div, "lean", leanspeed, dtime)
			hg.bone.Set(ply, "pelvis", vecZero, ang4 * ply.lean * amt * div, "lean", leanspeed, dtime)
			hg.bone.Set(ply, "r_upperarm", vecZero, ang11 * ply.lean * amt, "lean", leanspeed, dtime)
		end
	end

	--[[local wep, vel = ply:GetActiveWeapon(), ply:GetVelocity():LengthSqr()
	if IsValid(wep) and vel <= 30000 and not isragdoll then
		local post1_mul = ((ply.standposture or 0) == 1 and vel <= 1000
		and wep.GetFists and not wep:GetFists() and not ply:KeyDown(IN_DUCK) and ply:OnGround()) and 1 or 0
		hg.bone.Set(ply, "spine1", vecZero, post1_ang1 * post1_mul, "coolguy", 0.001)
		hg.bone.Set(ply, "head", vecZero, post1_ang1 * post1_mul, "coolguy", 0.001)
		hg.bone.Set(ply, "r_forearm", vecZero, post1_ang2 * post1_mul, "coolguy", 0.001)
		hg.bone.Set(ply, "l_forearm", vecZero, post1_ang3 * post1_mul, "coolguy", 0.001)

		local post2_mul = ((ply.standposture or 0) == 2 and vel <= 1000
		and (wep.GetFists and not wep:GetFists() or wep:GetClass() == "weapon_traitor_suit")
		and not ply:KeyDown(IN_DUCK) and ply:OnGround()) and 1 or 0
		hg.bone.Set(ply, "spine1", vecZero, post2_ang1 * post2_mul, "coolguy", 0.001)
		hg.bone.Set(ply, "spine", vecZero, post2_ang2 * post2_mul, "coolguy", 0.001)
		hg.bone.Set(ply, "head", vecZero, post2_ang3 * post2_mul, "coolguy", 0.001)
		hg.bone.Set(ply, "r_upperarm", vecZero, post2_ang4 * post2_mul, "coolguy", 0.001)
		hg.bone.Set(ply, "l_upperarm", vecZero, post2_ang5 * post2_mul, "coolguy", 0.001)
		hg.bone.Set(ply, "l_forearm", vecZero, post2_ang6 * post2_mul, "coolguy", 0.001)
	end--]]

	--[[
	local tbl = {
		Angle(0,0,0),
		Angle(0,-10,0),
		Angle(0,-70,0),
		Angle(0,-150,0),
		Angle(0,-150,0),
		Angle(0,-90,0),
		Angle(0,-90,0),
	}
	local tbl2 = {
		Angle(0,60,0),
		Angle(0,70,0),
		Angle(0,80,0),
		Angle(0,120,0),
		Angle(0,120,0),
		Angle(0,-40,0),
		Angle(0,-40,0),
	}
	
	hg.bone.Set(ply, "r_thigh", vecZero, tbl[math.Round((CurTime()*10)%#tbl)])
	hg.bone.Set(ply, "r_calf", vecZero, tbl2[math.Round((CurTime()*10)%#tbl2)])
	--]]
	--пинок early access ^^^
	
	if ply:IsFlagSet(FL_ANIMDUCKING) and not ply:InVehicle() and not isragdoll then
		local normaldist = 80

		local tr = {}
		tr.start = ply:GetPos() + vector_up * 5
		tr.endpos = ply:GetPos() + vector_up * normaldist
		tr.filter = {ply}
		tr.collisiongroup = COLLISION_GROUP_PLAYER
		tr = util.TraceLine(tr)

		local dist = tr.HitPos:Distance(ply:GetPos())
		local frac = math.max(1 - dist / normaldist,0)
		
		hg.bone.Set(ply, "spine1", vecZero, Angle(0, frac * (60 + (isMoving(ply) and 30 or 0)), 0), "crouch", 0.2, dtime)
		hg.bone.Set(ply, "head", vecZero, Angle(0, frac * (30 + (isMoving(ply) and 30 or 0)), 0), "crouch", 0.2, dtime)
	end
end)

function SWEP:Step_Inspect(time)
	if self.inspect == nil or self.reload ~= nil then return end
	if self:KeyDown(IN_RELOAD) or self:KeyDown(IN_ATTACK) or self:KeyDown(IN_ATTACK2) then
		self.inspect = nil
	end

	local time2 = self.inspect
	
	if time2 and time2 < time then
		self.inspect = nil
	end

	if time2 then
		local part = 1 - (time2 - time) / 5
		
		part = math.ease.InOutQuad(part)

		self:AnimationInspect(part)
	end
end

SWEP.InspectAnimLH = {
	Vector(0,0,0)
}
SWEP.InspectAnimLHAng = {
	Angle(0,0,0)
}
SWEP.InspectAnimRH = {
	Vector(0,0,0)
}
SWEP.InspectAnimRHAng = {
	Angle(0,0,0)
}
SWEP.InspectAnimWepAng = {
	Angle(0,0,0)
}

function SWEP:AnimationInspect(time)
	local wep = self--weapons.Get( self:GetClass() )
	
	local anims = wep.InspectAnimLH
	local anims2 = wep.InspectAnimLHAng
	local floortime = math.floor(time * (#anims))
	local floortime2 = math.floor(time * (#anims2))
	local lerp = time * (#anims) - floortime
	local lerp2 = time * (#anims2) - floortime2
	
	local pos1,pos2 = anims[math.Clamp(floortime,1,#anims)],anims[math.Clamp(floortime+1,1,#anims)]

	self.LHPosOffset = Lerp(lerp,pos1,pos2)
	self.LHAngOffset = Lerp(lerp2,anims2[math.Clamp(floortime2,1,#anims2)],anims2[math.Clamp(floortime2+1,1,#anims2)])

	local anims = wep.InspectAnimRH
	local anims2 = wep.InspectAnimRHAng
	local floortime = math.floor(time * (#anims))
	local floortime2 = math.floor(time * (#anims2))
	local lerp = time * (#anims) - floortime
	local lerp2 = time * (#anims2) - floortime2
	
	local pos1,pos2 = anims[math.Clamp(floortime,1,#anims)],anims[math.Clamp(floortime+1,1,#anims)]

	self.RHPosOffset = Lerp(lerp,pos1,pos2)
	self.RHAngOffset = Lerp(lerp2,anims2[math.Clamp(floortime2,1,#anims2)],anims2[math.Clamp(floortime2+1,1,#anims2)])

	local anims2 = wep.InspectAnimWepAng
	local floortime2 = math.floor(time * (#anims2))
	local lerp2 = time * (#anims2) - floortime2

	--self.WepPosOffset = Lerp(lerp,anims[math.Clamp(floortime,1,#anims)],anims[math.Clamp(floortime+1,1,#anims)])
	local ang1,ang2 = anims2[math.Clamp(floortime2,1,#anims2)],anims2[math.Clamp(floortime2+1,1,#anims2)]
	
	local oldang = -(-self.WepAngOffset)
	
	self.WepAngOffset = Lerp(lerp2,ang1,ang2) + self.angvel

	self.angvel:Add((self.WepAngOffset-oldang)/75)
	self.angvel = self.angvel * 0.99
	if CLIENT and self:GetOwner() == LocalPlayer() then
		local addang = self.WepAngOffset / 600
		addang[3] = addang[1]
		ViewPunch2(addang)
		ViewPunch(addang)
	end
end
