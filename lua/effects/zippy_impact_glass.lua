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
        
        smoke:SetStartAlpha(math.Rand(12, 25))
        smoke:SetEndAlpha(0)
        smoke:SetColor(150,150,175)
        --smoke:SetLighting(true)
        smoke:SetGravity(Vector(0,0,-math.Rand(33, 66)))
        smoke:SetRollDelta(math.random(0, 0.5*math.pi))
        smoke:SetAirResistance(175)

        smoke:SetStartSize(5*intensity)
        smoke:SetDieTime(math.Rand(0.75, 1.5)*intensity)
        smoke:SetEndSize(math.Rand(15, 30)*intensity)
        smoke:SetVelocity((normal*math.Rand(40, 200)+VectorRand()*50)*intensity)
    end

    for i = 1,15*intensity do
        local shard = emitter:Add("effects/fleck_glass" .. math.random(1, 3), pos+normal*8)

        shard:SetStartAlpha(255)
        shard:SetEndAlpha(0)
        shard:SetCollide(true)
        shard:SetBounce(math.Rand(0,1))
        shard:SetColor(255,255,255)
        --shard:SetLighting(true)
        shard:SetGravity(Vector(0,0,-600))
        shard:SetRollDelta(math.random(0, 0.5*math.pi))

        local size = math.Rand(0.5, 2)
        shard:SetEndSize(size)
        shard:SetStartSize(size)

        shard:SetDieTime(math.Rand(0.5, 1)*intensity)
        shard:SetVelocity((normal*math.Rand(40, 200)+VectorRand()*50)*intensity*0.75)
    end

    emitter:Finish()
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EFFECT:Think() end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EFFECT:Render() end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------