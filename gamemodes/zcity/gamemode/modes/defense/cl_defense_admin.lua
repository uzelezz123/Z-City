local ADMIN_MENU = {
    BACKGROUND_COLOR = Color(0, 0, 0, 200),
    PRIMARY_COLOR = Color(180, 40, 40),
    SECONDARY_COLOR = Color(40, 40, 40),
    TEXT_COLOR = Color(255, 255, 255),
    HOVER_COLOR = Color(200, 60, 60),
    PANEL_WIDTH = 500,
    PANEL_HEIGHT = 400
}

local adminWaveMenu = nil


surface.CreateFont("Defense_AdminTitle", {
    font = "Roboto",
    size = 24,
    weight = 700,
    antialias = true,
    shadow = true
})

surface.CreateFont("Defense_AdminText", {
    font = "Roboto",
    size = 18,
    weight = 500,
    antialias = true
})

surface.CreateFont("Defense_AdminInfo", {
    font = "Roboto",
    size = 16,
    weight = 400,
    antialias = true
})

local function DrawBackgroundBlur(panel)
    local x, y = panel:LocalToScreen(0, 0)
    local scrW, scrH = ScrW(), ScrH()
    
    surface.SetDrawColor(0, 0, 0, 150)
    surface.SetMaterial(Material("pp/blurscreen"))
    
    for i = 1, 5 do
        Material("pp/blurscreen"):SetFloat("$blur", (i / 3) * 4)
        Material("pp/blurscreen"):Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(-x, -y, scrW, scrH)
    end
    
    surface.SetDrawColor(0, 0, 0, 180)
    surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
end

