local function DrawSunEffect()
	local sun = util.GetSunInfo()
	if not sun then return end
	if not sun.obstruction == 0 or sun.obstruction == 0 then return end
	local sunpos = EyePos() + sun.direction * 1024 * 4
	local scrpos = sunpos:ToScreen()
	local dot = (sun.direction:Dot(EyeVector()) - 0.8) * 5
	if dot <= 0 then return end
	DrawSunbeams(0.1, 0.15 * dot * sun.obstruction, 0.1, scrpos.x / ScrW(), scrpos.y / ScrH())
end

hg.postprocess = hg.postprocess or {}
local postprs = hg.postprocess
postprs.addtiveLayer = {
	bloom_darken = 0,
	bloom_mul = 0,
	bloom_sizex = 0,
	bloom_sizey = 0,
	bloom_passes = 0,
	bloom_colormul = 0,
	bloom_colorr = 0,
	bloom_colorg = 0,
	bloom_colorb = 0,
	blur_addalpha = 0,
	blur_drawalpha = 0,
	blur_delay = 0,
	toytown = 0,
	toytown_h = 0,
	brightness = 0,
	sharpen = 0,
	sharpen_dist = 0
}

postprs.layers = postprs.layers or {}
local layers = postprs.layers
local layers_name = {}
function postprs.LayerAdd(name, tab)
	tab.weight = 0
	layers_name[#layers_name+1] = name
	layers[name] = tab
end

function postprs.LayerWeight(name, lerp, value)
	layers[name].weight = LerpFT(lerp, layers[name].weight, value)
end

function postprs.LayerSetWeight(name, value)
	layers[name].weight = value
end

local addtiveLayer = postprs.addtiveLayer
local tab = {
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 1
}

--local potatopc = GetConVar("hg_potatopc") or CreateClientConVar("hg_potatopc", "0", true, false, "enable this if you are noob", 0, 1)
local hook_Run = hook.Run
hook.Add("RenderScreenspaceEffects", "homigrad", function()
	//if potatopc:GetInt() >= 1 then return end
	hook_Run("Post Processing")
	//DrawSunEffect()
	for _, layer in ipairs(layers_name) do
		layer = layers[layer]
		local weight = layer.weight
		--for k, v in pairs(layer) do
			--if k == "weight" then continue end
		addtiveLayer["brightness"] = Lerp(weight, 0, layer["brightness"] or 0)
		--end
	end

	//DrawBloom(addtiveLayer.bloom_darken, addtiveLayer.bloom_mul, addtiveLayer.bloom_sizex, addtiveLayer.bloom_sizey, addtiveLayer.bloom_passes, addtiveLayer.bloom_colormul, addtiveLayer.bloom_colorr, addtiveLayer.bloom_colorg, addtiveLayer.bloom_colorb)
	//DrawSharpen(addtiveLayer.sharpen, addtiveLayer.sharpen_dist)
	//if not brain_motionblur then DrawMotionBlur(addtiveLayer.blur_addalpha, addtiveLayer.blur_drawalpha, addtiveLayer.blur_delay) end
	//DrawToyTown(addtiveLayer.toytown, addtiveLayer.toytown_h * ScrH())
	tab["$pp_colour_brightness"] = addtiveLayer.brightness
	DrawColorModify(tab)

	hook_Run("Post Pre Post Processing")

	hook_Run("Post Post Processing")
end)

local postprs = hg.postprocess
postprs.LayerAdd("main", {
	bloom_darken = 0.64,
	bloom_mul = 0.5,
	bloom_sizex = 4,
	bloom_sizey = 4,
	bloom_passes = 2,
	bloom_colormul = 1,
	bloom_colorr = 1,
	bloom_colorg = 1,
	bloom_colorb = 1
})

postprs.LayerAdd("water", {
	bloom_darken = 0.15,
	bloom_mul = 1,
	bloom_sizex = 30,
	bloom_sizey = 30,
	bloom_passes = 2,
	bloom_colormul = 1,
	bloom_colorr = 0.05,
	bloom_colorg = 0.5,
	bloom_colorb = 1,
	blur_addalpha = 0.1,
	blur_drawalpha = 0.5,
	blur_delay = 0.01
})

postprs.LayerAdd("water2", {
	toytown = 6,
	toytown_h = 4
})

postprs.LayerAdd("water3", {
	brightness = -0.5
})

local oldWaterLevel, lastWater = 0, 0
local LayerWeight = postprs.LayerWeight
local LayerSetWeight = postprs.LayerSetWeight
local CurTime = CurTime
local timecheck = CurTime()
hook.Add("Post Processing", "Main", function()
	//if potatopc:GetInt() >= 1 then return end
	//if !lply:Alive() then return end
	local ply = lply:Alive() and lply or lply:GetNWEntity("spect")
	if !IsValid(ply) then return end
	local waterLevel = oldWaterLevel
	if timecheck < CurTime() then
		local pos = hg.eye(lply)
		
		if !pos then return end

		waterLevel = (ply:WaterLevel() == 3) or ((ply:WaterLevel() > 1) and bit.band(util.PointContents(pos), CONTENTS_WATER) == CONTENTS_WATER)//lply:WaterLevel()

		timecheck = CurTime() + 0.1
	end

	local time = CurTime()

	if oldWaterLevel ~= waterLevel and waterLevel then
		lastWater = time + 2
	end

	local animpos = lastWater - time
	if animpos > 0 then
		LayerSetWeight("water3", animpos)
	else
		LayerSetWeight("water3", 0)
	end

	if waterLevel then
		LayerWeight("main", 0.1, 0)
		LayerWeight("water", 0.1, 1)
		LayerWeight("water2", 0.1, 1)
	else
		LayerWeight("main", 0.5, 1)
		LayerWeight("water", 0.5, 0)
		LayerWeight("water2", 0.01, 0)
	end

	oldWaterLevel = waterLevel

	DrawSunEffect()
end)

local color_red = Color( 56, 43, 0, 255)
local haloents = {
	["attachment_base"] = true,
	["ammo_base"] = true,
	["armor_base"] = true,
	["hg_flashlight"] = true,
	["homigrad_base"] = true,
	["weapon_melee"] = true,
	["weapon_bandage_sh"] = true,
	["hg_sling"] = true,
	["hg_brassknuckles"] = true,
	["weapon_m4super"] = true,
	["weapon_revolver2"] = true,
	["weapon_hg_f1_tpik"] = true
}

--[[hook.Add( "PreDrawHalos", "AddPropHalos", function() -- вариант с подсветкой всего в радиусе
	local pickuphalo = {}
	 
	local lpos = lply:GetPos()
	for _, ent in ipairs(ents.FindInSphere(lpos, 256)) do
		if IsValid(ent) and (haloents[ent.Base] or haloents[ent:GetClass()]) and not IsValid(ent:GetOwner()) then
		table.insert(pickuphalo, ent)
		local dist = lpos:Distance(ent:GetPos()) * 0.02
		--print(dist)
		color_red.r = Lerp(FrameTime()*5,color_red.r,56 / dist)
		color_red.g = Lerp(FrameTime()*5,color_red.g,43 / dist)
		end
	end
	halo.Add( pickuphalo, color_red, 1, 1, 1 )
end )]]

--[[hook.Add( "PreDrawHalos", "AddPropHalos", function() -- вариант с подсвечиванием только когда смотришь
	local pickuphalo = {}
	 
	local tr = hg.eyeTrace(lply,72)
	if IsValid(tr.Entity) and haloents[tr.Entity.Base] then
		table.insert(pickuphalo, tr.Entity)
		local dist = lply:GetPos():Distance(tr.Entity:GetPos()) * 0.03
		--print(dist)
		color_red.r = Lerp(FrameTime()*2,color_red.r,56 / dist)
		color_red.g = Lerp(FrameTime()*2,color_red.g,43 / dist)
	else
		color_red.r = Lerp(FrameTime()*2,color_red.r,0)
		color_red.g = Lerp(FrameTime()*2,color_red.g,0)
	end
	halo.Add( pickuphalo, color_red, 1, 1, 1 )
end )]]

-- funny :)

