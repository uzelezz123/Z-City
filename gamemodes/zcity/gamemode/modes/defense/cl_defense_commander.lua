local COMMANDER_UI = {
    BACKGROUND_COLOR = Color(0, 0, 0, 180),
    PRIMARY_COLOR = Color(180, 40, 40), 
    SECONDARY_COLOR = Color(40, 40, 40),
    TEXT_COLOR = Color(255, 255, 255),
    HOVER_COLOR = Color(200, 60, 60), 
    UNAVAILABLE_COLOR = Color(100, 100, 100),
    PANEL_WIDTH = 900,
    PANEL_HEIGHT = 650
}

local iconCache = {}


local iconExtensions = {".vmt", ".png", ".jpg", ".vtf", ""}

local function GetItemIcon(entityName, customIcon)
    if iconCache[entityName] then
        return iconCache[entityName]
    end
    
    local icon = nil
    

    if customIcon then
        for _, ext in ipairs(iconExtensions) do
            local fullPath = "materials/" .. customIcon .. ext
            if file.Exists(fullPath, "GAME") then
                if ext == ".png" then
                    icon = Material(customIcon .. ext, "smooth mips")
                else
                    icon = Material(customIcon)
                end
                break
            end
        end
        
        if not icon and not string.find(customIcon, "materials/") then
            if not string.find(customIcon, "vgui/") then
                local vguiPath = "vgui/entities/" .. customIcon
                for _, ext in ipairs(iconExtensions) do
                    if file.Exists("materials/" .. vguiPath .. ext, "GAME") then
                        icon = Material(vguiPath)
                        break
                    end
                end
            end
        end
    end
    
  
    if not icon or icon:IsError() then
        if weapons.Get(entityName) then
            local weaponData = weapons.Get(entityName)
            if weaponData.IconTexture then
                for _, ext in ipairs(iconExtensions) do
                    if file.Exists("materials/" .. weaponData.IconTexture .. ext, "GAME") then
                        if ext == ".png" then
                            icon = Material(weaponData.IconTexture .. ext, "smooth mips")
                        else
                            icon = Material(weaponData.IconTexture)
                        end
                        break
                    end
                end
            elseif weaponData.WepSelectIcon then
                if type(weaponData.WepSelectIcon) == "number" then
                    icon = Material("vgui/entities/weapon_pistol")
                else
                    icon = weaponData.WepSelectIcon
                end
            end
        elseif scripted_ents.Get(entityName) then
            local entTable = scripted_ents.Get(entityName)
            if entTable.IconTexture then
                for _, ext in ipairs(iconExtensions) do
                    if file.Exists("materials/" .. entTable.IconTexture .. ext, "GAME") then
                        if ext == ".png" then
                            icon = Material(entTable.IconTexture .. ext, "smooth mips")
                        else
                            icon = Material(entTable.IconTexture)
                        end
                        break
                    end
                end
            end
        end
    end
    
    if not icon or icon:IsError() then
        if string.find(entityName, "weapon_") then
            if string.find(entityName, "grenade") or string.find(entityName, "explosive") then
                for _, ext in ipairs(iconExtensions) do
                    if file.Exists("materials/vgui/entities/weapon_frag" .. ext, "GAME") then
                        icon = Material("vgui/entities/weapon_frag" .. (ext == ".png" and ext or ""))
                        break
                    end
                end
                if not icon or icon:IsError() then
                    icon = Material("vgui/entities/weapon_frag")
                end
            else
                for _, ext in ipairs(iconExtensions) do
                    if file.Exists("materials/vgui/entities/weapon_pistol" .. ext, "GAME") then
                        icon = Material("vgui/entities/weapon_pistol" .. (ext == ".png" and ext or ""))
                        break
                    end
                end
                if not icon or icon:IsError() then
                    icon = Material("vgui/entities/weapon_pistol")
                end
            end
        elseif string.find(entityName, "ent_armor_") then
            for _, ext in ipairs(iconExtensions) do
                if file.Exists("materials/vgui/entities/item_item_crate" .. ext, "GAME") then
                    icon = Material("vgui/entities/item_item_crate" .. (ext == ".png" and ext or ""))
                    break
                end
            end
            if not icon or icon:IsError() then
                icon = Material("vgui/entities/item_item_crate")
            end
        elseif string.find(entityName, "ent_ammo_") then
            for _, ext in ipairs(iconExtensions) do
                if file.Exists("materials/vgui/entities/item_ammo_pistol" .. ext, "GAME") then
                    icon = Material("vgui/entities/item_ammo_pistol" .. (ext == ".png" and ext or ""))
                    break
                end
            end
            if not icon or icon:IsError() then
                icon = Material("vgui/entities/item_ammo_pistol")
            end
        elseif entityName == "player_reinforcements" then
            icon = Material("icon16/user_add.png", "smooth mips")
        elseif entityName == "support_team" then
            icon = Material("icon16/group.png", "smooth mips")
        else
            icon = Material("vgui/entities/item_item_crate")
        end
    end
    
    if not icon or icon:IsError() then
        icon = Material("icon16/box.png", "smooth mips")
    end
    
    iconCache[entityName] = icon
    return icon
