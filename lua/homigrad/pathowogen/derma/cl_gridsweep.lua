local PANEL = {}

local xbars = 17
local ybars = 30

local xbars2 = 0
local ybars2 = 0

local gradient_d = Material("vgui/gradient-d")
local gradient_u = Material("vgui/gradient-u")
local gradient_l = Material("vgui/gradient-l")
local gradient_r = Material("vgui/gradient-r")

local sw, sh = ScrW(), ScrH()

function PANEL:Init()
    self.bordersize = ScreenScale(30)

    self.r = 0
    self.g = 0
    self.b = 0
    self.a = 0
end

function PANEL:FadeColor(newr, newg, newb, newa)
    self:CreateAnimation(1, {
        index = 1,
        target = {
            r = newr,
            g = newg,
            b = newb,
            a = newa or self.a
        },
        easing = "linear",
        bIgnoreConfig = true
    })
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(self.r, self.g, self.b)
    surface.DrawRect(0, 0, w, h)

    surface.SetDrawColor(11, 11, 11, self.a)

    for i = 1, (ybars + 1) do
        surface.DrawRect((sw / ybars) * i - (CurTime() * 30 % (sw / ybars)), 0, ScreenScale(1), sh)
    end

    for i = 1, (xbars + 1) do
        surface.DrawRect(0, (sh / xbars) * (i - 1) + (CurTime() * 30 % (sh / xbars)), sw, ScreenScale(1))
    end

    local border_size = self.bordersize

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

vgui.Register("ZB_FurGrid", PANEL, "EditablePanel")