local view = render.GetViewSetup()
local whitelist = {
	weapon_physgun = true,
	gmod_tool = true,
	gmod_camera = true,
	weapon_crowbar = true,
	weapon_pistol = true,
	weapon_crossbow = true,
	gmod_smoothcamera = true,
	none = true
}

local vecZero, vecFull = Vector(0.001, 0.001, 0.001), Vector(1, 1, 1)
 
local CameraTransformApply
local hook_Run = hook.Run
local result
local util_TraceLine, util_TraceHull = util.TraceLine, util.TraceHull
local math_Clamp = math.Clamp
local Round, Max, abs = math.Round, math.max, math.abs
local compression = 12
local traceBuilder = {
	filter = lply,
	mins = -Vector(5, 5, 5),
	maxs = Vector(5, 5, 5),
	mask = MASK_SOLID,
	collisiongroup = COLLISION_GROUP_DEBRIS
}

local anglesYaw = Angle(0, 0, 0)
local vecVel = Vector(0, 0, 0)
local angVel = Angle(0, 0, 0)
local limit = 4
local sideMul = 5
local eyeAngL = Angle(0, 0, 0)
local IsValid = IsValid

local hg_fov = ConVarExists("hg_fov") and GetConVar("hg_fov") or CreateClientConVar("hg_fov", "70", true, false, "changes fov to value", 75, 100)
local hg_realismcam = ConVarExists("hg_realismcam") and GetConVar("hg_realismcam") or CreateClientConVar("hg_realismcam", "0", true, false, "realism camera", 0, 1)
local hg_gopro = ConVarExists("hg_gopro") and GetConVar("hg_gopro") or CreateClientConVar("hg_gopro", "0", true, false, "gopro camera", 0, 1)

local oldview = render.GetViewSetup()
local breathing_amount = 0
local walk_amount = 0
local curTime = CurTime()
local curTime2 = CurTime()
local angfuk23 = Angle(0,0,0)
local vecdiff = Vector(0, 0, 0)
angle_difference_localvec = Vector(0, 0, 0)
angle_difference_localvec2 = Vector(0, 0, 0)
angle_difference = Angle(0, 0, 0)
angle_difference2 = Angle(0, 0, 0)
position_difference = Vector(0, 0, 0)
position_difference2 = Vector(0, 0, 0)
position_difference23 = Vector(0, 0, 0)
position_difference3 = Vector(0, 0, 0)

offsetView = offsetView or Angle(0, 0, 0)

camera_position_addition = Vector(0,0,0)

local swayAng = Angle(0, 0, 0)
hook.Add("Camera", "Weapon", function(ply, ...)
	local ply = ply or lply
	wep = ply:GetActiveWeapon()
	if wep.Camera then return wep:Camera(...) end
end)

hook.Add("MotionBlur", "Weapon", function(x,y,w,z)
	wep = lply:GetActiveWeapon()
	if wep.Blur then return wep:Blur(x,y,w,z) end
end)

hook.Add("GetMotionBlurValues", "MotionBlurEffect", function( x, y, w, z)
    local blur = hook_Run("MotionBlur",x,y,w,z)
	if blur then
		return blur[1],blur[2],blur[3],blur[4]
	end
end)

local TickInterval = engine.TickInterval

-- local hg.clamp = hg.hg.clamp

local lerpholdbreath = 1

local velocityAdd = Vector()
local velocityAddVel = Vector()
local walkLerped = 0
local walkTime = 0

