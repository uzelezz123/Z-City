MODE.name = "event"

local MODE = MODE

local radius = nil
local mapsize = 7500

local EventersList = {}

ZonePos = ZonePos or Vector(0,0,0)

local roundend = false

net.Receive("event_start",function()
    roundend = false
    zb.RemoveFade()
end)


net.Receive("event_eventers_update", function()
    EventersList = {}
    local data = net.ReadTable()
    for _, id in ipairs(data) do
        EventersList[id] = true
    end
end)

local fighter = {
    color1 = Color(0,120,190)
}

local eventer = {
    color1 = Color(50,200,50)
}

local mat = Material("hmcd_dmzone")

local mapsize = 7500

function MODE:RenderScreenspaceEffects()
	
    if zb.ROUND_START + 7.5 < CurTime() then return end
	
    local fade = math.Clamp(zb.ROUND_START + 7.5 - CurTime(),0,1)

    surface.SetDrawColor(0,0,0,255 * fade)
    surface.DrawRect(-1,-1,ScrW() + 1,ScrH() + 1)
end

function MODE:HUDPaint()
	 
	if not lply:Alive() then return end
    if zb.ROUND_START + 8.5 < CurTime() then return end
	zb.RemoveFade()
    local fade = math.Clamp(zb.ROUND_START + 8 - CurTime(),0,1)

    local eventname = GetGlobalString("ZB_EventName","Event")
    draw.SimpleText("ZCity | "..eventname, "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.1, Color(0,162,255, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    

    local isEventer = EventersList[LocalPlayer():SteamID()]
    local Rolename = isEventer and "Eventer" or GetGlobalString("ZB_EventRole","Player")
    local ColorRole = isEventer and eventer.color1 or fighter.color1
    ColorRole.a = 255 * fade
    draw.SimpleText("You are a "..Rolename , "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.5, ColorRole, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    local Objective = GetGlobalString("ZB_EventObjective","")
    local ColorObj = isEventer and eventer.color1 or fighter.color1
    ColorObj.a = 255 * fade
    draw.SimpleText( Objective, "ZB_HomicideMedium", sw * 0.5, sh * 0.9, ColorObj, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local CreateEndMenu = nil
local wonply = nil

net.Receive("event_end",function()
	local ent = net.ReadEntity()
	wonply = nil
	if IsValid(ent) then
		ent.won = true
		wonply = ent
	end
	
	roundend = CurTime()
	
    CreateEndMenu()
end)

local colGray = Color(85,85,85,255)
local colRed = Color(217,201,99)
local colRedUp = Color(207,181,59)

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

    hmcdEndMenu.PaintOver = function(self,w,h)

		local txt = (wonply and wonply:GetPlayerName() or "Nobody").." won!"
		surface.SetFont( "ZB_InterfaceMediumLarge" )
		surface.SetTextColor(col.r,col.g,col.b,col.a)
		local lengthX, lengthY = surface.GetTextSize(txt)
		surface.SetTextPos(w / 2 - lengthX/2,20)
		surface.DrawText(txt)
	end
	
	local DScrollPanel = vgui.Create("DScrollPanel", hmcdEndMenu)
	DScrollPanel:SetPos(10, 80)
	DScrollPanel:SetSize(sizeX - 20, sizeY - 90)

	for i,ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end
		local but = vgui.Create("DButton",DScrollPanel)
		but:SetSize(100,50)
		but:Dock(TOP)
		but:DockMargin( 8, 6, 8, -1 )
		but:SetText("")
		but.Paint = function(self,w,h)
			local col1 = (ply.won and colRed) or (ply:Alive() and colBlue) or colGray
            local col2 = (ply.won and colRedUp) or (ply:Alive() and colBlueUp) or colSpect1
			
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
    for i,ply in player.Iterator() do
		ply.won = nil
    end

    if IsValid(hmcdEndMenu) then
        hmcdEndMenu:Remove()
        hmcdEndMenu = nil
    end
end


local eventLootTable = {}



local function CreateLootPollingMenu()
    if IsValid(LootPollingMenu) then
        LootPollingMenu:Remove()
    end
    
    local serverName = GetHostName()
    local themeColor = Color(10, 10, 160)
    local accentColor = Color(40, 40, 160)
    local textColor = Color(255, 255, 255)
    
    Dynamic = 0
    LootPollingMenu = vgui.Create("ZFrame")
    LootPollingMenu:SetTitle("Event Loot Manager")
    LootPollingMenu:SetSize(700, 550)
    LootPollingMenu:Center()
    LootPollingMenu:MakePopup()
    LootPollingMenu:SetKeyboardInputEnabled(true)
    LootPollingMenu:ShowCloseButton(true)
    
    LootPollingMenu.Paint= function(self, w, h)
        
        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawRect(0, 0, w, h)
        
        surface.SetDrawColor(accentColor.r, accentColor.g, accentColor.b, 128)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        
        surface.SetFont("ZB_InterfaceMedium")
        surface.SetTextColor(textColor.r, textColor.g, textColor.b, textColor.a)
        local text = "Event Loot Settings - " .. serverName
        local textW, textH = surface.GetTextSize(text)
        surface.SetTextPos(w/2 - textW/2, 10)
        surface.DrawText(text)
    end
    
    local itemList = vgui.Create("DListView", LootPollingMenu)
    itemList:SetPos(20, 50)
    itemList:SetSize(660, 300)
    itemList:SetMultiSelect(false)
    itemList:AddColumn("Weight").Width = 80
    itemList:AddColumn("Item Class").Width = 580
    
    itemList.Paint = function(self, w, h)
        surface.SetDrawColor(30, 30, 40, 200)
        surface.DrawRect(0, 0, w, h)
        
        surface.SetDrawColor(accentColor.r, accentColor.g, accentColor.b, 100)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    
    function LootPollingMenu:RefreshItems()
        itemList:Clear()
        
        for i, item in ipairs(eventLootTable) do
            local weight = item[1]
            local class = item[2]
            
            local line = itemList:AddLine(weight, class)
            line.ItemIndex = i
            
            line.Paint = function(self, w, h)
                if self:IsSelected() then
                    surface.SetDrawColor(themeColor.r, themeColor.g, themeColor.b, 150)
                    surface.DrawRect(0, 0, w, h)
                elseif self:IsHovered() then
                    surface.SetDrawColor(themeColor.r, themeColor.g, themeColor.b, 50)
                    surface.DrawRect(0, 0, w, h)
                else
                    if i % 2 == 0 then
                        surface.SetDrawColor(30, 30, 40, 100)
                    else
                        surface.SetDrawColor(40, 40, 50, 100)
                    end
                    surface.DrawRect(0, 0, w, h)
                end
            end
        end
    end
    
    local controlPanel = vgui.Create("DPanel", LootPollingMenu)
    controlPanel:SetPos(20, 370)
    controlPanel:SetSize(660, 70)
    controlPanel.Paint = function(self, w, h)
        surface.SetDrawColor(30, 30, 40, 200)
        surface.DrawRect(0, 0, w, h)
        
        surface.SetDrawColor(accentColor.r, accentColor.g, accentColor.b, 100)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    
    local weightLabel = vgui.Create("DLabel", controlPanel)
    weightLabel:SetPos(15, 10)
    weightLabel:SetText("Weight (Chance):")
    weightLabel:SetTextColor(textColor)
    weightLabel:SizeToContents()
    
    local weightEntry = vgui.Create("DNumberWang", controlPanel)
    weightEntry:SetPos(15, 35)
    weightEntry:SetSize(60, 25)
    weightEntry:SetMinMax(1, 100)
    weightEntry:SetValue(5)
    
    local classLabel = vgui.Create("DLabel", controlPanel)
    classLabel:SetPos(90, 10)
    classLabel:SetText("Item Class:")
    classLabel:SetTextColor(textColor)
    classLabel:SizeToContents()
    
    local classEntry = vgui.Create("DTextEntry", controlPanel)
    classEntry:SetPos(90, 35)
    classEntry:SetSize(380, 25)
    classEntry:SetPlaceholderText("weapon_name or prop_physics")
    
    local addButton = vgui.Create("DButton", controlPanel)
    addButton:SetPos(480, 35)
    addButton:SetSize(100, 25)
    addButton:SetText("Add Item")
    addButton:SetTextColor(textColor)
    addButton.Paint = function(self, w, h)
        if self:IsHovered() then
            surface.SetDrawColor(themeColor.r, themeColor.g, themeColor.b, 200)
        else
            surface.SetDrawColor(themeColor.r, themeColor.g, themeColor.b, 150)
        end
        surface.DrawRect(0, 0, w, h)
        
        surface.SetDrawColor(accentColor.r, accentColor.g, accentColor.b, 200)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    
    addButton.DoClick = function()
        local weight = weightEntry:GetValue()
        local class = classEntry:GetValue()
        
        if weight <= 0 or class == "" then
            notification.AddLegacy("Please specify weight and item class", NOTIFY_ERROR, 3)
            return
        end
        
        net.Start("event_loot_add")
        net.WriteTable({
            weight = weight,
            class = class
        })
        net.SendToServer()
        
        surface.PlaySound("buttons/button14.wav")
    end
    
    local buttonPanel = vgui.Create("DPanel", LootPollingMenu)
    buttonPanel:SetPos(20, 460)
    buttonPanel:SetSize(660, 70)
    buttonPanel.Paint = function(self, w, h)
        surface.SetDrawColor(30, 30, 40, 200)
        surface.DrawRect(0, 0, w, h)
        
        surface.SetDrawColor(accentColor.r, accentColor.g, accentColor.b, 100)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    
    local createButton = function(parent, x, y, w, h, text, color, hoverColor, clickFunc)
        local btn = vgui.Create("DButton", parent)
        btn:SetPos(x, y)
        btn:SetSize(w, h)
        btn:SetText(text)
        btn:SetTextColor(textColor)
        btn.Paint = function(self, width, height)
            if self:IsHovered() then
                surface.SetDrawColor(hoverColor.r, hoverColor.g, hoverColor.b, 200)
            else
                surface.SetDrawColor(color.r, color.g, color.b, 150)
            end
            surface.DrawRect(0, 0, width, height)
            
            surface.SetDrawColor(hoverColor.r, hoverColor.g, hoverColor.b, 200)
            surface.DrawOutlinedRect(0, 0, width, height, 1)
        end
        btn.DoClick = function()
            clickFunc()
            surface.PlaySound("buttons/button14.wav")
        end
        return btn
    end
    
    local removeButton = createButton(buttonPanel, 15, 20, 140, 30, "Remove Selected", 
        Color(180, 10, 10), Color(220, 30, 30),
        function()
            local selected = itemList:GetSelectedLine()
            if not selected then return end
            
            local line = itemList:GetLine(selected)
            if not line or not line.ItemIndex then return end
            
            net.Start("event_loot_remove")
            net.WriteUInt(line.ItemIndex, 16)
            net.SendToServer()
        end
    )
    
    local resetButton = createButton(buttonPanel, 505, 20, 140, 30, "Reset All", 
        Color(180, 10, 10), Color(220, 30, 30),
        function()
            if not LocalPlayer():IsAdmin() and not EventersList[LocalPlayer():SteamID()] then return end
            
            Derma_Query(
                "Are you sure you want to reset the entire loot table?",
                "Confirmation",
                "Yes", function()
                    RunConsoleCommand("zb_event_loot_reset")
                end,
                "No", function() end
            )
        end
    )
    
    local specialButton = createButton(buttonPanel, 165, 20, 160, 30, "Select from List", 
        Color(80, 80, 160), Color(100, 100, 190),
        function()
            local menu = DermaMenu()
            menu:SetSkin("Default")
            
            local weaponSubMenu = menu:AddSubMenu("Weapons")
            weaponSubMenu:AddOption("Pistol (USP)", function() classEntry:SetValue("weapon_hk_usp") end)
            weaponSubMenu:AddOption("Revolver", function() classEntry:SetValue("weapon_revolver357") end)
            weaponSubMenu:AddOption("Desert Eagle", function() classEntry:SetValue("weapon_deagle") end)
            weaponSubMenu:AddOption("Shotgun", function() classEntry:SetValue("weapon_remington870") end)
            weaponSubMenu:AddOption("MP5", function() classEntry:SetValue("weapon_mp5") end)
            weaponSubMenu:AddOption("AKM", function() classEntry:SetValue("weapon_akm") end)
            weaponSubMenu:AddOption("Sniper Rifle", function() classEntry:SetValue("weapon_m98b") end)
            
            local meleeSubMenu = menu:AddSubMenu("Melee")
            meleeSubMenu:AddOption("Lead Pipe", function() classEntry:SetValue("weapon_leadpipe") end)
            meleeSubMenu:AddOption("Crowbar", function() classEntry:SetValue("weapon_hg_crowbar") end)
            meleeSubMenu:AddOption("Axe", function() classEntry:SetValue("weapon_hg_axe") end)
            meleeSubMenu:AddOption("Machete", function() classEntry:SetValue("weapon_hatchet") end)
            
            local explosiveSubMenu = menu:AddSubMenu("Explosives")
            explosiveSubMenu:AddOption("Molotov Cocktail", function() classEntry:SetValue("weapon_hg_molotov_tpik") end)
            explosiveSubMenu:AddOption("Grenade", function() classEntry:SetValue("weapon_hg_f1_tpik") end)
            explosiveSubMenu:AddOption("RPG", function() classEntry:SetValue("weapon_hg_rpg") end)
            
            local armorSubMenu = menu:AddSubMenu("Armor")
            armorSubMenu:AddOption("Vest", function() classEntry:SetValue("ent_armor_vest3") end)
            armorSubMenu:AddOption("Helmet", function() classEntry:SetValue("ent_armor_helmet1") end)
            
            local specialSubMenu = menu:AddSubMenu("Special Items")
            specialSubMenu:AddOption("Ammo (Random)", function() classEntry:SetValue("*ammo*") end)
            
            menu:Open()
        end
    )
    
    local healButton = createButton(buttonPanel, 335, 20, 160, 30, "Medical", 
        Color(80, 160, 80), Color(100, 190, 100),
        function()
            local menu = DermaMenu()
            menu:SetSkin("Default")
            menu:AddOption("Medkit", function() classEntry:SetValue("weapon_medkit_sh") end)
            menu:AddOption("Bandages", function() classEntry:SetValue("weapon_bandage_sh") end)
            menu:AddOption("Painkillers", function() classEntry:SetValue("weapon_painkillers") end)
            menu:Open()
        end
    )
    
    local infoLabel = vgui.Create("DLabel", LootPollingMenu)
    infoLabel:SetPos(350, 535)
    infoLabel:SetText("Loot table is automatically saved")
    infoLabel:SetTextColor(Color(180, 180, 180))
    infoLabel:SizeToContents()
    
    LootPollingMenu:RefreshItems()
    
    return LootPollingMenu
end


net.Receive("event_loot_sync", function()
    eventLootTable = net.ReadTable()

    if IsValid(LootPollingMenu) then
        LootPollingMenu:RefreshItems()
    end
end)



concommand.Add("zb_event_loot_menu", function()
    RunConsoleCommand("zb_event_lootpoll")
end)


net.Receive("event_loot_request", function()
    CreateLootPollingMenu()
end)