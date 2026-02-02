local PANEL = {}

local gradient_l = Material("vgui/gradient-l")

local xbars = 17
local ybars = 30

surface.CreateFont("ZB_ProotOSLarge", {
	font = "Ari-W9500",
	size = ScreenScale(500),
	extended = true,
	weight = 400,
})

surface.CreateFont("ZB_ProotOSMedium", {
	font = "Ari-W9500",
	size = ScreenScale(10),
	extended = true,
	weight = 400,
})

surface.CreateFont("ZB_ProotOSSmall", {
	font = "Ari-W9500",
	size = ScreenScale(5),
	extended = true,
	weight = 400,
})

surface.CreateFont("ZB_ProotOSAssimilation", {
	font = "Blue Screen Personal Use",
	size = ScreenScale(20),
	extended = true,
	weight = 400,
	antialias = true
})

surface.CreateFont("ZB_ProotOSMatrix", {
	font = "Ari-W9500",
	size = ScreenScale(10),
	extended = true,
	weight = 400,
})

surface.CreateFont("ZB_ProotOSMatrix2", {
	font = "Ari-W9500",
	size = ScreenScale(5),
	extended = true,
	weight = 400,
})

-- local tbl = vgui.GetAll()

-- for _, v in pairs(tbl) do
--     v:Remove()
-- end

local bluewhite = Color(187, 187, 255)
local bluewhite2 = Color(213, 43, 43)

local sw, sh = ScrW(), ScrH()

function PANEL:Init()
	system.FlashWindow()

	self.progress = 0
	self.alpha = 255
	self.alphagrid = 255

	self.blur = 5

	self.done = false
	self:CreateAnimation(2.5, {
		index = 5,
		target = {
			blur = 0
		},
		easing = "linear",
		bIgnoreConfig = true,
	})

	timer.Simple(2, function()
		self:CreateAnimation(0.5, {
			index = 10,
			target = {
				progress = math.Rand(0.01, 0.1)
			},
			easing = "outQuint",
			bIgnoreConfig = true,
			OnComplete = function()
				self:CreateAnimation(1.5, {
					index = 11,
					target = {
						progress = math.Rand(0.6, 0.9)
					},
					easing = "linear",
					bIgnoreConfig = true,
					OnComplete = function()
						self:CreateAnimation(1, {
							index = 12,
							target = {
								progress = 1
							},
							easing = "outQuint",
							bIgnoreConfig = true,
							OnComplete = function()
								timer.Simple(0.5, function()
									if !IsValid(self) then return end
									self:Close()
								end)
							end
						})
					end
				})
			end
		})
	end)

	self.initAnim = 0
	self.initAnim2 = 0

	self:CreateAnimation(1, {
		index = 20,
		target = {
			initAnim = 1
		},
		easing = "linear",
		bIgnoreConfig = true,
		OnComplete = function()
			self:CreateAnimation(10, {
				index = 21,
				target = {
					initAnim2 = 1
				},
				easing = "linear",
				bIgnoreConfig = true,
			})
		end
	})

	if IsValid(hg.furload) then
		hg.furload:Remove()
	end
	hg.furload = self

	self:SetSize(sw, sh)
	self:RequestFocus()

	-- sound.PlayFile("sound/zbattle/boot.ogg", "", function()
	-- end)

	sound.PlayFile("sound/zbattle/startup2.ogg", "", function()
	end)

	sound.PlayFile("sound/zbattle/startup_scan.ogg", "", function()
	end)

	timer.Simple(4.4, function()
		sound.PlayFile("sound/zbattle/scan_flash.ogg", "", function()
		end)
	end)

	self.ScrollDelay = 1

	self.ScrollLastTime = 0
	self.ScrollStartTime = RealTime() + 3

	self.Cursors = {}
	self.CursorLength = 10

	self.RandomDelay = {}

	self.matrixX = 80
	self.matrixY = 42 + self.CursorLength

	for i = 1, self.matrixX do
		self.RandomDelay[i] = RealTime() + 3 + math.Rand(0, 0.1)
	end

	self.TextArray = {}
	for x = 1, self.matrixX do
		self.TextArray[x] = self.TextArray[x] or {}
		for y = 1, self.matrixY do
			self.TextArray[x][y] = math.random(0, 2) == 2 and "1" or "0"
		end
	end

	self.RandomAlpha = {}
	for x = 1, self.matrixX do
		self.RandomAlpha[x] = self.RandomAlpha[x] or {}
		for y = 1, self.matrixY do
			self.RandomAlpha[x][y] = math.Rand(0.5, 1)
		end
	end

	self.RandomFlash = {}
	for x = 1, self.matrixX do
		self.RandomFlash[x] = self.RandomFlash[x] or {}
		for y = 1, self.matrixY do
			self.RandomFlash[x][y] = (math.random(1, 10) == 1 and true) or nil
		end
	end

	self.flash = 0
	timer.Simple(4.9, function()
		self.flash = 1
		for x = 1, self.matrixX do
			self.TextArray[x] = self.TextArray[x] or {}
			for y = 1, self.matrixY do
				if self.RandomFlash[x][y] then
					self.TextArray[x][y] = (self.TextArray[x][y] == "0" and "1") or "0"
				end
			end
		end
		self:CreateAnimation(2, {
			index = 40,
			target = {
				flash = 0
			},
			easing = "outQuint",
			bIgnoreConfig = true
		})
	end)

	self.haveanicedayalpha = 0

	self.BootStage = 1

	local BootTimes = {
		1,
		2,
		2.2,
		2.5,
		2.7,
		4.2, //memory scan complete
		4.3,
		4.9, //memory adjustment complete
		6.2,
		6.5
	}

	for k, v in ipairs(BootTimes) do
		timer.Simple(v, function()
			if IsValid(self) then
				self.BootStage = k
			end
		end)
	end