local lerped_ang = Angle(0,0,0)
function HGAddView(ply, origin, angles, velLen)
	if ply:Alive() then
		local ent = hg.GetCurrentCharacter(ply)
		local org = ply.organism or {}
		local pulse = org.pulse or 70
		local adrenaline = org.adrenaline or 0
		local temp = org.temperature or 36.6
		local o2 = org.o2 and org.o2[1] or 30
		local analgesia = org.analgesia or 0

		local wep = ply:GetActiveWeapon()
		local inSight = IsValid(wep) and wep.IsZoom and wep:IsZoom()

		breathing_amount = breathing_amount + math.max((math.Clamp(pulse, 0, 80) / 120 / 30 + velLen / 100 - (30 - o2) / 3000), 0)
		--walk_amount = walk_amount + velLen / 100

		--[[camera_position_addition[1] = 0
		camera_position_addition[2] = 0
		camera_position_addition[3] = 0]]
		
		--camera_position_addition[1] = (math.cos(breathing_amount)) * math.Clamp((math.max(pulse / 80,1) - 1) / 2,0,0.5)
		--camera_position_addition[2] = (math.cos(breathing_amount))* math.Clamp((math.max(pulse / 80,1) - 1) / 2,0,0.5)
		//camera_position_addition[3] = (math.sin(breathing_amount)) * math.Clamp((math.max(pulse / 80,1) - 1) / 2,0,0.5) * 0.5 * (org.lungsfunction and 1 or 0) * math.max(2 - analgesia, 0) * 0.5
		
		--origin:Add(camera_position_addition)

		local ang = AngleRand(-0.1, 0.1) * math.Rand(0, math.min(adrenaline, 1)) / 1
		ang[1] = ang[1] + (math.sin(breathing_amount)) * math.Clamp((math.max(pulse / 80,1) - 1) / 2,0,0.5) / 5 * (org.lungsfunction and 1 or 0) * math.max(2 - analgesia, 0) * 0.5
		ang[3] = 0

		lerped_ang = LerpFT(0.2, lerped_ang, ang * (inSight and 1 or 1) * math.max(org.recoilmul or 1,0.1))
		local tmpmul = math.max(36.6 - temp, 0)
		ang[1] = math.Rand(-tmpmul, tmpmul) / 155
		ang[2] = math.Rand(-tmpmul, tmpmul) / 155
		ang[3] = math.Rand(-adrenaline, adrenaline) / 15
		--angles:Add(ang)
		//ply:SetEyeAngles(ply:EyeAngles() + lerped_ang / 2)
		//angles:Add(ang)
		//ViewPunch2(lerped_ang * 0.1)

		--[[if hg_realismcam:GetBool() then
			origin = origin + angle_difference_localvec2 * 100
		end]]

		local vel = ent:GetVelocity()
		local vellen = vel:Length()
	
		local vellenlerp = velocityAdd and velocityAdd:Length() or vellen
		
		walkLerped = LerpFT(0.1, walkLerped, ply:InVehicle() and 0 or vellenlerp * 100)
		
		local walk = math.Clamp(walkLerped / 100, 0, 1)
		
		walkTime = walkTime + walk * FrameTime() * 2 * game.GetTimeScale() * (ply:OnGround() and 1 or 0)
		
		velocityAddVel = LerpFT(0.9, velocityAddVel * 0.9, -vel * 0.1)
	
		velocityAdd = LerpFT(0.1, velocityAdd, velocityAddVel)
	
		if ply:IsSprinting() then
			walk = walk * 1
		end
	
		local huy = walkTime
		
		local x, y = math.cos(huy) * math.sin(huy) * walk * 1, math.sin(huy) * walk * 1
		local x2, y2 = math.cos(huy) * math.sin(huy) * walk + math.sin(huy + 0.25) * 0.25 * walk, math.sin(huy) * walk + math.cos(huy) * 0.25 * walk

		//angles[1] = angles[1] + x * 1
		//angles[2] = angles[2] + y * 1
		ViewPunch4(Angle(y2, x2, x2 * 50) * 0.0005 * (ishgweapon(wep) and 1.5 or 1))

		local music = hg.DynamicMusicV2.Player.GetTrack()

		if music then
			local layer = hg.DynamicMusicV2.Player.Layers[1] and hg.DynamicMusicV2.Player.Layers[1][2] or false

			if layer then
				local offset = music.Offset or 0
				local bpm = music.BPM or 140
				local intensity = 1 - ((layer:GetTime() - offset) / 60 * bpm)
				intensity = (intensity - math.Round(intensity)) % 1
				intensity = math.Clamp((intensity * 0.25 + 0.75), 0, 1)
				intensity = math.ease.InExpo(intensity) * 1
			
			--angles[1] = angles[1] + intensity * 1
			end
		end

		ply.xMove = x

		if(ply.MovementInertiaAddView)then
			angles = angles + ply.MovementInertiaAddView
			ply.MovementInertiaAddView.r = Lerp(FrameTime() * 5, ply.MovementInertiaAddView.r, 0)
			ply.MovementInertiaAddView.p = Lerp(FrameTime() * 5, ply.MovementInertiaAddView.p, 0)
		end
	else
		if(ply.MovementInertiaAddView)then
			ply.MovementInertiaAddView.r = 0
			ply.MovementInertiaAddView.p = 0
		end
	end
	
	return origin, angles
end

hook.Add("ShouldDrawLocalPlayer","drawlocalplayeralways",function(ply)
	--return true
end)
local materialsWheelDirve = {
	["dirt"] = true, ["sand"] = true, ["grass"] = true
}

LookX, LookY = 0, 0
local altlook = false

