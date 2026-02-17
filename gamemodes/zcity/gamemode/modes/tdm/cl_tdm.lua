MODE.name = "tdm"

local MODE = MODE

net.Receive("tdm_start",function()
    surface.PlaySound("csgo_round.wav")
	zb.rtype = net.ReadString()
	hg.DynaMusic:Start( "swat4" )
	zb.RemoveFade()
end)

local teams = {
	[0] = {
		objective = "",
		name = "a Terrorist",
		color1 = Color(190,0,0),
		color2 = Color(190,0,0)
	},
	[1] = {
		objective = "",
		name = "a Counter Terrorist",
		color1 = Color(0,120,190),
		color2 = Color(0,120,190)
	},
}

hook.Add( "StartCommand", "TDM_DisallowMoveOrShoting", function( ply, mv )
	--; BLYAT NY NAXUA PISAT VSE V ODNY LINIY BLYAAA
	if zb.CROUND == "tdm" and (zb.ROUND_START or 0) + 20 > CurTime() then 
		mv:RemoveKey(IN_ATTACK)
		mv:RemoveKey(IN_ATTACK2)
		mv:RemoveKey(IN_FORWARD)
		mv:RemoveKey(IN_BACK)
		mv:RemoveKey(IN_MOVELEFT)
		mv:RemoveKey(IN_MOVERIGHT)
	end
end)

function MODE:RenderScreenspaceEffects()
    local StartTime = zb.ROUND_START or CurTime()
	if StartTime + 7.5 < CurTime() then return end
    local fade = math.Clamp(StartTime + 7.5 - CurTime(),0,1)

    surface.SetDrawColor(0,0,0,255 * fade)
    surface.DrawRect(-1,-1,ScrW() + 1,ScrH() + 1)
end

