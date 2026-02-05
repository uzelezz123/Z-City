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

    for i = 1,4*intensity do
        local smoke = emitter:Add(smoke_mats[math.random(#smoke_mats)], pos)
        
        smoke:SetStartAlpha(math.Rand(15, 25))
        smoke:SetEndAlpha(0)
        smoke:SetColor(255,255,255)
        --smoke:SetLighting(true)
        smoke:SetGravity(Vector(0,0,-math.Rand(33, 66)))
        smoke:SetRollDelta(math.random(0, 0.5*math.pi))
        smoke:SetAirResistance(175)

        smoke:SetStartSize(5*intensity)
        smoke:SetDieTime(math.Rand(0.5, 1)*intensity)
        smoke:SetEndSize(math.Rand(15, 30)*intensity)
        smoke:SetVelocity((normal*math.Rand(40, 200)+VectorRand()*50)*intensity)
    end

    for i = 1,15*intensity do
        local spark = emitter:Add("effects/spark", pos+normal*8)
        
        spark:SetStartAlpha(255)
        spark:SetEndAlpha(0)
        spark:SetCollide(true)
        spark:SetBounce(math.Rand(0,1))
        spark:SetColor(200,150,100)
        --spark:SetLighting(true)
        spark:SetGravity(Vector(0,0,-600))
        spark:SetEndLength(0)
        --spark:SetRollDelta(math.random(0, 0.5*math.pi))

        local size = math.Rand(0.5, 1)*intensity
        spark:SetEndSize(size)
        spark:SetStartSize(size)

        spark:SetStartLength(math.Rand(5,10)*intensity)
        spark:SetDieTime(math.Rand(0, 0.33)*intensity)
        spark:SetVelocity((normal*math.Rand(150, 300)+VectorRand()*200)*intensity*0.5)
    end

    local flash = emitter:Add("effects/yellowflare",pos)
    flash:SetPos(pos+normal*15)
    flash:SetStartAlpha(math.Rand(100, 200))
    flash:SetEndAlpha(0)
    flash:SetColor(255,255,255)
    flash:SetEndSize(0)
    flash:SetDieTime(0.075)

    flash:SetStartSize(math.random(66, 75)*intensity)

    local dlight = DynamicLight( LocalPlayer():EntIndex() )
	if dlight then
		dlight.pos = pos
		dlight.r = 255
		dlight.g = 125
		dlight.b = 0
		dlight.brightness = math.Rand(0, 1)*1
		dlight.Decay = 1000
		dlight.Size = 256*intensity*1
		dlight.DieTime = CurTime() + 0.075
	end

    emitter:Finish()
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EFFECT:Think() end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EFFECT:Render() end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------