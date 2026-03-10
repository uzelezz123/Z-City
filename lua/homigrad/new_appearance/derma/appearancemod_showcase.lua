if SERVER then return end


hg.Appearance = hg.Appearance or {}

local SHOWCASE_COLS = 15

-- óâåëè÷åííûå èêîíêè
local ICON_W = 150
local ICON_H = 310

--[[
local ICON_W = 150
local ICON_H = 260
]]





function hg.Appearance.OpenShowcaseMenu(appearanceTable)

    local frame = vgui.Create("DFrame")
    frame:SetSize(ScrW(), ScrH())
    frame:SetTitle("")
    frame:MakePopup()
    frame:Center()
    frame:SetDraggable(false)
    frame:ShowCloseButton(true)

    -- ×¨ÐÍÛÉ ÔÎÍ (êàê òû õîòåë)
    function frame:Paint(w,h)
        surface.SetDrawColor(0,0,0,255)
        surface.DrawRect(0,0,w,h)
    end

    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)

    local grid = vgui.Create("DGrid", scroll)
    grid:Dock(TOP)
    grid:SetCols(SHOWCASE_COLS)
    grid:SetColWide(ICON_W + 8)
    grid:SetRowHeight(ICON_H + 8) -- áûëî +26

    local editTable = appearanceTable or hg.Appearance.CurrentEditTable
    if not editTable then return end

    local modelName = editTable.AModel

    local modelData =
        hg.Appearance.PlayerModels[1][modelName] or
        hg.Appearance.PlayerModels[2][modelName]

    if not modelData then return end

    local modelPath = modelData.mdl
    local sexIndex = modelData.sex and 2 or 1

    local clothes = hg.Appearance.Clothes[sexIndex]
    local facemap = editTable.AFacemap or "Default"

    for clothesID, clothesMat in SortedPairs(clothes) do

        local pnl = vgui.Create("DPanel")
        pnl:SetSize(ICON_W, ICON_H)

        function pnl:Paint(w,h)
            draw.RoundedBox(6,0,0,w,h,Color(20,20,20))
        end

        local mdl = vgui.Create("DModelPanel", pnl)

        mdl:Dock(FILL)
        mdl:SetModel(modelPath)

        mdl:SetAnimated(false)

        ----------------------------------------------------------------
        --                ÊÀÌÅÐÀ ÈÊÎÍÊÈ (ÐÅÄÀÊÒÈÐÓÉ ÇÄÅÑÜ)
        ----------------------------------------------------------------
        -- Åñëè ìîäåëü ñëèøêîì ìàëåíüêàÿ / áîëüøàÿ — ìåíÿé çíà÷åíèÿ
        -- CamPos = ðàññòîÿíèå êàìåðû
        -- LookAt = òî÷êà êóäà êàìåðà ñìîòðèò
        -- FOV = ìàñøòàá
        ----------------------------------------------------------------


        mdl:SetFOV(16)                      -- ìàñøòàá ìîäåëè
        mdl:SetCamPos(Vector(120,0,38))      -- ïîçèöèÿ êàìåðû
        mdl:SetLookAt(Vector(0,0,30))       -- öåíòð âçãëÿäà


        --[[
        mdl:SetFOV(28)                      -- ìàñøòàá ìîäåëè
        mdl:SetCamPos(Vector(75,0,60))      -- ïîçèöèÿ êàìåðû
        mdl:SetLookAt(Vector(0,0,55))       -- öåíòð âçãëÿäà
        ]]
        ----------------------------------------------------------------
        --   ÝÒÈ 3 ÏÀÐÀÌÅÒÐÀ ÒÛ ÁÓÄÅØÜ ÏÎÄÃÎÍßÒÜ ÏÎÄ ÑÂÎÈ ÌÎÄÅËÈ
        ----------------------------------------------------------------

        function mdl:LayoutEntity(ent)

            ent:SetAngles(Angle(0,0,0))
            ent:SetSequence(ent:LookupSequence("idle_suitcase"))

            local mats = ent:GetMaterials()

            local slots = modelData.submatSlots

            local function Apply(slot, texture)

                local matName = slots[slot]
                if not matName then return end

                for i,mat in ipairs(mats) do
                    if mat == matName then
                        ent:SetSubMaterial(i-1, texture)
                        break
                    end
                end

            end

            Apply("main", clothesMat)
            Apply("pants", clothesMat)
            Apply("boots", clothesMat)
            Apply("hands", "models/humans/male/group01/normal")

            if facemap ~= "Default" then

                for i = 1,#mats do
                    local mat = mats[i]

                    if hg.Appearance.FacemapsSlots[mat]
                    and hg.Appearance.FacemapsSlots[mat][facemap] then

                        ent:SetSubMaterial(
                            i-1,
                            hg.Appearance.FacemapsSlots[mat][facemap]
                        )

                    end
                end

            end

        end

        local label = vgui.Create("DLabel", pnl)
        label:Dock(BOTTOM)
        label:SetTall(20)
        label:SetText(clothesID)
        label:SetContentAlignment(5)
        label:SetTextColor(Color(255,255,255))

        grid:AddItem(pnl)

    end

end





local function GetFacemapVariantsForModel(modelPath)
    local combinedVariants = {}
    if not modelPath then return combinedVariants end

    local modelKey = string.lower(modelPath)
    local multi = hg.Appearance.MultiFacemaps and hg.Appearance.MultiFacemaps[modelKey]

    if multi then
        return table.Copy(multi)
    end

    local modelSlots = hg.Appearance.FacemapsModels and hg.Appearance.FacemapsModels[modelKey]
    if not modelSlots then
        return combinedVariants
    end

    local slotVariants = hg.Appearance.FacemapsSlots and hg.Appearance.FacemapsSlots[modelSlots]
    if not slotVariants then
        return combinedVariants
    end

    for varName, texturePath in pairs(slotVariants) do
        combinedVariants[varName] = {
            [modelSlots] = texturePath
        }
    end

    return combinedVariants
