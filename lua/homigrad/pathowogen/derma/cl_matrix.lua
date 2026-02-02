local PANEL = {}
local sw, sh = ScrW(), ScrH()

function PANEL:Init()
	self.matrixX = 80
	self.matrixY = 42

	self:SetSize(sw, sh)
	self:RequestFocus()

	if IsValid(hg.matrix) then
		hg.matrix:Remove()
	end
	hg.matrix = self

	self.TextArray = {}
	for x = 1, self.matrixX do
		self.TextArray[x] = self.TextArray[x] or {}
		for y = 1, self.matrixY do
			self.TextArray[x][y] = math.random(0, 2) == 2 and "1" or "0"
		end
	end

	self.RandomValue = {}
	for x = 1, self.matrixX do
		self.RandomValue[x] = self.RandomValue[x] or {}
		for y = 1, self.matrixY do
			self.RandomValue[x][y] = math.Rand(0.1, 0.9)
		end
	end

	self.alpha = 0
	self:CreateAnimation(2, {
		index = 1,
		target = {
			alpha = 255
		},
		easing = "linear",
		bIgnoreConfig = true,
		Think = function()
			self:SetAlpha(self.alpha)
		end,
	})
end

local blue = Color(149, 121, 214)

function PANEL:Close()
	self:CreateAnimation(2, {
		index = 1,
		target = {
			alpha = 0
		},
		easing = "linear",
		bIgnoreConfig = true,
		Think = function()
			self:SetAlpha(self.alpha)
		end,
		OnComplete = function()
			self:Remove()
		end
	})
end

function PANEL:Paint()
	for x = 1, self.matrixX do
		for y = 1, self.matrixY do
			local posX = sw / self.matrixX * (x - 1)
			local posY = sh / self.matrixY * (y - 1)

			if posY > sh or posY < 0 then continue end

			local alpha = math.sin((self.RandomValue[x][y] / 2 * CurTime()) + self.RandomValue[x][y])

			local color
			color = ColorAlpha(blue, alpha * 7)
			draw.SimpleText(self.TextArray[x][y], "ZB_ProotOSMatrix", posX, posY, color)
		end
	end

	if self:GetAlpha() <= 0 then // a sanity check
		self:Remove()
	end
end

vgui.Register("ZB_Matrix", PANEL, "EditablePanel")