lerpfovadd = 0
local CalcView
local oldVechicleAng = Angle(0,0,0)
local viewOverride

local hg_thirdperson = ConVarExists("hg_thirdperson") and GetConVar("hg_thirdperson") or CreateConVar("hg_thirdperson", 0, FCVAR_REPLICATED, "ragdoll combat", 0, 1)
local hg_legacycam = ConVarExists("hg_legacycam") and GetConVar("hg_legacycam") or CreateConVar("hg_legacycam", 0, FCVAR_REPLICATED, "ragdoll combat", 0, 1)
local lerpasad = 0

hook.Remove("CalcView", "wac_air_calcview")
hook.Remove("CreateMove", "wac_cl_seatswitch_centerview")
//PrintTable(wac)

local lerpaim = 1
local hg_leancam_mul = ConVarExists("hg_leancam_mul") and GetConVar("hg_leancam_mul") or CreateClientConVar("hg_leancam_mul", "7", true, false, "changes lean cam mul", -10, 10)
zooming = false
lerpfovadd2 = 0

concommand.Add("+hg_zoom",function()
	zooming = true
end)

concommand.Add("-hg_zoom",function()
	zooming = false
end)

concommand.Add("hg_zoom",function()
	zooming = not zooming
end)

surface.CreateFont(
	"BODYCAMFONT",
	{
		font = "Arial",
		size = 42,
		italic = true,
		weight = 1500
	}
)

hook.Add("HUDPaint", "HUDPaint_DrawABox", function() -- этот код старше вас, не судите строго
	local lply = LocalPlayer()
	if lply:Alive() and hg_gopro:GetBool() then
		local specPly = lply
		if not specPly:IsValid() then return end
		local Text = "GoPro #" .. math.Round(util.SharedRandom(specPly:GetName(),1000,9999,specPly:EntIndex()),0)
		draw.DrawText(Text, "BODYCAMFONT", ScrW() * 0.905 + 2, ScrH() * 0.035 + 2, Color(0, 0, 0), TEXT_ALIGN_CENTER)
		draw.DrawText(Text, "BODYCAMFONT", ScrW() * 0.905, ScrH() * 0.035, Color(255, 255, 255), TEXT_ALIGN_CENTER)
		draw.RoundedBox(0, ScrW() * 0.85, ScrH() * 0.085, 50, 28, Color(0, 173, 255))
		draw.RoundedBox(0, ScrW() * 0.85 + 58, ScrH() * 0.085, 50, 28, Color(0, 173, 255))
		draw.RoundedBox(0, ScrW() * 0.85 + 58 * 2, ScrH() * 0.085, 50, 28, Color(0, 70, 103))
		draw.RoundedBox(0, ScrW() * 0.85 + 58 * 3, ScrH() * 0.085, 50, 28, color_white)
		Text = specPly:GetName()
		draw.DrawText(Text, "BODYCAMFONT", ScrW() * 0.905 + 2, ScrH() * 0.11 + 2, Color(0, 0, 0), TEXT_ALIGN_CENTER)
		draw.DrawText(Text, "BODYCAMFONT", ScrW() * 0.905, ScrH() * 0.11, Color(255, 255, 255), TEXT_ALIGN_CENTER)
		DrawBloom(0.8, 1, 9, 9, 1, 1.2, 0.8, 0.8, 1.2)
		DrawSharpen(0.2, 1.2)
	end
end)

function SpecCam(ply, vec, ang, fov, znear, zfar)
	if !ply:Alive() then return end
	local hand = ply:GetAttachment(ply:LookupAttachment("anim_attachment_rh"))
	local eye = ply:GetAttachment(ply:LookupAttachment("eyes"))
	local org = eye.Pos
	local ang1 = eye.Ang + Angle(5, 2, 0)
	local org1 = eye.Pos + eye.Ang:Up() * 6 + eye.Ang:Forward() * -1 + eye.Ang:Right() * 6.5
	if ply:GetNWBool("fake") == true and IsValid(ply:GetNWEntity("DeathRagdoll")) then
		local attach = ply:GetNWEntity("DeathRagdoll"):GetAttachment(1)
		local view = {
			origin = attach.Pos + attach.Ang:Up() * 4 + attach.Ang:Forward() * -5 + attach.Ang:Right() * 6.5,
			angles = attach.Ang + Angle(-10, 5, 0),
			fov = 88,
			drawviewer = true,
			znear = 0.1
		}

		return view
	end

	local view = {
		origin = org1,
		angles = ang1,
		fov = 110,
		drawviewer = true,
		znear = 0.1
	}

	return view
