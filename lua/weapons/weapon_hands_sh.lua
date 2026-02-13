if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_base"
local function RagdollOwner(ent)
	return hg.RagdollOwner(ent)
end

SWEP.Category = "ZCity Other"
SWEP.Instructions = "LMB - raise fists\nRELOAD - lower fists\n\nIn the raised state:\nLMB - strike\nRMB - block\n\nIn the lowered state: RMB - raise the object, RMB+R - check the pulse (when used on someone's head or hand)\n\nWhen holding the object: RELOAD - fix the object in air, E - spin the object in the air."
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.HoldType = "normal"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/c_arms.mdl"
SWEP.UseHands = true
SWEP.AttackSlowDown = .5
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.ReachDistance = 40
SWEP.HomicideSWEP = true
SWEP.NoDrop = true
SWEP.ShockMultiplier = 1
SWEP.PainMultiplier = 1
SWEP.BreakBoneMul = 0.33
SWEP.Penetration = 1
SWEP.DamageMul = 1
SWEP.animtime = 0

SWEP.lefthandmodel = "models/weapons/gleb/w_firematch.mdl"
SWEP.offsetVec2 = Vector(4,-1.2,1)
SWEP.offsetAng2 = Angle(10,0,90)
SWEP.ModelScale2 = 1.5

SWEP.blockinganim = 0

local clawClasses = {
	["furry"] = 0.5,
	["headcrabzombie"] = 1.5
}

local function qerp(delta, a, b)
	local qdelta = -(delta ^ 2) + (delta * 2)
	qdelta = math.Clamp(qdelta, 0, 1)

	return Lerp(qdelta, a, b)
end

function SWEP:Initialize()
	self:SetNextIdle(CurTime() + 5)
	self:SetNextDown(CurTime() + 5)
	self:SetHoldType(self.HoldType)
	self:SetFists(false)
	self:SetBlocking(false)
end

function SWEP:OnRemove()
	--[[if IsValid(self.worldModel) then
		self.worldModel:Remove()
	end--]]
end

if CLIENT then
	local blocking_ang = Angle(-40,0,0)

	--[[if IsValid(modelHands) then
		modelHands:Remove()
	end--]]

	function SWEP:GetWM()
		return self.worldModel
	end

	-- Settings...

	function SWEP:DrawWorldModel()
		local owner = self:GetOwner()

		if not IsValid(self.worldModel) then
			self.worldModel = ClientsideModel(self.WorldModel)
		end

		if clawClasses[owner.PlayerClassName] and self.worldModel != "models/weapons/salat/anims/furry_fists.mdl" then
			self.worldModel:SetModel("models/weapons/salat/anims/furry_fists.mdl")
		end

		if not self:GetFists() then return end

		local WorldModel = self.worldModel

		WorldModel:SetCycle(1 - math.Clamp(self.animtime - CurTime(),0,1))

		self.blockinganim = qerp(0.05 * FrameTime() / engine.TickInterval(),self.blockinganim,self:GetBlocking() and 1 or 0)

		if (IsValid(owner)) then
			local ang = owner:EyeAngles()
			local posa, aimvec = hg.eye(owner)--hg.eyeTrace(owner)

			local pos = posa + ang:Forward() * (-14) + ang:Up() * -9 * self.blockinganim

			local ang = owner:EyeAngles()

			local _,ang = LocalToWorld(vector_origin,blocking_ang * self.blockinganim,vector_origin,ang)

			local pos, ang = self:ModelAnim(WorldModel, pos, ang)

			if clawClasses[owner.PlayerClassName] then
				pos = pos + ang:Forward() * 10
			end

			WorldModel:SetRenderOrigin(pos)
			WorldModel:SetRenderAngles(ang)
		else
			WorldModel:SetPos(self:GetPos())
			WorldModel:SetAngles(self:GetAngles())
		end

		WorldModel:SetupBones()
		--WorldModel:DrawModel()
	end
end

local host_timescale = game.GetTimeScale

local addAng = Angle()
local addPos = Vector()
//local velpunch = Vector()

local vechuy = Vector(-12, 0, 0)
local zombHandOffset = Vector(5, -2, -7)

function SWEP:ModelAnim(model, pos, ang)
	local owner = self:GetOwner()

	if !IsValid(owner) or !owner:IsPlayer() then return end

	local ent = hg.GetCurrentCharacter(owner)
	local pos, aimvec = hg.eye(owner, 60, ent)--hg.eyeTrace(owner, 60, ent)
	local eyeAng = owner:EyeAngles()

	local vel = ent:GetVelocity()
	local vellen = vel:Length()

	local vellenlerp = self.velocityAdd and self.velocityAdd:Length() or vellen

	if !pos then return end

	self.walkLerped = LerpFT(0.1, self.walkLerped or 0, (owner:InVehicle()) and 0 or vellenlerp * 200)
	self.walkTime = self.walkTime or 0

	local walk = math.Clamp(self.walkLerped / 200, 0, 1)

	self.walkTime = self.walkTime + walk * FrameTime() * 1 * game.GetTimeScale() * (owner:OnGround() and 1 or 0)

	self.velocityAdd = self.velocityAdd or Vector()
	self.velocityAddVel = self.velocityAddVel or Vector()

	self.velocityAddVel = LerpFT(0.9, self.velocityAddVel * 0.99, -vel * 0.01)
	self.velocityAddVel[3] = self.velocityAddVel[3]

	self.velocityAdd = LerpFT(0.03, self.velocityAdd, self.velocityAddVel)

	local huy = self.walkTime

	local x, y = math.cos(huy) * math.sin(huy) * walk + math.cos(CurTime() * 5) * walk * math.sin(CurTime() * 2) * 0.5, math.sin(huy) * walk * 1 + math.sin(CurTime() * 5) * walk * math.cos(CurTime() * 4) * 0.5

	x = x * 0.5
	y = y * 0.5

	if self:IsLocal() then
		addPos:Zero()
		addAng:Zero()

		addPos.z = x * 2 * vellenlerp * 0.3 - vellenlerp * 1
		addPos.y = y * 2 * vellenlerp * 0.3

		addAng.z = -x * 2// * vellenlerp * 0.3
		addAng.y = -y * 2// * vellenlerp * 0.3

		addPos.y = addPos.y - angle_difference.y * 2
		addAng.y = addAng.y + angle_difference.y * 4

		addPos.z = addPos.z + angle_difference.p * 2
		addAng.p = addAng.p + angle_difference.p * 4

		addAng.p = addAng.p + math.cos(CurTime() * 2) * 1

		//addPos.z = addPos.z + eyeAng[1] * 0.05
		addPos.x = addPos.x + eyeAng[1] * 0.05

		local veldot = self.velocityAdd:Dot(aimvec:Angle():Right())

		addAng.r = addAng.r - veldot * 5 + math.cos(CurTime() * 5) * walk * 2

		//addAng.p = addAng.p + math.cos(CurTime() * 2) * 1

		self.lastAddPos = addPos
	end


	//local inattack1 = self:GetAttackType() == 1 and math.max(self:GetLastAttack() - CurTime(),0) / self.AttackTime > 0 or false
	//local inattack2 = self:GetAttackType() == 2 and math.max(self:GetLastAttack() - CurTime(),0) / self.AttackTime > 0 or false

	//self.attackanim = LerpFT(0.1, self.attackanim, (inattack1 and 0.8 or 0) - (inattack2 and 0.3 or 0))
	//self.sprintanim = LerpFT(0.05, self.sprintanim, self:IsSprinting() and 1 or 0)

	local hpos = (self.HoldPos or vector_origin) + vechuy
	local hang = (self.HoldAng or angle_zero)

	local pos, ang = LocalToWorld(hpos + addPos, hang + addAng, pos + self.velocityAdd, eyeAng)
	if owner.PlayerClassName == "headcrabzombie" then
		self.HoldPos = zombHandOffset
		ang.x = math.Clamp(ang.x, -60, 60)
	end

	return pos, ang
end

SWEP.supportTPIK = true
SWEP.ismelee = true
function SWEP:Camera(eyePos, eyeAng, view, vellen)
	//self:SetHandPos()
	self:DrawWorldModel()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	self.walkinglerp = Lerp(hg.lerpFrameTime2(0.1),self.walkinglerp or 0, owner.InVehicle and owner:InVehicle() and 0 or hg.GetCurrentCharacter(owner):GetVelocity():LengthSqr())
	self.huytime = self.huytime or 0
	local walk = math.Clamp(self.walkinglerp / 10000,0,1)

	self.huytime = self.huytime + walk * FrameTime() * 4 * host_timescale()
	if owner:IsSprinting() then
		walk = walk * 2
	end

	local huy = self.huytime

	local x,y = math.cos(huy) * math.sin(huy) * walk * 1,math.sin(huy) * walk * 1
	eyePos = eyePos - eyeAng:Up() * walk
	eyePos = eyePos - eyeAng:Up() * x * 0.5
	eyePos = eyePos - eyeAng:Right() * y * 0.5

	view.origin = (eyePos - (angle_difference_localvec * 150) - (position_difference * 0.5))

	return view
end

SWEP.rhandik = false
SWEP.lhandik = false

if CLIENT then
	if IsValid(handcuffmodel) then
		handcuffmodel:Remove()
	end

	local lpos,lang = Vector(-3.5,0,0),Angle(0,0,-90)

	--hook.Add("PostDrawPlayerRagdoll","Drawhandcuffs", function(ply,ent)
	function hg.CuffedAnim(ent, ply)
		if ply:IsRagdoll() or ent:IsRagdoll() then return end
		if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() or not ply:GetNetVar("handcuffed",false) then return end

		local rh,lh = ply:LookupBone("ValveBiped.Bip01_R_Hand"),ply:LookupBone("ValveBiped.Bip01_L_Hand")
		local rhmat,lhmat = ply:GetBoneMatrix(rh),ply:GetBoneMatrix(lh)

		if not rhmat then return end

		handcuffmodel = IsValid(handcuffmodel) and handcuffmodel or ClientsideModel( "models/weapons/spy/w_handcuffs.mdl" )
		handcuffmodel:SetNoDraw( true )

		local model = handcuffmodel

		model:SetModelScale(1, 0)

		local angle = (rhmat:GetTranslation() - lhmat:GetTranslation()):Angle()
		angle[3] = -rhmat:GetAngles()[1]
		local pos,ang = LocalToWorld(lpos,lang,rhmat:GetTranslation(),angle)

		model:SetPos(pos)
		model:SetAngles(ang)

		model:SetRenderOrigin(pos)
		model:SetRenderAngles(ang)
		model:SetupBones()
		model:DrawModel()
		--model:SetRenderOrigin()
		--model:SetRenderAngles()
		return
	end
	--end)
