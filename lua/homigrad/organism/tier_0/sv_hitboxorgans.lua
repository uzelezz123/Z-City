hg.organism = hg.organism or {}
local empty = {}
local Vector = Vector --ыыы
local vecZero, angZero = Vector(0, 0, 0), Angle(0, 0, 0)
local box, _mins = Vector(0, 0, 0), Vector(0, 0, 0)
local center

local LocalToWorld = LocalToWorld

local util_IntersectRayWithOBB = util.IntersectRayWithOBB
local util_IsOBBIntersectingOBB = util.IsOBBIntersectingOBB
local math_ceil = math.ceil
local stepDiv = 1
local tracePos = Vector(0, 0, 0)
function hg.organism.Trace(pos, dir, size, maxpen, boxs, center, endDis, organs, ricochetable, funcInput, ...)
	local endDisSqr = endDis * endDis
	tracePos:Set(pos)

	local hitBoxs = {}
	local tracePoses = {}
	local inputHole, outputHole = {}, {}
	local inBody, hitSomething
	local box
	local stepDis = 1 / stepDiv
	local distance = math_ceil(dir:Length())
	local dirSub = 0
	local ricocheted
	local ricochetAng
	distance = math.Clamp(distance, 0, 50)
	dir:Normalize()
	dir = dir * stepDis
	
	local distancereal = distance
	
	local passing = 0
	local maxtries = 20
	while(passing < distance and maxtries > 0)do
		maxtries = maxtries - 1
		
		if maxpen ~= 0 and passing >= maxpen then break end

		dir:Normalize()

		local frac = 1
		local iHit
		local normal
		local hit
		for i = 1, #boxs do
			if hitBoxs[i] then continue end

			box = boxs[i]
			
			if not organs[box[6]] then continue end
			
			local startpos = tracePos - dir * 0
			local endpos = dir * 100

			local hit_, normal_, frac_ = util_IntersectRayWithOBB(startpos, endpos, box[1], box[2], box[3], box[4])
			
			if hit_ then
				//print(organs[box[6]][box[7]][1], distance, passing, passing > distance, 2)
				if frac_ < frac then
					iHit = i
					
					frac = frac_
					normal = normal_
					hit = hit_
				end
			end
		end
		
		frac = math.max(frac, 0.001)

		dir = dir:GetNormalized() * frac * 100
		
		if iHit then
			hitBoxs[iHit] = true
			hitSomething = true

			local box = boxs[iHit]
			
			/*if ricochetable then
				local bonemul = organs[box[6]] and organs[box[6]][box[7]][2] or 0
				local prot = (organs[box[6]] and organs[box[6]][box[7]][8] or 0) / distance

				normal:Rotate(box[2])
				ricochetAng = math.deg(math.acos(math.abs(normal:Dot(dir:GetNormalized()))))

				local randomness = math.random(100) <= math.max(ricochetAng - 70,10) / 30 * 100
				ricocheted = ((bonemul >= 0.5 and randomness) or prot >= 1)
				ricocheted = ricocheted and (ricochetAng > 70)

				if ricocheted then
					if ricochetAng > 60 then
						local NewVec = dir:Angle()
						NewVec:RotateAroundAxis(normal,180)
						NewVec = LerpAngle(math.Rand(0, 1), NewVec, (-dir):Angle())
						dir = -NewVec:Forward() * frac * 100
					end
				end
			end*/
			
			dirSub = funcInput(box, tracePos, ricocheted, ...)
			
			if dirSub then
				distance = distance - dirSub * distance
			end
			
			//print(organs[box[6]][box[7]][1], distance, dirSub, passing, passing > distance)
		end
		
		passing = passing + 100 * frac

		if not inBody and iHit then
			inBody = true
			inputHole[#inputHole + 1] = Vector(tracePos[1], tracePos[2], tracePos[3])
		end

		if inBody and not iHit then
			outputHole[#outputHole + 1] = Vector(tracePos[1], tracePos[2], tracePos[3])
			inBody = nil
		end

		if hit then
			tracePos = hit
		else
			//tracePos:Add(dir)
		end
		
		tracePoses[#tracePoses + 1] = Vector(tracePos[1], tracePos[2], tracePos[3])
		
		if passing >= distance or (tracePos - center):LengthSqr() > endDisSqr then break end
	end
	
	if !hitSomething then
		inputHole[1] = Vector(pos[1], pos[2], pos[3])
	end

	if !hitSomething then
		outputHole[1] = Vector(tracePos[1], tracePos[2], tracePos[3])
	end

	dir:Normalize()

	return tracePos, hitBoxs, inputHole, outputHole, dir, distance, tracePoses
end

function hg.organism.BlastTrace(pos, size, dmg, boxs, organs, funcInput, ...)
	local box
	local center
	
	local size = size
	for i = 1, #boxs do
		box = boxs[i]
		center = box[1]

		local dist = pos:Distance(center)
		--size = size * 999
		local amt = dmg / dist * (1 - (organs[box[6]] and organs[box[6]][box[7]][2] or 0)) / size
		
		local dirSub = funcInput(box, amt, ...)
		
		size = size * (dirSub * 0.01 + 1)
	end
end