end
-- Сделайте чтобы локальный игрок рендерился всегда, у меня не вышло
CalcView = function(ply, origin, angles, fov, znear, zfar)
	local x, y = input.GetCursorPos()

	if vgui.CursorVisible() or (x == 0 and y == 0) then
		local ang = ply:EyeAngles()
		ang[3] = 0
		ply:SetEyeAngles(ang)
	end

	if g_VR and g_VR.active then return end
	if GetViewEntity() ~= (ply or LocalPlayer()) then return end
	local rlEnt = hg.GetCurrentCharacter(ply)
	lerpfovadd = LerpFT(0.001, lerpfovadd, (ply:IsSprinting() and rlEnt == ply and rlEnt:GetVelocity():LengthSqr() > 1500 and 10 or 0) - ( ply.organism and (ply.organism and (((ply.organism.immobilization or 0) / 4) - (ply.organism.adrenaline or 0) * 5)) or 0) / 2 - (ply.suiciding and (ply:GetNetVar("suicide_time",CurTime()) < CurTime()) and (1 - math.max(ply:GetNetVar("suicide_time",CurTime()) + 8 - CurTime(),0) / 8) * 20 or 0))
	lerpfovadd2 = LerpFT(0.1, lerpfovadd2, zooming and -25 or 0)

	fov = hg_fov:GetInt()
	
	if not IsValid(ply) then return end
	//do return end

	--print(ply, ply.FakeRagdoll, ply:GetNWEntity("FakeRagdoll"))
	
	if LocalPlayer().lean and math.abs(LocalPlayer().lean) < 0.01 then
		oldlean = 0
		lean_lerp = 0
	end

	angles.roll = (turned and 180 or 0) + lean_lerp * 10
	
	if IsValid(follow) then
		return hg.CalcViewFake(ply, origin, angles, fov, znear, zfar)
	end
	if ply:InVehicle() then
		ply.lockcamera = false//true
	else
		ply.lockcamera = false
	end

	if not ply:Alive() and not follow then
		
		if lply:GetNWInt("viewmode",0) == 1 then
			ply = lply:GetNWEntity("spect",NULL)
			
			if IsValid(ply) then
				origin = ply:EyePos()
				angles = ply:EyeAngles()
				--lply:SetEyeAngles(ply:EyeAngles())
			end
		else
			return hook.Run("HG_CalcView", lply, origin, angles, fov, znear, zfar)
		end
	end

	if not IsValid(ply) or not ply.LookupBone or not ply:LookupBone("ValveBiped.Bip01_Head1") then return end
	
	if not ply.GetAimVector then return end

	local firstPerson = GetViewEntity() == lply

	local fova = {0}
	hook.Run("HG_CalcView", ply, origin, angles, fova, znear, zfar)
	
	if not firstPerson then return end
	
	att = ply:GetAttachment(ply:LookupAttachment("eyes"))
	if not att or not istable(att) then return end
	
	--ply:SetupBones()
	--selfdraw = true
	--ply:DrawModel()
	--selfdraw = nil
	//hg.DoTPIK(lply, lply)
	local tr, hullcheck, headm = hg.eyeTrace(ply, 10, ply, att.Ang)
	
	--[[if hg_realismcam:GetBool() and ishgweapon(ply:GetActiveWeapon()) then
		tr = hg.torsoTrace(ply)
		local huy = angles[3]
		angles = tr.Normal:Angle()
		angles[3] = huy
		local att = ply:GetAttachment(ply:LookupAttachment("eyes"))
		angles = LerpAngle(0.5, angles, att.Ang)
	end]]

	local eyePos = tr.StartPos
	local vehicle = ply:GetVehicle()
	local vehiclebase = ply.GetSimfphys and ply:GetSimfphys() or nil
	local BadSurfaceDrive = false
	local vel = ply:GetMoveType() ~= MOVETYPE_NOCLIP and ( ( ply:InVehicle() and -vehicle:GetVelocity() or -ply:GetVelocity()) / (ply:InVehicle() and (BadSurfaceDrive and 150 or 550) or 200)) or vector_origin

	//local ent = tr.Entity
	//if IsValid(ent) then
	//	debugoverlay.Line(ent:GetPos(), ent:GetPos() + ent:GetAngles():Forward() * 102, 1, color_white, false)
	//end

	if IsValid(vehicle) then
		if IsValid(vehiclebase) then
			vehicle = vehiclebase
		end
		local tr = util.TraceLine( {
			start = vehicle:GetPos(),
			endpos = vehicle:GetPos() + vector_up * -75,
			mask = MASK_SOLID_BRUSHONLY,
		} )
		local surfaces = util.GetSurfacePropName( tr.SurfaceProps )
		if materialsWheelDirve[surfaces] then
			BadSurfaceDrive = true
		end
		local angPunch = vehicle:GetAngles()
		--oldVechicleAng = angPunch
		angPunch:Sub(oldVechicleAng)
		angPunch:Normalize()
		angPunch:Div(5) -- Ставьте это на 1 чтобы врубить блевота мод
		
		--print(angPunch)
		local PunchFinal = -angPunch
		--print(PunchFinal)
		ViewPunch2(PunchFinal)
		ViewPunch(PunchFinal)
		oldVechicleAng = vehicle:GetAngles()
		--oldVechicleAng:Normalize()
		vel = vehicle:GetVelocity() / (BadSurfaceDrive and 350 or 550)
	end

	local velLen = vel:Length()
	--print()
	ViewPunch(AngleRand(-1,1) * velLen / (BadSurfaceDrive and 5 or 50))

	eyePos:Add(VectorRand() * ( (ply:InVehicle() or velLen > 2) and (velLen +( ply:InVehicle() and 0 or - 2)) / (ply:InVehicle() and 50 or 10) or 0))
	hg.clamp(vel, limit)
	angles = ply:InVehicle() and ply:GetAimVector():AngleEx(vehicle:GetUp()) or angles

	angles:RotateAroundAxis(angles:Up(),-LookX)
	angles:RotateAroundAxis(angles:Right(),-LookY)
	--angles = angles + Angle(LookY,-LookX,0)
	
	hg.cam_things(ply,view,angles)
	--print(ply:EyeAngles())
	if not RENDERSCENE then
		--[[local CamControl = hook.Run("HG_CalcView",ply, origin, angles, fov, znear, zfar)
		if CamControl ~= nil then
			return CamControl
		end]]

		local HuyControl = (zb and zb.OverrideCalcView) and zb.OverrideCalcView(ply, origin, angles, fov, znear, zfar)
		if HuyControl ~= nil then
			return HuyControl
		end
	end

	--ply:ManipulateBoneScale(ply:LookupBone("ValveBiped.Bip01_Head1"), firstPerson and (not hg_thirdperson:GetBool() or hg_legacycam:GetBool() or lerpaim < 0.3) and vecZero or vecFull)

	--local angle = tr.Normal:Angle()
	--angle[3] = angles[3]

	if hg_thirdperson:GetBool() then
		lerpaim = LerpFT(0.1, lerpaim, (not IsAimingNoScope(ply)) and 1 or (hg_legacycam:GetBool() and 1 or 0))
		leanmul1 = ((ply.lean < 0 and ply.lean * 2.2 or 0) + 1)
		leanmul2 = ((ply.lean > 0 and ply.lean * 2.2 or 0) + 1)
		origin = origin + ((angles:Forward() * -30 + angles:Right() * 15 * leanmul1) * lerpaim)
		view = hook.Run("Camera", ply, view.origin, view.angles, view, vector_origin) or view
		lerpasad = Lerp(0.1, lerpasad, ((IsAimingNoScope(ply) or hg_legacycam:GetBool()) and 0.001 or 1))

		local pos = hg.eye(ply, 10, follow)
		local ang = ply:EyeAngles()
		local tr = {}
		tr.start = pos
		tr.endpos = pos - ang:Forward() * 60 * lerpasad + ang:Right() * 15 * lerpasad
		tr.filter = {ply}
		tr.mask = MASK_SOLID

		view.origin = util.TraceLine(tr).HitPos + ((tr.endpos - tr.start):GetNormalized() * -5)
		view.angles = angles
		view.drawviewer = true
		view.fov = 95 + lerpfovadd + lerpfovadd2
		return view
	end

	view.znear = 1 -- 3
	view.zfar = zfar
	view.fov = math.Clamp(hg_fov:GetFloat(),75,100) + fova[1] + lerpfovadd + lerpfovadd2
	view.drawviewer = true--not hullcheck.Hit
	view.origin = origin
	view.angles = angles
	
	--local fixVal = math.min(math.max(angles[1] -30,0),40)/40
	--fixLerp = LerpFT(.4,fixLerp, fixVal)
	--local fixBlinkingModel = angles:Forward() * (-8 * fixLerp) + angles:Up()* (2 * fixLerp)
	--eyePos:Add( fixBlinkingModel )

	--view.fov = view.fov - 10 * fixVal
	
	result = hook_Run("Camera", ply, eyePos, angles, view, velLen * 200)
	--if not RENDERSCENE then
	view.origin, view.angles = HGAddView(ply, view.origin, view.angles, velLen)
	--end
	
	--[[if lply:InVehicle() then
		local FPersPos =  lply:GetAttachment(lply:LookupAttachment( "eyes" ))
		view.origin = FPersPos.Pos
		view.angles = FPersPos.Ang
		return view
	end--]]
	if hg_gopro:GetBool() then return SpecCam(ply, origin, angles, fov, znear, zfa) end

	if result == view then
		traceBuilder.start = origin
		traceBuilder.endpos = view.origin
		local trace = hg.hullCheck(ply:EyePos() - vector_up * 10,view.origin,ply)
		view.origin = trace.HitPos
		local vpang = GetViewPunchAngles2() + GetViewPunchAngles3()
		vpang[3] = 0
		view.angles:Add(-vpang)
		view.angles[3] = view.angles[3] + GetViewPunchAngles4()[3]
		return view
	end
	
	view.origin = eyePos
	view.angles = angles
	local vpang = GetViewPunchAngles2() + GetViewPunchAngles3()
	vpang[3] = 0
	view.angles:Add(-vpang)
	view.angles[3] = view.angles[3] + GetViewPunchAngles4()[3]

	wep = ply:GetActiveWeapon()
	if IsValid(wep) and whitelist[wep:GetClass()] then return end

	return view
