local PANEL = {}
local sw, sh = ScrW(), ScrH()    
local color_white = Color(255,255,255)

net.Receive("zb_cs_round_intermission", function()
	plyteam = net.ReadBool()
	rounds = net.ReadInt(6)
	vgui.Create("zb_cs_round_intermission")
end)

function PANEL:Init()
	self:SetPos(sw * 0.4, sh * 0.15)
	self:SetSize(sw * 0.2, sh * 0.07)
	if IsValid(zb.CSIntermission) then
		zb.CSIntermission:Remove()
	end
	zb.CSIntermission = self

	self.appearAlpha = 255
	self.appearProgress = 0

	self:CreateAnimation(1, {
		index = 1,
		target = {
			appearAlpha = 0,
			appearProgress = 1
		},
		easing = "linear",
		bIgnoreConfig = true,
		Think = function()
		end,
		OnComplete = function()
		end
	})

	self.CloseOnLast = false
	self.bClosing = false

	self.text = vgui.Create("DLabel", self)
	self.text:Dock(FILL)
	self.text:DockMargin(0, 0, 0, 0)
	self.text:SetText(rounds == 0 and "Warm-up" or "Round "..rounds)
	self.text:SetFont("ZB_InterfaceLarge")
	self.text:SetTextColor(color_white)
	self.text:SetWrap(false)
	self.text:SetAutoStretchVertical(false)
	self.text:SetContentAlignment(5)

	self.timebetween = SysTime() + 1.2

    timer.Simple(10, function()
        self:Close()
    end)
end

local ctcolor = Color(0,50,70)
local tcolor = Color(70,50,0)

function PANEL:PaintOver(w, h)
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(!plyteam and ctcolor or tcolor)
	surface.DrawRect(0, 0, w, h)
	surface.SetDrawColor(!plyteam and Color(0,137,191) or Color(184,132,0))
	surface.DrawOutlinedRect(0, 0, w, h, ScreenScale(1))
	surface.SetDrawColor(255, 255, 255, self.appearAlpha * 4)
	surface.DrawRect(0, 0, w, h)
end



function PANEL:Think()
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
			-- self:SetSize(sw * 0.22 * self.appearProgress, sh * 0.12)
			self:SetAlpha(255 * self.appearProgress / 2)
		end,
		OnComplete = function()
			self:Remove()
		end
	})
end

vgui.Register("zb_cs_round_intermission", PANEL, "EditablePanel")