end

local ang1 = Angle(90,-15,180)
local ang2 = Angle(90,15,0)

local ang4 = Angle(0,0,180)
local ang5 = Angle(0,0,0)

local ang3 = Angle(0,0,180)
local clamp = math.Clamp

function hg.handcuffedhands(ply)
	local posi, ang = ply:GetBonePosition(0)
	local dtime = SysTime() - (ply.dtimehandcuffs or SysTime())
	ply.crouchinglerp = Lerp(hg.lerpFrameTime2(0.1,dtime),ply.crouchinglerp or 0, (ply:IsFlagSet(FL_ANIMDUCKING)) and 1 or 0)
	ply.dtimehandcuffs = SysTime()
	ang1[1] = 90 - 50 * ply.crouchinglerp
	ang2[1] = 90 - 50 * ply.crouchinglerp

	local pos = posi + ang:Up() * (6 + 12 * ply.crouchinglerp) + ang:Right() * (2 + -14 * ply.crouchinglerp) + ang:Forward() * 4 * ply.crouchinglerp
	local pointpos = hg.torsoTrace(ply,20)
	--[[if hg.KeyDown(ply,IN_ATTACK2) then
		pos = pointpos.HitPos
		ply.lerphandpos = Lerp(hg.lerpFrameTime2(0.1,dtime), ply.lerphandpos or Vector(0,0,0), pos)
		hg.DragHandsToPos(ply,ply:GetActiveWeapon(),ply.lerphandpos,true,4.5,pointpos.Normal,ang3,angle_zero)
	else
		ply.lerphandpos = Lerp(hg.lerpFrameTime2(0.1,dtime), ply.lerphandpos or Vector(0,0,0), pos)
		hg.DragHandsToPos(ply,ply:GetActiveWeapon(),ply.lerphandpos,true,4.5,ang:Up(),ang1,ang2)
	end--]]
	hg.DragHandsToPos(ply, ply:GetActiveWeapon(), pos, true, 3.5, ang:Up(), ang1, ang2)
end

SWEP.KnuckleModel = "models/mosi/fallout4/props/weapons/melee/knuckles.mdl"
SWEP.offsetVec = Vector(2.2, -0.5, 0)
SWEP.offsetAng = Angle(0, 90, 90)
SWEP.idleVec = Vector(4.5, -2, -0.2)
SWEP.idleAng = Angle(0, 0, -80)

local blockingR = Vector()
local blockingL = Vector()
local vecBlockingR = Vector(-2, 3, -2)
local vecBlockingL = Vector(-2, -3, 4)

local vecIdleR = Vector(0, -1, 2)
local vecIdleL = Vector(0, 1, 0.5)

local ang180, ang1, ang2 = Angle(0,180,0), Angle(-110,-90,0), Angle(-70,-90,0)
function SWEP:SetHandPos(noset)
	local ply = self:GetOwner()
	if CLIENT and self.IsLocal and not self:IsLocal() and IsValid(ply) and ply.PlayerClassName == "headcrabzombie" and not IsValid(ply:GetNetVar("carryent")) then return end

	if not IsValid(ply) or not IsValid(self.worldModel) then return end
	if IsValid(ply) and (not ply.shouldTransmit or ply.NotSeen) then return end
	-- ply:SetupBones()

	local ent = self:GetNWEntity("carryent")
	self.rhandik = (self:GetFists()) or (IsValid(ent) and twohands)
	self.lhandik = (self:GetFists() and hg.CanUseLeftHand(ply)) or IsValid(ent)

	local bones2 = hg.TPIKBonesOther

	local ply_spine_index = ply:LookupBone("ValveBiped.Bip01_Spine4")
	if !ply_spine_index then return end
	local ply_spine_matrix = ply:GetBoneMatrix(ply_spine_index)
	if !ply_spine_matrix then return end
	local wmpos = ply_spine_matrix:GetTranslation()

	local wm = self:GetWM()
	if !IsValid(wm) then return end

	local inv = ply:GetNetVar("Inventory",{})
	local havekastet = inv["Weapons"] and inv["Weapons"]["hg_brassknuckles"]

	if havekastet then
		self.model = IsValid(self.model) and self.model or ClientsideModel(self.KnuckleModel)
		self.model:SetNoDraw(true)
	end

	if ply:GetNetVar("handcuffed",false) then
		hg.handcuffedhands(ply)

		return
	end

	local break_data = ply.Ability_NeckBreak

	if(break_data and IsValid(break_data.Victim))then
		local victim = break_data.Victim
		local head, anga = victim:GetBonePosition(victim:LookupBone("ValveBiped.Bip01_Head1"))
		head = head + anga:Right() * -3 + anga:Forward() * 2 - anga:Up() * break_data.Progress / 40
		local ang = victim:EyeAngles()

		ang[2] = ang[2] - break_data.Progress / 5

		hg.DragHandsToPos(ply, ply:GetActiveWeapon(), head, true, 2, ang:Forward(), ang4, ang5)
	end

	local ang = ply:EyeAngles()

	local rhmat, lhmat = ply:GetBoneMatrix(ply:LookupBone("ValveBiped.Bip01_R_Hand")), ply:GetBoneMatrix(ply:LookupBone("ValveBiped.Bip01_L_Hand"))

	ply.rhold = rhmat
	ply.lhold = lhmat

	if self:GetFists() then
		local bones = hg.TPIKBonesRH

		local lastaddpos = self:IsLocal() and self.lastAddPos or vector_origin
		local posadd, _ = LocalToWorld(lastaddpos, angle_zero, vector_origin, ply:EyeAngles())
		//local posadd = self:IsLocal() and self.lastAddPos and -(-self.lastAddPos) or -(-vector_origin)

		local vecR = vector_origin
		if ply.PlayerClassName == "headcrabzombie" then
			vecR = vecIdleR
		end

		self.blockingR = LerpFT(0.1, self.blockingR or vecR, (self:GetBlocking() and vecBlockingR or vecR))
		local blocking = -(-self.blockingR)
		blocking:Rotate(ang)

		if self.rhandik then
			for _, bone in ipairs(bones) do
				local wm_boneindex = wm:LookupBone(bone)
				if !wm_boneindex then continue end
				local wm_bonematrix = wm:GetBoneMatrix(wm_boneindex)
				if !wm_bonematrix then continue end

				local ply_boneindex = ply:LookupBone(bone)
				if !ply_boneindex then continue end
				local ply_bonematrix = ply:GetBoneMatrix(ply_boneindex)
				if !ply_bonematrix then continue end

				local bonepos = wm_bonematrix:GetTranslation()
				local boneang = wm_bonematrix:GetAngles()

				bonepos.x = clamp(bonepos.x, wmpos.x - 38, wmpos.x + 38) -- clamping if something gone wrong so no stretching (or animator is fleshy)
				bonepos.y = clamp(bonepos.y, wmpos.y - 38, wmpos.y + 38)
				bonepos.z = clamp(bonepos.z, wmpos.z - 38, wmpos.z + 38)

				ply_bonematrix:SetTranslation(bonepos + posadd * -0.2 - ang:Right() * 2 + blocking)
				ply_bonematrix:SetAngles(boneang)

				ply:SetBoneMatrix(ply_boneindex, ply_bonematrix)
				--ply:SetBonePosition(ply_boneindex, bonepos, boneang)
			end
		end

		local bones = hg.TPIKBonesLH

		posadd:Rotate(Angle(0,0,0))

		local vecL = vector_origin
		if ply.PlayerClassName == "headcrabzombie" then
			vecL = vecIdleL
		end

		self.blockingL = LerpFT(0.1, self.blockingL or vecL, (self:GetBlocking() and vecBlockingL or vecL))
		local blocking = -(-self.blockingL)

		blocking:Rotate(ang)

		if self.lhandik then
			for _, bone in ipairs(bones) do
				local wm_boneindex = wm:LookupBone(bone)
				if !wm_boneindex then continue end
				local wm_bonematrix = wm:GetBoneMatrix(wm_boneindex)
				if !wm_bonematrix then continue end

				local ply_boneindex = ply:LookupBone(bone)
				if !ply_boneindex then continue end
				local ply_bonematrix = ply:GetBoneMatrix(ply_boneindex)
				if !ply_bonematrix then continue end

				local bonepos = wm_bonematrix:GetTranslation()
				local boneang = wm_bonematrix:GetAngles()

				bonepos.x = clamp(bonepos.x, wmpos.x - 38, wmpos.x + 38) -- clamping if something gone wrong so no stretching (or animator is fleshy)
				bonepos.y = clamp(bonepos.y, wmpos.y - 38, wmpos.y + 38)
				bonepos.z = clamp(bonepos.z, wmpos.z - 38, wmpos.z + 38)

				ply_bonematrix:SetTranslation(bonepos + posadd * -0.7 + ang:Right() * 2 + blocking)
				ply_bonematrix:SetAngles(boneang)

				ply:SetBoneMatrix(ply_boneindex, ply_bonematrix)
				--ply:SetBonePosition(ply_boneindex, bonepos, boneang)
			end
		end
	end

	if IsValid(ply) and havekastet and not IsValid(ply:GetNetVar("carryent")) then
		local offsetVec = self:GetFists() and self.offsetVec or self.idleVec
		local offsetAng = self:GetFists() and self.offsetAng or self.idleAng
		local boneid = ply:LookupBone("ValveBiped.Bip01_R_Hand")
		if not boneid then return end
		local matrix = ply:GetBoneMatrix(boneid)
		if not matrix then return end
		local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())
		local kastet = self.model
		kastet:SetRenderOrigin(newPos)
		kastet:SetRenderAngles(newAng)
		kastet:SetPos(newPos)
		kastet:SetAngles(newAng)
		kastet:SetupBones()
		kastet:DrawModel()
		kastet:SetModelScale(0.9) -- с новыми руками можно будет 1 оставить
	end

	hg.DragHands(self:GetOwner(), self)

	if true then return end
	if self:GetFists() or self:GetBlocking() or IsValid(ply:GetNetVar("carryent")) then return end

	local wmpos2 = ply_spine_matrix:GetTranslation() - ply:EyeAngles():Right() * -5
	local tr2 = {}
	tr2.start = wmpos2
	tr2.endpos = wmpos2 + ply:GetAimVector() * 30
	tr2.filter = ply
	local trace2 = util.TraceLine(tr2)
	if IsValid(ply:GetNetVar("carryent2")) and trace2.Entity == ply:GetNetVar("carryent2") then return end

	if trace2.Hit and not (trace2.Entity:IsPlayer() or trace2.Entity:IsNPC()) then -- freaky
		-- hg.DragRightHand(ply, self, trace2.HitPos - ply:GetAimVector() * 5, ply:GetAimVector(), (trace2.Entity:IsWorld() and Lerp(1, trace2.HitNormal:Angle(), ply:EyeAngles() + ang180) or ply:EyeAngles() + ang180) + ang2 - ply:EyeAngles())
	end

	local wmpos1 = ply_spine_matrix:GetTranslation() - ply:EyeAngles():Right() * 5
	local tr1 = {}
	tr1.start = wmpos1
	tr1.endpos = wmpos1 + ply:GetAimVector() * 30
	tr1.filter = ply
	local trace = util.TraceLine(tr1)
	if trace.Entity:IsPlayer() or trace.Entity:IsNPC() then return end -- freaky

	if trace.Hit and not trace2.Hit and not IsValid(ply:GetNetVar("carryent2")) then
		-- hg.DragLeftHand(ply, self, trace.HitPos - ply:GetAimVector() * 5, ply:GetAimVector(), (trace.Entity:IsWorld() and Lerp(1, trace.HitNormal:Angle(), ply:EyeAngles() + ang180) or ply:EyeAngles() + ang180) + ang1 - ply:EyeAngles())
	end