end

local angleZero = Angle(0,0,0)
local torsoOld

function hg.cam_things(ply, view, angles)
	local wep = ply:GetActiveWeapon()
	local eyeAngs = ply:EyeAngles()
	eyeAngs[3] = 0
	local oldviewa = oldview or view
	local ent = hg.GetCurrentCharacter(ply)
	if not ent:LookupBone("ValveBiped.Bip01_Spine") then return end
	if not ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Spine")) then return end
	local torso = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Spine")):GetAngles()
	--local oldorigin = originnew or ply:EyePos()
	oldviewa = not ply:Alive() and view or oldviewa
	
	local different, _ = WorldToLocal(eyeAngs:Forward(), angle_zero, (eyeAnglesOld or eyeAngs):Forward(), angle_zero)
	local different2, _ = WorldToLocal(torso:Forward(), angle_zero, (torsoOld or torso):Forward(), angle_zero)
	local _, localAng = WorldToLocal(vector_origin, eyeAngs, vector_origin, eyeAnglesOld or eyeAngs)

	torsoOld = torso

	local fthuy = ftlerped * 150 * game.GetTimeScale()--hg.FrameTimeClamped() * 300
	fthuy = math.max(0.0001, fthuy) -- WHAT IF...
	
	angle_difference_localvec = LerpVectorFT(0.08, angle_difference_localvec, -different / (fthuy))
	angle_difference_localvec2 = LerpVectorFT(0.08, angle_difference_localvec2, -different2 / (fthuy))
	angle_difference = LerpAngleFT(0.08, angle_difference, localAng * 2 / (fthuy))
	angle_difference2 = LerpAngleFT(0.1, angle_difference2, localAng * 2 / (fthuy))
	local vela = -(hg.GetCurrentCharacter(ply):GetVelocity() / 50)
	position_difference = LerpVectorFT(0.15, position_difference, vela)
	position_difference2 = LerpVectorFT(0.05, position_difference2, vela)
	position_difference23 = ply:EyeAngles():Right() * math.Clamp(position_difference2:Dot(ply:EyeAngles():Right()), -4, 4) + ply:EyeAngles():Up() * math.Clamp(position_difference2:Dot(ply:EyeAngles():Up()), -4, 4)
	--if hg.GetCurrentCharacter(ply) ~= ply then position_difference:Zero() end

	table.CopyFromTo(view, oldview)
	--originnew = ply:GetPos()

	position_difference3[1] = 0
	position_difference3[3] = 0
	position_difference3[2] = position_difference:Dot(eyeAngs:Right())-- * (fthuy)
	
	hg.clamp(position_difference, 2)
	hg.clamp(position_difference3, 5)
	hg.clamp(angle_difference_localvec, 10)
	hg.clamp(angle_difference, 10)
	hg.clamp(angle_difference2, 10)
	
	if not hg.KeyDown(ply, IN_SPEED) then
		offsetView[1] = math_Clamp(offsetView[1] - angle_difference2[1] / 18, -2, 2)
		offsetView[2] = math_Clamp(offsetView[2] - angle_difference2[2] / 18, -4, 4)
	end

	offsetView = LerpFT(0.001,offsetView,angleZero)

	eyeAnglesOld = eyeAngs
	local position_differencedot = position_difference:Dot(angles:Right()) * 2
	angles[3] = angles[3] - angle_difference[2] * 0.5
	--angles[3] = angles[3] - position_differencedot
	angles[3] = angles[3] - (lean_lerp or 0) * hg_leancam_mul:GetInt()