function MODE:HUDPaint()
    local StartTime = zb.ROUND_START or CurTime()
	self:AddHudPaint()
	if StartTime + 20 > CurTime() then
		draw.SimpleText( string.FormattedTime(StartTime + 20 - CurTime(), "%02i:%02i:%02i"	), "ZB_HomicideMedium", sw * 0.5, sh * 0.95, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText( "Press F3 to open buymenu", "ZB_HomicideMedium", sw * 0.5, sh * 0.9, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		local time = string.FormattedTime( math.max(StartTime + (zb.ROUND_TIME or 400) - CurTime(), 0), "%02i:%02i:%02i" )
		draw.SimpleText( time, "ZB_HomicideMedium", sw * 0.5, sh * 0.95, ColorObj, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

    if StartTime + 20 < CurTime() then return end
	 
	if not lply:Alive() then return end
	zb.RemoveFade()
    local fade = math.Clamp(StartTime + 8 - CurTime(),0,1)
	local team_ = lply:Team()
    draw.SimpleText("ZBattle | "..(self.PrintName or "Team Deathmatch"), "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.1, Color(0,162,255, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    local Rolename = teams[team_].name
    local ColorRole = teams[team_].color1
    ColorRole.a = 255 * fade
    draw.SimpleText("You are "..Rolename , "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.5, ColorRole, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    local Objective = teams[team_].objective
    local ColorObj = teams[team_].color2
    ColorObj.a = 255 * fade
    draw.SimpleText( Objective, "ZB_HomicideMedium", sw * 0.5, sh * 0.9, ColorObj, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	if hg.PluvTown.Active then
		surface.SetMaterial(hg.PluvTown.PluvMadness)
		surface.SetDrawColor(255, 255, 255, math.random(175, 255) * fade / 2)
		surface.DrawTexturedRect(sw * 0.25, sh * 0.44 - ScreenScale(15), sw / 2, ScreenScale(30))

		draw.SimpleText("SOMEWHERE IN PLUVTOWN", "ZB_ScrappersLarge", sw / 2, sh * 0.44 - ScreenScale(2), Color(0, 0, 0, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

function MODE:AddHudPaint()
end

local CreateEndMenu

net.Receive("tdm_roundend",function()
    CreateEndMenu()
end)



local colGray = Color(85,85,85,255)
local colRed = Color(130,10,10)
local colRedUp = Color(160,30,30)

local colBlue = Color(10,10,160)
local colBlueUp = Color(40,40,160)
local col = Color(255,255,255,255)

local colSpect1 = Color(75,75,75,255)
local colSpect2 = Color(255,255,255)

local colorBG = Color(55,55,55,255)
local colorBGBlacky = Color(40,40,40,255)

local blurMat = Material("pp/blurscreen")
local Dynamic = 0

BlurBackground = BlurBackground or hg.DrawBlur

if IsValid(hmcdEndMenu) then
    hmcdEndMenu:Remove()
    hmcdEndMenu = nil
end

CreateEndMenu = function()
	if IsValid(hmcdEndMenu) then
		hmcdEndMenu:Remove()
		hmcdEndMenu = nil
	end
	Dynamic = 0
	hmcdEndMenu = vgui.Create("ZFrame")

    surface.PlaySound("ambient/alarms/warningbell1.wav")

	local sizeX,sizeY = ScrW() / 2.5 ,ScrH() / 1.2
	local posX,posY = ScrW() / 1.3 - sizeX / 2,ScrH() / 2 - sizeY / 2

	hmcdEndMenu:SetPos(posX,posY)
	hmcdEndMenu:SetSize(sizeX,sizeY)
	--hmcdEndMenu:SetBackgroundColor(colGray)
	hmcdEndMenu:MakePopup()
	hmcdEndMenu:SetKeyboardInputEnabled(false)
	hmcdEndMenu:ShowCloseButton(false)

	local closebutton = vgui.Create("DButton",hmcdEndMenu)
	closebutton:SetPos(5,5)
	closebutton:SetSize(ScrW() / 20,ScrH() / 30)
	closebutton:SetText("")
	
	closebutton.DoClick = function()
		if IsValid(hmcdEndMenu) then
			hmcdEndMenu:Close()
			hmcdEndMenu = nil
		end
	end

	closebutton.Paint = function(self,w,h)
		surface.SetDrawColor( 122, 122, 122, 255)
        surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
		surface.SetFont( "ZB_InterfaceMedium" )
		surface.SetTextColor(col.r,col.g,col.b,col.a)
		local lengthX, lengthY = surface.GetTextSize("Close")
		surface.SetTextPos( lengthX - lengthX/1.1, 4)
		surface.DrawText("Close")
	end

    hmcdEndMenu.Paint = function(self,w,h)
		BlurBackground(self)

		surface.SetFont( "ZB_InterfaceMediumLarge" )
		surface.SetTextColor(col.r,col.g,col.b,col.a)
		local lengthX, lengthY = surface.GetTextSize("Players:")
		surface.SetTextPos(w / 2 - lengthX/2,20)
		surface.DrawText("Players:")

		surface.SetDrawColor( 255, 0, 0, 128)
        surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
	end
	-- PLAYERS
	local DScrollPanel = vgui.Create("DScrollPanel", hmcdEndMenu)
	DScrollPanel:SetPos(10, 80)
	DScrollPanel:SetSize(sizeX - 20, sizeY - 90)
	function DScrollPanel:Paint( w, h )
		BlurBackground(self)

		surface.SetDrawColor( 255, 0, 0, 128)
        surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
	end

	for i, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end
		local but = vgui.Create("DButton",DScrollPanel)
		but:SetSize(100,50)
		but:Dock(TOP)
		but:DockMargin( 8, 6, 8, -1 )
		but:SetText("")
		but.Paint = function(self,w,h)
            local col1 = (ply:Alive() and colRed) or colGray
            local col2 = (ply:Alive() and colRedUp) or colSpect1
			surface.SetDrawColor(col1.r,col1.g,col1.b,col1.a)
			surface.DrawRect(0,0,w,h)
			surface.SetDrawColor(col2.r,col2.g,col2.b,col2.a)
			surface.DrawRect(0,h/2,w,h/2)

            local col = ply:GetPlayerColor():ToColor()
			surface.SetFont( "ZB_InterfaceMediumLarge" )
			local lengthX, lengthY = surface.GetTextSize( ply:GetPlayerName() or "He quited..." )
			
			surface.SetTextColor(0,0,0,255)
			surface.SetTextPos(w / 2 + 1,h/2 - lengthY/2 + 1)
			surface.DrawText(ply:GetPlayerName() or "He quited...")

			surface.SetTextColor(col.r,col.g,col.b,col.a)
			surface.SetTextPos(w / 2,h/2 - lengthY/2)
			surface.DrawText(ply:GetPlayerName() or "He quited...")

            
			local col = colSpect2
			surface.SetFont( "ZB_InterfaceMediumLarge" )
			surface.SetTextColor(col.r,col.g,col.b,col.a)
			local lengthX, lengthY = surface.GetTextSize( ply:GetPlayerName() or "He quited..." )
			surface.SetTextPos(15,h/2 - lengthY/2)
			surface.DrawText((ply:Name() .. (not ply:Alive() and " - died" or "")) or "He quited...")

			surface.SetFont( "ZB_InterfaceMediumLarge" )
			surface.SetTextColor(col.r,col.g,col.b,col.a)
			local lengthX, lengthY = surface.GetTextSize( ply:Frags() or "He quited..." )
			surface.SetTextPos(w - lengthX -15,h/2 - lengthY/2)
			surface.DrawText(ply:Frags() or "He quited...")
		end

		function but:DoClick()
			if ply:IsBot() then chat.AddText(Color(255,0,0), "no, you can't") return end
			gui.OpenURL("https://steamcommunity.com/profiles/"..ply:SteamID64())
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

surface.CreateFont("ZB_TDM_MENU", {
    font = "Bahnschrift",
    size = ScreenScale(12),
    extended = true,
    weight = 400,
    antialias = true
})
surface.CreateFont("ZB_TDM_DESC", {
    font = "Bahnschrift",
    size = ScreenScale(7),
    extended = true,
    weight = 400,
    antialias = true
})

surface.CreateFont("ZB_TDM_CATEGORY", {
    font = "Bahnschrift",
    size = ScreenScale(6),
    extended = true,
    weight = 400,
    antialias = true
})

surface.CreateFont("ZB_TDM_DESCSMALL", {
    font = "Bahnschrift",
    size = ScreenScale(5),
    extended = true,
    weight = 400,
    antialias = true
})

local function PaintFrame(self,w,h)
	BlurBackground(self)

	surface.SetDrawColor( 255, 0, 0, 128)
    surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
end

local function PaintPanel(self,w,h)
	surface.SetDrawColor( 0, 0, 0,155)
    surface.DrawRect( 0, 0, w, h, 2.5 )
	surface.SetDrawColor( 255, 0, 0, 128)
    surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
end

local gradient_l = Material("vgui/gradient-l")

local function PaintPanel1(self,w,h)
	surface.SetDrawColor( 0, 0, 0,155)
    surface.DrawRect( 0, 0, w, h, 2.5 )
	surface.SetDrawColor( 255, 0, 0, 128)
    surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
	draw.RoundedBox( 0, 2.5, 2.5, w-5, h-5, Color( 0, 0, 0, 140) )
    surface.SetDrawColor(155, 0, 0, 55)
    surface.SetMaterial(gradient_l)
    surface.DrawTexturedRect( 0, 0, w/1.5, h )
end

local function PaintPanel2(self,w,h)
	--surface.SetDrawColor( 15, 15, 15,25)
    --surface.DrawRect( 0, 0, w, h, 2.5 )
	--draw.RoundedBox( 0, 2.5, 2.5, w-5, h-5, Color( 0, 0, 0, 140) )
    surface.SetDrawColor(55, 155, 55, 25)
    surface.SetMaterial(gradient_l)
    surface.DrawTexturedRect( 0, 0, w*1.2, h )
end

local rtabFunc = function(self)

	local ExtraInset = 10

	if ( self.Image ) then
		ExtraInset = ExtraInset + self.Image:GetWide()
	end

	self:SetTextInset( ExtraInset, 2 )
	local w, h = self:GetContentSize()
	h = self:GetTabHeight()

	self:SetSize( w + 10, h + 7 )

	DLabel.ApplySchemeSettings( self )

end

local function OpenBuyMenu()
	if TDM_OpenedBuyMenu then
		TDM_OpenedBuyMenu:Remove()
		TDM_OpenedBuyMenu = nil
	end
	local StartTime = zb.ROUND_START or CurTime()
	if not LocalPlayer():Alive() or StartTime + 40 < CurTime() then return end
	TDM_OpenedBuyMenu = vgui.Create("ZFrame")
	local Frame = TDM_OpenedBuyMenu
	Frame:SetSize(ScrW()*0.35,ScrH()*0.85)
	Frame:Center()
	Frame:MakePopup()
	Frame:SetTitle("Buy menu")
	Frame.Paint = PaintFrame
	
	local Sheet = vgui.Create( "DPropertySheet", Frame )
	Sheet:Dock( FILL )
	Sheet:SetTextInset(50)
	Sheet.Paint = function() end
	Sheet.tabScroller:SetOverlap( 0 )
	Sheet.tabScroller:DockMargin( 8, 0, 8, 0 )
	Sheet:SetFadeTime(0.1)

	for k,category in SortedPairsByMemberValue(MODE.BuyItems, "Priority") do
		local CategoryPanel = vgui.Create( "DScrollPanel", sheet )
		--CategoryPanel:Dock()
		CategoryPanel.Paint = function() end
		for n,Item in pairs(category) do
			if n == "Priority" then continue end
			local weapon = weapons.GetStored( Item.ItemClass )
			local ent = scripted_ents.GetStored( Item.ItemClass )

			local ItemPanel = vgui.Create("DPanel",CategoryPanel)
			ItemPanel:SetSize(0,ScrH()*0.1)
			ItemPanel:Dock(TOP)
			ItemPanel:DockMargin(0,5,0,0)
			ItemPanel.Paint = PaintPanel1
			--print(Item.ItemClass,weapon)
			if ( weapon ~= nil and ( (weapon.WepSelectIcon2 and weapon.WepSelectIcon2:GetName()) or (weapon.IconOverride)) ) or ((ent and ent.t.IconOverride)) then
				local ItemButton = vgui.Create("DImage",ItemPanel)
				local bBox = ((ent and ent.t.IconOverride) or weapon~=nil and weapon.WepSelectIcon2box)
				ItemButton:SetSize(ScrH() * ( (bBox and 0.1) or 0.17), ScrH() * 0.1)
				ItemButton:Dock(LEFT)
				local boxed = ScrH()*0.07/2
				ItemButton:DockMargin(5 + (bBox and boxed or 0),5,5 + (bBox and boxed or 0),5)
				ItemButton:SetImage( ( weapon ~= nil and ( (weapon.WepSelectIcon2 and weapon.WepSelectIcon2:GetName() .. ".png") or weapon.IconOverride) ) or ((ent and ent.t.IconOverride) or "none") )
			end

			local ItemButton = vgui.Create("DPanel",ItemPanel)
			ItemButton:Dock(FILL)
			ItemButton:DockMargin(0,5,0,0)
			ItemButton.Paint = function() end

			local lbl = vgui.Create("DLabel", ItemButton)
			lbl:SetText(n)
			lbl:DockMargin(10,0,5,0)
			lbl:Dock(TOP)
			lbl:SetFont("ZB_TDM_MENU")
			lbl:SetSize(ScrW()*0.5,ScrH()*0.04)

			local lbl = vgui.Create("DLabel", ItemButton)
			lbl:SetText("Price: $"..Item.Price)
			lbl:DockMargin(10,0,5,0)
			lbl:Dock(TOP)
			lbl:SetTextColor(Color(155,200,155))
			lbl:SetFont("ZB_TDM_DESC")
			lbl:SetSize(ScrW()*0.5,ScrH()*0.02)

			local BuyBtn = vgui.Create("DButton", ItemButton)
			BuyBtn:DockMargin(10,5,10,10)
			BuyBtn:Dock(LEFT)
			BuyBtn:SetText("Buy")
			BuyBtn:SetTextColor(Color(200,200,200))
			BuyBtn:SetFont("ZB_TDM_DESC")
			BuyBtn:SetHeight(ScrH()*0.025)
			BuyBtn.Paint = PaintPanel
			BuyBtn.Item = {k,n}

			function BuyBtn:DoClick()
				net.Start("tdm_buyitem")
					net.WriteTable(self.Item)
				net.SendToServer()
			end
			
			if weapon then
				local ammo = weapon.Primary.Ammo != "none" and weapon.Primary.Ammo or weapon.Ammo or (weapons.GetStored( weapon.Base ) and weapons.GetStored( weapon.Base ).Primary.Ammo)
				
				if hg.ammotypeshuy[ammo] then
					local amm = vgui.Create( "DButton", ItemButton)
					amm:DockMargin(10,5,10,10)
					amm:Dock(LEFT)
					amm:SetText(ammo)
					amm:SetTextColor(Color(200,200,200))
					amm:SetFont("ZB_TDM_DESCSMALL")
					
					surface.SetFont("ZB_TDM_DESCSMALL")
					local w, h = surface.GetTextSize(ammo)

					amm:SetHeight(ScrH()*0.025)
					amm:SetWidth(w + 7)
					local ammo2 = "ent_ammo_"..hg.ammotypeshuy[ammo].name
					local name
					for name2, ammo in pairs(MODE.BuyItems["Ammo"]) do
						if not istable(ammo) then continue end
						if ammo.ItemClass == ammo2 then
							name = name2
						end
					end
					
					amm.huy = {"Ammo", name}

					function amm:DoClick()
						net.Start("tdm_buyitem")
							net.WriteTable(amm.huy)
						net.SendToServer()
					end

					amm.Paint = PaintPanel
				end
			end

			if Item.Attachments and #Item.Attachments > 0 then
				local ItemAtt = vgui.Create("DGrid",ItemPanel)
				ItemAtt:Dock(RIGHT)
				ItemAtt:DockMargin(0,5,0,0)
				ItemAtt:SetCols( 4 )
				ItemAtt:SetColWide(50)
				ItemAtt:SetRowHeight(50)
				ItemAtt.Paint = function() end
				for id,AttachN in pairs(Item.Attachments) do
					local ico = hg.attachmentsIcons[AttachN]
					local Attach = vgui.Create( "DImageButton" )
					Attach:SetImage(ico)
					Attach:SetSize(45,45)

					Attach.Attachment = {k,n,AttachN}

					function Attach:DoClick()
						net.Start("tdm_buyitem")
							net.WriteTable(self.Attachment)
						net.SendToServer()
					end

					Attach.Paint = PaintPanel2
					ItemAtt:AddItem(Attach)
				end
			end
		end
		local tab = Sheet:AddSheet(k,CategoryPanel)
		local rTab = tab["Tab"]
		rTab.Paint = PaintPanel
		rTab:SetFont("ZB_TDM_CATEGORY")
		rTab.ApplySchemeSettings = rtabFunc
		--rTab:SetTextInset(50)
	end

	local StartTime = zb.ROUND_START or CurTime()
	local lbl = vgui.Create("DLabel", Frame)
	lbl:SetText("Time Left: "..string.FormattedTime(StartTime + 40 - CurTime(), "%02i:%02i:%02i"))
	lbl:DockMargin(10,0,10,10)
	lbl:Dock(BOTTOM)
	lbl:SetTextColor(Color(255,255,255))
	lbl:SetFont("ZB_TDM_DESC")
	lbl:SetSize(0,ScrH()*0.015)

	function lbl:Think()
		if not LocalPlayer():Alive() or StartTime + 40 < CurTime() then TDM_OpenedBuyMenu:Remove() end
		self:SetText("Time Left: "..string.FormattedTime(StartTime + 40 - CurTime(), "%02i:%02i:%02i"))
	end

	local lbl = vgui.Create("DLabel", Frame)
	lbl:SetText("Cash: $"..LocalPlayer():GetNWInt("TDM_Money",0))
	lbl:DockMargin(10,5,10,5)
	lbl:Dock(BOTTOM)
	lbl:SetTextColor(Color(61,173,61))
	lbl:SetFont("ZB_TDM_DESC")
	lbl:SetSize(0,ScrH()*0.02)

	function lbl:Think()
		self:SetText("Cash: $"..LocalPlayer():GetNWInt("TDM_Money",0))
	end

end

net.Receive("tdm_open_buymenu",function() OpenBuyMenu() end)
TDM_OpenedBuyMenu = TDM_OpenedBuyMenu or nil