local PANEL = {}
local sw, sh = ScrW(), ScrH()
local color_white = Color(255,255,255)
local bg_color = Color(0,0,0,180)
local accent_color = Color(92,92,92)

net.Receive("bomb_planted", function()
    vgui.Create("CS_BombPlanted")
end)

function PANEL:Init()


    self:SetSize(sw * 0.4, sh * 0.08)
    self:SetPos(sw * 0.5 - self:GetWide() * 0.5, -self:GetTall())

    self:SetAlpha(0)

    self.text = vgui.Create("DLabel", self)
    self.text:Dock(FILL)
    self.text:SetText("BOMB HAS BEEN PLANTED")
    self.text:SetFont("ZB_InterfaceMediumLarge")
    self.text:SetTextColor(color_white)
    self.text:SetContentAlignment(5)

    self:MoveTo(self:GetX(), sh * 0.08, 0.3, 0, -1)
    self:AlphaTo(255, 0.3, 0)

    timer.Simple(5, function()
        if IsValid(self) then
            self:Close()
        end
    end)
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(bg_color)
    surface.DrawRect(0, 0, w, h)

    surface.SetDrawColor(accent_color)
    surface.DrawOutlinedRect(0, 0, w, h, 2)

end

function PANEL:Close()
    self:MoveTo(self:GetX(), -self:GetTall(), 0.3, 0, -1)
    self:AlphaTo(0, 0.3, 0)

    timer.Simple(0.3, function()
        if IsValid(self) then
            self:Remove()
        end
    end)

end

vgui.Register("CS_BombPlanted", PANEL, "EditablePanel")