end

function SWEP:IsLocal()
	if SERVER then return end
	return not game.SinglePlayer() and CLIENT and self:GetOwner() == LocalPlayer() and LocalPlayer() == GetViewEntity()
end

if SERVER then
	SWEP.Weight = 0
	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom = false
else
	SWEP.PrintName = "Hands"
	SWEP.Slot = 0
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
	SWEP.ViewModelFOV = 45
	SWEP.BounceWeaponIcon = false
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_hands")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_hands.png"
	local colWhite = Color(255, 255, 255, 255)
	local colGray = Color(200, 200, 200, 200)
	local lerpthing = 1
	local lerpalpha = 0
	local lerpalpha2 = 0
	local colwhite = Color(0, 0, 0, 0)
	local colred = Color(122, 0, 0, 0)

	function SWEP:DrawHUD()
		local owner = LocalPlayer()

		if GetViewEntity() ~= owner then return end
		if owner:InVehicle() then return end
		local Tr = hg.eyeTrace(owner, self.ReachDistance)
		if not Tr then return end
		local Size = math.max(math.min(1 - (Tr and Tr.Fraction or 0), 1), 0.1)
		local x, y = Tr.HitPos:ToScreen().x, Tr.HitPos:ToScreen().y

		lerpthing = Lerp(0.1, lerpthing, Tr.Hit and not self:GetFists() and self:CanPickup(Tr.Entity) and 1 or 0)
		colWhite.a = 255 * Size * lerpthing
		surface.SetDrawColor(colWhite)
		surface.DrawRect(x - 25 * lerpthing * 0.1, y - 2.5, 50 * lerpthing * 0.1, 5)
		surface.DrawRect(x - 2.5, y - 25 * lerpthing * 0.1, 5, 50 * lerpthing * 0.1)

		do return end // mannytko stupid UwU

		local ent = IsValid(Tr.Entity) and Tr.Entity.organism and Tr.Entity or owner
		if ent.organism then
			if Tr.Entity == ent then ent.is_lookedat = hg.KeyDown(owner, IN_RELOAD) end
			lerpalpha = LerpFT(0.1, lerpalpha, hg.KeyDown(owner, IN_RELOAD) and 255 + 2000 or 0)
			local lerpalpha = lerpalpha - 2000
			local org = ent.organism
			local add_x = 0
			local scrw, scrh = ScrW(), ScrH()
			local w, h = ScreenScale(30), ScreenScale(30)
			local add = ScreenScale(2)
			local posx, posy = scrw * 0.05, scrh * 0.95
			colwhite.a = lerpalpha / 1.1
			colred.a = lerpalpha / 1.1

			draw.RoundedBox(0, posx - 4, posy - h * 1.5 - 4, w * 10 + add * 10 + 8, 1.5 * h + 8, colred)
			draw.RoundedBox(0, posx, posy - h * 1.5, w * 10 + add * 10, 1.5 * h, colwhite)

			surface.SetFont("HomigradFontLarge")
			surface.SetTextColor(255, 255, 255, lerpalpha)
			local txt = "Afflictions shown for "..ent:GetPlayerName()..":"
			local w1, h1 = surface.GetTextSize(txt)
			surface.SetTextPos(scrw * 0.05, scrh * 0.95 - h - h1)
			surface.DrawText(txt)

			if org.blood and org.blood < 4000 then
				hg.DrawAffliction(posx + add_x, posy - h, w, h, (4000 - org.blood) / 4000, hg.afflictions.pale, lerpalpha, "Pale skin")

				add_x = add_x + w + add
			end

			if org.bleed and org.bleed > 0.1 then
				hg.DrawAffliction(posx + add_x, posy - h, w, h, math.min(org.bleed / 10, 1), hg.afflictions.bleeding, lerpalpha, "Bleeding")

				add_x = add_x + w + add
			end

			if org.disorientation and org.disorientation > 0.1 and ent == owner then
				hg.DrawAffliction(posx + add_x, posy - h, w, h, math.min(org.disorientation / 2, 1), hg.afflictions.concussion, lerpalpha, "Concussion")

				add_x = add_x + w + add
			end

			if org.rleg and org.rleg > 0 then
				hg.DrawAffliction(posx + add_x, posy - h, w, h, org.rleg, org.rleg > 0.999 and hg.afflictions.lfracture or hg.afflictions.lblunt, lerpalpha, org.rleg > 0.999 and "Right leg fracture" or "Right leg blunt trauma")

				add_x = add_x + w + add
			end

			if org.lleg and org.lleg > 0 then
				hg.DrawAffliction(posx + add_x, posy - h, w, h, org.lleg, org.lleg > 0.999 and hg.afflictions.lfracture or hg.afflictions.lblunt, lerpalpha, org.lleg > 0.999 and "Left leg fracture" or "Left leg blunt trauma")

				add_x = add_x + w + add
			end

			if org.rarm and org.rarm > 0 then
				hg.DrawAffliction(posx + add_x, posy - h, w, h, org.rarm, org.rarm > 0.999 and hg.afflictions.afracture or hg.afflictions.ablunt, lerpalpha, org.rarm > 0.999 and "Right arm fracture" or "Right arm blunt trauma")

				add_x = add_x + w + add
			end

			if org.larm and org.larm > 0 then
				hg.DrawAffliction(posx + add_x, posy - h, w, h, org.larm, org.larm > 0.999 and hg.afflictions.afracture or hg.afflictions.ablunt, lerpalpha, org.larm > 0.999 and "Left arm fracture" or "Left arm blunt trauma")

				add_x = add_x + w + add
			end

			if org.pain and org.pain > 20 and not org.otrub then
				hg.DrawAffliction(posx + add_x, posy - h, w, h, (org.pain - 20) / 30, hg.afflictions.pain, lerpalpha, "Pain")

				add_x = add_x + w + add
			end

			if org.o2 and org.o2[1] < 5 then
				hg.DrawAffliction(posx + add_x, posy - h, w, h, (5 - org.o2[1]) / 5, hg.afflictions.lung_failure, lerpalpha, "Lung failure")

				add_x = add_x + w + add
			end

			--hg.DrawAffliction(scrw * 0.05 + add_x, scrh * 0.95 - h, w, h, 1, 3, 255)

			if add_x == 0 then
				surface.SetFont("HomigradFontLarge")
				surface.SetTextColor(255, 255, 255, lerpalpha)
				surface.SetTextPos(scrw * 0.05, scrh * 0.95 - h)
				surface.DrawText("No afflictions.")
			end
		end
	end
end

local function WhomILookinAt(ply, cone, dist)
	local CreatureTr, ObjTr, OtherTr
	for i = 1, 150 * cone do
		local Tr = hg.eyeTrace(ply, dist)
		if Tr.Hit and not Tr.HitSky and Tr.Entity then
			local Ent, Class = Tr.Entity, Tr.Entity:GetClass()
			if Ent:IsPlayer() or Ent:IsNPC() then
				CreatureTr = Tr
			elseif (Class == "prop_physics") or (Class == "prop_physics_multiplayer") or (Class == "prop_ragdoll") then
				ObjTr = Tr
			else
				OtherTr = Tr
			end
		end
	end

	if CreatureTr then return CreatureTr.Entity, CreatureTr.HitPos, CreatureTr.HitNormal, CreatureTr.PhysicsBone, CreatureTr end
	if ObjTr then return ObjTr.Entity, ObjTr.HitPos, ObjTr.HitNormal, ObjTr.PhysicsBone, ObjTr end
	if OtherTr then return OtherTr.Entity, OtherTr.HitPos, OtherTr.HitNormal, OtherTr.PhysicsBone, OtherTr end

	return
end


function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "NextIdle")
	self:NetworkVar("Bool", 2, "Fists")
	self:NetworkVar("Float", 1, "NextDown")
	self:NetworkVar("Bool", 3, "Blocking")
	self:NetworkVar("Bool", 4, "IsCarrying")
	self:NetworkVar("Bool", 5, "Blocking")
	self:NetworkVar("Float", 6, "LastBlocked")
	self:NetworkVar("Float", 7, "StartedBlocking")
end

function SWEP:Deploy()
	if not IsFirstTimePredicted() then
		self:DoBFSAnimation("fists_draw",1)
		local owner = self:GetOwner()
		if not IsValid(owner:GetViewModel()) then
			owner:GetViewModel():SetPlaybackRate(.1)
		end
		return true
	end

	self:SetNextPrimaryFire(CurTime() + .5)
	self:SetFists(false)
	self:SetNextDown(CurTime())
	self:DoBFSAnimation("fists_draw",1)
	return true
