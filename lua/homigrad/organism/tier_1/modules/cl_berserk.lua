hg.underberserk = hg.underberserk or false
hg.underberserk2 = hg.underberserk2 or false
hg.berserkStartTime = hg.berserkStartTime or 0
hg.berserkStartTime2 = hg.berserkStartTime2 or 0
hg.berserkStation = hg.berserkStation or nil

local tab = {
	[ "$pp_colour_addr" ] = 0,
	[ "$pp_colour_addg" ] = 0,
	[ "$pp_colour_addb" ] = 0,
	[ "$pp_colour_brightness" ] = 0,
	[ "$pp_colour_contrast" ] = 1,
	[ "$pp_colour_colour" ] = 1,
	[ "$pp_colour_mulr" ] = 0,
	[ "$pp_colour_mulg" ] = 0,
	[ "$pp_colour_mulb" ] = 0
}

local tab2 = {
	[ "$pp_colour_addr" ] = 0,
	[ "$pp_colour_addg" ] = 0,
	[ "$pp_colour_addb" ] = 0,
	[ "$pp_colour_brightness" ] = 0,
	[ "$pp_colour_contrast" ] = 1,
	[ "$pp_colour_colour" ] = 1,
	[ "$pp_colour_mulr" ] = 0,
	[ "$pp_colour_mulg" ] = 0,
	[ "$pp_colour_mulb" ] = 0
}

local cc = Material( "effects/shaders/merc_chromaticaberration" )

local offset = CreateClientConVar("berserk_offset", "0.85", true, false, "Set berserk music offset from start", 0, 5)
local bpm = CreateClientConVar("berserk_bpm", "70", true, false, "Set berserk effect bpm", 1, 280)
local path = CreateClientConVar("berserk_path", "sound/zbattle/pharmacia.mp3", true, false, "Set berserk effect music path")

