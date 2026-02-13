--
local vecZero, angZero = Vector(0, 0, 0), Angle(0, 0, 0)
local eyeAngL = EyeAngles()
local angZoom = Angle(0, 0, 0)
local k, k2, passive = 0, 0, 0
local vec1 = Vector(-1, 0, 0)
local angfuk23 = Angle(0,0,0)

SWEP.ZoomPos = Vector()
SWEP.attAng = Angle(0, 0, 0)
SWEP.attPos = Vector(0, 0, 0)

SWEP.Ergonomics = 1

local Lerp, LerpVector, LerpAngle = Lerp, LerpVector, LerpAngle
local ply
local math_sin, math_cos = math.sin, math.cos
local math_Clamp = math.Clamp
local CurTime = CurTime
local gun
local traceBuilder = {}
local util_TraceLine = util.TraceLine
local dof_zoom = 0
disthuy = 0
local angRandLerp = Angle(0,0,0)
local angle_spray = Angle(0,0,0)
local fovlerp = 0

local hg_setzoompos = CreateClientConVar("hg_setzoompos", "0", false, false, "settingzoom", 0, 1)
local hg_gun_cam = CreateClientConVar("hg_gun_cam", "0", false, false, "settingzoom", 0, 1)
local hg_realismcam = ConVarExists("hg_realismcam") and GetConVar("hg_realismcam") or CreateClientConVar("hg_realismcam", "0", true, false, "realism camera", 0, 1)

local zoomPosSetter = Vector()
local isSettingZoom = false

hook.Add("HG.InputMouseApply", "huyUwU", function(tbl)
	if IsValid(lply) and lply:IsSuperAdmin() and hg_setzoompos:GetBool() and lply:KeyDown(IN_ATTACK2) then
		zoomPosSetter:Add(Vector(tbl.cmd:GetMouseWheel(), -tbl.x / 500, -tbl.y / 500))
		local str = "SWEP.ZoomPos = Vector("..math.Round(zoomPosSetter[1], 4)..", "..math.Round(zoomPosSetter[2], 4)..", "..math.Round(zoomPosSetter[3], 4)..")"

		print(str)
		SetClipboardText(str.."\n")

		tbl.x = 0
		tbl.y = 0

		isSettingZoom = true
	else
		isSettingZoom = false
	end
end)

function SWEP:GetZoomPos(recoilZoomPos, view, eyePos)
	recoilZoomPos = recoilZoomPos or vecZero
	gun = IsValid(gun) and gun or self:GetWeaponEntity()
	local pos, ang = gun:GetPos(), gun:GetAngles()

	if self.WorldModelFake then
		local mat = Matrix()
		mat:SetTranslation(self.FakePos)
		mat:SetAngles(self.FakeAng)
		mat = mat:GetInverse()
		pos, ang = LocalToWorld(mat:GetTranslation(), mat:GetAngles(), gun:GetPos(), gun:GetAngles())
	end

	if LocalPlayer():IsAdmin() and hg_gun_cam:GetBool() then
		local att = self:GetWM():GetAttachment(1)
		local mat = Matrix()
		mat:SetTranslation(self.FakePos)
		mat:SetAngles(self.FakeAng)
		mat = mat:GetInverse()
		pos, ang = LocalToWorld(mat:GetTranslation(), mat:GetAngles(),att.Pos 
			+ att.Ang:Up() * (self.GunCamPos and self.GunCamPos["x"] or 5) 
			+ att.Ang:Forward() * (self.GunCamPos and self.GunCamPos["y"] or -10) 
			+ att.Ang:Right() * ( self.GunCamPos and self.GunCamPos["z"] or -4.2), 
		att.Ang)

		return pos, ang
	end

	local zoomPos = -(-self.ZoomPos)
	if isSettingZoom then
		zoomPos = zoomPosSetter
	end
	
	local pos2, ang2 = self:GetTrace(true, nil, nil, true)

	local posZoom = LocalToWorld(zoomPos, angle_zero, pos, ang2)
	
	local override = self:GetCameraOverride(view)
	if override then
		posZoom = override
	end
	
	local viewangs = self.prankang + view.angles
	--posZoom:Add(viewangs:Forward() * -10)

	if eyePos then
		if self:HasAttachment("sight","optic") then
			posZoom = posZoom - recoilZoomPos * 0.25 - ang2:Forward() * (self.AdditionalPos2[1]) * 0.5 + ang2:Forward() * 1
		else
			local _, hitpos, dist = util.DistanceToLine(posZoom, posZoom + view.angles:Forward(), eyePos)
			dist = dist - 1
			posZoom = posZoom + ang2:Forward() * dist - recoilZoomPos * 0.5
		end
	end
	--posZoom:Add(viewangs:Forward() * -10)
	--posZoom:Add(ang2:Forward() * 10)
	return posZoom, ang2