end

concommand.Add("+altlook",function()
	altlook = true
end)
concommand.Add("-altlook",function()
	altlook = false
end)

local MaxLookX,MinLookX = 55,-55 
local MaxLookY,MinLookY = 45,-45

hook.Add( "HG.InputMouseApply", "FreezeTurning", function( tbl )

	MaxLookX,MinLookX = hg.MaxLookX or MaxLookX, hg.MinLookX or MinLookX
	MaxLookY,MinLookY = hg.MaxLookY or MaxLookY, hg.MinLookY or MinLookY

	if not altlook then
		LookY = LerpFT(0.1, LookY, 0)
		LookY = math.abs(LookY) > 0.01 and LookY or 0
		LookX = LerpFT(0.1, LookX, 0)
		LookX = math.abs(LookX) > 0.01 and LookX or 0
	end
	
	if altlook and LocalPlayer():Alive() then
		LookX = math.Clamp(LookX + tbl.x * 0.015, MinLookX, MaxLookX)
    	LookY = math.Clamp(LookY + tbl.y * 0.015, MinLookY, MaxLookY)
		
		tbl.x = 0
		tbl.y = 0
	end

end )

hg.CalcView = CalcView
hook.Add("CalcView", "homigrad-view", function(ply, origin, angles, fov, znear, zfar)
	local viewa = viewOverride
	viewOverride = nil
	return viewa or CalcView(ply, origin, angles, fov, znear, zfar)
end)

