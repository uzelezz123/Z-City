local CLASS = player.RegClass("furry")

function CLASS.Off(self)
	if CLIENT then return end

	ApplyAppearance(self,false,false,false,true)

	-- if self.oldspeed then
	-- 	self:SetRunSpeed(self.oldspeed)
	-- 	self.oldspeed = nil
	-- end

	if SERVER then
		self.organism.bloodtype = self.oldbloodtype or "o-"
		
		hg.ClearArmorRestrictions(self)
	end

	if eightbit and eightbit.EnableEffect and self.UserID then
		eightbit.EnableEffect(self:UserID(), 0)
	end

	self.JumpPowerMul = nil
	self.SpeedGainClassMul = nil
	self:SetNWInt("SpeedGainClassMul", nil)
	self.MeleeDamageMul = nil
	self.StaminaExhaustMul = nil
end

local sw, sh = CLIENT and ScrW() or nil, CLIENT and ScrH() or nil

local oneofus = {
	"One of us! One of us!",
	"A new one!",
	"We are unstoppable!",
	"A new meaning to life itself!",
	"Assimilation complete!",
	"Turning into tigers, turning into wolves...",
	"A new purpose in life!"
}

local function Randomize(self)
	-- for _, bg in ipairs(self:GetBodyGroups()) do
	-- 	if bg.id > 0 and bg.num > 0 then
	-- 		self:SetBodygroup(bg.id, math.random(0, bg.num - 1))
	-- 	end
	-- end
	-- self:SetSkin(math.random(0, 5))

	if SERVER then
		self:SetSkin(4)

		local random = math.random(0, 4)
		if random == 1 then // no place for silly nub tails >w<
			random = 0
		end
		self:SetBodygroup(1, random)

		local Appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()
		Appearance.AAttachments = ""
		Appearance.AColthes = ""
		local plycolor = Color(Appearance.AColor.r, Appearance.AColor.g, Appearance.AColor.b)

		-- local plycolor = self:GetPlayerColor()
		if plycolor then
			local h, s, l = plycolor:ToHSL()
			plycolor = HSLToColor(h, s / 4, l * 2)
			Appearance.AColor = plycolor

			plycolor = plycolor:ToVector()
		end

		self:SetNetVar("Accessories", "")

		self.CurAppearance = Appearance

		self:SetPlayerColor(plycolor or VectorRand(0.95, 1))
	end
end

CLASS.NoGloves = true
local col1 = Color(121, 97, 217)