end

function SWEP:GetZoomValue()
	return k or 0
end

SWEP.punchmul = 1
SWEP.punchspeed = 1

local blurintens = CreateClientConVar("hg_weaponshotblur_mul", "0.03", true, false,"Sets shotblurintens",0,1)
local shouldblur = CreateClientConVar("hg_weaponshotblur_enable", "1", true, false,"Enable shotblur",0,1)
local hg_nofovzoom = CreateClientConVar("hg_nofovzoom", "0", true, false, "Enable fov zooming when aiming", 0, 1)
local hg_show_hitposmuzzle = ConVarExists("hg_show_hitposmuzzle") and GetConVar("hg_show_hitposmuzzle") or CreateClientConVar("hg_show_hitposmuzzle", "0", false, false, "shows weapons crosshair, work only ведьма admin rank or sv_cheats 1")
local hg_aiminganim = ConVarExists("hg_aiminganim") and GetConVar("hg_aiminganim") or CreateClientConVar("hg_aiminganim", "0", false, false, "change the way you aim your gun")

function SWEP:Blur(x,y,w,z)
	if not shouldblur:GetBool() then return nil end
	local primary = self.Primary
	
	local fraction = self:GetAnimPos_Shoot2(self.lastShoot or 0, 0.01 * (math.max((self.weight or 1) - 1,0.1) * 5 + 1))

	w = w + fraction * - blurintens:GetFloat()
	local blurtbl = {x,y,w,z}
	return blurtbl
end

hook.Add("HUDPaint","drawWeaponHUD",function()
	if lply:Alive() then return end
	local ply = lply:GetNWEntity("spect", lply)
	if not IsValid(ply) or not ply:IsPlayer() or viewmode != 1 or ply == lply then return end
	local wep = ply:GetActiveWeapon()
	if IsValid(ply) and IsValid(wep) and wep.DrawHUD then
		wep:DrawHUD()
	end
end)

local hg_fov = ConVarExists("hg_fov") and GetConVar("hg_fov") or CreateClientConVar("hg_fov", "70", true, false, "changes fov to value", 75, 100)
local fov = hg_fov:GetFloat()
local fov_mode_lerp = 0

local hg_oldsights = CreateConVar("hg_oldsights", "0", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "No camera wobble when aiming")

local angZero = Angle(0,0,0)

local scopedLerpAddvec = Vector()
local oldzoom = false
local lastzoom = 0
local lastPosSelected = 0
local randomPos = VectorRand(-1, 1)
local randomPosL = Vector()
local lerpedAdren = Angle()