local hook_Run = hook.Run
local render_RenderView = render.RenderView
local renderView = {
	x = 0,
	y = 0,
	drawhud = true,
	drawviewmodel = true,
	dopostprocess = true,
	drawmonitors = true,
	fov = 100
}
local fliprt = GetRenderTarget( "fb_flipped", ScrW(), ScrH(), false )
local fliprtmat = CreateMaterial(
    "fliprtmat",
    "UnlitGeneric",
    {
        [ '$basetexture' ] = fliprt,
        [ '$basetexturetransform' ] = "center .5 .5 scale -1 1 rotate 0 translate 0 0",
    }
)

local invertCam = CreateClientConVar("hg_cheats","0",false,false,"enable uselezz cheats",0,1)

hook.Add("HG.InputMouseApply","ASdInvert",function(tbl)
	if invertCam:GetBool() then
		tbl.x = -tbl.x
		--print("huy")
		--return true
	end
end)

hook.Add( "CreateMove", "flipmove", function( cmd )	
	if invertCam:GetBool() then
		cmd:SetSideMove( -cmd:GetSideMove() )
	end
end)

local hg_norenderoverride = ConVarExists("hg_norenderoverride") and GetConVar("hg_norenderoverride") or CreateClientConVar("hg_norenderoverride", 0, true, false, "if you have lags you can try turning that on", 0, 1)
local mapswithfog = { -- Надо от сервер сайда сделать...
	["gm_freespace_09_super_extended_night"] = 5500,
	["gm_white_forest_countryside"] = 6000,
	["gm_york_remaster"] = 9500,
	["gm_city_of_silence"] = 1500,
	--["gm_construct"] = 8000,
	["gm_fork"] = 9500,
	["rp_zapolye_v2"] = 7500
}
--GlobalRenderOverideTickOFF = true
local zfar = mapswithfog[game.GetMap()] or 0
local map = game.GetMap()
local render_RenderView
local scrw,scrh = ScrW(),ScrH()
local entmeta = FindMetaTable("Entity")
local eyepos = entmeta.EyePos
local eyeangles = entmeta.EyeAngles
local fLPly = LocalPlayer
local IsValid = IsValid
local function renderscene(pos, angle, fov)
	lply = IsValid(lply) and lply or fLPly()
	
	pos = eyepos(lply)
	angle = eyeangles(lply)
	local view = CalcView(lply, pos, angle, fov)
	viewOverride = view
	
	local invert = invertCam:GetBool()
	
	RENDERSCENE = nil
	if not view then return end
	if invert then
		local oldrt = render.GetRenderTarget()
		render.SetRenderTarget( fliprt )
	end

	--hook.Run("HG_RenderScene", pos, angle, fov)

	renderView.w = scrw
	renderView.h = scrh
	renderView.fov = fov
	renderView.origin = view.origin
	renderView.angles = view.angles
	if mapswithfog[map] then
		renderView.zfar = zfar
	end
	//local cur = hg.GetCurrentCharacter(lply)
	//if cur == lply then hg.renderOverride(cur, lply) end

	lply.norender = true
	
	if not render_RenderView then render_RenderView = render.RenderView return end
	if not isvector(view.origin) or not isangle(view.angles) then return end
	--if GlobalRenderOverideTickOFF then GlobalRenderOverideTickOFF = nil return end
	--lply:DrawModel()

	render_RenderView(renderView)
	lply.norender = nil
	
	if invert then
		render.SetRenderTarget( oldrt )
		fliprtmat:SetTexture( "$basetexture", fliprt )
		render.SetMaterial( fliprtmat )
		render.DrawScreenQuad()
	end

	return true
