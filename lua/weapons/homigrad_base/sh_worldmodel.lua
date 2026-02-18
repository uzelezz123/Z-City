AddCSLuaFile()
local IsValid = IsValid
--
hook.Add("PhysgunPickup", "homigrad-weapons", function(ply, ent) if ent:GetNWBool("nophys") then return false end end)
SWEP.WorldPos = Vector(13, -0.3, 3.4)
SWEP.WorldAng = Angle(5, 0, 180)
SWEP.UseCustomWorldModel = false

function SWEP:ShouldUseFakeModel()
	return self.WorldModelFake// and IsValid(self:GetOwner())
end

SWEP.weaponAng = Angle(0, 0, 0)
local angZero = Angle(0, 0, 0)
local math_max, math_Clamp = math.max, math.Clamp
function SWEP:GetAnimPos_Shoot2(time, timeSpan)
	local animpos = math.max(time - RealTime() + timeSpan,0) / timeSpan
	
	return animpos
end

function SWEP:GetAnimShoot2(time, force, delay)
	if self.IsPistolHoldType and not self:IsPistolHoldType() and not force then return 0 end
	
	local animpos = self:GetAnimPos_Shoot2(self.lastShoot or 0, time * (math.max((self.weight or 1) + (self.addweight or 0) - 1,0.1) * 2 + 2))
	
	--/ (FrameTime() / engine.TickInterval())
	animpos = 1.5 * animpos ^ 3 - 1 * animpos ^ 2
	
	if animpos > 0 then
		--animpos = animpos * math.max(self.Primary.Force / 40, 0) / (math.max((self.weight or 1) - 1,0.1) * 5 + 1) * (self.NumBullet or 1)
		--animpos = animpos * (self.animposmul or 1)
	end
	
	return animpos
end

local angZero, vecZero = Angle(0, 0, 0), Vector(0, 0, 0) -- а неиспользуется потому что глуалин подчеркнул это
local angPosture3 = Angle(45, 45, -25)
local angPosture3pistol = Angle(5, 65, 0)
local angPosture4 = Angle(40, -30, -40)
local angPosture5 = Angle(5, 5, 0)
local angPosture6 = Angle(30, 20, 0)
local angPosture7 = Angle(5, -30, 0)
local angPosture8 = Angle(40, 10, -30)
local angSuicide = Angle(-35, 120, 0)
local angReload = Angle(-20, 10, 0)

SWEP.AllowedInspect = true



local funcNil = function() end

hg.postureFuncWorldModel = {
	[1] = function(self,ply)
	end,
	[2] = function(self,ply)
		self.weaponAng[3] = self.weaponAng[3] - 15
	end,
	[3] = function(self, ply, force)
		if self:IsZoom() and not force then return end
		self.weaponAng:Add( (self:IsPistolHoldType() or self.CanEpicRun) and angPosture3pistol or angPosture3)
	end,
	[4] = function(self, ply, force)
		if self:IsZoom() and not force then return end
		self.weaponAng:Add((self:IsPistolHoldType() and angPosture7) or (ply:IsFlagSet(FL_ANIMDUCKING) and angPosture8 or angPosture4))
		--self.weaponAng[2] = self.weaponAng[2] - 12
	end,
	[5] = function(self,ply)
		self.weaponAng[3] = self.weaponAng[3] - (self:IsZoom() and 0 or 20)
	end,
	[6] = function(self,ply)
		if self:IsZoom() then return end
		self.weaponAng[3] = self.weaponAng[3] + 20
	end,
	[9] = function(self,ply)
		if self:IsZoom() then return end
		self.weaponAng[3] = self.weaponAng[3] - 40
	end,
}
SWEP.lerpaddcloseanim = 0
SWEP.closeanimdis = 40
SWEP.WepAngOffset = Angle(0,0,0)
SWEP.weaponAngLerp = Angle(0,0,0)

local tickInterval = engine.TickInterval -- gde
local hook_Run = hook.Run