end

function PANEL:Close()
	self.done = true
	sound.PlayFile("sound/zbattle/login.wav", "", function()
	end)

	self.alpha = 255
	self.haveanicedayalpha = 255

	timer.Simple(1, function()
		self:CreateAnimation(1, {
			index = 2,
			target = {
				alpha = 0
			},
			easing = "linear",
			bIgnoreConfig = true,
			Think = function()
				self:SetAlpha(self.alpha)
			end,
			OnComplete = function()
				self:CreateAnimation(5, {
					index = 4,
					target = {
						haveanicedayalpha = 0
					},
					easing = "outQuint",
					bIgnoreConfig = true,
					Think = function()
						self:SetAlpha(self.alpha)
					end,
					OnComplete = function()
						self:Remove()
					end
				})
			end
		})
	end)

	self:CreateAnimation(1, {
		index = 3,
		target = {
			alphagrid = 0
		},
		easing = "linear",
		bIgnoreConfig = true,
	})
end

local blur = Material("pp/blurscreen")

local blue = Color(149, 121, 214)
local red = Color(178, 33, 47)
local white = Color(230, 192, 255)
local glow = Color(149, 121, 214)
local glow2 = Color(119, 97, 169)

function PANEL:DrawMatrix()
	local init = self.initAnim2
	local BootUpProgress = self.progress

	local MatrixCursorPos = (math.Round((1 - BootUpProgress) * (self.matrixY + 1)))

	if self.alpha > 0 then
		for x = 1, self.matrixX do
			for y = 1, self.matrixY do
				local posX = sw / self.matrixX * (x - 1)
				local posY = sh / (self.matrixY - self.CursorLength) * ((y - self.CursorLength) - 1)

				if posY > sh or posY < 0 then continue end

				local pos = MatrixCursorPos

				local alpha = init * self.RandomAlpha[x][y]

				if y == pos then
					draw.GlowingText(self.TextArray[x][y], "ZB_ProotOSMatrix", posX, posY, ColorAlpha(white, alpha * 255), ColorAlpha(glow, alpha * 255), ColorAlpha(glow2, alpha * 255))
				else
					local color
					if y < pos then
						color = ColorAlpha(red, 20 * alpha)
					else
						color = ColorAlpha(blue, math.Clamp(255 - ((y - pos) * (255 / self.CursorLength)), 20, 255) * alpha)
					end
					draw.SimpleText(self.TextArray[x][y], "ZB_ProotOSMatrix", posX, posY, color)
				end

				if self.flash >= 0 and self.RandomFlash[x][y] then
					draw.GlowingText("▓", "ZB_ProotOSMatrix2", posX, posY + ScreenScale(3), ColorAlpha(white, self.flash * alpha * 255), ColorAlpha(glow, self.flash * alpha * 255), ColorAlpha(glow2, self.flash * alpha * 255))
				end
			end
		end
	end
end

