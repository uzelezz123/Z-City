function EFFECT:Init(data)
	local SelfPos = data:GetOrigin()
	local Radius = data:GetRadius()
	if self:WaterLevel() >= 2 then return end
	local dlight = DynamicLight(self:EntIndex())
	if dlight and math.random(5) > 3 then
		dlight.Pos = SelfPos
		dlight.r = 245
		dlight.g = 125
		dlight.b = 15
		dlight.Brightness = 4
		dlight.Size = Radius * 1.5
		dlight.Decay = 0
		dlight.DieTime = CurTime() + .5
		dlight.Style = 0
	end

	local Emitter = ParticleEmitter(SelfPos)
	for i = 0, Radius / 10 do
		local sprite = "sprites/flamelet" .. math.random(1, 5)
		local particle = Emitter:Add(sprite, SelfPos)
		if particle then
			particle:SetVelocity(10000 * VectorRand())
			particle:SetAirResistance(0)
			particle:SetGravity(Vector(0, 0, math.random(200, 300)))
			particle:SetDieTime(.15)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)
			particle:SetStartSize(1)
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(-3, 3))
			particle:SetRollDelta(math.Rand(-2, 2))
			particle:SetLighting(false)
			local darg = math.Rand(150, 255)
			particle:SetColor(darg, darg, darg)
			particle:SetCollide(true)
			particle:SetBounce(.01)
			particle:SetCollideCallback(function(part, hitpos, hitnormal)
				local Dist = (hitpos - SelfPos):Length()
				if Dist < Radius then
					local Vel = part:GetVelocity()
					Vel.x = 0
					Vel.y = 0
					part:SetVelocity(Vel)
					part:SetStartSize(50 + Dist / 3.5)
					part:SetStartAlpha(255)
					part:SetEndAlpha(255)
					part:SetLifeTime(.1)
					part:SetDieTime(math.Rand(.75, 1.5))
					part:SetPos(hitpos + hitnormal)
					if math.random(1, 25) == 5 then util.Decal("Scorch", hitpos + hitnormal, hitpos - hitnormal) end
				else
					part:SetLifeTime(0)
					part:SetDieTime(.01)
				end
			end)
		end
	end

	Emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