--that one furry game


local painMat = Material("effects/shaders/zb_grain")
local noiseMat = Material("effects/shaders/zb_grainwhite")
local vignetteMat = Material("effects/shaders/zb_vignette")
local assimilationMat = Material("effects/shaders/zb_assimilation")
local coldMat = Material("effects/shaders/zb_colda")
local grainMat = Material("effects/shaders/zb_grain2")
local heatMat = Material("effects/shaders/zb_heat")
local zombMat = grainMat -- Material("effects/shaders/zb_zomb")

local PainLerp = 0
local O2Lerp = 0
local assimilatedLerp = 0
local tempLerp = 36.6

local show_image_time = 0
local show_some_images_time = 0
local lobotomy_mats = {
	[1] = Material("overlays/photopsiaoverlay1.png"),
	[2] = Material("overlays/photopsiaoverlay2.png"),
	[3] = Material("overlays/photopsiaoverlay3.png"),
	[4] = Material("overlays/photopsiaoverlay4.png"),
	[5] = Material("overlays/peripheralorboverlay.png"),
	[6] = Material("overlays/tallflash1.png"),
	[7] = Material("overlays/tallflash2.png"),
	[8] = Material("overlays/tallflash3.png")
}

local function stopthings()
	PainLerp = 0
	O2Lerp = 0
	shockLerp = 0
	assimilatedLerp = 0
	tempLerp = 36.6
	consciousnessLerp = 1

	lply.tinnitus = 0
	
	--[[if IsValid(PainStation) then
		PainStation:Stop()
		PainStation = nil
	end--]]

	if IsValid(NoiseStation) then
		NoiseStation:Stop()
		NoiseStation = nil
	end

	if IsValid(NoiseStation2) then
		NoiseStation2:Stop()
		NoiseStation2 = nil
	end

	if IsValid(BrainTraumaStation) then
		BrainTraumaStation:Stop()
		BrainTraumaStation = nil
	end

	if IsValid(BrainTraumaStation2) then
		BrainTraumaStation2:Stop()
		BrainTraumaStation2 = nil
	end

	if IsValid(BrainTraumaStation3) then
		BrainTraumaStation3:Stop()
		BrainTraumaStation3 = nil
	end

	if IsValid(BrainTraumaStation4) then
		BrainTraumaStation4:Stop()
		BrainTraumaStation4 = nil
	end

	if IsValid(BrainTraumaStation5) then
		BrainTraumaStation5:Stop()
		BrainTraumaStation5 = nil
	end

	if IsValid(Tinnitus) then
		Tinnitus:Stop()
		Tinnitus = nil
	end

	if IsValid(AssimilationStation) then
		AssimilationStation:Stop()
		AssimilationStation = nil
	end