hook.Add("RenderScreenspaceEffects", "berserkEffect", function()
	local organism = lply:Alive() and lply.organism
	
	if !organism then
		hg.underberserk = false
		hg.underberserk2 = false

		if IsValid(hg.berserkStation) then
			hg.berserkStation:Stop()
			hg.berserkStation = nil
			-- atlaschat.font:SetString("atlaschat.theme.text")
		end

		hg.notificationFont = "HuyFont"
		hg.berserkIntensity = 0

		return
	end

	local berserk = (organism.berserk or 0)
	local berserkClamped = math.Clamp(berserk, 0, 3) * (organism.consciousness or 1)

	if berserk > 0.0001 and (!hg.underberserk and !hg.underberserk2) then
		hg.underberserk = true
		surface.PlaySound("zbattle/deathsample.ogg")

		hg.berserkStartTime = SysTime()

		local part = CreateParticleSystem( LocalPlayer(), "[2]sparkle1", PATTACH_POINT_FOLLOW, 1)

		hg.currentNotification = nil
		hg.notifications = {}
		hg.CreateNotificationBerserk("I feel...")

		timer.Simple(3.95, function()
			if IsValid(part) then
				part:StopEmission( false, true, false )
			end

			for i = 1, 30 do
				timer.Simple(i/120,function()
					ViewPunch(AngleRand(-1,1))
				end)
			end

			hg.underberserk = false
			hg.underberserk2 = true
			sound.PlayFile(path:GetString(), "noblock", function(channel)
				hg.berserkStation = channel
				channel:EnableLooping(true)
				-- atlaschat.font:SetString("BerserkChatFont")
			end)

			hg.currentNotification = nil
			hg.notifications = {}
			hg.CreateNotificationBerserk("GREAT.")

			hg.berserkStartTime2 = SysTime()
		end)
	elseif berserk < 0.0001 then
		hg.underberserk = false
		hg.underberserk2 = false
		if IsValid(hg.berserkStation) then
			hg.berserkStation:Stop()
			hg.berserkStation = nil
			-- atlaschat.font:SetString("atlaschat.theme.text")
		end

		hg.notificationFont = "HuyFont"
		hg.berserkIntensity = 0
	end

	if hg.underberserk then
		local intensity = (SysTime() - hg.berserkStartTime)
		tab[ "$pp_colour_contrast" ] = intensity / 2
		tab[ "$pp_colour_addr" ] = intensity / 10
		tab[ "$pp_colour_brightness" ] = intensity / 10
		DrawColorModify(tab)
		DrawBloom( 0.65, intensity * 4, 9, 9, 1, 1, intensity / 16, 0.2, 0.2 )

		render.UpdateScreenEffectTexture()
			cc:SetFloat("$c0_x", 3.5 - intensity)
			cc:SetInt("$c0_y", 1)
			render.SetMaterial(cc)
		render.DrawScreenQuad()
	end

	if hg.underberserk2 and IsValid(hg.berserkStation) then
		--local intensity = ((hg.berserkStartTime2 + SysTime()) / 60) * 70 % 1
		--intensity = math.abs(math.cos(1 - (intensity * 2))) * berserkClamped
		local intensity = 1 - ((hg.berserkStation:GetTime() - offset:GetFloat()) / 60 * bpm:GetInt())
		intensity = (intensity - math.Round(intensity)) % 1
		--intensity = math.sqrt(math.sqrt(intensity))
		intensity = math.Clamp((intensity * 0.25 + 0.75), 0, 1)
		intensity = math.ease.InExpo(intensity) * berserkClamped * 2--math.abs(math.cos(1 - (intensity * 2))) * berserkClamped

		tab2[ "$pp_colour_mulr" ] = (1.5 * math.min(1, berserk * 4)) + (intensity / 5)
		tab2[ "$pp_colour_addr" ] = (0.1 * math.min(1, berserk * 4)) + intensity / 64
		-- tab[ "$pp_colour_contrast" ] = 1 + intensity / 8

		tab2[ "$pp_colour_colour" ] = 1 - math.Clamp(intensity, 0, 0.9)
		tab2[ "$pp_colour_mulg" ] = 0
		tab2[ "$pp_colour_mulb" ] = 0

		DrawColorModify(tab2)
		DrawBloom( 0.65, intensity, 9, 9, 1, 1, intensity / 16, 0.2, 0.2 )

		hg.notificationFont = "BerserkFont"

		hg.berserkIntensity = intensity
		hg.berserkClamped = berserkClamped
	end

	if IsValid(hg.berserkStation) then
		hg.berserkStation:SetVolume(math.min(1, (organism.otrub and 0) or berserkClamped))
	end
end)

local grainMat = CreateMaterial("grain2berserk","screenspace_general",{
	["$pixshader"] = "zb_grain2_ps20b",
	["$basetexture"] = "_rt_FullFrameFB",
	["$texture1"] = "stickers/steamhappy",
	["$texture2"] = "",
	["$texture3"] = "",
	["$ignorez"] = 1,
	["$vertexcolor"] = 1,
	["$vertextransform"] = 1,
	["$copyalpha"] = 1,
	["$alpha_blend_color_overlay"] = 0,
	["$alpha_blend"] = 1,
	["$linearwrite"] = 1,
	["$linearread_basetexture"] = 1,
	["$linearread_texture1"] = 1,
	["$linearread_texture2"] = 1,
	["$linearread_texture3"] = 1,
})

hook.Add("Post Post Processing", "berserkEffect", function()
	if hg.underberserk2 and hg.berserkClamped then
		render.UpdateScreenEffectTexture()
		render.UpdateFullScreenDepthTexture()
		
		grainMat:SetFloat("$c0_x", CurTime()) -- time
		grainMat:SetFloat("$c0_y", 0.5) -- gate
		grainMat:SetFloat("$c0_z", 2) -- Pixelize
		grainMat:SetFloat("$c1_x", 0.2 * hg.berserkClamped) -- lerp
		grainMat:SetFloat("$c1_y", 1.5) -- vignette intensity
		grainMat:SetFloat("$c1_z", 0.2) -- BlurIntensity
		grainMat:SetFloat("$c2_x", 6) -- r
		grainMat:SetFloat("$c2_y", 0) -- g
		grainMat:SetFloat("$c2_z", 0) -- b
		grainMat:SetFloat("$c3_x", 0) -- ImageIntensity
	
		render.SetMaterial(grainMat)
		render.DrawScreenQuad()
	end
end)

