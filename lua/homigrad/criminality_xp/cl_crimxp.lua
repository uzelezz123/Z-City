local hudEnabled = CreateClientConVar("hg_crimxp_hud", "1", true, false, "Toggle the Criminality XP level bar")
local popupsEnabled = CreateClientConVar("hg_crimxp_popups", "1", true, false, "Toggle the Criminality XP kill popups")

surface.CreateFont("HG_CrimXPTiny", {
	font = "Bahnschrift",
	size = ScreenScale(2.7),
	weight = 400,
	extended = true,
	antialias = true,
})

surface.CreateFont("HG_CrimXPSmall", {
	font = "Bahnschrift",
	size = ScreenScale(3.5),
	weight = 500,
	extended = true,
	antialias = true,
})

surface.CreateFont("HG_CrimXPMedium", {
	font = "Bahnschrift",
	size = ScreenScale(6),
	weight = 600,
	extended = true,
	antialias = true,
})

surface.CreateFont("HG_CrimXPBig", {
	font = "Bahnschrift",
	size = ScreenScale(10),
	weight = 700,
	extended = true,
	antialias = true,
})

surface.CreateFont("HG_CrimXPHuge", {
	font = "Bahnschrift",
	size = ScreenScale(16),
	weight = 800,
	extended = true,
	antialias = true,
	shadow = true,
})

surface.CreateFont("HG_CrimXPKillSmall", {
	font = "Bahnschrift",
	size = ScreenScale(5),
	weight = 500,
	extended = true,
	antialias = true,
})

surface.CreateFont("HG_CrimXPKillTiny", {
	font = "Bahnschrift",
	size = ScreenScale(3.8),
	weight = 400,
	extended = true,
	antialias = true,
})

surface.CreateFont("HG_CrimXPKillMedium", {
	font = "Bahnschrift",
	size = ScreenScale(8),
	weight = 600,
	extended = true,
	antialias = true,
})

surface.CreateFont("HG_CrimXPDeathTitle", {
	font = "Bahnschrift",
	size = ScreenScale(24),
	weight = 800,
	extended = true,
	antialias = true,
	shadow = true,
})

surface.CreateFont("HG_CrimXPDeathInfo", {
	font = "Bahnschrift",
	size = ScreenScale(8),
	weight = 500,
	extended = true,
	antialias = true,
})

surface.CreateFont("HG_CrimXPDeathButton", {
	font = "Bahnschrift",
	size = ScreenScale(7),
	weight = 600,
	extended = true,
	antialias = true,
})

surface.CreateFont("HG_CrimXPDeathIcon", {
	font = "Segoe UI Symbol",
	size = ScreenScale(9),
	weight = 400,
	antialias = true,
})

local deathBlurMat = Material("pp/blurscreen")

-- Criminality palette (sampled from reference screenshots)
local colBox = Color(6, 6, 6, 235)
local colBoxGrey = Color(48, 48, 46, 245)
local colBarBack = Color(18, 18, 18, 235)
local colDivider = Color(45, 45, 45)
local colAvatarBg = Color(24, 24, 24)
local colWhite = Color(210, 210, 208)
local colGrey = Color(165, 165, 165)
local colDim = Color(120, 120, 120)
local colNameRed = Color(200, 40, 40)
local colRed = Color(225, 55, 55)
local colXPText = Color(150, 160, 175)
local colLevelBlue = Color(130, 157, 207)
local colGreen = Color(167, 218, 170)
local colBonus = Color(120, 160, 120)

local killNotifs = {}
local assistPopup, deathScreen, levelUpPopup

local deathButtons = {}
local deathMouseDown = false
local deathCursorOn = false

local xpBarLastXP = -100

local function bumpXPBar()
	xpBarLastXP = CurTime()
end

local function shorten(name)
	if #name > 20 then
		return string.sub(name, 1, 19) .. "…"
	end

	return name
end

local function initialsOf(name)
	local a = string.match(name, "%a")
	local b = string.match(name, "%s(%a)")

	if a and b then return string.upper(a .. b) end
	if a then return string.upper(a) end

	return "?"
end