function CLASS.On(self, data)
	if SERVER then
		if eightbit and eightbit.EnableEffect and self.UserID then
            eightbit.EnableEffect(self:UserID(), eightbit.EFF_PROOT)
		end

		if self.organism then
			self.oldbloodtype = self.organism.bloodtype
			self.organism.bloodtype = "c-"
		end

		local Appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()

		local name = "Specimen #" .. math.random(1, 999)

		self:SetNWString("PlayerName", name)
		Appearance.AName = name

		hg.SetArmorRestrictions(self, {all = true})
	end

	if data.instant then
		if SERVER then
			-- self.oldspeed = self:GetRunSpeed()
			-- self:SetRunSpeed(3000)
			self.JumpPowerMul = 1.5
			self.SpeedGainClassMul = 5
			self.StaminaExhaustMul = 0.75
			self:SetNWInt("SpeedGainClassMul", self.SpeedGainClassMul)
	
			self.armors = {}
			//self.armors["torso"] = "cmb_armor"
			self.armors["head"] = "protovisor"
			self:SyncArmor()

			zb.GiveRole(self, "Specimen", col1)
		else
			hg.furcrack = {}
		end

		self:SetModel("models/eradium/protogen_player.mdl")

		self:SetSubMaterial()

		if self.SetNetVar then
			self:SetNetVar("Accessories", "")
		end

		Randomize(self)

		for i = 1, self:GetFlexNum() - 1 do
			self:SetFlexWeight(i, 0)
		end

		return
	end

	hook.Run("HG_OnAssimilation", self)
	-- Randomize(self)

	if CLIENT then
		if lply == self then
			vgui.Create("ZB_FurLoading")
			-- atlaschat.font:SetString("ZB_ProotOSChat")
			hg.furcrack = {}
		end

		//local ent = hg.GetCurrentCharacter(self)

		if IsValid(self.mdlfur) then
			self.mdlfur:Remove()
		end

		self.mdlfur = ClientsideModel("models/eradium/protogen_player.mdl")
		self.mdlfur.GetPlayerColor = function() return self:GetPlayerColor() end
		local mdl = self.mdlfur
		mdl:SetNoDraw(true)

		hg.converging[self] = CurTime()


		return
	else
		-- self.oldspeed = self:GetRunSpeed()
		-- self:SetRunSpeed(3000)
		self.JumpPowerMul = 1.5
		self.SpeedGainClassMul = 5
		self:SetNWInt("SpeedGainClassMul", self.SpeedGainClassMul)
		self.StaminaExhaustMul = 0.75

		hg.SetArmorRestrictions(self, {all = true})

		self.armors = {}
		//self.armors["torso"] = "cmb_armor"
		self.armors["head"] = "protovisor"
		self:SyncArmor()

		if zb and zb.GiveRole then zb.GiveRole(self, "Specimen", col1) end

		for _, v in player.Iterator() do
			if math.random(1, 3) == 1 then
				if v:Alive() and v.PlayerClassName == "furry" and self:GetPos():Distance(v:GetPos()) < 256 and v != self then
					v:Notify(table.Random(oneofus))
				end
			end
		end
	end

	-- self:SetNWString("PlayerName", rank .. " " .. Appearance.AName)

	hg.Fake(self, nil, true)
	timer.Create("furry"..self:EntIndex(), 1.6, 1, function()
		if IsValid(self) then
			hg.SavePoses(self)
			hg.FakeUp(self, true, true)

			self:SetModel("models/eradium/protogen_player.mdl")

			self:SetSubMaterial()

			if self.SetNetVar then
				self:SetNetVar("Accessories", "")
			end

			Randomize(self)

			for i = 1, self:GetFlexNum() - 1 do
				self:SetFlexWeight(i, 0)
			end

			hg.Fake(self, nil, true)
			hg.ApplyPoses(self)

			hg.organism.Clear( self.organism )

			if self.organism then
				self.oldbloodtype = self.organism.bloodtype
				self.organism.bloodtype = "c-"
			end
		end
	end)
end

local bluewhite = Color(187, 187, 255)

if CLIENT then
	surface.CreateFont("ZB_ProotLarge", {
		font = "Bahnschrift",
		size = ScreenScale(8),
		extended = true,
		weight = 400,
		antialias = true
	})

	surface.CreateFont("ZB_ProotLarge2", {
		font = "Bahnschrift",
		size = ScreenScale(8),
		extended = true,
		weight = 400,
		antialias = true
	})
end

-- local symbols = {
-- 	[1] = {
-- 		symbol = "▓▓",
-- 		value = 7
-- 	},
-- 	[2] = {
-- 		symbol = "▒▒",
-- 		value = 4
-- 	},
-- 	[3] = {
-- 		symbol = "░░",
-- 		value = 1
-- 	},
-- }

// old shit!!!!!!

-- local aimvectorsmooth = Angle()
-- local hpcolor = Color(229, 56, 26)
-- local shadow = Color(0, 0, 0, 150)
-- local healthlerp = 0
-- local shadowbar = Color(50, 50, 75, 50)

-- -- 	draw.GlowingText("INTEGRITY", "ZB_ProotLarge", w / 2, h * 0.8, ColorAlpha(bluewhite, 255), ColorAlpha(bluewhite, 255), ColorAlpha(bluewhite, 255), TEXT_ALIGN_CENTER)
-- -- 	draw.GlowingText("NOMINAL", "ZB_ProotLarge", w / 2, h * 0.85, ColorAlpha(bluewhite, 255), ColorAlpha(bluewhite, 255), ColorAlpha(bluewhite, 255), TEXT_ALIGN_CENTER)

-- 	local frametime = 1 - math.exp(-0.5 * FrameTime())
-- 	if frametime > 0.01 then
-- 		frametime = 0.01
-- 	end

