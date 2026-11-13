if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_traitor_ied"
SWEP.PrintName = "Shitty IED"
SWEP.Instructions = "A poorly made C4 explosive stuffed in a cardboard box. The detonator is a cracked old nokia phone and most of the charge is just filler. It's less than half as strong as a proper IED, but it's cheap. LMB to place in an object, RMB to simply place the bomb. LMB to activate it after it's put."
SWEP.Category = "Weapons - Explosive"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.BlastDis = 12 * 0.43
SWEP.BlastDamage = 350 * 0.43

if CLIENT then
	local countdowns = {}
	local hudLerp = 0
	local hudCrosshairColor = Color(255, 255, 255, 255)

	net.Receive("shitied_countdown", function()
		local bomb = net.ReadEntity()
		local delay = net.ReadFloat()
		local activator = net.ReadEntity()

		if not IsValid(bomb) then return end

		local old = countdowns[bomb]
		if old and old.channel then
			old.channel:Stop()
		end

		local entry = { endTime = CurTime() + delay, activator = activator }
		countdowns[bomb] = entry

		sound.PlayFile("sound/shitiedtrigger.mp3", "3d mono", function(channel, err)
			if not IsValid(channel) then return end
			if not IsValid(bomb) or CurTime() > entry.endTime then
				channel:Stop()
				return
			end

			channel:SetPos(bomb:GetPos())
			channel:Set3DFadeDistance(60, 900)
			channel:SetVolume(0.2)
			channel:Play()

			entry.channel = channel
		end)
	end)

	hook.Add("Think", "shitied_countdown_think", function()
		local now = CurTime()

		for bomb, entry in pairs(countdowns) do
			if not IsValid(bomb) or now > entry.endTime + 0.1 then
				if entry.channel then entry.channel:Stop() end
				countdowns[bomb] = nil
			elseif entry.channel then
				entry.channel:SetPos(bomb:GetPos())
			end
		end
	end)

	local function GetCountdownEnd()
		local now = CurTime()
		local soonestEnd

		for bomb, entry in pairs(countdowns) do
			if entry.activator == LocalPlayer() and IsValid(bomb) and now <= entry.endTime then
				if not soonestEnd or entry.endTime < soonestEnd then
					soonestEnd = entry.endTime
				end
			end
		end

		return soonestEnd, now
	end

	function SWEP:DrawHUD()
		if GetViewEntity() ~= LocalPlayer() then return end
		if LocalPlayer():InVehicle() then return end

		local soonestEnd, now = GetCountdownEnd()

		if not self:GetPlanted() or not soonestEnd then
			local baseIED = weapons.Get("weapon_traitor_ied")
			if baseIED and baseIED.DrawHUD then
				baseIED.DrawHUD(self)
			end
			return
		end

		local tr = self:GetEyeTrace()
		if not tr then return end

		local toScreen = tr.HitPos:ToScreen()
		local Size = math.max(math.min(1 - (tr and tr.Fraction or 0), 1), 0.1)
		local x, y = toScreen.x, toScreen.y

		hudLerp = Lerp(0.1, hudLerp, tr.Hit and 1 or 0)
		hudCrosshairColor.a = 255 * Size * hudLerp
		surface.SetDrawColor(hudCrosshairColor)
		surface.DrawRect(x - 25 * hudLerp * 0.1, y - 2.5, 50 * hudLerp * 0.1, 5)
		surface.DrawRect(x - 2.5, y - 25 * hudLerp * 0.1, 5, 50 * hudLerp * 0.1)

		local text = "TIME UNTIL DETONATION: " .. tostring(math.ceil(soonestEnd - now))
		local xrand, yrand = math.random(-1, 1), math.random(-1, 1)
		draw.SimpleText(text, "HomigradFontMedium", toScreen.x + 2 + xrand, toScreen.y + 26 + yrand, color_black, TEXT_ALIGN_CENTER)
		draw.SimpleText(text, "HomigradFontMedium", toScreen.x + xrand, toScreen.y + 25 + yrand, color_red, TEXT_ALIGN_CENTER)
	end