function CreateAdminWaveMenu(subMode, currentWave, totalWaves, isActive)
    if IsValid(adminWaveMenu) then 
        adminWaveMenu:Remove() 
    end
    
    adminWaveMenu = vgui.Create("ZFrame")
    adminWaveMenu:SetSize(ADMIN_MENU.PANEL_WIDTH, ADMIN_MENU.PANEL_HEIGHT)
    adminWaveMenu:Center()
    adminWaveMenu:SetTitle("")
    adminWaveMenu:SetDraggable(true)
    adminWaveMenu:ShowCloseButton(false)
    adminWaveMenu:MakePopup()
    

    local closeBtn = vgui.Create("DButton", adminWaveMenu)
    closeBtn:SetSize(30, 30)
    closeBtn:SetPos(adminWaveMenu:GetWide() - 40, 10)
    closeBtn:SetText("")
    
    closeBtn.Paint = function(self, w, h)
        local color = self:IsHovered() and ADMIN_MENU.HOVER_COLOR or ADMIN_MENU.PRIMARY_COLOR
        draw.RoundedBox(15, 0, 0, w, h, color)
        surface.SetDrawColor(ADMIN_MENU.TEXT_COLOR)
        surface.DrawLine(8, 8, w-8, h-8)
        surface.DrawLine(8, h-8, w-8, 8)
    end
    
    closeBtn.DoClick = function()
        adminWaveMenu:Close()
        surface.PlaySound("ui/buttonclickrelease.wav")
    end
    
    adminWaveMenu.Paint = function(self, w, h)
        DrawBackgroundBlur(self)
        
        surface.SetDrawColor(ADMIN_MENU.PRIMARY_COLOR)
        surface.DrawRect(0, 0, w, 50)
        
        surface.SetDrawColor(ADMIN_MENU.BACKGROUND_COLOR)
        surface.DrawRect(0, 50, w, h - 50)
        
        surface.SetDrawColor(ADMIN_MENU.PRIMARY_COLOR)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        
        draw.SimpleText("DEBUG", "Defense_AdminTitle", w/2, 25, ADMIN_MENU.TEXT_COLOR, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        

        local status = isActive and "Active" or "Prepare"
        draw.SimpleText("Wave now: " .. currentWave .. " / " .. totalWaves, "Defense_AdminText", w/2, 70, ADMIN_MENU.TEXT_COLOR, TEXT_ALIGN_CENTER)
        draw.SimpleText("Sub-Mode: " .. subMode, "Defense_AdminText", w/2, 95, ADMIN_MENU.TEXT_COLOR, TEXT_ALIGN_CENTER)
        draw.SimpleText("Status: " .. status, "Defense_AdminText", w/2, 120, ADMIN_MENU.TEXT_COLOR, TEXT_ALIGN_CENTER)
    end
    

    local waveScroll = vgui.Create("DScrollPanel", adminWaveMenu)
    waveScroll:SetSize(ADMIN_MENU.PANEL_WIDTH - 40, ADMIN_MENU.PANEL_HEIGHT - 180)
    waveScroll:SetPos(20, 150)
    
    local scrollBar = waveScroll:GetVBar()
    scrollBar:SetWide(12)
    scrollBar.btnUp:SetVisible(false)
    scrollBar.btnDown:SetVisible(false)
    
    function scrollBar:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(40, 40, 40, 200))
    end
    
    function scrollBar.btnGrip:Paint(w, h)
        draw.RoundedBox(6, 2, 0, w-4, h, ADMIN_MENU.PRIMARY_COLOR)
    end
    
    waveScroll.Paint = function(self, w, h)
        surface.SetDrawColor(ADMIN_MENU.SECONDARY_COLOR)
        surface.DrawRect(0, 0, w, h)
        
        surface.SetDrawColor(ADMIN_MENU.PRIMARY_COLOR)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    

    for i = 1, totalWaves do
        local waveBtn = vgui.Create("DButton", waveScroll)
        waveBtn:SetSize(waveScroll:GetWide() - 20, 40)
        waveBtn:SetPos(10, (i - 1) * 45 + 10)
        waveBtn:SetText("")
        
        waveBtn.Paint = function(self, w, h)
            local bgColor = self:IsHovered() and ADMIN_MENU.HOVER_COLOR or ADMIN_MENU.SECONDARY_COLOR
            
            if i == currentWave then
                bgColor = Color(60, 120, 60)
            end
            
            surface.SetDrawColor(bgColor)
            surface.DrawRect(0, 0, w, h)
            
            surface.SetDrawColor(ADMIN_MENU.PRIMARY_COLOR)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
            
            draw.SimpleText("Волна " .. i, "Defense_AdminText", w/2, h/2, ADMIN_MENU.TEXT_COLOR, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        waveBtn.DoClick = function()
            net.Start("defense_admin_wave_skip")
            net.WriteInt(i, 8)
            net.SendToServer()
            
            adminWaveMenu:Close()
            surface.PlaySound("ui/buttonclick.wav")
        end
    end
    

    local infoPanel = vgui.Create("DPanel", adminWaveMenu)
    infoPanel:SetSize(ADMIN_MENU.PANEL_WIDTH - 40, 30)
    infoPanel:SetPos(20, ADMIN_MENU.PANEL_HEIGHT - 40)
    infoPanel.Paint = function(self, w, h)
        surface.SetDrawColor(30, 30, 30)
        surface.DrawRect(0, 0, w, h)
        draw.SimpleText("Нажмите на номер волны чтобы перейти к ней", "Defense_AdminInfo", w/2, h/2, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end


net.Receive("defense_admin_wave_menu", function()
    local subMode = net.ReadString()
    local currentWave = net.ReadInt(8)
    local totalWaves = net.ReadInt(8)
    local isActive = net.ReadBool()
    
    CreateAdminWaveMenu(subMode, currentWave, totalWaves, isActive)
end)


hook.Add("OnPlayerChat", "DefenseAdminWavesChat", function(ply, text)
    if ply ~= LocalPlayer() then return end
    
    if text:lower() == "!waves" or text:lower() == "/waves" then
        RunConsoleCommand("defense_waves_admin")
        return true
    end
end)
