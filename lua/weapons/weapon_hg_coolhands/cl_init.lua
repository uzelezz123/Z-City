include("shared.lua")
SWEP.Category = "ZCity Other"
SWEP.PrintName = "CoolHands"
SWEP.Spawnable = false --// Use this hands if you like it more.. - Mannytko
SWEP.Instructions = "LMB - raise fists\nRELOAD - lower fists\n\nIn the raised state:\nLMB - strike\nRMB - block\n\nIn the lowered state: RMB - raise the object, RMB+R - check the pulse (when used on someone's head or hand)\n\nWhen holding the object: RELOAD - fix the object in air, E - spin the object in the air."
SWEP.blockinganim = 0
SWEP.animtime = 0
SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.ViewModelFOV = 45
SWEP.BounceWeaponIcon = false
SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_hands")
SWEP.IconOverride = "vgui/wep_jack_hmcd_hands.png"
SWEP.visualweight = 2
local math = math -- owo
local math_random, math_Clamp, CurTime, Color = math.random, math.Clamp, CurTime, Color

local colWhite = Color(255, 255, 255, 255)
local lerpthing = 1
local lerpalpha = 0
local colwhite = Color(0, 0, 0, 0)
local colred = Color(122, 0, 0, 0)

local ang4 = Angle(0,0,180)
local ang5 = Angle(0,0,0)

local ang3 = Angle(0,0,180)
local clamp = math_Clamp

function SWEP:SecondaryAttack()
end

function SWEP:DrawHUD()
	local owner = LocalPlayer()

	if GetViewEntity() ~= owner then return end
	if owner:InVehicle() then return end
	local Tr = hg.eyeTrace(owner,self.ReachDistance)
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

local function qerp(delta, a, b)
	local qdelta = -(delta ^ 2) + (delta * 2)
	qdelta = math_Clamp(qdelta, 0, 1)

	return Lerp(qdelta, a, b)
end

function SWEP:GetWM()
	return self.worldModel
end

-- Settings...
local blocking_ang = Angle(-40,0,0)
function SWEP:DrawWorldModel()
	local owner = self:GetOwner()

	if not IsValid(self.worldModel) then
		self.worldModel = ClientsideModel(self.WorldModel)
	end

	if owner.PlayerClassName == "furry" and self.worldModel != "models/weapons/salat/anims/furry_fists.mdl" then
		self.worldModel:SetModel("models/weapons/salat/anims/furry_fists.mdl")
	end

	if not self:GetFists() then return end

	local WorldModel = self.worldModel

	WorldModel:SetCycle(1 - math_Clamp(self.animtime - CurTime(),0,1))

	self.blockinganim = qerp(0.05 * FrameTime() / engine.TickInterval(),self.blockinganim,self:GetBlocking() and 1 or 0)

	if (IsValid(owner)) then
		local ang = owner:EyeAngles()
		local tr = hg.eyeTrace(owner)

		local pos = tr.StartPos + ang:Forward() * (-14) + ang:Up() * -9 * self.blockinganim
		if owner.PlayerClassName == "sc_infiltrator" then
			pos = tr.StartPos + ang:Forward() * (-18) + ang:Up() * -5 -- этим кулакам никакой оффсет не поможет
		end

		local ang = owner:EyeAngles()

		local _,ang = LocalToWorld(vector_origin,blocking_ang * self.blockinganim,vector_origin,ang)

		local pos, ang = self:ModelAnim(WorldModel, pos, ang)

		if owner.PlayerClassName == "furry" then
			pos = pos + ang:Forward() * 10
		end

		--print(pos)
		WorldModel:SetRenderOrigin(pos)
		WorldModel:SetRenderAngles(ang)
	else
		WorldModel:SetPos(self:GetPos())
		WorldModel:SetAngles(self:GetAngles())
	end

	WorldModel:SetupBones()
	--WorldModel:DrawModel()
end

local host_timescale = game.GetTimeScale