-- 	draw.SimpleText(":", "ZB_ProotLarge", sw * 0.2, sh * 0.8, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
-- 	draw.SimpleTextOutlined("ЦЕЛОСТНОСТЬ:", "ZB_ProotLarge", sw * 0.2, sh * 0.8, bluewhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, ColorAlpha(shadow, 50))
-- 		draw.GlowingText("ЦЕЛОСТНОСТЬ:", "ZB_ProotLarge2", sw * 0.2, sh * 0.8, ColorAlpha(bluewhite, 255), ColorAlpha(bluewhite, 200), ColorAlpha(bluewhite, 100), TEXT_ALIGN_CENTER)

-- 	local HealthBar = ""

-- 	local health = LocalPlayer():Health()
-- 	healthlerp = Lerp(FrameTime(), healthlerp, health)

-- 	for i = 0, 9 do
-- 		if math.Round(healthlerp) >= ((i + 1) * (LocalPlayer():GetMaxHealth() / 10)) then
-- 			HealthBar = HealthBar .. "██ "
-- 		else
-- 			local LastDigits = healthlerp - (i * (LocalPlayer():GetMaxHealth() / 10))

-- 			local symbol = "  "

-- 			for i2 = 1, 3 do
-- 				if LastDigits >= symbols[i2].value then
-- 					symbol = symbols[i2].symbol
-- 					break
-- 				end
-- 			end

-- 			HealthBar = HealthBar .. symbol
-- 		end
-- 	end

-- 	draw.SimpleText("██ ██ ██ ██ ██ ██ ██ ██ ██ ██", "ZB_ProotLarge", sw * 0.12, sh * 0.81, shadowbar)
-- 	draw.SimpleText(HealthBar, "ZB_ProotLarge", sw * 0.12 + 1, sh * 0.81 + 1, shadow)
-- 	-- draw.SimpleTextOutlined(HealthBar, "ZB_ProotLarge", sw * 0.12, sh * 0.81, hpcolor, nil, nil, 1, ColorAlpha(shadow, 50))

-- 	draw.GlowingText(HealthBar, "ZB_ProotLarge2", sw * 0.12, sh * 0.81, ColorAlpha(bluewhite, 255), ColorAlpha(bluewhite, 200), ColorAlpha(bluewhite, 100))

local xbars = 17
local ybars = 30

local gradient_l = Material("vgui/gradient-l")
local assimilation = 0
local alpha = 0

function CLASS.HUDPaint(self)
	if !self:Alive() then return end

	local carryent = lply.GetNetVar and lply:GetNetVar("carryent") or nil

	assimilation = Lerp(1, assimilation, lply:GetLocalVar("assimilation", 0))

	alpha = LerpFT(0.1, alpha, IsValid(carryent) and carryent.organism and carryent.organism.alive and carryent.organism.owner.PlayerClassName != "furry" and hg.KeyDown(lply, IN_ATTACK) and 255 or 0)
	-- render.PushFilterMag(TEXFILTER.ANISOTROPIC)
	-- render.PushFilterMin(TEXFILTER.ANISOTROPIC)

	surface.SetFont("ZB_ProotOSAssimilation")
	surface.SetTextColor(50, 50, 50, alpha)
	local txt = "Assimilating..."
	local w, h = surface.GetTextSize(txt)
	surface.SetTextPos(sw * 0.5 - w * 0.5, sh * 0.75 - h - ScreenScale(5))
	surface.DrawText(txt)

	surface.SetFont("ZB_ProotOSAssimilation")
	surface.SetTextColor(50, 50, 50, alpha)
	local txt = "Assimilating..."
	local w, h = surface.GetTextSize(txt)
	surface.SetTextPos(sw * 0.5 - w * 0.5 + 2, sh * 0.75 - h - ScreenScale(5) + 2)
	surface.DrawText(txt)

	render.SetScissorRect(0, sh * 0.75 - (assimilation * ScreenScale(20)), sw, sh, true)
		surface.SetFont("ZB_ProotOSAssimilation")
		surface.SetTextColor(164, 171, 2350, alpha)
		local txt = "Assimilating..."
		local w, h = surface.GetTextSize(txt)
		surface.SetTextPos(sw * 0.5 - w * 0.5, sh * 0.75 - h - ScreenScale(5))
		surface.DrawText(txt)

		-- surface.SetDrawColor(255, 255, 255)
		-- surface.DrawRect(0, 0, sw, sh)
	render.SetScissorRect( 0, 0, 0, 0, false )


	-- if !lply.testpluv then return end

	-- local sw, sh = ScrW(), ScrH()

	-- BootUpProgress = Lerp(FrameTime() / 2, BootUpProgress, 1)

	-- //grid sweep
	-- surface.SetDrawColor(0, 0, 0)
	-- surface.DrawRect(-10, -10, sw + 10, sh + 10)

	-- surface.SetDrawColor(4, 19, 22)

	-- for i = 1, (ybars + 1) do
	-- 	surface.DrawRect((sw / ybars) * i - (CurTime() * 30 % (sw / ybars)), 0, ScreenScale(1), sh)
	-- end

	-- for i = 1, (xbars + 1) do
	-- 	surface.DrawRect(0, (sh / xbars) * (i - 1) + (CurTime() * 30 % (sh / xbars)), sw, ScreenScale(1))
	-- end

	-- local text = "Now loading..."
	-- local trim = 12 + (math.Round(CurTime()) % 3)

	-- text = string.Left(text, trim)

	-- draw.GlowingText("OwOS", "ZB_ProotOSLarge", sw * 0.5, sh * 0.4, ColorAlpha(bluewhite, 255), ColorAlpha(bluewhite, 235), ColorAlpha(bluewhite, 10), TEXT_ALIGN_CENTER)
	-- draw.GlowingText(text, "ZB_ProotOSMedium", sw * 0.46, sh * 0.485, ColorAlpha(bluewhite, 255), ColorAlpha(bluewhite, 50), ColorAlpha(bluewhite, 10))

	-- surface.SetDrawColor(bluewhite)
	-- surface.DrawRect(sw * 0.4, sh * 0.52, sw * 0.2 * BootUpProgress, sh * 0.02)

	-- surface.SetDrawColor(149, 121, 214)
	-- surface.SetMaterial(gradient_l)
	-- surface.DrawTexturedRect(sw * 0.4, sh * 0.52, sw * 0.2 * BootUpProgress, sh * 0.02)

	-- surface.SetDrawColor(bluewhite)
	-- surface.DrawOutlinedRect(sw * 0.4 - 5, sh * 0.52 - 5, sw * 0.2 + 10, sh * 0.02 + 10)
end

function CLASS.Guilt(self, victim)
    if victim:GetPlayerClass() == self:GetPlayerClass() then
        return 1
    end
end

local CrackMat = Material( "effects/shaders/zb_shattered_ps30" )

local rnd1 = math.Rand(1, 999)
local rnd2 = math.Rand(1, 999)
local rnd3 = math.Rand(1, 999)
local rnd4 = math.Rand(1, 999)

local amount = 0.4
hg.furcrack = {
	-- ["intensity"]	=	0.12508668005466,
	-- ["x"]	=	0.59191020339656,
	-- ["y"]	=	0.11713030567233,
}

hook.Add("RenderScreenspaceEffects","proot_HUD",function()
	if !lply:Alive() or lply.PlayerClassName != "furry" then return end

	CLASS.HUDPaint(lply)

	if hg.furcrack.intensity then
		hg.furcrack.intensity = Lerp(FrameTime() / 30, hg.furcrack.intensity, 0)
	end

	if hg.furcrack.intensity and hg.furcrack.intensity < 0.001 then
		hg.furcrack = {}
	end

	if hg.furcrack.intensity then
		render.SetMaterial(CrackMat)
		render.UpdateScreenEffectTexture()
		CrackMat:SetFloat("$c0_x", hg.furcrack.x) //crackX
		CrackMat:SetFloat("$c0_y", hg.furcrack.y) //crackY
		CrackMat:SetFloat("$c1_x", 1 - (hg.furcrack.intensity ^ 0.001)) //Lerp

		CrackMat:SetFloat("$c1_y", 20) //Lerp

		CrackMat:SetFloat("$c1_z", hg.furcrack.rnd1) //amount
		CrackMat:SetFloat("$c2_x", hg.furcrack.rnd2) //amount
		CrackMat:SetFloat("$c2_y", hg.furcrack.rnd3) //amount
		CrackMat:SetFloat("$c2_z", hg.furcrack.rnd4) //amount
		render.DrawScreenQuad()
	end
end)

if CLIENT then
	net.Receive("CrackScreen", function()
		local crack = {
			x = math.Rand(0.1, 0.9),
			y = math.Rand(0.1, 0.9),
			intensity = net.ReadFloat(),
			rnd1 = math.Rand(1, 999),
			rnd2 = math.Rand(1, 999),
			rnd3 = math.Rand(1, 999),
			rnd4 = math.Rand(1, 999),
		}

		if hg.furcrack.intensity then
			hg.furcrack.intensity = math.Clamp(hg.furcrack.intensity + crack.intensity, 0, 0.8)
		else
			hg.furcrack = crack
		end
	end)
end

if CLIENT then
	local scancolor = Color(60, 199, 220)

	local SPHERE_NUMBER_RULES = {[0]=2,[1]=1,[3]=2,[5]=1,[7]=2,[9]=1}

	local function isInSphere(ent, spherePos, radius)
		if not IsValid(ent) then return false end
		local entPos = ent:GetPos()
		return entPos:DistToSqr(spherePos) <= radius * radius
	end

	local ds = 0

	function BorderSphereUnit(color, pos, radius, detail, thickness)
		radius = math.floor(radius)
		thickness = math.floor(thickness or 24)
		detail = math.min(math.floor(detail or 32), 100)

		if thickness >= radius then
			thickness = radius
		end

		local lastDigit = tonumber(string.sub(tostring(radius), -1))
		local rule = SPHERE_NUMBER_RULES[lastDigit]
		if rule == 1 then
			ds = 1
		elseif rule == 2 then
			ds = 0.50
		end

		local view = render.GetViewSetup(true)
		local cam_pos, cam_angle = view.origin, view.angles

		local cam_normal = cam_angle:Forward()

		render.SetStencilEnable(true)

		render.ClearStencil()

		render.SetStencilReferenceValue(0x55)
		render.SetStencilTestMask(0x1C)
		render.SetStencilWriteMask(0x1C)
		render.SetStencilPassOperation( STENCIL_KEEP )
		render.SetStencilZFailOperation( STENCIL_KEEP )
		render.SetStencilCompareFunction( STENCIL_KEEP )
		render.SetStencilFailOperation( STENCIL_KEEP )

		render.SetColorMaterial()
		local detailWithDs = detail + ds
		local radiusMinusThickness = radius - thickness

		render.SetStencilReferenceValue(1)
		render.SetStencilCompareFunction(STENCIL_ALWAYS)
		render.SetStencilZFailOperation(STENCIL_INVERT)

		local invisibleColor = Color(0, 0, 0, 0)
		render.DrawSphere(pos, -radius, detail, detail, invisibleColor)
		render.DrawSphere(pos, radius, detail, detail, invisibleColor)
		render.DrawSphere(pos, -radiusMinusThickness, detailWithDs, detailWithDs, invisibleColor)
		render.DrawSphere(pos, radiusMinusThickness, detailWithDs, detailWithDs, invisibleColor)

		render.SetStencilZFailOperation(STENCIL_REPLACE)
		render.DrawSphere(pos, radius + 0.25, detailWithDs, detailWithDs, invisibleColor)

		render.SetStencilCompareFunction(STENCIL_NOTEQUAL)
		
		cam.IgnoreZ(true)

		render.SetStencilReferenceValue(1)
		render.DrawQuadEasy(cam_pos + cam_normal * 10, -cam_normal, 10000, 10000, color, cam_angle.roll)

		cam.IgnoreZ(false)

		render.SetStencilPassOperation( STENCIL_KEEP )
		render.SetStencilZFailOperation( STENCIL_KEEP )
		render.SetStencilCompareFunction( STENCIL_KEEP )
		render.SetStencilFailOperation( STENCIL_KEEP )
		render.SetStencilTestMask(0xFF)
		render.SetStencilWriteMask(0xFF)
		render.SetStencilReferenceValue(0)

		render.ClearStencil()

		render.SetStencilEnable(false)
	end

	local scanRadius = 0
	local scan = false
	local scanPos = Vector()

	local scanCD = 0

	local foundPrey = {}

	hook.Add("PostDrawTranslucentRenderables", "FindPrey", function()
		if scan then
			scanRadius = math.Approach(scanRadius, 100000, FrameTime() * 1000)
			BorderSphereUnit(ColorAlpha(scancolor, 255 - (math.min(scanRadius / 30, 255))), scanPos, scanRadius, 32, scanRadius / 30)

			for _, ply in player.Iterator() do
				if ply == lply then continue end

				if isInSphere(ply, scanPos, scanRadius) and !foundPrey[ply] and ply:Alive() then
					local color
					if ply.PlayerClassName != "furry" then
						local weaponry = ply:GetWeapons()
						local armed = false
						for _, v in ipairs(weaponry) do
							if ishgweapon(v) then
								armed = true
								break
							end
						end

						if armed then
							color = Color(255 - math.min(255, scanRadius / 150), 0 + math.min(255, scanRadius / 500), 0 + math.min(255, scanRadius / 500))
						else
							color = Color(255 - math.min(255, scanRadius / 150), 200 - math.min(255, scanRadius / 150), 0 + math.min(255, scanRadius / 500))
						end
					else
						color = scancolor
					end

					foundPrey[ply] = {
						pos = ply:GetPos(),
						color = color,
						time = CurTime() + 5
					}

					surface.PlaySound("zbattle/sonarping.ogg")
				end
			end
		else
			scanRadius = 0
		end
	end)

	local glow = Material("sprites/light_ignorez")

	hook.Add("HUDPaint", "FindPrey", function()
		if lply.PlayerClassName != "furry" then return end

		-- PrintTable(foundPrey)

		local scrW, scrH = ScrW(), ScrH()

		for _, v in pairs(foundPrey) do
			local screenPosition = v.pos:ToScreen()

			local marginX, marginY = scrH * .1, scrH * .1
			local x, y = math.Clamp(screenPosition.x, marginX, scrW - marginX), math.Clamp(screenPosition.y, marginY, scrH - marginY)

			local size = 100

			surface.SetDrawColor(ColorAlpha(v.color, math.max(0, (v.time - CurTime()) * 100)))
			surface.SetMaterial(glow)
			surface.DrawTexturedRect(x - size / 2, y - size / 2, size, size)
		end
	end)

	local function scanForPrey()
		if scanCD > CurTime() then
			return
		end

		surface.PlaySound("zbattle/charge.wav")

		scanCD = CurTime() + 20

		timer.Simple(2.5, function()
			scanRadius = 0
			foundPrey = {}
			scanPos = lply:EyePos()

			scan = true

			timer.Simple(5, function()
				fadeGoal = 0
			end)

			timer.Simple(20, function()
				scan = false
				foundPrey = {}

				surface.PlaySound("zbattle/flashcharge.ogg")
			end)

			surface.PlaySound("zbattle/sonar.ogg")

			for i = 1, 30 do
				timer.Simple(i/60,function()
					ViewPunch(AngleRand(-.3,.3))
				end)
			end
		end)
	end

	hook.Add("radialOptions", "scanprey", function()
		if LocalPlayer():Alive() and LocalPlayer().PlayerClassName == "furry" then
			hg.radialOptions[#hg.radialOptions + 1] = {scanForPrey, "Scan"}
		end
	end)

	local white = Material("sprites/physbeama")

	hg.converging = hg.converging or {}

	local validBones = {
		["ValveBiped.Bip01_Pelvis"] = true,
		["ValveBiped.Bip01_Spine1"] = true,
		["ValveBiped.Bip01_Spine2"] = true,
		["ValveBiped.Bip01_R_Clavicle"] = true,
		["ValveBiped.Bip01_L_Clavicle"] = true,
		["ValveBiped.Bip01_R_UpperArm"] = true,
		["ValveBiped.Bip01_L_UpperArm"] = true,
		["ValveBiped.Bip01_L_Forearm"] = true,
		["ValveBiped.Bip01_L_Hand"] = true,
		["ValveBiped.Bip01_R_Forearm"] = true,
		["ValveBiped.Bip01_R_Hand"] = true,
		["ValveBiped.Bip01_R_Thigh"] = true,
		["ValveBiped.Bip01_R_Calf"] = true,
		["ValveBiped.Bip01_Head1"] = true,
		["ValveBiped.Bip01_Neck1"] = true,
		["ValveBiped.Bip01_L_Thigh"] = true,
		["ValveBiped.Bip01_L_Calf"] = true,
		["ValveBiped.Bip01_L_Foot"] = true,
		["ValveBiped.Bip01_R_Foot"] = true
	}

	function DrawConversion(ent, ply)
		if !hg.converging[ply] then
			if IsValid(ply.mdlfur) then
				ply.mdlfur:Remove()
			end

			return
		end
		
		local time = hg.converging[ply]

		if !IsValid(ent) then
			hg.converging[ply] = nil

			return
		end
		
		local status = math.ease.OutSine(1 - math.Clamp((time - CurTime() + 3) / 3, 0, 1))
		
		if status == 1 then
			hg.converging[ply] = nil
			
			if IsValid(ply.mdlfur) then
				ply.mdlfur:Remove()
			end

			return
		end
		
		render.SetStencilEnable( true )

		render.ClearStencil()
		render.SetStencilTestMask( 255 )
		render.SetStencilWriteMask( 255 )
		render.SetStencilPassOperation( STENCILOPERATION_KEEP )
		render.SetStencilZFailOperation( STENCILOPERATION_KEEP )
		render.SetStencilCompareFunction( STENCILOPERATION_KEEP )
		render.SetStencilFailOperation( STENCILOPERATION_KEEP )

		render.SetStencilReferenceValue( 1 )
		render.SetStencilFailOperation( STENCILOPERATION_REPLACE )

		if IsValid(ent) then
			ent:DrawModel()
		end

		render.SetStencilReferenceValue( 2 )

		render.SetMaterial(white)
		local pos = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Head1")):GetTranslation()
		render.DrawSphere(pos, 48 * math.max(status - 0.3, 0), 32, 32, color_white)
		local pos = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Spine1")):GetTranslation()
		render.DrawSphere(pos, 48 * math.max(status - 0.4, 0), 32, 32, color_white)
		local pos = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_L_Foot")):GetTranslation()
		render.DrawSphere(pos, 48 * math.max(status - 0.7, 0), 32, 32, color_white)
		local pos = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_R_Foot")):GetTranslation()
		render.DrawSphere(pos, 48 * math.max(status - 0.2, 0), 32, 32, color_white)
		//render.DrawSphere(pos + VectorRand(-16, 16), 64 * status, 32, 32, color_white)

		render.SetStencilFailOperation( STENCILOPERATION_KEEP )
		render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
		render.SetStencilReferenceValue( 2 )

		render.DepthRange( 0, 1 )

		if IsValid(ply.mdlfur) then
			local mdl = ply.mdlfur
			mdl:SetPos(ent:GetPos())
			mdl:SetupBones()
			ent:SetupBones()
			//PrintBones(mdl)
			/*for i = 0, mdl:GetBoneCount() - 1 do
				local bon = ent:LookupBone(mdl:GetBoneName(i))
				if !bon then continue end
				local m1 = mdl:GetBoneMatrix(i)
				local m2 = ent:GetBoneMatrix(bon)

				if !m1 or !m2 then continue end
				
				local q1 = Quaternion()
				q1:SetMatrix(m1)

				local q2 = Quaternion()
				q2:SetMatrix(m2)
				local q3 = q1:SLerp(q2, status)

				local newmat = Matrix()
				newmat:SetTranslation(LerpVector(status, m1:GetTranslation(), m2:GetTranslation()))
				newmat:SetAngles(q3:Angle())

				hg.bone_apply_matrix(ent, i, newmat)
				//hg.bone_apply_matrix(mdl, i, newmat)
			end*/
			for i = 0, mdl:GetBoneCount() - 1 do
				local nam = ent:GetBoneName(i)
				if !validBones[nam] then continue end
				local bon = mdl:LookupBone(nam)
				if !bon then continue end
				local m1 = ent:GetBoneMatrix(i)

				hg.bone_apply_matrix(mdl, bon, m1)
			end
			//ent:DrawModel()
			mdl:DrawModel()
		end

		render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NOTEQUAL )

		ent:DrawModel()

		render.DepthRange( 0, 1 )
		
		render.SetStencilWriteMask( 0xFF )
		render.SetStencilTestMask( 0xFF )
		render.SetStencilReferenceValue( 0 )
		render.SetStencilPassOperation( STENCIL_KEEP )
		render.SetStencilZFailOperation( STENCIL_KEEP )
		render.SetStencilFailOperation( STENCIL_KEEP )
		render.ClearStencil()

		render.SetStencilEnable( false )
	end
end

// stripped from combine playerclass
if CLIENT then
    local pnv_enabled = false
    local next_toggle_time = 0
    local toggle_cooldown = 1
    local transition_time = 1
    local transition_start = 0
    local transitioning = false
    local pnv_light = nil

    local pnv_color_1 = {
        ["$pp_colour_addr"] = 0,
        ["$pp_colour_addg"] = 0.07,
        ["$pp_colour_addb"] = 0.1,
        ["$pp_colour_brightness"] = 0.01,
        ["$pp_colour_contrast"] = 1.5,
        ["$pp_colour_colour"] = 0.3,
        ["$pp_colour_mulr"] = 0,
        ["$pp_colour_mulg"] = 0.1,
        ["$pp_colour_mulb"] = 0.5
    }

    local function togglePNV()
        local ply = LocalPlayer()
        if ply.PlayerClassName ~= "furry" or not ply:Alive() then
            if pnv_enabled then
                pnv_enabled = false
                surface.PlaySound("items/nvg_off.wav")
                hook.Remove("RenderScreenspaceEffects","PNV_ColorCorrectionFur")
                if IsValid(pnv_light) then
                    pnv_light:Remove()
                    pnv_light = nil
                end
            end
            return
        end

        pnv_enabled = not pnv_enabled
        transition_start = CurTime()

        if pnv_enabled then
            transitioning = true
            surface.PlaySound("items/nvg_on.wav")
            hook.Add("RenderScreenspaceEffects","PNV_ColorCorrectionFur",function()
                if ply.PlayerClassName ~= "furry" then return end
                local progress = math.min((CurTime() - transition_start)/transition_time,1)
                local cc = table.Copy(pnv_color_1)
                for k,v in pairs(cc) do
                    cc[k] = v * progress
                end
                DrawColorModify(cc)
                DrawBloom(0.1*progress,1*progress,2*progress,2*progress,1*progress,0.4*progress,1,1,1)
                if progress >= 1 then transitioning = false end
            end)
        else
            transitioning = false
            surface.PlaySound("items/nvg_off.wav")
            hook.Remove("RenderScreenspaceEffects","PNV_ColorCorrectionFur")
        end
    end

    hook.Add("RenderScreenspaceEffects","PNV_ColorCorrectionFur",function()
        local ply = LocalPlayer()
        if ply.PlayerClassName ~= "furry" then return end
        if pnv_enabled then
            local cc = pnv_color_1
            DrawColorModify(cc)
            DrawBloom(0.1,0.5,2,2,1,0.4,1,1,1)
        end
    end)

    hook.Add("PreDrawHalos","PNV_LightFur",function()
        local ply = LocalPlayer()
        if ply.PlayerClassName ~= "furry" then return end
        if pnv_enabled then
            if not IsValid(pnv_light) then
                pnv_light = ProjectedTexture()
                pnv_light:SetTexture("effects/flashlight001")
                pnv_light:SetBrightness(2)
                pnv_light:SetEnableShadows(false)
                pnv_light:SetConstantAttenuation(0.02)
                pnv_light:SetNearZ(12)
                pnv_light:SetFOV(70)
            end
            pnv_light:SetPos(ply:EyePos())
            pnv_light:SetAngles(ply:EyeAngles())
            pnv_light:Update()
        elseif IsValid(pnv_light) then
            pnv_light:Remove()
            pnv_light = nil
        end
    end)

    hook.Add("Think","PNV_ThinkFur",function()
        local ply = LocalPlayer()
        if ply:Alive() and ply.PlayerClassName == "furry" then
            if input.IsKeyDown(KEY_F) and not gui.IsGameUIVisible() and not IsValid(vgui.GetKeyboardFocus()) and (CurTime() > next_toggle_time) then
                togglePNV()
                next_toggle_time = CurTime() + toggle_cooldown
            end
        end
        if not ply:Alive() and pnv_enabled then togglePNV() end
        if ply.PlayerClassName ~= "furry" and pnv_enabled then togglePNV() end

        if pnv_enabled and IsValid(pnv_light) then
            pnv_light:SetPos(ply:EyePos())
            pnv_light:SetAngles(ply:EyeAngles())
            pnv_light:Update()
        end
    end)
end