local hide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudSecondaryAmmo"] = true,
	["CHudCrosshair"] = true,
	["CHudDamageIndicator"] = true,
	["CHudGeiger"] = true,
	["CHudSquadStatus"] = true,
	["CHudTrain"] = true,
	["CHudZoom"] = true,
	["CHudSuitPower"] = true,
	["CHUDQuickInfo"] = true,
	["CHudHistoryResource"] = true,
}

local gordon_hide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudSecondaryAmmo"] = true,
	["CHudCrosshair"] = true,
	["CHudSuitPower"] = true,
}

hook.Add("HUDShouldDraw", "homigrad", function(name)
	if hide[name] or lply.PlayerClassName and lply.PlayerClassName == "Gordon" and gordon_hide[name] then
		return false
	end
end)
hook.Add("HUDDrawTargetID", "homigrad", function()
	return false
end)

hook.Add("DrawDeathNotice", "homigrad", function()
	return false
end)

hook.Add("HUDWeaponPickedUp", "HidePickedStuff", function(wep)
	if IsValid(lply) and lply.PlayerClassName and lply.PlayerClassName == "Gordon" then
		return
	end


	return false
end)

hook.Add("HUDAmmoPickedUp", "HidePickedStuff", function(ammoname, amt)
	if IsValid(lply) and lply.PlayerClassName and lply.PlayerClassName == "Gordon" then
		return
	end

	return false
end)

hook.Add("HUDItemPickedUp", "HidePickedStuff", function(itemname)
	if IsValid(lply) and lply.PlayerClassName and lply.PlayerClassName == "Gordon" then
		return
	end

	return false
end)

hook.Add("HUDDrawPickupHistory", "HidePickedStuff", function()
	if IsValid(lply) and lply.PlayerClassName and lply.PlayerClassName == "Gordon" then
		return
	end

	return false
end)

local hg_font = ConVarExists("hg_font") and GetConVar("hg_font") or CreateClientConVar("hg_font", "Bahnschrift", true, false, "change every text font to selected because ui customization is cool")
local font = function() -- hg_coolvetica:GetBool() and "Coolvetica" or "Bahnschrift"
    local usefont = "Bahnschrift"

    if hg_font:GetString() != "" then
        usefont = hg_font:GetString()
    end

    return usefont
end

surface.CreateFont("HomigradFont", {
	font = font(),
	size = ScreenScale(10),
	weight = 1100,
	outline = false
})

surface.CreateFont("ScoreboardPlayer", {
	font = font(),
	size = ScreenScale(7),
	weight = 1100,
	outline = false
})

surface.CreateFont("HomigradFontBig", {
	font = font(),
	size = ScreenScale(12),
	weight = 1100,
	outline = false,
	shadow = true
})

surface.CreateFont("HomigradFontMedium", {
	font = font(),
	size = ScreenScale(8),
	weight = 1100,
	outline = false,
})

surface.CreateFont("HomigradFontLarge", {
	font = font(),
	size = ScreenScale(15),
	weight = 1100,
	outline = false
})

surface.CreateFont("HomigradFontGigantoNormous", {
	font = font(),
	size = ScreenScale(25),
	weight = 1100,
	outline = false,
	shadow = false
})

surface.CreateFont("HomigradFontSmall", {
	font = font(),
	size = 17,
	weight = 1100,
	outline = false
})

surface.CreateFont("HomigradFontVSmall", {
	font = font(),
	size = 12,
	weight = 400,
	outline = false
})

local w, h

hook.Add("HUDPaint", "homigrad-dev", function()
	if engine.ActiveGamemode() ~= "sandbox" then return end
	w, h = ScrW(), ScrH()
end)

function draw.CirclePart(x, y, radius, seg, parts, pos)
	local cir = {}
	table.insert(cir, {
		x = x,
		y = y,
		u = 0.5,
		v = 0.5
	})

	for i = 0, seg do
		local a = math.rad((i / seg) * -360 / parts - pos * 360 / parts) + math.pi
		table.insert(cir, {
			x = x + math.sin(a) * radius,
			y = y + math.cos(a) * radius,
			u = math.sin(a) / 2 + 0.5,
			v = math.cos(a) / 2 + 0.5
		})
	end

	render.PushFilterMin(TEXFILTER.ANISOTROPIC)
	surface.DrawPoly(cir)
	render.PopFilterMin()
end

-- Ring segment with gaps between sections
function draw.CirclePartRing(x, y, rInner, rOuter, seg, parts, pos, gapDeg)
	gapDeg = gapDeg or 3
	local poly = {}
	local totalDeg = 360 / parts
	local startDeg = pos * totalDeg + gapDeg * 0.5
	local endDeg   = (pos + 1) * totalDeg - gapDeg * 0.5
	local startR = math.rad(startDeg - 90)
	local endR   = math.rad(endDeg   - 90)

	for i = 0, seg do
		local a = startR + (endR - startR) * (i / seg)
		poly[#poly + 1] = {
			x = x + math.cos(a) * rOuter,
			y = y + math.sin(a) * rOuter,
			u = 0.5, v = 0.5
		}
	end
	for i = seg, 0, -1 do
		local a = startR + (endR - startR) * (i / seg)
		poly[#poly + 1] = {
			x = x + math.cos(a) * rInner,
			y = y + math.sin(a) * rInner,
			u = 0.5, v = 0.5
		}
	end

	render.PushFilterMin(TEXFILTER.ANISOTROPIC)
	surface.DrawPoly(poly)
	render.PopFilterMin()
