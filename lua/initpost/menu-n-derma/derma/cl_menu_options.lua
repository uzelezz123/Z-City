hg.settings = hg.settings or {}
hg.settings.tbl = hg.settings.tbl or {}

function hg.settings:AddOpt( strCategory, strConVar, strTitle, bDecimals, bString )
    self.tbl[strCategory] = self.tbl[strCategory] or {}
    self.tbl[strCategory][strConVar] = { strCategory, strConVar, strTitle, bDecimals or false, bString or false }
end
local hg_firstperson_death = CreateClientConVar("hg_firstperson_death", "0", true, false, "Toggle first-person death camera view", 0, 1)
local hg_font = CreateClientConVar("hg_font", "Bahnschrift", true, false, "change every text font to selected because ui customization is cool")
local hg_attachment_draw_distance = CreateClientConVar("hg_attachment_draw_distance", 0, true, nil, "distance to draw attachments", 0, 4096)

xbars = 17
ybars = 30

gradient_l = Material("vgui/gradient-l")

local blur = Material("pp/blurscreen")
local blur2 = Material("effects/shaders/zb_blur" )
local sw, sh = ScrW(), ScrH()

local font = function() -- hg_coolvetica:GetBool() and "Coolvetica" or "Bahnschrift"
    local usefont = "Bahnschrift"

    if hg_font:GetString() != "" then
        usefont = hg_font:GetString()
    end

    return usefont
end

surface.CreateFont("ZCity_setiings_tiny", {
	font = font(),
	size = ScreenScale(7),
	weight = 100
})

surface.CreateFont("ZCity_setiings_fine", {
	font = font(),
	size = ScreenScale(10),
	weight = 100
})


hg.settings:AddOpt("Gameplay","hg_old_notificate", "Old Notifications")
hg.settings:AddOpt("Gameplay","hg_cheats", "Enable/Disable Cheats")


hg.settings:AddOpt("Optimization","hg_potatopc", "Potato PC Mode")
hg.settings:AddOpt("Optimization","hg_anims_draw_distance", "Animations Draw Distance")
hg.settings:AddOpt("Optimization","hg_anim_fps", "Animations FPS")
hg.settings:AddOpt("Optimization","hg_attachment_draw_distance", "Attachment Draw Distance")
hg.settings:AddOpt("Optimization","hg_maxsmoketrails", "Maximum Smoke Trails")
hg.settings:AddOpt("Optimization","hg_tpik_distance", "TPIK Render Distance")

hg.settings:AddOpt("Blood","hg_blood_draw_distance", "Blood Draw Distance")
hg.settings:AddOpt("Blood","hg_blood_fps", "Blood FPS")
hg.settings:AddOpt("Blood","hg_blood_sprites", "Blood Sprites (DISABLED FOR EVERYONE)")

hg.settings:AddOpt("UI","hg_font", "Change Custom Font", false, true)

hg.settings:AddOpt("Weapons","hg_weaponshotblur_enable", "Shooting Blur")
hg.settings:AddOpt("Weapons","hg_dynamic_mags", "Dynamic Ammo Inspect")

hg.settings:AddOpt("View","hg_firstperson_death", "First-Person Death")
hg.settings:AddOpt("View","hg_fov", "Field Of View")
hg.settings:AddOpt("View","hg_newspectate", "Smooth Spectator Camera")
hg.settings:AddOpt("View","hg_change_gloves", "Gloves Model")
hg.settings:AddOpt("View","hg_cshs_fake", "C'sHS Ragdoll Camera")
hg.settings:AddOpt("View","hg_gun_cam", "Gun Camera (ADMIN ONLY)")
hg.settings:AddOpt("View","hg_nofovzoom", "Disable/Enable FOV Zoom")
  
hg.settings:AddOpt("Sound","hg_dmusic", "Dynamic Music")

hg.settings:AddOpt("Sound","hg_quietshots", "Enable/Disable Quietshoot Sounds (FOR PUSSY)")


