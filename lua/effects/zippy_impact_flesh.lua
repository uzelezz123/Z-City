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
        
        smoke:SetStartAlpha(math.Rand(12, 35))
        smoke:SetEndAlpha(0)
        smoke:SetColor(75,25,25)
        --smoke:SetLighting(true)
        smoke:SetGravity(Vector(0,0,-math.Rand(33, 66)))
        smoke:SetRollDelta(math.random(0, 0.5*math.pi))
        smoke:SetAirResistance(175)

        smoke:SetStartSize(5*intensity/2)
        smoke:SetDieTime(math.Rand(0.75, 1.5)*intensity)
        smoke:SetEndSize(math.Rand(15, 30)*intensity)
        smoke:SetVelocity((normal*math.Rand(10, 20)+VectorRand()*50)*intensity)
    end

    for i = 1,5*intensity do
        local flesh = emitter:Add("effects/fleck_cement" .. math.random(1, 2), pos+normal*8)

        flesh:SetStartAlpha(255)
        flesh:SetEndAlpha(0)
        flesh:SetCollide(true)
        flesh:SetBounce(math.Rand(0,1))
        flesh:SetColor(150,50,50)
        --flesh:SetLighting(true)
        flesh:SetGravity(Vector(0,0,-600))
        flesh:SetRollDelta(math.random(math.pi, 2*math.pi))

        local size = math.Rand(0.5, 1)
        flesh:SetEndSize(size)
        flesh:SetStartSize(size)

        flesh:SetDieTime(math.Rand(0.5, 1)*intensity)
        flesh:SetVelocity((normal*math.Rand(40, 200)+VectorRand()*50)*intensity*1.25)
    end

    emitter:Finish()
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EFFECT:Think() end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EFFECT:Render() end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------