function SWEP:Camera(eyePos, eyeAng, view, vellen, ply)
	if not IsValid(self) then return end
	ply = ply or self:GetOwner()
	gun = self:GetWeaponEntity()
	
	//if self.drawnlasttime != CurTime() then
		//self.drawnlasttime = CurTime()
		hg.DrawWorldModel(self, true)

		//self:GetTrace(true, nil, nil, true)
	//end

	if not ply.GetAimVector then return end

	local ent = hg.GetCurrentCharacter(ply)

	local aimvec = ply:GetAimVector():Angle()
	local up, right, forward = aimvec:Up(), aimvec:Right(), aimvec:Forward()
	
	local cocking = (self:GetNetVar("shootgunReload", 0) > CurTime()) or self.reload
	--print(self:GetNetVar("shootgunReload", 0))
	local posZoom, angPos = self:GetZoomPos(recoilZoomPos, view, eyePos)
	
	local inpain = ply.organism and ply.organism.pain and ply.organism.pain > 50
	local painmul = 0.5 - math.Clamp((((ply.organism.pain or 0) - 50) / 50), 0, 0.5)
	
	painmul = painmul * 2
	--local noZoomHelmet = (ply.armors and (not ply.armors["head"] or not hg.armor.head[ply.armors["head"]] or not hg.armor.head[ply.armors["head"]].cantsight or self:IsPistolHoldType()))
	local zooming = self:IsZoom() --and noZoomHelmet
	--print(zooming)
	local justzoomed = zooming and !oldzoom
	lastzoom = (justzoomed or (cocking or self.shot2 == 1)) and CurTime() or lastzoom

	local tta = math.Clamp(self.weight / 4, 0.25, 1) * 0.5
	if isvector(vellen) then
		vellen = vellen:Length()
	end
	local slowlyZooming = math.Clamp((lastzoom - CurTime() + tta) / tta, inpain and 1 - (0.9 * painmul) or (0.10 * (math.Clamp(vellen / 200 * (ply:Crouching() and 0.5 or 1), 0, 1) * 15 + 1)), 1)
	
	if lastPosSelected + 0.1 * (inpain and 0.1 or 1) < CurTime() then
		lastPosSelected = CurTime()
		--randomPos = 0.75 * VectorRand(-0.75, 0.75)
		randomPos = (inpain and 1.5 - (1 * painmul) or 1) * ((lastzoom - CurTime() + tta) < 0 and ply.organism and ply.organism.holdingbreath and 0.25 or 1) * 0.5 * Vector(math.random(2) == 1 and math.Rand(-0.75, -0.5) or math.Rand(0.5, 0.75), math.random(2) == 1 and math.Rand(-0.75, -0.5) or math.Rand(0.5, 0.75), math.random(2) == 1 and math.Rand(-0.75, -0.5) or math.Rand(0.5, 0.75))
	end

	randomPosL = LerpFT(0.05 * (inpain and 25 - (24 * painmul) or 1), randomPosL, randomPos)
	
	scopedLerpAddvec = LerpVectorFT(((false or self.shot2 == 1) and 1 or 0.05) * (cocking and 0.25 or 1) * (inpain and 1 or 1), scopedLerpAddvec, (cocking and 1 or 1) * (justzoomed and 0.5 or 1) * (self.shot2 == 1 and 0.5 or 1) * 3 * randomPosL * slowlyZooming)
	if !hg_oldsights:GetBool() then
		if not (ply:IsSuperAdmin() and hg_setzoompos:GetBool()) then
			posZoom:Add(scopedLerpAddvec)
		end
	end
	oldzoom = zooming

	if LocalPlayer():IsAdmin() and hg_gun_cam:GetBool() then
		view.origin = posZoom
		view.angles = angPos
		view.angles:RotateAroundAxis(view.angles:Right(), self.GunCamAng and self.GunCamAng[1] or 90)
		view.angles:RotateAroundAxis(view.angles:Up(), self.GunCamAng and self.GunCamAng[2] or -80)
		view.angles:RotateAroundAxis(view.angles:Forward(), self.GunCamAng and self.GunCamAng[3] or 0 )
		local fraction = self:GetAnimPos_Shoot2(self.lastShoot or 0, 0.01 * (math.max((self.weight or 1) - 1,0.1) * 5 + 1))
		--print(CurTime() - self.lastShoot )
		view.origin = view.origin + VectorRand(-fraction,fraction) * fraction/12
		view.angles = view.angles + AngleRand(-fraction,fraction) * fraction
		return view 
	end
	angZoom = -(-eyeAng)

	local posIdle = eyePos
	local angIdle = eyeAng
	local zoom = self:IsZoom() and (IsValid(ply.FakeRagdoll) or ((self.lerpaddcloseanim * self.closeanimdis) < 3)) and (self:GetNetVar("shootgunReload", 0) < CurTime())// and (posIdle:IsEqualTol(posZoom,20))))
	
	--if hg_aiminganim:GetBool() then
		self.k = Lerp(self.Ergonomics * FrameTime() * 2, self.k or 0, zoom and 1 or 0)
	--else
	--	self.k = math.Approach(self.k or 0, zoom and 1 or 0, FrameTime() * 3 * self.Ergonomics)
	--end

	local k = math.min(1, math.ease.InOutCubic(self.k * 1))

	local organism = ply.organism or {}
	local larm = (type(organism.larm) == "number") and organism.larm or 0
	local rarm = (type(organism.rarm) == "number") and organism.rarm or 0
	local sp1  = (type(organism.spine1) == "number") and organism.spine1 or 0
	local sp2  = (type(organism.spine2) == "number") and organism.spine2 or 0
	local sp3  = (type(organism.spine3) == "number") and organism.spine3 or 0

	local debil = (((larm > 0.75 and (larm - 0.75) * (ply.posture != 7 and ply.posture != 8 and 1 or 0)) or 0)
		+ ((rarm > 0.1 and (rarm - 0.1)) or 0)) / 4

	local addview = AngleRand(-debil-0.005,debil+0.005) * (organism.holdingbreath and 0.1 or 1)
	addview[3] = 0

	if ply == LocalPlayer() then
		ViewPunch2(addview)
	end

	local k4 = ((organism.adrenaline or 0) * 0.01)
	local angRand = AngleRand(-k4 * 2, k4 * 2) * 0.2
	lerpedAdren:Add(angRand)
	lerpedAdren = LerpFT(0.1, lerpedAdren, angle_zero)
	--ViewPunch(angRand)
	local ang = ply:EyeAngles()
	ang:Add(lerpedAdren * 1)
	ply:SetEyeAngles(ang)
	
	local angRand2 = AngleRand(-0.1, 0.1)

	if (ply.Karma or 100) < 70 then
		ViewPunch2(angRand2 * (1 - ply.Karma / 60))
	end

	local angfuk = angfuk23
	angfuk[2] = -position_difference3[2]/40

	//ViewPunch2(angfuk)

	--local shootLerp = self.Anim_RecoilLerp
	--view.fov = Lerp(shootLerp,view.fov,view.fov - 5 * self.Penetration / 15)
	local outputPos, outputAng
	local animpos = (self.AdditionalAng or Angle(0, 0, 0))[2] / 20 + (self.AdditionalAng2 or Angle(0, 0, 0))[2] / 20 --:GetAnimShoot2()
	local eyeSpray = -(-self.EyeSpray)
	local mult = (hg.GunPositions[ply] and hg.GunPositions[ply][1] and (hg.GunPositions[ply][1] / 4 + 1) / 2 + 1 or 1) / 2
	
	local spray = self:GetCameraSprayValues(animpos) * mult

	spray = spray + animpos * 6 * k * mult * ply:EyeAngles():Up()

	//angIdle:Add(-angle_difference*2)
	//angZoom:Add(-angle_difference*1)

	angZoom:Add(self.prankang or angle_zero)

	local fraction2 = math.ease.InCubic(self:GetAnimPos_Shoot2(self.lastShoot or 0, 1))
	
	outputPos = LerpVector(k, posIdle, posZoom)
	outputAng = LerpAngle(k, angIdle, angIdle)

	--outputPos:Add(VectorRand(-1, 1) * (math.random(2) == 1 and 1 or -1) * 0.05 * fraction2)

	if zoom or hg.KeyDown(ply, IN_SPEED) then offsetView = LerpFT(0.07, offsetView, angZero) end

	outputAng:Add(-eyeSpray * 10)
	
	outputPos:Add(-(angle_difference_localvec * 30 * (-k + 2) * 2) / (self.Ergonomics or 1) + position_difference23 * 0.25 * (-k + 1.25))
	outputPos:Add(spray * 1.1)
	
	local fthuy = ftlerped * 150

	angle_spray[3] = math.Rand(-self.sprayAngles[3], self.sprayAngles[3]) * 60 * game.GetTimeScale() * 0.7
	angle_spray[1] = math.Rand(-self.sprayAngles[3], self.sprayAngles[3]) * 12 * game.GetTimeScale() * 0.7
	angle_spray[2] = math.Rand(-self.sprayAngles[3], self.sprayAngles[3]) * 12 * game.GetTimeScale() * 0.7
	outputAng:Add(angle_spray)
	
	local imm = (organism and organism.immobilization) or 0
	if type(imm) ~= "number" then imm = 0 end
	local adr = (organism and organism.adrenaline) or 0
	if type(adr) ~= "number" then adr = 0 end

	local suicVal = 0
	if ply.suiciding and ply:GetNetVar("suicide_time", CurTime()) < CurTime() then
		suicVal = (1 - math.max(ply:GetNetVar("suicide_time", CurTime()) + 4 - CurTime(), 0) / 4) * 20
	end

	self.shot = LerpFT(0.1, self.shot or 0, 0)
	self.shot2 = LerpFT(0.1, self.shot2 or 0, 0)

	fovlerp = Lerp(0.01, fovlerp,
		--(ply:IsSprinting() and ply:GetVelocity():LengthSqr() > 1500 and 10 or 0)
		-- ((imm / 4) - (adr * 5)) / 2
		 - suicVal + self.shot * 5
	)

	ply:SetLOD(0);

	if hg_realismcam:GetBool() then
		outputPos:Add(-(angle_difference_localvec * 150))
		local ang = -(angle_difference * 5)
		ang[3] = ang[3] / 2
		outputAng:Add(ang)
	end

	if not hg_nofovzoom:GetBool() then
		fov_mode_lerp = LerpFT(0.12, fov_mode_lerp, (self:HasAttachment("sight","optic") and not self.viewmode1 and -15 - (hg_fov:GetInt() - 75)) or - (hg_fov:GetInt() - 80))
		fov = fovlerp + fov_mode_lerp * k//Lerp(k, fovlerp, fov_mode_lerp)
	else
		fov = fovlerp
	end

	if isSettingZoom then
		fov = -50
	end
	
	view.origin = outputPos
	view.angles = outputAng
	
	view.fov = math.max(40, view.fov + fov)

	if LOW_RENDER then
		view.zfar = 50
	end

	return view