function hg.CreateCategory(ctgName, ParentPanel, yPos)
    local pppanel = vgui.Create('DPanel', ParentPanel)
    pppanel:SetSize(ParentPanel:GetWide()/1.05, ParentPanel:GetTall()/12)
    pppanel:SetPos(ParentPanel:GetWide()/2-pppanel:GetWide()/2, yPos)
    --pppanel:SetText(ctgName)
    pppanel.Paint = function(self,w,h)
        surface.SetDrawColor(60,60,60,145)
        surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(42, 42, 42, 184)
		surface.DrawRect(0, h-5, w, 5)
    
        draw.SimpleText(ctgName, 'ZCity_Fixed_Medium', w / 2, h / 2, color3, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    return pppanel
end

function hg.GetConVarType(convar)
    local stringv = convar:GetString()
    local floatVal = convar:GetFloat()
    local intVal = convar:GetInt()
    local boolVal = convar:GetBool()

    if (stringv == '0' and not boolVal) or (stringv == '1' and boolVal) then
        return 'bool'
    end

    if tonumber(stringv) and math.floor(stringv) == floatVal then
        if intVal == floatVal then
            return "int"
        end
    end

    return "string"
end
local clr_1 = Color(255,255,255,104)
local clr_2 = Color(122,122,122,104)
local clr_3 = Color(28,28,28)
local clr_4 = Color(0, 0, 0, 30)
local clr_5 = Color(30, 29, 29, 30)
local clr_6 = Color(255, 255, 255, 100)
local clr_7 = Color(255, 255, 255, 200)
local clr_8 = Color(70, 130, 180)
function hg.CreateButton(buttonData, convarName, ParentPanel, yPos)
    local convar = GetConVar(convarName)

    if not convar then 
        return 
    end
    local pppanel = vgui.Create('DPanel', ParentPanel)
    pppanel:SetSize(ParentPanel:GetWide()/1.05, ParentPanel:GetTall()/15)
    pppanel:SetPos(ParentPanel:GetWide()/2-pppanel:GetWide()/2, yPos)
    
    surface.SetFont('ZCity_setiings_fine')
    local width2, height2 = surface.GetTextSize(buttonData[3])
    
    local convarType = hg.GetConVarType(convar)
    pppanel.Paint = function(self,w,h)
        surface.SetDrawColor(43, 43, 43,145)
        surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(47, 47, 47,145)
		surface.DrawRect(0, h-3, w, 3)
        
        draw.SimpleText(buttonData[3], 'ZCity_setiings_fine', 30, h / 2 -height2/2.5, clr_1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(convar:GetHelpText(), 'ZCity_setiings_tiny', 30, h / 2+height2/2, clr_2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    if convarType == 'bool' then
        local toggle = vgui.Create('DButton', pppanel)
        toggle:SetSize(pppanel:GetWide() / 18, pppanel:GetTall() / 2)

        
        toggle:SetPos(pppanel:GetWide() - toggle:GetWide()*1.4 - pppanel:GetWide() / 20, pppanel:GetTall() / 2 - toggle:GetTall() / 2)
        toggle:SetText('')
        
        local animProgress = convar:GetBool() and 1 or 0
        local targetProgress = animProgress
        
        function toggle:Paint(w, h)
            if animProgress ~= targetProgress then
                animProgress = Lerp(FrameTime() * 8, animProgress, targetProgress)
            end
            
            local bgColor = Color(
                Lerp(animProgress, 180, 80),  
                Lerp(animProgress, 30, 120),  
                Lerp(animProgress, 30, 50)   
            )
            
            local shadowColor = Color(0, 0, 0, Lerp(animProgress, 150, 40))
            surface.SetDrawColor(clr_3)
            draw.RoundedBox(0, 0, 0, w, h, clr_3)
            
            surface.SetDrawColor(clr_5)
            draw.RoundedBox(0, 2, 2, w - 4, h - 4, clr_4)
            
            local slsize = h - 12
            local slPos = Lerp(animProgress, 6, w - slsize - 6)
            surface.SetDrawColor(bgColor)
            draw.RoundedBox(0, slPos, 6, slsize, slsize, bgColor)
            surface.SetDrawColor(shadowColor)
            surface.DrawRect(slPos, slsize+4, slsize, 3)
    
            surface.SetDrawColor(clr_6)
        end
        
        function toggle:DoClick()
            if convar then
                convar:SetBool(not convar:GetBool())

                surface.PlaySound('glide/headlights_on.wav')
                targetProgress = convar:GetBool() and 1 or 0
            end
        end
        
    elseif convarType == 'int' then
        local slider = vgui.Create('DNumSlider', pppanel)
        slider:SetSize(280, 30)
        slider:SetPos(pppanel:GetWide() - 300, pppanel:GetTall() / 2 - 15)
        slider:SetText('')
        
        local min = buttonData[4] or 0
        local max = buttonData[5] or 100
        local decimals = 0 
        
        slider:SetMin(min)
        slider:SetMax(max)
        slider:SetDecimals(decimals)
        slider:SetValue(convar:GetInt())
        
        function slider:OnValueChanged(val)
            if convar then
                convar:SetInt(math.Round(val))
            end
        end
        
        local valueLabel = vgui.Create('DLabel', pppanel)
        valueLabel:SetPos(pppanel:GetWide() - 350, pppanel:GetTall() / 2 - 8)
        valueLabel:SetSize(50, 20)
        valueLabel:SetText(convar:GetInt())
        valueLabel:SetTextColor(clr_7)
        valueLabel:SetFont('ZCity_setiings_tiny')
        
        slider.Think = function()
            if convar then
                valueLabel:SetText(convar:GetInt())
            end
        end
        
    elseif convarType == 'string' then
        local textEntry = vgui.Create('DTextEntry', pppanel)
        textEntry:SetSize(pppanel:GetWide()/8, pppanel:GetTall()/2)
        textEntry:SetPos(pppanel:GetWide()-pppanel:GetWide()/8-20, pppanel:GetTall()/2-textEntry:GetTall()/2)
        textEntry:SetText(convar:GetString())
        textEntry:SetUpdateOnType(true) 
        textEntry:SetFont('ZCity_Tiny')
        
    
        textEntry.Paint = function(self, w, h)
            surface.SetDrawColor(30, 30, 30, 255)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(60, 60, 60, 255)
            surface.DrawOutlinedRect(0, 0, w, h)
            
            self:DrawTextEntryText(color_white, clr_8, color_white)
        end
        
        function textEntry:OnValueChange(val)
            if convar then
                convar:SetString(val)
            end
        end
    end
    
    return pppanel
end

function hg.DrawSettings(ParentPanel)
    ParentPanel:SetAlpha(0)
    ParentPanel.Paint = function(self,w,h)

        surface.SetDrawColor(28,28,28,255)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(107, 107, 107,20)

        for i = 1, (ybars + 1) do
            surface.DrawRect((sw / ybars) * i - (CurTime() * 30 % (sw / ybars)), 0, ScreenScale(1), sh)
        end

        for i = 1, (xbars + 1) do
            surface.DrawRect(0, (sh / xbars) * (i - 1) + (CurTime() * 30 % (sh / xbars)), sw, ScreenScale(1))
        end

        local border_size = ScreenScale(2)

        surface.SetDrawColor(0, 0, 0)
        surface.SetMaterial(gradient_l)
        surface.DrawTexturedRect(0, 0, border_size, sh)
		surface.SetMaterial(blur)
        surface.SetDrawColor(28,28,28,208)
        surface.DrawRect(0, 0, w, h)
    end
    hg.DrawBlur(ParentPanel, 5)
    ParentPanel:AlphaTo(255,0.15,0)
    local pppanel3 = vgui.Create('DScrollPanel', ParentPanel)
    pppanel3:SetSize(ParentPanel:GetWide(), ParentPanel:GetTall())
    pppanel3:SetPos(0,0)
    --pppanel3:SetAlpha(0)
    pppanel3.Paint = function()end
    -- 🥴 <- лучший смайлик

    local yOffset = pppanel3:GetTall()/100

    for categoryName, categoryTable in pairs(hg.settings.tbl) do
        local category = hg.CreateCategory(categoryName, pppanel3, yOffset)
        yOffset = yOffset + category:GetTall() + 12
        for convarName, settingData in pairs(categoryTable) do
            local vbv = hg.CreateButton(settingData,convarName,pppanel3,yOffset)
            if not vbv then continue end
            yOffset = yOffset + (vbv:GetTall()) + 12
        end
    end
    local pppanel23 = vgui.Create('DPanel', pppanel3)
    pppanel23:SetSize(0, 0)
    pppanel23:SetPos(0,yOffset+12)
end