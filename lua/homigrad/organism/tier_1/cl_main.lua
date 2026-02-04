hg.bonetohitgroup = {
	["ValveBiped.Bip01_Head1"] = HITGROUP_HEAD,
	["ValveBiped.Bip01_L_UpperArm"] = HITGROUP_LEFTARM,
	["ValveBiped.Bip01_L_Forearm"] = HITGROUP_LEFTARM,
	["ValveBiped.Bip01_L_Hand"] = HITGROUP_LEFTARM,
	["ValveBiped.Bip01_R_UpperArm"] = HITGROUP_RIGHTARM,
	["ValveBiped.Bip01_R_Forearm"] = HITGROUP_RIGHTARM,
	["ValveBiped.Bip01_R_Hand"] = HITGROUP_RIGHTARM,
	["ValveBiped.Bip01_Pelvis"] = HITGROUP_CHEST,
	["ValveBiped.Bip01_Spine2"] = HITGROUP_CHEST,
	["ValveBiped.Bip01_Spine1"] = HITGROUP_STOMACH,
	["ValveBiped.Bip01_Spine4"] = HITGROUP_CHEST,
	["ValveBiped.Bip01_Spine"] = HITGROUP_STOMACH,
	["ValveBiped.Bip01_L_Thigh"] = HITGROUP_LEFTLEG,
	["ValveBiped.Bip01_L_Calf"] = HITGROUP_LEFTLEG,
	["ValveBiped.Bip01_L_Foot"] = HITGROUP_LEFTLEG,
	["ValveBiped.Bip01_R_Thigh"] = HITGROUP_RIGHTLEG,
	["ValveBiped.Bip01_R_Calf"] = HITGROUP_RIGHTLEG,
	["ValveBiped.Bip01_R_Foot"] = HITGROUP_RIGHTLEG
}

hg.amputeetable = {
	--["ValveBiped.Bip01_L_UpperArm"] = "larm",
	["ValveBiped.Bip01_L_Forearm"] = "larm",
	["ValveBiped.Bip01_L_Hand"] = "larm",
	--["ValveBiped.Bip01_R_UpperArm"] = "rarm",
	["ValveBiped.Bip01_R_Forearm"] = "rarm",
	["ValveBiped.Bip01_R_Hand"] = "rarm",
	--["ValveBiped.Bip01_L_Thigh"] = "lleg",
	["ValveBiped.Bip01_L_Calf"] = "lleg",
	["ValveBiped.Bip01_L_Foot"] = "lleg",
	--["ValveBiped.Bip01_R_Thigh"] = "rleg",
	["ValveBiped.Bip01_R_Calf"] = "rleg",
	["ValveBiped.Bip01_R_Foot"] = "rleg"
}

--[[hg.amputeetable = {
	[HITGROUP_LEFTLEG] = "lleg",
	[HITGROUP_RIGHTLEG] = "rleg",
	[HITGROUP_LEFTARM] = "larm",
	[HITGROUP_RIGHTARM] = "rarm",
	//[HITGROUP_HEAD] = 0.5
}--]]

hook.Add("ScalePlayerDamage", "remove-effects", function(ent, hitgroup, dmgInfo)
	if dmgInfo:IsDamageType(DMG_BUCKSHOT + DMG_BULLET + DMG_SLASH) then
		return true
	end
end)

local min = math.min
local pain_mat = Material("sprites/mat_jack_hmcd_narrow")

local tab = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 1,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0,
}

local tabblood = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 1,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0,
}

local k1, k2, k3

local upDir = Vector(0, 0, 1)
local fwdDir = Vector(0, 2.5, 0)
local rightDir = Vector(2.5, 0, 0)

local function MegaDSP(ply)
		local trDist = 3000
		local view = render.GetViewSetup()
		local viewent = GetViewEntity()
		local filter = {hg.GetCurrentCharacter(ply),ply,viewent}
		local trUp = util.TraceLine({
			start = view.origin,
			endpos = view.origin + upDir * trDist,
			filter = filter
		})
		local trUpFwdL = util.TraceLine({
			start = view.origin,
			endpos = view.origin + (upDir + fwdDir - rightDir) * trDist,
			filter = filter
		})
		local trUpFwd = util.TraceLine({
			start = view.origin,
			endpos = view.origin + (upDir + fwdDir + rightDir / 2) * trDist,
			filter = filter
		})
		local trUpFwdR = util.TraceLine({
			start = view.origin,
			endpos = view.origin + (upDir + fwdDir + rightDir) * trDist,
			filter = filter
		})
		local trUpBackL = util.TraceLine({
			start = view.origin,
			endpos = view.origin + (upDir - fwdDir - rightDir) * trDist,
			filter = filter
		})
		local trUpBack = util.TraceLine({
			start = view.origin,
			endpos = view.origin + (upDir - fwdDir + rightDir / 2) * trDist,
			filter = filter
		})
		local trUpBackR = util.TraceLine({
			start = view.origin,
			endpos = view.origin + (upDir - fwdDir + rightDir) * trDist,
			filter = filter
		})
		local trRight = util.TraceLine({
			start = view.origin,
			endpos = view.origin + (upDir + rightDir) * trDist,
			filter = filter
		})
		local trLeft = util.TraceLine({
			start = view.origin,
			endpos = view.origin + (upDir - rightDir) * trDist,
			filter = filter
		})
	
		local trDown = util.TraceLine({
			start = view.origin,
			endpos = view.origin - upDir * trDist,
			filter = filter
		})
		local trDownFwdL = util.TraceLine({
			start = view.origin,
			endpos = view.origin + (-upDir + fwdDir - rightDir) * trDist,
			filter = filter
		})
		local trDownFwd = util.TraceLine({
			start = view.origin,
			endpos = view.origin + (-upDir + fwdDir + rightDir / 2) * trDist,
			filter = filter
		})
		local trDownFwdR = util.TraceLine({
			start = view.origin,
			endpos = view.origin + (-upDir + fwdDir + rightDir) * trDist,
			filter = filter
		})
		local trDownBackL = util.TraceLine({
			start = view.origin,
			endpos = view.origin + (-upDir - fwdDir - rightDir) * trDist,
			filter = filter
		})
		local trDownBack = util.TraceLine({
			start = view.origin,
			endpos = view.origin + (-upDir - fwdDir + rightDir / 2) * trDist,
			filter = filter
		})
		local trDownBackR = util.TraceLine({
			start = view.origin,
			endpos = view.origin + (-upDir - fwdDir + rightDir) * trDist,
			filter = filter
		})
		local trDownRight = util.TraceLine({
			start = view.origin,
			endpos = view.origin + (-upDir + rightDir) * trDist,
			filter = filter
		})
		local trDownLeft = util.TraceLine({
			start = view.origin,
			endpos = view.origin + (-upDir - rightDir) * trDist,
			filter = filter
		})
	
		local avgUpDist = 0
		local avgDownDist = 0
		local avgDist
		local upTraces = {trUp, trUpFwdL, trUpFwd, trUpFwdR, trUpBackL, trUpBack, trUpBackR, trRight, trLeft}
		local downTraces = {trDown, trDownFwdL, trDownFwd, trDownFwdR, trDownBackL, trDownBack, trDownBackR, trDownRight, trDownLeft}
		local shouldCompute = true
	
		for _, tr in ipairs(upTraces) do
			-- debugoverlay.Line(view.origin, tr.HitPos, 0.1)
			if not tr.Hit or tr.HitSky then
				shouldCompute = false
				break
			end
		end
		for _, tr in ipairs(downTraces) do
			-- debugoverlay.Line(view.origin, tr.HitPos, 0.1)
			if not tr.Hit or tr.HitSky then
				shouldCompute = false
				break
			end
		end
	
		if shouldCompute then
			for _, tr in ipairs(upTraces) do
				avgUpDist = avgUpDist + (tr.Hit and (tr.HitPos - view.origin):LengthSqr() or 0)
			end
			avgUpDist = avgUpDist / #upTraces
	
			for _, tr in ipairs(downTraces) do
				avgDownDist = avgDownDist + (tr.Hit and (tr.HitPos - view.origin):LengthSqr() or 0)
			end
			avgDownDist = avgDownDist / #downTraces
			
			avgDist = avgUpDist > avgDownDist and avgUpDist or avgDownDist
		else
			avgDist = 10 ^ 8
		end
	
		-- Do not set to 0 for no effect; it causes DSP allocation error.
		--print(avgDist)
		if avgDist > 50000000 then
			RunConsoleCommand("dsp_player", 0)
			RunConsoleCommand("room_type", 1)
		elseif avgDist > 5000000 then
			RunConsoleCommand("dsp_player", 105)
			RunConsoleCommand("room_type", 1)
		elseif avgDist > 500000 then
			RunConsoleCommand("dsp_player", 3)
			RunConsoleCommand("room_type", 1)
		elseif avgDist > 50000 then
			RunConsoleCommand("dsp_player", 2)
			RunConsoleCommand("room_type", 1)
		elseif avgDist > 5000 then
			RunConsoleCommand("dsp_player", 104)
			RunConsoleCommand("room_type", 1)
		elseif avgDist <= 5000 then
			RunConsoleCommand("dsp_player", 102)
			RunConsoleCommand("room_type", 1)
		end
