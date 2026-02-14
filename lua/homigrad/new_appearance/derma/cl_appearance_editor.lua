hg.Appearance = hg.Appearance or {}
local APmodule = hg.Appearance
local PANEL = {}

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

local presetsDir = "zcity/appearances/presets/"

local function SavePreset(strName, tblAppearance)
    file.CreateDir(presetsDir)
    file.Write(presetsDir .. strName .. ".json", util.TableToJSON(tblAppearance, true))
end

local function LoadPreset(strName)
    if not file.Exists(presetsDir .. strName .. ".json", "DATA") then return nil end
    return util.JSONToTable(file.Read(presetsDir .. strName .. ".json", "DATA"))
end

local function GetPresetList()
    file.CreateDir(presetsDir)
    local files = file.Find(presetsDir .. "*.json", "DATA")
    local presets = {}
    for _, f in ipairs(files or {}) do
        table.insert(presets, string.StripExtension(f))
    end
    return presets
end

local function DeletePreset(strName)
    if file.Exists(presetsDir .. strName .. ".json", "DATA") then
        file.Delete(presetsDir .. strName .. ".json")
        return true
    end
    return false
end

hg.Appearance.SavePreset = SavePreset
hg.Appearance.LoadPreset = LoadPreset
hg.Appearance.GetPresetList = GetPresetList
hg.Appearance.DeletePreset = DeletePreset

local modelsPrecached = false
local function PrecacheAccessoryModels()
    if modelsPrecached then return end
    modelsPrecached = true
    
    timer.Simple(0.1, function()
        if APmodule.PlayerModels then
            for _, sexModels in pairs(APmodule.PlayerModels) do
                for _, modelData in pairs(sexModels) do
                    if modelData.mdl then
                        util.PrecacheModel(modelData.mdl)
                    end
                end
            end
        end
        
        if hg.Accessories then
            for _, accessory in pairs(hg.Accessories) do
                if accessory.model then
                    util.PrecacheModel(accessory.model)
                end
            end
        end
    end)
end


hook.Add("InitPostEntity", "HG_PrecacheAppearanceModels", function()
    timer.Simple(5, PrecacheAccessoryModels)
end)

hg.Appearance.PrecacheModels = PrecacheAccessoryModels


local function CreateStyledScrollPanel(parent)
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

