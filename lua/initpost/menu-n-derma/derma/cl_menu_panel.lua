local PANEL = {}
local curent_panel 
local red_select = Color(192,0,0)

local Selects = {
    {Title = "Disconnect", Func = function(luaMenu) RunConsoleCommand("disconnect") end},
    {Title = "Main Menu", Func = function(luaMenu) gui.ActivateGameUI() luaMenu:Close() end},
    {Title = "Settings", Func = function(luaMenu,pp) 
        hg.DrawSettings(pp) 
    end},
    {Title = "Discord", Func = function(luaMenu) luaMenu:Close() gui.OpenURL("https://discord.gg/475EmEdTgH")  end},
    {Title = "Achievements", Func = function(luaMenu,pp) 
        hg.DrawAchievmentsMenu(pp)
    end},
    {Title = "Appearance", Func = function(luaMenu,pp) hg.CreateApperanceMenu(pp) end},
    {Title = "Return", Func = function(luaMenu) luaMenu:Close() end},
}

local splasheh = {
    'LIKE HOMICIDED',
    'PLUV PLUV PLUVISKI',
    'LULU IS NOT DEAD | !PLUV',
    'THE TRAITOR WAS KILLED',
    'NAB HOMICIDE SERVER',
    'ALSO TRY MODDED HOMICIDE 2',
    'HOP ON Z-CITY',
    'JOHN Z-CITY',
    ':pluvrare:',
    'SAW51 IS REAL',
    'MORE SMALLTOWN',
    'MORE CLUE2022',
    'BACKROOMS == CLUE',
    'HELL IS NEAR',
    'I WISH YOU GOOD HEALTH, JASON STATHAM'
}

--print(string.upper('I wish you good health, Jason Statham'))
surface.CreateFont("ZC_MM_Title", {
    font = "Bahnschrift",
    size = ScreenScale(40),
    weight = 800,
    antialias = true
})
-- local Title = markup.Parse("error")

local Pluv = Material("pluv/pluvkid.jpg")

