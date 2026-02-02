local ShockWave = Material("sprites/mat_jack_shockwave_white")
function EFFECT:Init(data)
	local vOffset = data:GetOrigin()
	local Scayul = data:GetScale()
	local Normal = data:GetNormal()
	self.Pos = vOffset
	self.Scayul = Scayul
	self.Normal = Normal or Vector(0, 0, 1)
	self.Siyuz = 1
	self.DieTime = CurTime() + .1
	self.Opacity = 1
	local Spl = EffectData()
	Spl:SetOrigin(vOffset)
	Spl:SetScale(1)
	--util.Effect("Explosion", Spl, true, true)

	local dlight = DynamicLight(self:EntIndex())
	if dlight then
		dlight.Pos = vOffset
		dlight.r = 255
		dlight.g = 200
		dlight.b = 100
		dlight.Brightness = 5
		dlight.Size = 25 * 1.5
		dlight.Decay = 0
		dlight.DieTime = CurTime() + .5
		dlight.Style = 0
	end

	if self:WaterLevel() == 3 then
		local Splach = EffectData()
		Splach:SetOrigin(vOffset)
		Splach:SetNormal(Vector(0, 0, 1))
		Splach:SetScale(Scayul * 200)
		util.Effect("WaterSplash", Splach)
		return
	end

	local emitter = ParticleEmitter(vOffset)
	local particle = emitter:Add("effects/fire_cloud1", vOffset)
	particle:SetVelocity(math.Rand(40, 60) * VectorRand() * Scayul)
	particle:SetAirResistance(20)
	particle:SetDieTime(0.035 * Scayul)
	particle:SetStartAlpha(150)
	particle:SetEndAlpha(0)
	particle:SetStartSize(10 * Scayul)
	particle:SetEndSize(300 * Scayul)
	particle:SetRoll(math.Rand(180, 480))
	particle:SetRollDelta(math.Rand(-1, 1) * 6)
	particle:SetColor(255, 255, 255)
	for i = 0, 1 * Scayul do
		local sprite = "sprites/flamelet" .. math.random(1, 3)
		local particle = emitter:Add(sprite, vOffset)
		particle:SetVelocity(math.Rand(900, 1300) * VectorRand() * Scayul)
		particle:SetAirResistance(800)
		particle:SetGravity(Vector(0, 0, math.Rand(25, 100)))
		particle:SetDieTime(math.Rand(0.01, 0.05))
		particle:SetStartAlpha(math.Rand(200, 255))
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(50, 70) * Scayul)
		particle:SetEndSize(math.Rand(70, 100) * Scayul)
		particle:SetRoll(0)
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetLighting(true)
		local darg = 255
		particle:SetColor(darg - 20, darg, darg)
	end

	for i = 0, 5 * Scayul ^ 2 do
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

	for i = 0, 150 * Scayul do
		local Pos = data:GetOrigin() + Vector(math.Rand(-1, 1), math.Rand(-1, 1), math.Rand(-1, 1))
		local particle = emitter:Add("sprites/mat_jack_nicespark", Pos)
		if particle then
			particle:SetVelocity(VectorRand() * math.Rand(10, 3000) * Scayul)
			particle:SetLifeTime(0)
			particle:SetDieTime(math.Rand(0.6, 1.2))
			local herpdemutterfickendenderp = math.Rand(200, 255)
			particle:SetColor(255, herpdemutterfickendenderp, herpdemutterfickendenderp - 50)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(1, 2) * Scayul)
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(-360, 360))
			particle:SetRollDelta(math.Rand(-0.21, 0.21))
			particle:SetAirResistance(200)
			particle:SetGravity(Vector(0, 0, -1000))
			particle:SetCollide(true)
			particle:SetBounce(0.9)
		end
	end

	local particle = emitter:Add("sprites/heatwave", vOffset)
	particle:SetVelocity(Vector(0, 0, 0))
	particle:SetAirResistance(200)
	particle:SetGravity(VectorRand() * math.Rand(0, 200))
	particle:SetDieTime(math.Rand(0.02, 0.04) * Scayul)
	particle:SetStartAlpha(40)
	particle:SetEndAlpha(0)
	particle:SetStartSize(150 * Scayul)
	particle:SetEndSize(150 * Scayul)
	particle:SetRoll(math.Rand(0, 10))
	particle:SetRollDelta(6000)
	emitter:Finish()
	local Emitter = ParticleEmitter(vOffset)
	for i = 0, 200 * Scayul do
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
		particle:SetVelocity(Vector(math.Rand(-320, 320) * i, math.Rand(-320, 320) * i, math.Rand(-1000, 1000) / i) * Scayul)
		particle:SetAirResistance(8000)
		particle:SetGravity(VectorRand() * math.Rand(0, 4000))
		particle:SetDieTime(math.Rand(4, 7))
		particle:SetStartAlpha(math.Rand(50, 255))
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(10, 20) * Scayul * 3)
		particle:SetEndSize(math.Rand(15, 25) * Scayul * 6)
		particle:SetRoll(math.Rand(-3, 3))
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetLighting(true)
		local darg = math.Rand(150, 200)
		particle:SetColor(darg, darg, darg)
		particle:SetCollide(true)
	end

	for i = 0, 200 * Scayul do
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
		particle:SetVelocity(Vector(math.Rand(-300000, 300000) / i, math.Rand(-300000, 300000) / i, math.Rand(-200 * i, 200 * i)) * Scayul)
		particle:SetAirResistance(8000)
		particle:SetGravity(Vector(math.Rand(-1000, 1000), math.Rand(-1000, 1000), math.Rand(0, -6000)))
		particle:SetDieTime(math.Rand(4, 7))
		particle:SetStartAlpha(math.Rand(50, 255))
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(10, 20) * Scayul)
		particle:SetEndSize(math.Rand(15, 25) * Scayul)
		particle:SetRoll(math.Rand(-3, 3))
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetLighting(true)
		local darg = math.Rand(150, 200)
		particle:SetColor(darg, darg, darg)
		particle:SetCollide(true)
	end

	--[[for i=0,200*Scayul do
		local sprite
		local chance=math.random(1,6)
		if(chance==1)then
			sprite="particle/smokestack"
		elseif(chance==2)then
			sprite="particles/smokey"
		elseif(chance==3)then
			sprite="particle/particle_smokegrenade"
		elseif(chance==4)then
			sprite="sprites/mat_jack_smoke1"
		elseif(chance==5)then
			sprite="sprites/mat_jack_smoke2"
		elseif(chance==6)then
			sprite="sprites/mat_jack_smoke3"
		end
		local particle=emitter:Add(sprite, vOffset)
		particle:SetVelocity(VectorRand()*10e10)
		particle:SetAirResistance(8000)
		particle:SetGravity(Vector(math.Rand(-500,500),math.Rand(-500,500),math.Rand(0,-3000)))
		particle:SetDieTime(math.Rand(4,7))
		particle:SetStartAlpha(math.Rand(50,255))
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(10, 20)*Scayul)
		particle:SetEndSize(math.Rand(15, 25)*Scayul)
		particle:SetRoll(math.Rand(-3,3))
		particle:SetRollDelta(math.Rand(-3,3))
		particle:SetLighting(true)
		local darg=math.Rand(150,200)
		particle:SetColor(darg,darg,darg)
		particle:SetCollide(true)
	end--]]
	Emitter:Finish()
	local dlight = DynamicLight(self:EntIndex())
	if dlight then
		dlight.Pos = vOffset
		dlight.r = 255
		dlight.g = 200
		dlight.b = 175
		dlight.Brightness = 2 * Scayul ^ 0.5
		dlight.Size = 250 * Scayul ^ 0.5
		dlight.Decay = 1000
		dlight.DieTime = CurTime() + 0.1
		dlight.Style = 0
	end
end

function EFFECT:Think()
	if self.DieTime > CurTime() then
		self.Siyuz = self.Siyuz + 500
		self:NextThink(CurTime() + .01)
		return true
	else
		return false
	end
end

function EFFECT:Render()
	local TimeLeftFraction = (self.DieTime - CurTime()) / .25
	local Opacity = math.Clamp(TimeLeftFraction * 60 * self.Scayul, 0, 255)
	render.SetMaterial(ShockWave)
	render.DrawQuadEasy(self.Pos, self.Normal, self.Siyuz, self.Siyuz, Color(255, 255, 255, Opacity))
	render.DrawSprite(self.Pos, self.Siyuz, self.Siyuz, Color(255, 255, 255, Opacity))
end