end

local stations = {
	0.06,
	0.1,
	0.15,
	0.22,
	0.27,
}

local choosera = 1
local tempolerp = 0
hook.Add("Post Post Processing", "ItHurts", function()
	local spect = IsValid(lply:GetNWEntity("spect")) and lply:GetNWEntity("spect")
	
	if IsValid(PainStation) then
		PainStation:SetVolume(0)
	end
	
	if !lply:Alive() and !IsValid(spect) then stopthings() return end
	if !lply:Alive() and viewmode != 1 then stopthings() return end
	local organism = lply:Alive() and lply.organism or (IsValid(spect) and spect.organism)
	if not organism then stopthings() return end
	if not organism.brain then stopthings() return end
	local org = organism
	
	if !IsValid(PainStation) or PainStation:GetState() != GMOD_CHANNEL_PLAYING then
		sound.PlayFile("sound/zbattle/pain_beat.ogg", "noblock noplay", function(station)
			if IsValid(station) then
				station:SetVolume(0)
				station:Play()
				station:SetTime(math.min(math.Rand(0, station:GetLength()), 139))
				PainStation = station
				station:EnableLooping(true)
			end
		end)
	end

	local LerpFT = LerpFT or Lerp

	if !org or !org.o2 or !isnumber(org.o2[1]) or !org.analgesia then stopthings() return end

	local o2 = org.o2[1] or 0
	o2 = o2 + (org.CO or 0)
	local brain = org.brain or 0
	O2Lerp = LerpFT(0.01, O2Lerp, (30 - o2) * (org.otrub and 2 or 10) + (brain * 100) * (org.otrub and 1 or 5))

	tempLerp = LerpFT(0.01, tempLerp, org.temperature)

	if lply.PlayerClassName == "headcrabzombie" then
		render.UpdateScreenEffectTexture()

		heatMat:SetFloat("$c0_x", -CurTime() * 0.1) //time
		heatMat:SetFloat("$c0_y", 0.1) //intensity (strict)
		heatMat:SetFloat("$c2_x", 2)

		render.SetMaterial(heatMat)
		render.DrawScreenQuad()

		render.UpdateScreenEffectTexture()
		render.UpdateFullScreenDepthTexture()
		
		zombMat:SetFloat("$c0_x", CurTime()) -- time
		zombMat:SetFloat("$c0_y", -1) -- gate
		zombMat:SetFloat("$c0_z", 1) -- Pixelize
		zombMat:SetFloat("$c1_x", 12) -- lerp
		zombMat:SetFloat("$c1_y", 0.2) -- vignette intensity
		zombMat:SetFloat("$c1_z", 0.3) -- BlurIntensity
		zombMat:SetFloat("$c2_x", 0.3) -- r
		zombMat:SetFloat("$c2_y", 0.05) -- g
		zombMat:SetFloat("$c2_z", 0) -- b
		zombMat:SetFloat("$c3_x", 0) -- ImageIntensity
	
		render.SetMaterial(zombMat)
		render.DrawScreenQuad()
	end

	if tempLerp > 38 then
		local heat = tempLerp - 38

		render.UpdateScreenEffectTexture()

		heatMat:SetFloat("$c0_x", -CurTime() * 0.25)//math.sin(CurTime() * 0.1) * CurTime() * 0.01) //time
		heatMat:SetFloat("$c0_y", 0.06 * heat)//(math.sin(CurTime()) + 1) * 2) //intensity (strict)
		heatMat:SetFloat("$c2_x", (math.sin(CurTime()) - 2) * heat)

		render.SetMaterial(heatMat)
		render.DrawScreenQuad()
	end

	local pain = org.pain or 0
	pain = math.max(pain - 15, 0)
	local shock = (org.shock or 0) * 1 + (1 - org.consciousness) * 40
	shockLerp = LerpFT(0.01, shockLerp or 0, shock)
	consciousnessLerp = LerpFT(org.consciousness < (consciousnessLerp or 1) and 1 or 0.01, consciousnessLerp or 1, org.consciousness)
	-- local immobilization = org.immobilization
	PainLerp = LerpFT(0.05, PainLerp, math.max(pain * (org.otrub and 0.2 or 1), 0))
	assimilatedLerp = LerpFT(0.01, assimilatedLerp, (org.assimilated or 0))

	if assimilatedLerp > 0.001 then
		render.UpdateScreenEffectTexture()

		assimilationMat:SetFloat("$c0_x", -CurTime())//math.sin(CurTime() * 0.1) * CurTime() * 0.01) //time
		assimilationMat:SetFloat("$c0_y", assimilatedLerp * 3)//(math.sin(CurTime()) + 1) * 2) //intensity (strict)
		local ctime = CurTime() * 2
		local val = math.Clamp(3 - 1 / 3 * (math.sin(ctime * 2.8862) + math.cos(ctime * 1.115) - math.sin(ctime * 0.6215) + 3), 0, 5)
		local val2 = math.Clamp(1 - 1 / 6 * (math.sin(ctime * 1.1862) + math.cos(ctime * 2.315) - math.sin(ctime * 0.9215) + 3), 0, 1)
		assimilationMat:SetFloat("$c1_y", val)
		assimilationMat:SetFloat("$c1_x", val2 - 0.5)

		if !IsValid(AssimilationStation) or AssimilationStation:GetState() != GMOD_CHANNEL_PLAYING then
			sound.PlayFile("sound/zbattle/furry/conversion/assimilation_noise3.ogg", "noblock noplay", function(station, err)
				if IsValid(station) then
					station:SetVolume(0)
					station:Play()
					AssimilationStation = station
					station:EnableLooping(true)
				end
			end)
		else
			AssimilationStation:SetVolume(assimilatedLerp * 2)
			//AssimilationStation:SetPlaybackRate(assimilatedLerp * 1)
		end

		render.SetMaterial(assimilationMat)
		render.DrawScreenQuad()
	else
		if IsValid(AssimilationStation) then
			AssimilationStation:Stop()
			AssimilationStation = nil
		end
	end

	if (org.consciousness or 0) < 1 then
		local consciousness = 1 - consciousnessLerp
		render.UpdateScreenEffectTexture()
		render.UpdateFullScreenDepthTexture()
		
		grainMat:SetFloat("$c0_x", CurTime()) -- time
		grainMat:SetFloat("$c0_y", 0.5) -- gate
		grainMat:SetFloat("$c0_z", consciousness * 3) -- Pixelize
		grainMat:SetFloat("$c1_x", consciousness) -- lerp
		grainMat:SetFloat("$c1_y", 10) -- vignette intensity
		grainMat:SetFloat("$c1_z", consciousness) -- BlurIntensity
		grainMat:SetFloat("$c2_x", 0) -- r
		grainMat:SetFloat("$c2_y", 0) -- g
		grainMat:SetFloat("$c2_z", 0) -- b
		grainMat:SetFloat("$c3_x", 0) -- ImageIntensity
	
		render.SetMaterial(grainMat)
		render.DrawScreenQuad()
	end

	local tempo = math.Clamp((5 - (tempLerp - 29)) * 0.5 - 5 * (org.heartbeat < 1 and 1 or 0), 0, 5)
	tempolerp = LerpFT(0.01, tempolerp, tempo)
	
	if (tempolerp > 0) then
		render.UpdateScreenEffectTexture()

		coldMat:SetFloat("$c0_y", tempolerp)
		
		render.SetMaterial(coldMat)
		render.DrawScreenQuad()
	end

	if (PainLerp > 0.001 or shockLerp > 5) or org.otrub then
		local strobe = math.ease.InOutSine(math.abs(math.cos(CurTime() * 2))) * PainLerp / 2
		pain = PainLerp + strobe
		shock = shockLerp
		render.UpdateScreenEffectTexture()

		vignetteMat:SetFloat("$c2_x", CurTime() + 10000) //Time
		vignetteMat:SetFloat("$c0_z", org.otrub and 5 or (pain / 40 + math.max(shock - 5, 0) / 3)) //ColorIntensity
		vignetteMat:SetFloat("$c1_y", org.otrub and 10 or (pain / 40 + math.max(shock - 5, 0) / 3)) //Vignette

		render.SetMaterial(vignetteMat)
		render.DrawScreenQuad()

		render.UpdateScreenEffectTexture()

		painMat:SetFloat("$c2_x", CurTime() + 10000) //Time
		painMat:SetFloat("$c0_y", 0.8) //Gate
		painMat:SetFloat("$c0_z", 1) //ColorIntensity
		painMat:SetFloat("$c1_x", math.Clamp(pain / 90, 0, 0.75)) //Lerp
		painMat:SetFloat("$c1_y", math.Clamp(pain / 90, 0, 0.75)) //Vignette

		render.SetMaterial(painMat)
		render.DrawScreenQuad()

		if org.otrub then
			DrawMotionBlur(0.1, 1., 0.01)
			lply:ScreenFade( SCREENFADE.IN, Color(0,0,0), 2, 0.5 )
		end
		
		//if pain > 10 then
			if IsValid(PainStation) then
				PainStation:SetVolume(math.Clamp(math.Remap(pain, 0, 120, 0, 2), 0, 2))
			end
		//else
		//	if IsValid(PainStation) then
		//		PainStation:Stop()
		//		PainStation = nil
		//	end
		//end
	else
		//if IsValid(PainStation) then
		//	PainStation:Stop()
		//	PainStation = nil
		//end
	end

	if brain > 0.01 then
		local chooser = 1
		for i, choose in ipairs(stations) do
			if choose < brain then
				chooser = i
			end
		end
	
		if !IsValid(BrainTraumaStation) or choosera != chooser or BrainTraumaStation:GetState() != GMOD_CHANNEL_PLAYING then
			if IsValid(BrainTraumaStation) then
				BrainTraumaStation:Stop()
				BrainTraumaStation = nil
			end

			sound.PlayFile("sound/zcitysnd/real_sonar/brainhemorrhagestage"..chooser..".mp3", "noblock noplay", function(station, err)
				if IsValid(station) then
					station:SetVolume(0)
					station:Play()
					BrainTraumaStation = station
					station:EnableLooping(true)
				end
			end)
			choosera = chooser
		end

		if IsValid(BrainTraumaStation) then
			BrainTraumaStation:SetVolume(math.Clamp(!org.otrub and brain * 2 or 0, 0, 1))
		end
	else
		if IsValid(BrainTraumaStation) then
			BrainTraumaStation:Stop()
			BrainTraumaStation = nil
		end
	end

	//if brain > 0.1 and not org.otrub and show_some_images_time > 0 and false then
	if lply.tinnitus and lply.tinnitus > CurTime() and lply:Alive() then
		if !IsValid(Tinnitus) or Tinnitus:GetState() != GMOD_CHANNEL_PLAYING  then
			sound.PlayFile("sound/zcitysnd/real_sonar/tinnitus"..math.random(3)..".mp3", "noblock noplay", function(station, err)
				if IsValid(station) then
					station:SetVolume(0)
					station:Play()
					Tinnitus = station
					station:EnableLooping(true)
				end
			end)
		end

		if IsValid(Tinnitus) then
			Tinnitus:SetVolume(math.min(math.max(lply.tinnitus - CurTime(), 0) / 10, 1))
		end
	else
		if IsValid(Tinnitus) then
			Tinnitus:Stop()
			Tinnitus = nil
		end
	end
	
	if brain > 0.1 and not org.otrub then
		if show_some_images_time > 0 then
			brain_motionblur = true
			DrawMotionBlur(0.1, 1., 0.1)
			show_some_images_time = show_some_images_time - 1
			if show_image_time <= 0 and math.random(10 * (1 - brain)) < 2 then
				show_image_time = 250 * (0.1 * 3) * math.Rand(0.1, 1) * (math.random(2) == 1 and 0.1 or 1)
				lobotomy_index = math.random(#lobotomy_mats)
			end

			if show_image_time > 0 then
				show_image_time = show_image_time - 1

				if lobotomy_index then
					surface.SetDrawColor(255,255,255,255)
					surface.SetMaterial(lobotomy_mats[lobotomy_index])
					local rand = 5
					surface.DrawTexturedRect(-math.random(rand), -math.random(rand), ScrW() + math.random(rand), ScrH() + math.random(rand))
				end
			end
		else
			brain_motionblur = false
			show_some_images_time = math.random(1200) < (brain * 15) and 250 or 0
		end
	else
		brain_motionblur = false
		show_image_time = 0
		lobotomy_index = 0
	end
	
	if O2Lerp > 1 then
		render.UpdateScreenEffectTexture()
		
		o2 = O2Lerp
		
		noiseMat:SetFloat("$c0_y", 1 - o2 / 200) //Gate
		noiseMat:SetFloat("$c0_z", 1) //ColorIntensity
		noiseMat:SetFloat("$c1_x", math.Clamp(o2 / 200, 0, 2)) //Lerp
		noiseMat:SetFloat("$c1_y", o2 * (!org.otrub and 0.05 or 1)) //Vignette
		noiseMat:SetFloat("$c2_x", CurTime() + 10000) //Time

		render.SetMaterial(noiseMat)
		render.DrawScreenQuad()
		
		if o2 > 50 and !org.otrub then
			if !IsValid(NoiseStation2) or NoiseStation2:GetState() != GMOD_CHANNEL_PLAYING then
				sound.PlayFile("sound/zbattle/conscioustypebeat.ogg", "noblock noplay", function(station)
					if IsValid(station) then
						station:SetVolume(0)
						station:Play()
						station:SetTime(math.min(brain / 0.5 * station:GetLength()), 87)
						NoiseStation2 = station
						station:EnableLooping(true)
					end
				end)
			end
			
			if IsValid(NoiseStation2) then
				NoiseStation2:SetVolume(math.Clamp((o2 - 50) / 100 + (brain > 0.3 and (brain - 0.3) * 5 or 0), 0, 0.25))
			end
		else
			if IsValid(NoiseStation2) then
				NoiseStation2:SetVolume(0)
			end
		end
		
		if o2 > 20 and org.otrub then
			if !IsValid(NoiseStation) or NoiseStation:GetState() != GMOD_CHANNEL_PLAYING then
				sound.PlayFile("sound/zbattle/unconscious_type_beat.ogg", "noblock noplay", function(station)
					if IsValid(station) then
						station:SetVolume(0)
						station:Play()
						station:SetTime(math.min(brain / 0.5 * station:GetLength(), 200))
						NoiseStation = station
						station:EnableLooping(true)
					end
				end)
			end

			if IsValid(NoiseStation) then
				NoiseStation:SetVolume(math.Clamp((o2 - 30) / 100 + (brain > 0.3 and (brain - 0.3) * 5 or 0), 0, 1))
			end
		else
			if IsValid(NoiseStation) then
				NoiseStation:SetVolume(0)
			end
		end
	else
		if IsValid(NoiseStation) then
			NoiseStation:Stop()
			NoiseStation = nil
		end
	end
end)

hook.Add("Player_Death", "ItDoesntNow", function(ply)
	if !((ply == lply) or (ply == lply:GetNWEntity("spect"))) then return end

	stopthings()
end)

hook.Add("Player Spawn", "ItDoesntNow", function(ply)
	if ply != lply then return end

	stopthings()
end)