end

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:CanSecondaryAttack()
	return true
end

local pickupWhiteList = {
	["prop_ragdoll"] = true,
	["prop_physics"] = true,
	["prop_physics_multiplayer"] = true
}

function SWEP:CanPickup(ent)
	if ent:IsNPC() then return false end
	if ent:IsPlayer() then return false end
	if ent:IsWorld() then return false end
	local class = ent:GetClass()
	if pickupWhiteList[class] then return true end
	if CLIENT then return true end
	if IsValid(ent:GetPhysicsObject()) then return true end
	return false
end

local trMins, trMaxs = Vector(-5, -5, -5), Vector(5, 5, 5)
local trMinsClaws, trMaxsClaws = Vector(-8, -8, -8), Vector(8, 8, 8)
function SWEP:SecondaryAttack()
	local owner = self:GetOwner()
	if owner:InVehicle() then return end
	if not IsFirstTimePredicted() then return end
	if self:GetFists() and owner.PlayerClassName == "sc_infiltrator" then
		self:PrimaryAttack(true)
	end

	if self:GetFists() --[[and owner.PlayerClassName ~= "headcrabzombie"]] then return end
	--[[if self:GetFists() and owner.PlayerClassName == "headcrabzombie" then
		self:SetFists(false)
	end--]]
	if owner:GetNetVar("handcuffed",false) then return end

	if SERVER then
		self:SetCarrying()
		local ply = owner
		local pos = hg.eye(ply)
		local tr = util.QuickTrace(pos, owner:GetAimVector() * self.ReachDistance, {owner})

		if clawClasses[ply.PlayerClassName] then
			tr = util.TraceHull({
				start = pos,
				endpos = pos + owner:GetAimVector() * self.ReachDistance,
				filter = {ply, hg.GetCurrentCharacter(ply)},
				mins = trMinsClaws,
				maxs = trMaxsClaws,
			})
		else
			tr = util.TraceHull({
				start = pos,
				endpos = pos + owner:GetAimVector() * self.ReachDistance,
				filter = {ply, hg.GetCurrentCharacter(ply)},
				mins = trMins,
				maxs = trMaxs,
			})
		end

		--if (IsValid(tr.Entity) or game.GetWorld() == tr.Entity) and self:CanPickup(tr.Entity) and not tr.Entity:IsPlayer() then
		if (IsValid(tr.Entity)) and self:CanPickup(tr.Entity) and not tr.Entity:IsPlayer() then
			local Dist = (select(1, hg.eye(owner)) - tr.HitPos):Length()
			--if Dist < self.ReachDistance then
				sound.Play("Flesh.ImpactSoft", owner:GetShootPos(), 65, math.random(90, 110))
				self:SetCarrying(tr.Entity, tr.PhysicsBone, tr.HitPos, Dist)
				tr.Entity.Touched = true
				self:ApplyForce()
			--end
		elseif IsValid(tr.Entity) and tr.Entity:IsPlayer() then
			local Dist = (select(1, hg.eye(owner)) - tr.HitPos):Length()
			if Dist < self.ReachDistance then
				sound.Play("Flesh.ImpactSoft", owner:GetShootPos(), 65, math.random(90, 110))
				owner:SetVelocity(owner:GetAimVector() * 20)
				tr.Entity:SetVelocity((owner:KeyDown(IN_SPEED) and 1 or -1) * owner:GetAimVector() * 50)
				self:SetNextSecondaryFire(CurTime() + .25)
				if owner.organism.superfighter or owner.PlayerClassName == "sc_infiltrator" or (clawClasses[owner.PlayerClassName] and !(tr.Entity.PlayerClassName == "furry" or (tr.Entity.IsBerserk and tr.Entity:IsBerserk()))) or owner:IsBerserk() then
					hg.LightStunPlayer(tr.Entity, 3)
					timer.Simple(0,function()
						local rag = hg.GetCurrentCharacter(tr.Entity)
						if IsValid(rag) and rag ~= tr.Entity then
							self:SetCarrying(rag, tr.PhysicsBone, tr.HitPos, Dist)
						end
					end)
				end
			end
		end
	end
end

SWEP.Checking = 0

-- function SWEP:AdjustMouseSensitivity()
-- 	local owner = self:GetOwner()
-- 	local ent = owner:GetNetVar("carryent", nil)
-- 	if IsValid(ent) and ent:IsRagdoll() and owner.PlayerClassName ~= "sc_infiltrator" and owner.PlayerClassName ~= "superfighter" then
-- 		local entPos = ent:GetPos()
-- 		local vecPos = owner:GetAimVector()

-- 		local diff = entPos - owner:GetShootPos()

-- 		local dot = vecPos:Dot( diff )/ diff:Length()
-- 		return math.max(dot-0.5,0.01)
-- 	end
-- end -- nope

function SWEP:ApplyForce()
	local ply = self:GetOwner()
	local target = self:GetOwner():GetAimVector() * self.CarryDist + select(1, hg.eye(ply))
	if not IsValid(self.CarryEnt) then return end
	local phys = self.CarryEnt:GetPhysicsObjectNum(self.CarryBone)

	if ply.organism and ply.organism.rarmamputated and ply:IsTyping() then
		self:SetCarrying()

		return
	end
	
	if IsValid(phys) then
		local TargetPos = phys:GetPos()

		if self.CarryEnt.poisoned then
			if ply.organism then
				ply.organism.poison2 = CurTime()
				self.CarryEnt.poisoned = nil
			end
		end

		if self.CarryEnt.organism and ((ply.sendTimeOrg or 0) < CurTime()) then
			ply.sendTimeOrg = CurTime() + 0.5

			//hg.send_organism(self.CarryEnt.organism, ply)
		end

		if self.CarryPos then
			if self.CarryEnt:IsRagdoll() then
				TargetPos = LocalToWorld(self.CarryPos, angle_zero, phys:GetPos(), phys:GetAngles())
			else
				TargetPos = self.CarryEnt:LocalToWorld(self.CarryPos)
			end
		end

		local vec = target - TargetPos
		local len, mul = vec:Length(), phys:GetMass()

		vec:Normalize()

		if (ply.organism and ply.organism.superfighter) then
			mul = mul * 5
		end

		if (ply.organism and ply:IsBerserk()) then
			mul = mul * (1 + ply.organism.berserk / 5)
		end

		local avec = vec * len * 8 - phys:GetVelocity()

		local Force = avec * mul
		local ForceMagnitude = math.min(Force:Length(), 3000) * (1 / math.max(phys:GetVelocity():Dot(vec) / 25, 1))

		Force = Force:GetNormalized() * ForceMagnitude

		if len > 100 then
			self:SetCarrying()
			return
		end

		phys:Wake()
		self.CarryEnt:SetPhysicsAttacker(ply, 15)

		if SERVER then
			if self.CarryEnt.welds then
				for i, weld in pairs(self.CarryEnt.welds) do
					if IsValid(weld) then weld:Remove() end
				end
				self.CarryEnt.welds = nil
			end
			if (ply:GetGroundEntity() == self.CarryEnt) or (ply:GetEntityInUse() == self.CarryEnt) or IsValid(ply.FakeRagdoll) or self.CarryEnt:IsPlayerHolding() then
				self:SetCarrying()
				return
			end
		end

		if self.CarryEnt:GetClass() == "ent_hg_cyanide_canister" then
			ply.Guilt = math.max(ply.Guilt, 5)
		end

		if self.CarryEnt:GetClass() == "prop_ragdoll" then
			local ply2 = RagdollOwner(self.CarryEnt) or self.CarryEnt
			local bone = self.CarryEnt:GetBoneName(self.CarryEnt:TranslatePhysBoneToBone(self.CarryBone))

			if ply:KeyPressed(IN_RELOAD) then
				if not ply2.noHead and ply2.organism then

					if ply2.organism.CantCheckPulse then
						--ply:ChatPrint("The armor is too thick to feel the pulse.")
					elseif ((bone == "ValveBiped.Bip01_L_Hand") or (bone == "ValveBiped.Bip01_R_Hand") or (bone == "ValveBiped.Bip01_Head1")) then
						local org = ply2.organism

						if org.heartstop then
							--ply:ChatPrint("No pulse.")
						else
							--ply:ChatPrint(org.pulse < 20 and "Barely can feel the pulse." or (org.pulse <= 50 and "Low pulse.") or (org.pulse <= 90 and "Normal pulse.") or "High pulse.")
						end

						if (org.last_heartbeat + 60) > CurTime() then
							ply:ChatPrint("The body is still warm.")
						else
							ply:ChatPrint((org.last_heartbeat + 180) < CurTime() and "The body has been here for awhile." or "The body is slightly warm")
						end

						if org.blood < 3500 then
							//if org.blood < 1000 then
								//ply:ChatPrint("The skin looks almost white.")
							//else
								ply:ChatPrint("The skin is pale.")
							//end
						end

						if org.bleed > 0 then
							ply:ChatPrint("The body is bleeding "..((org.bleed > 10 and "profusely.") or (org.bleed > 5 and "moderately.") or "slightly."))
						end

						//org.bulletwounds = 0
						//org.stabwounds = 0
						//org.slashwounds = 0
						//org.bruises = 0
						//org.burns = 0
						//org.explosionwounds = 0

						if org.bulletwounds > 0 then
							ply:ChatPrint("You notice "..org.bulletwounds.." bullet wounds on this body.")
						end

						if org.stabwounds > 0 then
							ply:ChatPrint("You notice "..org.stabwounds.." stab wounds on this body.")//28 STAB WOUNDS. YOU WOULDNT LEAVE HIM A CHANCE, HUH?
						end

						if org.slashwounds > 0 then
							ply:ChatPrint("You notice "..org.slashwounds.." slashes on this body.")
						end

						if org.bruises > 0 then
							ply:ChatPrint("You notice "..org.bruises.." bruises on this body.")
						end

						if org.burns > 0 then
							ply:ChatPrint("The body was burned.")
						end

						if org.explosionwounds > 0 then
							ply:ChatPrint("The body appears to have blast trauma.")
						end

						if (bone == "ValveBiped.Bip01_Head1") then
							if (org.o2.curregen == 0 or not org.alive or org.holdingbreath) then
								--ply:ChatPrint("Not breathing.")
							else
								--ply:ChatPrint("Breathing.")
							end

							--ply:ChatPrint(org.otrub and "No reaction." or "Reaction present.")

							if org.isPly and not org.otrub then
								org.owner:ChatPrint("You were checked for reaction.")
							end
						end
					end

					self.Checking = math.min(self.Checking + FrameTime() * 2, 10)
				else
					ply:Notify("I dont think I need to check their vitals.", 10)
				end
			end
		end

		if SERVER then
			local ply2 = self.CarryEnt
			local org = ply2.organism
			if ply:KeyDown(IN_ATTACK) and !ply.organism.superfighter and !(org and ply.PlayerClassName == "furry" and org.owner.PlayerClassName != "furry") and !ply:IsBerserk() then
				local bone = self.CarryEnt:GetBoneName(self.CarryEnt:TranslatePhysBoneToBone(self.CarryBone))

				local tr = {}
				tr.start = TargetPos
				tr.endpos = TargetPos - vector_up * 32
				tr.mask = MASK_SOLID
				tr.filter = {self.CarryEnt, self, ply}
				local trace = util.TraceLine(tr)
				
				if bone != "ValveBiped.Bip01_Spine2" or !trace.Hit then
					phys:ApplyForceCenter(ply:GetAimVector() * math.min(5000, phys:GetMass() * 800))
					self:SetCarrying()
				end

				if org and bone == "ValveBiped.Bip01_Spine2" and trace.Hit then
					if self.firstTimePrint then
						if not ply2.noHead then
							ply:ChatPrint("You are beginning to perform CPR.")
						else
							ply:Notify("I dont think CPR would help here...", 10)
						end
					end

					self.firstTimePrint = false
					if (self.CPRThink or 0) < CurTime() then
						self.CPRThink = CurTime() + (1 / 120) * 60
						if org.alive then
							//org.o2[1] = math.min(org.o2[1] + hg.organism.OxygenateBlood(org) * 2 * (ply.Profession == "doctor" and 2 or 1), org.o2.range)
							org.pulse = math.min(org.pulse + 5 * (ply.Profession == "doctor" and 2 or 1),70)
							org.CO = math.Approach(org.CO, 0, (ply.Profession == "doctor" and 2 or 1))
							org.COregen = math.Approach(org.COregen, 0, (ply.Profession == "doctor" and 2 or 1))

							if math.random(3) == 1 then
								org.lungsfunction = true
							end

							if math.random(50) == 1 and (ply.Profession != "doctor") then
								local dmginfo = DamageInfo()
								dmginfo:SetDamageType(DMG_CRUSH)
								dmginfo:SetInflictor(self)
								hg.organism.input_list.chest(org, 1, 5, dmginfo)
							end

							if org.pulse > 15 then org.heartstop = false end
						end

						phys:ApplyForceCenter(-vector_up * 6000)

						--self.CarryEnt:EmitSound("physics/body/body_medium_impact_soft" .. tostring(math.random(7)) .. ".wav")
					end
				end
			else
				self.firstTimePrint = true
				self.firstTimePrint2 = true
			end

			if ply:KeyDown(IN_ATTACK) and ply.PlayerClassName == "furry" and org ~= nil and org.alive and org.owner.PlayerClassName != "furry" and !(org.owner.IsBerserk and org.owner:IsBerserk()) then
				org.assimilated = math.Approach(org.assimilated, 1, FrameTime() / 6)
				ply:SetLocalVar("assimilation", org.assimilated)

				hg.LightStunPlayer(org.owner, 1)

				//phys:ApplyForceCenter(ply:GetAimVector() * 40000 * self.Penetration)
				//self:SetCarrying()
			end

			if ply:KeyDown(IN_ATTACK) and (ply.organism.superfighter or ply:IsBerserk()) then
				phys:ApplyForceCenter(ply:GetAimVector() * 40000 * self.Penetration * (1 + ply.organism.berserk / 10))
				self:SetCarrying()
			end
		end

		if self.CarryPos then
			phys:ApplyForceOffset(Force, TargetPos)
		else
			phys:ApplyForceCenter(Force)
		end

		--[[if IsValid(self.CarryEnt) and self.CarryBone then
			hg.ShadowControl(self.CarryEnt, self.CarryBone, 0.1, angle_zero, 0, 0, target, 60, 40)
		end]]

		if ply:KeyDown(IN_USE) then
			SetAng = SetAng or ply:EyeAngles()
			local commands = ply:GetCurrentCommand()
			local x, y = commands:GetMouseX(), commands:GetMouseY()
			if IsValid(self.CarryEnt) and self.CarryEnt:IsRagdoll() then
				rotate = Vector(0, -x, -y) / 6
			else
				rotate = Vector(0, -x, -y) / 4
			end

			//phys:AddAngleVelocity(rotate * phys:GetMass() / 10)
		end

		phys:ApplyForceCenter(Vector(0, 0, mul))
		phys:AddAngleVelocity(-phys:GetAngleVelocity() / 10)
	end
