local MODE = MODE
local HNS_SCHIZO_PHRASES = {
    "KILL THEM ALL",
    "THEY DESERVE WHAT'S COMING",
    "DON'T LET THEM HIDE",
    "THEY'RE WATCHING",
    "END IT",
    "NO MERCY",
    "MAKE THEM PAY",
    "LISTEN TO THE VOICES",
    "FINISH THE HUNT",
    "BLOOD FOR BLOOD",
}

local hnsSchizoNextAt = 0
local hnsSchizoShowUntil = 0
local hnsSchizoBatch = {}

hook.Add("HUDPaint", "HNS_SchizoFlashes", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    if not ply:GetNetVar("HNS_Schizo", false) then return end

    local t = CurTime()

    -- Show for 5 seconds, then wait 10 seconds before next burst
    if hnsSchizoShowUntil == 0 or (t >= hnsSchizoShowUntil and t >= hnsSchizoNextAt) then
        hnsSchizoBatch = {}
        for i = 1, 12 do
            hnsSchizoBatch[i] = HNS_SCHIZO_PHRASES[math.random(#HNS_SCHIZO_PHRASES)]
        end
        hnsSchizoShowUntil = t + 5
        hnsSchizoNextAt = hnsSchizoShowUntil + 10
    end

    if t < hnsSchizoShowUntil then
        local w, h = ScrW(), ScrH()
        local alpha = math.Clamp(200 + 55 * math.sin(t * 15), 80, 255)
        surface.SetFont("Trebuchet24")
        for i = 1, #hnsSchizoBatch do
            local x = math.random(math.floor(w * 0.1), math.floor(w * 0.9))
            local y = math.random(math.floor(h * 0.1), math.floor(h * 0.9))
            draw.SimpleTextOutlined(
                hnsSchizoBatch[i], "Trebuchet24", x, y,
                Color(255, 0, 0, alpha),
                TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
                1, Color(0, 0, 0, alpha * 0.6)
            )
        end
    end
end)
MODE.name = "hideseek"
local roundEnding = false
net.Receive("hns_start", function()
    timer.Simple(0.2, function()
        sound.PlayFile("sound/zbattle/criresp/criepmission.mp3", "mono noblock", function(station)
            if IsValid(station) then
                station:Play()
            end
        end)
    end)
end)

local teams = {
    [0] = {
        objective = "boi how you get this XD",
        name = "SWAT Agent",
        color1 = Color(68, 10, 255),
        color2 = Color(68, 10, 255)
    },
    [1] = {
        objective = "Some people have bad intentions. Hide from the Seekers, they'll arrive shortly.",
        name = "Hider",
        color1 = Color(0, 190, 190),
        color2 = Color(0, 190, 190)
    },
    [2] = {
        objective = "Can't turn back now, kill all the hiders.",
        name = "Seeker",
        color1 = Color(255, 0, 0),
        color2 = Color(228, 49, 49)
    },
}

function MODE:RenderScreenspaceEffects()
    zb.RemoveFade()
    if zb.ROUND_START + 7.5 < CurTime() then return end
    local fade = math.Clamp(zb.ROUND_START + 7.5 - CurTime(), 0, 1)
    surface.SetDrawColor(0, 0, 0, 255 * fade)
    surface.DrawRect(-1, -1, ScrW() + 1, ScrH() + 1)
end
local posadd = 0
function MODE:HUDPaint()

    if zb.ROUND_START + 60 > CurTime() then
        posadd = Lerp(FrameTime() * 5,posadd or 0, zb.ROUND_START + 7.3 < CurTime() and 0 or -sw * 0.4)
        local blink = math.sin(CurTime()*3) >= 0 and Color(255,0,0) or Color(0,0,0)
        draw.SimpleText( "Seeker will arrive in: "..string.FormattedTime(zb.ROUND_START + 60 - CurTime(), "%02i:%02i"), "ZB_HomicideMedium", sw * 0.02 + posadd, sh * 0.91, Color(0,0,0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText( "Seeker will arrive in: "..string.FormattedTime(zb.ROUND_START + 60 - CurTime(), "%02i:%02i"), "ZB_HomicideMedium", (sw * 0.02) - 2 + posadd, (sh * 0.91) - 2, blink, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    if zb.ROUND_START + 240 > CurTime() then
        posadd = Lerp(FrameTime() * 5,posadd or 0, zb.ROUND_START + 7.3 < CurTime() and 0 or -sw * 0.4) 
        local color = Color(255*-math.sin(CurTime()*3),25,255*math.sin(CurTime()*3))
        draw.SimpleText( string.FormattedTime(zb.ROUND_START + 240 - CurTime(), "%02i:%02i").." Until Round End", "ZB_HomicideMedium", sw * 0.02 + posadd, sh * 0.95, Color(0,0,0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText( string.FormattedTime(zb.ROUND_START + 240 - CurTime(), "%02i:%02i").." Until Round End", "ZB_HomicideMedium", (sw * 0.02) - 2 + posadd, (sh * 0.95) - 2, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        local fade = math.Clamp(zb.ROUND_START + 7.5 - CurTime(), 0, 1)
        surface.SetDrawColor(0, 0, 0, 255 * fade)
        surface.DrawRect(-1, -1, ScrW() + 1, ScrH() + 1)
    end

    if lply:Team() == 2 then
        local arrive = (zb.ROUND_START + 60) - CurTime()
        local t = CurTime()
        local active = t < arrive
        local fadeout = math.Clamp((arrive + 1.5 - t) / 1.5, 0, 1)
        local revealEnd = zb.ROUND_START + 8.5
        if (active or fadeout > 0) and t >= revealEnd then
            local alpha = active and 255 or math.floor(255 * fadeout)
            surface.SetDrawColor(0, 0, 0, alpha)
            surface.DrawRect(0, 0, sw, sh)
            local fade = active and 1 or fadeout
            local colRed = Color(228, 49, 49, 255 * fade)
            local colWhite = Color(255, 255, 255, 255 * fade)
            draw.SimpleText("You are a seeker", "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.4, colRed, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("Find all hiders and kill them.", "ZB_HomicideMedium", sw * 0.5, sh * 0.5, colWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("You will arrive in " .. string.FormattedTime(math.max(arrive - t, 0), "%02i:%02i"), "ZB_HomicideMedium", sw * 0.5, sh * 0.6, colWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

	if zb.ROUND_START + 8.5 > CurTime() then
		if not lply:Alive() and not lply:Team() == 0 then return end
		local fade = math.Clamp(zb.ROUND_START + 8 - CurTime(), 0, 1)
		local team_ = lply:Team()
		draw.SimpleText("ZBattle | Hide n' Seek", "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.1, Color(195, 0, 0, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		local Rolename = teams[team_].name
		local ColorRole = teams[team_].color1
		ColorRole.a = 255 * fade
		draw.SimpleText("You are a " .. Rolename, "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.5, ColorRole, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		local Objective = teams[team_].objective
		local ColorObj = teams[team_].color2
		ColorObj.a = 255 * fade
		draw.SimpleText(Objective, "ZB_HomicideMedium", sw * 0.5, sh * 0.9, ColorObj, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	if hg.PluvTown.Active and fade then
		surface.SetMaterial(hg.PluvTown.PluvMadness)
		surface.SetDrawColor(255, 255, 255, math.random(175, 255) * fade / 2)
		surface.DrawTexturedRect(sw * 0.25, sh * 0.44 - ScreenScale(15), sw / 2, ScreenScale(30))

		draw.SimpleText("SOMEWHERE IN PLUVTOWN", "ZB_ScrappersLarge", sw / 2, sh * 0.44 - ScreenScale(2), Color(0, 0, 0, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

local CreateEndMenu
net.Receive("hns_roundend", function()
    roundEnding = true
    CreateEndMenu(net.ReadBool())
end)
local colGray = Color(85, 85, 85, 255)
local colRed = Color(130, 10, 10)
local colRedUp = Color(160, 30, 30)
local colBlue = Color(10, 10, 160)
local colBlueUp = Color(40, 40, 160)
local col = Color(255, 255, 255, 255)
local colSpect1 = Color(75, 75, 75, 255)
local colSpect2 = Color(255, 255, 255)
local colorBG = Color(55, 55, 55, 255)
local colorBGBlacky = Color(40, 40, 40, 255)
local blurMat = Material("pp/blurscreen")
local Dynamic = 0
BlurBackground = BlurBackground or hg.DrawBlur

if IsValid(hmcdEndMenu) then
	hmcdEndMenu:Remove()
	hmcdEndMenu = nil
end

CreateEndMenu = function(whowin)
	if IsValid(hmcdEndMenu) then
		hmcdEndMenu:Remove()
		hmcdEndMenu = nil
	end

	Dynamic = 0
	hmcdEndMenu = vgui.Create("ZFrame")
	surface.PlaySound( (whowin == 1) and "zbattle/criresp/failedSWAT.mp3" or "ambient/alarms/warningbell1.wav")
	local sizeX, sizeY = ScrW() / 2.5, ScrH() / 1.2
	local posX, posY = ScrW() / 1.3 - sizeX / 2, ScrH() / 2 - sizeY / 2
	hmcdEndMenu:SetPos(posX, posY)
	hmcdEndMenu:SetSize(sizeX, sizeY)
	--hmcdEndMenu:SetBackgroundColor(colGray)
	hmcdEndMenu:MakePopup()
	hmcdEndMenu:SetKeyboardInputEnabled(false)
	hmcdEndMenu:ShowCloseButton(false)
	local closebutton = vgui.Create("DButton", hmcdEndMenu)
	closebutton:SetPos(5, 5)
	closebutton:SetSize(ScrW() / 20, ScrH() / 30)
	closebutton:SetText("")
	closebutton.DoClick = function()
		if IsValid(hmcdEndMenu) then
			hmcdEndMenu:Close()
			hmcdEndMenu = nil
		end
	end

	closebutton.Paint = function(self, w, h)
		surface.SetDrawColor(122, 122, 122, 255)
		surface.DrawOutlinedRect(0, 0, w, h, 2.5)
		surface.SetFont("ZB_InterfaceMedium")
		surface.SetTextColor(col.r, col.g, col.b, col.a)
		local lenghtX, lenghtY = surface.GetTextSize("Close")
		surface.SetTextPos(lenghtX - lenghtX / 1.1, 4)
		surface.DrawText("Close")
	end

	hmcdEndMenu.PaintOver = function(self, w, h)
		surface.SetFont("ZB_InterfaceMediumLarge")
		surface.SetTextColor(col.r, col.g, col.b, col.a)
		local lenghtX, lenghtY = surface.GetTextSize("Players:")
		surface.SetTextPos(w / 2 - lenghtX / 2, 20)
		surface.DrawText("Players:")
	end

	-- PLAYERS
	local DScrollPanel = vgui.Create("DScrollPanel", hmcdEndMenu)
	DScrollPanel:SetPos(10, 80)
	DScrollPanel:SetSize(sizeX - 20, sizeY - 90)

	for i, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end
		local but = vgui.Create("DButton", DScrollPanel)
		but:SetSize(100, 50)
		but:Dock(TOP)
		but:DockMargin(8, 6, 8, -1)
		but:SetText("")
		but.Paint = function(self, w, h)
	local col1 = (ply:Alive() and colRed) or colGray
	local col2 = (ply:Alive() and colRedUp) or colSpect1
	surface.SetDrawColor(col1.r, col1.g, col1.b, col1.a)
	surface.DrawRect(0, 0, w, h)
	surface.SetDrawColor(col2.r, col2.g, col2.b, col2.a)
	surface.DrawRect(0, h / 2, w, h / 2)
	local col = ply:GetPlayerColor():ToColor()
	surface.SetFont("ZB_InterfaceMediumLarge")
	local lenghtX, lenghtY = surface.GetTextSize(ply:GetPlayerName() or "He quited...")
	surface.SetTextColor(0, 0, 0, 255)
	surface.SetTextPos(w / 2 + 1, h / 2 - lenghtY / 2 + 1)
	surface.DrawText(ply:GetPlayerName() or "He quited...")
	surface.SetTextColor(col.r, col.g, col.b, col.a)
	surface.SetTextPos(w / 2, h / 2 - lenghtY / 2)
	surface.DrawText(ply:GetPlayerName() or "He quited...")
	local col = colSpect2
	surface.SetFont("ZB_InterfaceMediumLarge")
	surface.SetTextColor(col.r, col.g, col.b, col.a)
	local lenghtX, lenghtY = surface.GetTextSize(ply:GetPlayerName() or "He quited...")
	surface.SetTextPos(15, h / 2 - lenghtY / 2)
	surface.DrawText(ply:Name() .. (ply:GetNetVar("handcuffed", false) and " - neutralized" or (not ply:Alive() and " - dead") or " - alive"))
	surface.SetFont("ZB_InterfaceMediumLarge")
	surface.SetTextColor(col.r, col.g, col.b, col.a)
	local lenghtX, lenghtY = surface.GetTextSize(ply:Frags() or "He quited...")
	surface.SetTextPos(w - lenghtX - 15, h / 2 - lenghtY / 2)
	surface.DrawText(ply:Frags() or "He quited...")
end


		function but:DoClick()
			if ply:IsBot() then
				chat.AddText(Color(255, 0, 0), "no, you can't")
				return
			end

			gui.OpenURL("https://steamcommunity.com/profiles/" .. ply:SteamID64())
		end

		DScrollPanel:AddItem(but)
	end
	return true
end

function MODE:RoundStart()
    if IsValid(hmcdEndMenu) then
        hmcdEndMenu:Remove()
        hmcdEndMenu = nil
    end
end
