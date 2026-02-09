----
local PANEL = {}

--[[
hg.AddOptionPanel( "hg_potatopc", "switcher", {desc = "Enables weaker effects. Use for weak PCs"}, "optimization" )
hg.AddOptionPanel( "hg_dynamic_mags", "switcher", {desc = "Enables the \"floating Ammo HUD\" feature"}, "other" )
hg.AddOptionPanel( "hg_anims_draw_distance", "slider", {desc = "Changes the rendering distance of animations\nCan help increase FPS | 0 - inf",min = 0,max = 4096}, "optimization" )
hg.AddOptionPanel( "hg_attachment_draw_distance", "slider", {desc = "Changes the rendering distance of attachments\nCan help increase FPS | 0 - inf",min = 0,max = 4096}, "optimization" )
hg.AddOptionPanel( "hg_old_notificate", "switcher", {desc = "Enables old damage notifications (in chat)",min = 0,max = 4096}, "other" )
hg.AddOptionPanel( "hg_weaponshotblur_enable", "switcher", {desc = "Enables blur when you are shooting the weapon",min = 0,max = 4096}, "other" )
hg.AddOptionPanel( "hg_weaponshotblur_mul", "slider", {desc = "Multiplicates the blur that happens when you are shooting the weapon",min = 0,max = 1,decimals = 3}, "other" )
hg.AddOptionPanel( "hg_bulletholes", "slider", {desc = "Amount of bullet hole effects (Rainbow Six Siege-like)",min = 0,max = 500,decimals = 0}, "optimization" )
hg.AddOptionPanel( "hg_maxsmoketrails", "slider", {desc = "Max amount of smoke trail effects (lags after 10)",min = 0,max = 30,decimals = 0}, "optimization" )
hg.AddOptionPanel( "hg_optimise_scopes", "slider", {desc = "Enable this if scoping makes your fps cry (1 - lowers quality of props around you, 2 - \"disables\" main render)",min = 0,max = 2,decimals = 0}, "optimization" )

]]

hg.settings = hg.settings or {}
hg.settings.tbl = hg.settings.tbl or {}


function hg.settings:AddOpt( strCategory, strConVar, strTitle, bDecimals, bString )
    self.tbl[strCategory] = self.tbl[strCategory] or {}
    self.tbl[strCategory][strConVar] = { strCategory, strConVar, strTitle, bDecimals or false, bString or false }
end

hg.settings:AddOpt("Optimization","hg_potatopc", "Potato PC Mode")
hg.settings:AddOpt("Optimization","hg_anims_draw_distance", "Animations Draw Distance")
hg.settings:AddOpt("Optimization","hg_anim_fps", "Animations FPS")
hg.settings:AddOpt("Optimization","hg_attachment_draw_distance", "Attachment Draw Distance")
hg.settings:AddOpt("Optimization","hg_maxsmoketrails", "Maximum Smoke Trails")
hg.settings:AddOpt("Optimization","hg_tpik_distance", "TPIK Render Distance")

hg.settings:AddOpt("Blood","hg_blood_draw_distance", "Blood Draw Distance")
hg.settings:AddOpt("Blood","hg_blood_fps", "Blood FPS")
hg.settings:AddOpt("Blood","hg_blood_sprites", "Blood Sprites (DISABLED FOR EVERYONE)")

--hg.settings:AddOpt("Other","hg_coolvetica", "Coolvetica font")
hg.settings:AddOpt("UI","hg_font", "Change Custom Font", false, true)
hg.settings:AddOpt("UI","hg_nostatic", "Remove static border effects")

hg.settings:AddOpt("Weapons","hg_weaponshotblur_enable", "Shooting Blur")
hg.settings:AddOpt("Weapons","hg_dynamic_mags", "Dynamic Ammo Inspect")

hg.settings:AddOpt("View","hg_firstperson_death", "First-Person Death")
hg.settings:AddOpt("View","hg_fov", "Field Of View")
hg.settings:AddOpt("View","hg_coolgloves", "Cool Gloves")
hg.settings:AddOpt("View","hg_newspectate", "Smooth Spectator Camera")
hg.settings:AddOpt("View","hg_change_gloves", "Gloves Model")
hg.settings:AddOpt("View","hg_cshs_fake", "C'sHS Ragdoll Camera")
hg.settings:AddOpt("View","hg_gun_cam", "Gun Camera (ADMIN ONLY)")
hg.settings:AddOpt("View","hg_nofovzoom", "Disable/Enable FOV Zoom")
  
hg.settings:AddOpt("Sound","hg_dmusic", "Dynamic Music")

hg.settings:AddOpt("Sound","hg_quietshots", "Enable/Disable Quietshoot Sounds (FOR PUSSY)")

--hg.settings:AddOpt("Sound","hg_thirdperson","ThirdPerson",false,true)
--^^ СТРИНГ ИНПУТ
hg.settings:AddOpt("Gameplay","hg_old_notificate", "Old Notifications")
hg.settings:AddOpt("Gameplay","hg_random_appearance", "Enable/Disable Random Appearance")
hg.settings:AddOpt("Gameplay","hg_cheats", "Enable/Disable Cheats")


