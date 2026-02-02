hg.bloodparticles1 = hg.bloodparticles1 or {}
bloodparticles_hook = bloodparticles_hook or {}

local tr = {
	//filter = function(ent) return not ent:IsPlayer() and not ent:IsRagdoll() end
}

local col_red_darker = Color(122,0,0)
local col_red = Color(200,0,0)
local vecDown = Vector(0, 0, -40)
local vecZero = Vector(0, 0, 0)
local LerpVector = LerpVector
local math_random = math.random
local table_remove = table.remove
local util_Decal = util.Decal
local util_TraceLine = util.TraceLine
local render_SetMaterial = render.SetMaterial
local render_DrawSprite = render.DrawSprite
local render_DrawBeam = render.DrawBeam
local render_GetLightColor = render.GetLightColor

local hg_blood_draw_distance = ConVarExists("hg_blood_draw_distance") and GetConVar("hg_blood_draw_distance") or CreateClientConVar("hg_blood_draw_distance", 1024, true, nil, "distance to draw blood", 0, 4096)
local hg_blood_sprites = ConVarExists("hg_blood_sprites") and GetConVar("hg_blood_sprites") or CreateClientConVar("hg_blood_sprites", 1, true, nil, "blood is sprites or trails", 0, 1)

hook.Add("PostCleanupMap","removeblooddroplets",function()
	hg.bloodparticles1 = {}
	hg.bloodpositions = {}
	hg.bloodcount = 0
end)

local mat_huy = Material("effects/blood_core")
local lightcolor = Color(0, 0, 0, 255)
bloodparticles_hook[1] = function(anim_pos, mul)
	 
	local int = hg_blood_draw_distance:GetInt()
	local pos = lply:EyePos()
	--render.OverrideBlend( true, BLEND_SRC_ALPHA, BLEND_ONE, BLENDFUNC_ADD )
	local dstsqr = int * int
	local lplypos = LocalPlayer():EyePos()
	local lplyang = LocalPlayer():EyeAngles():Forward()
	for i = 1, #hg.bloodparticles1 do
		local part = hg.bloodparticles1[i]
		if not part then continue end
		if (pos - lplypos):Dot(lplyang) < 0 then continue end
		if (part[2] - pos):LengthSqr() > dstsqr then continue end
		--if !hg.isVisible(part[1],LocalPlayer():GetShootPos(),LocalPlayer(),MASK_VISIBLE) then continue end
		--render_SetMaterial(part[4])
		local pos = LerpVector(anim_pos, part[2], part[1])
		
		local light1 = render.GetLightColor(pos)
		local light2 = render.ComputeLighting(pos, vector_up * 1)
		local light3 = render.ComputeDynamicLighting(pos, vector_up * 1)

		local light = (light1 + light2 + light3) * 3

		if part.kishki then
			render_SetMaterial(part[4])
			lightcolor.r = math.min((part.artery and 45 or 10) * light[1], 255)
			render_DrawSprite(pos, part[5], part[6], lightcolor)
		else
			local len = (part[2] - part[1]):LengthSqr()
			--part.lerpeddiff = LerpVector(FrameTime() * 1, part.lerpeddiff or Vector(), (part[2] - part[1]))
			--if len > 1 * 1 then
				render_SetMaterial(mat_huy)
				lightcolor.r = math.min((part.artery and 45 or 20) * light[1], 255)
				--part.lerpedshit = LerpFT(!part.lasthit and 1 or mul * 1, part.lerpedshit or 1, part.lasthit and 7 or 1)
				--render_DrawBeam(pos - (len < 2 and (part[2] - part[1]):GetNormalized() * part.lerpedshit or (part[2] - part[1])) * 0.5 / mul / 24,pos + (part[2] - part[1]) * 0.5 / mul / 24, part.lerpedshit, 0, 1, part[9] or lightcolor )
				--render_DrawBeam(pos - (part[2] - part[1]) * part.lerpedshit / mul / 24 * 0.5,pos + (part[2] - part[1]) * part.lerpedshit / mul / 24 * 0.5, part.lerpedshit, 0, 1, part[9] or lightcolor )
				
				--render_DrawBeam(pos - (len < 2 and (part[2] - part[1]):GetNormalized() * 2 or (part[2] - part[1])) * 0.5 / mul / 24,pos + (part[2] - part[1]) * 0.5 / mul / 24, 1, 0, 1, part[9] or lightcolor )
				render_DrawBeam(pos - (part[2] - part[1]) * 1 / mul / 24 * 0.5,pos + (part[2] - part[1]) * 1 / mul / 24 * 0.5, 1, 0, 1, part[9] or lightcolor )

				--lightcolor.r = lightcolor.r * 0.25
				--debugoverlay.Line(part[2], part[1], 1, lightcolor, false)	
			--end
		end
	end
	--render.OverrideBlend( false )