function SWEP:ChangeGunPos(dtime)
	local ply = self:GetOwner()
	if not IsValid(ply) then return end
	if not ply:IsPlayer() then return end

	if ply.suiciding then self.weaponAngLerp:Zero() self.weaponAng:Zero() return end
	
	local fakeRagdoll = IsValid(ply.FakeRagdoll)

	local inuse = self:InUse()
	
	local should = true and not (fakeRagdoll and not (inuse))

	self.lerped_positioning = Lerp(hg.lerpFrameTime2(0.1, dtime), self.lerped_positioning or 0, should and 1 or 0.3)
	self.lerped_angle = Lerp(hg.lerpFrameTime2(0.1, dtime), self.lerped_angle or 0, should and 1 or (hg.KeyDown(owner, IN_ATTACK2) and 1 or 0))
	self.restlerp = Lerp(hg.lerpFrameTime(0.0001, dtime), self.restlerp or 0, self:IsResting() and 1 or 0)

	self.weaponAng[1] = 0
	self.weaponAng[2] = 0
	self.weaponAng[3] = 0
	
	if ply.viewingGun and ply.viewingGun > CurTime() then
		self.weaponAng:Add(Angle(math.sin(ply.viewingGun - CurTime()) * -5, math.sin(ply.viewingGun - CurTime()) * -5, math.cos(ply.viewingGun+1.5 - CurTime()) * 30))
		ply.viewingGun = not (self:KeyDown(IN_ATTACK2) or self:KeyDown(IN_ATTACK)) and ply.viewingGun or nil
	end
	
	local huya = false//self.lerpaddcloseanim > (self:IsPistolHoldType() and 0.7 or 0.39)
	local func = hg.postureFuncWorldModel[ply:GetNWFloat("InLegKick",0) > CurTime() and 3 or self.reload and 0 or (self:IsSprinting() or huya) and ((ply.posture == 3 and 3) or ((ply.posture == 3 or fakeRagdoll) and 3) or (self:IsPistolHoldType() and 3 or 3)) or ply.posture] or funcNil
	
	if not self.inspect then
		func(self, ply, huya)
	end

	if (ply.posture == 7 or ply.posture == 8) and not self.reload and not ply.suiciding then
		--gangsta mode!!!
		if ply.posture == 7 then
			self.weaponAng[3] = self.weaponAng[3] - (not self:IsZoom() and 60 or 0)
		else
			self.weaponAng[3] = self.weaponAng[3] - (not self:IsZoom() and 10 or 0)
		end
		self.setlhik = false
	end

	--self.weaponAng[1] = self.weaponAng[1] + math.Clamp(((self.deploy and ((self.deploy - CurTime())) or self.holster and (((self.CooldownDeploy / self.Ergonomics) - (self.holster - CurTime()))) or 0) / (self.CooldownDeploy / self.Ergonomics)) * 90,0,90)
	--self.weaponAng[2] = self.weaponAng[2] - math.Clamp(((self.deploy and ((self.deploy - CurTime())) or self.holster and (((self.CooldownDeploy / self.Ergonomics) - (self.holster - CurTime()))) or 0) / (self.CooldownDeploy / self.Ergonomics)) * 90,0,90)

	local _, anga = LocalToWorld(vecZero, self.WepAngOffset, vecZero, self.weaponAng)
	
	self.weaponAng = anga

	--self.weaponAng:Add((self.reload and self.reload - 0.5 > CurTime()) and not fakeRagdoll and angReload or angZero)
	--local animpos = self:GetAnimShoot2(0.15,self.podkid or self:IsPistolHoldType()) * 2 / ((self.weight or 1))
	--local dtime = SysTime() - (self.timetick or SysTime())
	--
	--self.weaponAng[2] = self.weaponAng[2] - animpos * -10 * (self.podkid or 5)
	
	--self.weaponAngLerp = Lerp(hg.lerpFrameTime2(0.1,dtime) * self.Ergonomics, self.weaponAngLerp or Angle(0, 0, 0), self.weaponAng)
	
	self.timetick = SysTime()
end

function SWEP:DrawPost() end

--[[ 
	self.WepPosOffset
	self.WepAngOffset
--]]

local veccopy = Vector(0,0,0)

local vecZero = Vector(0,0,0)
local angZero = Angle(0,0,0)

SWEP.fuckhands = 0

local math_ApproachAngle = math.ApproachAngle

local torsoadd = Vector(5,5,3)

SWEP.prankang = Angle(0,0,0)

local hg_setzoompos = CreateClientConVar("hg_setzoompos", "0", false, false, "settingzoom", 0, 1)
local developer = GetConVar("developer")

local localPos = Vector()
local localAng = Angle()

function SWEP:RestedAnim(pos, ang, dtime)
    return pos, ang
end

local hg_gary = CreateClientConVar("hg_gary", "0", false, true, "center weapon in fake", 0, 1)