local clr_ico, clr_menu = Color(30, 30, 40, 255), Color(15, 15, 20, 250)
local function CreateStyledAccessoryMenu(parent, title)
    local menu = vgui.Create("DFrame")
    menu:SetTitle(title or "")
    menu:SetSize(ScreenScale(90), ScreenScale(140))
    local cx,cy = input.GetCursorPos()
    menu:SetPos(cx,cy)
    menu:MakePopup()
    menu:SetDraggable(false)
    menu:ShowCloseButton(true)
    
    menu.CurrentPreviewIcon = nil  
    
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

    local iconLayout = vgui.Create("DIconLayout", scroll)
    iconLayout:Dock(TOP)
    iconLayout:SetSpaceX(ScreenScale(2))
    iconLayout:SetSpaceY(ScreenScale(2))

    menu.IconLayout = iconLayout
    menu.ScrollPanel = scroll

    function menu:AddAccessoryIcon(model, accessorKey, accessoryData, onSelect, onRightClick, isPreview)
        local ico = vgui.Create("DPanel", self.IconLayout)
        local icoSize = ScreenScale(36)
        ico:SetSize(icoSize, icoSize)
        ico.Accessor = accessorKey
        ico.bIsHovered = false
        ico.IsPreviewing = false

        local spawnIcon = vgui.Create( "DModelPanel", ico )
        spawnIcon:Dock(FILL)
        spawnIcon:DockMargin(2,2,2,2)
        spawnIcon:SetModel(model or "models/error.mdl")
        spawnIcon:SetTooltip(string.NiceName(accessoryData and accessoryData.name or accessorKey))
        spawnIcon:SetFOV(15)
        spawnIcon:SetLookAt( accessoryData.vpos or Vector(0,0,0) )
        function spawnIcon:PreDrawModel(ent)
            if accessoryData.bSetColor then
                local colorDraw = accessoryData.vecColorOveride or ( lply.GetPlayerColor and lply:GetPlayerColor() or lply:GetNWVector("PlayerColor",Vector(1,1,1)) )
                render.SetColorModulation( colorDraw[1],colorDraw[2],colorDraw[3] )
            end
        end

        function spawnIcon:PostDrawModel(ent)
            if accessoryData.bSetColor then
                render.SetColorModulation( 1, 1, 1 )
            end
        end
        timer.Simple(0,function()
            spawnIcon.Entity:SetSkin((isfunction(accessoryData.skin) and accessoryData.skin()) or (accessoryData.skin or 0))
            spawnIcon.Entity:SetBodyGroups(accessoryData.bodygroups or "0000000")
            if accessoryData.SubMat then
                spawnIcon.Entity:SetSubMaterial( 0, accessoryData.SubMat )
            end
        end)

        function spawnIcon:DoClick()
            if onSelect then onSelect(accessorKey) end
            surface.PlaySound("player/clothes_generic_foley_0"..math.random(5)..".wav")
            menu:Close()
        end
        
        function spawnIcon:Think()
            if onRightClick and self:IsHovered() then
                ico.IsPreviewing = true

                if ico.IsPreviewing then
                    menu.CurrentPreviewIcon = ico
                else
                    menu.CurrentPreviewIcon = nil
                end

                onRightClick(accessorKey, ico.IsPreviewing)
            end
        end

        function ico:Paint(w, h)
            draw.RoundedBox(4, 0, 0, w, h, clr_ico)
        end

        function ico:Think()
            self.bIsHovered = vgui.GetHoveredPanel() == self or vgui.GetHoveredPanel() == spawnIcon
        end

        return ico
    end
    
    function menu:AddNoneOption(onSelect)
        local ico = vgui.Create("DPanel", self.IconLayout)
        local icoSize = ScreenScale(36)
        ico:SetSize(icoSize, icoSize)
        ico.Accessor = "none"
        ico.bIsHovered = false
        
        function ico:Paint(w, h)
            local borderCol = self.bIsHovered and colors.scrollbarGripHover or colors.scrollbarBorder
            draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 40, 255))
            surface.SetDrawColor(borderCol)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
            
            surface.SetDrawColor(colors.highlightText)
            local margin = ScreenScale(8)
            surface.DrawLine(margin, margin, w - margin, h - margin)
            surface.DrawLine(w - margin, margin, margin, h - margin)
            
            draw.SimpleText("None", "DermaDefault", w/2, h - ScreenScale(4), colors.mainText, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        end
        
        function ico:Think()
            self.bIsHovered = vgui.GetHoveredPanel() == self
        end
        
        function ico:OnMousePressed(mc)
            if mc == MOUSE_LEFT then
                if onSelect then onSelect("none") end
                surface.PlaySound("player/clothes_generic_foley_0"..math.random(5)..".wav")
                menu:Close()
            end
        end
        
        function ico:OnCursorEntered()
            self:SetCursor("hand")
        end
        
        return ico
    end
    
    return menu
end

function PANEL:SetAppearance( tAppearacne )
    self.AppearanceTable = tAppearacne
end

function PANEL:CallbackAppearance()

end

function PANEL:First( ply )
    self:SetY(self:GetY() + self:GetTall())
    self:MoveTo(self:GetX(), self:GetY() - self:GetTall(), 0.4, 0, 0.2, function() end)
    self:AlphaTo( 255, 0.2, 0.1, nil )

    if self.PostInit then
        self:PostInit()
    end
end

local sizeX, sizeY = ScrW() * 1, ScrH() * 1

local xbars = 17
local ybars = 30

local xbars2 = 0
local ybars2 = 0

local gradient_d = Material("vgui/gradient-d")
local gradient_u = Material("vgui/gradient-u")
local gradient_l = Material("vgui/gradient-l")
local gradient_r = Material("vgui/gradient-r")

local sw, sh = ScrW(), ScrH()

function PANEL:Paint(w,h)
    surface.SetDrawColor(11, 11, 11, 255)
    surface.DrawRect(0, 0, w, h)

    surface.SetDrawColor(155,15,15,15)

    for i = 1, (ybars + 1) do
        surface.DrawRect((sw / ybars) * i - (CurTime() * 30 % (sw / ybars)), 0, ScreenScale(1), sh)
    end

    for i = 1, (xbars + 1) do
        surface.DrawRect(0, (sh / xbars) * (i - 1) + (CurTime() * 30 % (sh / xbars)), sw, ScreenScale(1))
    end

    local border_size = ScreenScale(55)

    surface.SetDrawColor(0, 0, 0)
    surface.SetMaterial(gradient_d)
    surface.DrawTexturedRect(0, sh - border_size + 1, sw, border_size)

    surface.SetDrawColor(0, 0, 0)
    surface.SetMaterial(gradient_u)
    surface.DrawTexturedRect(0, 0, sw, border_size)

    surface.SetDrawColor(0, 0, 0)
    surface.SetMaterial(gradient_l)
    surface.DrawTexturedRect(0, 0, border_size, sh)

    surface.SetDrawColor(0, 0, 0)
    surface.SetMaterial(gradient_r)
    surface.DrawTexturedRect(sw - border_size, 0, border_size, sh)
end

function PANEL:PostInit()
    local main = self
    self:SetBorder(false)
    self:SetDraggable(false)
    self.modelPosID = "All"

    self.AppearanceTable = self.AppearanceTable or hg.Appearance.LoadAppearanceFile(hg.Appearance.SelectedAppearance:GetString()) or APmodule.GetRandomAppearance()

    local tMdl = APmodule.PlayerModels[1][self.AppearanceTable.AModel] or APmodule.PlayerModels[2][self.AppearanceTable.AModel]
    --print(tMdl.mdl)
    local viewer = vgui.Create( "DModelPanel", self )
    viewer:SetSize(sizeX / 2.6,sizeY)
    viewer:SetModel( util.IsValidModel( tostring(tMdl.mdl) ) and tostring(tMdl.mdl) or "models/player/group01/female_01.mdl" )
    viewer:SetFOV( 75 )
    viewer:SetLookAng( Angle( 11, 180, 0 ) )
    viewer:SetCamPos( Vector( 100, 0, 55 ) )
    viewer:SetDirectionalLight(BOX_RIGHT, Color(255, 0, 0))
    viewer:SetDirectionalLight(BOX_LEFT, Color(125, 155, 255))
    viewer:SetDirectionalLight(BOX_FRONT, Color(160, 160, 160))
    viewer:SetDirectionalLight(BOX_BACK, Color(0, 0, 0))
    viewer:SetDirectionalLight(BOX_TOP, Color(255, 255, 255))
    viewer:SetDirectionalLight(BOX_BOTTOM, Color(0, 0, 0))
    viewer:Dock(FILL)
    viewer:SetAmbientLight(Color(255, 0, 0, 255))

    function viewer:OnMouseWheeled(delta)
        self.SmoothFOVDelta = self:GetFOV() - delta * 5
    end
    local offsets = {
        ["All"] = 1,
        ["Head"] = 1.15,
        ["Face"] = 1.1,
        ["Torso"] = 0.9,
        ["Legs"] = 0.4,
        ["Boots"] = 0.1,
        ["Hands"] = 0.5
    }
    function viewer:Think()
        self.SmoothFOV = LerpFT(0.05,self.SmoothFOV or self:GetFOV(), main.modelPosID == "All" and 75 or 35)
        self.LookAngles = LerpFT(0.05, self.LookAngles or 11, main.modelPosID == "All" and 11 or 0)
        self:SetFOV( self.SmoothFOV )
        self:SetLookAng( Angle( self.LookAngles, 180, 0 ) )

        --self.OffsetY = LerpFT(0.2,self.OffsetY or 0,1)

        self.OffsetY = LerpFT(0.1,self.OffsetY or 0,offsets[main.modelPosID] or 1)
    end
    local funpos1x
    local funpos3x
    function viewer:LayoutEntity( Entity )
        local lookX, lookY = input.GetCursorPos()
        lookX = lookX / sizeX - 0.5
        lookY = lookY / sizeY - 0.5
        Entity.Angles = Entity.Angles or Angle(0,0,0)
        Entity.Angles = LerpAngle(FrameTime() * 5,Entity.Angles,Angle(lookY * 2,(self.Rotate and -179 or 0) -lookX * 75,0))
        local tbl = main.AppearanceTable
        tMdl = APmodule.PlayerModels[1][tbl.AModel] or APmodule.PlayerModels[2][tbl.AModel]

        Entity:SetNWVector("PlayerColor",Vector(tbl.AColor.r / 255, tbl.AColor.g / 255, tbl.AColor.b / 255))
        Entity:SetAngles(Entity.Angles)
        Entity:SetSequence(Entity:LookupSequence("idle_suitcase"))
        Entity:SetSubMaterial()
        self:SetCamPos( Vector( 100, 0, 55 * (self.OffsetY or 1) ) )
        if Entity:GetModel() != tMdl.mdl then
            Entity:SetModel(tMdl.mdl)
            self:SetModel(tMdl.mdl)
            tbl.AFacemap = "Default"
        end
        --print(tMdl.mdl)

        local mats = Entity:GetMaterials()
        for k, v in pairs(tMdl.submatSlots) do
            local slot = 1
            for i = 1, #mats do
                if mats[i] == v then slot = i-1 break end
            end
            Entity:SetSubMaterial(slot, hg.Appearance.Clothes[tMdl.sex and 2 or 1][tbl.AClothes[k]] or hg.Appearance.Clothes[tMdl.sex and 2 or 1]["normal"] )
            Entity:SetNWString("Colthes" .. k,tbl.AClothes[k])
        end
        for i = 1, #mats do
            if hg.Appearance.FacemapsSlots[mats[i]] and hg.Appearance.FacemapsSlots[mats[i]][tbl.AFacemap] then
                Entity:SetSubMaterial(i - 1, hg.Appearance.FacemapsSlots[mats[i]][tbl.AFacemap])
            end
        end
        local bodygroups = Entity:GetBodyGroups()
        tbl.ABodygroups = tbl.ABodygroups or {}
        for k, v in ipairs(bodygroups) do
            if !tbl.ABodygroups[v.name] then continue end
            for i = 0, #v.submodels do
                local b = v.submodels[i]
                if not hg.Appearance.Bodygroups[v.name][tMdl.sex and 2 or 1][tbl.ABodygroups[v.name]] then continue end
                if hg.Appearance.Bodygroups[v.name][tMdl.sex and 2 or 1][tbl.ABodygroups[v.name]][1] != b then continue end
                Entity:SetBodygroup(k-1,i)
            end
        end

        if IsValid(Entity) and Entity:LookupBone("ValveBiped.Bip01_Head1") then
            funpos1x = lookX * 75
            funpos3x = -lookX * 75
        end
    end

    function viewer:PostDrawModel(Entity)
        local tbl = main.AppearanceTable

        for k,attach in ipairs(tbl.AAttachments) do
            DrawAccesories(Entity, Entity, attach, hg.Accessories[attach],false,true)
        end
        Entity:SetupBones()
    end

    function viewer.Entity:GetPlayerColor() return end

    function viewer:PaintOver(w,h)
        --surface.SetDrawColor(colors.highlightText)
        --surface.DrawOutlinedRect(0,0,w,h,1)
    end

    local upPanel = vgui.Create("DPanel",viewer)
    upPanel:Dock(TOP)
    upPanel:DockMargin(ScreenScale(164),0,ScreenScale(164),0)
    upPanel:SetSize(1,ScreenScale(15))
    function upPanel:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,colors.secondary)
    end

    local modelSelector = vgui.Create( "DComboBox", upPanel )
    modelSelector:SetSize(ScreenScale(164),ScreenScale(15))
    modelSelector:SetFont("ZCity_Tiny")
    modelSelector:SetText(main.AppearanceTable.AModel)
    modelSelector:Dock(FILL)
    modelSelector:SetContentAlignment(5)
    function modelSelector:OnSelect(i,str)
        main.AppearanceTable.AModel = str
    end

    for k, v in pairs(APmodule.PlayerModels[1]) do
        modelSelector:AddChoice(k)
    end

    for k, v in pairs(APmodule.PlayerModels[2]) do
        modelSelector:AddChoice(k)
    end

    -- Main bottom container
    local bottomContainer = vgui.Create("DPanel", viewer)
    bottomContainer:Dock(BOTTOM)
    bottomContainer:SetSize(1, ScreenScale(50))
    bottomContainer:DockMargin(ScreenScale(100), 0, ScreenScale(100), ScreenScale(8))
    function bottomContainer:Paint(w, h) end

    -- Down panel (original controls)
    local downPanel = vgui.Create("DPanel", bottomContainer)
    downPanel:Dock(BOTTOM)
    downPanel:SetSize(1, ScreenScale(15))
    downPanel:DockMargin(ScreenScale(44), 0, ScreenScale(44), 0)
    function downPanel:Paint(w,h) end

    local backViewButton = vgui.Create("DButton",downPanel)
    backViewButton:SetSize(ScreenScale(72),ScreenScale(15))
    backViewButton:SetFont("ZCity_Tiny")
    backViewButton:SetText("Rotate")
    backViewButton:Dock(LEFT)
    function backViewButton:DoClick()
        viewer.Rotate = not viewer.Rotate
        surface.PlaySound("pwb2/weapons/iron.wav")
    end
    function backViewButton:Paint(w,h)
        draw.RoundedBox(4,0,0,w,h,colors.secondary)
        surface.SetDrawColor(colors.scrollbarBorder)
        surface.DrawOutlinedRect(0,0,w,h,1)
    end

    local ApplyButton = vgui.Create("DButton",downPanel)
    ApplyButton:SetSize(ScreenScale(72),ScreenScale(15))
    ApplyButton:SetFont("ZCity_Tiny")
    ApplyButton:SetText("Apply")
    ApplyButton:Dock(RIGHT)
    function ApplyButton:DoClick()
        hg.Appearance.CreateAppearanceFile(hg.Appearance.SelectedAppearance:GetString(),main.AppearanceTable)

        net.Start("OnlyGet_Appearance")
            net.WriteTable(main.AppearanceTable)
        net.SendToServer()

        surface.PlaySound("pwb2/weapons/iron.wav")
        main:Close()
    end

    function ApplyButton:Paint(w,h)
        draw.RoundedBox(4,0,0,w,h,colors.selectionBG)
        surface.SetDrawColor(Color(30, 160, 35, 255))
        surface.DrawOutlinedRect(0,0,w,h,1)
    end

    local NameEntry = vgui.Create("DTextEntry",downPanel)
    NameEntry:SetSize(ScreenScale(164),ScreenScale(15))
    NameEntry:SetFont("ZCity_Tiny")
    NameEntry:SetText(main.AppearanceTable.AName)
    NameEntry:Dock(FILL)
    NameEntry:DockMargin(ScreenScale(4), 0, ScreenScale(4), 0)
    NameEntry:SetContentAlignment(5)
    function NameEntry:OnChange()
        main.AppearanceTable.AName = self:GetValue()
    end
    function NameEntry:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(20, 20, 25, 240))
        surface.SetDrawColor(colors.scrollbarBorder)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        self:DrawTextEntryText(colors.mainText, colors.selectionBG, colors.mainText)
    end

    local presetsPanel = vgui.Create("DPanel", bottomContainer)
    presetsPanel:Dock(BOTTOM)
    presetsPanel:SetSize(1, ScreenScale(16))
    presetsPanel:DockMargin(ScreenScale(60), 0, ScreenScale(60), ScreenScale(4))
    function presetsPanel:Paint(w, h) end

    local savePresetBtn = vgui.Create("DButton", presetsPanel)
    savePresetBtn:Dock(LEFT)
    savePresetBtn:SetSize(ScreenScale(30), ScreenScale(16))
    savePresetBtn:SetFont("ZCity_Tiny")
    savePresetBtn:SetText("Save")
    savePresetBtn:SetTextColor(colors.mainText)
    savePresetBtn:DockMargin(0,0,5,0)
    function savePresetBtn:Paint(w, h)
        local bgCol = self:IsHovered() and Color(30, 150, 35, 255) or colors.selectionBG
        draw.RoundedBox(4, 0, 0, w, h, bgCol)
        surface.SetDrawColor(Color(40, 180, 45, 255))
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    local presetNameEntry

    function savePresetBtn:DoClick()
        local presetName = presetNameEntry:GetValue()
        if presetName == "" or #presetName < 2 then
            surface.PlaySound("buttons/button10.wav")
            notification.AddLegacy("Enter a preset name (min 2 chars)", NOTIFY_ERROR, 3)
            return
        end
        
        presetName = string.gsub(presetName, "[^%w%s_-]", "")
        
        SavePreset(presetName, main.AppearanceTable)
        surface.PlaySound("buttons/button14.wav")
        notification.AddLegacy("Preset '" .. presetName .. "' saved!", NOTIFY_GENERIC, 3)
    end

    local loadPresetBtn = vgui.Create("DButton", presetsPanel)
    loadPresetBtn:Dock(LEFT)
    loadPresetBtn:SetSize(ScreenScale(30), ScreenScale(20))
    loadPresetBtn:SetFont("ZCity_Tiny")
    loadPresetBtn:SetText("Load")
    loadPresetBtn:SetTextColor(colors.mainText)
    loadPresetBtn:DockMargin(0,0,5,0)
    function loadPresetBtn:Paint(w, h)
        local bgCol = self:IsHovered() and Color(50, 100, 180, 255) or Color(35, 75, 150, 230)
        draw.RoundedBox(4, 0, 0, w, h, bgCol)
        surface.SetDrawColor(Color(60, 120, 200, 255))
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    function loadPresetBtn:DoClick()
        local presetList = GetPresetList()
        if #presetList == 0 then
            surface.PlaySound("buttons/button10.wav")
            notification.AddLegacy("No presets saved yet!", NOTIFY_ERROR, 3)
            return
        end
        
        local presetMenu = vgui.Create("DFrame")
        presetMenu:SetTitle("Load Preset")
        presetMenu:SetSize(ScreenScale(120), ScreenScale(100))
        presetMenu:Center()
        presetMenu:MakePopup()
        presetMenu:SetDraggable(false)
        
        function presetMenu:Paint(w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(20, 20, 28, 250))
            surface.SetDrawColor(colors.presetBorder)
            surface.DrawOutlinedRect(0, 0, w, h, 2)
            draw.RoundedBoxEx(8, 0, 0, w, ScreenScale(12), colors.secondary, true, true, false, false)
        end
        
        local scroll = CreateStyledScrollPanel(presetMenu)
        scroll:Dock(FILL)
        scroll:DockMargin(ScreenScale(2), ScreenScale(2), ScreenScale(2), ScreenScale(2))
        
        for _, presetName in ipairs(presetList) do
            local presetBtn = vgui.Create("DButton", scroll)
            presetBtn:Dock(TOP)
            presetBtn:DockMargin(2, 2, 2, 0)
            presetBtn:SetTall(ScreenScale(14))
            presetBtn:SetFont("ZCity_Tiny")
            presetBtn:SetText(presetName)
            presetBtn:SetTextColor(colors.mainText)
            
            function presetBtn:Paint(w, h)
                local bgCol = self:IsHovered() and colors.presetHover or colors.presetBG
                draw.RoundedBox(4, 0, 0, w, h, bgCol)
                surface.SetDrawColor(colors.scrollbarBorder)
                surface.DrawOutlinedRect(0, 0, w, h, 1)
            end
            
            function presetBtn:DoClick()
                local loadedPreset = LoadPreset(presetName)
                if loadedPreset then
                    main.AppearanceTable = loadedPreset
                    NameEntry:SetText(loadedPreset.AName or "")
                    modelSelector:SetText(loadedPreset.AModel or "Male 01")
                    presetNameEntry:SetText(presetName)
                    surface.PlaySound("buttons/button14.wav")
                    notification.AddLegacy("Preset '" .. presetName .. "' loaded!", NOTIFY_GENERIC, 3)
                else
                    surface.PlaySound("buttons/button10.wav")
                    notification.AddLegacy("Failed to load preset!", NOTIFY_ERROR, 3)
                end
                presetMenu:Close()
            end
            
            function presetBtn:DoRightClick()
                local confirmMenu = DermaMenu()
                confirmMenu:AddOption("Delete '" .. presetName .. "'", function()
                    DeletePreset(presetName)
                    surface.PlaySound("buttons/button15.wav")
                    notification.AddLegacy("Preset deleted!", NOTIFY_HINT, 2)
                    presetBtn:Remove()
                end):SetIcon("icon16/cross.png")
                confirmMenu:Open()
            end
        end
    end

    local deletePresetBtn = vgui.Create("DButton", presetsPanel)
    deletePresetBtn:Dock(LEFT)
    deletePresetBtn:SetSize(ScreenScale(35), ScreenScale(20))
    deletePresetBtn:SetFont("ZCity_Tiny")
    deletePresetBtn:SetText("Delete")
    deletePresetBtn:SetTextColor(colors.mainText)
    function deletePresetBtn:Paint(w, h)
        local bgCol = self:IsHovered() and Color(180, 50, 50, 255) or Color(140, 40, 40, 230)
        draw.RoundedBox(4, 0, 0, w, h, bgCol)
        surface.SetDrawColor(Color(200, 60, 60, 255))
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    function deletePresetBtn:DoClick()
        local presetName = presetNameEntry:GetValue()
        if presetName == "" then
            surface.PlaySound("buttons/button10.wav")
            notification.AddLegacy("Enter preset name to delete", NOTIFY_ERROR, 3)
            return
        end
        
        if DeletePreset(presetName) then
            surface.PlaySound("buttons/button15.wav")
            notification.AddLegacy("Preset '" .. presetName .. "' deleted!", NOTIFY_HINT, 3)
            presetNameEntry:SetText("")
        else
            surface.PlaySound("buttons/button10.wav")
            notification.AddLegacy("Preset not found!", NOTIFY_ERROR, 3)
        end
    end

    presetNameEntry = vgui.Create("DTextEntry", presetsPanel)
    presetNameEntry:Dock(FILL)
    presetNameEntry:SetSize(ScreenScale(80), ScreenScale(20))
    presetNameEntry:SetFont("ZCity_Tiny")
    presetNameEntry:SetPlaceholderText("Preset name...")
    presetNameEntry:SetContentAlignment(5)
    presetNameEntry:DockMargin(5,0,0,0)
    function presetNameEntry:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(15, 15, 20, 255))
        surface.SetDrawColor(colors.scrollbarBorder)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        self:DrawTextEntryText(colors.mainText, colors.selectionBG, colors.mainText)
    end

    local previewAccessory = {nil, nil, nil}  -- [1] = hat, [2] = face, [3] = body
    local originalAccessory = {nil, nil, nil}

    local accessoryMenus = {}
    local function CloseAllAccessoryMenus()
        for _, menu in ipairs(accessoryMenus) do
            if IsValid(menu) then menu:Close() end
        end
        accessoryMenus = {}
    end

    local hatSelector = vgui.Create("DButton",viewer)
    hatSelector:SetSize(ScreenScale(100),ScreenScale(16))
    hatSelector:SetFont("ZCity_Tiny")
    hatSelector:SetText("Hats")
    function hatSelector:Think()
        if funpos1x then
            hatSelector:SetPos(sizeX * 0.2 + funpos1x, sizeY * 0.2)
        end
    end

    function hatSelector:Paint(w,h)
        draw.RoundedBox(4,0,0,w,h,colors.secondary)
        surface.SetDrawColor(colors.scrollbarBorder)
        surface.DrawOutlinedRect(0,0,w,h,1)
    end
    
    function hatSelector:DoClick()
        main.modelPosID = "Head"
        CloseAllAccessoryMenus()
        
        originalAccessory[1] = main.AppearanceTable.AAttachments[1]
        
        hatSelectMenu = CreateStyledAccessoryMenu(nil, "Select Hat")
        table.insert(accessoryMenus, hatSelectMenu)
        
        for k, v in pairs(hg.Accessories) do
            if v.placement != "head" and v.placement != "ears" then continue end
            if not lply:PS_HasItem(k) and v.bPointShop and !hg.Appearance.GetAccessToAll(lply) then continue end
            
            hatSelectMenu:AddAccessoryIcon(v.model, k, v, 
                function(accessorKey)
                    main.AppearanceTable.AAttachments[1] = accessorKey
                    previewAccessory[1] = nil
                end,
                function(accessorKey, isPreviewing)
                    if isPreviewing then
                        previewAccessory[1] = accessorKey
                        main.AppearanceTable.AAttachments[1] = accessorKey
                    else
                        previewAccessory[1] = nil
                        main.AppearanceTable.AAttachments[1] = originalAccessory[1]
                    end
                end
            )
        end
        
        hatSelectMenu:AddNoneOption(function()
            main.AppearanceTable.AAttachments[1] = "none"
            previewAccessory[1] = nil
        end)
        
        function hatSelectMenu:OnClose()
            if previewAccessory[1] then
                main.AppearanceTable.AAttachments[1] = originalAccessory[1]
                previewAccessory[1] = nil
            end
            main.modelPosID = "All"
        end

        function hatSelectMenu:OnFocusChanged(gained)
            if !gained then self:Close() end
        end
    end

    local faceSelector = vgui.Create("DButton",viewer)
    faceSelector:SetSize(ScreenScale(100),ScreenScale(16))
    faceSelector:SetFont("ZCity_Tiny")
    faceSelector:SetText("Face")
    function faceSelector:Think()
        if funpos1x then
            faceSelector:SetPos(sizeX * 0.2 + funpos1x, sizeY * 0.2 + ScreenScale(32))
        end
    end
    function faceSelector:Paint(w,h)
        draw.RoundedBox(4,0,0,w,h,colors.secondary)
        surface.SetDrawColor(colors.scrollbarBorder)
        surface.DrawOutlinedRect(0,0,w,h,1)
    end
    
    function faceSelector:DoClick()
        main.modelPosID = "Face"
        CloseAllAccessoryMenus()
        
        originalAccessory[2] = main.AppearanceTable.AAttachments[2]
        
        faceSelectorMenu = CreateStyledAccessoryMenu(nil, "Select Face Accessory")
        table.insert(accessoryMenus, faceSelectorMenu)
        
        for k, v in pairs(hg.Accessories) do
            if v.placement != "face" then continue end
            if not lply:PS_HasItem(k) and v.bPointShop and !hg.Appearance.GetAccessToAll(lply) then continue end
            
            faceSelectorMenu:AddAccessoryIcon(v.model, k, v,
                function(accessorKey)
                    main.AppearanceTable.AAttachments[2] = accessorKey
                    previewAccessory[2] = nil
                end,
                function(accessorKey, isPreviewing)
                    if isPreviewing then
                        previewAccessory[2] = accessorKey
                        main.AppearanceTable.AAttachments[2] = accessorKey
                    else
                        previewAccessory[2] = nil
                        main.AppearanceTable.AAttachments[2] = originalAccessory[2]
                    end
                end
            )
        end
        
        faceSelectorMenu:AddNoneOption(function()
            main.AppearanceTable.AAttachments[2] = "none"
            previewAccessory[2] = nil
        end)
        
        function faceSelectorMenu:OnClose()
            if previewAccessory[2] then
                main.AppearanceTable.AAttachments[2] = originalAccessory[2]
                previewAccessory[2] = nil
            end
            main.modelPosID = "All"
        end

        function faceSelectorMenu:OnFocusChanged(gained)
            if !gained then self:Close() end
        end
    end

    local bodySelector = vgui.Create("DButton",viewer)
    bodySelector:SetSize(ScreenScale(100),ScreenScale(16))
    bodySelector:SetFont("ZCity_Tiny")
    bodySelector:SetText("Body")
    function bodySelector:Think()
        if funpos3x then
            bodySelector:SetPos(sizeX * 0.2 - funpos3x, sizeY * 0.2 + ScreenScale(64))
        end
    end
    function bodySelector:Paint(w,h)
        draw.RoundedBox(4,0,0,w,h,colors.secondary)
        surface.SetDrawColor(colors.scrollbarBorder)
        surface.DrawOutlinedRect(0,0,w,h,1)
    end
    bodySelector:SetPos(sizeX * 0.7, sizeY * 0.5)
    
    function bodySelector:DoClick()
        main.modelPosID = "Torso"
        CloseAllAccessoryMenus()
        
        originalAccessory[3] = main.AppearanceTable.AAttachments[3]
        
        bodySelectorMenu = CreateStyledAccessoryMenu(nil, "Select Body Accessory")
        table.insert(accessoryMenus, bodySelectorMenu)
        
        for k, v in pairs(hg.Accessories) do
            if v.placement != "torso" and v.placement != "spine" then continue end
            if not lply:PS_HasItem(k) and v.bPointShop and !hg.Appearance.GetAccessToAll(lply) then continue end
            
            bodySelectorMenu:AddAccessoryIcon(v.model, k, v,
                function(accessorKey)
                    main.AppearanceTable.AAttachments[3] = accessorKey
                    previewAccessory[3] = nil
                end,
                function(accessorKey, isPreviewing)
                    if isPreviewing then
                        previewAccessory[3] = accessorKey
                        main.AppearanceTable.AAttachments[3] = accessorKey
                    else
                        previewAccessory[3] = nil
                        main.AppearanceTable.AAttachments[3] = originalAccessory[3]
                    end
                end
            )
        end
        
        bodySelectorMenu:AddNoneOption(function()
            main.AppearanceTable.AAttachments[3] = "none"
            previewAccessory[3] = nil
        end)
        
        function bodySelectorMenu:OnClose()
            if previewAccessory[3] then
                main.AppearanceTable.AAttachments[3] = originalAccessory[3]
                previewAccessory[3] = nil
            end

            main.modelPosID = "All"
        end

        function bodySelectorMenu:OnFocusChanged(gained)
            if !gained then self:Close() end
        end
    end

    local bodyMatSelector = vgui.Create("DButton",viewer)
    bodyMatSelector:SetSize(ScreenScale(100),ScreenScale(16))
    bodyMatSelector:SetFont("ZCity_Tiny")
    bodyMatSelector:SetText("Jacket")
    function bodyMatSelector:Think()
        if funpos3x then
            bodyMatSelector:SetPos(sizeX * 0.65 - funpos3x, sizeY * 0.2)
        end
    end
    function bodyMatSelector:Paint(w,h)
        draw.RoundedBox(4,0,0,w,h,colors.secondary)
        surface.SetDrawColor(colors.scrollbarBorder)
        surface.DrawOutlinedRect(0,0,w,h,1)
    end
    bodyMatSelector:SetPos(sizeX * 0.7, sizeY * 0.5)
    function bodyMatSelector:DoClick()
        main.modelPosID = "Torso"
        bodyMatSelectorMenu = DermaMenu()
        for k, v in pairs(hg.Appearance.Clothes[tMdl.sex and 2 or 1]) do
            local mater = bodyMatSelectorMenu:AddOption(k,function()
				surface.PlaySound("player/weapon_draw_0"..math.random(2, 5)..".wav")
                main.AppearanceTable.AClothes.main = k
            end)
            if hg.Appearance.ClothesDesc[k] then
                mater:SetTooltip(hg.Appearance.ClothesDesc[k].desc)
                if hg.Appearance.ClothesDesc[k].link then
                    function mater:DoRightClick()
                        gui.OpenURL(hg.Appearance.ClothesDesc[k].link)
                    end
                end
            end
        end
        local colorSelector = vgui.Create("DColorCombo",bodyMatSelectorMenu)
        function colorSelector:OnValueChanged(clr)
            main.AppearanceTable.AColor = clr
        end
        colorSelector:SetColor(main.AppearanceTable.AColor)
        bodyMatSelectorMenu:AddPanel(colorSelector)
        bodyMatSelectorMenu:Open()
        function bodyMatSelectorMenu:OnRemove()
            main.modelPosID = "All"
        end
    end

    local legsMatSelector = vgui.Create("DButton",viewer)
    legsMatSelector:SetSize(ScreenScale(100),ScreenScale(16))
    legsMatSelector:SetFont("ZCity_Tiny")
    legsMatSelector:SetText("Pants")
    function legsMatSelector:Think()
        if funpos3x then
            legsMatSelector:SetPos(sizeX * 0.65 - funpos3x, sizeY * 0.2 + ScreenScale(32))
        end
    end
    function legsMatSelector:Paint(w,h)
        draw.RoundedBox(4,0,0,w,h,colors.secondary)
        surface.SetDrawColor(colors.scrollbarBorder)
        surface.DrawOutlinedRect(0,0,w,h,1)
    end
    legsMatSelector:SetPos(sizeX * 0.7, sizeY * 0.5)
    function legsMatSelector:DoClick()
        main.modelPosID = "Legs"
        legsMatSelectorMenu = DermaMenu()
        for k, v in pairs(hg.Appearance.Clothes[tMdl.sex and 2 or 1]) do
            local mater = legsMatSelectorMenu:AddOption(k,function()
				surface.PlaySound("player/weapon_draw_0"..math.random(2, 5)..".wav")
                main.AppearanceTable.AClothes.pants = k
            end)
            if hg.Appearance.ClothesDesc[k] then
                mater:SetTooltip(hg.Appearance.ClothesDesc[k].desc)
                if hg.Appearance.ClothesDesc[k].link then
                    function mater:DoRightClick()
                        gui.OpenURL(hg.Appearance.ClothesDesc[k].link)
                    end
                end
            end
        end
        legsMatSelectorMenu:Open()
        function legsMatSelectorMenu:OnRemove()
            main.modelPosID = "All"
        end
    end

    local bootsMatSelector = vgui.Create("DButton",viewer)
    bootsMatSelector:SetSize(ScreenScale(100),ScreenScale(16))
    bootsMatSelector:SetFont("ZCity_Tiny")
    bootsMatSelector:SetText("Boots")
    function bootsMatSelector:Think()
        if funpos3x then
            bootsMatSelector:SetPos(sizeX * 0.65 - funpos3x, sizeY * 0.2 + ScreenScale(64))
        end
    end
    function bootsMatSelector:Paint(w,h)
        draw.RoundedBox(4,0,0,w,h,colors.secondary)
        surface.SetDrawColor(colors.scrollbarBorder)
        surface.DrawOutlinedRect(0,0,w,h,1)
    end
    bootsMatSelector:SetPos(sizeX * 0.7, sizeY * 0.5)
    function bootsMatSelector:DoClick()
        main.modelPosID = "Boots"
        bootsMatSelectorMenu = DermaMenu()
        for k, v in pairs(hg.Appearance.Clothes[tMdl.sex and 2 or 1]) do
            local mater = bootsMatSelectorMenu:AddOption(k,function()
				surface.PlaySound("player/weapon_draw_0"..math.random(2, 5)..".wav")
                main.AppearanceTable.AClothes.boots = k
            end)
            if hg.Appearance.ClothesDesc[k] then
                mater:SetTooltip(hg.Appearance.ClothesDesc[k].desc)
                if hg.Appearance.ClothesDesc[k].link then
                    function mater:DoRightClick()
                        gui.OpenURL(hg.Appearance.ClothesDesc[k].link)
                    end
                end
            end
        end
        bootsMatSelectorMenu:Open()
        function bootsMatSelectorMenu:OnRemove()
            main.modelPosID = "All"
        end
    end

    local glovesSelector = vgui.Create("DButton",viewer)
    glovesSelector:SetSize(ScreenScale(100),ScreenScale(16))
    glovesSelector:SetFont("ZCity_Tiny")
    glovesSelector:SetText("Gloves")
    function glovesSelector:Think()
        if funpos3x then
            glovesSelector:SetPos(sizeX * 0.65 - funpos3x, sizeY * 0.2 + ScreenScale(96))
        end
    end
    function glovesSelector:Paint(w,h)
        draw.RoundedBox(4,0,0,w,h,colors.secondary)
        surface.SetDrawColor(colors.scrollbarBorder)
        surface.DrawOutlinedRect(0,0,w,h,1)
    end
    glovesSelector:SetPos(sizeX * 0.7, sizeY * 0.5)
    function glovesSelector:DoClick()
        main.modelPosID = "Hands"
        glovesSelectorMenu = DermaMenu()
        for k, v in pairs(hg.Appearance.Bodygroups["HANDS"][tMdl.sex and 2 or 1]) do
            if not lply:PS_HasItem(v["ID"]) and v[2] and !hg.Appearance.GetAccessToAll(lply) then continue end
            glovesSelectorMenu:AddOption(k,function()
				surface.PlaySound("player/weapon_draw_0"..math.random(2, 5)..".wav")
                main.AppearanceTable.ABodygroups = main.AppearanceTable.ABodygroups or {}
                main.AppearanceTable.ABodygroups["HANDS"] = k
            end)
        end
        glovesSelectorMenu:Open()
        function glovesSelectorMenu:OnRemove()
            main.modelPosID = "All"
        end
    end

    local faceMatSelector = vgui.Create("DButton",viewer)
    faceMatSelector:SetSize(ScreenScale(100),ScreenScale(16))
    faceMatSelector:SetFont("ZCity_Tiny")
    faceMatSelector:SetText("Facemap")
    function faceMatSelector:Think()
        if funpos3x then
            faceMatSelector:SetPos(sizeX * 0.65 - funpos3x, sizeY * 0.2 + ScreenScale(96 + 32))
        end
    end
    function faceMatSelector:Paint(w,h)
        draw.RoundedBox(4,0,0,w,h,colors.secondary)
        surface.SetDrawColor(colors.scrollbarBorder)
        surface.DrawOutlinedRect(0,0,w,h,1)
    end
    faceMatSelector:SetPos(sizeX * 0.7, sizeY * 0.5)
    function faceMatSelector:DoClick()
        main.modelPosID = "Face"
        faceMatSelectorMenu = DermaMenu()
        for k, v in SortedPairs(hg.Appearance.FacemapsSlots[hg.Appearance.FacemapsModels[tMdl.mdl]]) do
            local mater = faceMatSelectorMenu:AddOption(k,function()
				surface.PlaySound("player/weapon_draw_0"..math.random(2, 5)..".wav")
                main.AppearanceTable.AFacemap = k
            end)
        end
        faceMatSelectorMenu:Open()
        function faceMatSelectorMenu:OnRemove()
            main.modelPosID = "All"
        end
    end
    --backViewButton:

    local oldClose = self.Close
    function self:Close()
        CloseAllAccessoryMenus()
        if oldClose then oldClose(self) end
    end
    self:CallbackAppearance()
end

vgui.Register( "HG_AppearanceMenu", PANEL, "ZFrame")

concommand.Add("hg_appearance_menu",function()
    if hg.Appearance.PrecacheModels then
        hg.Appearance.PrecacheModels()
    end
    
    hg.PointShop:SendNET( "SendPointShopVars", nil, function( data )
        if IsValid(zpan) then
            zpan:Close()
        end
        zpan = vgui.Create("HG_AppearanceMenu")
        zpan:SetSize(sizeX,sizeY)
        zpan:SetPos()
        zpan:MakePopup()
    end)
end)