local addAng = Angle()
local addPos = Vector()
local vechuy = Vector(-12, 0, 0)
SWEP.HoldPos = Vector(7, 0, 2)
SWEP.HoldAng = Angle(1, 0, 0)
function SWEP:ModelAnim(model, pos, ang)
	local owner = self:GetOwner()

	if !IsValid(owner) or !owner:IsPlayer() then return end

	local ent = hg.GetCurrentCharacter(owner)
	local tr = hg.eyeTrace(owner, 60, ent)
	local eyeAng = owner:EyeAngles()

	local vel = ent:GetVelocity()
	local vellen = vel:Length()

	local vellenlerp = self.velocityAdd and self.velocityAdd:Length() or vellen

	if !tr then return end

	self.walkLerped = LerpFT(0.1, self.walkLerped or 0, (owner:InVehicle()) and 0 or vellenlerp * 200)
	self.walkTime = self.walkTime or 0

	local walk = math_Clamp(self.walkLerped / 200, 0, 1)

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

		local veldot = self.velocityAdd:Dot(tr.Normal:Angle():Right())

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

	local pos, ang = LocalToWorld(hpos + addPos, hang + addAng, tr.StartPos + self.velocityAdd, eyeAng)

	return pos, ang
end

function SWEP:Camera(eyePos, eyeAng, view, vellen)
	//self:SetHandPos()
	self:DrawWorldModel()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	self.walkinglerp = Lerp(hg.lerpFrameTime2(0.1),self.walkinglerp or 0, owner.InVehicle and owner:InVehicle() and 0 or hg.GetCurrentCharacter(owner):GetVelocity():LengthSqr())
	self.huytime = self.huytime or 0
	local walk = math_Clamp(self.walkinglerp / 10000,0,1)

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

SWEP.KnuckleModel = "models/mosi/fallout4/props/weapons/melee/knuckles.mdl"
SWEP.offsetVec = Vector(2.2, -0.5, 0)
SWEP.offsetAng = Angle(0, 90, 90)
SWEP.idleVec = Vector(4.5, -2, -0.2)
SWEP.idleAng = Angle(0, 0, -80)

