local MODE = MODE

local function ShowShadows(ent, ply, bool)
	ply:DrawShadow(bool)
	ent:DrawShadow(bool)
end

function MODE:PreDrawPlayer2(ent, ply)
	local lply = LocalPlayer()

	if !IsValid(ent) or !IsValid(ply) then return end
	if lply == ply then return end

	if !lply:Alive() then
		ShowShadows(ent, ply, true)
		local wpn = ply.GetActiveWeapon and ply:GetActiveWeapon()
		if IsValid(wpn) then
			wpn:DrawShadow(true)
		end
		return
	end

	local bool = lply:GetNetVar("disappearance", nil) // it's not actually bool but float. works either way :3. update: it's a bool now >w<
	if bool then
		ShowShadows(ent, ply, false)
		local wpn = ply.GetActiveWeapon and ply:GetActiveWeapon()
		if IsValid(wpn) then
			wpn:DrawShadow(false)
		end
		return bool
	end

	local bool2 = ply:GetNetVar("disappearance", nil)
	if bool2 then
		ShowShadows(ent, ply, false)
		local wpn = ply.GetActiveWeapon and ply:GetActiveWeapon()
		if IsValid(wpn) then
			wpn:DrawShadow(false)
		end
		return bool2
	end
end

hg.ghostStation = hg.ghostStation or nil
local cc = Material( "effects/shaders/merc_chromaticaberration" )

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

local alone = {
	"Where is everyone?",
	"Anyone here?",
	"Where did everyone go?",
	"Did i miss something?",
	"It's oddly quiet."
}

function MODE:CheckInDarkness(ply)
	return render.GetLightColor(ply:EyePos())
end

net.Receive("check_lightness", function(len)
	local ply = net.ReadEntity()
	
	if IsValid(ply) then
		net.Start("check_lightness")
		net.WriteVector(MODE:CheckInDarkness(ply))
		net.SendToServer()
	end
end)

local atpeace = {
	"I feel... At peace.",
	"Is this the end?",
	"What is happening?",
	"I think i've lived long enough.",
	"Finally, light at the end of a tunnel...",
	"I think that's it.",
	"Is this really how it ends?"
}

hg.fearphrase1 = hg.fearphrase1 or nil
hg.fearphrase2 = hg.fearphrase2 or nil

function MODE:RenderScreenspaceEffects()
	local lply = LocalPlayer()

	self.BaseClass.RenderScreenspaceEffects(self)

	local disappearance = lply:GetNetVar("disappearance", nil)

	if disappearance and !hg.fearphrase1 then
		timer.Simple(math.Rand(20, 40), function()
			hg.CreateNotification(table.Random(alone))
		end)
		hg.fearphrase1 = true
	end

	if !disappearance then
		hg.fearphrase1 = nil
	end

	local ghost = lply:GetNetVar("afterlife") // curtime start here
	if !ghost then
		if IsValid(hg.ghostStation) then
			hg.ghostStation:Stop()
			hg.ghostStation = nil
		end

		hg.fearphrase2 = nil
		return
	end
	
	local intensity = CurTime() - ghost

	local time = 60

	if intensity > time and !IsValid(hg.ghostStation) then
		sound.PlayFile("sound/zbattle/dragonfly_wings.ogg", "noplay", function(channel) //the track is 59 seconds btw
			channel:SetVolume(0)
			channel:Play()
			hg.ghostStation = channel
		end)
	end

	if intensity > time then
		local intensity2 = (intensity - time) / 100
		tab[ "$pp_colour_contrast" ] = 1 + intensity2
		tab[ "$pp_colour_addr" ] = intensity2 / 10
		tab[ "$pp_colour_brightness" ] = intensity2
		DrawColorModify(tab)
		DrawBloom( 0.65, intensity2 * 4, 9, 9, 1, 1, intensity2 / 16, 0.2, 0.2 )

		render.UpdateScreenEffectTexture()
			cc:SetFloat("$c0_x", intensity2 / 5)
			cc:SetInt("$c0_y", 1)
			render.SetMaterial(cc)
		render.DrawScreenQuad()
	end

	if IsValid(hg.ghostStation) then
		hg.ghostStation:SetVolume(math.min((intensity - time) / 50, 1))
	end

	if intensity > time + 30 and !hg.fearphrase2 then
		hg.CreateNotification(table.Random(atpeace))
		hg.fearphrase2 = true
	end
