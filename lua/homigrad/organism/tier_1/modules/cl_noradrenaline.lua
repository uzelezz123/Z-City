hg.undernoradrenaline = hg.undernoradrenaline or false
hg.noradrenalineStartTime = hg.noradrenalineStartTime or 0
hg.noradrenalineStation = hg.noradrenalineStation or nil

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
hook.Add("RenderScreenspaceEffects", "noradrenalineEffect", function()
	local organism = lply:Alive() and lply.organism
	
	if !organism then
		if hg.undernoradrenaline then
			hg.DynamicMusicV2.Player.Stop()
		end

		hg.undernoradrenaline = false

		hg.noradrenalineIntensity = 0

		return
	end

	local noradrenaline = (organism.noradrenaline or 0)
	local noradrenalineClamped = math.Clamp(noradrenaline, 0, 3) * (organism.consciousness or 1)
	
	hg.noradrenalineClamped = noradrenalineClamped

	if noradrenaline > 0.0001 and !hg.undernoradrenaline then
		hg.undernoradrenaline = true
		surface.PlaySound("shitty/music/mi_deathcam.mp3")
		hg.DynamicMusicV2.Player.Start("overdose")

		hg.noradrenalineStartTime = SysTime()

		for i = 1, 90 do
			timer.Simple(i/120,function()
				ViewPunch(AngleRand(-1,1))
			end)
		end
	elseif noradrenaline < 0.0001 then
		if hg.undernoradrenaline then
			hg.DynamicMusicV2.Player.Stop()
		end

		hg.undernoradrenaline = false

		hg.noradrenalineIntensity = 0
	end
end)

local grainMat = CreateMaterial("grain2noradrenaline", "screenspace_general",{
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

hook.Add("Post Post Processing", "noradrenalineEffect", function()
	if hg.undernoradrenaline and hg.noradrenalineClamped then
		render.UpdateScreenEffectTexture()
		render.UpdateFullScreenDepthTexture()

		local start = math.Clamp((SysTime() - hg.noradrenalineStartTime) * 2, 0, 1) * lply.organism.noradrenaline

		local asad = math.sin(CurTime() * 10) / 4
		--print(asad)
		grainMat:SetFloat("$c0_x", CurTime() * start) -- time
		grainMat:SetFloat("$c0_y", asad * start) -- gate
		grainMat:SetFloat("$c0_z", 1) -- Pixelize
		grainMat:SetFloat("$c1_x", (0.2 * hg.noradrenalineClamped) * start) -- lerp
		grainMat:SetFloat("$c1_y", 0.6 * start) -- vignette intensity
		grainMat:SetFloat("$c1_z", (0.2 * asad) * start) -- BlurIntensity
		grainMat:SetFloat("$c2_x", 0) -- r
		grainMat:SetFloat("$c2_y", 2 * start) -- g
		grainMat:SetFloat("$c2_z", 6 * start) -- b
		grainMat:SetFloat("$c3_x", 0) -- ImageIntensity
	
		render.SetMaterial(grainMat)
		render.DrawScreenQuad()
	end
end)

local META = FindMetaTable("Player")
function META:IsStimulated()
	if !self:Alive() then return false end

	return hg.undernoradrenaline or false
end

local META2 = FindMetaTable("Entity")
function META2:IsStimulated()
	return false
end