function SWEP:PosAngChanges(ply, desiredPos, desiredAng, bNoAdditional, closeanim, dtime)
	desiredPos = desiredPos or vecZero
	desiredAng = desiredAng or angZero
	
    if ply:IsNPC() then
        return desiredPos, desiredAng
    end
	
	local ent = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or ply
	--ent = IsValid(ply.OldRagdoll) and ply.OldRagdoll:IsRagdoll() and ply.OldRagdoll or ent

	local inuse = self:InUse()
		
	self.setrhik = true
	self.setlhik = !self:IsPistolHoldType() or !ply.suiciding
	self.setlhik = (not (ply.posture == 7 or ply.posture == 8 or ( (self:IsPistolHoldType() or self.CanEpicRun) and self:IsSprinting() and !(ply.organism and ply.organism.rarmamputated) ) or (self:IsPistolHoldType() and ply.posture == 9) or (self:IsPistolHoldType() and ply.suiciding) ) or self.reload and self.setlhik or false)
	self.setlhik = !(self:IsPistolHoldType() and (self:GetButtstockAttack() - CurTime() > -0.5)) and self.setlhik
	
	local tr = hg.eyeTrace(ply, 60, ent)
	if not tr then return end
	local pos = tr.StartPos - tr.Normal:Angle():Up() * 1
	local wepang = ply:GetAimVector():Angle()

	wepang:Normalize()

	if not bNoAdditional then wepang[1] = math_ApproachAngle(wepang[1], 0, wepang[1] * self.pitch) end

	local ang = wepang
	
	if ent ~= ply then
		local gary = math.Round(ply:GetInfoNum("hg_gary", 0)) == 1

		local att_Ang = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Head1")):GetAngles()
		att_Ang:RotateAroundAxis(att_Ang:Up(), -90)
		att_Ang:RotateAroundAxis(att_Ang:Forward(), -90)
		att_Ang:RotateAroundAxis(att_Ang:Right(), 15)
		--debugoverlay.Line(pos + Vector(5, 0, 0), pos + att_Ang:Forward() * 555, 1, color_white, true)
		local _, ot = WorldToLocal(vector_origin, ang, vector_origin, att_Ang)
		ot:Normalize()
	
		local use = self:InUse()
		local fourtyfive = 45 * (use and 1 or 0)
		ot[2] = math.Clamp(ot[2], -fourtyfive, fourtyfive)
		ot[1] = math.Clamp(ot[1], -fourtyfive, fourtyfive)
	
		local _, angEye = LocalToWorld(vector_origin, ot, vector_origin, att_Ang)
		angEye:Normalize()
		
		ang = gary and att_Ang or angEye

		ang[3] = gary and (ang[3] + 90) or (ang[3] + (ply:EyeAngles()[3]) + 90)
	else
		ang[3] = ang[3] + (ply:EyeAngles()[3]) + 90
	end
	
	local pranktime = CurTime() / 20
	
	if not (IsValid(lply) and lply:IsSuperAdmin() and hg_setzoompos:GetBool()) then
		self.prankang[2] = 4 * math.cos(pranktime) * math.sin(pranktime - 2) * math.cos(pranktime + 1)
		self.prankang[1] = 2 * math.sin(pranktime) * math.sin(pranktime - 5) * math.cos(pranktime + 15)
	end

	if ply.posture == 7 or ply.posture == 8 then
		self.prankang = self.prankang * 2
	end

	ang[2] = ang[2] + self.prankang[2]
	ang[1] = math.Clamp(ang[1] + self.prankang[1], -90, 90)

	if CLIENT and self:IsLocal() then
		ang[3] = ang[3] + position_difference3[2] * -4 - GetViewPunchAngles2()[2] * 0.25
	end
	self.fuckingfuckangle = ang
	self.fuckingfuckpos = pos
	desiredPos, desiredAng = LocalToWorld(self.RHPos + (bNoAdditional and vector_origin or (self.AdditionalPos + self.AdditionalPos2)), bNoAdditional and angle_zero or (self.AdditionalAng + self.AdditionalAng2), pos, ang)
	desiredAng[3] = desiredAng[3] + 90
    
	local restpos

    if self:GetNWVector("RestPos") and IsValid(self:GetNWEntity("RestEntity")) or self:GetNWEntity("RestEntity"):IsWorld() then
		local posa, anga2, anga = self:GetBipodPosAng()

        restpos = LocalToWorld(self:GetNWVector("RestPos"), angle_zero, posa, anga)
    end
	
    if restpos then
        localPos:Zero()
        localAng:Zero()

        local lpos, lang = self:RestedAnim(localPos, localAng, dtime)

        desiredPos = LocalToWorld(LerpVector(self.restlerp, vector_origin, -self.RestPosition - self.WorldPos) + lpos, lang, LerpVector(self.restlerp, desiredPos, restpos), desiredAng)
    end

	local x,y,z = hg.GunPositions[ply] and hg.GunPositions[ply][1], hg.GunPositions[ply] and hg.GunPositions[ply][2], hg.GunPositions[ply] and hg.GunPositions[ply][3]
	
	veccopy.x = x or 0
	veccopy.x = ((ply.posture == 7 or ply.posture == 8) and not self.reload) and 1 or veccopy.x
	veccopy.y = -(y or 0)
	veccopy.z = z or 0

	local willsuicide = ply:GetNWFloat("willsuicide", 0)
	if ply.suiciding then--willsuicide > 0 then
		local amt = 0.05 * math.Clamp(((ply.organism and ply.organism.heartbeat or 70) - 70) / 50, 0, 1)
		if willsuicide > 0 then
			amt = amt * (1 - math.max((willsuicide - CurTime()) / 5, 0))
		else
			amt = amt * (1 - math.max(((ply.startsuicide or CurTime()) - CurTime() + 1), 0))
		end
		desiredPos[1] = desiredPos[1] + math.Rand(-amt, amt)
		desiredPos[2] = desiredPos[2] + math.Rand(-amt, amt)
		desiredPos[3] = desiredPos[3] + math.Rand(-amt, amt)
	end
	
	local angnorm = ang:Forward():Angle()

	desiredPos = LocalToWorld(veccopy, angZero, desiredPos, angnorm)

	desiredPos:Add(desiredAng:Up() * 1)
	
	local matr = Matrix()
	--matr:SetAngles(self.LocalMuzzleAng - self.WorldAng)
	--matr:Invert()
	desiredPos, desiredAng = LocalToWorld(matr:GetTranslation(), matr:GetAngles(), desiredPos, desiredAng)

    return desiredPos, desiredAng