end

local hg_old_blood = ConVarExists("hg_old_blood") and GetConVar("hg_old_blood") or CreateClientConVar("hg_old_blood", 0, true, false, "new decals, or old", 0, 1)

hg.bloodpositions = hg.bloodpositions or {}
hg.bloodcount = hg.bloodcount or 0
local function decalBlood(pos, normal, tr, artery, owner)
	local vec = tostring(math.Round(pos[1]))..tostring(math.Round(pos[2]))..tostring(math.Round(pos[3]))

	hg.bloodcount = hg.bloodcount + 1
	
	if hg.bloodcount > 10000 then
		hg.bloodpositions = {}
		hg.bloodcount = 0
	end

	-- я не знаю насколько большой можно делать такие таблицы... надеюсь, что это не так страшно выйдет

	if artery then
		if !hg_old_blood:GetBool() then
			local howmuch = 1
			
			//timer.Simple(0.1, function()
				hg.bloodpositions[vec] = (hg.bloodpositions[vec] or 0) + 1
				if hg.bloodpositions[vec] < 6 then
					util.Decal("Arterial.Blood2"..math.Clamp(hg.bloodpositions[vec], 1, 5), pos + normal, pos - normal, owner)
				end
				sound.Play("homigrad/blooddrip" .. math_random(1, 4) .. ".wav", pos, math.random(10, 60), tr.MatType == MAT_METAL and math.random(100, 120) or math.random(80, 120))
				if tr.MatType == MAT_METAL then
					sound.Play("zbattle/blood_drop_metal.mp3", pos, math.random(10, 40), tr.MatType == MAT_METAL and math.random(100, 120) or math.random(80, 120))
				end
			//end)
		else
			util.Decal("Arterial.Blood1", pos + normal, pos - normal, owner)
			sound.Play("homigrad/blooddrip" .. math_random(1, 4) .. ".wav", pos, math.random(10, 60), tr.MatType == MAT_METAL and math.random(100, 120) or math.random(80, 120))
			if tr.MatType == MAT_METAL then
				sound.Play("zbattle/blood_drop_metal.mp3", pos, math.random(10, 40), tr.MatType == MAT_METAL and math.random(100, 120) or math.random(80, 120))
			end
		end
	else
		if !hg_old_blood:GetBool() then
			local howmuch = 1
			
			//timer.Simple(0.1, function()
				hg.bloodpositions[vec] = (hg.bloodpositions[vec] or 0) + 1
				
				sound.Play("homigrad/blooddrip" .. math_random(1, 4) .. ".wav", pos, math.random(10, 60), tr.MatType == MAT_METAL and math.random(100, 120) or math.random(80, 120))
				if tr.MatType == MAT_METAL then
					sound.Play("zbattle/blood_drop_metal.mp3", pos, math.random(10, 40), tr.MatType == MAT_METAL and math.random(100, 120) or math.random(80, 120))
				end

				if hg.bloodpositions[vec] < 6 then
					util.Decal("Normal.Blood2"..math.Clamp((hg.bloodpositions[vec] or 0) + math.random(0, 2), 1, 5), pos + normal, pos - normal, owner)
				end

				if hg.bloodpositions[vec] == 50 then
					util.Decal("Blood", pos + normal, pos - normal, owner)
				end

			//end)
		else
			util.Decal("Normal.Blood1", pos + normal, pos - normal, owner)
			sound.Play("homigrad/blooddrip" .. math_random(1, 4) .. ".wav", pos, math.random(10, 60), tr.MatType == MAT_METAL and math.random(100, 120) or math.random(80, 120))
			if tr.MatType == MAT_METAL then
				sound.Play("zbattle/blood_drop_metal.mp3", pos, math.random(10, 40), tr.MatType == MAT_METAL and math.random(100, 120) or math.random(80, 120))
			end
		end
	end
end
--дурак, просто смотри сколько ентити стоит в одном месте
local tr2 = { collisiongroup = COLLISION_GROUP_WORLD, output = {} }

function util.IsInWorld( pos )
	tr2.start = pos
	tr2.endpos = pos

	return not util.TraceLine( tr2 ).HitWorld