function PANEL:Init()
    self:SetAlpha( 0 )
    self:SetSize( ScrW()*1, ScrH()*1 )
    self:SetY( ScrH() )
    self:SetX( ScrW() / 2 - self:GetWide() / 2 )
    self:SetTitle( "" )
    self:SetBorder( false )
    self:SetColorBG( Color(10,10,25,245) )
    self:SetBlurStrengh( 2 )
    self:SetDraggable( false )
    self:ShowCloseButton( true )
    self.Options = {}

    timer.Simple(0,function()
        if self.First then
            self:First()
        end
    end)

    self.fDock = vgui.Create("DScrollPanel",self)
    local fDock = self.fDock
    fDock:Dock( FILL )

    self:CreateCategory( "ZCity Settings" )
    
    for k,t in SortedPairs(hg.settings.tbl) do
        for _,tbl in SortedPairs(t) do
            local convar = GetConVar(tbl[2])
            if convar then
                self:CreateOption(tbl[1],convar:GetMax() == 1,convar, tbl[4], tbl[3] or convar:GetName(), nil, tbl[5])
            else
                -- print("huy'" .. tostring(tbl[2]) .. "' nema")
            end
        end
    end
end

function PANEL:First( ply )
    self:MoveTo(self:GetX(), ScrH() / 2 - self:GetTall() / 2, 0.4, 0, 0.2, function() end)
    self:AlphaTo( 255, 0.2, 0.1, nil )
end

function PANEL:CreateCategory( strCategory )
    local fDock = self.fDock
    if not self.Options[strCategory] then
        local category = vgui.Create("DLabel",fDock)
        category:Dock( TOP )
        category:SetSize(0,ScreenScale(20))
        category:SetText(strCategory)
        category:SetFont("ZCity_Small")
        category:DockMargin(ScreenScaleH(65),2,ScreenScaleH(65),5)
    end
    self.Options[strCategory] = self.Options[strCategory] or {}
    return self.Options[strCategory]
end

local color_blacky = Color(39,39,39,220)
local color_reddy = Color(105,0,0,220)

function PANEL:CreateOption( strCategory, bType, cConVar, bDecimals, strTitle, strDesc, bString )
    if not cConVar then
        --print("huy")
        return
    end
    
    local fDock = self.fDock
    local Category = self:CreateCategory( strCategory )
    Category[cConVar:GetName()] = vgui.Create("DPanel",fDock)
    local opt = Category[cConVar:GetName()]
    opt:Dock( TOP )
    opt:SetSize(0,ScreenScale(25))
    opt:DockMargin(ScreenScaleH(75),2,ScreenScaleH(75),2)
    function opt:Paint(w,h)
        draw.RoundedBox( 0, 0, 0, w, h, color_blacky )
        --hg.DrawBlur(self, 0.1)
        surface.SetDrawColor( color_reddy )
        surface.DrawOutlinedRect(0,0,w,h,1.5)
    end

    opt.NLabel = vgui.Create("DLabel",opt)
    local NLbl = opt.NLabel
    NLbl:SetText( strTitle.."\n"..(strDesc or string.NiceName( cConVar:GetHelpText() ) ) )
    NLbl:SetFont("ZCity_Tiny")
    NLbl:SizeToContents()
    NLbl:Dock(LEFT)
    NLbl:DockMargin(10,0,0,0)

    if bString then
        opt.TextInput = vgui.Create("DTextEntry",opt)
        local TextInput = opt.TextInput
        TextInput:DockMargin( 10,ScreenScale(5),10,ScreenScale(5) )
        TextInput:DockPadding(ScreenScale(5),ScreenScale(5),ScreenScale(5),ScreenScale(5))
        TextInput:SetSize( ScreenScale(90),0 )
        TextInput:Dock( RIGHT )

        TextInput:SetValue(cConVar:GetString())
        TextInput:SetPlaceholderText("Your cool var "..cConVar:GetName())
        TextInput:SetFont("ZCity_Tiny")
        function TextInput:OnLoseFocus()
            cConVar:SetString(self:GetValue())
        end
    elseif bType then
        opt.Button = vgui.Create("DButton",opt)
        local btn = opt.Button
        btn:SetText( "" )
        btn:DockMargin( 10,ScreenScale(5),10,ScreenScale(5) )
        btn:SetSize( ScreenScale(40),0 )
        btn:Dock( RIGHT )

        btn.On = cConVar:GetBool()

        function btn:Paint(w,h)
            self.Lerp = LerpFT(0.2,self.Lerp or (btn.On and 1 or 0), btn.On and 1 or 0)
            local CLR = color_reddy:Lerp(Color(55,175,55),self.Lerp)
            draw.RoundedBox( 0, 0, 0, w, h, CLR )
            --hg.DrawBlur(self, 0.1)
            
            draw.RoundedBox( 0, (w/2)*(self.Lerp), 0, w/2, h, ColorAlpha(color_blacky,255) )
            surface.SetDrawColor( color_reddy )
            surface.DrawOutlinedRect(0,0,w,h,1.5)
        end
        
        function btn:DoClick()
            cConVar:SetBool(not cConVar:GetBool())
            btn.On = cConVar:GetBool()
        end
    else
        local Slid = vgui.Create( "DNumSlider", opt )
        Slid:DockMargin( 10,15,10,15 )
        Slid:SetSize( 500, 0 )
        Slid:Dock( RIGHT )
        Slid:SetMin( cConVar:GetMin() )
        Slid:SetMax( cConVar:GetMax() )
        Slid:SetDecimals( bDecimals and 2 or 0)
        Slid:SetConVar( cConVar:GetName() )
        Slid.TextArea:SetFont("ZCity_Tiny")
    end
end

vgui.Register( "ZOptions", PANEL, "ZFrame")
 
concommand.Add("hg_settings",function()
    if hg_options and IsValid(hg_options) then
        hg_options:Close()
        hg_options = nil
    end
    local s = vgui.Create("ZOptions") 
    s:MakePopup()
    hg_options = s
end)

--https://vk.com/audio-2001212316_123212316