end

if SERVER then return end

local function remove(self, model)
    model:Remove()
end
--SWEP.drawDtime = SysTime() - 0.01
SWEP.FakeViewBobBone = ""
SWEP.FakeViewBobBaseBone = ""
local vec = Vector(1.3,0.2,4.5)
local lpos, lang = Vector(-5,0,0), Angle(0,0,0)
local lpos2, lang2 = Vector(0,5,0), Angle(0,0,0)
local reloadlerp = 0
SWEP.GetDebug = false

local function DrawWorldModel(self, force)
	if RENDERING_SCOPE == self then return end
	if not IsValid(self) or not self.WorldModel_Transform then return end
	local owner = self:GetOwner()
	
	if IsValid(owner) and (owner != lply) and not owner.shouldTransmit or owner.NotSeen then
		return
	end

	if not IsValid(self.worldModel) then
		self.worldModel = self:CreateWorldModel()
	end

	local willdraw = false
	
	local localdraw = (self:IsLocal2() and (owner:GetActiveWeapon() == self)) and not force
	
	if not owner:IsNPC() then self:DrawPost() end
	//self.worldModel:SetRenderOrigin(self:GetPos())
	//self.worldModel:SetPos(self:GetPos())
	
	if not localdraw then
		if IsValid(owner) and (owner.GetActiveWeapon and (owner:GetActiveWeapon() ~= self) or owner:IsRagdoll()) then
			if not self.shouldntDrawHolstered then
				self:WorldModel_Transform_Holstered()
				willdraw = true
			else
				if IsValid(self.worldModel) then
					//self.worldModel:Remove()
					self.worldModel:SetNoDraw(true)
				end
				self:ClearAttModels()
				return
			end
		elseif owner:IsNPC() or owner.GetActiveWeapon and owner:GetActiveWeapon() == self then
			self:WorldModel_Transform()
			
			if self.deploy then
				self:WorldModel_Transform_Holstered()
			end
			willdraw = true
		elseif not IsValid(owner) then
			self:WorldModel_Transform()
			willdraw = true
		end
	else
		willdraw = true
	end

	if self:IsLocal() then
		--hg.StartCaptureRender()
	end

	if IsValid(self.worldModel) and willdraw then
		if self:ShouldUseFakeModel() then
			if self:IsLocal2() then
				local WorldModel = self.worldModel
				if not IsValid(WorldModel) then return end
				--[[reloadlerp = Lerp(FrameTime() * 3, reloadlerp, self.reload == nil and 0 or 2)
				if reloadlerp >= 0.3 then
					DrawBokehDOF(reloadlerp, 2, 0)
				end]]
				local camBone = (WorldModel:LookupBone(self.FakeViewBobBone) or (self.FakeVPShouldUseHand and WorldModel:LookupBone("ValveBiped.Bip01_R_Hand") or WorldModel:LookupBone("Weapon"))) or WorldModel:LookupBone("ValveBiped.Bip01_R_Hand")
				if camBone then
					local matrix = WorldModel:GetBoneMatrix(camBone)
					if matrix then
						local gAngles = matrix:GetAngles()
						local _,gAngles = WorldToLocal(vector_origin,gAngles, WorldModel:GetPos(), WorldModel:GetBoneMatrix(WorldModel:LookupBone(self.FakeViewBobBaseBone) or 0):GetAngles())
						self.OldAngPunch = self.OldAngPunch or gAngles
						local punch = ( self.OldAngPunch - gAngles )/(self.ViewPunchDiv or 50)
						--print(punch)
						ViewPunch2( -punch )
						ViewPunch( punch )
						self.OldAngPunch = gAngles
					end
				end
			end
			
			if self.seq then self:GetWM():SetSequence(self.seq) end
			local timing
			if not self.cycling then
				timing = (1 - math.Clamp((self.animtime - CurTime()) / self.animspeed, 0, 1))
				timing = self.reverseanim and (1 - timing) or timing
				self.worldModel:SetCycle(timing)

				if self.callback and timing == ((not self.reverseanim) and 1 or 0) then
					self.callback(self)
					self.callback = nil
				end
			else
				timing = ((CurTime() - (self.animtime - self.animspeed)) % self.animspeed) / self.animspeed
				self.worldModel:SetCycle(timing)
			end
		end
		
		/*SWEP.MagModel = "models/btk/nam_akmmag.mdl" 

		SWEP.lmagpos = Vector(0,0,0)
		SWEP.lmagang = Angle(0,0,0)
		SWEP.lmagpos2 = Vector(0,0,0)
		SWEP.lmagang2 = Angle(0,0,0)*/
		if self.GetDebug and LocalPlayer():IsSuperAdmin() and self:ShouldUseFakeModel() and IsValid(self:GetWM()) then
			local matrix = self:GetWM():GetBoneMatrix(isnumber(self.FakeMagDropBone) and self.FakeMagDropBone or self:GetWM():LookupBone(self.FakeMagDropBone or "Magazine") or self:GetWM():LookupBone("ValveBiped.Bip01_L_Hand"))
			if matrix then
				local lpos, lang = self.lmagpos or lpos, self.lmagang or lang
				local lpos2, lang2 = self.lmagpos2 or lpos2, self.lmagang2 or lang2
				local pos = matrix:GetTranslation()
				local ang = matrix:GetAngles()
				local pos, ang = LocalToWorld(lpos2, lang2, pos, ang)
				ang:RotateAroundAxis(ang:Up(),-90)

				local invmat = Matrix()
				invmat:SetTranslation(lpos)
				invmat:SetAngles(lang)
				invmat:Invert()
				
				local newmat = Matrix()
				newmat:SetTranslation(pos)
				newmat:SetAngles(ang)
				newmat = newmat * invmat
				local pos = newmat:GetTranslation()
				local ang = newmat:GetAngles()
				
				self.OwOmodel = IsValid(self.OwOmodel) and self.OwOmodel or ClientsideModel(self.MagModel or "models/weapons/upgrades/w_magazine_m1a1_30.mdl")
				debugoverlay.BoxAngles( pos, vec, -vec, ang, 0.1, Color(255,0,0))
				local pos, ang = LocalToWorld(lpos, lang, pos, ang)
				self.OwOmodel:SetNoDraw(true)
				self.OwOmodel:SetMaterial("models/wireframe")
				self.OwOmodel:SetPos(pos)
				self.OwOmodel:SetAngles(ang)
				self.OwOmodel:DrawModel()

				self.worldModel:CallOnRemove("removeMreowu", function()
					if IsValid(self.OwOmodel) then self.OwOmodel:Remove() end
				end)
			end
		else
			if IsValid(self.OwOmodel) then self.OwOmodel:Remove() end
		end
		--hg.StartCaptureRender()
		self.worldModel:SetupBones()
		self.worldModel:DrawModel()
		
		if self.GetDebug and LocalPlayer():IsSuperAdmin() and self:ShouldUseFakeModel() and IsValid(self:GetWM()) then
			self:DrawModel()
		end
	end
	
	if willdraw then
		self:DrawAttachments()
	end

	if self:IsLocal() then
		--render.BlurRenderTarget(hg.GetCaptureTex(), 1, 1, 2)
	end

	--if self.dort then self:DoRT() end

	if self:IsLocal() then
		--hg.EndCaptureRender()

		--hg.DrawCaptured()
	end