end

function SWEP:GetCarrying()
	return self.CarryEnt
end

function SWEP:SetCarrying(ent, bone, pos, dist)
	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	if IsValid(ent) or game.GetWorld() == ent then
		self.CarryEnt = ent
		self.CarryBone = bone
		self.CarryDist = dist

		local phys = self.CarryEnt:GetPhysicsObjectNum(self.CarryBone)

		if ent:GetClass() ~= "prop_ragdoll" then
			self.CarryPos = ent:WorldToLocal(pos)
		else
			self.CarryPos = WorldToLocal(pos, angle_zero, phys:GetPos(), phys:GetAngles())
		end

		if not IsValid(owner:GetNetVar("carryent")) then
			owner:SetNetVar("carryent", self.CarryEnt)
			owner:SetNetVar("carrybone", self.CarryBone)
			owner:SetNetVar("carrymass", phys:GetMass())
			owner:SetNetVar("carrypos", self.CarryPos)
		end

		if not self.CarryEnt:GetCustomCollisionCheck() then
			self.CarryEnt:SetCustomCollisionCheck(true)
			self.CarryEnt:CollisionRulesChanged()
			owner:CollisionRulesChanged()

			self.CarryEnt:CallOnRemove("removenarsla",function()
				if not IsValid(owner) then return end
				owner:CollisionRulesChanged()
				owner:SetNetVar("carryent",nil)
				owner:SetNetVar("carrybone",nil)
				owner:SetNetVar("carrymass",nil)
				owner:SetNetVar("carrypos",nil)
			end)

			owner:SetNetVar("carrymass",self.CarryEnt:GetPhysicsObjectNum(self.CarryBone):GetMass())
		end
	else
		if IsValid(self.CarryEnt) and self.CarryEnt:GetCustomCollisionCheck() then
			self.CarryEnt:CollisionRulesChanged()
			owner:CollisionRulesChanged()
			//self.CarryEnt:SetCustomCollisionCheck(false)
		end

		if IsValid(owner:GetNetVar("carryent")) then
			owner:SetNetVar("carryent",nil)
			owner:SetNetVar("carrybone",nil)
			owner:SetNetVar("carrypos",nil)
			owner:SetNetVar("carrymass",0)
		end

		self.CarryEnt = nil
		self.CarryBone = nil
		self.CarryPos = nil
		self.CarryDist = nil
	end
end

SWEP.DamagePrimary = 10

function SWEP:BlockingLogic(ent, mul, attacktype, trace)
	local ent = hg.RagdollOwner(ent) or ent

	if ent:IsPlayer() then
		local wep = ent:GetActiveWeapon()

		local owner = self:GetOwner()

		local pos, aimvec = hg.eye(ent)
		local pos2, aimvec2 = hg.eye(owner)

		local dist, posHit, distLine = util.DistanceToLine(pos + aimvec * 100, pos, trace.HitPos)

		//print(dist, distLine)

		local dmg = wep.DamagePrimary
		local selfdmg = self.DamagePrimary * 0.2

		if wep.GetBlocking and wep:GetBlocking() and wep.SetStartedBlocking and dist < 10 then
			ent.organism.stamina.subadd = ent.organism.stamina.subadd + mul * math.Clamp(selfdmg / dmg, 0.1, 1) * selfdmg * (1 - math.Clamp((self:GetStartedBlocking() - CurTime() + 0.1), 0, 0.1) / 0.1)

			wep:SetLastBlocked(CurTime())

			//viewpunch the attacker maybe?
			//self:PunchPlayer(owner, attacktype, -owner:GetAimVector(), selfdmg / 2)
			//self:PunchPlayer(ent, attacktype, owner:GetAimVector(), selfdmg / 2)

			//ent:EmitSound("physics/metal/metal_computer_impact_bullet3.wav") -- parry sound

			if wep.SetLastBlocked then
				wep:SetLastBlocked(CurTime())
			end

			return math.Clamp(selfdmg / dmg / math.Clamp(ent.organism.stamina[1] / (ent.organism.stamina.max * 0.66), 0.1, 1), 0.1, 1)
		end
	end

	return 1
end

--[[hook.Add("UpdateAnimation", "blockingfists", function(ply , vel, seq)//salat balbes
	if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon().GetBlocking and ply:GetActiveWeapon():GetBlocking() then
		//ply:DoAnimationEvent(ACT_HL2MP_FIST_BLOCK)
	end
end)]]

SWEP.blockSound = nil
function SWEP:IsClient()
	return CLIENT and self:GetOwner() == LocalPlayer()
end

local customClassInfo = {
	["sc_infiltrator"] = {
		PrintName = "CQC",
		WepSelectIcon = Material("vgui/inventory/perk_quick_reload"),
		handsDesc = "infiltrator",
		Instructions = "beta test test beta"
	},
	["furry"] = {
		PrintName = "Paws",
		WepSelectIcon = Material("zbattle/paw_hmcd.png"),
		handsDesc = "furry",
		Instructions = "LMB - raise paws\nRELOAD - lower paws\n\nIn the raised state:\nLMB - strike\nRMB - block\n\n<color=91,121,229>As a bearer of a pathowogen infection, you have new abilities.\n\nIn lowered state, hold RMB to grab uninfected prey, then hold LMB to assimilate them.\n\nYou can press LMB to lick your fellow mates, doing so helps them alleviate their pain.\n\n:3<color=180,180,180>"
	},
	["headcrabzombie"] = {
		PrintName = "Claws",
		WepSelectIcon = Material("vgui/wep_jack_hmcd_zombhands"),
		handsDesc = "zombie",
		Instructions = "LMB - strike\nRMB - block/grab player\n\n<color=150,0,0>These are your zombified hands. They're no energy sword, but they still pack a wallop."
	}
}