hook.Add("HG_CalcView","InsaneRollCam",function(ply, origin, angles, fova)
	if ply:Alive() and hg.underberserk2 and IsValid(hg.berserkStation) and hg.berserkClamped then
		local intensity = 1 - ((hg.berserkStation:GetTime() - offset:GetFloat()) / 60 * bpm:GetInt())
		angles[1] = angles[1] - hg.berserkIntensity * 0.2
		angles[3] = math.cos(CurTime() * 0.3) * hg.berserkClamped + hg.berserkIntensity * 2 * (intensity % 2 > 1 and 1 or -1)
		--print(fova)
		fova[1] = fova[1] + hg.berserkIntensity * -2
	end
end)

local META = FindMetaTable("Player")
function META:IsBerserk()
	if !self:Alive() then return false end

	return hg.underberserk2 or false
end

local META2 = FindMetaTable("Entity")
function META2:IsBerserk()
	return false
end

local HM_sky_material = CreateMaterial("g_sky_HMFrf", "g_Sky", {
	["$topcolor"]      = "[1 0 0.5]",
	["$bottomcolor"]   = "[0 0 1]",
	["$fadebias"]      = "1.0",
	["$hdrscale"]      = "0.25",
	
	["$duskcolor"]     = "[1 0.3 0.25]",
	["$duskscale"]     = "0.5",
	["$duskintensity"] = "5.0",
	
	["$sunnormal"]     = "[0 1 1]",
	["$suncolor"]      = "[0 1 1]",
	["$sunsize"]       = "5",
	
	["$startexture"]   = "skybox/starfield",
	["$starfade"]      = "0",
	["$starscale"]     = "1",
	["$starpos"]       = "1",
	["$starlayers"]    = "4",
})

local maxs = Vector(64, 64, 64)
local mins = -maxs
--local alphacolor = Color(255,255,255,255)

local matGlow = Material("Sprites/light_glow02_add_noz")
local red = Color(255, 58, 84)
local blue = Color(47, 0, 255)

hook.Add("PostDrawTranslucentRenderables", "berserkSky", function(depth, drawsky, sky3d)
	if !hg.underberserk2 then return end

	if !drawsky then
		cam.Start3D()
			for _, ply in player.Iterator() do
				if ply == LocalPlayer() then continue end
				local distance = ply:GetPos():DistToSqr(EyePos())

				local pos = (IsValid(ply.FakeRagdoll) and ply.FakeRagdoll:WorldSpaceCenter()) or ply:WorldSpaceCenter()
				render.SetMaterial(matGlow)
				local size = 20 * hg.berserkIntensity * (distance / 3000000)
				if size > 1 then
					render.DrawSprite(pos, size * 3, size, red)
					render.DrawSprite(pos, size, size * 3, red)
				end
			end
		cam.End3D()
	end

	if (drawsky or sky3d) then
		local sun_info = util.GetSunInfo()
		if sun_info != nil then HM_sky_material:SetVector("$sunnormal", sun_info.direction) end
		--alphacolor.a = hg.berserkIntensity
		HM_sky_material:SetFloat("$duskscale",math.abs(math.sin(CurTime()*1.5))*1)
		HM_sky_material:SetFloat("$duskintensity",0.2*hg.berserkIntensity/(hg.berserkIntensity/3))

		--print(hg.berserkIntensity)
		cam.Start3D(vector_origin, EyeAngles())
			render.SetMaterial(HM_sky_material)
			cam.IgnoreZ(true)
				--render.DrawBox(vector_origin, angle_zero, maxs, mins, color_white)
			cam.IgnoreZ(false)
		cam.End3D()
	end
end)