end

local ScarySounds = {
	--"npc/stalker/stalker_scream1.wav",
	--"npc/stalker/stalker_scream2.wav",
	--"npc/stalker/stalker_scream3.wav",
	--"npc/stalker/stalker_scream4.wav",
	--"npc/stalker/breathing3.wav",
	--"npc/crow/alert1.wav",
	--"npc/advisor/advisorscreenvx06.wav",
	--"npc/advisor/advisorscreenvx07.wav",
	--"npc/advisor/advisorscreenvx08.wav",
	--"cry1.wav",
	--"cry2.wav",
	"mumbling.wav",
	"blow.mp3",
	--"strangeround.wav",
	"knock.mp3",
	"ambient/atmosphere/hole_hit1.wav",
	"ambient/atmosphere/hole_hit2.wav",
	"ambient/atmosphere/hole_hit3.wav",
	"ambient/atmosphere/hole_hit4.wav",
	--"ambient/creatures/town_child_scream1.wav",
	"ambient/creatures/town_moan1.wav",
	"ambient/creatures/town_muffled_cry1.wav",
	"ambient/creatures/town_scared_breathing1.wav",
	"ambient/creatures/town_scared_breathing2.wav",
	"ambient/creatures/town_scared_sob1.wav",
	"ambient/creatures/town_scared_sob2.wav",
}

local notifs = {
	"Uh-oh...",
	"Oh no",
	"This isn't good",
	"Where's everyone?",
}

function MODE:Player_Death(ply)
	local lply = LocalPlayer()

	self:CreateTimer("fearfearingfearful", 3, 1, function()
		local players = zb:CheckAlive()

		if #players == 1 and players[1] == lply then
			self:CreateTimer("fearfearingfearful2", 0.1, 1, function()
				RunConsoleCommand("stopsound")
			end)

			self:CreateTimer("fear", 5, 1, function()
				--RunConsoleCommand("cl_soundscape_flush")
				hg.CreateNotification(table.Random(notifs))

				self:CreateTimer("fear2", 115, 1, function()
					hg.CreateNotification("bye")
				end)
			end)

			self:CreateTimer("fearfearingfearful3", 1, 1, function()
				sound.PlayFile("sound/crawlspace.mp3", "", function(channel)
					hg.lastOneStation = channel
				end)
			end)
		end
	end)
end

function MODE:RoundStart()
	self:CreateTimer("FearSounds", 1, 0, function()
		local lply = LocalPlayer()
		if !IsValid(lply) then return end
		local snd = table.Random(ScarySounds)

		if snd == "knock.mp3" then
			surface.PlaySound("knock.mp3")
			timer.Adjust("FearSounds", math.Rand(20, 60))

			return
		end

		local pos = lply:GetPos() + Vector(math.Rand(-512, 512), math.Rand(-512, 512), math.Rand(0, 512))
		
		EmitSound(snd, pos, 0, nil)
		timer.Adjust("FearSounds", math.Rand(40, 90))
	end)
end

function MODE:EndRound()
	for k, _ in pairs(self.saved.Timers or {}) do
		timer.Remove(k)
	end

	if IsValid(hg.lastOneStation) then
		hg.lastOneStation:Stop()
		hg.lastOneStation = nil
	end
end

function MODE:EntityEmitSound(data)
	local disappearance = lply:GetNetVar("disappearance", nil)
	if disappearance and IsValid(data.Entity) and (data.Entity:IsRagdoll() or data.Entity:IsPlayer() or ishgweapon(data.Entity) or data.Entity.ismelee) then
		return false
	end
end

--[[concommand.Add("status", function()
	for _, ply in ipairs( player.GetAll() ) do
		print( ply:Nick() .. ", " .. ply:SteamID() .. "\n" )
	end
end)--]]