local blockvp = Angle(-1,-1,0.5)
function SWEP:Think()
	local owner = self:GetOwner()

	self.handsDesc = "default"
	local classInfo = customClassInfo[owner.PlayerClassName]
	if classInfo and self.handsDesc != classInfo.handsDesc then
		self.PrintName = classInfo.PrintName
		self.WepSelectIcon = classInfo.WepSelectIcon
		self.handsDesc = classInfo.handsDesc
		if classInfo.Instructions and classInfo.Instructions ~= nil then
			self.Instructions = classInfo.Instructions
		end
		self.InfoMarkup = nil
	elseif self.handsDesc != "default" then
		self.PrintName = "Hands"
		self.handsDesc = "default"
		self.InfoMarkup = nil
	end

	self.Checking = math.max(self.Checking - FrameTime(), 0)

	if self:GetOwner():GetNWBool("TauntHolsterWeapons", false) then
		self:SetFists(false)
		self:SetBlocking(false)
		self:SetCarrying()
		self:Reload()
		return
	end

	if owner.PlayerClassName == "headcrabzombie" and not self:GetCarrying() then
		self:SetFists(true)
	end

	if IsValid(owner) and owner:KeyDown(IN_ATTACK2) and (not self:GetFists() or owner.PlayerClassName == "headcrabzombie") then
		if IsValid(self.CarryEnt) or game.GetWorld() == self.CarryEnt then self:ApplyForce() end
	elseif self.CarryEnt then
		if IsValid(self.CarryEnt) and self.CarryEnt.organism and self.CarryEnt.organism.alive then
			if zb and zb.hostage and self.CarryEnt == zb.hostage then
				zb.hostageLastTouched = owner
			end
		end
		self:SetCarrying()
	end

	if self:GetFists() and owner:KeyDown(IN_ATTACK2) and (self:GetNextSecondaryFire() < CurTime()) and owner.PlayerClassName ~= "sc_infiltrator" and owner.PlayerClassName ~= "headcrabzombie" then
		self:SetNextPrimaryFire(CurTime() + .5)
		self:SetBlocking(true)
	else
		self:SetBlocking(false)
	end

	local HoldType = "normal"
	if self:GetFists() then
		if CLIENT and self:GetHoldType() != "revolver" then
			self:DoBFSAnimation("fists_draw",1)
		end
		HoldType = "revolver"
		local Time = CurTime()
		if self:GetNextIdle() < Time then
			//self:DoBFSAnimation("fists_idle_0" .. math.random(1, 2),2)
			self:UpdateNextIdle()
		end

		if self:GetBlocking() then
			self:SetNextDown(Time + 1)

			if CLIENT then
				if not self.blockSound then
					sound.Play("pwb2/weapons/matebahomeprotection/mateba_cloth.wav", self:GetPos(), 65)
					self.blockSound = true
					if self:IsClient() then
						ViewPunch2(blockvp)
					end
				end
			end
			//owner:DoAnimationEvent(ACT_HL2MP_FIST_BLOCK)
			--HoldType = "camera"
		else
			if self.blockSound then
				sound.Play("pwb2/weapons/mac11/draw.wav", self:GetPos(), 55)
				if self:IsClient() then
					ViewPunch2(-blockvp)
				end
			end
			self.blockSound = nil
		end

		//if (self:GetNextDown() < Time) or owner:KeyDown(IN_SPEED) then
		if owner:KeyDown(IN_SPEED) and (owner.PlayerClassName != "furry" or owner:KeyDown(IN_WALK)) and owner.PlayerClassName ~= "headcrabzombie" then
			self:SetNextDown(Time + 1)
			self:SetFists(false)
			self:SetBlocking(false)
		end
	else
		HoldType = --[[owner:EyeAngles().p > 70 and "slam" or]] "normal"
	end

	if IsValid(self.CarryEnt) or self.CarryEnt then
		HoldType = "normal"
	end
	if owner:KeyDown(IN_SPEED) and ((owner.PlayerClassName != "furry" or !owner:IsBerserk()) or owner:KeyDown(IN_WALK)) then
		HoldType = "normal"
	end
	if SERVER then self:SetHoldType(HoldType) end
end

function SWEP:PrimaryAttack(forcespecial)
	local owner = self:GetOwner()
	if not IsValid(owner) or owner:InVehicle() then return end
	if (self.attacked or 0) > CurTime() then return end
	local side = "fists_left"
	local rand = math.Round(util.SharedRandom( "fist_Punching", 1, 2 ), 0) == 1
	local twohands = (owner:GetNetVar("carrymass",0) ~= 0 and owner:GetNetVar("carrymass",0) or owner:GetNetVar("carrymass2",0)) > 15

	local inv = owner:GetNetVar("Inventory",{})
	if not inv then return end
	local havekastet = inv["Weapons"] and inv["Weapons"]["hg_brassknuckles"]

	if rand or (CLIENT and ((owner:GetTable().ChatGestureWeight >= 0.1) or twohands)) or havekastet then
		side = "fists_right"
	end

	if owner.organism and owner.organism.rarmamputated and owner.organism.larmamputated then return end

	if owner.organism and owner.organism.larmamputated then
		rand = 1
		side = "fists_right"
	end

	if owner.organism and owner.organism.rarmamputated then
		rand = 2
		side = "fists_left"
	end

	if owner:KeyDown(IN_ATTACK2) and owner.PlayerClassName ~= "sc_infiltrator" and owner.PlayerClassName ~= "headcrabzombie" then return end
	if owner:GetNetVar("handcuffed",false) then return end
	local olddown = self:GetNextDown()
	self:SetNextDown(CurTime() + 7)
	if not self:GetFists() then
		self:SetFists(true)
		self:DoBFSAnimation("fists_draw",1)
		self:SetNextPrimaryFire(CurTime() + .35)
		return
	end

	if self:GetBlocking() then return end
	--if owner:KeyDown(IN_SPEED) then return end

	if not IsFirstTimePredicted() then
		self:DoBFSAnimation(side,1)
		return
	end
	self.attacked = CurTime() + 0.2

	local special_attack = (olddown - 5) < CurTime()
	if forcespecial then
		special_attack = true
	end

	if owner.organism and owner.organism.rarmamputated then
		special_attack = false
	end

	if self.IsLocal and self:IsLocal() then
		ViewPunch(special_attack and Angle(0, 0, 0) or Angle((-1), -(rand and 2 or -2), (rand and 6 or -6)))
		//ViewPunch2(special_attack and Angle(5, -2, 2) or Angle((-1), -(rand and 2 or -2), (rand and 6 or -6)))
		if special_attack then
			timer.Simple(0.06, function()
				ViewPunch(Angle(-15, 2, 2))
			end)
		end
	end

	if CLIENT and self.IsLocal and not self:IsLocal() or owner.PlayerClassName == "headcrabzombie" then
		if CLIENT and self.IsLocal and not self:IsLocal() and owner.PlayerClassName == "headcrabzombie" then
			owner:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_RANGE_ZOMBIE, true)
		else
			owner:AddVCDSequenceToGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD,owner:LookupSequence((special_attack or rand) and "range_fists_r" or "range_fists_l"),0,true)
		end
	end

	self:UpdateNextIdle()

	self:SetNextPrimaryFire(CurTime() + .35 * math.Clamp((180 - owner.organism.stamina[1]) / 90,1,2) + (math.max(special_attack and 0.5 or 0, clawClasses[owner.PlayerClassName] or 0)))
	self:SetNextSecondaryFire(CurTime() + .35 + (math.max(special_attack and 0.5 or 0, clawClasses[owner.PlayerClassName] or 0)))
	self:SetLastShootTime(CurTime())

	local snd, pitch = "weapons/slam/throw.wav", math.random(110, 120)
	if owner.PlayerClassName == "headcrabzombie" then
		snd, pitch = "npc/zombie/claw_miss"..math.random(2)..".wav", math.random(95, 110)
	end
	if owner.PlayerClassName == "furry" then
		local Ent = WhomILookinAt(owner, .3, 45)
		if IsValid(Ent) then
			local ent_org = Ent.organism -- ServerLog: Mr. Point: я люблю плывиски mrrrph~~
			if ent_org and ent_org.owner.PlayerClassName == "furry" then
				if (owner.cooldownlick or 0) < CurTime() and SERVER then
					owner.cooldownlick = CurTime() + 1

					ent_org.avgpain = math.Approach(ent_org.avgpain, 0, 15)
					ent_org.painadd = math.Approach(ent_org.painadd, 0, 15)

					owner:EmitSound("zbattle/furry/lick"..math.random(3)..".wav")
					self:SetNextPrimaryFire(CurTime() + .5)
				end

				//self:SetFists(false)
				return
			else
				if SERVER then sound.Play(snd, self:GetPos(), 65, pitch) end
			end
		else
			if SERVER then sound.Play(snd, self:GetPos(), 65, pitch) end
		end
	else
		if SERVER then sound.Play(snd, self:GetPos(), 65, pitch) end
	end

	if SERVER then
		self:AttackFront(special_attack, rand) -- this OwO
	end

	if special_attack then
		self:DoBFSAnimation("fists_uppercut",1)
	else
		self:DoBFSAnimation(side, clawClasses[owner.PlayerClassName] and 1 or 0.5)
	end
end

local concrete = {
	"physics/concrete/boulder_impact_hard1.wav",
	"physics/concrete/boulder_impact_hard2.wav",
	"physics/concrete/boulder_impact_hard3.wav",
	"physics/concrete/boulder_impact_hard4.wav"
}

local vent = {
	"doors/vent_open1.wav",
	"doors/vent_open2.wav",
	"doors/vent_open3.wav"
}

