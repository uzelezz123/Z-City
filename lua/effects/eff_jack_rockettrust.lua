function EFFECT:Init(data)
	local Pos, Dir, Scl = data:GetOrigin(), data:GetNormal(), data:GetScale()
	local emitter = ParticleEmitter(Pos)

	if emitter then
		for i = 1, 10 do
			local ParticlePos = Pos + Dir * math.random(-50, 500)
			local particle = emitter:Add("mats_jack_gmod_sprites/flamelet" .. math.random(1, 5), ParticlePos)
			particle:SetVelocity(Dir * math.random(500, 1500))
			particle:SetAirResistance(100)
			particle:SetGravity(Vector(0, 0, math.random(10, 100)))
			particle:SetDieTime(math.Rand(.15, .3))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			local Size = math.random(20, 40) * Scl
			particle:SetStartSize(Size / 10)
			particle:SetEndSize(Size)
			particle:SetRoll(math.Rand(-2, 2))
			particle:SetRollDelta(math.Rand(-2, 2))
			particle:SetColor(255, 255, 255)
			particle:SetLighting(false)
			particle:SetCollide(true)
		end

		for i = 1, 10 do
			local ParticlePos = Pos + Dir * math.random(-50, 200)
			local particle = emitter:Add("particle/smokestack", ParticlePos)
			particle:SetVelocity(Dir * math.random(200, 200))
			particle:SetAirResistance(100)
			particle:SetGravity(Vector(0, 0, math.random(10, 100)))
			particle:SetDieTime(math.Rand(10, 20))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			local Size = math.random(40, 80) * Scl
			particle:SetStartSize(Size / 20)
			particle:SetEndSize(Size)
			particle:SetRoll(math.Rand(-2, 2))
			particle:SetRollDelta(math.Rand(-2, 2))
			particle:SetColor(255, 255, 255)
			particle:SetLighting(true)
			particle:SetCollide(true)
		end
	end

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
--