hg.bloodparticles2 = hg.bloodparticles2 or {}
bloodparticles_hook = bloodparticles_hook or {}

local tr = {
	filter = function(ent) return not ent:IsPlayer() and not ent:IsRagdoll() end
}

local vecZero = Vector(0,0,0)
local LerpVector = LerpVector

local math_random = math.random
local table_remove = table.remove

local util_Decal = util.Decal
local util_TraceLine = util.TraceLine
local render_SetMaterial = render.SetMaterial
local render_DrawSprite = render.DrawSprite
local surface_SetDrawColor = surface.SetDrawColor

local color = Color(90,0,0,122)

bloodparticles_hook[3] = function(anim_pos)
    local time = CurTime()

    for i = 1,#hg.bloodparticles2 do
        local part = hg.bloodparticles2[i]
        if not part then continue end
        local animpos = math.max((part[7] - time) / part[8], 0)
        color.a = part.water and (200 * animpos) or (122 * animpos)
        local sizeing = part.water and math.max((1 - animpos), 0.1) or 1
        render_SetMaterial(part[4])
        render_DrawSprite(LerpVector(anim_pos,part[2],part[1]),part[5] * sizeing, part[6] * sizeing, color)
    end
end

local gravity = GetConVar("sv_gravity")
local vecDown = Vector(0, 0, -1)

local radius = 20000
local radiusSqr = radius * radius

hook.Add("InitPostEntity", "sizeget2", function()
	radius = hg.GetWorldSize()
    radiusSqr = radius * radius
end)

bloodparticles_hook[4] = function(mul)
    local time = CurTime()
    local grav = gravity:GetInt() / 30

    for i = #hg.bloodparticles2, 1, -1 do
        local part = hg.bloodparticles2[i]
        if not part then table_remove(hg.bloodparticles2, i) continue end

        local pos = part[1]
        local posSet = part[2]
        
        tr.start = posSet
        tr.endpos = tr.start + part[3] * mul
        result = util_TraceLine(tr)
        
        local hitPos = result.HitPos

        local up = hitPos[3] - pos[3]

		if radiusSqr < hitPos:LengthSqr() then table_remove(hg.bloodparticles2, i) continue end

        if result.Hit or part[7] - time <= 0 then
            table_remove(hg.bloodparticles2, i)
            
            --util.Decal("Water.Blood", pos + result.HitNormal, pos - result.HitNormal, ents.FindInSphere(pos, 1))

            --local newvec = result.Normal:Angle()
            --newvec:RotateAroundAxis(result.HitNormal, 180)
            --newvec = newvec:Forward() * part[3] * mul
--
            --pos:Set(posSet)
            --posSet:Set(hitPos + newvec)

            continue
        else
            pos:Set(posSet)
            posSet:Set(hitPos)
        end

        part[3] = LerpVector(0.5 * mul,part[3],vecZero)

        if bit.band(util.PointContents(pos + vector_up * 7), CONTENTS_WATER) != CONTENTS_WATER then
            part[3][3] = -5
            --pos:Add(-vector_up * up)
            --posSet:Add(-vector_up * up)
            --hg.addBloodPart(part[1], part[3] * 2)

			--table_remove(hg.bloodparticles2, i)
			--continue
        end
    end
end
