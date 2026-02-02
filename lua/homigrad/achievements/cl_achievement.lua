
hg.achievements = hg.achievements or {}
hg.achievements.achievements_data = hg.achievements.achievements_data or {}
hg.achievements.achievements_data.player_achievements = hg.achievements.achievements_data.player_achievements or {}
hg.achievements.achievements_data.created_achevements = {}

hg.achievements.MenuPanel = hg.achievements.MenuPanel or nil

local CreateMenuPanel

concommand.Add("hg_achievements",function()
    CreateMenuPanel()
end)

BlurBackground = BlurBackground or hg.DrawBlur
local gradient_u = Material("vgui/gradient-u")
local function PaintButton(self,w,h)
	BlurBackground(self)
    surface.SetDrawColor(155, 0, 0, 155)
    surface.SetMaterial(gradient_u)
    surface.DrawTexturedRect( 0, 0, w, h )

	surface.SetDrawColor( 70, 0, 0, 128)
    surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
end

local function createButton(frame, ach, text, func)
    local button = vgui.Create("DButton", frame)

    ach.img = isstring(ach.img) and Material(ach.img) or ach.img
    
    local localach = hg.achievements.GetLocalAchievements()
    --PrintTable(localach)
    local desc = markup.Parse("<font=HomigradFontMedium>"..ach.description.."<font>", 500 )
    
    local x,y = frame:LocalToScreen(button:GetPos())
    function button:Paint(w,h)
		PaintButton(self,w,h)
        local view = render.GetViewSetup(true)
        local pos,ang = view.origin,view.angles
        ang:RotateAroundAxis( ang:Up(), -90 )
	    ang:RotateAroundAxis( ang:Forward(), 90 )
        
        self.lerpcolor = Lerp(FrameTime() * 10,self.lerpcolor or 0,self:IsHovered() and 255 or 0)
       
        local val = localach[ach.key] and localach[ach.key].value or ach.start_value
        local amt = ScreenScale(1)

        --[[surface.SetDrawColor(71,36,48,(val / ach.needed_value) == 1 and 255 or 0)
        surface.SetMaterial(ach.img)
        surface.DrawTexturedRect(amt * 5,amt * 5,h - amt * 10,h - amt * 10)--]]

        surface.SetFont("HomigradFont") 
        local txt = ach.name..(ach.showpercent and " | " or "")..(ach.showpercent and (val / ach.needed_value * 100).."%" or "")
        local wt,ht = surface.GetTextSize(txt)
        surface.SetTextColor(255,255,255)
        surface.SetTextPos(w / 2 - (wt / 2), (ht / 2) * (1-(self.lerpcolor / 255)*5))
        surface.DrawText(txt)

       --surface.SetFont("HomigradFontMedium")
       --local wt,ht = surface.GetTextSize(ach.description)
       --surface.SetTextColor(255,255,255,255)
       --surface.SetTextPos(w / 2 - wt / 2,h - ((h/2)+ht/2) * (self.lerpcolor / 255))
        --surface.DrawText(ach.description)
        desc:Draw(w / 2,(h + desc:GetHeight()) - ((h/2) + desc:GetHeight()) * (self.lerpcolor / 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        surface.SetDrawColor(255,255,255,10)
        draw.NoTexture()
        surface.DrawTexturedRectRotated(w - self.lerpcolor / 255 * 100 + 50,0,10,400,-30)
        surface.DrawTexturedRectRotated(w - self.lerpcolor / 255 * 100 + 80,0,10,400,-30)
    end

    button:SetText("")
    button:SetSize(0,ScreenScale(22))
    button:Dock(TOP)
    button:DockMargin(0,0,0,ScreenScale(2.5))
    button.DoClick = function(self) func(self) end
    return button
end

local gradient_d = Material("vgui/gradient-d")
local function PaintFrame(self,w,h)
	BlurBackground(self)
    surface.SetDrawColor(50, 0, 0, 155)
    surface.SetMaterial(gradient_d)
    surface.DrawTexturedRect( 0, 0, w, h )

	surface.SetDrawColor( 150, 0, 0, 128)
    surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
end

CreateMenuPanel = function()
    hg.achievements.LoadAchievements()

    if IsValid(hg.achievements.MenuPanel) then
        hg.achievements.MenuPanel:Remove()
        hg.achievements.MenuPanel = nil
    end

    local frame = vgui.Create( "ZFrame" )
    hg.achievements.MenuPanel = frame
    frame:SetTitle("")
    frame:SetSize( ScrW() / 3, ScrH() / 2 )
    frame:SetPos( ScrW() * 0.5 - frame:GetWide() * 0.5,ScrH() + 500 )
    frame:MakePopup()
    frame:SetKeyboardInputEnabled(false)
    local pad = ScreenScale(15)
    local pad2 = ScreenScale(5)
    frame:DockPadding(pad2,pad,pad2,pad)
    frame.OnClose = function() frame = nil end 
    frame:SetAlpha(0)

    frame:MoveTo(frame:GetX(), ScrH() / 2 - frame:GetTall() / 2, 0.5, 0, 0.3, function() end)
    frame:AlphaTo( 255, 1, 0, nil )

	function frame:Paint( w,h )
        PaintFrame(self,w,h)
    end

    function frame:Close()
        self:MoveTo(frame:GetX(), ScrH() + 500, 0.5, 0, 0.3, function()
            self:Remove()
        end)
        self:AlphaTo( 0, 0.1, 0, nil )
        self:SetKeyboardInputEnabled(false)
        self:SetMouseInputEnabled(false)
    end

    local scroll = vgui.Create("DScrollPanel",frame)
    scroll:Dock(FILL)
    frame.scroll = scroll

    local sbar = scroll:GetVBar()
    sbar:SetHideButtons(true)
    function sbar:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100))
    end
    function sbar.btnGrip:Paint(w, h)
        self.lerpcolor = Lerp(FrameTime() * 10, self.lerpcolor or 0.2,(self:IsHovered() and 0.8 or 0.6))
        draw.RoundedBox(0, 0, 0, w, h, Color(100 * self.lerpcolor, 10, 10))
    end

    --function frame:Paint(w,h)
    --    (self)
    --    BlurBackground--surface.SetFont("HomigradFontMedium")
    --    --local name = "Achievements"
    --    --local wt,ht = surface.GetTextSize(name)
    --    --surface.SetTextColor(255,255,255)
    --    --surface.SetTextPos(15,0)
    --    --surface.DrawText(name)
