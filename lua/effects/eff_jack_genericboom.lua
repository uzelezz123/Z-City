local ShockWave = Material("sprites/mat_jack_shockwave_white")
local Refract = Material("sprites/mat_jack_shockwave")
local Wake = Material("effects/splashwake1")
local Shit = Material("sprites/mat_jack_ignorezsprite")

function EFFECT:Init(data)
	local vOffset = data:GetOrigin()
	local Scayul = data:GetScale()
	self.Scale = Scayul
	self.Position = vOffset
	self.Pos = vOffset
	self.Scayul = Scayul
	self.Normal = Vector(0, 0, 1)
	self.Siyuz = 1
	self.DieTime = CurTime() + .1
	self.Opacity = 1
	self.TimeToDie = CurTime() + 0.015 * self.Scale
	--local Spl = EffectData()
	--Spl:SetOrigin(vOffset)
	--Spl:SetScale(1)
	--util.Effect("Explosion", Spl, true, true)

	if self:WaterLevel() == 3 then
		self.Underwater = true
		self.DieTime = CurTime() + 2.5
		self.TimeToDie = CurTime() + .65 * self.Scale
		self.Siyuz = 5000 * self.Scale
		local Splach = EffectData()
		Splach:SetOrigin(vOffset)
		Splach:SetNormal(Vector(0, 0, 1))
		Splach:SetScale(100)
		util.Effect("WaterSplash", Splach)
		local emitter = ParticleEmitter(vOffset)

		for i = 0, 400 do
			local Sprite
			local Rand = math.random(1, 3)

			if Rand == 1 then
				Sprite = "effects/splash1"
			elseif Rand == 2 then
				Sprite = "effects/splash2"
			elseif Rand == 3 then
				Sprite = "effects/splash4"
			end

			local Vec = Vector(math.Rand(-80, 80), math.Rand(-80, 80), 0) * Scayul
			local Dist = Vec:Length()
			local particle = emitter:Add(Sprite, vOffset + Vec)
			particle:SetVelocity(VectorRand() * math.Rand(.5, 2) * Dist ^ .5 * Scayul + Vector(0, 0, math.Rand(1000, 10000)) * Scayul / Dist ^ .5)
			particle:SetCollide(false)
			particle:SetLighting(false)
			particle:SetBounce(.01)
			particle:SetGravity(Vector(0, 0, -1800))
			particle:SetAirResistance(10)
			particle:SetDieTime(math.Rand(.3, 1.3) * Scayul)
			particle:SetStartAlpha(math.Rand(150, 255))
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(.1, 60) * Scayul)
			particle:SetEndSize(math.Rand(.1, 40) * Scayul)
			particle:SetRoll(math.Rand(180, 480))
			particle:SetRollDelta(math.Rand(-1, 1) * 6)
			particle:SetColor(255, 255, 255)
		end

		for i = 0, 300 do
			local Sprite
			local Rand = math.random(1, 3)

			if Rand == 1 then
				Sprite = "effects/splash1"
			elseif Rand == 2 then
				Sprite = "effects/splash2"
			elseif Rand == 3 then
				Sprite = "effects/splash4"
			end

			local Vec = Vector(math.Rand(-80, 80), math.Rand(-80, 80), 0) * Scayul
			local Dist = Vec:Length()
			local particle = emitter:Add(Sprite, vOffset + Vec)
			particle:SetVelocity((VectorRand() * math.Rand(.5, 2) * Dist ^ .5 * Scayul + Vector(0, 0, math.Rand(1000, 10000)) * Scayul / Dist ^ .5) * 2)
			particle:SetCollide(false)
			particle:SetLighting(false)
			particle:SetBounce(.01)
			particle:SetGravity(Vector(0, 0, -1800))
			particle:SetAirResistance(10)
			particle:SetDieTime(math.Rand(.3, 1.3) * Scayul)
			particle:SetStartAlpha(math.Rand(200, 255))
			particle:SetEndAlpha(0)
			particle:SetStartSize(10)
			particle:SetEndSize(10)
			particle:SetRoll(math.Rand(180, 480))
			particle:SetRollDelta(math.Rand(-1, 1) * 6)
			particle:SetColor(255, 255, 255)
		end

		emitter:Finish()

		return
	end

	local emitter = ParticleEmitter(vOffset)
	local particle = emitter:Add("effects/fire_cloud1", vOffset)
	particle:SetVelocity(math.Rand(40, 60) * VectorRand() * Scayul)
	particle:SetAirResistance(20)
	particle:SetDieTime(0.04 * Scayul)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(10 * Scayul)
	particle:SetEndSize(300 * Scayul)
	particle:SetRoll(math.Rand(180, 480))
	particle:SetRollDelta(math.Rand(-1, 1) * 6)
	particle:SetColor(255, 255, 255)

	for i = 0, 10 * Scayul do
		local sprite = "sprites/flamelet" .. math.random(1, 3)
		local particle = emitter:Add(sprite, vOffset)
		particle:SetVelocity(math.Rand(30, 50) * VectorRand() * Scayul * i ^ 1.2)
		particle:SetAirResistance(2000)
		particle:SetGravity(Vector(0, 0, math.Rand(25, 100)))
		particle:SetLifeTime(0)
		particle:SetDieTime(math.Rand(0.001, 0.25))
		particle:SetStartAlpha(math.Rand(200, 255))
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(5, 70) * Scayul)
		particle:SetEndSize(math.Rand(7, 80) * Scayul)
		particle:SetRoll(0)
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetLighting(false)
		local darg = 255
		particle:SetColor(darg - 20, darg, darg)
	end

	for i = 0, 3 * Scayul ^ 2 do
		local Debris = emitter:Add("effects/fleck_cement" .. math.random(1, 2), vOffset)

		if Debris then
			Debris:SetVelocity(VectorRand() * math.Rand(250, 1500) * Scayul ^ 0.5)
			Debris:SetDieTime(3 * math.random(0.6, 1))
			Debris:SetStartAlpha(255)
			Debris:SetEndAlpha(0)
			Debris:SetStartSize(math.random(1, 5) * Scayul ^ 0.5)
			Debris:SetRoll(math.Rand(0, 360))
			Debris:SetRollDelta(math.Rand(-5, 5))
			Debris:SetAirResistance(1)
			Debris:SetColor(105, 100, 90)
			Debris:SetGravity(Vector(0, 0, -700))
			Debris:SetCollide(true)
			Debris:SetBounce(1)
			Debris:SetLighting(true)
		end
	end

	for i = 0, 100 * Scayul do
		local Pos = data:GetOrigin() + Vector(math.Rand(-1, 1), math.Rand(-1, 1), math.Rand(-1, 1))
		local particle = emitter:Add("sprites/mat_jack_nicespark", Pos)

		if particle then
			particle:SetVelocity(VectorRand() * math.Rand(1, 2) * Scayul * i ^ 1.2)
			particle:SetLifeTime(0)
			particle:SetDieTime(math.Rand(0.3, 2))
			local herpdemutterfickendenderp = math.Rand(200, 255)
			particle:SetColor(255, herpdemutterfickendenderp, herpdemutterfickendenderp - 50)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(2, 5) * Scayul)
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(-360, 360))
			particle:SetRollDelta(math.Rand(-0.21, 0.21))
			particle:SetAirResistance(0)
			particle:SetGravity(Vector(math.Rand(0, 0), math.Rand(0, 0), math.Rand(0, -1000)))
			particle:SetCollide(true)
			particle:SetBounce(0.9)
		end
	end

	local particle = emitter:Add("sprites/heatwave", vOffset)
	particle:SetVelocity(Vector(0, 0, 0))
	particle:SetAirResistance(200)
	particle:SetGravity(VectorRand() * math.Rand(0, 200))
	particle:SetDieTime(math.Rand(0.2, 0.3) * Scayul)
	particle:SetStartAlpha(40)
	particle:SetEndAlpha(0)
	particle:SetStartSize(150 * Scayul)
	particle:SetEndSize(0 * Scayul)
	particle:SetRoll(math.Rand(0, 10))
	particle:SetRollDelta(6000)
	emitter:Finish()

	timer.Simple(0.025, function()
		local Emitter = ParticleEmitter(vOffset)

		for i = 0, 75 * Scayul do
			local sprite
			local chance = math.random(1, 6)

			if chance == 1 then
				sprite = "particle/smokestack"
			elseif chance == 2 then
				sprite = "particles/smokey"
			elseif chance == 3 then
				sprite = "particle/particle_smokegrenade"
			elseif chance == 4 then
				sprite = "sprites/mat_jack_smoke1"
			elseif chance == 5 then
				sprite = "sprites/mat_jack_smoke2"
			elseif chance == 6 then
				sprite = "sprites/mat_jack_smoke3"
			end

			local particle = Emitter:Add(sprite, vOffset)

			if particle then
				particle:SetVelocity(math.Rand(3, 4) * VectorRand() * Scayul * i ^ 1.2)
				particle:SetAirResistance(1000)
				particle:SetGravity(VectorRand() * math.Rand(0, 2000))
				particle:SetDieTime(math.Rand(2, 15))
				particle:SetStartAlpha(math.Rand(50, 200))
				particle:SetEndAlpha(0)
				particle:SetStartSize(math.Rand(5, 45) * Scayul)
				particle:SetEndSize(math.Rand(10, 150) * Scayul)
				particle:SetRoll(math.Rand(-3, 3))
				particle:SetRollDelta(math.Rand(-2, 2))
				particle:SetLighting(true)
				local darg = math.Rand(200, 255)
				particle:SetColor(darg, darg, darg)
				particle:SetCollide(false)
			end
		end

		Emitter:Finish()
	end)

	local dlight = DynamicLight(self:EntIndex())

	if dlight then
		dlight.Pos = vOffset
		dlight.r = 255
		dlight.g = 200
		dlight.b = 175
		dlight.Brightness = 4 * Scayul ^ 0.5
		dlight.Size = 250 * Scayul ^ 0.5
		dlight.Decay = 1000
		dlight.DieTime = CurTime() + 0.1
		dlight.Style = 0
	end