end

hook.Add( "Think", "DOFThink", function()

end)

hook.Add( "Think", "DOFThink2", function()
	do return end
	local wep = lply:GetActiveWeapon()
	
	if !ishgweapon(wep) then return end

	local k = 1 - math.ease.InOutCubic(wep.k * 1)
	if k > 0.9 then k = 0 end

	DOF_SPACING = Lerp(k, 512, 112)
	DOF_OFFSET = Lerp(k, 512, 40)

	if k > 0.05 then
		if !DOF_ENABLED then
			DOF_ENABLED = true

			DOF_Start()
		end
	else
		if DOF_ENABLED then
			timer.Simple(0, function()
				DOF_Kill()
			end)

			DOF_ENABLED = false
		end
	end
end)

function SWEP:GetCameraSprayValues()
	local owner = self:GetOwner()
	local spray = self.EyeSpray + GetViewPunchAngles2() * 0.25 + GetViewPunchAngles3() * 0.25
	
	local _, newspr = LocalToWorld(vector_origin, spray * 8, vector_origin, owner:EyeAngles())

	return newspr:Forward() - owner:EyeAngles():Forward()
end

function SWEP:ChangeCameraPassive(value)
	return value
end

function SWEP:IsEyeAng()
	return self.reload or self.deploy or self.holster or self:IsSprinting() or not self:GetOwner():OnGround()