local BootStages = {
	[1] = function(init2)
		draw.SimpleText("SYSTEM BOOT INITIALIZATION", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05, ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end,
	[2] = function(init2)
		draw.SimpleText("SYSTEM BOOT INITIALIZATION", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05, ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("OwOS version: 2.13.0", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 1 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end,
	[3] = function(init2)
		draw.SimpleText("SYSTEM BOOT INITIALIZATION", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05, ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("OwOS version: 2.13.0", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 1 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("GLOBAL SYSTEM CHECK:", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 2 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end,
	[4] = function(init2)
		draw.SimpleText("SYSTEM BOOT INITIALIZATION", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05, ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("OwOS version: 2.13.0", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 1 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("GLOBAL SYSTEM CHECK:", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 2 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("OPTICS: OK", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 3 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("TOUCH: OK", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 4 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("HEARING: OK", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 5 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("SMELL: MODULE NOT FOUND", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 6 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("TASTE: MODULE NOT FOUND", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 7 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end,
	[5] = function(init2)
		draw.SimpleText("SYSTEM BOOT INITIALIZATION", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05, ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("OwOS version: 2.13.0", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 1 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("GLOBAL SYSTEM CHECK:", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 2 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("OPTICS: OK", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 3 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("TOUCH: OK", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 4 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("HEARING: OK", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 5 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("SMELL: MODULE NOT FOUND", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 6 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("TASTE: MODULE NOT FOUND", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 7 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("Memory Scan: IN PROGRESS", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 8 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end,
	[6] = function(init2)
		draw.SimpleText("SYSTEM BOOT INITIALIZATION", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05, ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("OwOS version: 2.13.0", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 1 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("GLOBAL SYSTEM CHECK:", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 2 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("OPTICS: OK", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 3 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("TOUCH: OK", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 4 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("HEARING: OK", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 5 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("SMELL: MODULE NOT FOUND", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 6 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("TASTE: MODULE NOT FOUND", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 7 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("Memory Scan: COMPLETE", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 8 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end,
	[7] = function(init2)
		draw.SimpleText("SYSTEM BOOT INITIALIZATION", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05, ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("OwOS version: 2.13.0", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 1 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("GLOBAL SYSTEM CHECK:", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 2 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("OPTICS: OK", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 3 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("TOUCH: OK", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 4 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("HEARING: OK", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 5 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("SMELL: MODULE NOT FOUND", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 6 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("TASTE: MODULE NOT FOUND", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 7 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("Memory Scan: COMPLETE", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 8 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("Memory Adjustment: IN PROGRESS", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 9 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end,
	[8] = function(init2)
		draw.SimpleText("SYSTEM BOOT INITIALIZATION", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05, ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("OwOS version: 2.13.0", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 1 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("GLOBAL SYSTEM CHECK:", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 2 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("OPTICS: OK", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 3 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("TOUCH: OK", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 4 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("HEARING: OK", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 5 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("SMELL: MODULE NOT FOUND", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 6 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("TASTE: MODULE NOT FOUND", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 7 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("Memory Scan: COMPLETE", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 8 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("Memory Adjustment: COMPLETE", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 9 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end,
	[9] = function(init2)
		draw.SimpleText("SYSTEM BOOT INITIALIZATION", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05, ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("OwOS version: 2.13.0", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 1 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("GLOBAL SYSTEM CHECK:", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 2 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("OPTICS: OK", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 3 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("TOUCH: OK", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 4 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("HEARING: OK", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 5 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("SMELL: MODULE NOT FOUND", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 6 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("TASTE: MODULE NOT FOUND", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 7 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("Memory Scan: COMPLETE", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 8 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("Memory Adjustment: COMPLETE", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 9 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("Consciousness initializing...", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 10 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end,
	[10] = function(init2)
		draw.SimpleText("SYSTEM BOOT INITIALIZATION", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05, ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("OwOS version: 2.13.0", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 1 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("GLOBAL SYSTEM CHECK:", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 2 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("OPTICS: OK", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 3 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("TOUCH: OK", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 4 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("HEARING: OK", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 5 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("SMELL: MODULE NOT FOUND", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 6 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("TASTE: MODULE NOT FOUND", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 7 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("Memory Scan: COMPLETE", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 8 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("Memory Adjustment: COMPLETE", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 9 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("Consciousness initializing...", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 10 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("echo \"Have a very :3 day!\"", "ZB_ProotOSSmall", sw * 0.012, sh * 0.05 + 11 * ScreenScale(5), ColorAlpha(bluewhite, 255 * init2), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end,
}

function PANEL:Paint()
	local BootUpProgress = self.progress

	local init = self.initAnim
	local init2 = self.initAnim2 * 10

	//grid sweep
	surface.SetDrawColor(0, 0, 0, init * 255)
	surface.DrawRect(-10, -10, sw + 10, sh + 10)

	-- surface.SetDrawColor(4, 19, 22, self.alphagrid * init)

	-- for i = 1, (ybars + 1) do
	-- 	surface.DrawRect((sw / ybars) * i - (CurTime() * 30 % (sw / ybars)), 0, ScreenScale(1), sh)
	-- end

	-- for i = 1, (xbars + 1) do
	-- 	surface.DrawRect(0, (sh / xbars) * (i - 1) + (CurTime() * 30 % (sh / xbars)), sw, ScreenScale(1))
	-- end

	self:DrawMatrix()

	local text = "Now loading..."
	local trim = 12 + (math.Round(CurTime()) % 3)

	text = string.Left(text, trim)

	local rainbow = HSVToColor(CurTime() * 50 % 360, 0.9, 0.9)

	draw.GlowingText("OwOS", "ZB_ProotOSLarge", sw * 0.5 + ScreenScale(1), sh * 0.4 + ScreenScale(1), ColorAlpha(rainbow, 100 * init2), ColorAlpha(rainbow, 10 * init2), ColorAlpha(rainbow, 2 * init2), TEXT_ALIGN_CENTER)
	draw.GlowingText("OwOS", "ZB_ProotOSLarge", sw * 0.5, sh * 0.4, ColorAlpha(bluewhite, 255 * init2), ColorAlpha(bluewhite, 235 * init2), ColorAlpha(bluewhite, 10 * init2), TEXT_ALIGN_CENTER)
	draw.GlowingText(text, "ZB_ProotOSMedium", sw * 0.4, sh * 0.485, ColorAlpha(bluewhite, 255 * init2), ColorAlpha(bluewhite, 50 * init2), ColorAlpha(bluewhite, 10 * init2))

	draw.GlowingText(math.Round(BootUpProgress * 100) .. "%", "ZB_ProotOSSmall", sw * 0.6, sh * 0.5, ColorAlpha(bluewhite, 255 * init2), ColorAlpha(bluewhite, 50 * init2), ColorAlpha(bluewhite, 10 * init2), TEXT_ALIGN_RIGHT)

	surface.SetDrawColor(ColorAlpha(color_black, 100 * init2))
	surface.DrawRect(sw * 0.4, sh * 0.52, sw * 0.2, sh * 0.02)

	surface.SetDrawColor(ColorAlpha(bluewhite, 255 * init2))
	surface.DrawRect(sw * 0.4, sh * 0.52, sw * 0.2 * BootUpProgress, sh * 0.02)

	surface.SetDrawColor(149, 121, 214, 255 * init2)
	surface.SetMaterial(gradient_l)
	surface.DrawTexturedRect(sw * 0.4, sh * 0.52, sw * 0.2 * BootUpProgress, sh * 0.02)

	surface.SetDrawColor(ColorAlpha(bluewhite, 255 * init2))
	surface.DrawOutlinedRect(sw * 0.4 - 5, sh * 0.52 - 5, sw * 0.2 + 10, sh * 0.02 + 10)

	BootStages[self.BootStage](init2)
end

local tab = {
	[ "$pp_colour_brightness" ] = 0,
	[ "$pp_colour_contrast" ] = 1,
}


hook.Add("RenderScreenspaceEffects", "furload", function()
	if IsValid(hg.furload) and hg.furload.alpha != 255 then
		tab["$pp_colour_brightness"] = hg.furload.alpha / 255
		DrawColorModify(tab)

		local alpha = hg.furload.haveanicedayalpha

		draw.SimpleText("Have a very :3 day!", "ZB_ProotOSMedium", sw * 0.5 + 2, sh * 0.8 + 2, ColorAlpha(color_black, 255 * alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("Have a very :3 day!", "ZB_ProotOSMedium", sw * 0.5, sh * 0.8, ColorAlpha(bluewhite, 255 * alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end)

hook.Add("ModifyTinnitusFactor", "fur", function(value)
	if IsValid(hg.furload) then
		local modified = (value + (hg.furload.alpha / 255) * 100) * hg.furload.initAnim
		return modified
	end
end)

vgui.Register("ZB_FurLoading", PANEL, "EditablePanel")