gasparticles = gasparticles or {}
gasparticles_hook = gasparticles_hook or {}
local gasparticles_hook = gasparticles_hook

--;; За каждую оптимизацию на канале мир становится...
local DECAL_BUDGET = 8          
local DEDUP_CELL_SIZE = 4       
local DEDUP_COOLDOWN = 0.15     
local FAR_DISTANCE = 2500       
local FAR_SKIP_CHANCE = 0.6
local FAR_DISTANCE_SQR = FAR_DISTANCE * FAR_DISTANCE

local recent_hits = {}  

local mats = {}
for i = 1, 3 do
	mats[i] = Material("homigrad/decals/blood" .. i)
end

local mats_huy = {}
for i = 1, 3 do
	mats_huy[i] = Material("homigrad/decals/bld" .. i + 3)
end


local tr_out = {}
local tr = {
	mask = MASK_SOLID_BRUSHONLY,  
	output = tr_out
}

local mat = Material("effects/blooddrop")
local vecDown = Vector(0, 0, -40)
local vecZero = Vector(0, 0, 0)
local LerpVector = LerpVector
local math_random = math.random
local util_Decal = util.Decal
local util_TraceLine = util.TraceLine
local render_SetMaterial = render.SetMaterial
local render_DrawSprite = render.DrawSprite
local col = Color( 131, 70, 21, 250)

local function hash_hit(pos, nrm)
    local gx = math.floor(pos.x / DEDUP_CELL_SIZE)
    local gy = math.floor(pos.y / DEDUP_CELL_SIZE)
    local gz = math.floor(pos.z / DEDUP_CELL_SIZE)
    local nx = math.floor(nrm.x * 10 + 0.5)
    local ny = math.floor(nrm.y * 10 + 0.5)
    local nz = math.floor(nrm.z * 10 + 0.5)
    return gx .. "," .. gy .. "," .. gz .. "|" .. nx .. "," .. ny .. "," .. nz
end

local function place_decal(hit_pos, normal, hit_tex)
    local lp = LocalPlayer()
    if IsValid(lp) then
        local d2 = lp:GetPos():DistToSqr(hit_pos)
        if d2 > FAR_DISTANCE_SQR and math.random() < FAR_SKIP_CHANCE then
            return false
        end
    end

    util.Decal("BeerSplash", hit_pos + normal, hit_pos - normal)
    return true
end

gasparticles_hook[1] = function(anim_pos)
	for i = 1, #gasparticles do
		local part = gasparticles[i]
		local pos = LerpVector(anim_pos, part[2], part[1])
		render_SetMaterial(mat)
		--render_DrawSprite(pos, part[5], part[6])
		render.DrawBeam(pos - (part[2] - part[1]) * 2,pos + (part[2] - part[1]) * 2, 10, 0, 1, col)
	end
end

gasparticles_hook[2] = function(mul)
	local now = CurTime()
	local placed = 0

	for k, t in pairs(recent_hits) do
		if t <= now then
			recent_hits[k] = nil
		end
	end

	for i = #gasparticles, 1, -1 do
		local part = gasparticles[i]
		if not part then
			gasparticles[i] = gasparticles[#gasparticles]
			gasparticles[#gasparticles] = nil
			goto cont
		end

		local pos = part[1]
		local posSet = part[2]
		tr.start = posSet
		tr.endpos = tr.start + part[3] * mul
		util_TraceLine(tr)
		local result = tr_out
		local hitPos = result.HitPos

		if result.Hit then
			if placed < DECAL_BUDGET then
				local key = hash_hit(hitPos, result.HitNormal)
				if not recent_hits[key] or recent_hits[key] <= now then
					if place_decal(hitPos, result.HitNormal, result.HitTexture) then
						recent_hits[key] = now + DEDUP_COOLDOWN
						placed = placed + 1
						sound.Play("homigrad/blooddrip" .. math_random(1, 4) .. ".wav", hitPos, math.random(10, 60), math.random(80, 120))
					end
				end
			end
			gasparticles[i] = gasparticles[#gasparticles]
			gasparticles[#gasparticles] = nil
		else
			pos:Set(posSet)
			posSet:Set(hitPos)
		end

		part[3] = LerpVector(0.25 * mul, part[3], vecZero)
		part[3]:Add(vecDown)

		::cont::
	end
end