net.Receive("hg_crimxp_kill", function()
	local notif = {
		victim = shorten(net.ReadString()),
		vLevel = net.ReadUInt(16),
		xp = net.ReadUInt(17),
		breakdown = net.ReadTable(),
		streak = net.ReadUInt(16),
		chain = net.ReadUInt(8),
		kills = net.ReadUInt(32),
		vRank = net.ReadString(),
		vColor = net.ReadColor(),
		vModel = net.ReadString(),
		vSkin = net.ReadUInt(8),
		vBodygroups = net.ReadTable(),
		vSubmats = net.ReadTable(),
		fracture = net.ReadUInt(32),
		time = CurTime(),
	}

	table.insert(killNotifs, 1, notif)

	while #killNotifs > 4 do
		table.remove(killNotifs)
	end

	bumpXPBar()

	sound.PlayFile("homigrad/vgui/deathnotice.wav", "", function() end)
end)

net.Receive("hg_crimxp_assist", function()
	assistPopup = {
		victim = shorten(net.ReadString()),
		xp = net.ReadUInt(16),
		time = CurTime(),
	}

	bumpXPBar()
end)

net.Receive("hg_crimxp_death", function()
	local ply = LocalPlayer()
	deathScreen = {
		killer = net.ReadString(),
		kLevel = net.ReadUInt(16),
		rank = net.ReadString(),
		color = net.ReadColor(),
		weapon = net.ReadString(),
		dist = net.ReadUInt(16),
		time = CurTime(),
		camStart = CurTime(),
		angles = IsValid(ply) and ply:EyeAngles() or Angle(0, 0, 0),
		fov = (IsValid(ply) and ply.GetFOV and ply:GetFOV()) or 70,
	}
end)

net.Receive("hg_crimxp_levelup", function()
	levelUpPopup = {
		level = net.ReadUInt(16),
		rank = net.ReadString(),
		color = net.ReadColor(),
		fracture = net.ReadUInt(32),
		time = CurTime(),
	}

	bumpXPBar()

	surface.PlaySound("garrysmod/content_downloaded.wav")
end)

local function fadeAlpha(startTime, dur)
	local a = 255

	if CurTime() > startTime + dur - 0.5 then
		a = math.Clamp((startTime + dur - CurTime()) / 0.5, 0, 1) * 255
	end

	if CurTime() < startTime + 0.15 then
		a = a * ((CurTime() - startTime) / 0.15)
	end

	return a
end

local function easeOut(t)
	return 1 - (1 - t) * (1 - t) * (1 - t)
end

local function xpBarAlpha()
	local since = CurTime() - xpBarLastXP

	if since < 0.2 then
		return math.Clamp(since / 0.2, 0, 1)
	elseif since < 3 then
		return 1
	end

	return math.Clamp(1 - (since - 3) / 1.5, 0, 1)
end