end

local function plyCommand(ply,cmd)
	local time = CurTime()
	ply.cmdtimer = ply.cmdtimer or time

	if cmd == "soundfade 100 99999" then
		if IsValid(hg.chat) then
			hg.chat:SetRealAlpha(0)

			timer.Create("otrubhuy", 1, 1, function()
				if not lply.organism.otrub then lply:ConCommand("soundfade 0 1") end
				hg.chat:AnimateRealAlpha(255)
			end)
		end
	end

	if ply.cmdtimer < time then
		ply.cmdtimer = time + 0.1

		ply:ConCommand(cmd)
	end
end

local clr_black1 = Color( 0, 0, 0, 255)
local clr_black2 = Color( 0, 0, 0, 255)

local mat1 = Material("vgui/gradient-u")
local mat2 = Material("vgui/gradient-d")

local ang1 = Angle()
local ang2 = Angle()

hook.Add("HUDShouldDraw", "hg.HUDShouldDraw", function(id)
	if (fakeTimer and fakeTimer - 2 > CurTime()) then
		return false
	end
end)

hook.Add("HG_OnOtrub", "adsadsadhuy!!", function(ply)	
	if ply == LocalPlayer() then
		lply:SetDSP(17)
		plyCommand(lply,"soundfade 100 99999")
	end
end)

hook.Add("Player_Death", "adsadsadhuy!!", function(ply)	
	if ply == LocalPlayer() then
		lply:SetDSP(17)
		plyCommand(lply,"soundfade 100 99999")
	end
end)

local auto_dsp_convar = ConVarExists("hg_auto_dsp") and GetConVar("hg_auto_dsp") or CreateClientConVar("hg_auto_dsp","1",true,false,"Enable auto D.S.P. (Reverb, echo etc.)",0,1)

local alivestart = CurTime()
hg.screens = hg.screens or {}
local screens = hg.screens
local screened = 0
local curscreen = 1
local switch = false
local file_Delete = file.Delete
hg.alivecntr = hg.alivecntr or 0

local function remove_imgs()
	if file.Exists("dreams", "DATA") then
		local files, _ = file.Find("dreams/*", "DATA")

		for i, file in pairs(files) do
			file_Delete("dreams/"..file)
		end
	end
end

local disorientationLerp = 0

hook.Add("Player Spawn", "screenshot_game", function(ply)
	if OverrideSpawn then return end

	if ply == lply then
		disorientationLerp = 0

		alivestart = CurTime()
		lply.tried_fixing_limb = nil

		hg.alivecntr = hg.alivecntr + 1

		for i, screen in ipairs(hg.screens) do
			hg.screens[i] = nil
		end

		remove_imgs()
	end
end)

hook.Add("InitPostEntity", "removeshits", function()
	remove_imgs()
end)

hook.Add("Player Disconnected", "removeshits", function()
	remove_imgs()
end)