end


cvars.AddChangeCallback( "hg_norenderoverride", function(cvar, old, new)
	if tonumber(new) == 0 then
		hook.Add("RenderScene", "jopa", renderscene)
	else
		--hook.Remove("RenderScene", "jopa")
	end
end, "huynuck")

hook.Add("RenderScene", "jopa", renderscene)

local vector_zero = Vector(0,0,0)
net.Receive("LookAway",function()
	local ply = net.ReadEntity()
	local LookX = net.ReadFloat()
	local LookY = net.ReadFloat()
	-- THE MOST TERRRRIBLE EXPPPLOIT EVERRR IS FFFRIXED!!!!!!!!!! :3 -w-
	ply.LookX1 = math.Clamp(LookX,MinLookX,MaxLookX)
	ply.LookY1 = math.Clamp(LookY,MinLookY,MaxLookY)
	ply.LastLookSend = CurTime()
end)

local angle_use = Angle(0,0,0)
hook.Add("Bones","HeadTurnAway",function(ply)
	if (ply.head_netsendtime or 0) < CurTime() and ply == LocalPlayer() and (hg.IsChanged(LookX, "LookX") or hg.IsChanged(LookY, "LookY")) then
		ply.head_netsendtime = CurTime() + 0.1
		
		net.Start("LookAway", true)
			net.WriteFloat(LookX)
			net.WriteFloat(LookY)
		net.SendToServer()
	end

	local lply = ply == LocalPlayer()

	if not lply and ((ply.LastLookSend or 0) + 1) < CurTime() then
		ply.LookX = nil
		ply.LookY = nil
	end

	ply.LookX = Lerp(0.1, ply.LookX or 0, lply and LookX or ply.LookX1 or 0)
	ply.LookY = Lerp(0.1, ply.LookY or 0, lply and LookY or ply.LookY1 or 0)

	local angle = angle_use
	angle[2] = -(ply.LookY or 0) * 0.6
	angle[3] = -(ply.LookX or 0) * 0.6

	if !angle:IsEqualTol(angle_zero, 0.01) then
		hg.bone.Set(ply, "head", vector_origin, angle, "headturn")
	end
end)

local n = 35
local color = Color(render.GetFogColor())
local fogcolor = Color(render.GetFogColor())
local tbl = {}
local function DrawFog(bDepth, bSkybox)
	if not mapswithfog[map] then return end
	--if ( bSkybox ) then return end

	render.SetColorMaterial()

	local view = render.GetViewSetup()
	local pos = view.origin
	local ang = view.angles

	zfar = LerpFT(0.005, zfar, not util.IsSkyboxVisibleFromPoint( pos ) and 15000 or mapswithfog[map])

	local zfar = zfar-(mapswithfog[map]/2.5)
	for i = 1, n do
		tbl[i] = tbl[i] or ColorAlpha(color, (i/n) * 110 )
		--tbl[i]["r"] = fogcolor["r"]
		--tbl[i]["g"] = fogcolor["g"]
		--tbl[i]["b"] = fogcolor["b"]
		render.DrawSphere( pos, -(zfar+((i-1)*(n))), 15, 15, tbl[i] )
	end
	--local clr1, clr2, clr3 = render.GetFogColor()
	--fogcolor["r"] = clr1
	--fogcolor["g"] = clr2
	--fogcolor["b"] = clr3
end
hook.Add( "PreDrawTranslucentRenderables", "FPS_Fog", function( bDepth, bSkybox )
	DrawFog(bDepth, bSkybox)
end )

--hook.Add( "PreDrawOpaqueRenderables", "FPS_Fog", function( bDepth, bSkybox )
--	--DrawFog(bDepth, bSkybox)
--end )