end

hg.DrawWorldModel = DrawWorldModel

//hg.models = hg.models or {}

function SWEP:CreateWorldModel()
	if not IsValid(self) then return end
	
	local model = ClientsideModel(self.WorldModelFake or self.WorldModel)
	self.worldModel = model

	--[[for i, tex in ipairs(model:GetMaterials()) do
		local mat = Material(tex)
		PrintTable(mat:GetKeyValues())
		--"$color2"						"[0.7 0.7 0.7]"
	--"$blendTintByBaseAlpha"			"1"
		mat:SetInt("$blendTintByBaseAlpha", 1)
		mat:SetVector("$color2", Vector(1, 1, 1))
		--mat:SetString("$color2", "[0.7 0.7 0.7]")
		--mat:SetInt("$blendTintByBaseAlpha", 0)
		--mat:SetInt("$notint", 0)
		--mat:SetInt("$allowdiffusemodulation", 0)
		--mat:SetInt("$blendtintcoloroverbase", 0)
		--mat:SetVector("$color2", Vector(255, 255, 255))
		print(mat:GetString("$color2"), mat:GetString("$phongalbedotint"))
	end--]]

	for i = 0, 6 do
		model:SetBodygroup(i, self:GetBodygroup(i))
	end

	if self.WorldModelFake then
		if self.FakeScale then model:SetModelScale(self.FakeScale,0) end
		self.attackanim = 0
		self.sprintanim = 0
		self.animtime = 0
		self.animspeed = 1
		self.reverseanim = false

		if self.FakeBodyGroups then
			model:SetBodyGroups(self.FakeBodyGroups)
		end
		local swep = self
		function model:GetShellColor()
			local ammotype = hg.ammotypeshuy[swep.Primary.Ammo].BulletSettings
			return ammotype.ShellColor or color_white
		end

		self:PlayAnim("idle", 1, false)
	end

	if self.ModelCreated then
		self:ModelCreated(model)
	end

	//hg.models[model:GetModel()] = model
	
	model:SetNoDraw(true)
	model:SetOwner(self)
	model:SetRenderOrigin(self:GetPos())
	model:SetPos(self:GetPos())
	--debug.Trace()
	model.RenderOverride = function(self)
		local model = self
		local self = self:GetOwner()
		if not IsValid(self) then return end
		model:SetPos(self:GetPos())
		model:DrawModel()
		--DrawWorldModel(self)
	end
	
	self:CallOnRemove("clientsidemodel", function() model:Remove() end)
	model:CallOnRemove("removeAtts", function() hg.ClearAttModels(model) end)
	
	if IsValid(model) then
		if self.MagIndex then
			self:GetWM():ManipulateBoneScale(self.MagIndex, vector_origin)
		end
	end

	--self:WorldModel_Transform(true)
	return model
