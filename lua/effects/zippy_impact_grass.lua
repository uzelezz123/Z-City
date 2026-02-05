local smoke_mats = {}
for i = 1,9 do
    table.insert(smoke_mats, "particle/smokesprites_000" .. i)
end
for i = 10,16 do
    table.insert(smoke_mats, "particle/smokesprites_00" .. i)
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EFFECT:Init(data)
    local pos = data:GetStart()
    local normal = data:GetNormal()
    local intensity = data:GetMagnitude()

    local emitter = ParticleEmitter(pos)

    for i = 1,15*intensity do
        local smoke = emitter:Add(smoke_mats[math.random(#smoke_mats)], pos)
        
        smoke:SetStartAlpha(math.Rand(40, 80))
        smoke:SetEndAlpha(0)
        smoke:SetColor(100,75,50)
        smoke:SetLighting(true)
        smoke:SetGravity(Vector(0,0,-math.Rand(75, 150)))
        smoke:SetRollDelta(math.random(0, 0.5*math.pi))
        smoke:SetAirResistance(175)

        smoke:SetStartSize(5*intensity)
        smoke:SetDieTime(math.Rand(0.5, 1)*intensity)
        smoke:SetEndSize(math.Rand(15, 30)*intensity)
        smoke:SetVelocity((normal*math.Rand(40, 200)+VectorRand()*50)*intensity)
    end

    for i = 1,8*intensity do
        local smoke = emitter:Add("particle/particle_debris_02", pos+normal*8)
        
        smoke:SetStartAlpha(255)
        smoke:SetEndAlpha(0)
        smoke:SetLighting(true)
        smoke:SetGravity(Vector(0,0,-math.Rand(300, 600)))
        smoke:SetRollDelta(math.random(0, 0.5*math.pi))
        smoke:SetAirResistance(175)

        smoke:SetStartSize(5*intensity)
        smoke:SetDieTime(math.Rand(0.5, 1)*intensity)
        smoke:SetEndSize(math.Rand(15, 30)*intensity)
        smoke:SetVelocity((normal*math.Rand(40, 200)+VectorRand()*100)*1.5*intensity)
    end

    emitter:Finish()
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EFFECT:Think() end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EFFECT:Render() end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------