end


surface.CreateFont("CommanderTitle", {
    font = "Roboto",
    size = 24,
    weight = 700,
    antialias = true,
    shadow = true
})

surface.CreateFont("CommanderCategory", {
    font = "Roboto",
    size = 20,
    weight = 600,
    antialias = true
})

surface.CreateFont("CommanderText", {
    font = "Roboto",
    size = 18,
    weight = 500,
    antialias = true
})

surface.CreateFont("CommanderSmall", {
    font = "Roboto",
    size = 16,
    weight = 400,
    antialias = true
})


surface.CreateFont("CommanderHintText", {
    font = "Roboto",
    size = 19,  
    weight = 600,
    antialias = true,
    shadow = false
})

local commanderMenu = nil
local currentCart = {}
local availableItems = {}


local function DrawBackgroundBlur()
    local x, y = 0, 0
    local scrW, scrH = ScrW(), ScrH()
    
    surface.SetDrawColor(0, 0, 0, 150)
    surface.SetMaterial(Material("pp/blurscreen"))
    
    for i = 1, 5 do
        Material("pp/blurscreen"):SetFloat("$blur", (i / 3) * 4)
        Material("pp/blurscreen"):Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
    end
    

    surface.SetDrawColor(0, 0, 0, 180)
    surface.DrawRect(0, 0, scrW, scrH)
end


local function CalculateCartCost()
    local totalCost = 0
    for _, item in pairs(currentCart) do
        totalCost = totalCost + (item.price * (item.quantity or 1))
    end
    return totalCost
end


local function CreateCloseButton(parent)
    local closeBtn = vgui.Create("DButton", parent)
    closeBtn:SetSize(30, 30)
    closeBtn:SetPos(parent:GetWide() - 40, 10)
    closeBtn:SetText("")
    
    closeBtn.Paint = function(self, w, h)
        local color = self:IsHovered() and COMMANDER_UI.HOVER_COLOR or COMMANDER_UI.PRIMARY_COLOR
        
        
        draw.RoundedBox(15, 0, 0, w, h, color)
        

        surface.SetDrawColor(COMMANDER_UI.TEXT_COLOR)
        surface.DrawLine(8, 8, w-8, h-8)
        surface.DrawLine(8, h-8, w-8, 8)
    end
    
    closeBtn.DoClick = function()
        parent:Close()
        surface.PlaySound("ui/buttonclickrelease.wav")
    end
    
    return closeBtn
end