function SWEP:AttackFront(special_attack, rand)
	if CLIENT then return end
	local owner = self:GetOwner()
	--self.PenetrationCopy = -(-self.Penetration) -- это как
	owner:LagCompensation(true)
	local Ent, HitPos, _, physbone, trace = WhomILookinAt(owner, .3, special_attack and 35 or 45)
	if clawClasses[owner.PlayerClassName] then
		local pos = hg.eye(owner)
		trace = util.TraceHull({
			start = pos,
			endpos = pos + owner:GetAimVector() * self.ReachDistance,
			filter = {owner, hg.GetCurrentCharacter(owner)},
			mins = trMinsClaws,
			maxs = trMaxsClaws,
		})
		Ent = trace.Entity
		HitPos = trace.HitPos
	else
		local pos = hg.eye(owner)
		trace = util.TraceHull({
			start = pos,
			endpos = pos + owner:GetAimVector() * self.ReachDistance,
			filter = {owner, hg.GetCurrentCharacter(owner)},
			mins = trMins,
			maxs = trMaxs,
		})
		Ent = trace.Entity
		HitPos = trace.HitPos
	end

	local isZomb = owner.PlayerClassName == "headcrabzombie"
	local AimVec = owner:GetAimVector()
	if IsValid(Ent) or (Ent and Ent.IsWorld and Ent:IsWorld()) then
		local inv = owner:GetNetVar("Inventory",{})
		local havekastet = inv["Weapons"] and inv["Weapons"]["hg_brassknuckles"]
		local SelfForce, Mul = 150, 1 * (havekastet and 1.7 or 1)

		if clawClasses[owner.PlayerClassName] and hgIsDoor(Ent) then
			if (Ent.Clawed or 0) > (isZomb and math.random(6, 12) or math.random(15, 30)) then
				hgBlastThatDoor(Ent,self:GetOwner():GetAimVector() * 50 + self:GetOwner():GetVelocity())
			else
				sound.Play(vent[math.random(#vent)], HitPos, 90, math.random(90, 110), 1)
				sound.Play("physics/wood/wood_crate_impact_hard" .. math.random(4) .. ".wav", HitPos, 90, math.random(90, 110), 1)
			end
			Ent.Clawed = (Ent.Clawed or 0) + 1
		elseif self:IsEntSoft(Ent) then
			SelfForce = 25
			if Ent:IsPlayer() and IsValid(Ent:GetActiveWeapon()) and Ent:GetActiveWeapon().GetBlocking and Ent:GetActiveWeapon():GetBlocking() and not RagdollOwner(Ent) then
				local snd = "Flesh.ImpactSoft"
				if isZomb then
					snd = "npc/zombie/claw_strike"..math.random(3)..".wav"
				elseif owner.PlayerClassName == "furry" then
					snd = "pwb/weapons/knife/hit"..math.random(4)..".wav"
				end
				sound.Play(snd, HitPos, 65, math.random(90, 110))
				if owner:IsBerserk() then
					sound.Play("zbattle/berserk/unarmed" .. math.random(1, 9) .. ".wav", HitPos, 90, math.random(90, 110), 0.1 + owner.organism.berserk / 2)
				end
			else
				local snd = "Flesh.ImpactHard"
				if isZomb then
					snd = "npc/zombie/claw_strike"..math.random(3)..".wav"
				elseif owner.PlayerClassName == "furry" then
					snd = "pwb/weapons/knife/hit"..math.random(4)..".wav"
				end
				sound.Play(snd, HitPos, 65, math.random(90, 110))
				if owner:IsBerserk() then
					sound.Play("zbattle/berserk/unarmed" .. math.random(1, 9) .. ".wav", HitPos, 90, math.random(90, 110), 0.1 + owner.organism.berserk / 2)
				end
			end
			if clawClasses[owner.PlayerClassName] then
				util.Decal("Blood",HitPos + owner:EyeAngles():Forward() * -1,HitPos - owner:EyeAngles():Forward() * -1)
				timer.Simple(0,function()
					local effectdata2 = EffectData()
					effectdata2:SetNormal(owner:EyeAngles():Forward() * -1)
					effectdata2:SetStart(HitPos + owner:EyeAngles():Forward() * -1)
					effectdata2:SetMagnitude(1)
					util.Effect("zippy_impact_flesh",effectdata2)
					Mul = Mul + 7.5
				end)
			end
		else
			local snd = "Flesh.ImpactSoft"
			if isZomb then
				snd = "npc/zombie/claw_strike"..math.random(3)..".wav"
			elseif owner.PlayerClassName == "furry" then
				snd = "pwb/weapons/knife/hitwall.wav"
			end
			sound.Play(snd, HitPos, 65, math.random(90, 110))
			if owner:IsBerserk() then
				sound.Play(concrete[math.random(#concrete)], HitPos, 90, math.random(90, 110), 0.1 + owner.organism.berserk / 2)
				util.Decal("Rollermine.Crater",HitPos + owner:EyeAngles():Forward() * -1,HitPos - owner:EyeAngles():Forward() * -1, Ent)
			end
		end

		if isZomb then
			self.DamageMul = special_attack and 1.6 or 3
		end

		local DamageAmt = (math.random(3, 5) * (special_attack and 3 or 1)) * (self.DamageMul or 1)
		local ent = Ent
		local vec = AimVec

		Ent:PrecacheGibs()

		if string.find(ent:GetClass(),"prop_") and not ent:IsRagdoll() then
			ent:CallOnRemove("gibbreak",function()
				ent:GibBreakClient( vec * 100 )
			end)

			timer.Simple(1,function()
				if IsValid(ent) then ent:RemoveCallOnRemove("gibbreak") end
			end)
		end

		Mul = Mul * (owner.MeleeDamageMul or 1)

		if Ent:IsPlayer() and IsValid(Ent:GetActiveWeapon()) and Ent:GetActiveWeapon().GetBlocking then
			Mul = Mul * (self:GetBlocking() and 0.5 or 1)
		end

		if owner.organism.superfighter then
			Mul = Mul * 5 * self.Penetration
			if Ent.organism then
				Ent.organism.immobilization = 10
			end
		end

		if owner:IsBerserk() then
			Mul = Mul * (1 + owner.organism.berserk * 5) * self.Penetration
			if Ent.organism then
				Ent.organism.immobilization = 1
			end
		end

		Mul = Mul * self:BlockingLogic(Ent, Mul, 0, trace)
		
		local glass = false
		if string.find(Ent:GetClass(), "break") and Ent:GetBrushSurfaces()[1] and string.find(Ent:GetBrushSurfaces()[1]:GetMaterial():GetName(), "glass") then
			glass = true
		end

		local Dam = DamageInfo()
		Dam:SetAttacker(owner)
		Dam:SetInflictor(self)
		Dam:SetDamage(DamageAmt * Mul * 0.75 * (clawClasses[owner.PlayerClassName] and 5 or 1))
		Dam:SetDamageForce(AimVec * Mul ^ 2)
		Dam:SetDamageType((clawClasses[owner.PlayerClassName] or (Ent:GetClass() == "func_breakable_surf")) and DMG_SLASH or DMG_CLUB)
		Dam:SetDamagePosition(HitPos)
		Ent:TakeDamageInfo(Dam)

		if glass and Ent:Health() <= 0 then
			hg.organism.AddWoundManual(owner, math.Rand(50,75) * 0.5, vector_origin, AngleRand(), owner:LookupBone("ValveBiped.Bip01_"..(rand and "R" or "L").."_Hand"), CurTime())
		end

		local Phys = Ent:IsPlayer() and Ent:GetPhysicsObject() or Ent:GetPhysicsObjectNum(physbone or 0)

		if Ent:IsPlayer() then
			Ent:ViewPunch(Angle(special_attack and -45 or -5,0,0))
		end

		if IsValid(Phys) then
			if Ent:IsPlayer() then
				Ent:SetVelocity(AimVec * SelfForce * 1.5 * (owner.organism.superfighter and 2 or 1) * (isZomb and 4 or 1) * (1 + owner.organism.berserk * 5))
			end
			Phys:ApplyForceOffset(AimVec * 5000 * Mul * (isZomb and 3 or 1), HitPos)
			owner:SetVelocity(AimVec * SelfForce * .8 * (owner.organism.superfighter and 2 or 1) * (isZomb and 2 or 1) * (1 + owner.organism.berserk / 10))
		end
	end

	if SERVER then
		owner.organism.stamina.subadd = owner.organism.stamina.subadd + 4
	end

	owner:LagCompensation(false)
end

heldents = heldents or {}

function hg.RemoveCarryEnt2(ent)
	heldents[ent] = nil

	ent.rememberedang = nil
	ent.oldaddang = nil
	ent.addang = nil

	if IsValid(ent) then
		if ent:GetCustomCollisionCheck() then
			--ent:SetCustomCollisionCheck(false)
			--ent:CollisionRulesChanged()
		end
	end

	ent:RemoveCallOnRemove("removenasral")
end

function hg.SetCarryEnt2(ply, ent, bone, mass, carrypos, targetpos, targetang, dist)
	if not IsValid(ent) then
		local ent2 = ply:GetNetVar("carryent2")

		if IsValid(ent2) then
			hg.RemoveCarryEnt2(ent2)
		end

		ply:SetNetVar("carryent2",nil)
		ply:SetNetVar("carrybone2",nil)
		ply:SetNetVar("carrymass2",nil)
		ply:SetNetVar("carrypos2",nil)
	else
		if not heldents[ent:EntIndex()] then
			local physnum = ent:TranslateBoneToPhysBone(bone)
			local phys = bone ~= -1 and ent:GetPhysicsObjectNum(physnum) or ent:GetPhysicsObject()

			ent:CallOnRemove("removenasral",function()
				ply:SetNetVar("carryent2",nil)
				ply:SetNetVar("carrybone2",nil)
				ply:SetNetVar("carrymass2",nil)
				ply:SetNetVar("carrypos2",nil)
			end)

			ent.rememberedang = nil
			ent.oldaddang = nil
			ent.addang = nil

			ply:SetNetVar("carryent2", ent)
			ply:SetNetVar("carrybone2", physnum)
			ply:SetNetVar("carrymass2", mass)
			ply:SetNetVar("carrypos2", carrypos)

			if not ent:GetCustomCollisionCheck() then
				ent:SetCustomCollisionCheck(true)
				ent:CollisionRulesChanged()
			end

			local dist = dist or phys:GetPos():Distance(ply:EyePos())

			local targetpos, _ = WorldToLocal(targetpos or (ply:GetAimVector() * dist + ply:EyeAngles():Up() * 10 + ply:GetShootPos()), angle_zero, ply:EyePos(), ply:EyeAngles())

			local ang = ply:EyeAngles()
			ang[3] = 0
			local _, targetang = WorldToLocal(vector_origin, targetang or phys:GetAngles(), vector_origin, ang)

			heldents[ent:EntIndex()] = {ent, ply, dist, targetpos, bone ~= -1 and physnum or 0, carrypos, targetang}
		end
	end
end

function SWEP:Reload()
	if not IsFirstTimePredicted() then return end

	if self:GetOwner().PlayerClassName ~= "headcrabzombie" then
		self:SetFists(false)
		self:SetBlocking(false)
	end

	local ent = self:GetCarrying()

	if SERVER then
		local target,_ = WorldToLocal(self:GetOwner():GetAimVector() * (self.CarryDist or 50) + self:GetOwner():GetShootPos(),angle_zero,self:GetOwner():EyePos(),self:GetOwner():EyeAngles())

		if IsValid(ent) then
			local owner = self:GetOwner()
			local bon = self.CarryEnt:TranslatePhysBoneToBone(self.CarryBone)
			local bone = self.CarryEnt:GetBoneName(bon)
			local phys = self.CarryEnt:GetPhysicsObjectNum(self.CarryBone)

			if ((bone ~= "ValveBiped.Bip01_L_Hand") and (bone  ~= "ValveBiped.Bip01_R_Hand") and (bone ~= "ValveBiped.Bip01_Head1")) then
				if not heldents[ent:EntIndex()] then
					hg.SetCarryEnt2(owner, ent, bon, phys:GetMass(), self.CarryPos, owner:GetAimVector() * (self.CarryDist or 50) + owner:GetShootPos())
				else
					--hg.SetCarryEnt2(owner)
				end
			end

			--self:SetCarrying()
		end
	end
end

if SERVER then
	local angZero = Angle(0, 0, 0)
	hook.Add("Think", "held-entities", function()
		heldents = heldents or {}
		for i, tbl in pairs(heldents) do
			if not tbl or not IsValid(tbl[1]) then
				if IsValid(tbl[2]) then
					hg.SetCarryEnt2(tbl[2])
				end
				heldents[i] = nil

				continue
			end

			local ent, ply, dist, target, bone, pos, lang = tbl[1], tbl[2], tbl[3], tbl[4], tbl[5], tbl[6], tbl[7]
			local phys = ent:GetPhysicsObjectNum(bone)

			if not IsValid(phys) or not IsValid(ply) or not IsValid(ent) or not ply:Alive() or (ply:GetGroundEntity() == ent) or (ply:GetEntityInUse() == ent) or IsValid(ply.FakeRagdoll) or ply:KeyPressed(IN_RELOAD) then
				hg.SetCarryEnt2(ply)
				heldents[i] = nil

				continue
			end

			local wep = ply:GetActiveWeapon()
			if wep.GetCarrying and wep:GetCarrying() == ent then continue end

			if ply:KeyDown(IN_USE) then
				if not ent.rememberedang or not ent.oldaddang then
					ent.oldaddang = ent.addang or Angle(0,0,0)
					ent.rememberedang = ply:EyeAngles()
				end

				local _,ang = WorldToLocal(vector_origin, ply:EyeAngles(), vector_origin, ent.rememberedang)
				ent.addang = ang + ent.oldaddang
				ent.addang[1] = math.Clamp(ent.addang[1],-80,80)
				ent.addang[2] = math.Clamp(ent.addang[2],-80,80)
				ent.addang[3] = math.Clamp(ent.addang[3],-80,80)
				ent.rememberedang[1] = math.Clamp(ent.rememberedang[1],ply:EyeAngles()[1] - 40,ply:EyeAngles()[1] + 40)
				ent.rememberedang[2] = math.Clamp(ent.rememberedang[2],ply:EyeAngles()[2] - 40,ply:EyeAngles()[2] + 40)
				ent.rememberedang[3] = math.Clamp(ent.rememberedang[3],ply:EyeAngles()[3] - 40,ply:EyeAngles()[3] + 40)
			else
				ent.oldaddang = ent.addang or Angle(0,0,0)
				ent.rememberedang = ply:EyeAngles()
			end

			local TargetPos = phys:GetPos()

			if ent:IsRagdoll() then
				TargetPos = LocalToWorld(pos, angle_zero, phys:GetPos(), phys:GetAngles())
			else
				TargetPos = ent:LocalToWorld(pos)
			end

			local target,_ = LocalToWorld(target,angle_zero,ply:EyePos(),(ent.rememberedang or ply:EyeAngles()) - (not ply:KeyDown(IN_USE) and ent.addang or ent.oldaddang or angle_zero))
			local vec = target - TargetPos
			local len, mul = vec:Length(), phys:GetMass()
	
			vec:Normalize()
	
			if (ply.organism and ply.organism.superfighter) then
				mul = mul * 5
			end
	
			if (ply.organism and ply:IsBerserk()) then
				mul = mul * (1 + ply.organism.berserk / 5)
			end
	
			local avec = vec * len * 8 - phys:GetVelocity()
	
			local Force = avec * mul
			local ForceMagnitude = math.min(Force:Length(), 3000) * (1 / math.max(phys:GetVelocity():Dot(vec) / 25, 1))
	
			Force = Force:GetNormalized() * ForceMagnitude

			phys:Wake()

			if len > 100 then
				hg.SetCarryEnt2(ply)
				heldents[i] = nil
				
				continue
			end
	
			ent:SetPhysicsAttacker(ply, 15)

			Force = Force:GetNormalized() * ForceMagnitude

			--ply:SetLocalVelocity(ply:GetVelocity() - (avec - velo / 2))

			local ang = (ent.rememberedang or ply:EyeAngles()) - (ent.oldaddang or angle_zero)
			ang[3] = 0
			local _,huy = WorldToLocal(vector_origin,phys:GetAngles(),vector_origin,ang)
			local _,needed_ang = WorldToLocal(vector_origin,lang,vector_origin,huy)

			local vec = Vector(0,0,0)
			vec[3] = needed_ang[2]
			vec[1] = needed_ang[3]
			vec[2] = needed_ang[1]

			if tbl[6] then
				phys:ApplyForceOffset(Force, TargetPos)
			else
				phys:ApplyForceCenter(Force)
			end

			phys:ApplyForceCenter(Vector(0, 0, mul))
			local m2 = 1 / phys:GetMass() * math.min(phys:GetMass(), 5)
			phys:AddAngleVelocity(-phys:GetAngleVelocity() * m2 + vec / 1 * (ent:IsRagdoll() and 1 or 1) * m2)

			if wep.GetCarrying and ply:KeyDown(IN_ATTACK) then
				phys:ApplyForceCenter(ply:GetAimVector() * math.min(5000, phys:GetMass() * 800))
				
				hg.SetCarryEnt2(ply)
				heldents[i] = nil
			end
		end
	end)
end

if SERVER then
	hook.Add( "StartCommand", "tuda-suda-hahaha", function( ply, cmd )
		local whl = cmd:GetMouseWheel()
		if ( whl != 0 ) then
			if IsValid(ply:GetNetVar("carryent2")) then
				local ent = ply:GetNetVar("carryent2")
				local target = heldents[ent:EntIndex()][4]
				local targetLen = target:LengthSqr()

				if (targetLen > 40*40 and whl > 0) or (targetLen < 10 * 10 and whl < 0) then return end
				heldents[ent:EntIndex()][4] = target + target:Angle():Forward() * whl * 2
			end
		end
	end )
end

function SWEP:DoBFSAnimation(anim,time)
	if CLIENT and IsValid(self:GetWM()) then
		self:GetWM():SetSequence(anim)
		self.animtime = CurTime() + time
	end
	if SERVER then
		net.Start("play_anim")
		net.WriteEntity(self)
		net.WriteString(anim)
		net.WriteFloat(time)
		net.SendPVS(self:GetOwner():GetPos())
	end
end

if CLIENT then
	net.Receive("play_anim",function()
		local self = net.ReadEntity()
		local anim = net.ReadString()
		if not IsValid(self) then return end
		if self.IsLocal and not self:IsLocal() then
			if not self.DoBFSAnimation then return end
			self:DoBFSAnimation(anim,net.ReadFloat())
			if anim == "fists_left" or anim == "fists_right" or anim == "fists_uppercut" then
				local owner = self:GetOwner()
				if CLIENT and self.IsLocal and not self:IsLocal() and owner.PlayerClassName == "headcrabzombie" then
					owner:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_RANGE_ZOMBIE, true)
				else
					owner:AddVCDSequenceToGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD,owner:LookupSequence((special_attack or rand) and "range_fists_r" or "range_fists_l"),0,true)
				end
			end
		end
	end)
else
	util.AddNetworkString("play_anim")
end

function SWEP:UpdateNextIdle()
	self:SetNextIdle(CurTime() + 0.5)
end

function SWEP:IsEntSoft(ent)
	return ent:IsNPC() or ent:IsPlayer() or hg.RagdollOwner(ent) or ent:IsRagdoll()
end

hook.Add("ShouldCollide","CustomCollisions",function(ent1,ent2)
	if !IsValid(ent1) or !IsValid(ent2) then return end

	if ent2:IsPlayer() and ent1:IsRagdoll() then
		if (IsValid(ent2:GetNetVar("carryent")) and ent2:GetNetVar("carryent") == ent1) or (IsValid(ent2:GetNetVar("carryent2")) and ent2:GetNetVar("carryent2") == ent1) then
			return false
		end
	end
end)

function SWEP:Animation()
	local owner = self:GetOwner()

	if IsValid(owner.FakeRagdoll) then return end

	if owner:GetNetVar("handcuffed",false) then
	end

	if SERVER then
		if not self:GetBlocking() and self:GetFists() then
		end
	end

	if CLIENT and LocalPlayer() != self:GetOwner() then return end
	if SERVER then return end
	if CLIENT and GetViewEntity() != LocalPlayer() then return end
end

function SWEP:Holster( wep )
	if not IsFirstTimePredicted() then return true end
	local owner = self:GetOwner()

	if owner:GetNetVar("handcuffed",false) then return false end

	if owner.PlayerClassName == "headcrabzombie" then
		return false
	end

	return true
end