function PANEL:InitializeMarkup()
	local mapname = game.GetMap()
	local prefix = string.find(mapname, "_")
	if prefix then
		mapname = string.sub(mapname, prefix + 1)
	end
	local gm = splasheh[math.random(#splasheh)] .. " | " .. string.NiceName(mapname) 

    if hg.PluvTown.Active then
        local text = "<font=ZC_MM_Title><colour=199,2,2>    </colour>City</font>\n<font=ZCity_Tiny><colour=105,105,105>" .. gm .. "</colour></font>"

        self.SelectedPluv = table.Random(hg.PluvTown.PluvMats)

        return markup.Parse(text)
    end

    local text = "<font=ZC_MM_Title><colour=199,2,2,255>Z</colour>-City</font>\n<font=ZCity_Tiny><colour=105,105,105>" .. gm .. "</colour></font>"
    return markup.Parse(text)
end

local color_red = Color(255,25,25,45)
local clr_gray = Color(255,255,255,25)
local clr_verygray = Color(10,10,19,235)

function PANEL:Init()
    self:SetAlpha(0)
    self:SetSize(ScrW(), ScrH())
    self:Center()
    self:SetTitle("")
    self:SetDraggable(false)
    self:SetBorder(false)
    self:SetColorBG(clr_verygray)
    self:SetDraggable(false)
    self:ShowCloseButton(false)
    curent_panel = nil
    self.Title, self.TitleShadow = self:InitializeMarkup()

    timer.Simple(0, function()
        if self.First then
            self:First()
        end
    end)

    self.lDock = vgui.Create("DPanel", self)
    local lDock = self.lDock
    lDock:Dock(LEFT)
    lDock:SetSize(ScrW() / 4, ScrH())
    lDock:DockMargin(ScreenScale(0), ScreenScaleH(100), ScreenScale(10), ScreenScaleH(100))
    lDock.Paint = function(this, w, h)
        if hg.PluvTown.Active then
            surface.SetDrawColor(color_white)
            surface.SetMaterial(self.SelectedPluv or Pluv)
            surface.DrawTexturedRect(0, ScreenScale(27), ScreenScale(35), ScreenScale(27))
        end

        self.Title:Draw(ScreenScale(15), ScreenScale(50), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 255, TEXT_ALIGN_LEFT)
    end

    self.Buttons = {}
    for k, v in ipairs(Selects) do
        if v.GamemodeOnly and engine.ActiveGamemode() != "zcity" then continue end
        self:AddSelect(lDock, v.Title, v)
    end


    local bottomDock = vgui.Create("DPanel", self)
    bottomDock:SetPos(ScreenScale(1), ScrH() - ScrH()/10)
    bottomDock:SetSize(ScreenScale(190), ScreenScaleH(40))
    bottomDock.Paint = function(this, w, h) end
    self.panelparrent = vgui.Create("DPanel", self)
    self.panelparrent:SetPos(bottomDock:GetWide()+bottomDock:GetX(), 0)
    self.panelparrent:SetSize(ScrW() - bottomDock:GetWide()*1, ScrH())
    self.panelparrent.Paint = function(this, w, h) end
    
    local git = vgui.Create("DLabel", bottomDock)
    git:Dock(BOTTOM)
    git:DockMargin(ScreenScale(10), 0, 0, 0)
    git:SetFont("ZCity_Tiny")
    git:SetTextColor(clr_gray)
    git:SetText("GitHub: github.com/" .. hg.GitHub_ReposOwner .. "/" .. hg.GitHub_ReposName)
    git:SetContentAlignment(4)
    git:SetMouseInputEnabled(true)
    git:SizeToContents()

    function git:DoClick()
        gui.OpenURL("https://github.com/" .. hg.GitHub_ReposOwner .. "/" .. hg.GitHub_ReposName)
    end

    local version = vgui.Create("DLabel", bottomDock)
    version:Dock(BOTTOM)
    version:DockMargin(ScreenScale(10), 0, 0, 0)
    version:SetFont("ZCity_Tiny")
    version:SetTextColor(clr_gray)
    version:SetText(hg.Version)
    version:SetContentAlignment(4)
    version:SizeToContents()

    local zteam = vgui.Create("DLabel", bottomDock)
    zteam:Dock(BOTTOM)
    zteam:DockMargin(ScreenScale(10), 0, 0, 0)
    zteam:SetFont("ZCity_Tiny")
    zteam:SetTextColor(clr_gray)
    zteam:SetText("Authors: uzelezz, Sadsalat, Mr.Point, Zac90, Deka, Mannytko")
    zteam:SetContentAlignment(4)
    zteam:SizeToContents()
end

function PANEL:First( ply )
    self:AlphaTo( 255, 0.1, 0, nil )
end

local gradient_d = surface.GetTextureID("vgui/gradient-d")
local gradient_r = surface.GetTextureID("vgui/gradient-u")
local gradient_l = surface.GetTextureID("vgui/gradient-l")

function PANEL:Paint(w,h)
    draw.RoundedBox( 0, 0, 0, w, h, self.ColorBG )
    hg.DrawBlur(self, 5)
    surface.SetDrawColor( self.ColorBG )
    surface.SetTexture( gradient_l )
    surface.DrawTexturedRect(0,0,w,h)
    surface.SetDrawColor( Color(102,0,0,35) )
    surface.SetTexture( gradient_d )
    surface.DrawTexturedRect(0,0,w,h)
end

function PANEL:AddSelect( pParent, strTitle, tbl )
    local id = #self.Buttons + 1
    self.Buttons[id] = vgui.Create( "DLabel", pParent )
    local btn = self.Buttons[id]
    btn:SetText( strTitle )
    btn:SetMouseInputEnabled( true )
    btn:SizeToContents()
    btn:SetFont( "ZCity_Small" )
    btn:SetTall( ScreenScale( 15 ) )
    btn:Dock(BOTTOM)
    btn:DockMargin(ScreenScale(15),ScreenScale(1.5),0,0)
    btn.Func = tbl.Func
    btn.HoveredFunc = tbl.HoveredFunc
    local luaMenu = self 
    if tbl.CreatedFunc then tbl.CreatedFunc(btn, self, luaMenu) end
    btn.RColor = Color(225,225,225)
    function btn:DoClick()
        -- ,kz оптимизировать надо, но идёт ошибка(кэшировать бы luaMenu.panelparrent вместо вызова его каждый раз)
        if curent_panel == string.lower(strTitle) then 
            luaMenu.panelparrent:AlphaTo(0,0.2,0,function()
                luaMenu.panelparrent:Remove()
                luaMenu.panelparrent = nil
                luaMenu.panelparrent = vgui.Create("DPanel", luaMenu)
                
                luaMenu.panelparrent:SetPos(some_coordinates_x, 0)
                luaMenu.panelparrent:SetSize(some_size_x, some_size_y)
                luaMenu.panelparrent.Paint = function(this, w, h) end
                --btn.Func(luaMenu,luaMenu.panelparrent)
                curent_panel = nil
            end)
            return 
        end
        some_size_x = luaMenu.panelparrent:GetWide()
        some_size_y = luaMenu.panelparrent:GetTall()
        some_coordinates_x = luaMenu.panelparrent:GetX()
        luaMenu.panelparrent:AlphaTo(0,0.2,0,function()
            luaMenu.panelparrent:Remove()
            luaMenu.panelparrent = nil
            luaMenu.panelparrent = vgui.Create("DPanel", luaMenu)
            
            luaMenu.panelparrent:SetPos(some_coordinates_x, 0)
            luaMenu.panelparrent:SetSize(some_size_x, some_size_y)
            luaMenu.panelparrent.Paint = function(this, w, h) end
            btn.Func(luaMenu,luaMenu.panelparrent)
            curent_panel = string.lower(strTitle)
        end)
    end

    function btn:Think()
        self.HoverLerp = LerpFT(0.2, self.HoverLerp or 0, (self:IsHovered() or (IsValid(self:GetChild(0)) and self:GetChild(0):IsHovered()) or (IsValid(self:GetChild(0)) and IsValid(self:GetChild(0):GetChild(0)) and self:GetChild(0):GetChild(0):IsHovered())) and 1 or 0)

        local v = self.HoverLerp
        self:SetTextColor(self.RColor:Lerp(red_select, v))
        local targetText = (self:IsHovered()) and string.upper(strTitle) or strTitle
        local crw = self:GetText()
        
        if (crw ~= targetText) or (curent_panel == string.lower(strTitle)) then
            local ntxt = ""
            local will_text = curent_panel == string.lower(strTitle) and '[ '..string.upper(strTitle)..' ]' or strTitle
            for i = 1, #will_text do
                local char = will_text:sub(i, i)
                if i <= math.ceil(#will_text * v) then
                    ntxt = ntxt .. string.upper(char)
                else
                    ntxt = ntxt .. char
                end
            end
            self:SetText(ntxt)
        end
        self:SizeToContents()
    end
end

function PANEL:Close()
    self:AlphaTo( 0, 0.1, 0, function() self:Remove() end)
    self:SetKeyboardInputEnabled(false)
    self:SetMouseInputEnabled(false)
end

vgui.Register( "ZMainMenu", PANEL, "ZFrame")

hook.Add("OnPauseMenuShow","OpenMainMenu",function()
    local run = hook.Run("OnShowZCityPause")
    if run != nil then
        return run
    end

    if MainMenu and IsValid(MainMenu) then
        MainMenu:Close()
        MainMenu = nil
        return false
    end

    MainMenu = vgui.Create("ZMainMenu")
    MainMenu:MakePopup()
    return false
end)