function CreateCommanderMenu()
    if IsValid(commanderMenu) then commanderMenu:Remove() end
    
    local ply = LocalPlayer()
    local points = ply:GetNWInt("CommanderPoints", 0)
    

    commanderMenu = vgui.Create("ZFrame")
    commanderMenu:SetSize(COMMANDER_UI.PANEL_WIDTH, COMMANDER_UI.PANEL_HEIGHT)
    commanderMenu:Center()
    commanderMenu:SetTitle("")
    commanderMenu:SetDraggable(true)
    commanderMenu:ShowCloseButton(false) 
    commanderMenu:MakePopup()
    

    CreateCloseButton(commanderMenu)
    
    commanderMenu.Paint = function(self, w, h)
        DrawBackgroundBlur(self)
        

        surface.SetDrawColor(COMMANDER_UI.PRIMARY_COLOR)
        surface.DrawRect(0, 0, w, 50)

        surface.SetDrawColor(COMMANDER_UI.BACKGROUND_COLOR)
        surface.DrawRect(0, 50, w, h - 50)
        

        surface.SetDrawColor(COMMANDER_UI.PRIMARY_COLOR)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        
        draw.SimpleText("COMMANDER SUPPLY REQUISITION", "CommanderTitle", w/2, 25, COMMANDER_UI.TEXT_COLOR, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        draw.SimpleText("Available Points: " .. points, "CommanderText", w - 120, 25, COMMANDER_UI.TEXT_COLOR, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end
    

    local categoryPanel = vgui.Create("DPanel", commanderMenu)
    categoryPanel:SetSize(200, COMMANDER_UI.PANEL_HEIGHT - 60)
    categoryPanel:SetPos(10, 55)
    categoryPanel:DockMargin(5, 5, 5, 5)
    categoryPanel.Paint = function(self, w, h)
        surface.SetDrawColor(COMMANDER_UI.SECONDARY_COLOR)
        surface.DrawRect(0, 0, w, h)
        
        surface.SetDrawColor(COMMANDER_UI.PRIMARY_COLOR)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    

    local itemsPanel = vgui.Create("DScrollPanel", commanderMenu)
    itemsPanel:SetSize(COMMANDER_UI.PANEL_WIDTH - 230, COMMANDER_UI.PANEL_HEIGHT - 190)
    itemsPanel:SetPos(220, 55)
    itemsPanel:DockMargin(5, 5, 5, 5)
    

    local scrollBar = itemsPanel:GetVBar()
    scrollBar:SetWide(12)
    scrollBar.btnUp:SetVisible(false)
    scrollBar.btnDown:SetVisible(false)
    
    function scrollBar:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(40, 40, 40, 200))
    end
    
    function scrollBar.btnGrip:Paint(w, h)
        draw.RoundedBox(6, 2, 0, w-4, h, COMMANDER_UI.PRIMARY_COLOR)
    end
    
    itemsPanel.Paint = function(self, w, h)
        surface.SetDrawColor(COMMANDER_UI.SECONDARY_COLOR)
        surface.DrawRect(0, 0, w, h)
        
        surface.SetDrawColor(COMMANDER_UI.PRIMARY_COLOR)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    

    local cartPanel = vgui.Create("DPanel", commanderMenu)
    cartPanel:SetSize(COMMANDER_UI.PANEL_WIDTH - 230, 120)
    cartPanel:SetPos(220, COMMANDER_UI.PANEL_HEIGHT - 130)
    cartPanel:DockMargin(5, 5, 5, 5)
    cartPanel.Paint = function(self, w, h)
        surface.SetDrawColor(COMMANDER_UI.SECONDARY_COLOR)
        surface.DrawRect(0, 0, w, h)
        
        surface.SetDrawColor(COMMANDER_UI.PRIMARY_COLOR)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        
        draw.SimpleText("YOUR ORDER", "CommanderCategory", 10, 10, COMMANDER_UI.TEXT_COLOR, TEXT_ALIGN_LEFT)
        
        local totalCost = CalculateCartCost()
        draw.SimpleText("Total Cost: " .. totalCost .. " points", "CommanderText", w - 10, 10, COMMANDER_UI.TEXT_COLOR, TEXT_ALIGN_RIGHT)
    end
    

    local cartList = vgui.Create("DScrollPanel", cartPanel)
    cartList:SetSize(COMMANDER_UI.PANEL_WIDTH - 250, 70)
    cartList:SetPos(10, 40)
    cartList:DockMargin(5, 5, 5, 5)
    

    local cartScrollBar = cartList:GetVBar()
    cartScrollBar:SetWide(12)
    cartScrollBar.btnUp:SetVisible(false)
    cartScrollBar.btnDown:SetVisible(false)
    
    function cartScrollBar:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(40, 40, 40, 200))
    end
    
    function cartScrollBar.btnGrip:Paint(w, h)
        draw.RoundedBox(6, 2, 0, w-4, h, COMMANDER_UI.PRIMARY_COLOR)
    end
    
    local cartFlow = vgui.Create("DIconLayout", cartList)
    cartFlow:SetSize(cartList:GetWide(), cartList:GetTall())
    cartFlow:SetSpaceX(10)
    cartFlow:SetSpaceY(5)
    cartFlow:DockMargin(5, 5, 5, 5)
    
    local function UpdateCartDisplay()
        cartFlow:Clear()
        
        for i, item in ipairs(currentCart) do
            local cartItem = cartFlow:Add("DPanel")
            cartItem:SetSize(120, 60) 
            cartItem:DockMargin(5, 5, 5, 5)
            cartItem.Paint = function(self, w, h)
                surface.SetDrawColor(50, 50, 50)
                surface.DrawRect(0, 0, w, h)
                surface.SetDrawColor(COMMANDER_UI.PRIMARY_COLOR)
                surface.DrawOutlinedRect(0, 0, w, h, 1)
                

                local iconMat = GetItemIcon(item.entity, item.icon)
                if iconMat and type(iconMat) ~= "number" then
                    surface.SetDrawColor(255, 255, 255)
                    surface.SetMaterial(iconMat)
                    surface.DrawTexturedRect(5, 5, 30, 30)
                end
                
                draw.SimpleText(item.name, "CommanderSmall", w/2 + 10, 15, COMMANDER_UI.TEXT_COLOR, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText(item.price .. " pts x " .. (item.quantity or 1), "CommanderSmall", w/2 + 10, 35, COMMANDER_UI.TEXT_COLOR, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            
            local removeButton = vgui.Create("DButton", cartItem)
            removeButton:SetSize(15, 15)
            removeButton:SetPos(103, 2)
            removeButton:SetText("X")
            removeButton:SetTextColor(COMMANDER_UI.TEXT_COLOR)
            removeButton.Paint = function(self, w, h)
                surface.SetDrawColor(COMMANDER_UI.PRIMARY_COLOR)
                surface.DrawRect(0, 0, w, h)
            end
            removeButton.DoClick = function()
                table.remove(currentCart, i)
                UpdateCartDisplay()
                surface.PlaySound("ui/buttonclickrelease.wav")
            end
            

            local minusButton = vgui.Create("DButton", cartItem)
            minusButton:SetSize(15, 15)
            minusButton:SetPos(45, 40)
            minusButton:SetText("-")
            minusButton:SetTextColor(COMMANDER_UI.TEXT_COLOR)
            minusButton.Paint = function(self, w, h)
                surface.SetDrawColor(self:IsHovered() and COMMANDER_UI.HOVER_COLOR or COMMANDER_UI.PRIMARY_COLOR)
                surface.DrawRect(0, 0, w, h)
            end
            minusButton.DoClick = function()
                if item.quantity and item.quantity > 1 then
                    item.quantity = item.quantity - 1
                    UpdateCartDisplay()
                    surface.PlaySound("ui/buttonclick.wav")
                end
            end
            
            local plusButton = vgui.Create("DButton", cartItem)
            plusButton:SetSize(15, 15)
            plusButton:SetPos(80, 40)
            plusButton:SetText("+")
            plusButton:SetTextColor(COMMANDER_UI.TEXT_COLOR)
            plusButton.Paint = function(self, w, h)
                surface.SetDrawColor(self:IsHovered() and COMMANDER_UI.HOVER_COLOR or COMMANDER_UI.PRIMARY_COLOR)
                surface.DrawRect(0, 0, w, h)
            end
            plusButton.DoClick = function()
                item.quantity = (item.quantity or 1) + 1
                UpdateCartDisplay()
                surface.PlaySound("ui/buttonclick.wav")
            end
        end
    end
    

    local orderButton = vgui.Create("DButton", commanderMenu)
    orderButton:SetSize(200, 40)
    orderButton:SetPos(COMMANDER_UI.PANEL_WIDTH - 220, COMMANDER_UI.PANEL_HEIGHT - 45)
    orderButton:SetText("")
    orderButton:DockMargin(5, 5, 5, 5)
    orderButton.Paint = function(self, w, h)
        local bgColor = self:IsHovered() and COMMANDER_UI.HOVER_COLOR or COMMANDER_UI.PRIMARY_COLOR
        
        if #currentCart == 0 or CalculateCartCost() > points then
            bgColor = COMMANDER_UI.UNAVAILABLE_COLOR
        end
        
        surface.SetDrawColor(bgColor)
        surface.DrawRect(0, 0, w, h)
        
        surface.SetDrawColor(COMMANDER_UI.TEXT_COLOR)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        
        draw.SimpleText("PLACE ORDER", "CommanderText", w/2, h/2, COMMANDER_UI.TEXT_COLOR, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    orderButton.DoClick = function()
        if #currentCart == 0 then return end
        
        local totalCost = CalculateCartCost()
        if totalCost > points then
            chat.AddText(COMMANDER_UI.PRIMARY_COLOR, "Not enough supply points!")
            surface.PlaySound("buttons/button10.wav")
            return
        end
        
        net.Start("defense_commander_purchase")
        net.WriteTable(currentCart)
        net.SendToServer()
        

        currentCart = {}
        UpdateCartDisplay()
        
        surface.PlaySound("items/ammocrate_open.wav")
        commanderMenu:Close()
    end
    

    local function PopulateItems(category)
        itemsPanel:Clear()
        
        if not availableItems[category] then return end
        
        local itemFlow = vgui.Create("DIconLayout", itemsPanel)
        itemFlow:SetSize(itemsPanel:GetWide(), itemsPanel:GetTall())
        itemFlow:SetSpaceY(10)
        itemFlow:DockMargin(5, 5, 5, 5)
        
        for _, item in ipairs(availableItems[category]) do
            local itemButton = itemFlow:Add("DPanel")
            itemButton:SetSize(itemsPanel:GetWide() - 20, 80)
            itemButton:DockMargin(5, 5, 5, 5)
            itemButton.Paint = function(self, w, h)
                surface.SetDrawColor(30, 30, 30)
                surface.DrawRect(0, 0, w, h)
                
                local borderColor = self.Hovered and COMMANDER_UI.HOVER_COLOR or COMMANDER_UI.PRIMARY_COLOR
                

                if item.price > points then
                    borderColor = COMMANDER_UI.UNAVAILABLE_COLOR
                end
                
                surface.SetDrawColor(borderColor)
                surface.DrawOutlinedRect(0, 0, w, h, 1)
                

                local iconMat = GetItemIcon(item.entity, item.icon)
                if iconMat and type(iconMat) ~= "number" then
                    surface.SetDrawColor(255, 255, 255)
                    surface.SetMaterial(iconMat)
                    surface.DrawTexturedRect(10, 10, 60, 60)
                end
                

                draw.SimpleText(item.name, "CommanderText", 80, 20, COMMANDER_UI.TEXT_COLOR, TEXT_ALIGN_LEFT)
                draw.SimpleText(item.price .. " points", "CommanderText", w - 150, 20, COMMANDER_UI.TEXT_COLOR, TEXT_ALIGN_RIGHT)
                

                draw.SimpleText(item.desc, "CommanderSmall", 80, 45, COMMANDER_UI.TEXT_COLOR, TEXT_ALIGN_LEFT)
            end
            

            local quantity = 1
            

            local quantityLabel = vgui.Create("DLabel", itemButton)
            quantityLabel:SetSize(30, 20)
            quantityLabel:SetPos(itemButton:GetWide() - 80, 45)
            quantityLabel:SetText("x1")
            quantityLabel:SetTextColor(COMMANDER_UI.TEXT_COLOR)
            

            local minusBtn = vgui.Create("DButton", itemButton)
            minusBtn:SetSize(20, 20)
            minusBtn:SetPos(itemButton:GetWide() - 110, 45)
            minusBtn:SetText("-")
            minusBtn:SetTextColor(COMMANDER_UI.TEXT_COLOR)
            minusBtn.Paint = function(self, w, h)
                surface.SetDrawColor(self:IsHovered() and COMMANDER_UI.HOVER_COLOR or COMMANDER_UI.PRIMARY_COLOR)
                surface.DrawRect(0, 0, w, h)
            end
            minusBtn.DoClick = function()
                if quantity > 1 then
                    quantity = quantity - 1
                    quantityLabel:SetText("x" .. quantity)
                    surface.PlaySound("ui/buttonclick.wav")
                end
            end
            

            local plusBtn = vgui.Create("DButton", itemButton)
            plusBtn:SetSize(20, 20)
            plusBtn:SetPos(itemButton:GetWide() - 50, 45)
            plusBtn:SetText("+")
            plusBtn:SetTextColor(COMMANDER_UI.TEXT_COLOR)
            plusBtn.Paint = function(self, w, h)
                surface.SetDrawColor(self:IsHovered() and COMMANDER_UI.HOVER_COLOR or COMMANDER_UI.PRIMARY_COLOR)
                surface.DrawRect(0, 0, w, h)
            end
            plusBtn.DoClick = function()
                local maxPossibleItems = math.floor(points / item.price)
                if quantity < maxPossibleItems then
                    quantity = quantity + 1
                    quantityLabel:SetText("x" .. quantity)
                    surface.PlaySound("ui/buttonclick.wav")
                end
            end
            

            local addToCartBtn = vgui.Create("DButton", itemButton)
            addToCartBtn:SetSize(100, 25)
            addToCartBtn:SetPos(itemButton:GetWide() - 110, 15)
            addToCartBtn:SetText("Add to Cart")
            addToCartBtn:SetTextColor(COMMANDER_UI.TEXT_COLOR)
            addToCartBtn:DockMargin(5, 5, 5, 5)
            addToCartBtn.Paint = function(self, w, h)
                local btnColor = self:IsHovered() and COMMANDER_UI.HOVER_COLOR or COMMANDER_UI.PRIMARY_COLOR
                
                if item.price * quantity > points then
                    btnColor = COMMANDER_UI.UNAVAILABLE_COLOR
                end
                
                surface.SetDrawColor(btnColor)
                surface.DrawRect(0, 0, w, h)
                surface.SetDrawColor(COMMANDER_UI.TEXT_COLOR)
                surface.DrawOutlinedRect(0, 0, w, h, 1)
            end
            
            addToCartBtn.DoClick = function()
                if item.price * quantity > points then
                    chat.AddText(COMMANDER_UI.PRIMARY_COLOR, "Not enough supply points for this item!")
                    surface.PlaySound("buttons/button10.wav")
                    return
                end
                

                local existingItemIndex = nil
                for idx, cartItem in ipairs(currentCart) do
                    if cartItem.entity == item.entity then
                        existingItemIndex = idx
                        break
                    end
                end
                
                if existingItemIndex then
                    currentCart[existingItemIndex].quantity = (currentCart[existingItemIndex].quantity or 1) + quantity
                else
                    table.insert(currentCart, {
                        name = item.name,
                        entity = item.entity,
                        price = item.price,
                        quantity = quantity,
                        special = item.special,
                        icon = item.icon
                    })
                end
                
                UpdateCartDisplay()
                surface.PlaySound("ui/buttonclick.wav")
            end
        end
    end
    
    local yPos = 10
    for category, _ in pairs(availableItems) do
        local categoryButton = vgui.Create("DButton", categoryPanel)
        categoryButton:SetSize(180, 40)
        categoryButton:SetPos(10, yPos)
        categoryButton:SetText("")
        categoryButton:DockMargin(5, 5, 5, 5)
        categoryButton.Paint = function(self, w, h)
            local bgColor = self:IsHovered() and COMMANDER_UI.HOVER_COLOR or COMMANDER_UI.PRIMARY_COLOR
            surface.SetDrawColor(bgColor)
            surface.DrawRect(0, 0, w, h)
            
            draw.SimpleText(category, "CommanderText", w/2, h/2, COMMANDER_UI.TEXT_COLOR, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        categoryButton.DoClick = function()
            PopulateItems(category)
            surface.PlaySound("ui/buttonclick.wav")
        end
        
        yPos = yPos + 50
    end
    

    local firstCategory
    for category, _ in pairs(availableItems) do
        firstCategory = category
        break
    end
    
    if firstCategory then
        PopulateItems(firstCategory)
    end
    
    UpdateCartDisplay()
end


net.Receive("defense_commander_menu", function()
    availableItems = net.ReadTable()
    CreateCommanderMenu()
end)


net.Receive("defense_commander_notification", function()
    local message = net.ReadString()
    local pointChange = net.ReadInt(16)
    
    local color = Color(255, 255, 255)
    if pointChange > 0 then
        color = Color(50, 255, 50)
    elseif pointChange < 0 then
        color = Color(255, 50, 50)
    end
    
    chat.AddText(color, message)
    
    if pointChange ~= 0 then
        surface.PlaySound("items/ammo_pickup.wav")
    end
end)


hook.Add("radialOptions", "CommanderSupplyMenu", function()
    local ply = LocalPlayer()
    
    if ply:GetNWString("PlayerRole") == "Commander" and ply:Alive() then
        local points = ply:GetNWInt("CommanderPoints", 0)
        local tbl = {
            function()
                net.Start("defense_commander_menu")
                net.SendToServer()
            end,
            "Order Supplies (" .. points .. " pts)"
        }
        hg.radialOptions[#hg.radialOptions + 1] = tbl
    end
end)


local COMMANDER_HINT = {
    active = false,
    alpha = 0,
    startTime = 0,
    typewriterText = "",
    typewriterIndex = 0,
    typewriterSpeed = 0.025, 
    nextTypewriterTime = 0,
    iconPos = Vector(0, 0, 0),
    targetIconPos = Vector(0, 0, 0),
    text = [[As a Commander, you are responsible for supporting your team!  
    
Use the Q-menu to order equipment and support for your soldiers.

You get supply points after each wave. Use them wisely!

Your team relies on your leadership and tactical decisions!]]
}


if file.Exists("materials/hint/info.png", "GAME") then
    COMMANDER_HINT.iconMaterial = Material("hint/info.png", "noclamp smooth")
else

    COMMANDER_HINT.iconMaterial = Material("icon16/information.png")
end


function CheckAndShowCommanderHint()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    if ply:GetNWString("PlayerRole") == "Commander" and ply:Alive() then
        if not COMMANDER_HINT.shownThisRound then
            ShowCommanderHint()
            COMMANDER_HINT.shownThisRound = true
            --print("[DEFENSE] Showing commander hint")
        end
    end
end


local function ShowCommanderHint()
    COMMANDER_HINT.active = true
    COMMANDER_HINT.alpha = 0
    COMMANDER_HINT.startTime = CurTime()
    COMMANDER_HINT.typewriterText = ""
    COMMANDER_HINT.typewriterIndex = 0
    COMMANDER_HINT.nextTypewriterTime = CurTime()
    
    COMMANDER_HINT.iconPos = Vector(-50, ScrH() * 0.3, 0)
    

    COMMANDER_HINT.targetIconPos = Vector(0, 0, 0) 
    
    COMMANDER_HINT.endTime = nil

    surface.PlaySound("buttons/button24.wav")
    --print("[DEFENSE] Commander hint activated")
end


local function DrawCommanderHint()
    if not COMMANDER_HINT.active then return end
    
    local currentTime = CurTime()
    

    local panelWidth = ScrW() * 0.35  
    local panelHeight = ScrH() * 0.25  
    local panelX = ScrW() * 0.5 - panelWidth * 0.5
    local panelY = ScrH() * 0.15 
    

    if COMMANDER_HINT.targetIconPos.x == 0 then
        COMMANDER_HINT.targetIconPos = Vector(panelX + panelWidth - 36, panelY + 36, 0)
    end
    

    local fadeInTime = 0.8
    if currentTime - COMMANDER_HINT.startTime < fadeInTime then
        COMMANDER_HINT.alpha = math.Clamp((currentTime - COMMANDER_HINT.startTime) / fadeInTime, 0, 1) * 230
    else
        COMMANDER_HINT.alpha = 230
    end
    

    if COMMANDER_HINT.endTime and currentTime > COMMANDER_HINT.endTime then
        local fadeOutProgress = (currentTime - COMMANDER_HINT.endTime) / 1.5
        COMMANDER_HINT.alpha = 230 * (1 - fadeOutProgress)
        
        if fadeOutProgress >= 1 then
            COMMANDER_HINT.active = false
            return
        end
    end
    

    surface.SetDrawColor(10, 10, 10, COMMANDER_HINT.alpha)
    surface.DrawRect(panelX, panelY, panelWidth, panelHeight)
    
    surface.SetDrawColor(COMMANDER_UI.PRIMARY_COLOR.r, COMMANDER_UI.PRIMARY_COLOR.g, COMMANDER_UI.PRIMARY_COLOR.b, COMMANDER_HINT.alpha)
    surface.DrawOutlinedRect(panelX, panelY, panelWidth, panelHeight, 3)  
    
    local iconAnimSpeed = 0.1
    COMMANDER_HINT.iconPos.x = Lerp(iconAnimSpeed, COMMANDER_HINT.iconPos.x, COMMANDER_HINT.targetIconPos.x)
    COMMANDER_HINT.iconPos.y = Lerp(iconAnimSpeed, COMMANDER_HINT.iconPos.y, COMMANDER_HINT.targetIconPos.y)
    

    local iconSize = 48  
    local iconAlpha = math.min(COMMANDER_HINT.alpha, 255)
    surface.SetDrawColor(255, 255, 255, iconAlpha)
    surface.SetMaterial(COMMANDER_HINT.iconMaterial)
    surface.DrawTexturedRect(COMMANDER_HINT.iconPos.x - iconSize/2, COMMANDER_HINT.iconPos.y - iconSize/2, iconSize, iconSize)
    

    if COMMANDER_HINT.typewriterIndex < string.len(COMMANDER_HINT.text) and currentTime >= COMMANDER_HINT.nextTypewriterTime then
        COMMANDER_HINT.typewriterIndex = COMMANDER_HINT.typewriterIndex + 1
        COMMANDER_HINT.typewriterText = string.sub(COMMANDER_HINT.text, 1, COMMANDER_HINT.typewriterIndex)
        COMMANDER_HINT.nextTypewriterTime = currentTime + COMMANDER_HINT.typewriterSpeed
        

        if math.random(1, 3) == 1 then 
            surface.PlaySound("ui/buttonclick.wav")
        end
    end
    
    if COMMANDER_HINT.typewriterIndex == string.len(COMMANDER_HINT.text) and not COMMANDER_HINT.endTime then
        COMMANDER_HINT.endTime = currentTime + 5 
    end
    

    draw.DrawText(COMMANDER_HINT.typewriterText, "CommanderHintText", panelX + 25, panelY + 25, 
                 Color(255, 255, 255, COMMANDER_HINT.alpha), TEXT_ALIGN_LEFT)
end


hook.Add("HUDPaint", "DrawCommanderHint", DrawCommanderHint)


hook.Add("OnEntityCreated", "CheckCommanderForHint", function(ent)
    if not IsValid(ent) then return end
    if not ent:IsPlayer() then return end
    
    timer.Simple(1, function()
        if not IsValid(ent) then return end
        if ent ~= LocalPlayer() then return end
        
        if ent:GetNWString("PlayerRole") == "Commander" and ent:Alive() then
            if not COMMANDER_HINT.shownThisRound then
                ShowCommanderHint()
                COMMANDER_HINT.shownThisRound = true
            end
        end
    end)
end)

hook.Add("InitPostEntity", "ResetCommanderHintFlag", function()
    COMMANDER_HINT.shownThisRound = false
end)

net.Receive("npc_defense_start", function()
    COMMANDER_HINT.shownThisRound = false
end)


hook.Add("OnPlayerSpawn", "CheckPlayerCommanderRole", function(ply)
    if not IsValid(ply) then return end
    if ply ~= LocalPlayer() then return end
    
    timer.Simple(1, function()
        if not IsValid(ply) then return end
        if ply:GetNWString("PlayerRole") == "Commander" and ply:Alive() then
            if not COMMANDER_HINT.shownThisRound then
                ShowCommanderHint()
                COMMANDER_HINT.shownThisRound = true
            end
        end
    end)
end)

hook.Add("InitPostEntity", "InitCommanderHint", function()
    COMMANDER_HINT.shownThisRound = false
    timer.Simple(2, CheckAndShowCommanderHint)
end)


hook.Add("HUDPaint", "CheckForCommanderStatus", function()
    if not COMMANDER_HINT.haveCheckedInitially then
        timer.Simple(5, function()
            CheckAndShowCommanderHint()
            COMMANDER_HINT.haveCheckedInitially = true
        end)
    end
end)


timer.Create("CommanderHintChecker", 1, 0, function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    

    if ply:GetNWString("PlayerRole") == "Commander" and ply:Alive() and not COMMANDER_HINT.shownThisRound then
        ShowCommanderHint()
        COMMANDER_HINT.shownThisRound = true
        print("[DEFENSE] Commander hint triggered by timer")
    end
end)


net.Receive("npc_defense_start", function()
    COMMANDER_HINT.shownThisRound = false
    timer.Simple(2, CheckAndShowCommanderHint)
    print("[DEFENSE] Reset hint status on defense start")
end)

net.Receive("npc_defense_prepphase", function()
    timer.Simple(1, CheckAndShowCommanderHint)
    print("[DEFENSE] Checking hint on prep phase")
end)


hook.Add("OnLocalPlayerRoleChanged", "CheckCommanderRoleChange", function(oldRole, newRole)
    if newRole == "Commander" and not COMMANDER_HINT.shownThisRound then
        ShowCommanderHint()
        COMMANDER_HINT.shownThisRound = true
        --print("[DEFENSE] Commander hint triggered by role change")
    end
end)


concommand.Add("defense_show_hint", function()
    ShowCommanderHint()
    --print("[DEFENSE] Commander hint triggered by console command")
end)
