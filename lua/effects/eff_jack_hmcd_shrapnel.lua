/*---------------------------------------------------------
	EFFECT:Init(data)
---------------------------------------------------------*/
local parts = {}

function EFFECT:Init(data)
	local vOffset = data:GetOrigin()
	
	local Scayul=data:GetScale()
	self.Scale=Scayul
	self.Position=vOffset
	
	self.Pos=vOffset
	self.Scayul=Scayul
	local Normal=data:GetNormal()
	self.Siyuz=1
	self.DieTime=CurTime()+.1
	self.Opacity=1
	self.TimeToDie=CurTime()+0.015*self.Scale
	
	if(self:WaterLevel()==3)then return end
	
	local Emitter=ParticleEmitter(vOffset)
	for i=0,400*Scayul do
		local sprite="sprites/mat_jack_nsmokethick"
		local particle = Emitter:Add(sprite,vOffset)
		if(particle)then
			particle:SetVelocity(5000*(vector_up + Vector(math.Rand(-5,5),math.Rand(-5,5),math.Rand(-2,1)))*(i / 1000*Scayul))
			particle:SetAirResistance(0)
			particle:SetGravity(VectorRand())
			particle:SetDieTime(.001*Scayul)
			particle:SetStartAlpha(1)
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(1, 20)*Scayul)
			particle:SetEndSize(math.Rand(20, 50)*Scayul)
			particle:SetRoll(math.Rand(-3,3))
			particle:SetRollDelta(math.Rand(-0.2,0.2))
			particle:SetLighting(true)
			local darg=math.Rand(150,255)
			particle:SetColor(darg,darg,darg)
			particle:SetCollide(true)
			particle:SetBounce(0.1)
			particle:SetCollideCallback(function(part,hitpos,hitnormal)
				part:SetStartAlpha(math.Rand(15,25))
				part:SetStartSize(math.Rand(20,40))
				part:SetLifeTime(0)
				part:SetDieTime(math.Rand(62,66.5))
				part:SetVelocity( VectorRand(-120,120) - hitnormal * 200 )
				part:SetBounce(0.5)
				part:SetEndSize(math.Rand(250, 260))
				part:SetGravity(-vector_up * 2.5)
				part:SetAirResistance(30)
				part:SetCollide(false)
				util.Decal("ExplosiveGunshot",hitpos+hitnormal,hitpos-hitnormal)
				part:SetCollideCallback(function(part) part:SetCollide(true) end)
				if math.random(1,3) == 3 then 
					part:SetDieTime(0.1)
				else
					parts[#parts + 1] = part
				end
			end)
		end
	end
	timer.Create("RemoveSHIT_shrapnel",100,1,function()
		for i = 0, #parts do
			if parts[i] and parts[i].SetDieTime then
				parts[i]:SetDieTime(0.1)
			end
		end
	end)
	Emitter:Finish()
end

hook.Add("PostCleanupMap","RemoveParticlesShrapnel",function()
	for i = 0, #parts do
		if parts[i] and parts[i].SetDieTime then
			parts[i]:SetDieTime(0.1)
		end
	end
end)
/*---------------------------------------------------------
	EFFECT:Think()
---------------------------------------------------------*/
function EFFECT:Think()
	return false
end
/*---------------------------------------------------------
	EFFECT:Render()
---------------------------------------------------------*/
function EFFECT:Render()
	--wat
end