end

local vecZero = Vector(0, 0, 0)
local angZero = Angle(0, 0, 0)
local math_max = math.max

hook.Add("NotifyShouldTransmit", "PvsThingy", function(ent, shouldTransmit)
	ent.shouldTransmit = shouldTransmit
	
	if !shouldTransmit and ishgweapon(ent) then
		if IsValid(ent.worldModel) then
			ent.worldModel:Remove()
		end
	end
end)

function SWEP:WorldModel_Transform(bNoApply, bNoAdditional, model)
	local model, owner = model or self.worldModel, self:GetOwner()
	if not IsValid(model) then self.worldModel = self:CreateWorldModel() model = self.worldModel end
	
	if IsValid(owner) and (owner:IsNPC() or owner:IsPlayer()) then
		local ent = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or owner
		local inuse = self:InUse()
		
		local dtime = SysTime() - (self.last_transform or SysTime())
		self.last_transform = SysTime()

		local should = hg.ShouldTPIK(owner) and not (ent ~= owner and not (inuse))
		if not should and not IsValid(owner.FakeRagdoll) then
			if IsValid(model) then
				-- local ownAngs = owner:EyeAngles()
				-- model:SetRenderAngles(ownAngs)
				-- model:SetRenderOrigin(owner:EyePos() + ownAngs:Forward() * 15 + owner:GetUp() * -10)

				model:SetModel(self.WorldModel)
				model:AddEffects(EF_BONEMERGE)
				model:SetParent(owner)
				model:Remove()
				model = nil
			end

			return
		end
		
		-- if not should then ent:SetupBones() end
		
		local RHand = ent:LookupBone("ValveBiped.Bip01_R_Hand")
		
		if not RHand then return end

		local matrixR = ent:GetBoneMatrix(RHand) or ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_R_Forearm"))
		
		if not matrixR then 
			//matrixR = Matrix()
			//local att = ent:GetAttachment(ent:LookupAttachment("anim_attachment_RH"))
			//matrixR:SetTranslation(att.Pos)
			//matrixR:SetAngles(att.Ang)
			return
		end
		
		local aimvec = ent:IsNPC() and matrixR:GetAngles() or owner:GetAimVector():Angle()

		//self:ChangeGunPos()
		
		local matrixRAngRot = matrixR:GetAngles()
		matrixRAngRot:RotateAroundAxis(matrixRAngRot:Forward(),180)
		local lerp = self:KeyDown(IN_ATTACK2) and 1 or 1
		local _, ang = WorldToLocal(vecZero,matrixRAngRot,vecZero,aimvec)
		ang = ang * lerp
		local _,ang = LocalToWorld(vecZero,ang,vecZero,aimvec)
		ang[3] = matrixRAngRot[3]
		local desiredAng = ((ent~=owner)) and ang or aimvec
		desiredAng[3] = desiredAng[3] + (owner:EyeAngles()[3])
		desiredAng:RotateAroundAxis(desiredAng:Forward(), ent:IsNPC() and 0 or 180)
		local desiredPos = matrixR:GetTranslation()
		
		--local oldPos = -(-desiredPos)
		--local oldAng = -(-desiredAng)
				
		if !owner:IsNPC() then//should then
			local desiredPos1, desiredAng1 = self:PosAngChanges(owner, desiredPos, desiredAng, bNoAdditional, nil, dtime)
			
			desiredPos = LerpVector(self.lerped_positioning or 0, desiredPos, desiredPos1)
			desiredAng = LerpAngle(self.lerped_angle or 0, desiredAng, desiredAng1)
			--self.lastTpikPos = desiredPos
			--self.lastTpikAng = desiredAng
		end
		
		--self.fuckhands = LerpFT(0.1, self.fuckhands, self.setrhik and 1 or 0)

		--desiredPos = LerpVector(self.fuckhands, oldPos, self.lastTpikPos or desiredPos)
		--desiredAng = LerpAngle(self.fuckhands, oldAng, self.lastTpikAng or desiredAng)

		local newPos, newAng = LocalToWorld(self.WorldPos, self.WorldAng + (self.WorldAng2 or angle_zero), desiredPos, desiredAng)
		newAng:RotateAroundAxis(newAng:Forward(), 180)
		
		if self:ShouldUseFakeModel() then
			newPos, newAng = LocalToWorld(self.FakePos, self.FakeAng, newPos, newAng)
		end
		
		if bNoApply then
			return newPos, newAng, desiredPos, desiredAng
		end

		self.desiredPos, self.desiredAng = newPos, newAng
		self.handPos, self.handAng = desiredPos, desiredAng
		
		model:SetRenderOrigin(newPos)
		model:SetRenderAngles(newAng)
		model:SetPos(newPos)
		model:SetAngles(newAng)
		self:DrawShadow(true)
	else
		local pos, ang = self:GetPos(), self:GetAngles()

		if self:ShouldUseFakeModel() then
			pos, ang = LocalToWorld(self.FakePos, self.FakeAng, pos, ang)
		end
		
		model:SetRenderOrigin(pos)
		model:SetRenderAngles(ang)
		model:SetPos(pos)
		model:SetAngles(ang)
		self:DrawShadow(false)
	end
