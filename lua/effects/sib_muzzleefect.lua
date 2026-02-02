local images_muzzle = {"effects/muzzleflash1", "effects/muzzleflash2", "effects/muzzleflash3", "effects/muzzleflash4"}
local images_distort = {"sprites/heatwave"}
local function TableRandomChoice(tbl)
	return tbl[math.random(#tbl)]
end

local SIB = {}
SIB.SmokeImages = {"particle/smokesprites_0001", "particle/smokesprites_0002", "particle/smokesprites_0003", "particle/smokesprites_0004", "particle/smokesprites_0005", "particle/smokesprites_0006", "particle/smokesprites_0007", "particle/smokesprites_0008", "particle/smokesprites_0009", "particle/smokesprites_0010", "particle/smokesprites_0011", "particle/smokesprites_0012", "particle/smokesprites_0013", "particle/smokesprites_0014", "particle/smokesprites_0015", "particle/smokesprites_0016"}
function SIB_GetSmokeImage()
	return SIB.SmokeImages[math.random(#SIB.SmokeImages)]
end

function EFFECT:Init(data)
	local quality = 3
	if quality == 0 then return end
	local wpn = data:GetEntity()
	if not IsValid(wpn) then return end
	local ply = wpn:GetOwner()
	if not IsValid(ply) then return end
	local pos, dir = wpn:GetAttachment(wpn:LookupAttachment("muzzle")).Pos, wpn:GetAttachment(wpn:LookupAttachment("muzzle")).Ang
	dir = dir:Forward()
	local addvel = ply:GetVelocity()
	local emitter = ParticleEmitter(pos)
	
	--[[for i = 1, math.Round(quality*math.Clamp(wpn.Primary.Force/30,1,5)) do
        local particle = emitter:Add(SIB_GetSmokeImage(), pos)

        if particle then
            particle:SetVelocity(VectorRand() * 10 + (dir * i * math.Rand(12, 24)) + addvel)
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(0.5, 0.8)*math.Clamp(wpn.Primary.Force/30,1,3))
            particle:SetStartAlpha(math.Rand(10, 15) * (1.5))
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.Rand(2, 6))
            particle:SetEndSize(math.Rand(26, 32)*math.Clamp(wpn.Primary.Force/30,1,5))
            particle:SetRoll(math.rad(math.Rand(0, 360)))
            particle:SetRollDelta(math.Rand(-1, 1))
            particle:SetLighting(true)
            particle:SetAirResistance(96)
            particle:SetGravity(Vector(-7, 3, 60))
            particle:SetColor(185, 185, 185)
        end
    end--]]
	if quality >= 3 then
		local particle = emitter:Add(TableRandomChoice(images_distort), pos)
		if particle then
			particle:SetVelocity((dir * 25) + 1.05 * addvel)
			particle:SetLifeTime(0)
			particle:SetDieTime(math.Rand(0.1, 0.2))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(7, 10))
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-2, 2))
			particle:SetAirResistance(5)
			particle:SetGravity(Vector(0, 0, 40))
			particle:SetColor(255, 255, 255)
		end
	end

	if wpn.DoFlash then
		local dlight = DynamicLight(LocalPlayer():EntIndex())
		if dlight then
			dlight.pos = pos
			dlight.r = 255
			dlight.g = 215
			dlight.b = 55
			dlight.brightness = 1
			dlight.decay = 4000
			dlight.size = 156
			dlight.dietime = CurTime() + 0.2
		end
	end

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
	return false
end