end

function draw.CirclePartRingOutline(x, y, rInner, rOuter, seg, parts, pos, gapDeg)
	gapDeg = gapDeg or 3
	local totalDeg = 360 / parts
	local startDeg = pos * totalDeg + gapDeg * 0.5
	local endDeg   = (pos + 1) * totalDeg - gapDeg * 0.5
	local startR = math.rad(startDeg - 90)
	local endR   = math.rad(endDeg   - 90)

	local lastX, lastY
	for i = 0, seg do
		local a = startR + (endR - startR) * (i / seg)
		local cx = x + math.cos(a) * rOuter
		local cy = y + math.sin(a) * rOuter
		if lastX then surface.DrawLine(lastX, lastY, cx, cy) end
		lastX, lastY = cx, cy
	end

	local inEndX = x + math.cos(endR) * rInner
	local inEndY = y + math.sin(endR) * rInner
	surface.DrawLine(lastX, lastY, inEndX, inEndY)

	lastX, lastY = inEndX, inEndY
	for i = seg, 0, -1 do
		local a = startR + (endR - startR) * (i / seg)
		local cx = x + math.cos(a) * rInner
		local cy = y + math.sin(a) * rInner
		if lastX then surface.DrawLine(lastX, lastY, cx, cy) end
		lastX, lastY = cx, cy
	end

	local outStartX = x + math.cos(startR) * rOuter
	local outStartY = y + math.sin(startR) * rOuter
	surface.DrawLine(lastX, lastY, outStartX, outStartY)
end

if IsValid(MENUPANELHUYHUY) then
	MENUPANELHUYHUY:Remove()
	MENUPANELHUYHUY = nil
end

hg.radialOptions = hg.radialOptions or {}

-- AI CODED RADIAL IM SO FUCKING SCARED
local colSegBase        = Color(8,   2,   2,   160)  
local colSegHover       = Color(28,  6,   6,   210) 
local colBorderBase     = Color(120, 120, 120, 80) 
local colBorderHover    = Color(180, 180, 180, 220)
local colTextBase       = Color(190, 160, 160, 170) 
local colTextHover      = Color(240, 215, 215, 255) 
local colWhiteTransparent = Color(140, 30, 30, 90)
local colWhite          = Color(210, 185, 185, 255)
local colTransparent    = Color(0, 0, 0, 0)

local RAD_INNER_FRAC = 0

local matHuy = Material("vgui/white")
local vecXY = Vector(0, 0)
local vecDown = Vector(0, 1)
local isMouseIntersecting = false
local isMouseOnRadial = false
local current_option = 1
local current_option_select = 1
local hook_Run = hook.Run

local incoentCol = Color(128,0,0)
local taitorCol = Color(155,0,0)

local menuPanel