end

local white = Color(255, 255, 255)
local white2 = Color(150, 150, 150)
local white3 = Color(0, 0, 0)
local red = Color(250, 100, 100)
local green = Color(100, 250, 100)
local blue = Color(100, 100, 250)
local sv_cheats = GetConVar("sv_cheats")
local pos, wep, lply
hook.Add("HUDPaint", "homigrad-test-att", function()
	lply = LocalPlayer()
	if not hg_show_hitposmuzzle:GetBool() or (hg_show_hitposmuzzle:GetBool() and not (sv_cheats:GetBool() or lply:IsAdmin() or lply:IsSuperAdmin())) then return end
	wep = lply:GetActiveWeapon()
	if not IsValid(wep) or not wep.GetTrace then return end
	local tr = wep:GetTrace(true)
	local att = wep:GetMuzzleAtt(nil, true)
	local pos2, ang2 = att.Pos, att.Ang

	pos = tr.StartPos:ToScreen()
	draw.RoundedBox(0, pos.x - 2, pos.y - 2, 4, 4, red)
	pos = tr.HitPos:ToScreen()
	draw.RoundedBox(0, pos.x - 2, pos.y - 2, 4, 4, white)
	pos = pos2:ToScreen()
	draw.RoundedBox(0, pos.x - 2, pos.y - 2, 4, 4, green)
	local tr = lply:GetEyeTrace()
	local scr = tr.HitPos:ToScreen()
	draw.RoundedBox(0, scr.x - 2, scr.y - 2, 4, 4, white2)

	if not wep.GetWeaponEntity then return end
	local gun = wep:GetWeaponEntity()
	if not IsValid(gun) then return end
	
	local attmuzle = wep:GetMuzzleAtt(gun, true)
	local att = gun:GetAttachment(gun:LookupAttachment(wep.FakeEjectBrassATT or "ejectbrass")) or gun:GetAttachment(gun:LookupAttachment("shell"))
	local pos, ang
	if not att then
		pos, ang = gun:GetPos(), gun:GetAngles()
	else
		pos, ang = att.Pos, att.Ang
	end

	local _
	if wep.EjectPos then pos = gun:GetPos() + ang:Right() * wep.EjectPos.x + ang:Up() * wep.EjectPos.z + ang:Forward() * wep.EjectPos.y end
	if wep.EjectAng then _,ang = LocalToWorld(vecZero,wep.EjectAng,vecZero,ang) end
	local posa = pos:ToScreen()
	draw.RoundedBox(0, posa.x - 2, posa.y - 2, 4, 4, blue)
	posa = (pos + ang:Forward()):ToScreen()
	draw.RoundedBox(0, posa.x - 2, posa.y - 2, 4, 4, blue)

	//draw.RoundedBox(0, ScrW() / 2 - 2, ScrH() / 2 - 2, 4, 4, white3)
end)

