--[[
    ZCity Appearance Mod
    Çŕěĺí˙ĺň ńňŕíäŕđňíűĺ âűďŕäŕţůčĺ ěĺíţ âűáîđŕ îäĺćäű íŕ ďŕíĺëč ń čęîíęŕěč.
    Ďîëíîńňüţ ńîâěĺńňčě ń îđčăčíŕëüíűě cl_appearance_editor.lua – íĺ ňđĺáóĺň ĺăî çŕěĺíű.
]]

-- Óáĺäčěń˙, ÷ňî îńíîâíŕ˙ ňŕáëčöŕ ńóůĺńňâóĺň
hg.Appearance = hg.Appearance or {}

-----------------------------------------------------------------------
-- 1. Öâĺňŕ č âńďîěîăŕňĺëüíűĺ ôóíęöčč (čç âŕřĺăî ôŕéëŕ)
-----------------------------------------------------------------------
local colors = {}
colors.secondary = Color(25,25,35,195)
colors.mainText = Color(255,255,255,255)
colors.secondaryText = Color(45,45,45,125)
colors.selectionBG = Color(20,130,25,225)
colors.highlightText = Color(120,35,35)
colors.presetBG = Color(35,35,45,220)
colors.presetBorder = Color(80,80,100,255)
colors.presetHover = Color(50,50,65,240)
colors.scrollbarBG = Color(20,20,30,200)
colors.scrollbarGrip = Color(70,70,90,255)
colors.scrollbarGripHover = Color(100,100,130,255)
colors.scrollbarBorder = Color(100,100,120,200)
colors.previewBorder = Color(255,200,50,255)

local clr_ico = Color(30, 30, 40, 255)
local clr_menu = Color(15, 15, 20, 250)

local scrollPositions = {}

local function ApplyBaseAppearanceButtonStyle(btn)
    if not IsValid(btn) then return end
    btn:SetFont("ZCity_Tiny")
    function btn:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, colors.secondary)
        surface.SetDrawColor(colors.scrollbarBorder)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
end

-- Ôóíęöč˙ ńîçäŕíč˙ ńňčëčçîâŕííîăî ńęđîëëŕ (ĺńëč ĺ¸ íĺň â îđčăčíŕëĺ)
if not CreateStyledScrollPanel then
    function CreateStyledScrollPanel(parent)
        local scroll = vgui.Create("DScrollPanel", parent)
        local sbar = scroll:GetVBar()
        sbar:SetWide(ScreenScale(4))
        sbar:SetHideButtons(true)
        function sbar:Paint(w, h)
            draw.RoundedBox(4, 0, 0, w, h, colors.scrollbarBG)
            surface.SetDrawColor(colors.scrollbarBorder)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
        end
        function sbar.btnGrip:Paint(w, h)
            local col = self:IsHovered() and colors.scrollbarGripHover or colors.scrollbarGrip
            draw.RoundedBox(4, 2, 2, w - 4, h - 4, col)
            surface.SetDrawColor(colors.scrollbarBorder)
            surface.DrawOutlinedRect(2, 2, w - 4, h - 4, 1)
        end
        return scroll
    end
end