end

function hg.Appearance.OpenAllFacemapsMenu(appearanceTable)
    local editTable = appearanceTable or hg.Appearance.CurrentEditTable
    if not editTable then return end

    local frame = vgui.Create("DFrame")
    frame:SetSize(ScrW(), ScrH())
    frame:SetTitle("")
    frame:MakePopup()
    frame:Center()
    frame:SetDraggable(false)
    frame:ShowCloseButton(true)

    function frame:Paint(w, h)
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawRect(0, 0, w, h)
    end

    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)

    local iconSize = 140
    local iconPadding = 8
    local cols = math.max(1, math.floor((ScrW() - iconPadding * 2) / (iconSize + iconPadding)))

    local grid = vgui.Create("DGrid", scroll)
    grid:Dock(TOP)
    grid:SetCols(cols)
    grid:SetColWide(iconSize + iconPadding)
    grid:SetRowHeight(iconSize + 22 + iconPadding)

    local clothesSelection = (editTable.AClothes or {})

    local function BuildAllIconsForModel(modelName, modelData)
        if not modelData or not modelData.mdl then return end

        local modelPath = modelData.mdl
        local variants = GetFacemapVariantsForModel(modelPath)
        if table.IsEmpty(variants) then return end

        local sortedNames = table.GetKeys(variants)
        table.sort(sortedNames)

        for _, varName in ipairs(sortedNames) do
            local panel = vgui.Create("DPanel")
            panel:SetSize(iconSize, iconSize + 22)

            function panel:Paint(w, h)
                draw.RoundedBox(6, 0, 0, w, h, Color(20, 20, 20, 245))
                surface.SetDrawColor(70, 70, 90, 255)
                surface.DrawOutlinedRect(0, 0, w, h, 1)
            end

            local mdl = vgui.Create("DModelPanel", panel)
            mdl:SetPos(2, 2)
            mdl:SetSize(iconSize - 4, iconSize - 4)
            mdl:SetModel(modelPath)
            mdl:SetCamPos(Vector(45, 2, 63))
            mdl:SetLookAt(Vector(7, 1, 63))
            mdl:SetFOV(20)
            mdl:SetDirectionalLight(BOX_RIGHT, Color(255, 0, 0))
            mdl:SetDirectionalLight(BOX_LEFT, Color(125, 155, 255))
            mdl:SetDirectionalLight(BOX_FRONT, Color(160, 160, 160))
            mdl:SetDirectionalLight(BOX_BACK, Color(0, 0, 0))
            mdl:SetAmbientLight(Color(50, 50, 50))

            function mdl:LayoutEntity(ent)
                if not IsValid(ent) then return end

                ent:SetAngles(Angle(0, 0, 0))
                ent:SetSequence(ent:LookupSequence("idle_suitcase"))

                local mats = ent:GetMaterials()
                local slots = modelData.submatSlots or {}

                local function ApplyBySlot(slotName, clothesId)
                    local matName = slots[slotName]
                    if not matName then return end

                    local clothesTable = hg.Appearance.Clothes[modelData.sex and 2 or 1] or {}
                    local texturePath = clothesTable[clothesId or ""] or clothesTable.normal or ""
                    for i, mat in ipairs(mats) do
                        if mat == matName then
                            ent:SetSubMaterial(i - 1, texturePath)
                            break
                        end
                    end
                end

                ApplyBySlot("main", clothesSelection.main)
                ApplyBySlot("pants", clothesSelection.pants)
                ApplyBySlot("boots", clothesSelection.boots)

                local slotMap = variants[varName] or {}
                for slotMaterial, texturePath in pairs(slotMap) do
                    for i, matName in ipairs(mats) do
                        if matName == slotMaterial then
                            ent:SetSubMaterial(i - 1, texturePath)
                            break
                        end
                    end
                end

                ent:SetColor(Color(255, 255, 255))
            end

            local label = vgui.Create("DLabel", panel)
            label:Dock(BOTTOM)
            label:SetTall(20)
            label:SetText(modelName .. " | " .. varName)
            label:SetFont("ZCity_Tiny")
            label:SetContentAlignment(5)
            label:SetTextColor(Color(255, 255, 255))

            grid:AddItem(panel)
        end
    end

    for _, sex in ipairs({1, 2}) do
        for modelName, modelData in SortedPairs(hg.Appearance.PlayerModels[sex] or {}) do
            BuildAllIconsForModel(modelName, modelData)
        end
    end
end

hook.Add("Think","Appearance_ShowcaseHook",function()

    if hg.Appearance.ShowcaseHooked then return end

    if not vgui or not vgui.GetWorldPanel then return end

    for _,panel in ipairs(vgui.GetWorldPanel():GetChildren()) do

        if panel:GetClassName() == "DFrame" then

            for _,child in ipairs(panel:GetChildren()) do

                if child:GetClassName() == "DButton"
                and child:GetText() == "Facemap" then

                    hg.Appearance.ShowcaseHooked = true

                    local oldClick = child.DoClick

                    function child:DoClick()

                        if input.IsKeyDown(KEY_LSHIFT) then
                            hg.Appearance.OpenShowcaseMenu()
                            return
                        end

                        if oldClick then
                            oldClick(self)
                        end

                    end

                end

            end

        end

    end

end)