end

function EFFECT:Think()
	if self.DieTime > CurTime() then
		self.Siyuz = self.Siyuz + 200
		self:NextThink(CurTime() + .01)

		return true
	else
		return false
	end
end

function EFFECT:Render()
	local TimeLeftFraction = (self.DieTime - CurTime()) / .25
	local Opacity = math.Clamp(TimeLeftFraction * 50 * self.Scayul, 0, 255)

	if self.Underwater then
		render.SetMaterial(Wake)
		render.DrawQuadEasy(self.Pos, self.Normal, self.Siyuz / 25, self.Siyuz / 25, Color(255, 255, 255, Opacity))
		render.DrawQuadEasy(self.Pos + self.Normal * 30, self.Normal, self.Siyuz / 25, self.Siyuz / 25, Color(255, 255, 255, Opacity))

		return
	end

	render.SetMaterial(ShockWave)
	render.DrawQuadEasy(self.Pos, self.Normal, self.Siyuz, self.Siyuz, Color(255, 255, 255, Opacity))
	render.DrawSprite(self.Pos, self.Siyuz, self.Siyuz, Color(255, 255, 255, Opacity))
	local TimeLeft = self.TimeToDie - CurTime()
	local TimeFraction = math.Clamp(TimeLeft / (0.015 * self.Scale), 0, 10)
	local ReverseFraction = 1 - TimeFraction
	render.SetMaterial(Shit)
	render.DrawSprite(self.Position, 2000 * TimeFraction * self.Scale, 2000 * TimeFraction * self.Scale, Color(255, 255, 255, 255 * TimeFraction))
end