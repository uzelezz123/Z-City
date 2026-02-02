local PANEL = PANEL or {}

function PANEL:Init()
    self.hovered = false
    self.alpha = 0
    self.setalpha = 0
    self:SetFont("ZB_ScrappersMedium")
	self:SetPaintBackground(false)
	self:SetContentAlignment(5)
    self:SetTextColor(color_white)

    self.disabled = false
    self.selected = false
end

function PANEL:Paint(w, h)
    if self.disabled then return end
    surface.SetDrawColor(0, 0, 0, 50)
    surface.DrawRect(0, 0, w, h)

    if self.disabled then
        surface.SetDrawColor(255, 255, 255, 50)
    else
        surface.SetDrawColor(239, 47, 47)
    end

    surface.DrawOutlinedRect(0, 0, w, h, ScreenScale(0.5))

    surface.SetDrawColor(239, 47, 47, self.alpha)
    surface.DrawRect(0, 0, w, h)
end

function PANEL:OnCursorEntered()
    if self.disabled then return end
    self:CreateAnimation(0.1, {
        index = 1,
        target = {
            alpha = 255
        },
        easing = "inExpo",
        bIgnoreConfig = true
    })
    self.hovered = true
end

function PANEL:OnCursorExited()
    if self.selected then return end

    self:CreateAnimation(0.3, {
        index = 1,
        target = {
            alpha = self.setalpha
        },
        easing = "outExpo",
        bIgnoreConfig = true
    })
    self.hovered = false
end

function PANEL:SetSelected(value)
    self.selected = value
    if value then self:OnCursorEntered()
    else self:OnCursorExited() end
end

function PANEL:Disabled(bool)
    self.disabled = bool
    if bool then
        self:SetTextColor(Color(255, 255, 255, 50))
        self:SetCursor("arrow")
    else
        self:SetTextColor(color_white)
        self:SetCursor("hand")
    end
end

vgui.Register("ZB_ScrappersButton", PANEL, "DButton")