end

local noSlingBone = "ValveBiped.Bip01_Pelvis"
local noSlingPos = Vector(9, 3, 0)
local noSlingAng = Angle(-70, 90, 180)

SWEP.holsteredBone = "ValveBiped.Bip01_Spine2"
SWEP.holsteredPos = Vector(5, 8, -4)
SWEP.holsteredAng = Angle(210, 0, 180)

SWEP.addAngle = Angle(0, 0, 0)
local addAngle = Angle(0, 0, 0)
local addHolsterPos = Vector(0, 1, 0)

function SWEP:WorldModel_Transform_Holstered()
	local model, owner = self.worldModel, self:GetOwner()
	if not IsValid(model) then model = self:CreateWorldModel() end
	
	local ent = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or owner
	
	if not IsValid(ent) then
		model:SetNoDraw(true)
		return
	end

	local inv = owner:IsPlayer() and owner:GetNetVar("Inventory")
	
	if IsValid(ent) then
		local noSling = inv and (not inv["Weapons"] or not inv["Weapons"]["hg_sling"]) and not self.shouldntDrawHolstered
		--if noSling then self:WorldModel_Transform() return end
		--потом...
		--local bone = noSling and noSlingBone or self.holsteredBone
		--local pos = noSling and noSlingPos or self.holsteredPos
		--local ang = noSling and noSlingAng or self.holsteredAng
		local bone = self.holsteredBone
		local pos = self.holsteredPos
		local ang = self.holsteredAng

		local matrix = ent:GetBoneMatrix(ent:LookupBone(bone))
		if not matrix then return end
		local localPos, localAng = pos, ang
		
		local ang = owner:GetAngles()
		
		if owner:IsPlayer() then
			ang = owner:EyeAngles()
			ang[1] = 0
			local vel = ent:GetVelocity()
			local dotforward = vel:Dot(ang:Forward())
			local dotright = vel:Dot(ang:Right())
			
			addAngle[2] = math.Clamp(-dotforward / 3, -1, 10) + math.abs(math.Clamp(dotright / 1, -3, 3))
			addAngle[1] = math.Clamp(dotright / 3, -10, 10)
			
			self.addAngle = LerpAngleFT(0.05, self.addAngle, addAngle)
		else
			addAngle:Zero()
		end

		local desiredPos, desiredAng = LocalToWorld(localPos, localAng, matrix:GetTranslation(), matrix:GetAngles())
		
		desiredAng:RotateAroundAxis(ang:Right(), self.addAngle[2])
		desiredAng:RotateAroundAxis(ang:Forward(), self.addAngle[1])

		local newPos, newAng = LocalToWorld(self.WorldPos, self.WorldAng, desiredPos, desiredAng)
		if self:ShouldUseFakeModel() then
			newPos, newAng = LocalToWorld(self.FakePos, self.FakeAng, newPos, newAng)
		end
		local booba = self.deploy
		local booba2 = self.deploy and (self.CooldownDeploy / self.Ergonomics)
		
		local lerp = (not booba) and 0 or math.Clamp(1 - ((booba - CurTime()) / booba2) * 1.2, 0, 1)
		lerp = math.ease.InOutExpo(lerp)
		
		local newPos = LerpVector(lerp, newPos, model:GetPos())
		local newAng = LerpAngle(lerp, newAng, model:GetAngles())
		
		local matrix = Matrix()
		matrix:SetTranslation(self.WorldPos)
		matrix:SetAngles(self.WorldAng)
		local newmat = matrix:GetInverse()
		local ang = -(-newAng)
		ang:RotateAroundAxis(ang:Forward(),180)
		
		local desiredPos, desiredAng = LocalToWorld(newmat:GetTranslation(), newmat:GetAngles(), newPos, ang)

		self.handPos, self.handAng = desiredPos, desiredAng

		self.holstercheckwait = CurTime()--FUCKING FUCK

		model:SetRenderOrigin(newPos)
		model:SetRenderAngles(newAng)
		model:SetPos(newPos)
		model:SetAngles(newAng)
		self.desiredPos = newPos
		self.desiredAng = newAng
	else
		local pos, ang = self:GetPos(), self:GetAngles()

		if self:ShouldUseFakeModel() then
			pos, ang = LocalToWorld(self.FakePos, self.FakeAng, pos, ang)
		end

		model:SetRenderOrigin(pos)
		model:SetRenderAngles(ang)
		model:SetPos(pos)
		model:SetAngles(ang)
		model:SetRenderOrigin()
		model:SetRenderAngles()
	end