local blockingR = Vector()
local blockingL = Vector()
local vecIdleR = Vector(-1, 1, 1)
local vecIdleL = Vector(-4, -2, 0.5)
local vecBlockingR = Vector(-1, 1, 2)
local vecBlockingL = Vector(-2, -3.5, 6)
local angle_zero = Angle(0,0,0)
local idleAng = Angle(60,0,50)
local blockAng = Angle(80,0,70)
SWEP.laptime = 0
local ang180, ang1, ang2 = Angle(0,180,0), Angle(-110,-90,0), Angle(-70,-90,0)
function SWEP:SetHandPos(noset)
	local ply = self:GetOwner()

	if not IsValid(ply) or not IsValid(self.worldModel) then return end
	if IsValid(ply) and (not ply.shouldTransmit or ply.NotSeen) then return end
	-- ply:SetupBones()

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

	local rh,lh = ply:LookupBone("ValveBiped.Bip01_R_Hand"),ply:LookupBone("ValveBiped.Bip01_L_Hand")
	local rhmat, lhmat = ply:GetBoneMatrix(rh), ply:GetBoneMatrix(lh)

	ply.rhold = rhmat
	ply.lhold = lhmat

	if self:GetFists() then
		local bones = hg.TPIKBonesRH

		local lastaddpos = self:IsLocal() and self.lastAddPos or vector_origin
		local posadd, _ = LocalToWorld(lastaddpos, angle_zero, vector_origin, ply:EyeAngles())
		//local posadd = self:IsLocal() and self.lastAddPos and -(-self.lastAddPos) or -(-vector_origin)

		self.blockingR = LerpFT(0.1, self.blockingR or vector_origin, (self:GetBlocking() and vecBlockingR or (self:GetNextIdle() < CurTime() and vecIdleR or vector_origin)))
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
			local mat = ply:GetBoneMatrix(rh)
			local ang = mat:GetAngles()
			self.blockAngR = LerpFT(0.1, self.blockAngR or angle_zero, (self:GetBlocking() and blockAng or (self:GetNextIdle() < CurTime() and idleAng or angle_zero)))
			local _, ang = LocalToWorld(vector_origin, self.blockAngR, vector_origin, ang)
			mat:SetAngles(ang)
			hg.bone_apply_matrix(ply, rh, mat)
		end

		local bones = hg.TPIKBonesLH

		posadd:Rotate(angle_zero)

		self.blockingL = LerpFT(0.1, self.blockingL or vector_origin, (self:GetBlocking() and vecBlockingL or (self:GetNextIdle() < CurTime() and vecIdleL or vector_origin)))
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
			local mat = ply:GetBoneMatrix(lh)
			local ang = mat:GetAngles()
			self.blockAngL = LerpFT(0.1, self.blockAngL or angle_zero, (self:GetBlocking() and -blockAng or (self:GetNextIdle() < CurTime() and -idleAng or angle_zero)))
			local _, ang = LocalToWorld(vector_origin, self.blockAngL, vector_origin, ang)
			mat:SetAngles(ang)
			hg.bone_apply_matrix(ply, lh, mat)
		end
	end

	if IsValid(ply) and havekastet then
		local offsetVec = self:GetFists() and self.offsetVec or self.idleVec
		local offsetAng = self:GetFists() and self.offsetAng or self.idleAng
		if not rh then return end
		local matrix = ply:GetBoneMatrix(rh)
		if not matrix then return end
		local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())
		local kastet = self.model
		kastet:SetPos(newPos)
		kastet:SetAngles(newAng)
		kastet:SetupBones()
		kastet:DrawModel()
		kastet:SetModelScale(0.9) -- с новыми руками можно будет 1 оставить
	end

	hg.DragHands(self:GetOwner(),self)

	if self:GetFists() or self:GetBlocking() or IsValid(ply:GetNetVar("carryent")) then return end

	local wmpos2 = ply_spine_matrix:GetTranslation() - ply:EyeAngles():Right() * -5
	local tr2 = {}
	tr2.start = wmpos2
	tr2.endpos = wmpos2 + ply:GetAimVector() * 30
	tr2.filter = ply
	local trace2 = util.TraceLine(tr2)
	if IsValid(ply:GetNetVar("carryent2")) and trace2.Entity == ply:GetNetVar("carryent2") then return end

	local vel = ply:GetVelocity()

	if trace2.Hit and not (trace2.Entity:IsPlayer() or trace2.Entity:IsNPC()) then -- freaky
		if trace2.HitNormal:Dot(vel) < -200 or self.laptime > CurTime() then
			if self.laptime < CurTime() then
				self.laptime = CurTime() + 1
			end
			hg.DragRightHand(ply, self, trace2.HitPos - ply:GetAimVector() * 5, ply:GetAimVector(), (trace2.Entity:IsWorld() and Lerp(1, trace2.HitNormal:Angle(), ply:EyeAngles() + ang180) or ply:EyeAngles() + ang180) + ang2 - ply:EyeAngles())
		end
	end

	local wmpos1 = ply_spine_matrix:GetTranslation() - ply:EyeAngles():Right() * 5
	local tr1 = {}
	tr1.start = wmpos1
	tr1.endpos = wmpos1 + ply:GetAimVector() * 30
	tr1.filter = ply
	local trace = util.TraceLine(tr1)
	if trace.Entity:IsPlayer() or trace.Entity:IsNPC() then return end -- freaky

	if trace.Hit and not IsValid(ply:GetNetVar("carryent2")) then
		if trace.HitNormal:Dot(vel) < -200 or self.laptime > CurTime() then
			if self.laptime < CurTime() then
				self.laptime = CurTime() + 1
			end
			hg.DragLeftHand(ply, self, trace.HitPos - ply:GetAimVector() * 5, ply:GetAimVector(), (trace.Entity:IsWorld() and Lerp(1, trace.HitNormal:Angle(), ply:EyeAngles() + ang180) or ply:EyeAngles() + ang180) + ang1 - ply:EyeAngles())
		end
	end

	if (trace.Hit and trace2.Hit and self.laptime > CurTime() or (trace2.Hit and self.laptime > CurTime())) and self:GetHoldType() ~= "slam" then
		self:SetHoldType("slam")
	elseif not self:GetFists() and self:GetHoldType() ~= "normal" then
		self:SetHoldType("normal")
	end
end

function SWEP:IsLocal()
	if SERVER then return end
	return self:GetOwner() == LocalPlayer()
end

local paw = Material("zbattle/paw_hmcd.png")
local cqcicon = Material("vgui/inventory/perk_quick_reload")
SWEP.changedName = false

