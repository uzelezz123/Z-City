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

    for i = 1,8*intensity do
        local smoke = emitter:Add(smoke_mats[math.random(#smoke_mats)], pos)
        
        smoke:SetStartAlpha(math.Rand(33, 66))
        smoke:SetEndAlpha(0)
        smoke:SetColor(150,150,175)
        smoke:SetLighting(true)
        smoke:SetGravity(Vector(0,0,-math.Rand(33, 66)))
        smoke:SetRollDelta(math.random(0, 0.5*math.pi))
        smoke:SetAirResistance(175)

        smoke:SetStartSize(5*intensity)
        smoke:SetDieTime(math.Rand(0.75, 1.5)*intensity)
        smoke:SetEndSize(math.Rand(15, 30)*intensity)
        smoke:SetVelocity((normal*math.Rand(40, 200)+VectorRand()*50)*intensity)
    end

    for i = 1,10*intensity do
        local splinter = emitter:Add("effects/fleck_wood" .. math.random(1, 2), pos+normal*8)

        splinter:SetStartAlpha(255)
        splinter:SetEndAlpha(0)
        splinter:SetCollide(true)
        splinter:SetBounce(math.Rand(0,1))
        splinter:SetColor(255,255,255)
        splinter:SetLighting(true)
        splinter:SetGravity(Vector(0,0,-600))
        splinter:SetRollDelta(math.random(math.pi, 2*math.pi))

        local size = math.Rand(1, 2)
        splinter:SetEndSize(size)
        splinter:SetStartSize(size)

        splinter:SetDieTime(math.Rand(0.5, 1)*intensity)
        splinter:SetVelocity((normal*math.Rand(40, 200)+VectorRand()*125)*intensity*0.66)
    end

    emitter:Finish()
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EFFECT:Think() end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EFFECT:Render() end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------