local function DrawLevelBar(ply)
	if not hudEnabled:GetBool() then return end

	local org = ply.organism
	if org and org.otrub then return end

	local alpha = xpBarAlpha()
	if alpha <= 0.01 then return end

	local a = alpha * 255

	local level = ply:GetCrimeLevel()
	local xpInto = ply:GetNWInt("hg_crime_xp_into", 0)
	local xpNeed = ply:GetNWInt("hg_crime_xp_need", 0)
	local rankName, rankColor = CRIMXP.GetRank(level)

	local w = ScrW() * 0.22
	local h = ScreenScale(1.6)
	local x = ScrW() / 2 - w / 2
	local y = ScrH() - ScreenScale(11)

	draw.RoundedBox(4, x - 8, y - ScreenScale(5), w + 16, ScreenScale(7.4) + h, ColorAlpha(colBox, a))

	draw.SimpleText(rankName, "HG_CrimXPTiny", x, y - ScreenScale(2.5), ColorAlpha(rankColor, a), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.SimpleText("LEVEL " .. level, "HG_CrimXPTiny", x + w, y - ScreenScale(2.5), ColorAlpha(colWhite, a), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	draw.SimpleText(xpInto .. " / " .. (xpNeed > 0 and xpNeed or "MAX") .. " XP", "HG_CrimXPTiny", x + w / 2, y + h + ScreenScale(1.8), ColorAlpha(colDim, a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	draw.RoundedBox(4, x, y, w, h, ColorAlpha(colBarBack, a))

	if xpNeed > 0 then
		local frac = math.Clamp(xpInto / xpNeed, 0, 1)

		if frac > 0 then
			draw.RoundedBox(4, x, y, w * frac, h, ColorAlpha(colLevelBlue, a))
		end
	end
end

local PORTRAIT_SLOTS = 4
local portraitMats = {}

local function reservePortraitSlot()
	local used = {}
	for _, n in ipairs(killNotifs) do
		if n.portraitSlot then used[n.portraitSlot] = true end
	end

	for i = 1, PORTRAIT_SLOTS do
		if not used[i] then return i end
	end
end

local function renderPortrait(notif)
	if notif.portraitTried then return end
	notif.portraitTried = true

	local model = notif.vModel
	if not model or model == "" or not util.IsValidModel(model) then return end

	local slot = reservePortraitSlot()
	if not slot then return end

	local size = 128
	local rtName = "hg_crimxp_portrait_" .. slot
	local rt = GetRenderTarget(rtName, size, size, false)
	if not rt then return end

	local ent = ClientsideModel(model, RENDERGROUP_OTHER)
	if not IsValid(ent) then return end

	ent:SetNoDraw(true)
	ent:SetPos(Vector(0, 0, 0))
	ent:SetAngles(Angle(0, 0, 0))
	ent:SetSkin(math.Clamp(notif.vSkin or 0, 0, 255))

	local seq = ent:LookupSequence("idle_all_01")
	if seq and seq > 0 then ent:SetSequence(seq) end

	for _, bg in ipairs(notif.vBodygroups or {}) do
		ent:SetBodygroup(bg[1], bg[2])
	end

	for _, mat in ipairs(notif.vSubmats or {}) do
		ent:SetSubMaterial(mat[1], mat[2])
	end

	ent:SetupBones()

	local headBone = ent:LookupBone("ValveBiped.Bip01_Head1")
	local headPos = headBone and ent:GetBonePosition(headBone) or Vector(0, 0, 72)
	if not headPos or headPos:LengthSqr() < 1 then
		headPos = Vector(0, 0, 72)
	end

	local focus = headPos + Vector(0, 0, 4)
	local fwd = ent:GetAngles():Forward()

	local eye = ent:LookupAttachment("eyes")
	if eye and eye > 0 then
		local att = ent:GetAttachment(eye)
		if att then
			focus = att.Pos + Vector(0, 0, 2)
			fwd = att.Ang:Forward()
		end
	end

	local camPos = focus + fwd * 42 + Vector(0, 0, 3)

	render.PushRenderTarget(rt)
	render.Clear(12, 12, 12, 255, true, true)
	render.SetWriteDepthToDestAlpha(false)

	cam.Start3D(camPos, (focus - camPos):Angle(), 40, 0, 0, size, size, 1, 300)
		render.SetLightingOrigin(focus)
		render.ResetModelLighting(0.55, 0.55, 0.55)
		render.SetModelLighting(BOX_TOP, 1, 1, 1)
		render.SetModelLighting(BOX_FRONT, 0.95, 0.95, 0.95)
		render.SetModelLighting(BOX_LEFT, 0.65, 0.65, 0.65)
		render.SetModelLighting(BOX_RIGHT, 0.65, 0.65, 0.65)
		render.SetModelLighting(BOX_BACK, 0.35, 0.35, 0.35)
		ent:DrawModel()
	cam.End3D()

	render.PopRenderTarget()

	ent:Remove()

	notif.portraitSlot = slot
	notif.portraitName = rtName

	local mat = portraitMats[slot]
	if not mat then
		mat = CreateMaterial("hg_crimxp_portrait_mat_" .. slot, "UnlitGeneric", {
			["$basetexture"] = rtName,
			["$vertexcolor"] = 1,
			["$vertexalpha"] = 1,
		})
		portraitMats[slot] = mat
	end

	notif.portraitMat = mat
end

-- Kill notifications: dark boxes stacked in the lower middle, just above the
-- XP bar, victim "avatar" square, "Killed <name>" and XP reward lines.
local function DrawKillNotifications()
	if not popupsEnabled:GetBool() then return end

	for i = #killNotifs, 1, -1 do
		if CurTime() > killNotifs[i].time + 6 then
			table.remove(killNotifs, i)
		end
	end

	local pad = ScreenScale(2)
	local lineH = ScreenScale(6.2)
	local breakdownH = ScreenScale(4.6)
	local gap = ScreenScale(2)
	local stackBottom = ScrH() - ScreenScale(18)

	for _, notif in ipairs(killNotifs) do
		renderPortrait(notif)

		local a = 255
		if CurTime() > notif.time + 5.5 then
			a = math.Clamp((notif.time + 6 - CurTime()) / 0.5, 0, 1) * 255
		end

		local slide = easeOut(math.Clamp((CurTime() - notif.time) / 0.25, 0, 1))

		local breakdown = notif.breakdown
		local shown = math.min(#breakdown, 4)

		surface.SetFont("HG_CrimXPKillSmall")
		local wKilled = surface.GetTextSize("Killed ")
		local wName = surface.GetTextSize(notif.victim)
		local w1 = wKilled + wName
		local wXP = surface.GetTextSize("+" .. notif.xp .. " XP")

		surface.SetFont("HG_CrimXPKillTiny")
		local wStreak = notif.streak >= 2 and surface.GetTextSize("STREAK " .. notif.streak) or 0
		local fracture = notif.fracture or 0
		local wMoney = fracture > 0 and surface.GetTextSize("+$" .. fracture) or 0

		local w2 = wXP
		if wStreak > 0 then w2 = w2 + ScreenScale(1.5) + wStreak end
		if wMoney > 0 then w2 = w2 + ScreenScale(1.5) + wMoney end

		local wB = 0
		for b = 1, shown do
			local line = breakdown[b]
			wB = math.max(wB, surface.GetTextSize(line[1] .. "  +" .. line[2]))
		end

		local boxH = pad * 2 + lineH * 2 + shown * breakdownH
		local avS = boxH - pad * 2
		local boxW = pad * 2 + avS + ScreenScale(2.5) + math.max(math.max(w1, w2), wB)
		local baseY = stackBottom - boxH
		local x = ScrW() / 2 - boxW / 2
		local y = baseY + (1 - slide) * ScreenScale(2)

		stackBottom = baseY - gap

		draw.RoundedBox(4, x, y, boxW, boxH, ColorAlpha(colBox, a * 0.94))

		draw.RoundedBox(3, x + pad, y + pad, avS, avS, ColorAlpha(colAvatarBg, a))

		if notif.portraitMat then
			surface.SetDrawColor(255, 255, 255, a)
			surface.SetMaterial(notif.portraitMat)
			surface.DrawTexturedRect(x + pad + 1, y + pad + 1, avS - 2, avS - 2)
		else
			draw.SimpleText(initialsOf(notif.victim), "HG_CrimXPKillMedium", x + pad + avS / 2, y + pad + avS / 2, ColorAlpha(notif.vColor, a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		surface.SetDrawColor(notif.vColor.r, notif.vColor.g, notif.vColor.b, a)
		surface.DrawOutlinedRect(x + pad, y + pad, avS, avS, 1)

		surface.SetDrawColor(colDivider.r, colDivider.g, colDivider.b, a)
		surface.DrawRect(x + pad + avS + ScreenScale(1), y + pad, 1, boxH - pad * 2)

		local tx = x + pad + avS + ScreenScale(2.5)
		local line1Y = y + pad + lineH / 2
		local line2Y = line1Y + lineH

		surface.SetFont("HG_CrimXPKillSmall")
		draw.SimpleText("Killed ", "HG_CrimXPKillSmall", tx, line1Y, ColorAlpha(colGrey, a), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText(notif.victim, "HG_CrimXPKillSmall", tx + wKilled, line1Y, ColorAlpha(colNameRed, a), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("+" .. notif.xp .. " XP", "HG_CrimXPKillSmall", tx, line2Y, ColorAlpha(colXPText, a), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		local cursor = tx + wXP
		if wStreak > 0 then
			cursor = cursor + ScreenScale(1.5)
			draw.SimpleText("STREAK " .. notif.streak, "HG_CrimXPKillTiny", cursor, line2Y, ColorAlpha(colRed, a), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			cursor = cursor + wStreak
		end
		if wMoney > 0 then
			cursor = cursor + ScreenScale(1.5)
			draw.SimpleText("+$" .. fracture, "HG_CrimXPKillTiny", cursor, line2Y, ColorAlpha(colGreen, a), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end

		for b = 1, shown do
			local line = breakdown[b]
			draw.SimpleText(line[1] .. "  +" .. line[2], "HG_CrimXPKillTiny", tx, line2Y + lineH / 2 + b * breakdownH, ColorAlpha(colBonus, a), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
	end
end

local function DrawAssistPopup()
	if not popupsEnabled:GetBool() then return end
	if not assistPopup then return end

	local dur = 3
	if CurTime() > assistPopup.time + dur then assistPopup = nil return end

	local a = fadeAlpha(assistPopup.time, dur)

	surface.SetFont("HG_CrimXPSmall")

	local w1 = surface.GetTextSize("Assist ")
	local w2 = surface.GetTextSize(assistPopup.victim)
	local w3 = surface.GetTextSize("+" .. assistPopup.xp .. " XP")

	local boxW = w1 + w2 + ScreenScale(1.5) + w3 + ScreenScale(4)
	local boxH = ScreenScale(8)
	local x = ScrW() / 2 - boxW / 2
	local y = ScrH() - ScreenScale(18) - boxH

	draw.RoundedBox(4, x, y, boxW, boxH, ColorAlpha(colBox, a * 0.94))

	local tx = x + ScreenScale(2)

	draw.SimpleText("Assist ", "HG_CrimXPSmall", tx, y + boxH / 2, ColorAlpha(colGrey, a), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.SimpleText(assistPopup.victim, "HG_CrimXPSmall", tx + w1, y + boxH / 2, ColorAlpha(colWhite, a), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.SimpleText("+" .. assistPopup.xp .. " XP", "HG_CrimXPSmall", tx + w1 + w2 + ScreenScale(1.5), y + boxH / 2, ColorAlpha(colXPText, a), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

local DEATH_BLUR_DURATION = 4
local DEATH_DISMISS_FADE = 0.8

local function deathFade()
	if not deathScreen or not deathScreen.dismissStart then return 1 end

	return math.Clamp(1 - (CurTime() - deathScreen.dismissStart) / DEATH_DISMISS_FADE, 0, 1)
end

local function deathBlurProgress()
	if not deathScreen then return 0 end

	-- Tie the blur to the death camera pull-out so it builds up as the body
	-- zooms away from the camera instead of snapping on.
	local target = math.Clamp((CurTime() - (deathScreen.camStart or deathScreen.time)) / DEATH_BLUR_DURATION, 0, 1)

	-- Clamp how fast the value can climb so a frame hitch or a late death
	-- message can never make the blur pop in all at once.
	local p = deathScreen.blurP or 0
	local maxStep = math.Clamp(FrameTime(), 0, 1 / 20) / DEATH_BLUR_DURATION

	p = p + math.Clamp(target - p, -maxStep, maxStep)
	deathScreen.blurP = p

	return p * p * deathFade()
end

local function GetDeathRagdoll(ply)
	local rag = ply:GetNWEntity("RagdollDeath")
	if IsValid(rag) then return rag end

	rag = ply.FakeRagdoll
	if IsValid(rag) then return rag end

	rag = ply:GetNWEntity("FakeRagdoll")
	if IsValid(rag) then return rag end
end

local function BuildDeathCam()
	local ply = LocalPlayer()
	if not IsValid(ply) or ply:Alive() or not deathScreen then return end

	local rag = GetDeathRagdoll(ply)
	local focus = IsValid(rag) and rag:WorldSpaceCenter() or (ply:GetPos() + Vector(0, 0, 32))

	local t = math.Clamp((CurTime() - deathScreen.camStart) / 4, 0, 1)
	local ease = 1 - (1 - t) * (1 - t) * (1 - t)

	local baseAng = deathScreen.angles or Angle(0, 0, 0)
	local horiz = Angle(0, baseAng.y, 0)
	local fwd = horiz:Forward()
	local right = horiz:Right()

	local dist = Lerp(ease, 55, 235)
	local height = Lerp(ease, 25, 95)
	local side = Lerp(ease, 0, 30)

	local desired = focus - fwd * dist + Vector(0, 0, height) + right * side

	local filter = { ply }
	if IsValid(rag) then filter[#filter + 1] = rag end

	local tr = util.TraceHull({
		start = focus,
		endpos = desired,
		mins = Vector(-6, -6, -6),
		maxs = Vector(6, 6, 6),
		filter = filter,
		mask = MASK_SOLID,
	})

	if tr.Hit then
		desired = tr.HitPos + tr.HitNormal * 8
	end

	local baseFov = deathScreen.fov or 70

	return {
		origin = desired,
		angles = (focus - desired):Angle(),
		fov = Lerp(ease, baseFov, baseFov + 12),
		drawviewer = false,
		znear = 1,
	}
end

hook.Add("HG_CalcView", "hg_crimxp_deathcam", function()
	return BuildDeathCam()
end)

hook.Add("PostPostHGCalcView", "hg_crimxp_deathcam", function()
	return BuildDeathCam()
end)

timer.Simple(0, function()
	local calcHooks = hook.GetTable().CalcView
	local base = calcHooks and calcHooks["homigrad-view"]
	if not base then return end

	hg_crimxp_cam_base = hg_crimxp_cam_base or base
	local trueBase = hg_crimxp_cam_base

	hook.Remove("CalcView", "homigrad-view")
	hook.Add("CalcView", "homigrad-view", function(ply, origin, angles, fov, znear, zfar)
		local cam = BuildDeathCam()
		if cam then return cam end

		return trueBase(ply, origin, angles, fov, znear, zfar)
	end)
end)

hook.Add("Player Spawn", "hg_crimxp_deathscreen", function(ply)
	if ply == LocalPlayer() then
		deathScreen = nil
	end
end)

local function dismissDeathScreen()
	if not deathScreen or deathScreen.dismissStart then return end

	deathScreen.dismissStart = CurTime()
	deathButtons = {}
end

hook.Add("Think", "hg_crimxp_deathfade", function()
	if not deathScreen or not deathScreen.dismissStart then return end
	if CurTime() < deathScreen.dismissStart + DEATH_DISMISS_FADE then return end

	deathScreen = nil
	_G.follow = nil
	deathButtons = {}
end)

local function openZCityMenu()
	if IsValid(MainMenu) then return MainMenu end

	hook.Run("OnPauseMenuShow")

	if not IsValid(MainMenu) then
		pcall(function()
			MainMenu = vgui.Create("ZMainMenu")
			if IsValid(MainMenu) then MainMenu:MakePopup() end
		end)
	end

	return IsValid(MainMenu) and MainMenu or nil
end

local function openZCitySettings()
	local menu = openZCityMenu()
	if not IsValid(menu) then return end
	if not IsValid(menu.panelparrent) then return end
	if not hg.DrawSettings then return end

	hg.DrawSettings(menu.panelparrent)
end

hook.Add("PlayerButtonDown", "hg_crimxp_deathdismiss", function(ply, button)
	if ply ~= LocalPlayer() or not deathScreen then return end
	if button ~= KEY_E then return end

	dismissDeathScreen()
end)

hook.Add("Think", "hg_crimxp_deathcursor", function()
	local ply = LocalPlayer()
	local active = IsValid(ply) and not ply:Alive() and deathScreen ~= nil
	local menuOpen = IsValid(MainMenu) or gui.IsGameUIVisible()

	if active and not menuOpen then
		if not deathCursorOn then
			gui.EnableScreenClicker(true)
			deathCursorOn = true
		end
	elseif deathCursorOn and not menuOpen then
		gui.EnableScreenClicker(false)
		deathCursorOn = false
	elseif menuOpen then
		deathCursorOn = false
	end
end)

hook.Add("Think", "hg_crimxp_deathclick", function()
	local down = input.IsMouseDown(MOUSE_LEFT)

	if down and not deathMouseDown then
		deathMouseDown = true

		if deathScreen and not IsValid(MainMenu) and not gui.IsGameUIVisible() then
			local mx, my = input.GetCursorPos()

			for i = 1, #deathButtons do
				local b = deathButtons[i]

				if mx >= b.x and mx <= b.x + b.w and my >= b.y and my <= b.y + b.h then
					if b.action then b.action() end
					break
				end
			end
		end
	elseif not down then
		deathMouseDown = false
	end
end)

hook.Add("HUDPaintBackground", "hg_crimxp_deathblur", function()
	local ply = LocalPlayer()
	if not IsValid(ply) or ply:Alive() or not deathScreen then return end

	local p = deathBlurProgress()
	if p <= 0 then return end

	local w, h = ScrW(), ScrH()
	local a = math.Clamp(p * 8, 0, 1)

	surface.SetMaterial(deathBlurMat)

	for i = 1, 6 do
		surface.SetDrawColor(255, 255, 255, math.floor(255 * a))
		deathBlurMat:SetFloat("$blur", (i / 6) * 5 * p)
		deathBlurMat:Recompute()
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(0, 0, w, h)
	end

	surface.SetDrawColor(0, 0, 0, math.floor(150 * p))
	surface.DrawRect(0, 0, w, h)
end)

local function DrawDeathScreen()
	deathButtons = {}

	local ply = LocalPlayer()
	if not IsValid(ply) or ply:Alive() then return end
	if not deathScreen then return end

	local now = CurTime() - deathScreen.time
	if now < 0 then return end

	local fade = deathFade()
	if fade <= 0 then return end
	local dismissing = deathScreen.dismissStart ~= nil

	local cx = ScrW() / 2
	local pad = ScreenScale(9)
	local w = ScreenScale(204)
	local h = ScreenScale(96)
	local x = cx - w / 2
	local panelFinalY = ScrH() / 2 - h / 2 + ScreenScale(26)
	local titleBaseY = panelFinalY - ScreenScale(30)

	local titleIn = math.Clamp((now - 4) / 0.3, 0, 1)
	if titleIn <= 0 then return end

	local moveT = math.Clamp((now - 4.8) / 0.6, 0, 1)
	local moveEase = easeOut(moveT)
	local wipeT = math.Clamp((now - 5.4) / 1.1, 0, 1)

	local titleAlpha = math.floor(titleIn * 255 * fade)
	local titleY = titleBaseY + (1 - moveEase) * ScreenScale(10)
	local titleText = "YOU DIED!"
	local titleFont = "HG_CrimXPDeathTitle"

	draw.SimpleText(titleText, titleFont, cx, titleY, Color(0, 0, 0, titleAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	if wipeT > 0 then
		surface.SetFont(titleFont)
		local tw, th = surface.GetTextSize(titleText)
		local left = cx - tw / 2
		local top = titleY - th / 2
		local padY = ScreenScale(2)

		render.SetScissorRect(math.floor(left), math.floor(top - padY), math.floor(left + tw * wipeT), math.floor(top + th + padY), true)
		draw.SimpleText(titleText, titleFont, cx, titleY, Color(255, 255, 255, titleAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		render.SetScissorRect(0, 0, 0, 0, false)
	end

	local statsStart = 6.65
	if now < statsStart then return end

	local function anim(i)
		local p = math.Clamp((now - (statsStart + (i - 1) * 0.08)) / 0.5, 0, 1)
		return p, easeOut(p)
	end

	local panelP, panelE = anim(1)
	local panelY = panelFinalY - (1 - panelE) * ScreenScale(24)

	draw.RoundedBox(6, x, panelY, w, h, ColorAlpha(colBox, math.floor(panelP * 235 * fade)))
	surface.SetDrawColor(colDivider.r, colDivider.g, colDivider.b, math.floor(panelP * 230 * fade))
	surface.DrawOutlinedRect(x, panelY, w, h, 1)

	local killer = deathScreen.killer ~= "" and deathScreen.killer or "Unknown"
	local weapon = deathScreen.weapon ~= "" and deathScreen.weapon or "Unknown"
	local dist = deathScreen.dist or 0

	local rows = {
		{ "KILLED BY:", killer },
		{ "WEAPON:", weapon },
		{ "DISTANCE:", dist .. " M" },
	}

	local rowH = ScreenScale(13)
	local rowsTop = panelY + pad + ScreenScale(2)
	local labelX = x + pad + ScreenScale(2)
	local valueX = x + w - pad - ScreenScale(2)

	for i = 1, #rows do
		local rp, re = anim(1 + i)
		local ry = rowsTop + (i - 1) * rowH - (1 - re) * ScreenScale(8)
		local ra = math.floor(rp * 255 * fade)

		draw.SimpleText(rows[i][1], "HG_CrimXPDeathInfo", labelX, ry, ColorAlpha(colGrey, ra), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText(rows[i][2], "HG_CrimXPDeathInfo", valueX, ry, ColorAlpha(colWhite, ra), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	end

	local btnH = ScreenScale(15)
	local gap = ScreenScale(3)
	local row1Y = panelY + h - pad - btnH * 2 - gap
	local row2Y = row1Y + btnH + gap
	local smallW = btnH

	local function button(bx, by, bw, bh, text, font, action, ba)
		draw.RoundedBox(4, bx, by, bw, bh, ColorAlpha(colBoxGrey, ba))
		surface.SetDrawColor(colDivider.r, colDivider.g, colDivider.b, math.floor(ba * 0.9))
		surface.DrawOutlinedRect(bx, by, bw, bh, 1)
		draw.SimpleText(text, font or "HG_CrimXPDeathButton", bx + bw / 2, by + bh / 2, ColorAlpha(colWhite, ba), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		if ba > 100 and not dismissing then
			deathButtons[#deathButtons + 1] = { x = bx, y = by, w = bw, h = bh, action = action }
		end
	end

	local b1p, b1e = anim(5)
	local b2p, b2e = anim(6)
	local b1a = math.floor(b1p * 255 * fade)
	local b2a = math.floor(b2p * 255 * fade)
	local b1drop = (1 - b1e) * ScreenScale(6)
	local b2drop = (1 - b2e) * ScreenScale(6)

	button(x + pad, row1Y - b1drop, smallW, btnH, "!", nil, nil, b1a)

	local wideX = x + pad + smallW + gap
	local wideW = w - pad * 2 - smallW * 2 - gap * 2
	button(wideX, row1Y - b1drop, wideW, btnH, "Continue [E]", nil, dismissDeathScreen, b1a)

	local gearX = wideX + wideW + gap
	button(gearX, row1Y - b1drop, smallW, btnH, "⚙", "HG_CrimXPDeathIcon", openZCitySettings, b1a)

	button(x + pad, row2Y - b2drop, w - pad * 2, btnH, "MENU", nil, openZCityMenu, b2a)
end

local function DrawLevelUpPopup()
	if not popupsEnabled:GetBool() then return end
	if not levelUpPopup then return end

	local dur = 5
	if CurTime() > levelUpPopup.time + dur then levelUpPopup = nil return end

	local pop = levelUpPopup
	local a = fadeAlpha(pop.time, dur)
	local pulse = 0.86 + math.abs(math.sin(CurTime() * 3)) * 0.14

	local w = ScreenScale(66)
	local h = ScreenScale(52)
	local x = ScrW() / 2 - w / 2
	local y = ScreenScale(6)
	local cx = x + w / 2

	draw.RoundedBox(6, x, y, w, h, ColorAlpha(colBoxGrey, a))

	draw.SimpleText(pop.level, "HG_CrimXPBig", cx, y + h * 0.20, ColorAlpha(colLevelBlue, a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText("LEVEL UP!", "HG_CrimXPMedium", cx, y + h * 0.42, ColorAlpha(colWhite, a * pulse), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(pop.rank, "HG_CrimXPSmall", cx, y + h * 0.61, ColorAlpha(colGreen, a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	if (pop.fracture or 0) > 0 then
		draw.SimpleText("+$" .. pop.fracture, "HG_CrimXPMedium", cx, y + h * 0.80, ColorAlpha(colGreen, a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

hook.Add("HUDPaint", "hg_crimxp_hud", function()
	local ply = LocalPlayer()
	if not IsValid(ply) then return end

	DrawLevelBar(ply)
	DrawKillNotifications()
	DrawAssistPopup()
	DrawDeathScreen()
	DrawLevelUpPopup()
end)