local colBack = Color(0,0,0)
local function CreateRadialMenu(options_arg, bAutoClose)
	local sizeX, sizeY = ScrW(), ScrH()
	hg.radialOptions = {}
	local paining = lply.organism and lply.organism.pain and (lply.organism.pain > 100 or lply.organism.brain > 0.2) or false
	
	if !options_arg then
		local functions = hook.GetTable()["radialOptions"]
		for i, func in SortedPairs(functions) do
			func()
		end
	end

	//hook_Run("radialOptions")
	local options1 = options_arg or hg.radialOptions

	hg.radialOptions = options1
	
	if IsValid(MENUPANELHUYHUY) then
		MENUPANELHUYHUY:Remove()
		MENUPANELHUYHUY = nil
	end

	MENUPANELHUYHUY = vgui.Create("DPanel")
	menuPanel = MENUPANELHUYHUY
	menuPanel:SetPos(ScrW() / 2 - sizeX / 2, ScrH() / 2 - sizeY / 2)
	menuPanel:SetSize(sizeX, sizeY)
	menuPanel:MakePopup()
	menuPanel:SetKeyBoardInputEnabled(false)
	menuPanel:SetAlpha(0)
	menuPanel:AlphaTo(255,0.2)
	menuPanel.bAutoClose = bAutoClose
	if !options_arg then input.SetCursorPos(sizeX / 2, sizeY / 2) end

	function menuPanel:Close()
		if not IsValid(menuPanel) then return end
		menuPanel:AlphaTo(0,0.1,0,function()
			if IsValid(menuPanel) then
				menuPanel:Remove()
				menuPanel = nil
			end
		end)
	end

	local thinkwait = 0
	if !options_arg then
		menuPanel.Think = function()
			if menuPanel:GetAlpha() < 255 then return end
			if thinkwait > CurTime() then return end
			thinkwait = CurTime() + 0.25
			table.Empty(hg.radialOptions)
			local functions = hook.GetTable()["radialOptions"]
			
			for i, func in SortedPairs(functions) do
				//if i == "zmeyka_test" then continue end
				func()
			end
		end
	end
	
	local sizePan = 0
	local optionSelected = {}

	menuPanel.Paint = function(self, w, h)
		local mx, my = input.GetCursorPos()
		local cx, cy = w / 2, h / 2
		local dx = mx - sizeX / 2
		local dy = my - sizeY / 2
		vecXY.x = dx
		vecXY.y = dy
		local deg = (vecXY:GetNormalized() - vecDown):Angle()
		deg = math.NormalizeAngle((deg[2] - 180) * 2) + 180

		local options = {}
		if paining then
			options[#options + 1] = {function() RunConsoleCommand("hg_phrase") end, ""}
		else
			options = options1
		end

		sizePan = LerpFT(menuPanel:GetAlpha() > 100 and 0.05 or 0.25, sizePan, (menuPanel:GetAlpha() / 255))
		local viewLerp = Lerp(math.ease.OutExpo(sizePan), 0, 1)
		local panAlpha = menuPanel:GetAlpha() / 255

		local rOuter   = ScrH() * (options_arg ~= nil and 0.4 or 0.45) * viewLerp
		local rInner   = ScrH() * RAD_INNER_FRAC * viewLerp
		local sqrt     = math.sqrt(dx ^ 2 + dy ^ 2)
		local partDeg  = 360 / math.max(#options, 1)

		-- resolve hover before drawing (avoids early return inside loop)
		isMouseOnRadial = sqrt <= rOuter and sqrt > 2
		for num, option in ipairs(options) do
			local idx = num - 1
			isMouseIntersecting = isMouseOnRadial and deg > idx * partDeg and deg < (idx + 1) * partDeg
			if isMouseIntersecting then current_option = num end
			optionSelected[idx] = optionSelected[idx] or 0
			optionSelected[idx] = LerpFT(0.1, optionSelected[idx], isMouseIntersecting and 1 or 0)
		end

		-- draw segments
		for num, option in ipairs(options) do
			local idx = num - 1
			local sel = optionSelected[idx]

			if option[3] then
				-- sub-variant segment
				local segA = math.floor(Lerp(sel, colSegBase.a, colSegHover.a) * panAlpha)
				surface.SetMaterial(matHuy)
				surface.SetDrawColor(
					math.floor(Lerp(sel, colSegBase.r, colSegHover.r)),
					math.floor(Lerp(sel, colSegBase.g, colSegHover.g)),
					math.floor(Lerp(sel, colSegBase.b, colSegHover.b)),
					segA
				)
				draw.CirclePartRing(cx, cy, rInner, rOuter, 40, #options, idx, 3)

				local count = #option[4]
				local selectedPart = count - (math.floor((rOuter - sqrt) / (rOuter / count)))
				current_option_select = selectedPart
				for i, opt in pairs(option[4]) do
					local selected = selectedPart == i
					surface.SetMaterial(matHuy)
					if selected and isMouseIntersecting then
						surface.SetDrawColor(colWhiteTransparent.r, colWhiteTransparent.g, colWhiteTransparent.b, math.floor(colWhiteTransparent.a * panAlpha))
					else
						surface.SetDrawColor(0, 0, 0, 0)
					end
					local rA = rInner + (rOuter - rInner) * ((i - 1) / count)
					local rB = rInner + (rOuter - rInner) * (i / count)
					draw.CirclePartRing(cx, cy, rA, rB, 40, #options, idx, 3)

					local midDeg = idx * (360 / #options) + (360 / #options) / 2
					local midA = math.rad(midDeg - 90)
					local tRad = rInner + (rOuter - rInner) * (i / count - 0.5 / count)
					if paining then
						math.randomseed(math.Round(CurTime() / 5 + idx + i, 0))
						opt = ""
						math.randomseed(os.time())
					end
					draw.DrawText(opt, "ZCity_Veteran",
						ScrW() / 2 + math.cos(midA) * tRad,
						ScrH() / 2 + math.sin(midA) * tRad,
						Color(colWhite.r, colWhite.g, colWhite.b, math.floor(colWhite.a * panAlpha)),
						TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
				continue
			end

			-- normal segment background (expands on hover)
			local hoverR = rOuter * (1 + 0.05 * sel)
			surface.SetMaterial(matHuy)
			surface.SetDrawColor(
				math.floor(Lerp(sel, colSegBase.r, colSegHover.r)),
				math.floor(Lerp(sel, colSegBase.g, colSegHover.g)),
				math.floor(Lerp(sel, colSegBase.b, colSegHover.b)),
				math.floor(Lerp(sel, colSegBase.a, colSegHover.a) * panAlpha)
			)
			draw.CirclePartRing(cx, cy, rInner, hoverR, 40, #options, idx, 3)

			-- thin border along outer edge
			surface.SetDrawColor(
				math.floor(Lerp(sel, colBorderBase.r, colBorderHover.r)),
				math.floor(Lerp(sel, colBorderBase.g, colBorderHover.g)),
				math.floor(Lerp(sel, colBorderBase.b, colBorderHover.b)),
				math.floor(Lerp(sel, colBorderBase.a, colBorderHover.a) * panAlpha)
			)
			draw.CirclePartRingOutline(cx, cy, rInner, hoverR, 40, #options, idx, 3)

			-- "shine" effect when hovered
			if sel > 0.05 then
				surface.SetDrawColor(
					math.floor(Lerp(sel, colBorderBase.r, colBorderHover.r)),
					math.floor(Lerp(sel, colBorderBase.g, colBorderHover.g)),
					math.floor(Lerp(sel, colBorderBase.b, colBorderHover.b)),
					math.floor(Lerp(sel, 0, 80) * panAlpha)
				)
				-- draw slightly offset outline to create glow effect
				draw.CirclePartRingOutline(cx, cy, rInner - 1, hoverR + 1, 40, #options, idx, 3)
				draw.CirclePartRingOutline(cx, cy, rInner + 1, hoverR - 1, 40, #options, idx, 3)
			end

			-- text
			local midDeg = idx * (360 / #options) + (360 / #options) / 2
			local midA = math.rad(midDeg - 90)
			local tRad = rInner + (hoverR - rInner) * 0.58

			local txt = option[2]
            if isfunction(txt) then
                txt = txt()
            end
			if txt and !options_old then return end
			if paining then
				math.randomseed(math.Round(CurTime() / 5 + idx, 0))
				txt = hg.get_status_message(ply)
				math.randomseed(os.time())
			end

			local mainTxt = txt
			local subTxt = nil
			if txt and string.find(txt, "\n") then
				local nl = string.find(txt, "\n")
				mainTxt = string.sub(txt, 1, nl - 1)
				subTxt  = string.sub(txt, nl + 1)
			end

			local tx = ScrW() / 2 + math.cos(midA) * tRad
			local ty = ScrH() / 2 + math.sin(midA) * tRad

			local flashRed = 0
			if sel > 0 then
				flashRed = (math.sin(CurTime() * 10) * 0.5 + 0.5) * sel
			end

			local textColR = math.floor(Lerp(flashRed, Lerp(sel, colTextBase.r, colTextHover.r), 255))
			local textColG = math.floor(Lerp(flashRed, Lerp(sel, colTextBase.g, colTextHover.g), 0))
			local textColB = math.floor(Lerp(flashRed, Lerp(sel, colTextBase.b, colTextHover.b), 0))

			draw.DrawText(mainTxt, "ZCity_Veteran", tx, subTxt and ty - 12 or ty,
				Color(
					textColR,
					textColG,
					textColB,
					math.floor(Lerp(sel, colTextBase.a, colTextHover.a) * panAlpha)
				), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			if subTxt then
				draw.DrawText(subTxt, "ZCity_Veteran", tx, ty + 28,
					Color(
						textColR,
						textColG,
						textColB,
						math.floor(Lerp(sel, colTextBase.a, colTextHover.a) * panAlpha * 0.7)
					), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			-- player name and role, drawn once in first segment
			if idx == 0 and !(paining) then
				draw.SimpleText(lply:GetPlayerName(), "HomigradFontGigantoNormous",
					ScrW() * 0.0215 * viewLerp, ScrH() * 0.042, colBack, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				draw.SimpleText((lply.role and lply.role.name) or "", "HomigradFontGigantoNormous",
					ScrW() * 0.0215 * viewLerp, ScrH() * 0.098, colBack, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				local col = lply:GetPlayerColor():ToColor()
				draw.SimpleText(lply:GetPlayerName(), "HomigradFontGigantoNormous",
					ScrW() * 0.02 * viewLerp, ScrH() * 0.04, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				draw.SimpleText((lply.role and lply.role.name) or "", "HomigradFontGigantoNormous",
					ScrW() * 0.02 * viewLerp, ScrH() * 0.095,
					lply.role and lply.role.color or incoentCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end
		end

	end
end

local function PressRadialMenu(mouseClick)
	local options = hg.radialOptions

	hook_Run("RadialMenuPressed")

	local needed_mouseclick
	if IsValid(menuPanel) and options[current_option] and isMouseOnRadial then
		local func = options[current_option][1]
		if isfunction(func) then 
			needed_mouseclick = func(mouseClick, current_option_select)
			LocalPlayer():EmitSound("hover.ogg", 75, 110, 1, CHAN_AUTO)
		end
	end

	if needed_mouseclick != -1 and IsValid(menuPanel) and mouseClick != (needed_mouseclick or 2) and not menuPanel.bAutoClose then
		menuPanel:Close()
	end
end

hg.CreateRadialMenu = CreateRadialMenu
hg.PressRadialMenu = PressRadialMenu

local firstTime = true
local firstTime2 = true
local firstTime3 = true
local firstTime4 = true
local firstTime5 = true
local firstTime6 = true

-- first time?..

hook.Add("HG_OnOtrub", "resetshit", function(ply)
	if ply == lply then
		hook_Run("RadialMenuPressed")

		if IsValid(menuPanel) then
			menuPanel:Close()
		end
	end
end)

hook.Add( "PlayerBindPress", "PlayerBindPressExample2huy", function( ply, bind, pressed )
	if string.find(bind, "+menu") then

		if (lply.organism and lply.organism.otrub) then
			return (bind == "+menu") or nil
		end

		if (bind == "+menu") then
			if pressed and !IsValid(MENUPANELHUYHUY) then
				CreateRadialMenu()
			else
				PressRadialMenu(1)
			end
		else
			if lply:IsAdmin() then return end
		end

		return true
	end
end)

hook.Add("Think", "hg-radial-menu", function()
	if (lply.organism and lply.organism.otrub) then

		if IsValid(menuPanel) then
			hook_Run("RadialMenuPressed")
			menuPanel:Close()
		end

		return
	end
	
	if (engine.ActiveGamemode() ~= "sandbox" and input.IsKeyDown(KEY_Q)) or (engine.ActiveGamemode() == "sandbox" and input.IsKeyDown(KEY_C)) then
		if firstTime then
			firstTime = false
		end

		firstTime4 = true
	else
		if firstTime4 then
			firstTime4 = false
		end

		firstTime = true
	end

	if input.IsMouseDown(MOUSE_LEFT) then
		if firstTime2 then
			firstTime2 = false
		end

		firstTime3 = true
	else
		if firstTime3 then
			firstTime3 = false
			PressRadialMenu(1)
		end

		firstTime2 = true
	end

	if input.IsMouseDown(MOUSE_RIGHT) then
		if firstTime5 then
			firstTime5 = false
		end

		firstTime6 = true
	else
		if firstTime6 then
			firstTime6 = false
			PressRadialMenu(2)
		end

		firstTime5 = true
	end
end)

local function dropWeapon()
	RunConsoleCommand("drop")
end

hook.Add("radialOptions", "77", function()
	local organism = lply.organism or {}
	if not organism.otrub and IsValid(lply:GetActiveWeapon()) and lply:GetActiveWeapon():GetClass() ~= "weapon_hands_sh" then
		local tbl = {dropWeapon, "Drop Weapon"}
		hg.radialOptions[#hg.radialOptions + 1] = tbl
	end
end)

local randomGestures = {
	"wave",
	"salute",
	"halt",
	"group",
	"forward",
	"disagree",
	--"agree",
	"becon",
	{"point", function() RunConsoleCommand("hg_hand_gesture", "point") end},
	{"fuck you", function() RunConsoleCommand("hg_hand_gesture", "fuckyou") end},
	{"thumb_up", function() RunConsoleCommand("hg_hand_gesture" , "thumb_up") end},
}

concommand.Add("hg_randomgesture",function()
	randomGesture()
end)

hook.Add("radialOptions", "7", function()
    local ply = LocalPlayer()
    local organism = ply.organism or {}

    if ply:Alive() and not organism.otrub and hg.GetCurrentCharacter(ply) == ply then
        if ply.GetPlayerClass and ply:GetPlayerClass() and ply:GetPlayerClass().CanUseGestures ~= nil and not ply:GetPlayerClass().CanUseGestures then return end
		local tbl = {function(mouseClick)
			if mouseClick == 1 then
				RunConsoleCommand("act", randomGestures[math.random(#randomGestures)])
				if (ply.NextFoley or 0) < CurTime() then
					ply:EmitSound("player/clothes_generic_foley_0" .. math.random(5) .. ".wav", 55)
					ply.NextFoley = CurTime() + 1
				end
			else
				local commands = {}
				for i, str in ipairs(randomGestures) do
					commands[i] = {
						[1] = function()
							if istable(str) then
								str[2]()
							else
								RunConsoleCommand("act", str)
								if (ply.NextFoley or 0) < CurTime() then
									ply:EmitSound("player/clothes_generic_foley_0" .. math.random(5) .. ".wav", 55)
									ply.NextFoley = CurTime() + 1
								end
							end
						end,
						[2] = string.NiceName(istable(str) and str[1] or str)
					}
				end
				CreateRadialMenu(commands)
			end
		end, "Do Gesture\nRMB - Menu"}
        hg.radialOptions[#hg.radialOptions + 1] = tbl
    end
end)

hook.Add("radialOptions", "Afflictions", function()
    local ply = LocalPlayer()
    local organism = ply.organism or {}

    if ply:Alive() and not organism.otrub and hg.GetCurrentCharacter(ply) == ply then
        local tbl = {function()
            RunConsoleCommand("mcd_admire")
        end, "Afflictions"}
        hg.radialOptions[#hg.radialOptions + 1] = tbl
    end
end)

local font_size = 50
surface.CreateFont("HG_font", {
	font = "Arial",
	extended = false,
	size = font_size,
	weight = 500,
	outline = true
})

local CurTime = CurTime

local vector_one = Vector( 1, 1, 1 )

local function CopyRight( text, font, x, y, color, ang, scale )

	local m = Matrix()
	m:Translate( Vector( x, y, 0 ) )
	m:Rotate( Angle( 0, ang, 0 ) )
	m:Scale( vector_one * ( scale or 1 ) )

	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )

	m:Translate( Vector( -(w / 2)-25, -h / 2, 0 ) )

	cam.PushModelMatrix( m, true )
		draw.RoundedBox(5,0,2,w+52,h+2,Color(0,0,0))
		draw.RoundedBox(5,0,2,w+50,h,Color(255,0,0))
		draw.DrawText( text, font, 25, 0, color )	
	cam.PopModelMatrix()

end


hook.Add("HUDPaint","Identifier",function()
	if lply.organism and lply.organism.otrub then return end
	if !lply:Alive() then return end
	if lply:GetNetVar("disappearance", nil) then return end 
	
	local trace = hg.eyeTrace(lply)
	
	if not trace then return end

	local Size = math.max(math.min(1 - trace.Fraction, 1), 0.1)
	local x, y = trace.HitPos:ToScreen().x, trace.HitPos:ToScreen().y

	if trace.Hit and (trace.Entity:IsRagdoll() or trace.Entity:IsPlayer()) then
		if trace.Entity.PlayerClassName == "sc_infiltrator" then return end
		if trace.Entity:GetNetVar("disappearance", nil) then return end

		draw.NoTexture()

		local col = trace.Entity:GetPlayerColor():ToColor()
		col.a = 255 * Size * 1.5

		local coloutline = (col.r < 50 and col.g < 50 and col.b < 50) and Color(100,100,100) or Color(0,0,0)
		coloutline.a = 255 * Size * 1

		draw.DrawText(trace.Entity:GetPlayerName() or "", "HomigradFontLarge", x + 1, y + 31, coloutline, TEXT_ALIGN_CENTER)

		draw.DrawText(trace.Entity:GetPlayerName() or "", "HomigradFontLarge", x, y + 30, col, TEXT_ALIGN_CENTER)
	end
end)


function scare()
end

local hint
local hg_hints = ConVarExists("hg_hints") and GetConVar("hg_hints") or CreateClientConVar("hg_hints", "1", true, false, "Enable\\Disable hints.")

local HintBackgroundColor = Color( 0, 0, 0, 200 )

hook.Add("HUDPaint","EntHints",function()
	if not hg_hints:GetBool() then return end 
	if lply.organism and lply.organism.otrub then return end
	if !lply:Alive() then return end
	
	local trace = hg.eyeTrace(lply)

	if not trace then return end

	HintBackgroundColor.a = LerpFT(0.1, HintBackgroundColor.a, (IsValid(trace.Entity) and trace.Entity.HudHintMarkup) and 200 or 0)

	hg.BasicHudHint(trace.Entity, trace, hint)
end)

local observe_state = {
	active = false,
	stage = 1,
	stage_start = 0,
	target = nil,
	data_target = nil,
	last_health = 0,
	last_hurt = 0,
	last_painadd = 0,
	was_alive = true,
	require_admire_reset = false
}
local observe_parts = {"Arms", "Torso", "Legs"}
local observe_stage_time = 4.5
local observe_text_delay = 1.8
local observe_type_speed = 28
local observe_line_color = Color(0, 0, 0, 255)
local observe_box_color = Color(0, 0, 0, 220)
local observe_text_color = Color(255, 255, 255, 255)
local observe_line_screen = 50
local observe_line_screen_up = 22
local observe_font = "ZCity_Veteran"

local observe_bone_sets = {
	Arms = {
		{
			label = "Left Arm",
			bones = {"ValveBiped.Bip01_L_Forearm"},
			side = -1,
			offset = 12,
			fracture_keys = {"larm"},
			dis_key = "larmdislocation",
			hitgroups = {
				[HITGROUP_LEFTARM] = true
			}
		},
		{
			label = "Right Arm",
			bones = {"ValveBiped.Bip01_R_Forearm"},
			side = 1,
			offset = 12,
			fracture_keys = {"rarm"},
			dis_key = "rarmdislocation",
			hitgroups = {
				[HITGROUP_RIGHTARM] = true
			}
		}
	},
	Torso = {
		{
			label = "Torso",
			bones = {"ValveBiped.Bip01_Spine2", "ValveBiped.Bip01_Spine1", "ValveBiped.Bip01_Spine", "ValveBiped.Bip01_Pelvis"},
			side = 1,
			offset = 12,
			fracture_keys = {"chest", "spine1", "spine2", "spine3", "pelvis", "brokenribs"},
			hitgroups = {
				[HITGROUP_CHEST] = true,
				[HITGROUP_STOMACH] = true,
				[HITGROUP_GENERIC] = true
			}
		}
	},
	Legs = {
		{
			label = "Left Leg",
			bones = {"ValveBiped.Bip01_L_Calf", "ValveBiped.Bip01_L_Thigh", "ValveBiped.Bip01_L_Foot"},
			side = -1,
			fracture_keys = {"lleg"},
			dis_key = "llegdislocation",
			hitgroups = {
				[HITGROUP_LEFTLEG] = true
			}
		},
		{
			label = "Right Leg",
			bones = {"ValveBiped.Bip01_R_Calf", "ValveBiped.Bip01_R_Thigh", "ValveBiped.Bip01_R_Foot"},
			side = 1,
			fracture_keys = {"rleg"},
			dis_key = "rlegdislocation",
			hitgroups = {
				[HITGROUP_RIGHTLEG] = true
			}
		}
	}
}

local function get_observe_target(ply, admiring)
	local fake = (IsValid(ply.FakeRagdoll) and ply.FakeRagdoll) or (IsValid(ply:GetNWEntity("FakeRagdoll")) and ply:GetNWEntity("FakeRagdoll"))
	if IsValid(fake) then
		return fake, ply
	end
	local wep = ply:GetActiveWeapon()
	if IsValid(wep) and wep.CarryEnt and IsValid(wep.CarryEnt) then
		if wep.CarryEnt:IsRagdoll() then
			local owner = hg.RagdollOwner(wep.CarryEnt)
			return wep.CarryEnt, (IsValid(owner) and owner or wep.CarryEnt)
		end
		if wep.CarryEnt:IsPlayer() then
			return wep.CarryEnt, wep.CarryEnt
		end
	end
	local carry = ply:GetNetVar("carryent")
	if IsValid(carry) then
		if carry:IsRagdoll() then
			local owner = hg.RagdollOwner(carry)
			return carry, (IsValid(owner) and owner or carry)
		end
		if carry:IsPlayer() then
			if IsValid(carry.FakeRagdoll) then
				return carry.FakeRagdoll, carry
			end
			return carry, carry
		end
	end
	local tr = hg.eyeTrace(ply, 120)
	if tr and IsValid(tr.Entity) then
		local ent = tr.Entity
		if ent:IsRagdoll() then
			local owner = hg.RagdollOwner(ent)
			return ent, (IsValid(owner) and owner or ent)
		end
		if ent:IsPlayer() then
			if IsValid(ent.FakeRagdoll) then
				return ent.FakeRagdoll, ent
			end
			return ent, ent
		end
	end
	if admiring then
		return ply, ply
	end
end

local function get_hitgroup(ent, bone)
	if not bone then return end
	if not hg or not hg.bonetohitgroup then return end
	local bonename = bone
	if isnumber(bone) and IsValid(ent) then
		bonename = ent:GetBoneName(bone)
	end
	return bonename and hg.bonetohitgroup[bonename] or nil
end

local function count_wounds_for_groups(ent, wounds, groups)
	local count = 0
	if wounds then
		for i = 1, #wounds do
			local bone = wounds[i][4]
			local hitgroup = get_hitgroup(ent, bone)
			if hitgroup and groups[hitgroup] then
				count = count + 1
			end
		end
	end
	return count
end

local function count_arterial_for_groups(ent, arterialwounds, groups)
	local count = 0
	if arterialwounds then
		for i = 1, #arterialwounds do
			local bone = arterialwounds[i][4]
			local hitgroup = get_hitgroup(ent, bone)
			if hitgroup and groups[hitgroup] then
				count = count + 1
			end
		end
	end
	return count
end

local function has_fracture(org, keys)
	for i = 1, #keys do
		local key = keys[i]
		if key == "brokenribs" then
			if org.brokenribs and org.brokenribs > 0 then
				return true
			end
		else
			local v = org[key]
			if v then
				local threshold = 1
				if hg and hg.organism then
					local fake_key = hg.organism["fake_" .. key]
					if fake_key then
						threshold = fake_key
					end
				end
				if v >= threshold then
					return true
				end
			end
		end
	end
	return false
end

local function get_bleeding_label(count)
	if count <= 0 then return nil end
	if count == 1 then return "Minor bleeding" end
	if count <= 3 then return "Bleeding" end
	return "Intense bleeding"
end

local function get_bone_pos(ent, bones)
	ent:SetupBones()
	for i = 1, #bones do
		local id = ent:LookupBone(bones[i])
		if id then
			local pos = ent:GetBonePosition(id)
			if isvector(pos) then
				return pos
			end
		end
	end
	local center = ent:OBBCenter()
	if isvector(center) then
		return ent:LocalToWorld(center)
	end
end

local function build_observe_text(entry, ent)
	if not IsValid(ent) then
		return entry.label .. ": No target"
	end
	local org = ent.organism or ent.new_organism or {}
	local wounds = ent.wounds or ent:GetNetVar("wounds") or {}
	local arterialwounds = ent.arterialwounds or ent:GetNetVar("arterialwounds") or {}
	if not ent.organism and not ent.new_organism then
		return entry.label .. ": No data"
	end
	local fracture = has_fracture(org, entry.fracture_keys or {})
	local dislocation = entry.dis_key and (org[entry.dis_key] or false) or false
	local woundcount = count_wounds_for_groups(ent, wounds, entry.hitgroups or {})
	local arterialcount = count_arterial_for_groups(ent, arterialwounds, entry.hitgroups or {})
	if not fracture and not dislocation and woundcount <= 0 and arterialcount <= 0 then
		return entry.label .. ": All fine."
	end
	local parts = {}
	if fracture then parts[#parts + 1] = "Fracture" end
	if dislocation then parts[#parts + 1] = "Dislocated" end
	local bleeding = get_bleeding_label(woundcount)
	if bleeding then parts[#parts + 1] = bleeding end
	if arterialcount > 0 then parts[#parts + 1] = "Arterial bleeding" end
	return entry.label .. ": " .. table.concat(parts, ", ")
end

hook.Add("HUDPaint", "mcd_admire_observe", function()
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	local alive = ply:Alive() and ply:Health() > 0 and not (ply.organism and ply.organism.alive == false) and not IsValid(ply:GetNWEntity("spect"))
	local view_ent = GetViewEntity()
	local function reset_observe(require_reset)
		observe_state.active = false
		observe_state.target = nil
		observe_state.data_target = nil
		observe_state.stage = 1
		observe_state.stage_start = 0
		observe_state.last_health = 0
		observe_state.last_hurt = 0
		observe_state.last_painadd = 0
		if require_reset then
			observe_state.require_admire_reset = true
			ply.mcd_admire_local_cancel = true
			if ply:GetNWBool("mcd_admiring", false) then
				RunConsoleCommand("mcd_admire", "cancel")
			end
		end
	end
	if observe_state.was_alive and not alive then
		reset_observe(true)
	end
	if not observe_state.was_alive and alive then
		reset_observe(false)
	end
	observe_state.was_alive = alive
	if not alive then
		reset_observe(false)
		return
	end
	if view_ent ~= ply then
		reset_observe(true)
		return
	end
	local in_fake = IsValid(ply.FakeRagdoll) or IsValid(ply:GetNWEntity("FakeRagdoll")) or IsValid(ply:GetNWEntity("FakeRagdollOld")) or IsValid(ply:GetNWEntity("RagdollDeath")) or IsValid(ply.RagdollDeath)
	if in_fake then
		reset_observe(true)
		return
	end
	if not ply:OnGround() then
		reset_observe(true)
		return
	end
	local org = ply.organism or ply.new_organism
	local hurt = org and org.hurt or 0
	local painadd = org and org.painadd or 0
	if observe_state.last_painadd and painadd > observe_state.last_painadd + 0.01 then
		reset_observe(true)
		observe_state.last_painadd = painadd
		return
	end
	observe_state.last_painadd = painadd
	if observe_state.last_hurt and hurt > observe_state.last_hurt + 0.01 then
		reset_observe(true)
		observe_state.last_hurt = hurt
		return
	end
	observe_state.last_hurt = hurt
	local health = ply:Health()
	if observe_state.last_health and health < observe_state.last_health then
		reset_observe(true)
		observe_state.last_health = health
		return
	end
	observe_state.last_health = health
	local admiring = ply:GetNWBool("mcd_admiring", false)
	if observe_state.require_admire_reset then
		if admiring then return end
		observe_state.require_admire_reset = false
		ply.mcd_admire_local_cancel = false
	end
	if not admiring then
		observe_state.active = false
		observe_state.target = nil
		observe_state.data_target = nil
		ply.mcd_admire_local_cancel = false
		return
	end
	local draw_ent, data_ent = get_observe_target(ply, admiring)
	if not admiring and not IsValid(draw_ent) then
		observe_state.active = false
		observe_state.target = nil
		observe_state.data_target = nil
		return
	end

	if observe_state.target ~= draw_ent or not observe_state.active then
		observe_state.active = true
		observe_state.target = draw_ent
		observe_state.data_target = data_ent
		observe_state.stage = 1
		observe_state.stage_start = CurTime()
		observe_state.last_health = ply:Health()
	end

	local elapsed = CurTime() - observe_state.stage_start
	if elapsed >= observe_stage_time then
		observe_state.stage = observe_state.stage + 1
		if observe_state.stage > #observe_parts then
			observe_state.stage = 1
		end
		observe_state.stage_start = CurTime()
		elapsed = 0
	end

	local part = observe_parts[observe_state.stage]
	local entries = observe_bone_sets[part]
	if not entries or not IsValid(draw_ent) then return end
	local t = math.Clamp(elapsed / observe_stage_time, 0, 1)
	local fade = t <= 0.5 and (t * 2) or ((1 - t) * 2)
	local fade_alpha = math.Clamp(fade, 0, 1)
	if fade_alpha <= 0 then return end

	local offscreen_count = 0
	for i = 1, #entries do
		local entry = entries[i]
		local bone_pos = get_bone_pos(draw_ent, entry.bones)
		if bone_pos then
			if entry.offset and entry.offset ~= 0 then
				bone_pos = bone_pos + draw_ent:GetForward() * entry.offset
			end
			local screen = bone_pos:ToScreen()
			local is_offscreen = not screen.visible or screen.x < 0 or screen.x > ScrW() or screen.y < 0 or screen.y > ScrH()
			
			local end_x, end_y
			if is_offscreen then
				offscreen_count = offscreen_count + 1
				end_x = ScrW() * 0.5
				end_y = ScrH() - 20 - (offscreen_count * 40)
			else
				end_x = screen.x + observe_line_screen * (entry.side or 1)
				end_y = screen.y - observe_line_screen_up
				surface.SetDrawColor(observe_line_color.r, observe_line_color.g, observe_line_color.b, math.floor(255 * fade_alpha))
				surface.DrawLine(screen.x, screen.y, end_x, end_y)
			end

			local full_text
			local type_elapsed
			if elapsed < observe_text_delay then
				full_text = entry.label .. ": Observing..."
				type_elapsed = elapsed
			else
				full_text = build_observe_text(entry, observe_state.data_target or draw_ent)
				type_elapsed = elapsed - observe_text_delay
			end
			local max_chars = math.floor(type_elapsed * observe_type_speed)
			local text = string.sub(full_text, 1, math.Clamp(max_chars, 0, #full_text))

			surface.SetFont(observe_font)
			local tw, th = surface.GetTextSize(text)
			local pad = 6
			local box_w = tw + pad * 2
			local box_h = th + pad * 2
			local box_x = end_x - box_w * 0.5
			local box_y = end_y - box_h * 0.5
			draw.RoundedBox(0, box_x, box_y, box_w, box_h, Color(observe_box_color.r, observe_box_color.g, observe_box_color.b, math.floor(observe_box_color.a * fade_alpha)))
			draw.SimpleText(text, observe_font, end_x, end_y, Color(observe_text_color.r, observe_text_color.g, observe_text_color.b, math.floor(observe_text_color.a * fade_alpha)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
end)

function hg.BasicHudHint(ent, trace)
	hint = (IsValid(ent) and ent.HudHintMarkup) or hint

	if not hint then return end

	local x, y = trace.HitPos:ToScreen().x, trace.HitPos:ToScreen().y
	y = y + 145 + -45

	draw.RoundedBox(2, x - hint:GetWidth() / 2 - 2.5, y - 2.5, hint:GetWidth() + 5, hint:GetHeight() + 5, HintBackgroundColor)
	
	hint:Draw(x, y, TEXT_ALIGN_CENTER, nil, 175 * (HintBackgroundColor.a / 200), TEXT_ALIGN_CENTER)

	if ent.AdditionalInfoFunc then
		local str = ent.AdditionalInfoFunc()

		local w, h = surface.GetTextSize(str)
		surface.SetFont("ZCity_Tiny")
		surface.SetTextColor(color_white)
		surface.SetTextPos(x - w * 0.5, y + hint:GetHeight() + h)
		surface.DrawText(str)
	end
end

local leg = Material("zbattle/medical/broken_bone.png", "")

local white = Color(255, 255, 255, 255)
local bkg = Color(43, 30, 30)
hook.Add("HUDPaint","afflictionlist",function()
end)

-- Now playable :steamhappy: