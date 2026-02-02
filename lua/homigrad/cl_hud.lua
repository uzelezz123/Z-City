local hide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudAmmo"] = false,
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

hook.Add("HUDShouldDraw", "homigrad", function(name)
	if hide[name] then
		return false
	end
	if IsValid(lply) and lply.PlayerClassName == "Gordon" and name == "CHudHistoryResource" then
		return true
	end
end)
hook.Add("HUDDrawTargetID", "homigrad", function()
	return false
end)

hook.Add("DrawDeathNotice", "homigrad", function()
	return false
end)

--local hg_coolvetica = ConVarExists("hg_coolvetica") and GetConVar("hg_coolvetica") or CreateClientConVar("hg_coolvetica", "0", true, false, "changes every text to coolvetica because its good", 0, 1)
local hg_font = ConVarExists("hg_font") and GetConVar("hg_font") or CreateClientConVar("hg_font", "Bahnschrift", true, false, "change every text font to selected because ui customization is cool")
local font = function() -- hg_coolvetica:GetBool() and "Coolvetica" or "Bahnschrift"
    local usefont = "Bahnschrift"

    if hg_font:GetString() != "" then
        usefont = hg_font:GetString()
    end

    return usefont
end

--atlaschat.coolvetica
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

--draw.SimpleText(lply:Health(),"HomigradFontBig",100,h - 50,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
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
		--draw.DrawText("asd","HomigradFontBig",x + math.sin(a) * radius,y + math.cos(a) * radius)
	end

	--local a = math.rad(0)
	--table.insert(cir, {x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5})
	render.PushFilterMin(TEXFILTER.ANISOTROPIC)
	surface.DrawPoly(cir)
	render.PopFilterMin()
end

if IsValid(MENUPANELHUYHUY) then
	MENUPANELHUYHUY:Remove()
	MENUPANELHUYHUY = nil
end

hg.radialOptions = hg.radialOptions or {}
local colBlack = Color(0, 0, 0, 152)
local colOption = Color(40, 0, 55, 152)
local colWhite = Color(255, 255, 255, 255)
local colWhiteTransparent = Color(176, 40, 40, 100)
local colTransparent = Color(0, 0, 0, 0)
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
local function CreateRadialMenu(options_arg)
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
		local x, y = input.GetCursorPos()
		x = x - sizeX / 2
		y = y - sizeY / 2
		vecXY.x = x
		vecXY.y = y
		local deg = (vecXY:GetNormalized() - vecDown):Angle()
		//deg[2] = deg[2] - 180
		deg = math.NormalizeAngle((deg[2] - 180) * 2) + 180
		
		local options = {}
		if paining then
			options[#options + 1] = {function() RunConsoleCommand("hg_phrase") end, ""}
		else
			options = options1
		end

		sizePan = LerpFT( menuPanel:GetAlpha() > 100 and 0.05 or 0.25,sizePan,(menuPanel:GetAlpha()/255))
		local viewLerp = Lerp(math.ease.OutExpo(sizePan),0,1)
		for num, option in ipairs(options) do
			local num = num - 1
			
			local r = ScrH() * (options_arg ~= nil and 0.4 or 0.45) * viewLerp
			local partDeg = 360 / #options
			local sqrt = math.sqrt(x ^ 2 + y ^ 2)
			isMouseOnRadial = sqrt <= r and sqrt > 4
			isMouseIntersecting = isMouseOnRadial and deg > num * partDeg and deg < (num + 1) * partDeg
			if isMouseIntersecting then current_option = num + 1 end
			if sqrt > 0 and current_option > 0 and num and !intersect_xyPartDeg then return end

			optionSelected[num] = optionSelected[num] or 0
			optionSelected[num] = LerpFT(0.1, optionSelected[num], isMouseIntersecting and 1 or 0)
			
			if option[3] then
				surface.SetMaterial(matHuy)
				surface.SetDrawColor(isMouseIntersecting and colBlack or colBlack)
				draw.CirclePart(w / 2, h / 2, r, 40, #options, num)
				local count = #option[4]
				
				local selectedPart = count - (math.floor((r - sqrt) / (r / count)))
				
				current_option_select = selectedPart
				for i, opt in pairs(option[4]) do
					local selected = selectedPart == i
					surface.SetMaterial(matHuy)
					surface.SetDrawColor((selected and isMouseIntersecting) and colWhiteTransparent or colTransparent)
					draw.CirclePart(w / 2, h / 2, r * (i / count), 40, #options, num)
					local a = -partDeg * num - partDeg / 2
					a = math.rad(a) + math.pi

					if paining then
						math.randomseed(math.Round(CurTime() / 5 + num + i, 0))
						opt = ""//hg.get_status_message(ply)
						math.randomseed(os.time())
					end

					draw.DrawText(opt, "HomigradFont", ScrW() / 2 + math.sin(a) * r * (i / count - 0.5 / count), ScrH() / 2 + math.cos(a) * r * (i / count - 0.5 / count), colWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end

				continue
			end
			
			--print(options_arg ~= nil and true or false)
			surface.SetMaterial(matHuy)	
			surface.SetDrawColor(colWhiteTransparent:Lerp(options_arg ~= nil and colOption or colBlack, 1 - optionSelected[num]))
			draw.CirclePart(w / 2, h / 2, r * (1 + 0.1 * optionSelected[num]), 30, #options, num)
			local a = -partDeg * num - partDeg / 2
			a = math.rad(a) + math.pi
			local txt = option[2]
			if txt and !options_old then return end
			if paining then
				math.randomseed(math.Round(CurTime() / 5 + num, 0))
				txt = hg.get_status_message(ply)
				math.randomseed(os.time())
			end
			draw.DrawText(txt, "HomigradFont", ScrW() / 2 + math.sin(a) * r * 0.75, ScrH() / 2 + math.cos(a) * r * 0.75, colWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			if !(paining) then
				draw.SimpleText(lply:GetPlayerName(),"HomigradFontGigantoNormous",ScrW() * 0.0215* viewLerp,ScrH() * 0.042, colBack, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				draw.SimpleText( ( (lply.role and lply.role.name) or ""),"HomigradFontGigantoNormous" ,ScrW() * 0.0215 * viewLerp,ScrH() * 0.098, colBack, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

				local col = lply:GetPlayerColor():ToColor()
				draw.SimpleText(lply:GetPlayerName(),"HomigradFontGigantoNormous",ScrW() * 0.02 * viewLerp,ScrH() * 0.04, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				draw.SimpleText( ( (lply.role and lply.role.name) or ""),"HomigradFontGigantoNormous" ,ScrW() * 0.02 * viewLerp,ScrH() * 0.095, lply.role and lply.role.color or incoentCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end
		end
	end
end

local function PressRadialMenu(mouseClick)
	local options = hg.radialOptions
	--print(options[current_option][1])
	--[[if lply.organism and lply.organism.pain and lply.organism.pain > 100 then
		hook_Run("RadialMenuPressed")

		if IsValid(menuPanel) then
			menuPanel:Close()
		end

		return
	end--]]

	hook_Run("RadialMenuPressed")

	local needed_mouseclick
	if IsValid(menuPanel) and options[current_option] and isMouseOnRadial then
		local func = options[current_option][1]
		if isfunction(func) then needed_mouseclick = func(mouseClick, current_option_select) end
	end

	if needed_mouseclick != -1 and IsValid(menuPanel) and mouseClick != (needed_mouseclick or 2) then
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
			--CreateRadialMenu()
		end

		firstTime4 = true
	else
		if firstTime4 then
			firstTime4 = false
			--PressRadialMenu()
		end

		firstTime = true
	end

	if input.IsMouseDown(MOUSE_LEFT) then
		if firstTime2 then
			firstTime2 = false
			--print("pressed")
		end

		firstTime3 = true
	else
		if firstTime3 then
			firstTime3 = false
			--print("released")
			PressRadialMenu(1)
		end

		firstTime2 = true
	end

	if input.IsMouseDown(MOUSE_RIGHT) then
		if firstTime5 then
			firstTime5 = false
			--print("pressed")
		end

		firstTime6 = true
	else
		if firstTime6 then
			firstTime6 = false
			--print("released")
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
        local tbl = {function(mouseClick)
			if mouseClick == 1 then
				RunConsoleCommand("act", randomGestures[math.random(#randomGestures)])
			else
				local commands = {}
				for i, str in ipairs(randomGestures) do
					commands[i] = {
						[1] = function()
							if istable(str) then
								str[2]()
							else
								RunConsoleCommand("act", str)
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
	--render.PushFilterMag( TEXFILTER.ANISOTROPIC )
	--render.PushFilterMin( TEXFILTER.ANISOTROPIC )

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

	--render.PopFilterMag()
	--render.PopFilterMin()
end

--hook.Add("HUDPaint","homigrad-copyright",function()
	--local i = 1
	--CopyRight("ЖДИ ДОКС ЖДИ СВАТ","HomigradFontBig",ScrW()/2 +(math.cos(CurTime()*1)*15*i),ScrH()/2+(math.sin(CurTime()*1)*55*i)+15,Color(255,255,255),math.cos(CurTime()*1)*1,2+math.sin(CurTime()*1)*0.5)
--end)

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

--sound.PlayURL("https://cdn.discordapp.com/attachments/1254022273661145108/1257385761414582382/pon_pon_016eb317d_1.mp4?ex=66882bbe&is=6686da3e&hm=429f0e4427bdc9d80673d3bfa2eccf48221ae5572ec508fb7699274c2c7041ef&","",function() end)

function scare()
	-- hook.Add("RenderScreenspaceEffects","Scare",function()
		-- for i = 1, 5 do
		-- CopyRight("Плывиски","HomigradFontBig",ScrW()/2 +(math.cos(CurTime()*1)*15*i),ScrH()/2+(math.sin(CurTime()*1)*55*i)+15,Color(255,255,255),math.cos(CurTime()*1)*1,2+math.sin(CurTime()*1)*0.5)
		-- end
	-- end)
	-- for i = 1, 15 do
		-- sound.PlayURL("https://cdn.discordapp.com/attachments/1254022273661145108/1257385761414582382/pon_pon_016eb317d_1.mp4?ex=66882bbe&is=6686da3e&hm=429f0e4427bdc9d80673d3bfa2eccf48221ae5572ec508fb7699274c2c7041ef&","",function() end)
	-- end
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
	--[[if lply.organism and lply.organism.otrub then return end
	if !lply:Alive() then return end
	
	local org = lply.organism

	if org.lleg >= 0.99 then
		local w, h = 200, 200

		local ent = hg.GetCurrentCharacter(lply)
		local lkp = ent:LookupBone("ValveBiped.Bip01_R_Thigh")
		local matrix = ent:GetBoneMatrix(lkp)

		if matrix then
			local pos = matrix:GetTranslation() + matrix:GetForward() * ent:BoneLength(lkp + 1) * 0.5
			local scrpos = pos:ToScreen()

			surface.SetMaterial(leg)
			surface.SetDrawColor(white)
			--surface.DrawRect(sw / 2 - w / 2, sh / 2 - h / 2, w, h)
			surface.SetDrawColor(white)
			surface.DrawTexturedRect(scrpos.x - w / 2, scrpos.y - h / 2, w, h)
		end
	end--]]
end)
if game.SinglePlayer() then
	hook.Add("HUDPaint","Exit the singleplayer",function()
		draw.SimpleText("Z-City is not for SINGLEPLAYER server, in map select change green SINGLEPLAYER to 2 players or any.", "HomigradFontMedium",ScrW()/2,ScrH()/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end)
end