local pp_dof_initlength = CreateClientConVar("pp_dof_initlength", "256", true, false)
local pp_dof_spacing = CreateClientConVar("pp_dof_spacing", "512", true, false)
local pp_dof = CreateClientConVar("pp_dof", "0", false, false)
--local potatopc = GetConVar("hg_potatopc") or CreateClientConVar("hg_potatopc", "0", true, false, "enable this if you are noob", 0, 1)
--hook.Add("Think", "DOFThink", function()
	--if not GAMEMODE:PostProcessPermitted("dof") or not pp_dof:GetBool() or potatopc:GetInt() or 0 >= 1 then return end
	--DOF_SPACING = pp_dof_spacing:GetFloat()
	--DOF_OFFSET = pp_dof_initlength:GetFloat()
--end)

--[[local angleHuy = Angle(0,-90,0)
local someVec = Vector(0,0,36)
hook.Add("PreDrawTranslucentRenderables","huy",function()
	 
	local firstPerson = true--lply == GetViewEntity()
	if firstPerson then
		lply:ManipulateBoneAngles(lply:LookupBone("ValveBiped.Bip01_Spine1"),angleHuy)
		playerModel = playerModel or ClientsideModel(lply:GetModel())

		--local pos,ang = lply:GetBonePosition(0)

		playerModel:SetPos(lply:GetPos())

		--ang:RotateAroundAxis(ang:Right(),90)
		--ang:RotateAroundAxis(ang:Forward(),-90)
		local ang = lply:EyeAngles()
		ang[1] = 0
		playerModel:SetAngles(ang)
		local ang = lply:EyeAngles()

		playerModel:ManipulateBoneAngles(playerModel:LookupBone("ValveBiped.Bip01_Head1"),Angle(ang[3],-ang[1],0))

		playerModel:ManipulateBonePosition(0,playerModel:WorldToLocal(lply:GetBonePosition(0)) - someVec,false)
		playerModel:ManipulateBoneAngles(playerModel:LookupBone("ValveBiped.Bip01_L_Thigh"),-angleHuy)
		playerModel:ManipulateBoneAngles(playerModel:LookupBone("ValveBiped.Bip01_R_Thigh"),-angleHuy)
	end
end)]]