end

function SWEP:ClearAttModels()
	if self.modelAtt then
		for atta, model in pairs(self.modelAtt) do
			if not atta or not IsValid(self.modelAtt[atta]) then continue end
			if IsValid(model) then model:Remove() end
			self.modelAtt[atta] = nil
		end
	end
end

function hg.ClearAttModels(model)
	if model.modelAtt then
		for atta, modela in pairs(model.modelAtt) do
			if not atta or not IsValid(modela) then continue end
			if IsValid(modela) then modela:Remove() end
			model.modelAtt[atta] = nil
		end
		model.modelAtt = nil
	end
end

local function removeFlashlights(self)
	if self.flashlight and self.flashlight:IsValid() then
		self.flashlight:Remove()
		self.flashlight = nil
	end
end

function SWEP:DrawWorldModel()
	local owner = self:GetOwner()
	if IsValid(owner) and owner:IsNPC() then
		DrawWorldModel(self)
		//self:DrawModel()
	end

	if CLIENT then
		if self.Primary.Next + 1 < CurTime() then 
			self.dmgStack = 0
			self.dmgStack2 = Lerp(hg.lerpFrameTime2(0.001,dtime), self.dmgStack2, 0)
		end
	end

	if (not IsValid(owner)) then
		//self:SetupBones()
		//self:SetRenderOrigin()
		//self:SetRenderAngles()
		//self:DrawModel()
		//self:DrawPost()
		//self:DrawAttachments()
		//if IsValid(self.worldModel) then
			--[[self.worldModel:SetupBones()
			self.worldModel:SetRenderOrigin(self:GetPos())
			self.worldModel:SetRenderAngles(self:GetAngles())
			self.worldModel:SetPos(self:GetPos())
			self.worldModel:SetAngles(self:GetAngles())
			self.worldModel:DrawModel()--]]
			DrawWorldModel(self)
		//end
	end
end

--hook.Add("PostDrawPlayerRagdoll", "huyCock", function(ent,owner)
function hg.RenderWeapons(ent, owner)
	local wep = owner.GetActiveWeapon and owner:GetActiveWeapon()
	
	if IsValid(wep) and wep.ishgweapon then
		DrawWorldModel(wep)
    end

	if owner.GetWeapons then
		local weps = owner:GetWeapons()
		for i = 1, #weps do
			local wep2 = weps[i]
			if wep2.ishgweapon and wep2 ~= wep then
				DrawWorldModel(wep2)
			end
		end
	end

	local inv = ent:GetNetVar("Inventory",nil) or ent.PredictedInventory
	if ent == owner and not owner:IsPlayer()  and inv != nil and inv["Weapons"] then
		if not ent.shouldTransmit then return end
		if ent.NotSeen then return end
	
		for i, wep in pairs(inv["Weapons"]) do
			if isbool(wep) then continue end
			if not IsValid(wep) or not wep.ishgweapon then continue end
			wep:SetOwner(ent)
			DrawWorldModel(wep)
		end

	end
end
--end)

local table_IsEmpty = table.IsEmpty
local string_find = string.find

hook.Add("PostDrawTranslucentRenderables", "huyCock333", function()
	hg.weapons = hg.weapons or {}
	for i=1, #hg.weapons do
		self = hg.weapons[i]
		if not IsValid(self) then table.remove(hg.weapons,i) continue end
		if IsValid(self:GetOwner()) and self:GetOwner().GetActiveWeapon and self:GetOwner():GetActiveWeapon() ~= self and self.shouldntDrawHolstered then removeFlashlights(self) continue end
		if not self.attachments then continue end
		if not self.lasertoggle then removeFlashlights(self) end
		if self.attachments.underbarrel and not table_IsEmpty(self.attachments.underbarrel) and string_find(self.attachments.underbarrel[1], "laser") or self.laser then self:DrawLaser() end
	end
end)

function SWEP:ShouldDrawViewModel()
	return false
end