-----------------------------------------------------------------------
-- 2. Ôóíęöč˙ ńîçäŕíč˙ ěĺíţ ń čęîíęŕěč (čç âŕřĺăî ôŕéëŕ)
-----------------------------------------------------------------------
local function CreateClothesIconMenu(parent, title, clothesTable, sex, currentSelection, onSelect, showColorPicker, partName, currentModelName, currentModelPath, appearanceTable, onClose, scrollKey)
    local menu = vgui.Create("DFrame")
    menu:SetTitle(title or "Select Clothing")
    menu:SetSize(ScreenScale(226), ScreenScale(220))

    -- Ďîçčöčîíčđîâŕíčĺ
    local x, y
    if parent and IsValid(parent) then
        local parentX, parentY = parent:LocalToScreen(0, 0)
        local parentW, parentH = parent:GetSize()
        x = parentX + parentW + ScreenScale(5)
        y = parentY
        if x + menu:GetWide() > ScrW() then
            x = parentX - menu:GetWide() - ScreenScale(5)
        end
        if y + menu:GetTall() > ScrH() then
            y = ScrH() - menu:GetTall() - ScreenScale(5)
        end
    else
        local cx, cy = input.GetCursorPos()
        x, y = cx, cy
    end
    menu:SetPos(x, y)
    menu:MakePopup()
    menu:SetDraggable(false)
    menu:ShowCloseButton(true)

    function menu:OnFocusChanged(gained)
        if not gained then self:Close() end
    end

    function menu:Paint(w, h)
        draw.RoundedBox(8, 0, 0, w, h, clr_menu)
        surface.SetDrawColor(colors.scrollbarBorder)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        draw.RoundedBoxEx(8, 0, 0, w, ScreenScale(10), colors.secondary, true, true, false, false)
        surface.SetDrawColor(colors.scrollbarBorder)
        surface.DrawLine(0, ScreenScale(10), w, ScreenScale(10))
    end

    local scroll = CreateStyledScrollPanel(menu)
    scroll:Dock(FILL)
    scroll:DockMargin(ScreenScale(2), ScreenScale(2), ScreenScale(2), ScreenScale(2))


        -- Âîńńňŕíîâëĺíčĺ ďîçčöčč ńęđîëëŕ
    if scrollKey and scrollPositions[scrollKey] then
        timer.Simple(0.1, function()
            if IsValid(scroll) then
                local vbar = scroll:GetVBar()
                vbar:SetScroll(scrollPositions[scrollKey])
            end
        end)
    end



    -- Ńĺňęŕ 4x
    local grid = vgui.Create("DGrid", scroll)
    grid:Dock(TOP)
    grid:SetCols(4)
    grid:SetColWide(ScreenScale(53))
    grid:SetRowHeight(ScreenScale(56))

    -- Ďŕíĺëü ń ňĺęóůčě âűáîđîě
    local infoPanel = vgui.Create("DPanel", scroll)
    infoPanel:Dock(TOP)
    infoPanel:SetTall(ScreenScale(20))
    infoPanel:DockMargin(0, 0, 0, ScreenScale(4))
    function infoPanel:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(20, 20, 25, 240))
        surface.SetDrawColor(colors.scrollbarBorder)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    local currentLabel = vgui.Create("DLabel", infoPanel)
    currentLabel:Dock(FILL)
    currentLabel:DockMargin(ScreenScale(4), 0, 0, 0)
    currentLabel:SetFont("ZCity_Tiny")
    currentLabel:SetText("Current: " .. (currentSelection or "normal"))
    currentLabel:SetTextColor(colors.mainText)
    currentLabel:SetContentAlignment(4)

    -- Ďŕëčňđŕ öâĺňîâ (ňîëüęî äë˙ main)
    if showColorPicker then
        local colorPanel = vgui.Create("DPanel", scroll)
        colorPanel:Dock(TOP)
        colorPanel:SetTall(ScreenScale(32))
        colorPanel:DockMargin(0, ScreenScale(4), 0, 0)
        function colorPanel:Paint(w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(20, 20, 25, 240))
        end

        local colorLabel = vgui.Create("DLabel", colorPanel)
        colorLabel:SetPos(ScreenScale(4), ScreenScale(6))
        colorLabel:SetFont("ZCity_Tiny")
        colorLabel:SetText("Color:")
        colorLabel:SizeToContents()
        colorLabel:SetTextColor(colors.mainText)

        local colorPickerBtn = vgui.Create("DButton", colorPanel)
        colorPickerBtn:SetPos(ScreenScale(40), ScreenScale(4))
        colorPickerBtn:SetSize(ScreenScale(70), ScreenScale(28))
        colorPickerBtn:SetText("")

        local currentColor = onSelect and onSelect.getCurrentColor and onSelect.getCurrentColor() or Color(255,255,255)

        function colorPickerBtn:Paint(w, h)
            draw.RoundedBox(4, 0, 0, w, h, currentColor)
            local borderCol = self:IsHovered() and Color(255,200,50,255) or colors.scrollbarBorder
            surface.SetDrawColor(borderCol)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
            if self:IsHovered() then
                draw.SimpleText("Change", "ZCity_Tiny", w/2, h/2, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end

        function colorPickerBtn:DoClick()
            local colorMenu = vgui.Create("DFrame")
            colorMenu:SetTitle("Select Color")
            colorMenu:SetSize(ScreenScale(120), ScreenScale(140))
            local x, y = self:LocalToScreen(0, 0)
            x = x + self:GetWide() + ScreenScale(5)
            y = y
            if x + colorMenu:GetWide() > ScrW() then
                x = x - colorMenu:GetWide() - self:GetWide() - ScreenScale(10)
            end
            if y + colorMenu:GetTall() > ScrH() then
                y = ScrH() - colorMenu:GetTall() - ScreenScale(5)
            end
            colorMenu:SetPos(x, y)
            colorMenu:MakePopup()
            colorMenu:SetDraggable(false)

            function colorMenu:OnFocusChanged(gained)
                if not gained then self:Close() end
            end

            function colorMenu:Paint(w, h)
                draw.RoundedBox(8, 0, 0, w, h, Color(15, 15, 20, 250))
                surface.SetDrawColor(colors.scrollbarBorder)
                surface.DrawOutlinedRect(0, 0, w, h, 2)
            end

            local colorMixer = vgui.Create("DColorMixer", colorMenu)
            colorMixer:Dock(FILL)
            colorMixer:DockMargin(ScreenScale(4), ScreenScale(4), ScreenScale(4), ScreenScale(4))
            colorMixer:SetColor(currentColor)

            function colorMixer:ValueChanged(clr)
                currentColor = clr
                if onSelect and onSelect.color then
                    onSelect.color(clr)
                end
                if IsValid(colorPickerBtn) then
                    colorPickerBtn.currentColor = clr
                end
            end

            local closeBtn = vgui.Create("DButton", colorMenu)
            closeBtn:Dock(BOTTOM)
            closeBtn:SetTall(ScreenScale(16))
            closeBtn:DockMargin(ScreenScale(4), 0, ScreenScale(4), ScreenScale(4))
            closeBtn:SetText("Close")
            closeBtn:SetFont("ZCity_Tiny")
            function closeBtn:Paint(w, h)
                draw.RoundedBox(4, 0, 0, w, h, colors.secondary)
                surface.SetDrawColor(colors.scrollbarBorder)
                surface.DrawOutlinedRect(0, 0, w, h, 1)
            end
            function closeBtn:DoClick() colorMenu:Close() end
        end
    end

    -- Ďîëó÷ŕĺě ňĺęóůčĺ ňĺęńňóđű čç appearanceTable
    local currentMaterials = {}
    if appearanceTable and appearanceTable.AClothes then
        for slot, key in pairs(appearanceTable.AClothes) do
            if hg.Appearance.Clothes[sex] and hg.Appearance.Clothes[sex][key] then
                currentMaterials[slot] = hg.Appearance.Clothes[sex][key]
            else
                currentMaterials[slot] = hg.Appearance.Clothes[sex]["normal"]
            end
        end
    else
        local normalPath = hg.Appearance.Clothes[sex] and hg.Appearance.Clothes[sex]["normal"] or ""
        currentMaterials = { main = normalPath, pants = normalPath, boots = normalPath }
    end

    -- Ôóíęöč˙ ńîçäŕíč˙ čęîíęč
    local function CreateClothesIcon(clothesId, clothesPath, partName, modelPath, modelName)
        local ico = vgui.Create("DPanel")
        ico:SetSize(ScreenScale(52), ScreenScale(52))
        ico.ClothesId = clothesId
        ico.bIsHovered = false
        ico.IsSelected = (clothesId == currentSelection)

        local previewModel = vgui.Create("DModelPanel", ico)
        previewModel:Dock(FILL)
        previewModel:DockMargin(2, 2, 2, 2)
        previewModel:SetModel(modelPath)

        -- Íŕńňđîéęŕ ęŕěĺđű â çŕâčńčěîńňč îň ÷ŕńňč ňĺëŕ
        local camPos, lookAt, fov
        if partName == "main" or partName == "jacket" then
            camPos = Vector(70, 0, 40)
            lookAt = Vector(0, 0, 45)
            fov = 25
        elseif partName == "pants" then
            camPos = Vector(70, 0, 20)
            lookAt = Vector(0, 0, 15)
            fov = 30
        elseif partName == "boots" then
            camPos = Vector(60, 0, 5)
            lookAt = Vector(0, 0, 3)
            fov = 25
        end

        previewModel:SetCamPos(camPos)
        previewModel:SetLookAt(lookAt)
        previewModel:SetFOV(fov)
        previewModel:SetDirectionalLight(BOX_RIGHT, Color(255, 0, 0))
        previewModel:SetDirectionalLight(BOX_LEFT, Color(125, 155, 255))
        previewModel:SetDirectionalLight(BOX_FRONT, Color(160, 160, 160))
        previewModel:SetDirectionalLight(BOX_BACK, Color(0, 0, 0))
        previewModel:SetAmbientLight(Color(50, 50, 50))

        function previewModel:PreDrawModel(ent)
            render.SetColorModulation(1, 1, 1)
        end
        function previewModel:PostDrawModel(ent)
            render.SetColorModulation(1, 1, 1)
        end

        function previewModel:LayoutEntity(ent)
            if not IsValid(ent) then return end
            ent:SetSequence(ent:LookupSequence("idle_suitcase"))
            ent:SetAngles(Angle(0, 0, 0))

            local modelData = hg.Appearance.PlayerModels[sex] and hg.Appearance.PlayerModels[sex][modelName]
            if not modelData or not modelData.submatSlots then return end

            local mats = ent:GetMaterials()

            -- Ďđčěĺí˙ĺě ňĺęńňóđó äë˙ ňĺęóůĺăî ńëîňŕ
            local currentSlotMaterialName = modelData.submatSlots[partName]
            if currentSlotMaterialName then
                local slotIndex
                for i, matName in ipairs(mats) do
                    if matName == currentSlotMaterialName then slotIndex = i - 1 break end
                end
                if slotIndex then ent:SetSubMaterial(slotIndex, clothesPath) end
            end

            -- Ďđčěĺí˙ĺě îńňŕëüíűĺ ńëîňű čç currentMaterials
            for slot, matName in pairs(modelData.submatSlots) do
                if slot ~= partName then
                    local slotIndex
                    for i, mName in ipairs(mats) do
                        if mName == matName then slotIndex = i - 1 break end
                    end
                    if slotIndex then
                        local texturePath = currentMaterials[slot] or hg.Appearance.Clothes[sex]["normal"]
                        ent:SetSubMaterial(slotIndex, texturePath)
                    end
                end
            end
            ent:SetColor(Color(255,255,255))
        end

        local nameLabel = vgui.Create("DLabel", ico)
        nameLabel:SetPos(0, ScreenScale(42))
        nameLabel:SetSize(ScreenScale(52), ScreenScale(10))
        nameLabel:SetFont("ZCity_Tiny")
        nameLabel:SetText(string.NiceName(clothesId))
        nameLabel:SetTextColor(colors.mainText)
        nameLabel:SetContentAlignment(5)
        nameLabel:SetExpensiveShadow(1, Color(0,0,0,200))

        function previewModel:DoClick()
            if onSelect and onSelect.clothes then
                onSelect.clothes(clothesId)
            end
            surface.PlaySound("player/clothes_generic_foley_0"..math.random(5)..".wav")
            menu:Close()
        end

        function ico:Paint(w, h)
            local bgColor = self.IsSelected and Color(40, 140, 45, 255) or clr_ico
            draw.RoundedBox(4, 0, 0, w, h, bgColor)
            local borderCol = self.bIsHovered and Color(255,200,50,255) or colors.scrollbarBorder
            surface.SetDrawColor(borderCol)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
        end

        function ico:Think()
            self.bIsHovered = vgui.GetHoveredPanel() == self or vgui.GetHoveredPanel() == previewModel
            self.IsSelected = (clothesId == currentSelection)
        end

        return ico
    end

    -- Äîáŕâë˙ĺě âńĺ ďđĺäěĺňű â ńĺňęó
    for clothesId, clothesPath in SortedPairs(clothesTable) do
        local icon = CreateClothesIcon(clothesId, clothesPath, partName, currentModelPath, currentModelName)
        grid:AddItem(icon)
    end

    -- Đŕçäĺëčňĺëü
    local separator = vgui.Create("DPanel", scroll)
    separator:Dock(TOP)
    separator:SetTall(ScreenScale(2))
    separator:DockMargin(0, ScreenScale(4), 0, ScreenScale(2))
    function separator:Paint(w, h)
        surface.SetDrawColor(colors.scrollbarBorder)
        surface.DrawRect(0, 0, w, h)
    end

    -- Ęíîďęŕ None
    local noneButton = vgui.Create("DButton", scroll)
    noneButton:Dock(TOP)
    noneButton:SetTall(ScreenScale(24))
    noneButton:SetText("")
    function noneButton:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 50, 240))
        surface.SetDrawColor(colors.scrollbarBorder)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        draw.SimpleText("None (Reset)", "ZCity_Tiny", w/2, h/2, colors.mainText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    function noneButton:DoClick()
        if onSelect and onSelect.clothes then
            onSelect.clothes("normal")
        end
        surface.PlaySound("player/clothes_generic_foley_0"..math.random(5)..".wav")
        menu:Close()
    end



     -- Ńîőđŕíĺíčĺ ďîçčöčč ďđč çŕęđűňčč
    function menu:OnClose()
        if scrollKey and IsValid(scroll) then
            local vbar = scroll:GetVBar()
            scrollPositions[scrollKey] = vbar:GetScroll()
        end
        -- Ĺńëč ĺńňü âíĺříčé onClose, âűçűâŕĺě ĺăî
        if onClose then onClose() end
    end





    return menu
end



-----------------------------------------------------------------------
-- Ôóíęöč˙ ńîçäŕíč˙ ěĺíţ äë˙ Facemap
-----------------------------------------------------------------------
local function CreateFacemapIconMenu(parent, title, combinedVariants, sortedNames, sex, currentSelection, onSelect, partName, currentModelName, currentModelPath, appearanceTable, onClose, scrollKey)
    local menu = vgui.Create("DFrame")
    menu:SetTitle(title or "Select Face")
    menu:SetSize(ScreenScale(170), ScreenScale(220))

    -- Ďîçčöčîíčđîâŕíčĺ ęŕę â ClothesIconMenu
    local x, y
    if parent and IsValid(parent) then
        local parentX, parentY = parent:LocalToScreen(0, 0)
        local parentW, parentH = parent:GetSize()
        x = parentX + parentW + ScreenScale(5)
        y = parentY
        if x + menu:GetWide() > ScrW() then
            x = parentX - menu:GetWide() - ScreenScale(5)
        end
        if y + menu:GetTall() > ScrH() then
            y = ScrH() - menu:GetTall() - ScreenScale(5)
        end
    else
        local cx, cy = input.GetCursorPos()
        x, y = cx, cy
    end
    menu:SetPos(x, y)
    menu:MakePopup()
    menu:SetDraggable(false)
    menu:ShowCloseButton(true)

    function menu:OnFocusChanged(gained)
        if not gained then self:Close() end
    end

    function menu:Paint(w, h)
        draw.RoundedBox(8, 0, 0, w, h, clr_menu)
        surface.SetDrawColor(colors.scrollbarBorder)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        draw.RoundedBoxEx(8, 0, 0, w, ScreenScale(10), colors.secondary, true, true, false, false)
        surface.SetDrawColor(colors.scrollbarBorder)
        surface.DrawLine(0, ScreenScale(10), w, ScreenScale(10))
    end

    local scroll = CreateStyledScrollPanel(menu)
    scroll:Dock(FILL)
    scroll:DockMargin(ScreenScale(2), ScreenScale(2), ScreenScale(2), ScreenScale(2))


    if scrollKey and scrollPositions[scrollKey] then
        timer.Simple(0.1, function()
            if IsValid(scroll) then
                local vbar = scroll:GetVBar()
                vbar:SetScroll(scrollPositions[scrollKey])
            end
        end)
    end





    -- Ńĺňęŕ 3x
    local grid = vgui.Create("DGrid", scroll)
    grid:Dock(TOP)
    grid:SetCols(3)
    grid:SetColWide(ScreenScale(52))
    grid:SetRowHeight(ScreenScale(56))

    -- Ďŕíĺëü ń ňĺęóůčě âűáîđîě
    local infoPanel = vgui.Create("DPanel", scroll)
    infoPanel:Dock(TOP)
    infoPanel:SetTall(ScreenScale(20))
    infoPanel:DockMargin(0, 0, 0, ScreenScale(4))
    function infoPanel:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(20, 20, 25, 240))
        surface.SetDrawColor(colors.scrollbarBorder)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    local currentLabel = vgui.Create("DLabel", infoPanel)
    currentLabel:Dock(FILL)
    currentLabel:DockMargin(ScreenScale(4), 0, 0, 0)
    currentLabel:SetFont("ZCity_Tiny")
    currentLabel:SetText("Current: " .. (currentSelection or "Default"))
    currentLabel:SetTextColor(colors.mainText)
    currentLabel:SetContentAlignment(4)

    -- Ôóíęöč˙ ńîçäŕíč˙ čęîíęč
    local function CreateFacemapIcon(varName, slotMap, modelPath, modelName, sex, currentSelection, onSelect)
        local ico = vgui.Create("DPanel")
        ico:SetSize(ScreenScale(52), ScreenScale(52))
        ico.VarName = varName
        ico.bIsHovered = false
        ico.IsSelected = (varName == currentSelection)

        local previewModel = vgui.Create("DModelPanel", ico)
        previewModel:Dock(FILL)
        previewModel:DockMargin(2, 2, 2, 2)
        previewModel:SetModel(modelPath)

        -- ÍŔŃŇĐÎÉĘŔ ĘŔĚĹĐŰ ÄËß ĎĐĹÄĎĐÎŃĚÎŇĐŔ ËČÖŔ
        -- Çíŕ÷ĺíč˙ ďîäîáđŕíű äë˙ ćĺíńęčő ěîäĺëĺé. Äë˙ ěóćńęčő (îíč íĺěíîăî íčćĺ) íóćíű čçěĺíĺíč˙.
        -- Đĺęîěĺíäóĺěűĺ çíŕ÷ĺíč˙ äë˙ ćĺíůčí: CamPos(40,0,60), LookAt(7,1,63), FOV(20)
        previewModel:SetCamPos(Vector(45, 2, 63))  -- X, Y, Z ďîçčöč˙ ęŕěĺđű
        previewModel:SetLookAt(Vector(7, 1, 63))  -- ňî÷ęŕ, íŕ ęîňîđóţ ńěîňđčň ęŕěĺđŕ
        previewModel:SetFOV(20)                    -- óăîë îáçîđŕ


        previewModel:SetDirectionalLight(BOX_RIGHT, Color(255, 0, 0))
        previewModel:SetDirectionalLight(BOX_LEFT, Color(125, 155, 255))
        previewModel:SetDirectionalLight(BOX_FRONT, Color(160, 160, 160))
        previewModel:SetDirectionalLight(BOX_BACK, Color(0, 0, 0))
        previewModel:SetAmbientLight(Color(50, 50, 50))

        function previewModel:PreDrawModel(ent)
            render.SetColorModulation(1, 1, 1)
        end
        function previewModel:PostDrawModel(ent)
            render.SetColorModulation(1, 1, 1)
        end

        function previewModel:LayoutEntity(ent)
            if not IsValid(ent) then return end
            ent:SetSequence(ent:LookupSequence("idle_suitcase"))
            ent:SetAngles(Angle(0, 0, 0))

            local modelData = hg.Appearance.PlayerModels[sex] and hg.Appearance.PlayerModels[sex][modelName]
            if not modelData or not modelData.mdl then return end

            local mats = ent:GetMaterials()

            -- Ďđčěĺí˙ĺě âńĺ ňĺęńňóđű čç slotMap
            for slotMaterial, texturePath in pairs(slotMap) do
                -- Íŕőîäčě číäĺęń ýňîăî ěŕňĺđčŕëŕ â ěîäĺëč
                local slotIndex
                for i, matName in ipairs(mats) do
                    if matName == slotMaterial then
                        slotIndex = i - 1
                        break
                    end
                end
                if slotIndex then
                    ent:SetSubMaterial(slotIndex, texturePath)
                end
            end

            ent:SetColor(Color(255,255,255))
        end

        local nameLabel = vgui.Create("DLabel", ico)
        nameLabel:SetPos(0, ScreenScale(42))
        nameLabel:SetSize(ScreenScale(52), ScreenScale(10))
        nameLabel:SetFont("ZCity_Tiny")
        nameLabel:SetText(string.NiceName(varName))
        nameLabel:SetTextColor(colors.mainText)
        nameLabel:SetContentAlignment(5)
        nameLabel:SetExpensiveShadow(1, Color(0,0,0,200))

        function previewModel:DoClick()
            if onSelect then
                onSelect(varName)
            end
            surface.PlaySound("player/clothes_generic_foley_0"..math.random(5)..".wav")
            menu:Close()
        end

        function ico:Paint(w, h)
            local bgColor = self.IsSelected and Color(40, 140, 45, 255) or clr_ico
            draw.RoundedBox(4, 0, 0, w, h, bgColor)
            local borderCol = self.bIsHovered and Color(255,200,50,255) or colors.scrollbarBorder
            surface.SetDrawColor(borderCol)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
        end

        function ico:Think()
            self.bIsHovered = vgui.GetHoveredPanel() == self or vgui.GetHoveredPanel() == previewModel
            self.IsSelected = (varName == currentSelection)
        end

        return ico
    end

    -- Äîáŕâë˙ĺě âńĺ facemap â ńĺňęó
    for _, varName in ipairs(sortedNames) do
        local slotMap = combinedVariants[varName]  -- ňŕáëčöŕ ńëîň -> ďóňü
        local icon = CreateFacemapIcon(varName, slotMap, currentModelPath, currentModelName, sex, currentSelection, onSelect)
        grid:AddItem(icon)
    end

    -- Đŕçäĺëčňĺëü
    local separator = vgui.Create("DPanel", scroll)
    separator:Dock(TOP)
    separator:SetTall(ScreenScale(2))
    separator:DockMargin(0, ScreenScale(4), 0, ScreenScale(2))
    function separator:Paint(w, h)
        surface.SetDrawColor(colors.scrollbarBorder)
        surface.DrawRect(0, 0, w, h)
    end

    -- Ęíîďęŕ Default (ńáđîń íŕ ńňŕíäŕđňíîĺ ëčöî)
    local noneButton = vgui.Create("DButton", scroll)
    noneButton:Dock(TOP)
    noneButton:SetTall(ScreenScale(24))
    noneButton:SetText("")
    function noneButton:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 50, 240))
        surface.SetDrawColor(colors.scrollbarBorder)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        draw.SimpleText("Default", "ZCity_Tiny", w/2, h/2, colors.mainText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    function noneButton:DoClick()
        if onSelect then
            onSelect("Default")
        end
        surface.PlaySound("player/clothes_generic_foley_0"..math.random(5)..".wav")
        menu:Close()
    end



    function menu:OnClose()
        if scrollKey and IsValid(scroll) then
            local vbar = scroll:GetVBar()
            scrollPositions[scrollKey] = vbar:GetScroll()
        end
        if onClose then onClose() end
    end





    return menu
end









-- Ďóáëč÷íŕ˙ ôóíęöč˙ îňęđűňč˙ ěĺíţ îäĺćäű
function hg.Appearance.OpenClothesMenu(parent, partName, currentSelection, onSelectCallback, appearanceTable, onClose)
    local ply = LocalPlayer()
    if not ply then return end

    local editTable = appearanceTable or hg.Appearance.CurrentEditTable
    local currentModelName = "Male 01"
    local currentModelPath = "models/player/group01/male_01.mdl"
    if editTable and editTable.AModel then
        currentModelName = editTable.AModel
    end

    local isFemale = false
    if hg.Appearance.PlayerModels then
        if hg.Appearance.PlayerModels[2] and hg.Appearance.PlayerModels[2][currentModelName] then
            isFemale = true
        end
    end
    local sexIndex = isFemale and 2 or 1

    if hg.Appearance.PlayerModels then
        local sexModels = hg.Appearance.PlayerModels[sexIndex]
        if sexModels and sexModels[currentModelName] and sexModels[currentModelName].mdl then
            currentModelPath = sexModels[currentModelName].mdl
        end
    end

    local clothesTable = hg.Appearance.Clothes[sexIndex] or {}
    local titles = { main = "Select Jacket", pants = "Select Pants", boots = "Select Boots" }
    local showColorPicker = (partName == "main")

    local currentColor = Color(255,255,255)
    if editTable and editTable.AColor then
        currentColor = editTable.AColor
    end

    local menu = CreateClothesIconMenu(
        parent,
        titles[partName] or "Select Clothing",
        clothesTable,
        sexIndex,
        currentSelection,
        {
            clothes = function(id) if onSelectCallback then onSelectCallback(id) end end,
            color = function(clr) if editTable then editTable.AColor = clr end end,
            getCurrentColor = function() return currentColor end
        },
        showColorPicker,
        partName,
        currentModelName,
        currentModelPath,
        editTable,
        onClose,
        "clothes_" .. partName   -- scrollKey
    )
    return menu
end



-- Ďóáëč÷íŕ˙ ôóíęöč˙ îňęđűňč˙ ěĺíţ Facemap
function hg.Appearance.OpenFacemapMenu(parent, currentSelection, onSelectCallback, appearanceTable, onClose)
    local ply = LocalPlayer()
    if not ply then return end

    local editTable = appearanceTable or hg.Appearance.CurrentEditTable
    local currentModelName = "Male 01"
    local currentModelPath = "models/player/group01/male_01.mdl"
    if editTable and editTable.AModel then
        currentModelName = editTable.AModel
    end

    local isFemale = false
    if hg.Appearance.PlayerModels then
        if hg.Appearance.PlayerModels[2] and hg.Appearance.PlayerModels[2][currentModelName] then
            isFemale = true
        end
    end
    local sexIndex = isFemale and 2 or 1

    if hg.Appearance.PlayerModels then
        local sexModels = hg.Appearance.PlayerModels[sexIndex]
        if sexModels and sexModels[currentModelName] and sexModels[currentModelName].mdl then
            currentModelPath = sexModels[currentModelName].mdl
        end
    end


    -- =====================================================
    -- ÍÎÂŔß ŃČŃŇĹĚŔ MULTI-FACEMAPS (ĺńëč ĺńňü)
    -- =====================================================

    local combinedVariants = {}

    local modelKey = string.lower(currentModelPath)
    local multi = hg.Appearance.MultiFacemaps and hg.Appearance.MultiFacemaps[modelKey]

    if multi then
        -- Čńďîëüçóĺě íîâóţ ńčńňĺěó
        combinedVariants = multi

    else

        -- =====================================================
        -- ŃŇŔĐŔß ŃČŃŇĹĚŔ ZCITY (fallback)
        -- =====================================================

        local modelSlots = hg.Appearance.FacemapsModels and hg.Appearance.FacemapsModels[modelKey]

        if not modelSlots then
            notification.AddLegacy("This model does not support face changing", NOTIFY_ERROR, 3)
            return
        end

        local slotVariants = hg.Appearance.FacemapsSlots and hg.Appearance.FacemapsSlots[modelSlots]

        if slotVariants then
            for varName, texturePath in pairs(slotVariants) do
                combinedVariants[varName] = {
                    [modelSlots] = texturePath
                }
            end
        end

    end




    --[[
    -- Ďîëó÷ŕĺě âńĺ ńëîňű, ńâ˙çŕííűĺ ń ýňîé ěîäĺëüţ
    local modelSlots = hg.Appearance.ModelFaceSlots and hg.Appearance.ModelFaceSlots[currentModelPath]
    if not modelSlots or table.IsEmpty(modelSlots) then
        -- Ĺńëč íĺň ńďĺöčŕëüíűő ńëîňîâ, ďđîáóĺě ńňŕđűé ńďîńîá (îäčí ńëîň)
        local faceSlotMaterial = hg.Appearance.FacemapsModels and hg.Appearance.FacemapsModels[currentModelPath]
        if faceSlotMaterial then
            modelSlots = { [faceSlotMaterial] = true }
        else
            notification.AddLegacy("This model does not support face changing", NOTIFY_ERROR, 3)
            return
        end
    end

    -- Ńîáčđŕĺě âńĺ âŕđčŕíňű ëčöŕ, îáúĺäčí˙˙ ďî čěĺíč
    local combinedVariants = {}  -- ęëţ÷: čě˙ âŕđčŕíňŕ, çíŕ÷ĺíčĺ: ňŕáëčöŕ { [slot] = texturePath }
    for slot, _ in pairs(modelSlots) do
        local slotVariants = hg.Appearance.FacemapsSlots[slot]
        if slotVariants then
            for varName, texturePath in pairs(slotVariants) do
                combinedVariants[varName] = combinedVariants[varName] or {}
                combinedVariants[varName][slot] = texturePath
            end
        end
    end
    ]]


    if table.IsEmpty(combinedVariants) then
        notification.AddLegacy("No facemaps available", NOTIFY_ERROR, 3)
        return
    end

    -- Ńîđňčđóĺě čěĺíŕ âŕđčŕíňîâ (íŕďđčěĺđ, ďî ŕëôŕâčňó)
    local sortedNames = table.GetKeys(combinedVariants)
    table.sort(sortedNames)

    -- Ńîçäŕ¸ě ěĺíţ, ďĺđĺäŕâŕ˙ ńîáđŕííűĺ âŕđčŕíňű
    local menu = CreateFacemapIconMenu(
        parent,
        "Select Face",
        combinedVariants,        -- ňĺďĺđü ýňî ňŕáëčöŕ čě˙ -> { slot = texture }
        sortedNames,             -- îňńîđňčđîâŕííűé ńďčńîę čě¸í
        sexIndex,
        currentSelection,
        function(varName)        -- onSelect
            if onSelectCallback then
                onSelectCallback(varName)
            end
            -- Ĺńëč íóćíî îáíîâčňü íĺńęîëüęî ďîëĺé â AppearanceTable, ńäĺëŕé ýňî çäĺńü,
            -- íî äë˙ ńîâěĺńňčěîńňč îńňŕâë˙ĺě ďîęŕ ňîëüęî îäíî ďîëĺ.
            -- Íŕďđčěĺđ, ĺńëč ó ěîäĺëč ĺńňü îňäĺëüíűĺ ďîë˙ äë˙ âîëîń, čő ěîćíî óńňŕíîâčňü:
            -- if editTable then
            --     editTable.AFacemap = varName  -- îńíîâíîĺ ďîëĺ
            --     -- äë˙ âîëîń ěîćíî čńďîëüçîâŕňü editTable.AHair = varName, íî íóćíî çíŕňü, ęŕę îíč őđŕí˙ňń˙
            -- end
        end,
        "face",
        currentModelName,
        currentModelPath,
        editTable,
        onClose,
        "facemap"   -- scrollKey
    )
    return menu
end









-----------------------------------------------------------------------
-- 3. Ďĺđĺőâŕň ńîçäŕíč˙ ďŕíĺëč č çŕěĺíŕ ęíîďîę
-----------------------------------------------------------------------

-- Ńîőđŕí˙ĺě îđčăčíŕëüíóţ ôóíęöčţ
local oldCreateApperanceMenu = hg.CreateApperanceMenu

-- Ôóíęöč˙ ěîäčôčęŕöčč ďŕíĺëč: čůĺě ęíîďęč ďî ňĺęńňó č ďîäěĺí˙ĺě DoClick
local function ModifyAppearanceMenu(panel)
    if not IsValid(panel) then return end

    -- Ňŕáëčöŕ ńîîňâĺňńňâč˙: ňĺęńň ęíîďęč -> ÷ŕńňü ňĺëŕ
    local buttonMap = {
        ["Jacket"]  = "main",
        ["Pants"]   = "pants",
        ["Boots"]   = "boots",
        --["Gloves"]  = "gloves",      -- ĺńëč ďîíŕäîáčňń˙
        ["Facemap"] = "facemap"      -- ňĺńňčđóĺě
    }

    if not IsValid(panel.ShowcaseBtn) then
        local showcaseBtn = vgui.Create("DButton", panel)
        showcaseBtn:SetText("SHOWCASE")
        showcaseBtn:SetSize(ScreenScale(100), ScreenScale(16))
        ApplyBaseAppearanceButtonStyle(showcaseBtn)
        function showcaseBtn:Think()
            if not IsValid(panel) then return end
            local margin = ScreenScale(6)
            self:SetPos(panel:GetWide() - self:GetWide() - margin, panel:GetTall() - self:GetTall() - margin)
        end
        function showcaseBtn:DoClick()
            hg.Appearance.OpenShowcaseMenu(panel.AppearanceTable)
        end
        panel.ShowcaseBtn = showcaseBtn
    end

    if not IsValid(panel.AllFacemapsBtn) then
        local allFacemapsBtn = vgui.Create("DButton", panel)
        allFacemapsBtn:SetText("ALL_FACEMAPS")
        allFacemapsBtn:SetSize(ScreenScale(100), ScreenScale(16))
        ApplyBaseAppearanceButtonStyle(allFacemapsBtn)
        function allFacemapsBtn:Think()
            if not IsValid(panel) then return end
            local margin = ScreenScale(6)
            local spacing = ScreenScale(4)
            local rightButton = panel.ShowcaseBtn
            if not IsValid(rightButton) then return end
            self:SetPos(rightButton:GetX() - self:GetWide() - spacing, panel:GetTall() - self:GetTall() - margin)
        end
        function allFacemapsBtn:DoClick()
            if hg.Appearance.OpenAllFacemapsMenu then
                hg.Appearance.OpenAllFacemapsMenu(panel.AppearanceTable)
            end
        end
        panel.AllFacemapsBtn = allFacemapsBtn
    end

    ------------------------------------------------------
    ------------------------------------------------------





    -- Đĺęóđńčâíî čůĺě âńĺ ęíîďęč âíóňđč ďŕíĺëč
    local function FindButtons(parent)
        for _, child in ipairs(parent:GetChildren()) do
            if child:GetName() == "DButton" or child:GetClassName() == "DButton" then
                local text = child:GetText() or ""
                if buttonMap[text] then
                    -- Çŕďîěčíŕĺě îđčăčíŕëüíűé DoClick (íŕ âń˙ęčé ńëó÷ŕé)
                    local oldDoClick = child.DoClick
                    local part = buttonMap[text]

                    -- Ďîäěĺí˙ĺě ěĺňîä
                    child.DoClick = function(btn)
                        -- Óńňŕíŕâëčâŕĺě ďîçčöčţ ęŕěĺđű (ęŕę â îđčăčíŕëĺ)
                        if part == "main" then
                            panel.modelPosID = "Torso"
                        elseif part == "pants" then
                            panel.modelPosID = "Legs"
                        elseif part == "boots" then
                            panel.modelPosID = "Boots"
                        elseif part == "gloves" then
                            panel.modelPosID = "Hands"
                        elseif part == "facemap" then
                            panel.modelPosID = "Face"
                        end

                        -- Îďđĺäĺë˙ĺě ňĺęóůĺĺ çíŕ÷ĺíčĺ äë˙ ýňîé ÷ŕńňč
                        local current
                        if part == "main" then
                            current = panel.AppearanceTable.AClothes.main
                        elseif part == "pants" then
                            current = panel.AppearanceTable.AClothes.pants
                        elseif part == "boots" then
                            current = panel.AppearanceTable.AClothes.boots
                        elseif part == "gloves" then
                            -- äë˙ gloves íóćíî áđŕňü čç ABodygroups
                            current = panel.AppearanceTable.ABodygroups and panel.AppearanceTable.ABodygroups["HANDS"] or "Default"
                        elseif part == "facemap" then
                            current = panel.AppearanceTable.AFacemap or "Default"
                        end

                        -- Ęîëáýę îáíîâëĺíč˙ ňŕáëčöű
                        local function onSelect(id)
                            if part == "main" then
                                panel.AppearanceTable.AClothes.main = id
                            elseif part == "pants" then
                                panel.AppearanceTable.AClothes.pants = id
                            elseif part == "boots" then
                                panel.AppearanceTable.AClothes.boots = id
                            elseif part == "gloves" then
                                if not panel.AppearanceTable.ABodygroups then panel.AppearanceTable.ABodygroups = {} end
                                panel.AppearanceTable.ABodygroups["HANDS"] = id
                            elseif part == "facemap" then
                                panel.AppearanceTable.AFacemap = id
                            end
                        end

                        -- Îňęđűâŕĺě ńîîňâĺňńňâóţůĺĺ ěĺíţ
                        if part == "facemap" then
                            hg.Appearance.OpenFacemapMenu(btn, current, onSelect, panel.AppearanceTable, function()
                                panel.modelPosID = "All"
                            end)
                        else
                            hg.Appearance.OpenClothesMenu(btn, part, current, onSelect, panel.AppearanceTable, function()
                                panel.modelPosID = "All"
                            end)
                        end


                        -- Îňęđűâŕĺě íŕřĺ ěĺíţ
                        --hg.Appearance.OpenClothesMenu(btn, part, current, onSelect, panel.AppearanceTable, function()
                            -- Ďđč çŕęđűňčč ěĺíţ âîçâđŕůŕĺě ęŕěĺđó â ďîëîćĺíčĺ "All"
                            --panel.modelPosID = "All"
                        --end)
                    end
                end
            end
            -- Đĺęóđńčâíî îáőîäčě äî÷ĺđíčĺ ďŕíĺëč
            if child.GetChildren then
                FindButtons(child)
            end
        end
    end

    FindButtons(panel)
end

-- Ďĺđĺîďđĺäĺë˙ĺě ôóíęöčţ ńîçäŕíč˙ ěĺíţ
function hg.CreateApperanceMenu(ParentPanel)
    -- Âűçűâŕĺě îđčăčíŕë
    oldCreateApperanceMenu(ParentPanel)

    -- Ćä¸ě, ďîęŕ ďŕíĺëü ďî˙âčňń˙ č îňđčńóĺňń˙
    timer.Simple(0.1, function()
        if IsValid(zpan) then
            ModifyAppearanceMenu(zpan)
        end
    end)
end

print("[ZCityAppearanceMod] Is loaded")