--
    --    surface.SetDrawColor(col1)
    --    surface.DrawOutlinedRect( 0, 0, w, h, 1 )
    --end

    function frame:UpdateValues()
        local scroll = self.scroll
        scroll:Clear()
        
        for i,ach in pairs(hg.achievements.achievements_data.created_achevements) do
            scroll:AddItem(createButton(scroll, ach, ach.name, function() end))
        end
    end

    for i,ach in pairs(hg.achievements.achievements_data.created_achevements) do
        scroll:AddItem(createButton(scroll, ach, ach.name, function() end))
    end
end

local time_wait = 0
function hg.achievements.LoadAchievements()
    if time_wait > CurTime() then return end
    time_wait = CurTime() + 2

    net.Start("req_ach")
    net.SendToServer()
end

function hg.achievements.GetLocalAchievements()
    return hg.achievements.achievements_data.player_achievements[tostring(LocalPlayer():SteamID())]
end

net.Receive("req_ach",function()
    hg.achievements.achievements_data.created_achevements = net.ReadTable()
    hg.achievements.achievements_data.player_achievements[tostring(LocalPlayer():SteamID())] = net.ReadTable()
    
    if IsValid(hg.achievements.MenuPanel) then
        hg.achievements.MenuPanel:UpdateValues()
    end
end)
hg.achievements.NewAchievements = hg.achievements.NewAchievements or {}
local AchTable = hg.achievements.NewAchievements 
net.Receive("hg_NewAchievement",function()
    local Ach = {time = CurTime() + 7.5,name = net.ReadString(),img = net.ReadString()}
    table.insert(AchTable,1,Ach)
	surface.PlaySound("homigrad/vgui/achievement_earned.wav")
    --sound.PlayURL("https://www.myinstants.com/media/sounds/achievement_earned.mp3","noblock",function(station)
    --    if IsValid(station) then
    --        station:Play()
    --    end 
    --end)
end)

-- AchTable[1] = {time = CurTime() + 991,name = "Hello Everyone",img = "achievements/marksman"}
-- AchTable[2] = {time = CurTime() + 992,name = "John 'Alabama' Slasher",img = "achievements/bloodysouvenir"}
-- AchTable[3] = {time = CurTime() + 993,name = "Nab",img = "achievements/toxicfumes"}
-- AchTable[4] = {time = CurTime() + 994,name = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis pulvinar, elit in eleifend euismod, massa metus eleifend massa",img = "achievements/bunny"}
-- AchTable[5] = {time = CurTime() + 995,name = "Hello Everyone",img = "homigrad/vgui/models/star.png"}
local ach_clr1 , ach_clr2 = Color(200,25,25), Color(100,25,25)
hook.Add("HUDPaint","hg_NewAchievement", function()
    local frametime = FrameTime() * 10
    for i = 1, #AchTable do
        local ach = AchTable[i]
        if not ach then continue end
        local txt = "Achievement! "..ach.name
        ach.img = isstring(ach.img) and Material(ach.img) or ach.img
        local wt, _ = surface.GetTextSize(txt)

        ach.Lerp = Lerp( frametime, ach.Lerp or 0, math.min( ach.time - CurTime(), 1 ) * i )
        WSize, HSize = (ScrW() * 0.1) + (wt), ScrH() * 0.05
        local HPos = ScrH() - ( HSize * ach.Lerp )
        draw.RoundedBox( 0, 2, HPos + 2, WSize - 4, HSize - 4, ach_clr2 )
		
		surface.SetDrawColor(155, 0, 0, 255)
		surface.SetMaterial(gradient_u)
		surface.DrawTexturedRect( 0, HPos, WSize, HSize )
	
		surface.SetDrawColor( 150, 0, 0, 255)
		surface.DrawOutlinedRect( 0, HPos, WSize, HSize, 2.5 )

        surface.SetFont("HomigradFontMedium")
        surface.SetTextColor(255,255,255)
        surface.SetTextPos(HSize*1.25,(HPos + ( HSize/2 ) - ( HSize/4 )) )
        surface.DrawText(txt)
        surface.SetDrawColor(255,255,255)
        surface.SetMaterial(ach.img)
        surface.DrawTexturedRect(2,HPos+2,HSize-4,HSize-4)
        if ach.time < CurTime() then 
            table.remove(AchTable,i)
            --PrintTable(AchTable)
        end
    end
end)