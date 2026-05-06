local PANEL = {}
local sw, sh = ScrW(), ScrH()
local color_white = Color(255,255,255)
local ctcolor = Color(0,50,70)
local tcolor = Color(70,50,0)
local neutral_color = Color(65,65,65)
local color_bg = Color(0,0,0,155)

net.Receive("CS_Roundover", function()
	winner = net.ReadBool()
	winnerprt = net.ReadString()
    vgui.Create("CS_Roundover")
end)

function PANEL:Init()
    self:SetPos(sw * 0.35, sh * 0.15)
    self:SetSize(sw * 0.3, sh * 0.09)

    if IsValid(zb.CSIntermission) then
        zb.CSIntermission:Remove()
    end
    zb.CSIntermission = self

    self.appearAlpha = 255
    self.appearProgress = 0
    self.bClosing = false

    self:CreateAnimation(1, {
        index = 1,
        target = {
            appearAlpha = 0,
            appearProgress = 1
        },
        easing = "linear",
        bIgnoreConfig = true
    })

    self.text = vgui.Create("DLabel", self)
    self.text:Dock(FILL)
    self.text:SetText(winnerprt.." wins")
    self.text:SetFont("ZB_InterfaceLarge")
    self.text:SetTextColor(color_white)
    self.text:SetContentAlignment(5)

    timer.Simple(10, function()
        if IsValid(self) then
            self:Close()
        end
    end)
end
function PANEL:Paint(w, h)
    surface.SetDrawColor((winnerprt=="Nobody" and neutral_color)or(winner and ctcolor or tcolor))
    surface.DrawRect(0, 0, w, h)

    surface.SetDrawColor((winnerprt=="Nobody" and neutral_color)or(winner and Color(0,137,191) or Color(184,132,0)))
    surface.DrawOutlinedRect(0, 0, w, h, ScreenScale(1))

	surface.SetDrawColor(color_bg)
	surface.DrawRect(0, 0, w, h)

    surface.SetDrawColor(255, 255, 255, self.appearAlpha * 4)
    surface.DrawRect(0, 0, w, h)
end

function PANEL:Close()
    if self.bClosing then return end
    self.bClosing = true

    self:CreateAnimation(1, {
        index = 2,
        target = {
            appearAlpha = 255,
            appearProgress = 0
        },
        easing = "linear",
        bIgnoreConfig = true,
        Think = function()
            self:SetAlpha(255 * self.appearProgress / 2)
        end,
		OnComplete = function()
			self:Remove()
		end
    })
end

vgui.Register("CS_Roundover", PANEL, "EditablePanel")