hook.Add("radialOptions", "DislocatedJoint", function()
    if !lply:Alive() or !lply.organism or lply.organism.otrub then return end
	if (lply.tried_fixing_limb or 0) > CurTime() then return end
	local org = lply.organism
	if org.pain > 60 then return end
    
    if org.llegdislocation or org.rlegdislocation then
        local tbl = {
            function()
				lply.tried_fixing_limb = CurTime() + 0.5
				RunConsoleCommand("hg_fixdislocation", 1, 0)
            end,
            "Fix dislocation (leg)"
        }
        hg.radialOptions[#hg.radialOptions + 1] = tbl
	else
		local ent = hg.eyeTrace(lply).Entity

		if ent.organism and (ent.organism.llegdislocation or ent.organism.rlegdislocation) then
			local tbl = {
				function()
					lply.tried_fixing_limb = CurTime() + 0.5
					RunConsoleCommand("hg_fixdislocation", 1, 1)
				end,
				"Fix "..ent:GetPlayerName().."'s dislocation (leg)"
			}
			hg.radialOptions[#hg.radialOptions + 1] = tbl
		end
    end
end)

hook.Add("radialOptions", "DislocatedJoint2", function()
    if !lply:Alive() or !lply.organism or lply.organism.otrub then return end
	if (lply.tried_fixing_limb or 0) > CurTime() then return end
	local org = lply.organism
	if org.pain > 60 then return end
	
    if org.larmdislocation or org.rarmdislocation then
        local tbl = {
            function()
				lply.tried_fixing_limb = CurTime() + 0.5
				RunConsoleCommand("hg_fixdislocation", 2, 0)
            end,
            "Fix dislocation (arm)"
        }
        hg.radialOptions[#hg.radialOptions + 1] = tbl
	else
		local ent = hg.eyeTrace(lply).Entity

		if ent.organism and (ent.organism.larmdislocation or ent.organism.rarmdislocation) then
			local tbl = {
				function()
					lply.tried_fixing_limb = CurTime() + 0.5
					RunConsoleCommand("hg_fixdislocation", 2, 1)
				end,
				"Fix "..ent:GetPlayerName().."'s dislocation (arm)"
			}
			hg.radialOptions[#hg.radialOptions + 1] = tbl
		end
    end
end)

hook.Add("radialOptions", "DislocatedJaw", function()
    if !lply:Alive() or !lply.organism or lply.organism.otrub then return end
	if (lply.tried_fixing_limb or 0) > CurTime() then return end
	local org = lply.organism
	if org.pain > 60 then return end
	
    if org.jawdislocation then
        local tbl = {
            function()
				lply.tried_fixing_limb = CurTime() + 0.5
				RunConsoleCommand("hg_fixdislocation", 3, 0)
            end,
            "Fix dislocation (jaw)"
        }
        hg.radialOptions[#hg.radialOptions + 1] = tbl
	else
		local ent = hg.eyeTrace(lply).Entity

		if ent.organism and ent.organism.jawdislocation then
			local tbl = {
				function()
					lply.tried_fixing_limb = CurTime() + 0.5
					RunConsoleCommand("hg_fixdislocation", 3, 1)
				end,
				"Fix "..ent:GetPlayerName().."'s dislocation (jaw)"
			}
			hg.radialOptions[#hg.radialOptions + 1] = tbl
		end
    end
end)

hook.Add("PostRender", "screenshot_think", function()
	do return end
	local org = lply.organism
	
	if not org or not org.brain or org.otrub or !lply:Alive() then return end
	
	local part = CurTime() - alivestart
	//print(part)
	if part % 60 > 59 and (screened != math.Round(part / 60, 0)) then
		screened = math.Round(part / 60, 0)
		//gui.HideGameUI()

		if gui.IsGameUIVisible() or gui.IsConsoleVisible() or IsValid(vgui.GetHoveredPanel()) then return end

		local data = render.Capture( {
			format = "jpeg",
			x = 0,
			y = 0,
			w = ScrW(),
			h = ScrH(),
			quality = 1,
			//alpha = false
		} )

		if not data then return end

		local name = "dreams/dream"..hg.alivecntr.."_"..(#screens + 1)..".jpeg"
		
		if not file.Exists("dreams", "DATA") then file.CreateDir("dreams") end
		file.Write(name, data)
		
		timer.Simple(1, function()
			screens[#screens + 1] = Material("data/"..name)
		end)
	end
end)

local braindeathstart = CurTime() + 20
local lerpedpart = 0
local lerpedbrain = 0

hook.Add("Post Pre Post Processing", "ShowScreens", function()
	do return end
	local org = lply.organism
	
	if !lply:Alive() then return end
	if not org or not org.brain then return end

	local part = CurTime() - braindeathstart

	local show_multiki = org.brain > 0.1 and org.otrub

	if show_multiki then
		lerpedbrain = LerpFT(0.05, lerpedbrain, org.brain)
		local time = 40 - (lerpedbrain - 0.1) * 20
		if part % time > time / 3 and curscreen <= #screens and screens[curscreen] and !screens[curscreen]:IsError() then
			switch = true
			local part2 = math.ease.InOutSine(math.sin(((part % time) - time / 3) / (time / 3 * 2) * math.pi))
			lerpedpart = LerpFT(0.1, lerpedpart, part2)
			
			surface.SetDrawColor(255, 255, 255, math.Clamp(lerpedpart * 50, 0, 255))
			surface.SetMaterial(screens[curscreen])
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

			DrawToyTown(4, ScrH())
		else
			if switch then
				curscreen = curscreen == #screens and 1 or curscreen + 1
				switch = false
			end
		end
	else
		braindeathstart = CurTime()
	end
end)

local hurtoverlay = Material("zcity/neurotrauma/damageOverlay.png")
local blindoverlay = Material("zcity/neurotrauma/blindoverlay.png")
local addtime = CurTime()

local hg_potatopc
local old = false
local tinnitusSoundFactor
local lerpblood = 0
hook.Add("RenderScreenspaceEffects", "organism-effects", function()
	local spect = IsValid(lply:GetNWEntity("spect")) and lply:GetNWEntity("spect")
	local organism = lply:Alive() and lply.organism or (viewmode == 1 and IsValid(spect) and spect.organism) or {}
	local new_organism = lply:Alive() and lply.new_organism or (viewmode == 1 and IsValid(spect) and spect.new_organism) or {}

	//hg.DrawAffliction(0, 0, 100, 100, 1, "pale")

	if organism.owner == LocalPlayer() then
		if new_organism.otrub and !old then
			hook.Run("HG_OnOtrub", new_organism.owner)
		end
		
		old = new_organism.otrub
	end

	--LerpVariables(FrameTime(),organism,new_organism)

	if not organism then return end
	local alive = lply:Alive() or (spect and spect:Alive())

	local health = (lply:Alive() and lply:Health()) or 100

	if not alive or follow then end

	local org = organism
	
	if not org.brain then return end
	
	local adrenaline = org.adrenaline or 0
	local pulse = org.pulse or 70
	local pain = org.pain or 0
	local hurt = org.hurt or 0
	local blood = org.blood or 5000
	local bleed = org.bleed or 0
	local o2 = org.o2 and org.o2[1] or 30
	local brain = org.brain or 0
	local otrub = lply:Alive() and org.otrub or false
	local analgesia = organism.analgesia or 0
	local health = health
	local disorientation = org.disorientation or 0
	local immobilization = org.immobilization or 0
	local incapacitated = org.incapacitated or false
	local critical = org.critical or false
	tinnitusSoundFactor = Lerp(FrameTime()*2.5,tinnitusSoundFactor or 0, math.min(math.max( lply.tinnitus and (lply.tinnitus - CurTime()) or 0, 0)*7.5,120))
	local tinnitusSoundFactor2 = tinnitusSoundFactor + (hook.Run("ModifyTinnitusFactor", tinnitusSoundFactor) or 0)

	--print(lply.tinnitus)
	local adrenK = math.min(math.max(1 + adrenaline, 1), 1.2)
	
	if lply.suiciding and lply:Alive() then
		lply:SetDSP(130)
		olddspchange = true
	else
		if olddspchange then
			lply:SetDSP(0)
			olddspchange = false
		end
	end

	if org.otrub then
		//DrawMotionBlur(0.1, 1., 0.1)
		//lply:ScreenFade( SCREENFADE.IN, clr_black2, 2, 0.5 )
	end

	if otrub or (fakeTimer and fakeTimer - 2 > CurTime()) then
		--if otrub or (fakeTimer and fakeTimer - 2 > CurTime()) then
		clr_black1.a = math.Clamp(pain / 50 * 255, 250, 255)
		//lply:ScreenFade( SCREENFADE.IN, clr_black2, 2, 0.5 )
		--lply:ScreenFade( SCREENFADE.IN, Color(0,0,0,255), 2, 0.5 )
		
		if isnumber(zb.ROUND_STATE) and (zb.ROUND_STATE ~= 1) then
			lply:SetDSP(0)
			plyCommand(lply,"soundfade "..tinnitusSoundFactor2.." 25")
		elseif lply:Alive() then
			lply:SetDSP(17)
			plyCommand(lply,"soundfade 100 25")
		end
	else
		plyCommand(lply,"soundfade "..tinnitusSoundFactor2.." 25")

		if ((disorientation and disorientation > 3) or (brain and brain > 0.2)) and lply:Alive() then
			lply:SetDSP(130)
		end
		if auto_dsp_convar:GetBool() then
			MegaDSP(lply)
		else
			lply:SetDSP(0)
		end
	end

	if not alive then
		return false
	end
	
	k1 = Lerp(FrameTime() * 15, k1 or 0, math.min(math.min(adrenaline / 1, 2),1.5))
	k2 = (30 - (o2 or 30)) / 30 + (1 - (consciousnessLerp or 1)) * 1-- + brain * 2
	k3 = ((5000 / math.max(blood, 1000)) - 1) * 1.5

	DrawSharpen(k1 * 2, k1 * 1)
	local lowpulse = math.max((70 - pulse) / 70, 0) + math.max(3000 * ((math.cos(CurTime()/2) + 1) / 2 * 0.1 + 1) - (blood * adrenK - 300),0) / 400

	local amount = 1 - math.Clamp(lowpulse + disorientation / 4 + k2 * 2,0,1)

	disorientationLerp = LerpFT(disorientation > disorientationLerp and 1 or 0.01, disorientationLerp, disorientation)

	if (disorientationLerp > 1) and lply:Alive() or brain > 0 then
		local add2 = disorientationLerp - 1
		if not brain_motionblur then DrawMotionBlur(0.15 - math.Clamp(add2 / 1, 0, 0.1), add2 * 2, 0.001) end
		if disorientationLerp > 2 then
			local add = (disorientationLerp - 2) * 2
			local time = CurTime() * 3
			local mul = math.Clamp(add / 16, 0, 0.2)

			ang1[1] = math.cos(time) + math.sin(time * 0.5) + math.sin((time - 5) * 1.1)
			ang1[2] = math.sin(time) + math.cos(time * 0.5) + math.sin((time + 1) * 1.1)
			ViewPunch(ang1 * mul * 0.125)
			//ViewPunch2(ang1 * mul * 1 * 0.25)

			//local ang = lply:EyeAngles()
			//lply:SetEyeAngles(ang - ang1 * 0.01)

			ang2[3] = math.Rand(-15,15) * mul
			//SetViewPunchAngles(ang2)
			//ViewPunch(ang1 * mul * 1)
		end
	end

	if (org.consciousness < 0.7) then
		lerpblood = LerpFT(0.01, lerpblood or 0, math.Clamp((0.7 - org.consciousness) * 5, 0, 1) * 255)
		local lowblood = (3600 - blood) / 600

		addtime = addtime + FrameTime() / 6
		local amt = (math.cos(addtime) + math.sin(addtime * 3) + math.sin(addtime * 2)) / 90
		local amt2 = (math.sin(addtime) + math.cos(addtime * 5) + math.sin(addtime * 6)) / 90
		local mat = Matrix({
			{1 - amt, amt, 0, -amt2 / 2},
			{amt2, 1 - amt2, 0, -amt / 2},
			{0, 0, 1, 0},
			{0, 0, 0, 1},
		})
		hurtoverlay:SetMatrix("$basetexturetransform", mat)
		surface.SetMaterial(hurtoverlay)
		surface.SetDrawColor(0, 0, 0, lerpblood)
		surface.DrawTexturedRect(-ScrW() * 2.0, -ScrH() * 2.0, ScrW() * 5, ScrH() * 5)
		//ViewPunch(Angle(-amt * 1, amt2 * 1,0))
		//ViewPunch2(Angle(-amt * 1, amt2 * 1,0))
	end
	//pain = math.abs(math.cos(CurTime())) * 40
	if (pain > 0) or (hurt > 0) or (immobilization > 0) or (brain > 0) then
		local k = ((hurt + immobilization / 15) / 2)
		--DrawToyTown(1, k * ScrH())
		local newpain = pain - 10
		if newpain > 0 then
			//surface.SetDrawColor(0, 0, 0, (newpain / 20) * 255 - math.ease.InOutCirc(math.abs(math.cos(CurTime()))) * 50)
			//surface.SetMaterial(pain_mat)
			//surface.DrawTexturedRect(-1, -1, ScrW()+1, ScrH()+1)
			local blur = math.max((newpain / 30 + brain * 10),0) / 30
			if blur > 0 then
				DrawMaterialOverlay( "sprites/mat_jack_hmcd_scope_aberration", blur )
			end
		end
	end
	hg_potatopc = hg_potatopc or hg.ConVars.potatopc
	local potato = hg_potatopc:GetBool()
	if (k1 > 0) or (k2 > 0) or (k3 > 0) or brain > 0 then
		if !potato then
			DrawToyTown(2, (k3 * 3 + k2 * 1 + brain * 10) * ScrH() / 2)
		else

		end
	end

	--DrawMaterialOverlay( "homigrad/vgui/bloodblur.png", 0)
	local view = render.GetViewSetup()
	--RenderSuperDoF(view.origin,view.angles,0)
	if analgesia > 1 then
		DrawMaterialOverlay( "particle/warp4_warp_noz", -(analgesia - 0.5) * math.sin(CurTime()) * 5 / 150 )
	end

	/*

	local amt = (math.cos(addtime) + math.sin(addtime * 3) + math.sin(addtime * 2)) / 90
	local amt2 = (math.sin(addtime) + math.cos(addtime * 5) + math.sin(addtime * 6)) / 90
	surface.SetDrawColor(255,255,255,math.abs(amt * 255 * 30))
	surface.SetMaterial(blindoverlay)

	local mat = Matrix({
		{1 - amt, amt, 0, -amt2 / 2},
		{amt2, 1 - amt2, 0, -amt / 2},
		{0, 0, 1, 0},
		{0, 0, 0, 1},
	})
	blindoverlay:SetMatrix("$basetexturetransform", mat)
	surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

	*/

	tabblood["$pp_colour_colour"] = Lerp(FrameTime() * 30, tabblood["$pp_colour_colour"], (blood / 5000) * (potato and (blood / 5000) or 1) + (math.max(org.analgesia - 1, 0) * math.sin(CurTime()) * 5))
	//tabblood["$pp_colour_contrast"] = Lerp(FrameTime() * 30, tabblood["$pp_colour_contrast"], health < 80 and math.max(1.5 * ( 1 - math.min(health / 50, 1) ), 1 ) or 1)
	tabblood["$pp_colour_brightness"] = Lerp(FrameTime() * 30, tabblood["$pp_colour_brightness"], (potato and (blood / 5000 - 1) / 2 or 0) )
	tabblood["$pp_colour_addb"] = !org.otrub and ((potato and k2 / 5 or 0)) or 0
	//tabblood["$pp_colour_addg"] = k2 / 15
	//tabblood["$pp_colour_addr"] = k2 / 15
	--tab["$pp_colour_brightness"] = k1 > 1 and -(k1 - 1) / 20 or 0
	--tab["$pp_colour_contrast"] = k1 > 1 and -(k1 - 1) / 10 + 1 or 1
	--DrawBloom( 0.80, 2, 9, 9, 1, 1, 1, 1, 1 )
	//DrawColorModify(tab)
	
	DrawColorModify(tabblood)

	local ent = IsValid(lply.FakeRagdoll) and lply.FakeRagdoll or lply

	if otrub then
		--[[render.PushFilterMag( TEXFILTER.ANISOTROPIC )
		render.PushFilterMin( TEXFILTER.ANISOTROPIC )

		local textOtrub = "You are unconscious. "
		local textOtrub2 =  
			( critical and "You can't be saved." ) or 
			( incapacitated and "You will not get up without someone's help." ) or 
			( 
				"You will probably wake up in "
				..( 	
					( pain < 50 and "about a minute." ) or 
					( pain < 100 and "about two minutes." ) or 
					"a few minutes."
				) 
			)

		local parsed = markup.Parse( 
			"<font=HomigradFontMedium>"..
			( critical and "You're criticaly injured." or textOtrub )..
			"\n<colour=255,"..( critical and 25 or 255 )..","..( critical and 25 or 255 ) ..",255>"..
			( textOtrub2 ).."</colour></font>" 
		)
		--((critical and "You can not be saved.") or 
		--(incapacitated and "You will not get up without someone's help.") or 
		--( "You will probably wake up in " .. (pain < 50 and "about a minute.") ) or 
		--((pain < 100 and "about two minutes.") or "a few minutes.")) -- WTF???
		
		--surface.SetTextColor(255,255,255,255)
		--surface.SetFont("HomigradFontMedium")
		--local txtSizeX, txtSizeY = surface.GetTextSize(textOtrub)
		--surface.SetTextPos(ScrW()/2 - (txtSizeX/2),ScrH()/1.1 - (txtSizeY/2))
		--surface.DrawText(textOtrub)

		parsed:Draw( ScrW()/2, ScrH()/1.1, TEXT_ALIGN_CENTER, nil, nil, TEXT_ALIGN_CENTER )
		
		render.PopFilterMag()
		render.PopFilterMin()--]]
	end
	
	if IsValid(ent) and ent.Blinking and lply:Alive() then
		surface.SetDrawColor(0,0,0,255)
		if amtflashed and amtflashed > 0.1 then
			surface.DrawRect(-1,-1,ScrW()+1,ent.Blinking * ScrH())
			surface.DrawRect(-1,ScrH() + 1,ScrW()+1,-ent.Blinking * ScrH())
		end
	end
end)

hook.Add("OnNetVarSet","wounds_netvar",function(index, key, var)
	if key == "wounds" then
		local ent = Entity(index)
		--local ent = hg.RagdollOwner(ent) or ent
		
		if IsValid(ent) then
			if ent.wounds then
				for i = 1, #ent.wounds do
					if !var or !var[i] then continue end
					var[i][5] = ent.wounds[i][5]
				end
			end

			ent.wounds = var
			--PrintTable(ent.wounds)
			local rag = IsValid(ent:GetNWEntity("FakeRagdoll")) and ent:GetNWEntity("FakeRagdoll")-- or IsValid(ent:GetNWEntity("RagdollDeath")) and ent:GetNWEntity("RagdollDeath")
			if IsValid(rag) then
				rag.wounds = rag:GetNetVar("wounds") or var
			end
		end
	end
end)

hook.Add("OnNetVarSet","wounds_netvar2",function(index, key, var)
	if key == "arterialwounds" then
		local ent = Entity(index)
		--local ent = hg.RagdollOwner(ent) or ent
		
		if IsValid(ent) then
			if ent.arterialwounds then
				for i = 1, #ent.arterialwounds do
					if not var[i] then continue end
					var[i][5] = ent.arterialwounds[i][5]
				end
			end

			ent.arterialwounds = var
			local rag = IsValid(ent:GetNWEntity("FakeRagdoll")) and ent:GetNWEntity("FakeRagdoll")-- or IsValid(ent:GetNWEntity("RagdollDeath")) and ent:GetNWEntity("RagdollDeath")
			
			if IsValid(rag) then
				rag.arterialwounds = rag:GetNetVar("arterialwounds") or var
			end
		end
	end
end)

hook.Add("Player Spawn", "removewounds", function(ply)
	if OverrideSpawn then return end

	ply.wounds = {}
	ply.arterialwounds = {}
end)

hook.Add("Fake", "huyhuyhuy235", function(ply,ragdoll)
	if not IsValid(ragdoll) then return end

	ragdoll.wounds = ply.wounds
	ragdoll.arterialwounds = ply.arterialwounds
end)

function hg.applyFountain(pos, ang, mul, mul2, forward, ent)
	if bit.band(util.PointContents(pos), CONTENTS_WATER) == CONTENTS_WATER then
		if math.random(2) == 1 then return end
		hg.addBloodPart2(pos, ang:Forward() * forward * 0.5 + VectorRand(-25,25) * mul2, nil, nil, nil, nil, true, nil, ent)
		hg.addBloodPart2(pos + VectorRand(-1,1), ang:Forward() * forward * 0.25 + VectorRand(-10,10) * mul2, nil, nil, nil, nil, true, nil, ent)
		//hg.addBloodPart2(pos + VectorRand(-1,1), ang:Forward() * forward * 0.25 + VectorRand(-10,10) * mul2, nil, nil, nil, nil, true, nil, ent)
	else
		hg.addBloodPart(pos, ang:Forward() * forward * 2 * math.abs(math.sin(CurTime() * 3) + math.cos(CurTime() * 5) + math.sin(CurTime() * 2) + 4) * 0.1 + ang:Right() * 15 * (math.sin(CurTime()) * 1) + ang:Right() * math.sin(CurTime() * 2) * 15 + VectorRand(-3, 3),nil,nil,nil,true)
		hg.addBloodPart(pos + VectorRand(-1,1), ang:Forward() * 55 + VectorRand(-25,25) * mul2,nil,nil,nil,nil, nil, ent)
		//hg.addBloodPart(pos + VectorRand(-1,1), ang:Forward() * 55 + VectorRand(-25,25) * mul2,nil,nil,nil,nil, nil, ent)
	end
end

local hg_old_blood = ConVarExists("hg_old_blood") and GetConVar("hg_old_blood") or CreateClientConVar("hg_old_blood", 0, true, false, "new decals, or old", 0, 1)
local vecTorso = Vector(1, 1, 1)
local checkpulsebones = {
	["ValveBiped.Bip01_Head1"] = true,
	["ValveBiped.Bip01_R_Hand"] = true,
	["ValveBiped.Bip01_L_Hand"] = true,
}
local hg_blood_fps = ConVarExists("hg_blood_fps") and GetConVar("hg_blood_fps") or CreateClientConVar("hg_blood_fps", 24, true, nil, "fps to draw blood", 12, 165)

hook.Add("Player-Ragdoll think", "organism-think-client-blood", function(ply, ent, time)
	--local ent = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or ply
	--print(ply,ent,ply.organism.owner,ply.new_organism.owner)
	local organism = ply.organism
	local new_organism = ply.new_organism
	
	local seen = ent.shouldTransmit-- and not ent.NotSeen
	local wounds = ply.wounds
	local arterialwounds = ply.arterialwounds

	local org = ent.organism

	if !org then return end

	if org and org.pulse and org.o2 and org.o2[1] then
		local pulse = org.heartbeat
		ent.pulsethink = ent.pulsethink or 0
		local speed = math.Clamp(org.heartbeat / 60, 1, 120) * 0.5 * (org.o2[1] < 8 and 0 or 1)
		ent.pulsethink = ent.pulsethink + (org.holdingbreath and 0 or 1) * FrameTime() * 4 * (speed)

		local torso = ent:LookupBone("ValveBiped.Bip01_Spine2")
		--local chest = ent:LookupBone("ValveBiped.Bip01_Spine1")
		
		if torso then
			if ent:GetPos():Distance(lply:GetPos()) > 450 then return end
			local sin = (math.sin(ent.pulsethink) + 1) * 0.5
			local amt = 0.02 * sin * pulse / 70 * ((org.alive and !ent.headexploded) and 1 or 0)
			
			local size = 1 + amt
			vecTorso[1] = size
			vecTorso[2] = size
			vecTorso[3] = size
			
			ent:ManipulateBoneScale(torso, vecTorso)

			vecTorso[1] = 0
			vecTorso[2] = amt * 2
			vecTorso[3] = 0
			
			if sin < 0.1 and org.analgesia <= 1.5 and not org.breathed then
				org.breathed = true
				local heartbeat = org.heartbeat or 0
				local muffed
				
				if ent.armors then
					muffed = ent.armors["face"] == "mask2" or ent.PlayerClassName == "Combine"
				end
				ent:EmitSound("snds_jack_hmcd_breathing/" .. (ThatPlyIsFemale(ent) and "f" or "m") .. math.random(4) .. ".wav", min(heartbeat * 1.0 / ( muffed and 2.5 or 4), 45), math.random(95, 105) + (ply.PlayerClassName and ply.PlayerClassName == "furry" and 20 or 0), 0.5 * (((org.stamina and org.stamina[1] and org.stamina[1] < 160) or org.heartbeat > 140) and 1 or 0.05), CHAN_AUTO, 0, muffed and 16 or 0)
			elseif org.breathed and sin >= 0.1 then
				org.breathed = false
			end

			--ent:ManipulateBonePosition(torso, vecTorso)

			--local size = 1 - 0.02 * math.sin(ent.pulsethink)
			--vecTorso[1] = size
			--vecTorso[2] = size
			--vecTorso[3] = size

			--ent:ManipulateBoneScale(chest, vecTorso)
		end
	end

	ply.pulse_breathe = ply.pulse_breathe or {}
	ent.pulse_breathe = ply.pulse_breathe
	
	hg.LerpVariables(FrameTime() * 10, organism, new_organism)
	
	local org = ent.organism or {}
	local owner = ent
	
	local beatsPerSecond = math.max(min(30 / math.max(org.pulse or 70,2), 4), 0.1) * (!hg_old_blood:GetBool() and 0.3 or 1)
		
	if org.pulse and org.heartbeat > 30 and (org.lastpulse or 0) + (1 / math.Clamp(org.heartbeat, 1, 600)) * 60 < CurTime() then
		org.lastpulse = CurTime()
		local pulse = org.heartbeat or 0
		local pain = org.pain or 0
		
		local dist = owner:GetPos():DistToSqr(lply:GetPos())
		local carryent = lply:GetNetVar("carryent")
		local carrybone = lply:GetNetVar("carrybone")
		local cantcheck = org.CantCheckPulse
		local checkingplayer = (IsValid(carryent) and carryent.organism == ply.organism and !cantcheck and checkpulsebones[carryent:GetBoneName(carryent:TranslateBoneToPhysBone(carrybone))])
		
		if dist < 64 * 64 and (ply == lply or checkingplayer) then
			local vol = checkingplayer and 2 or ((pain > 60 and ply == lply) and 1 or (pulse > 200 and ((200 - 95) / 50 + 0.12 - (pulse - 200) / 1000) or pulse > 95 and (pulse - 95) / 50 + 0.12 or 0.12))
			
			--ply:EmitSound("heartbeat/heartbeat_single.wav", 55, 60, vol)
			if ent:GetVelocity():LengthSqr() < 10 then
				sound.Play("heartbeat/heartbeat_single.wav", ply:EyePos(), 55, 60, vol)
			else
				EmitSound("heartbeat/heartbeat_single.wav", ply:EyePos(), ply:EntIndex(), CHAN_AUTO, vol, 55, nil, 60)
			end
		end
	end

	--why?

	if org.pulse and (ent.pulse_breathe.lastbreathe or 0) < CurTime() and org.o2 and org.o2[1] and (org.heartbeat > 80 or (org.o2[1] < 15 and ent:WaterLevel() == 3)) and org.lungsfunction and not org.holdingbreath and org.timeValue then
		local heartbeat = org.heartbeat or 0
		ent.pulse_breathe.lastbreathe = CurTime() + (1 / math.Clamp(org.heartbeat + (org.o2[1] - 30) * 1, 1, 120)) * 90 + ( org.o2[1] < 20 and 5 or 0)
		
		if (ent:WaterLevel() < 3) then
			local muffed

			if ent.armors then
				muffed = ent.armors["face"] == "mask2" or ent.PlayerClassName == "Combine"
			end
			
			if org.o2.curregen <= org.timeValue * 0.5 and org.o2[1] < 20 then
				if org.analgesia <= 1.5 then
					ply:EmitSound("zcitysnd/real_sonar/"..(ThatPlyIsFemale(ent) and "fe" or "").."male_wheeze"..math.random(5)..".mp3", 40, nil, nil, nil, nil, 1)
				end
			end
		else
			if org.o2[1] < 15 then
				ply:EmitSound("zcitysnd/real_sonar/"..(ThatPlyIsFemale(ent) and "fe" or "").."male_drown"..math.random(5)..".mp3", 60)
			end
		end
	end

	local fountains = GetNetVar("fountains")
	if fountains and fountains[ent] then
		local tbl = fountains[ent]
		if (tbl.time or 0) < CurTime() and org.pulse then
			local mul = 1 / math.max(org.pulse / 40 * 25, 2) * 0.75
			local mul2 = math.max(org.pulse, 1) / 15
			local forward = mul2 * 150
			tbl.time = CurTime() + mul * 0.5
			
			if seen then
				local mat = ent:GetBoneMatrix(tbl.bone)

				if mat then
					local pos, ang = LocalToWorld(tbl.lpos, tbl.lang, mat:GetTranslation(), mat:GetAngles())
					
					hg.applyFountain(pos, ang, mul, mul2, forward, ent)
				end
			else
				local pos, ang = ent:GetPos(), angle_zero
				hg.applyFountain(pos, ang, mul, mul2, forward, ent)
			end
		end
	end
	
	if org and org.blood and org.blood > 10 and wounds and #wounds > 0 then
		if (owner:IsPlayer() and owner:Alive()) or not owner:IsPlayer() then
			for i, wound in pairs(wounds) do
				local size = math.random(0, 1) * math.max(math.min(wound[1], 1), 0.5)
				
				if wound[5] + beatsPerSecond < time then
					if seen and ent:LookupBone(wound[4]) then
						local bone = wound[4]
						local mat = ent:GetBoneMatrix(ent:LookupBone(bone))
						if not mat then return end
						local bonePos, boneAng = mat:GetTranslation(), mat:GetAngles()
						if not wound[2] or not wound[3] or not bonePos or not boneAng then return end
						local pos, ang = LocalToWorld(wound[2], wound[3], bonePos, boneAng)

						local water = bit.band(util.PointContents(pos), CONTENTS_WATER) == CONTENTS_WATER
						if water then
							if wound[5] + 1 < time then
								hg.addBloodPart2(pos, VectorRand(-5, 5), nil, nil, nil, nil, true, nil, ent)
							end
						else
							hg.addBloodPart(pos, VectorRand(-15, 15), nil, size, size, false, nil, ent)
						end

						wound[5] = time + (water and 2 or (math.Rand(0, 1) * (!hg_old_blood:GetBool() and 0.5 or 1) / wound[1] * 15))
					else
						local pos = ent:GetPos()

						local water = bit.band(util.PointContents(pos), CONTENTS_WATER) == CONTENTS_WATER
						if water then
							hg.addBloodPart2(pos, VectorRand(-5, 5), nil, nil, nil, nil, true, nil, ent)
						else
							hg.addBloodPart(pos, VectorRand(-15, 15), nil, size, size, false, nil, ent)
						end

						wound[5] = time + (water and 2 or (math.Rand(0, 1) * (!hg_old_blood:GetBool() and 0.5 or 1) / wound[1] * 15))
					end
				end
			end
		end
	end
	
	if org and org.blood and org.blood > 10 and arterialwounds and #arterialwounds > 0 then
		for i, wound in pairs(arterialwounds) do
			local addtime = seen and 1 / math.Clamp(org.pulse or 70, 1,15) * 0.25 or 0.06
			if wound[5] + addtime < time and ent:LookupBone(wound[4]) then
				local pos, ang = ent:GetBonePosition(ent:LookupBone(wound[4]))
				if (owner:IsPlayer() and owner:Alive()) or not owner:IsPlayer() then
					local size = math.random(1, 2) * math.max(math.min(wound[1], 1), 0.5)
					if seen then
						local bone = wound[4]
						local mat = ent:GetBoneMatrix(ent:LookupBone(bone))
						if not mat then return end
						local bonePos, boneAng = mat:GetTranslation(), mat:GetAngles()
						if not wound[2] or not wound[3] or not bonePos or not boneAng then return end
						local pos = LocalToWorld(wound[2], wound[3], bonePos, boneAng)

						local dir = wound[6]
						local len = dir:Length() * (org.pulse or 70) / 70
						local _, dir = LocalToWorld(vector_origin, dir:Angle(), vector_origin, ang)
						
						dir = -dir:Forward() * len

						local water = bit.band(util.PointContents(pos), CONTENTS_WATER) == CONTENTS_WATER
						if water then
							hg.addBloodPart2(pos, VectorRand(-5, 5), nil, nil, nil, nil, true, nil, ent)
						else
							hg.addBloodPart(pos, VectorRand(-1, 1) * (org.pulse or 70) / 70 + dir * 5 * (math.abs(math.sin(CurTime() * 2) + math.cos(CurTime() * (5 + i * 2)) + math.sin(CurTime() * (1 + i))) * 0.6 + math.sin(CurTime() * 2) + 4) * 0.1 + dir:Angle():Right() * 25 * math.sin(CurTime() * 2) * math.cos(CurTime() * 4) + ang:Up() * 25 * math.sin(CurTime() * 3) * math.cos(CurTime() * 1) + VectorRand(-1, 1) * (org.pulse or 70) / 70, nil, size, size, true, nil, ent)
						end

						wound[5] = time + (water and 2 or (0.5 * 1 / hg_blood_fps:GetInt()))
					else
						local pos = ent:GetPos()
						
						local water = bit.band(util.PointContents(pos), CONTENTS_WATER) == CONTENTS_WATER
						if water then
							hg.addBloodPart2(pos, VectorRand(-5, 5), nil, nil, nil, nil, true, nil, ent)
						else
							hg.addBloodPart(pos, VectorRand(-15, 15), nil, size, size, true, nil, ent)
						end

						wound[5] = time + (water and 2 or 0)
					end
				end
			end
		end
	end
end)

local grub = Model("models/grub_nugget_small.mdl")
--ValveBiped.Bip01_R_Hand
--ValveBiped.Bip01_R_Forearm
--ValveBiped.Bip01_R_Foot
--ValveBiped.Bip01_R_Thigh
--ValveBiped.Bip01_R_Calf
--ValveBiped.Bip01_R_Shoulder
--ValveBiped.Bip01_R_Elbow

local vecalmostzero = Vector(0.01, 0.01, 0.01)

local modelPlacements = {
	[1] = {
		["ValveBiped.Bip01_L_Calf"] = {Vector(15.5, 0, 0), Angle(0, 90, 0)},
		["ValveBiped.Bip01_R_Calf"] = {Vector(15.5, 0, 0), Angle(0, 90, 0)},
		["ValveBiped.Bip01_R_Forearm"] = {Vector(11, 0.5, 0.5), Angle(0, 90, 0)},
		["ValveBiped.Bip01_L_Forearm"] = {Vector(11, 0.5, -0.5), Angle(0, 90, 0)},
	},
	[0] = {
		["ValveBiped.Bip01_L_Calf"] = {Vector(17.5, 0, 0), Angle(0, 90, 0)},
		["ValveBiped.Bip01_R_Calf"] = {Vector(17.5, 0, 0), Angle(0, 90, 0)},
		["ValveBiped.Bip01_R_Forearm"] = {Vector(11, 0.5, 0.5), Angle(0, 90, 0)},
		["ValveBiped.Bip01_L_Forearm"] = {Vector(11, 0, -1), Angle(0, 90, 0)},
	}
}

local limbs = {
	["lleg"] = "ValveBiped.Bip01_L_Calf",
	["rleg"] = "ValveBiped.Bip01_R_Calf",
	["larm"] = "ValveBiped.Bip01_L_Forearm",
	["rarm"] = "ValveBiped.Bip01_R_Forearm",
}

function hg.amputatedbone(ent, bone)
	if ent.organism and hg.amputatedlimbs2[bone] then
		if ent.organism[hg.amputatedlimbs2[bone].."amputated"] then
			return true
		end
	end
end

hg.amputatedlimbs = limbs

hg.amputatedlimbs2 = {}
for k, v in pairs(limbs) do
	hg.amputatedlimbs2[v] = k
end

local vecFull = Vector(1, 1, 1)

function hg.GoreCalc(ent, ply)
	local org = ent.new_organism or ent.organism
	if !org then return end

	for bone, nam in pairs(limbs) do
		if !org[bone.."amputated"] then
			local bon = ent:LookupBone(nam)

			if !ent:GetManipulateBoneScale(bon):IsEqualTol(vecFull, 0.01) then
				ent:ManipulateBoneScale(bon, vecFull)
			end

			continue
		end
		
		local bon = ent:LookupBone(nam)
		local mat = ent:GetBoneMatrix(bon)
		local mat2 = ent:GetBoneMatrix(bon - 1)
		mat:SetScale(vecalmostzero)
		
		hg.bone_apply_matrix(ent, bon, mat)
		
		if IsValid(ply.OldFakeRagdoll) then
			hg.bone_apply_matrix(ply, bon, mat)
		end

		local fem = ThatPlyIsFemale(ent) and 1 or 0
		
		if !modelPlacements[fem][nam] then continue end

		local pos, ang = LocalToWorld(modelPlacements[fem][nam][1], modelPlacements[fem][nam][2], mat2:GetTranslation(), mat2:GetAngles())
		
		if !IsValid(headboom_mdl) then
			headboom_mdl = ClientsideModel(grub)
			headboom_mdl:SetNoDraw(true)
			--headboom_mdl:SetModel("models/grub_nugget_small.mdl")
			headboom_mdl:SetSubMaterial(0, "models/flesh")
			headboom_mdl:SetModelScale(0.8)
		end
		
		headboom_mdl:SetRenderOrigin(pos)
		headboom_mdl:SetRenderAngles(ang)
		headboom_mdl:SetupBones()
		headboom_mdl:DrawModel()
	end
end

local prank = {}
local time_troll = 100

local DontCallMe = false
hook.Add("HG.InputMouseApply","zzzzzzzzzzzzbrain_death",function(tbl)
	 

	if lply:Alive() and lply.organism and (lply.organism.brain or 0) > 0.1 then
		if #prank < time_troll then table.insert(prank,1,{tbl.x,tbl.y}) end
		if #prank >= time_troll then table.remove(prank,#prank) end
		
		local amt = lply.organism.brain / 0.3

		local xa = Lerp(1 * amt,tbl.x,prank[#prank][1])// + math.sin(CurTime() / 5) * amt * 10
		local ya = Lerp(1 * amt,tbl.y,prank[#prank][2])// + math.cos(CurTime() / 5) * math.sin(CurTime() / 2) * amt * 10

		tbl.angle.pitch = math.Clamp(tbl.angle.pitch + tbl.y / 100 + ya / 100, -89, 89)
		tbl.angle.yaw = tbl.angle.yaw - tbl.x / 100 - xa / 100
		tbl.override_angle = true
	end

	--[[local actwep = LocalPlayer():GetActiveWeapon()
	if not actwep or not actwep.GetTrace then return end
	local hitpos,pos,ang = actwep:GetTrace()

	local ply = hg.GetCurrentCharacter(Entity(2))
	local dist = ply:EyePos():Distance(LocalPlayer():EyePos())
	ply:SetupBones()
	scr = ply:GetBoneMatrix(ply:LookupBone("ValveBiped.Bip01_Head1")):GetTranslation():ToScreen()

	angle.pitch = math.Clamp(angle.pitch + (scr.y - (pos+ang:Forward() * dist):ToScreen().y) / 50, -89, 89)
	angle.yaw = angle.yaw - (scr.x - (pos+ang:Forward() * dist):ToScreen().x) / 50
	cmd:SetViewAngles(angle)

	return true--]]
end)