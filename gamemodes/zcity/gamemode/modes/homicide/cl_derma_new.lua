local MODE = MODE

local function set_role(role, mode)
	if mode == "soe" then
		RunConsoleCommand(MODE.ConVarName_SubRole_Traitor_SOE, role)
	else
		RunConsoleCommand(MODE.ConVarName_SubRole_Traitor, role)
	end
end

local glow = Material("zbattle/borderglow2.png")
local red = Color(255, 0, 0)

local rolesmaterials = {
	["traitor_default_soe"] = Material("vgui/traitor_icons/traitor_icon.png", "smooth"),
}

local gradient_d = Material("vgui/gradient-d")
local gradient_u = Material("vgui/gradient-u")
local gradient_l = Material("vgui/gradient-l")
local gradient_r = Material("vgui/gradient-r")

/*function PANEL:PostPaintPanel(w, h)
	if rolesmaterials[self.Role] then
		surface.SetDrawColor(vgui_color_main)
		surface.SetMaterial(rolesmaterials[self.Role])
		surface.DrawTexturedRect(0, -100, w, h + 200)
	end
end*/

local PANEL = {}

local sw, sh = ScrW(), ScrH()

surface.CreateFont("ZB_TraitorSelectionFont", {
	font = "Bahnschrift",
	size = ScreenScale(6),
	extended = true,
	weight = 400,
	antialias = true,
	scanlines = 2
})

function PANEL:Init()
	if IsValid(zb.TraitorSelectionWindow) then
		zb.TraitorSelectionWindow:Remove()
	end

	zb.TraitorSelectionWindow = self

	self:SetPos(sw * 0.4, sh * 0.4)
	self:SetSize(sw * 0.6, sh * 0.6)


	self:MakePopup()
	self:RequestFocus()
	self:SetMouseInputEnabled(true)
    self:SetKeyboardInputEnabled(false)

	local but = self:Add("ZB_TraitorCard")
    but:SetPos(10, 10)
	but:SetSize(sw * 0.4 - 20, sh * 0.6 - 20)

	function but:DoClick()
		zb.TraitorSelectionWindow:Close()
	end

	self.appearProgress = 0

	self:CreateAnimation(0.25, {
		index = 1,
		target = {
			appearProgress = 1
		},
		easing = "linear",
		bIgnoreConfig = true,
		Think = function()
			self:SetAlpha(255 * self.appearProgress)
		end,
		OnComplete = function()
		end
	})

	self.bClosing = false
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(59, 9, 21, 235)
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(59, 9, 21, 150)
	surface.SetMaterial(gradient_d)
	surface.DrawTexturedRect(0, 0, w, h)

	surface.SetDrawColor(59, 9, 21, 150)
	surface.SetMaterial(gradient_u)
	surface.DrawTexturedRect(0, 0, w, h)

	surface.SetDrawColor(59, 9, 21, 150)
	surface.SetMaterial(gradient_l)
	surface.DrawTexturedRect(0, 0, w, h)

	surface.SetDrawColor(59, 9, 21, 150)
	surface.SetMaterial(gradient_r)
	surface.DrawTexturedRect(0, 0, w, h)
end

function PANEL:Think()

end

function PANEL:SetText(text, delay)

end

function PANEL:SetTextAutoClose(text)
end

function PANEL:Close()
	if self.bClosing then return end
	self.bClosing = true

	self:CreateAnimation(0.25, {
		index = 2,
		target = {
			appearProgress = 0
		},
		easing = "linear",
		bIgnoreConfig = true,
		Think = function()
			self:SetAlpha(255 * self.appearProgress)
		end,
		OnComplete = function()
			self:Remove()
		end
	})
end

vgui.Register("ZB_TraitorSelectionMenu", PANEL, "EditablePanel")

local PANEL = {}

function PANEL:Init()
	self.appearProgress = 0

	self:CreateAnimation(0.25, {
		index = 1,
		target = {
			appearProgress = 1
		},
		easing = "linear",
		bIgnoreConfig = true,
		Think = function()
			self:SetAlpha(255 * self.appearProgress)
		end,
		OnComplete = function()
		end
	})

	self.bClosing = false
end

function PANEL:Paint(w, h)
	local width, height = w - (1 - self.HoveredLerp) * (sw * 0.35), h

	render.SetStencilEnable( true )

	render.ClearStencil()
	render.SetStencilTestMask( 255 )
	render.SetStencilWriteMask( 255 )
	render.SetStencilPassOperation( STENCIL_KEEP )
	render.SetStencilZFailOperation( STENCIL_KEEP )
	render.SetStencilCompareFunction( STENCIL_ALWAYS )
	render.SetStencilFailOperation( STENCIL_KEEP )

	render.SetStencilReferenceValue( 1 )
	render.SetStencilPassOperation( STENCIL_REPLACE )

	surface.SetDrawColor(14, 0, 4)
	surface.DrawRect(0, 0, width, height)

	render.SetStencilCompareFunction( STENCIL_EQUAL )
	render.SetStencilPassOperation( STENCIL_KEEP )

	surface.SetMaterial(rolesmaterials["traitor_default_soe"])
	surface.SetDrawColor(61, 4, 13)
	local w1, h1 = ScreenScale(200), ScreenScale(200)
	surface.DrawTexturedRect(self.HoveredLerp * ScreenScale(100) * 0.5 - w1 * 0.5, 0, w1, h1)

	surface.SetDrawColor(74, 10, 80, 50)
	surface.SetMaterial(gradient_r)
	surface.DrawTexturedRect(0, 0, w, h)

	render.SetStencilEnable( false )

	surface.SetDrawColor(61, 4, 13, 200)
	surface.SetMaterial(gradient_d)
	surface.DrawTexturedRect(0, 0, width, height)
end

function PANEL:Think()
	self.HoveredLerp = LerpFT(0.2, self.HoveredLerp or 0, self:IsHovered() and 1 or 0)
end

function PANEL:SetText(text, delay)
end

function PANEL:SetTextAutoClose(text)
end

function PANEL:Close()
	if self.bClosing then return end
	self.bClosing = true

	self:CreateAnimation(0.25, {
		index = 2,
		target = {
			appearProgress = 0
		},
		easing = "linear",
		bIgnoreConfig = true,
		Think = function()
			self:SetAlpha(255 * self.appearProgress)
		end,
		OnComplete = function()
			self:Remove()
		end
	})
end

vgui.Register("ZB_TraitorCard", PANEL, "EditablePanel")