local blockvp = Angle(-3, -1.5, 1)
function SWEP:Think()
	local owner = self:GetOwner()
	-- if not self.changedName then
		if owner.PlayerClassName == "sc_infiltrator" and self.PrintName ~= "CQC" then
			self.PrintName = "CQC"
			self.WepSelectIcon = cqcicon
		elseif owner.PlayerClassName == "furry" and self.PrintName ~= "Paws" then
			self.PrintName = "Paws"
			self.WepSelectIcon = paw
			self.Instructions = "LMB - raise paws\nRELOAD - lower paws\n\nIn the raised state:\nLMB - strike\nRMB - block\n\n<color=91,121,229>As a bearer of a pathowogen infection, you have new abilities.\n\nIn lowered state, hold RMB to grab uninfected prey, then hold LMB to assimilate them.\n\nYou can press LMB to lick your fellow mates, doing so helps them alleviate their pain.\n\n:3<color=180,180,180>"
		else
			self.PrintName = "Hands"
		end
		self.changedName = true
	-- end
	

	if self:GetBlocking() then
		if not self.blockSound then
			sound.Play("pwb2/weapons/matebahomeprotection/mateba_cloth.wav", self:GetPos(), 65)
			self.blockSound = true
			if self:IsClient() then
				ViewPunch2(blockvp)
			end
		end
	else
		if self.blockSound then
			sound.Play("pwb2/weapons/mac11/draw.wav", self:GetPos(), 55)
			if self:IsClient() then
				ViewPunch2(-blockvp)
			end
		end
		self.blockSound = nil
	end
end

local specang1, specang2, specangfur = Angle(-1, -3, 3), Angle(4, 12, 3), Angle(-15, 2, 2)
function SWEP:PrimaryAttack(forcespecial)
	local owner = self:GetOwner()
	if not IsValid(owner) or owner:InVehicle() then return end
	if (self.attacked or 0) > CurTime() then return end
	local isfur = owner.PlayerClassName == "furry"
	local side = isfur and "fists_left" or "attack_quick_2"
	local rand = math.Round(util.SharedRandom( "fist_Punching", 1, 2 ),0) == 1

	local inv = owner:GetNetVar("Inventory",{})
	if not inv then return end
	local havekastet = inv["Weapons"] and inv["Weapons"]["hg_brassknuckles"]

	if rand or (CLIENT and ((owner:GetTable().ChatGestureWeight and owner:GetTable().ChatGestureWeight >= 0.1) or twohands)) or havekastet then
		if isfur then
			side = "fists_right"
		else
			side = "attack_quick_1"
		end
	end
	if owner:KeyDown(IN_ATTACK2) and owner.PlayerClassName ~= "sc_infiltrator" then return end
	if owner:GetNetVar("handcuffed",false) then return end
	local olddown = self:GetNextDown()
	self:SetNextDown(CurTime() + 7)
	if not self:GetFists() then
		return
	end

	if self:GetBlocking() then return end
	--if owner:KeyDown(IN_SPEED) then return end

	if not IsFirstTimePredicted() then
		self:PlayAnim(side,1)
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

	if CLIENT and self.IsLocal and self:IsLocal() then
		ViewPunch(special_attack and specang1 or Angle(-1, -(rand and -3 or 3), (rand and -8 or 8)))
		//ViewPunch2(special_attack and Angle(5, -2, 2) or Angle((-1), -(rand and 2 or -2), (rand and 6 or -6)))
		if special_attack then
			if not isfur then
				timer.Simple(0.4, function()
					ViewPunch(specang2)
				end)
			else
				timer.Simple(0.06, function()
					ViewPunch(specangfur)
				end)
			end
		end
	end

	if CLIENT and self.IsLocal and not self:IsLocal() then
		owner:AddVCDSequenceToGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD,owner:LookupSequence((special_attack or rand) and "range_fists_r" or "range_fists_l"),0,true)
	end
end

function SWEP:Reload()
	if not IsFirstTimePredicted() then return end
	if CLIENT and (self:GetFists() or self:GetBlocking()) then
		self:EmitSound("pwb2/weapons/mac11/draw.wav", 35, math.random(95, 105), 1, CHAN_BODY)
	end
end