end

local gravity = GetConVar("sv_gravity")

local radius = 20000
local radiusSqr = radius * radius

hook.Add("InitPostEntity", "sizeget", function()
	radius = hg.GetWorldSize()
    radiusSqr = radius * radius
end)

bloodparticles_hook[2] = function(mul)
	local grav = gravity:GetInt() / 10
    local time = CurTime()
	local gravvec = vecDown * mul * (math.max(0.0, grav))
	for i = #hg.bloodparticles1, 1, -1 do
		local part = hg.bloodparticles1[i]
		if not part then table_remove(hg.bloodparticles1, i) continue end
		
		local pos = part[1]
		local posSet = part[2]

		tr.start = posSet + vector_up * 0.0
		tr.endpos = tr.start + part[3] * mul
		tr.collisiongroup = COLLISION_GROUP_NONE

		result = util_TraceLine(tr)
		local hitPos = result.HitPos
		
		if radiusSqr < hitPos:LengthSqr() then table_remove(hg.bloodparticles1, i) continue end
		
        if bit.band(util.PointContents(hitPos), CONTENTS_WATER) == CONTENTS_WATER then
			hg.addBloodPart2(hitPos, part[3] / 20 + VectorRand(-1, 1), nil, nil, nil, nil, true)

			table_remove(hg.bloodparticles1, i)
			continue
		end
		
		if time - part[7] >= 30 then
			table_remove(hg.bloodparticles1, i)

			continue
		end

		if result.Hit and result.Entity:IsWorld() then
			table_remove(hg.bloodparticles1, i)
			local dir = result.HitNormal
			decalBlood(result.HitPos, dir, result, part.artery, part.owner)
			
			
			--sound.Play("zbattle/blood_drop.mp3", hitPos, math.random(10, 60), math.random(120, 120))
			--sound.Play("homigrad/blooddrip" .. math_random(1, 4) .. ".wav", hitPos, math.random(10, 60), math.random(80, 120))
			
			continue
		else
			if result.Hit then
				--local down = vecDown * mul * (math.max(0, grav))
				local down = result.HitNormal
				local nextpos = (result.Normal + down):GetNormalized() * 5
				
				if !insolid and (part.nextput or 0) < CurTime() then
					part.nextput = CurTime() + 1

					decalBlood(result.HitPos, result.HitNormal, result, part.artery, part.owner)
				end

				local insolid = result.StartSolid and IsValid(result.Entity)
				if insolid then
					local ph = result.Entity:TranslatePhysBoneToBone(result.PhysicsBone)
					ph = ph != -1 and ph or 0
					local center = result.Entity:GetBoneMatrix(ph)
					local len = result.Entity:BoneLength(ph + 1)
					
					if center then
						center = center:GetTranslation() + (len and center:GetAngles():Forward() * len or vector_origin) * 0.5
						nextpos = -(center - hitPos + vecDown * 0):GetNormalized() * 5
					end
				end
				local pulldown = (-vector_up * (grav / 600)):Cross(-result.HitNormal:Angle():Right())
				nextpos:Add(pulldown)
				part.lerpedmove = LerpVector(1, part.lerpedmove or part[3] * mul, nextpos * mul * 1)
				if part.lerpedmove:LengthSqr() < 0.1 * mul then
					decalBlood(result.HitPos, result.HitNormal, result, part.artery, part.owner)
					
					table_remove(hg.bloodparticles1, i)
				end
				--part.lerpedmove[3] = 0
				pos:Set(posSet + part.start_velocity * mul)
				posSet:Set(hitPos + part.lerpedmove + part.start_velocity * mul)
				part.hashitsomething = true
				--part[3]:Set(vecDown * 0.01)
				--part[3]:Zero()
				--part[3]:Set(part.lerpedmove)
			else
				if part.hashitsomething then
					part.hashitsomething = nil
					--part[3][3] = 0
					part[3] = (posSet - pos) / mul * 1--part.lerpedmove / mul
					--part.lerpedmove = nil
					pos:Set(posSet)
					posSet:Set(posSet)
				else
					pos:Set(posSet + part.start_velocity * mul)
					posSet:Set(hitPos + part.start_velocity * mul)
				end
			end

			part.lasthit = result.Hit
		end

		part[3] = LerpVector(0.25 * mul, part[3], vecZero)
		if !(result.Hit) then
			part[3]:Add(gravvec)
		--else
			--part[3]:Set(vecDown * mul * (math.max(0.1, grav)))
		end
	end
end