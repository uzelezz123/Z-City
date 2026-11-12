local menu

local colBg = Color(8, 8, 8, 245)
local colPanel = Color(0, 0, 0, 180)
local colWhite = Color(255, 255, 255)
local colGrey = Color(160, 160, 160)
local colRed = Color(170, 0, 0)
local colBarBack = Color(25, 25, 25)

local function PaintMenu(self, w, h)
	draw.RoundedBox(6, 0, 0, w, h, colBg)
	surface.SetDrawColor(colRed)
	surface.DrawOutlinedRect(0, 0, w, h, 2)

	local ply = LocalPlayer()
	if not IsValid(ply) then return end

	local level = ply:GetCrimeLevel()
	local xp = ply:GetCrimeXP()
	local kills = ply:GetCrimeKills()
	local deaths = ply:GetCrimeDeaths()
	local streak = ply:GetCrimeStreak()
	local best = ply:GetCrimeBestStreak()
	local xpInto = ply:GetNWInt("hg_crime_xp_into", 0)
	local xpNeed = ply:GetNWInt("hg_crime_xp_need", 0)
	local rankName, rankColor = CRIMXP.GetRank(level)

	local pad = w * 0.06

	draw.SimpleText("CRIMINAL RECORD", "HG_CrimXPMedium", w / 2, h * 0.06, colRed, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	draw.SimpleText(ply:Nick(), "HG_CrimXPMedium", w / 2, h * 0.14, colWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(rankName, "HG_CrimXPSmall", w / 2, h * 0.2, rankColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	draw.SimpleText("LEVEL " .. level, "HG_CrimXPHuge", w / 2, h * 0.33, rankColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	local barW = w - pad * 2
	local barH = ScreenScale(1.6)
	local barX = pad
	local barY = h * 0.47

	draw.RoundedBox(4, barX, barY, barW, barH, colBarBack)

	if xpNeed > 0 then
		local frac = math.Clamp(xpInto / xpNeed, 0, 1)
		if frac > 0 then draw.RoundedBox(4, barX, barY, barW * frac, barH, rankColor) end
	end

	draw.SimpleText(xpInto .. " / " .. (xpNeed > 0 and xpNeed or "MAX") .. " XP", "HG_CrimXPSmall", w / 2, barY + barH / 2, colWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	local stats = {
		{"TOTAL XP", xp},
		{"KILLS", kills},
		{"DEATHS", deaths},
		{"K/D RATIO", string.format("%.2f", kills / math.max(deaths, 1))},
		{"CURRENT STREAK", streak},
		{"BEST STREAK", best},
	}

	local gridY = h * 0.58
	local colW = barW / 2
	local rowH = h * 0.06

	for i, stat in ipairs(stats) do
		local col = (i - 1) % 2
		local row = math.floor((i - 1) / 2)
		local x = barX + col * colW
		local y = gridY + row * rowH

		draw.RoundedBox(3, x + 2, y, colW - 4, rowH - 6, colPanel)
		draw.SimpleText(stat[1], "HG_CrimXPSmall", x + 10, y + (rowH - 6) / 2, colGrey, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText(tostring(stat[2]), "HG_CrimXPSmall", x + colW - 12, y + (rowH - 6) / 2, colWhite, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	end

	draw.SimpleText("Kill players to earn XP. Type !xp anywhere to open this.", "HG_CrimXPSmall", w / 2, h - ScreenScale(3), colGrey, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local function OpenMenu()
	if IsValid(menu) then menu:Remove() menu = nil return end

	menu = vgui.Create("DFrame")
	menu:SetSize(ScrW() * 0.28, ScrH() * 0.46)
	menu:Center()
	menu:SetTitle("")
	menu:ShowCloseButton(true)
	menu:MakePopup()
	menu.Paint = PaintMenu
end

concommand.Add("hg_xp", function()
	OpenMenu()
end)

hook.Add("OnPlayerChat", "hg_crimxp_chat_open", function(ply, text)
	if ply ~= LocalPlayer() then return end

	local cmd = string.Trim(string.lower(text or ""))

	if cmd == "!xp" or cmd == "!stats" or cmd == "!level" or cmd == "!rank" then
		RunConsoleCommand("hg_xp")
		return true
	end
end)