end

if SERVER then
	util.AddNetworkString("shitied_countdown")

	SWEP.nextattackhuy = 0
	SWEP.PlantedOnSelf = false

	local beatInterval = 60 / 177

	local function PulseBomb(bomb)
		if not IsValid(bomb) or bomb:IsPlayer() then return end

		local phys = bomb:GetPhysicsObject()
		if not IsValid(phys) then return end

		phys:Wake()

		local vel = phys:GetVelocity()
		if vel:LengthSqr() > 2500 then return end

		local mins = bomb:OBBMins()
		local tr = util.TraceLine({
			start = bomb:GetPos(),
			endpos = bomb:GetPos() + Vector(0, 0, mins.z - 4),
			filter = bomb,
		})

		if not tr.Hit then return end

		phys:EnableMotion(true)
		phys:SetVelocity(Vector(vel.x, vel.y, math.Rand(70, 90)))
		phys:SetAngleVelocity(Vector(math.Rand(-60, 60), math.Rand(-60, 60), math.Rand(-60, 60)))
	end

	local function StartDetonation(self)
		local owner = self:GetOwner()
		local bomb = self.PlantedOnSelf and owner or self.HaveTheBomb
		if not IsValid(bomb) then return end

		local dist = IsValid(owner) and owner:GetPos():Distance(bomb:GetPos()) or 0
		local delay = math.Clamp(dist / 200, 1, 10)

		self.DetonationPending = true

		net.Start("shitied_countdown")
			net.WriteEntity(bomb)
			net.WriteFloat(delay)
			net.WriteEntity(IsValid(owner) and owner or NULL)
		net.Broadcast()

		local timerName = "shitied_beat_" .. bomb:EntIndex()

		timer.Create(timerName, beatInterval, 0, function()
			if not IsValid(bomb) then
				timer.Remove(timerName)
				return
			end

			PulseBomb(bomb)
		end)

		timer.Simple(delay, function()
			timer.Remove(timerName)

			if not IsValid(self) or self.KABOOM then return end

			self.DetonationPending = false
			self.nextattackhuy = 0

			local baseIED = weapons.Get("weapon_traitor_ied")
			if baseIED and baseIED.AttackHuy then
				baseIED.AttackHuy(self)
			end
		end)
	end

	function SWEP:AttackHuy()
		if not (self.Planted or self.HaveTheBomb or self.PlantedOnSelf) then
			local Owner = self:GetOwner()
			local Tr = self:GetEyeTrace()

			if Tr and IsValid(Tr.Entity) and IsValid(Tr.Entity:GetPhysicsObject()) and Tr.Entity:GetPhysicsObject():GetMass() < 500 then
				local min, max = Tr.Entity:GetModelBounds()
				local minmaxs = (max - min)
				local size = minmaxs[1] + minmaxs[2] + minmaxs[3]
				if size <= 15 then return end

				local bomb = Tr.Entity

				self.Planted = true
				self.HaveTheBomb = bomb
				bomb.bombowner = self

				self.WorldModel = "models/saraphines/insurgency explosives/ied/insurgency_ied_phone.mdl"

				net.Start("ied_have_the_bomb")
				net.WriteEntity(self)
				net.Broadcast()

				Owner:EmitSound("snd_jack_hmcd_bombrig.wav", 50, 100, 1, CHAN_AUTO)
				self:SetNextPrimaryFire(CurTime() + 2)
				self.nextattackhuy = CurTime() + 2
				self:SetPlanted(true)
				return
			elseif hg.GetCurrentCharacter(Owner):IsRagdoll() then
				self:SecondaryAttack(true)
				return
			end
		end

		if (self.nextattackhuy or 0) <= CurTime() and (self.Planted or self.HaveTheBomb or self.PlantedOnSelf) and not self.KABOOM then
			if self.DetonationPending then return end
			StartDetonation(self)
		end
	end
end
