--[[-------------------------------------------------------------------------


vFire Creation Interface


---------------------------------------------------------------------------]]
if SERVER then
	--[[-------------------------------------------------------------------------
	In charge of creating a new fire in the world in appropriate positions/angles
	Attempts to create fire on a parent entity at a certain position
	Merges potentially new fires with existing ones if they're close enough
	---------------------------------------------------------------------------]]
	local mergeDistToSqr = 500
	local mergeDist = math.sqrt(mergeDistToSqr)
	local lastSpawned = CurTime()
	local spawnedammout = 0
	function CreateVFire(parent, pos, normal, newFeed, spreader)

		--;; КАКАЩКЕ
		if VFIRE_DISABLED then return end

		-- Just to make sure
		if vFireIsVFireEnt(parent) then return end
		
		-- Handle information regarding our spreader
		local owner = parent
		local spreaderIsFire = false
		if IsValid(spreader) then
			if spreader:GetClass() == "vfire" then
				spreaderIsFire = true
			end
			owner = spreader:GetOwner()
		end

		-- Settle on our bone
		local bone
		if vFireIsCharacter(parent) then
			local boneCount = parent:GetBoneCount()
			-- Build a valid set of bones to attach to
			if !parent.vFireValidBones then
				parent.vFireValidBones = {}
				for b = 0, boneCount do
					if parent:BoneHasFlag(b, BONE_USED_BY_ATTACHMENT) then
						local bonePos = parent:GetBonePosition(b)
						-- Avoid bones with bad positions
						if bonePos:DistToSqr(pos) <= 10000000 then
							parent.vFireValidBones[b] = b
						end
					end
				end
			end
			-- Choose a random bone from the verified ones
			bone = table.Random(parent.vFireValidBones)
		end
		if bone == nil then
			bone = 0
		end

		if !parent.fires then parent.fires = {} end

		-- Use a table of close fires
		local closeEnts
		if parent:IsWorld() then
			closeEnts = ents.FindInSphere(pos, mergeDist)
		else
			closeEnts = {}
			local clustersTable = parent.fireClusters
			if clustersTable then
				for cluster, clusterPos in pairs(parent.fireClusters) do
					if cluster.fires then
						for k, fire2 in pairs(cluster.fires) do
							table.insert(closeEnts, fire2)
						end
					end
				end
			end
		end

		-- Prevent fire entity spams by merging ourselves with existing neighbors
		for _, fire2 in pairs(closeEnts) do
			if !parent.fires[fire2] then continue end
			if vFireIsCharacter(parent) and fire2.bone != bone then continue end
			if IsValid(fire2) then
				-- Are we close enough?
				if pos:DistToSqr(fire2:GetPos()) <= mergeDistToSqr then
					
					if spreaderIsFire then -- We're spreading, give a random feed and life to the neighbor
						-- local spreaderGiveLife = math.Rand(spreader.life, spreader.life)
						-- spreader:GiveLife(fire2, spreaderGiveLife)
						spreader:GiveFeed(fire2, newFeed)
					else -- We're not spreading (we created a brand new fire) just add the new feed to the existing fire
						fire2.feed = fire2.feed + newFeed
					end

					-- Our neighbor will likely grow, prioritize it for responsiveness if the fire was made by a player
					if !spreaderIsFire then
						timer.Simple(0, function()
							if !IsValid(fire2) then return end
							fire2:Prioritize(5, true)
						end)
					end

					return
				end
			end
		end

		-- We didn't merge, create a new entity
		local fire = ents.Create("vfire")

		--[[-------------------------------------------------------------------------
		A WIP attempt to place fires with an angle that always faces a global wanted vector
		---------------------------------------------------------------------------
			   		local ang = normal:Angle()
			        -- local dot = ang:Up():Dot(Vector(1, 1, 0))
			        -- local rotate = 90 * dot

			        local forward = ang:Forward()
			        local up = ang:Up()

			        local wanted = Vector(0, 0, -1)
			        local flip = false
			        if forward.z != 0 then -- This happens when we aren't hitting a wall
			            local z2 = -forward.y/forward.z
			            wanted = Vector(0, 1, z2)
			            flip = (up.x < 0)
			        elseif forward.x != 0 then -- This happens when we are hitting a wall
			            local x2 = -forward.y/forward.x
			            wanted = Vector(x2, 1, 0)
			            flip = (forward.x > 0)
			        end
			        wanted:Normalize()
			        
			        local cos = math.Clamp(up:Dot(wanted), -1, 1) -- dot product = len1 * len2 * cos(angle between them), and both lengths are 1 in this case
			        local rollamount = math.deg(math.acos(cos))

			        -- Now we just need to figure out which way to rotate - left or right?
			        if flip then rollamount = 360 - rollamount end

			        -- ang:Add(Angle(0, 0, rollamount)) -- vector:Angle() always has roll = 0 so this is safe
			        ang:RotateAroundAxis(ang:Forward(), rollamount)

			        fire:SetAngles(ang)
        --[[-------------------------------------------------------------------------
        End of attempt
        ---------------------------------------------------------------------------]]

        fire:SetAngles(normal:Angle())



		-- Place our fire in respect to the parent
		if vFireIsCharacter(parent) then
			-- Fix position
			local bonePos = parent:GetBonePosition(bone)

			-- Parent is set internally through FollowBone
			fire:FollowBone(parent, bone)
			if bonePos then
				fire:SetPos(bonePos)
			else
				fire:SetPos(pos)
			end
		else
			fire:SetPos(pos)
			if IsValid(parent) then
				fire:SetParent(parent)
			end
		end

		-- Override some state limitations
		if vFireIsCharacter(parent) then
			local boneLen = parent:BoneLength(bone) or 1
			local maxState = math.Clamp(math.Round(boneLen / 8, 0), 2, 5)
			fire.stateDown = maxState
			fire.stateUp = maxState
		else
			-- Before we actually spawn, make sure we have the minimal placement requirement
			local canGrow, newPos = fire:ImprovePlacement(1, parent)
			if !canGrow then -- We're not worthy
				fire:Remove()
				return
			else
				fire:SetPos(newPos)
				fire.stateUp = 1
			end
		end

		-- Remember the bone for bone remembering purposes
		fire.bone = bone

		-- Initialize the owner as the parent or the spreader's owner
		fire:SetOwner(owner)

		fire:Spawn()

		-- Pass the new feed
		if spreaderIsFire then
			spreader:GiveFeed(fire, newFeed)
		else
			fire.feed = newFeed
		end

		-- Create a delayed decal
		if vFireEnableDecals then
			if math.Rand(0, 1) < vFireDecalProbability then
				timer.Simple(math.Rand(2, 15), function()
					if IsValid(fire) then
						local size = vFireStateToSize(fire:GetFireState())
						local scorch = "vScorch_"..size
						util.Decal(
							scorch,
							fire:GetPos() + fire:GetForward(),
							fire:GetPos() + fire:GetForward() * -15,
							fire
						)
					end
				end)
			end
		end

		return fire
	end





	--[[-------------------------------------------------------------------------
	In charge of creating a fire ball that sticks to surfaces
	---------------------------------------------------------------------------]]
	local lastSpawned2 = CurTime()
	local spawnedammout = 0
	function CreateVFireBall(life, feedCarry, pos, vel, owner)

		local fireBall = ents.Create("vfire_ball")
			fireBall:SetPos(pos)
			if owner then
				fireBall:SetOwner(owner)
			end
		fireBall:Spawn()

		fireBall:GetPhysicsObject():AddVelocity(vel)
		fireBall:ChangeLife(life)
		fireBall.feedCarry = feedCarry

		return fireBall
	end





	function CreateVFireEntFires(ent, count)
		if not IsValid(ent) then return end
		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then

			if !ent.vFireIgnitePositions then ent.vFireIgnitePositions = {} end

			-- Increased scope to reduce recalls
			local meshConvexes
			local radius
			local center
			
			for i = 1, count do
				
				local pos = ent.vFireIgnitePositions[i]

				if pos then

					-- We have a position cached for this index, use it by translating the local position to a world position

					pos = ent:LocalToWorld(pos)
				
				else
					
					-- We don't have a position cached, calculate it using the mesh convexes

					if !meshConvexes then meshConvexes = phys:GetMeshConvexes() end
					if !meshConvexes then return false end

					local convexData = table.Random(meshConvexes)

					local sumVec = Vector()
					local sum = 0
					for k, posTable in pairs(convexData) do
						local weight = math.Rand(0, 1)
						sumVec = sumVec + ent:LocalToWorld(posTable.pos) * weight
						sum = sum + weight
					end
					sumVec = sumVec / sum

					-- Cache and set the position variable
					ent.vFireIgnitePositions[i] = ent:WorldToLocal(sumVec)
					pos = sumVec

				end

				if pos then

					if !radius then radius = ent:GetModelRadius() end
					if !center then center = ent:WorldSpaceCenter() end

					if radius and center then

						local vel = (center - pos) * radius
						local norm = -vel
						norm:Normalize()
						local life = math.Rand(5, 7)
						local feed = radius

						CreateVFireBall(life, feed, pos + norm * 25, vel)

					end
					
				end

			end

			return true
		end

		return false
	end
end


















--[[-------------------------------------------------------------------------
In charge of creating clientside effects for visual fidelity purposes
---------------------------------------------------------------------------]]
if CLIENT then

	local function physDummyValid(c)
		return IsValid(c.dummy)
	end
	local function physDummyStep(c)
		if CurTime() > c.endTime then
			c.dummy:Remove()
		end
	end
	function CreateCSVFirePhysDummy(pos, vel, lifeTime, nocollide)

		local colGroup = COLLISION_GROUP_IN_VEHICLE
		if !nocollide then colGroup = COLLISION_GROUP_WORLD end


		local dummy = ents.CreateClientProp()
			dummy:SetNoDraw(true)
			dummy:SetModel(vFireDummyModel)
			dummy:SetPos(pos)
			dummy:PhysicsInit(SOLID_VPHYSICS)
			dummy:SetMoveType(MOVETYPE_VPHYSICS)
			dummy:SetSolid(SOLID_VPHYSICS)
			dummy:SetCollisionGroup(colGroup)
			dummy:SetAngles(AngleRand())
		dummy:Spawn()

		local phys = dummy:GetPhysicsObject()
		phys:SetVelocity(vel)
		phys:SetMaterial("gmod_silent")

		local context = {
			IsValid = physDummyValid,
			dummy = dummy,
			endTime = CurTime() + lifeTime
		}

		hook.Add("Think", context, physDummyStep)

		return dummy
	end

	local function followForceValid(c)
		return c.isValid
	end
	local function followForceStep(c)
		local curTime = CurTime()
		if curTime < c.nextRun then return end
		c.nextRun = curTime + c.frequency

		if !IsValid(c.follower) then
			c.isValid = false
			return
		end

		if c.isEntity then
			if !IsValid(c.target) then c.isValid = false return end
		end

		if curTime > c.endTime then c.isValid = false return end

		local frac1to0 = (c.endTime - curTime) / (c.lifeTime)
		local strength = c.startStrength * frac1to0 + c.endStrength * (1 - frac1to0)

		local targetPos = c.target
		if isentity(c.target) then targetPos = targetPos:GetPos() end

		local diff = targetPos - c.follower:GetPos()
		if c.normalize then diff = diff:GetNormalized() end
		c.follower:GetPhysicsObject():AddVelocity(diff * strength)
	end
	function CreateVFireFollowForce(follower, target, lifeTime, frequency, startStrength, endStrength, normalize)
		
		local startTime = CurTime()
		local endTime = CurTime() + lifeTime
		local isEntity = isentity(target)
		
		local context = {
			IsValid = followForceValid,
			isValid = true,

			isEntity = isEntity,

			nextRun = 0,
			lifeTime = lifeTime,
			startTime = startTime,
			endTime = endTime,
			frequency = frequency,

			follower = follower,
			target = target,

			startStrength = startStrength,
			endStrength = endStrength,

			normalize = normalize
		}

		followForceStep(context)

		hook.Add("Think", context, followForceStep)
	end

	function CreateVFireFireHazeParticle(pos, vel, size, dieTime, gravity, resist, roll, brightness, alpha)
		local pe = ParticleEmitter(pos)
		if (pe) then

			local p = pe:Add("effects/muzzleflash3", pos)

			p:SetLifeTime(0)
			p:SetDieTime(dieTime)
			
			p:SetStartSize(0)
			p:SetEndSize(size)

			p:SetStartAlpha(math.random(alpha / 2, alpha))
			p:SetEndAlpha(0)

			p:SetColor(brightness, brightness, brightness)
			p:SetLighting(false)
			
			p:SetVelocity(vel)
			p:SetGravity(gravity * size)
			p:SetAirResistance(resist)

			p:SetCollide(false)

			p:SetRoll(math.Rand(0, 2 * math.pi))
			p:SetRollDelta(roll)

			pe:Finish()
		end
	end

	function CreateVFireDebrisSpurt(pos, count, minDieTime, maxDieTime, minSize, maxSize, roll, vel, spread, collide)
		local pe = ParticleEmitter(pos)
		if (pe) then
			for i = 1, count do
				local p = pe:Add(table.Random(list.Get("vFireDebris")), pos)

				p:SetLifeTime(0)
				p:SetDieTime(math.Rand(minDieTime, maxDieTime))
				
				local size = math.Rand(minSize, maxSize)
				p:SetStartSize(size)
				p:SetEndSize(size)

				p:SetStartAlpha(255)
				p:SetEndAlpha(255)

				p:SetColor(255, 255, 255)
				p:SetLighting(true)
				
				p:SetVelocity(vel * math.Rand(0.5, 1) + VectorRand() * spread)
				p:SetGravity(Vector(0, 0, -750))
				p:SetAirResistance(0)

				p:SetCollide(collide)
				p:SetBounce(0.15)

				p:SetRoll(math.Rand(0, 2 * math.pi))
				p:SetRollDelta(math.Rand(-roll, roll))
			end
			pe:Finish()
		end
	end

	function CreateVFireDirtSpurt(pos, count, minDieTime, maxDieTime, minSize, maxSize, roll, vel, spread, collide)
		local pe = ParticleEmitter(pos)
		if (pe) then
			for i = 1, count do
				local p = pe:Add(table.Random(list.Get("vFireDirt")), pos)

				p:SetLifeTime(0)
				p:SetDieTime(math.Rand(minDieTime, maxDieTime))
				
				local size = math.Rand(minSize, maxSize)
				p:SetStartSize(0)
				p:SetEndSize(size)

				p:SetStartAlpha(255)
				p:SetEndAlpha(0)

				p:SetColor(255, 255, 255)
				p:SetLighting(true)
				
				p:SetVelocity(vel * math.Rand(0.5, 1) + VectorRand() * spread)
				p:SetGravity(Vector(0, 0, -750))
				p:SetAirResistance(0)

				p:SetCollide(collide)
				p:SetBounce(0.15)

				p:SetRoll(math.Rand(0, 2 * math.pi))
				p:SetRollDelta(math.Rand(-roll, roll))
			end
			pe:Finish()
		end
	end

	function CreateVFireSparksSpurt(pos, count, minDieTime, maxDieTime, minSize, maxSize, roll, vel, spread, resistance)
		local pe = ParticleEmitter(pos)
		if (pe) then
			for i = 1, count do
				local p = pe:Add("effects/yellowflare", pos)

				p:SetLifeTime(0)
				p:SetDieTime(math.Rand(minDieTime, maxDieTime))
				
				local size = math.Rand(minSize, maxSize)
				p:SetStartSize(size)
				p:SetEndSize(0)

				p:SetStartAlpha(255)
				p:SetEndAlpha(255)

				p:SetColor(255, 255, 255)
				p:SetLighting(false)
				
				p:SetVelocity(vel * math.Rand(0.5, 1) + VectorRand() * spread)
				p:SetGravity(Vector(0, 0, -750))
				p:SetAirResistance(resistance)

				p:SetCollide(collide)

				p:SetRoll(math.Rand(0, 2 * math.pi))
				p:SetRollDelta(math.Rand(-roll, roll))
			end
			pe:Finish()
		end
	end

	function CreateVFireShockwave(pos, magnitude, particleCount)
		local pe = ParticleEmitter(pos)
		if (pe) then

			local bubble = pe:Add("particle/particle_ring_wave_8", pos)

			local dieTime = math.sqrt(magnitude * 0.01) / 2
			bubble:SetLifeTime(0)
			bubble:SetDieTime(dieTime)
			
			local endSize = dieTime * 36000
			bubble:SetStartSize(0)
			bubble:SetEndSize(endSize)

			local alpha = math.max(math.tanh((magnitude - 7) / 20) * 255, 0)
			bubble:SetStartAlpha(alpha)
			bubble:SetEndAlpha(0)

			bubble:SetColor(128, 128, 128)
			bubble:SetLighting(false)
			
			bubble:SetVelocity(Vector())
			bubble:SetGravity(Vector())
			bubble:SetAirResistance(10000)

			bubble:SetCollide(false)

			bubble:SetRoll(math.Rand(0, 2 * math.pi))
			local rollDelta = 10
			bubble:SetRollDelta(math.Rand(-rollDelta, rollDelta))

			local kick = pe:Add("particle/smokestack", pos)
			kick:SetLifeTime(0)
			kick:SetDieTime(dieTime * 1.5)
			
			kick:SetStartSize(0)
			kick:SetEndSize(endSize * 1.5)

			kick:SetStartAlpha(alpha * 0.75)
			kick:SetEndAlpha(0)

			kick:SetColor(128, 128, 128)
			kick:SetLighting(false)
			
			kick:SetVelocity(Vector())
			kick:SetGravity(Vector())
			kick:SetAirResistance(1)

			kick:SetCollide(false)

			kick:SetRoll(math.Rand(0, 2 * math.pi))
			kick:SetRollDelta(math.Rand(-rollDelta, rollDelta) * 0.5)

			pe:Finish()
		end
	end

	--[[-------------------------------------------------------------------------
	Creates a single smoke particle with some hardcoded behavior for consistency purposes
	---------------------------------------------------------------------------]]
	function CreateVFireSmokeParticle(pos, vel, size, dieTime, gravity, resist, roll, brightness, alpha)

		local pe = ParticleEmitter(pos)
		if (pe) then

			local p = pe:Add(table.Random(list.Get("vFireSmoke")), pos)

			p:SetLifeTime(0)
			p:SetDieTime(dieTime)
			
			p:SetStartSize(0)
			p:SetEndSize(size)

			p:SetStartAlpha(alpha)
			p:SetEndAlpha(0)

			p:SetColor(brightness, brightness, brightness)
			p:SetLighting(true)
			
			p:SetVelocity(vel)
			p:SetGravity(gravity * size)
			p:SetAirResistance(size * resist)

			p:SetCollide(false)

			p:SetRoll(math.Rand(0, 2 * math.pi))
			-- The bigger the size the less the roll delta
			p:SetRollDelta(roll * 900 / size)

			pe:Finish()
		end
	end

	--[[-------------------------------------------------------------------------
	Attaches an explosion trail to an entity/position (follow can either be an entity or a vector)
	---------------------------------------------------------------------------]]
	local function explosionTrailValid(c)
		if c.reps <= 0 then return false end
		if c.isEntity and !IsValid(c.follow) then return false end
		return true
	end
	local function explosionTrailStep(c)
		local curTime = CurTime()
		if curTime < c.nextRun then return end
		c.nextRun = curTime + c.interval

			local pos
			if c.isEntity then
				pos = c.follow:GetPos()
			else
				pos = c.follow
			end

			local radiusOffset = VectorRand() * math.Rand(c.minRadius or 0, c.maxRadius or 0)

			local particleString
			if c.bigBurst then
				particleString = "vFire_Burst_Main_Big"
			else
				particleString = "vFire_Burst_Main"
			end
			ParticleEffect(particleString, pos + radiusOffset, Angle())

		c.reps = c.reps - 1	
	end
	function CreateVFireExplosionTrail(follow, lifeTime, interval, bigBurst, minRadius, maxRadius)
		
		local isEntity = isentity(follow)

		if isEntity and !IsValid(follow) then return end

		local reps = math.floor(lifeTime / interval, 0)
		
		local context = {
			IsValid = explosionTrailValid,
			interval = interval,
			reps = reps,
			nextRun = 0,
			
			follow = follow,
			isEntity = isEntity,

			bigBurst = bigBurst,
			minRadius = minRadius,
			maxRadius = maxRadius
		}

		explosionTrailStep(context)

		hook.Add("Think", context, explosionTrailStep)
	end

	--[[-------------------------------------------------------------------------
	Attaches a smoke trail to an entity/position (follow can either be an entity or a vector)
	---------------------------------------------------------------------------]]
	local function smokeTrailValid(c)
		if c.reps <= 0 then return false end
		if c.isEntity and !IsValid(c.follow) then return false end
		return true
	end
	local function smokeTrailStep(c)
		local curTime = CurTime()
		if curTime < c.nextRun then return end
		c.nextRun = curTime + c.interval
		
			local size = c.startRadius * (1 - c.frac) + c.endRadius * c.frac

			-- Introduce noise to the die time value, this helps develop the trail into more interesting shapes
			local dieTime
			if c.dieTimeNoise then
				dNoise = math.Rand(-c.dieTimeNoise, c.dieTimeNoise)
				local dFrc = math.Clamp(c.frac + dNoise, 0, 1)
				dieTime = c.startLength * (1 - dFrc) + c.endLength * dFrc
			else
				dieTime = c.startLength * (1 - c.frac) + c.endLength * c.frac
			end
			
			local brightness = math.random(c.minBright, c.maxBright)
			local alpha = math.random(c.minAlpha, c.maxAlpha)
			local pos, vel
			if c.isEntity then
				vel = c.follow:GetVelocity()
				pos = c.follow:GetPos()
			else
				pos = c.follow
				vel = Vector()
			end

			c.frac = c.frac + c.fracAdd

			local roll = math.Rand(c.minRoll, c.maxRoll)

			CreateVFireSmokeParticle(pos, vel, size, dieTime, c.gravity, c.resist, roll, brightness, alpha)

		c.reps = c.reps - 1	
	end
	function CreateVFireSmokeTrail(follow, lifeTime, interval, startRadius, endRadius, startLength, endLength, gravity, resist, minRoll, maxRoll, minBright, maxBright, minAlpha, maxAlpha, dieTimeNoise, delay)
		
		local isEntity = isentity(follow)

		if isEntity and !IsValid(follow) then return end

		local reps = math.ceil(lifeTime / interval)
		local frac, fracAdd = 0, 1 / reps

		delay = delay or 0
		
		local context = {
			IsValid = smokeTrailValid,
			interval = interval,
			reps = reps,
			nextRun = CurTime() + delay,
			
			isEntity = isEntity,
			frac = frac,
			fracAdd = fracAdd,
			follow = follow,
			startRadius = startRadius,
			endRadius = endRadius,
			startLength = startLength,
			endLength = endLength,
			gravity = gravity,
			resist = resist,
			minRoll = minRoll,
			maxRoll = maxRoll,
			minBright = minBright,
			maxBright = maxBright,
			minAlpha = minAlpha,
			maxAlpha = maxAlpha,
			dieTimeNoise = dieTimeNoise
		}

		smokeTrailStep(context)

		hook.Add("Think", context, smokeTrailStep)
	end


	--[[-------------------------------------------------------------------------
	Attaches a fire trail to an entity/position (follow can either be an entity or a vector)
	---------------------------------------------------------------------------]]
	local function fireTrailValid(c)
		if c.reps <= -1 then return false end
		if c.isEntity and !IsValid(c.attach) then return false end
		return true
	end
	local function fireTrailStep(c)

		local curTime = CurTime()
		if curTime < c.nextRun then return end
		c.nextRun = curTime + c.interval

		if IsValid(c.trailFlames) then
			c.trailFlames:StopEmission()
		end

		if c.reps > 0 then
			c.trailFlames = CreateParticleSystem(
				c.attach,
				"vFire_Flames_"..vFireStateToSize(c.state)..c.LODStr,
				1,
				0,
				c.attachPos
			)

			if c.pullPos then
				vFirePullParticlesToPos(c.trailFlames, c.pullPos)
			end
		end

		c.reps = c.reps - 1
		c.state = c.state + c.add

	end
	function CreateVFireTrail(follow, startLife, endLife, lifeTime, canLOD, pullPos)

		local isEntity = isentity(follow) -- If we're not an entity we assume to be a position

		local LODStr = ""
		if canLOD == nil then -- We force LODs if we're neither false or true
			LODStr = "_LOD"
		else
			if canLOD and vFireGetLOD(follow) == 1 then
				LODStr = "_LOD"
			end
		end
		
		local state = vFireLifeToState(startLife)
		local targetState = vFireLifeToState(endLife)
		local reps = math.max(math.abs(state - targetState), 1) + 1 -- At least one rep
		local interval = lifeTime / reps

		local attach, attachPos
		if !isEntity then
			attach = game.GetWorld()
			attachPos = follow
		else
			attach = follow
			attachPos = Vector()
		end

		local add = 0
		if targetState < state then add = -1 end
		if targetState > state then add = 1 end

		local context = {
			IsValid = fireTrailValid,
			interval = interval,
			reps = reps,
			nextRun = 0,
			add = add,

			state = state,
			targetState = targetState,
			attach = attach,
			attachPos = attachPos,
			isEntity = isEntity,
			trailFlames = nil,
			LODStr = LODStr,
			pullPos = pullPos
		}

		fireTrailStep(context)

		hook.Add("Think", context, fireTrailStep)
	end

	--[[-------------------------------------------------------------------------
	Create a dynamic light attachment
	---------------------------------------------------------------------------]]
	local function dynamicLightValid(c)
		if CurTime() > c.endTime then return false end
		if c.isEntity and !IsValid(c.follow) then return false end
		return true
	end
	local function dynamicLightStep(c)

		local attachPos
		if !c.isEntity then
			attachPos = c.follow
		else
			attachPos = c.follow:GetPos()
		end

		local curTime = CurTime()
		local frac = (c.endTime - curTime) / (c.lifeTime)
		local fracRev = 1 - frac

		local yellowness = c.startYellowness * frac + c.endYellowness * fracRev
		local glowSize = c.startSize * frac + c.endSize * fracRev

		local d = DynamicLight(c.lightID)
		if d then
			d.pos = attachPos
			d.r = 255 * frac
			d.g = yellowness * frac
			d.b = c.blue * frac
			d.brightness = c.brightness
			d.decay = 0
			d.size = glowSize
			d.dietime = CurTime() + c.dieTime
		end
	end
	local vFireLightAttachID = 5000
	function CreateVFireDynamicLight(follow, lifeTime, brightness, startSize, endSize, dieTime, startYellowness, endYellowness, blue)
		do return end
		local isEntity = isentity(follow) -- If we're not an entity we assume to be a position

		local startTime = CurTime()
		local endTime = startTime + lifeTime

		local context = {
			IsValid = dynamicLightValid,
			isEntity = isEntity,
			follow = follow,
			startTime = startTime,
			endTime = endTime,
			lifeTime = lifeTime,
			startSize = startSize,
			endSize = endSize,
			startYellowness = startYellowness,
			endYellowness = endYellowness,
			blue = blue,
			brightness = brightness,
			dieTime = dieTime,
			lightID = vFireLightAttachID
		}

		dynamicLightStep(context)

		hook.Add("Think", context, dynamicLightStep)

		vFireLightAttachID = vFireLightAttachID + 1
	end

	--[[-------------------------------------------------------------------------
	Create a glow sprite
	---------------------------------------------------------------------------]]
	local glowSpriteMat = Material("sprites/physg_glow1")
	local glowSpriteMatNoZ = Material("sprites/light_ignorez")
	local function glowSpriteValid(c)
		if CurTime() > c.endTime then return false end
		if c.isEntity and !IsValid(c.follow) then return false end
		return true
	end
	local function glowSpriteStep(c)

		local attachPos
		if !c.isEntity then
			attachPos = c.follow
		else
			attachPos = c.follow:GetPos()
		end

		local curTime = CurTime()
		local frac = (c.endTime - curTime) / (c.lifeTime)
		local fracRev = 1 - frac

		local alpha = c.startAlpha * frac + c.endAlpha * fracRev
		local yellowness = c.startYellowness * frac + c.endYellowness * fracRev
		local glowCol = Color(255, yellowness, c.blue, alpha)
		local glowSize = c.startSize * frac + c.endSize * fracRev

		if c.pixvis then
			local vis = util.PixelVisible(attachPos, 1, c.pixvis)
			if vis <= 0 then return end
			glowSize = glowSize * vis
			render.SetMaterial(glowSpriteMatNoZ)
		else
			render.SetMaterial(glowSpriteMat)
		end
		render.DrawSprite(attachPos, glowSize, glowSize, glowCol)
	end
	function CreateVFireGlowSprite(follow, lifeTime, startSize, endSize, startAlpha, endAlpha, startYellowness, endYellowness, blue, drawThroughEffects, usePixVis)

		local isEntity = isentity(follow) -- If we're not an entity we assume to be a position

		local startTime = CurTime()
		local endTime = startTime + lifeTime

		local pixvis
		if usePixVis then
			pixvis = util.GetPixelVisibleHandle()
		end

		local context = {
			IsValid = glowSpriteValid,
			isEntity = isEntity,
			follow = follow,
			startTime = startTime,
			endTime = endTime,
			lifeTime = lifeTime,
			startSize = startSize,
			endSize = endSize,
			startAlpha = startAlpha,
			endAlpha = endAlpha,
			startYellowness = startYellowness,
			endYellowness = endYellowness,
			blue = blue,
			pixvis = pixvis
		}

		if drawThroughEffects then
			hook.Add("PostDrawTranslucentRenderables", context, glowSpriteStep)
		else
			hook.Add("PreDrawTranslucentRenderables", context, glowSpriteStep)
		end
	end


	--[[-------------------------------------------------------------------------
	Creates a smoke ball
	---------------------------------------------------------------------------]]
	function CreateCSVFireSmokeBall(pos, vel, lifeTime, rate, startRadius, endRadius, startLength, endLength, gravity, resist, roll, minBright, maxBright, minAlpha, maxAlpha)
		local dummy = CreateCSVFirePhysDummy(pos, vel, lifeTime)
		
		CreateVFireSmokeTrail(
			dummy, -- Entity,
			lifeTime, -- Emission lifetime
			rate, -- Rate
			startRadius, -- Start radius
			endRadius,  -- End radius
			startLength, -- Length
			endLength,
			gravity, -- Gravity
			resist, -- Resistance
			roll,
			minBright,
			maxBright,
			minAlpha, -- Alpha
			maxAlpha
		)

		return dummy
	end

	--[[-------------------------------------------------------------------------
	Creates a fire ball
	---------------------------------------------------------------------------]]
	function CreateCSVFireBall(life, pos, vel, lifeTime, canLOD)

		local dummy = CreateCSVFirePhysDummy(pos, vel, lifeTime)

		-- Don't continue if we're underwater (if we can even tell at this point)
		if dummy:WaterLevel() > 0 then dummy:Remove() return end

		CreateVFireTrail(dummy, life, 0, lifeTime, canLOD)

		return dummy
	end


	--[[-------------------------------------------------------------------------
	Creates a non-physical mushroom explosion effect
	---------------------------------------------------------------------------]]
	local mushRoomID = 0
	function CreateVFireMushroom(pos, levels, ranDelay, spread, smokeFactor, startVel, span)

		if levels <= 0 then return end

		mushRoomID = mushRoomID + 1
		local timerID = "vFireMushroom"..mushRoomID

		if !startVel then startVel = VectorRand() end

		local follow = pos
		local startLife = vFireMaxLife
		local endLife = vFireMaxLife
		local lifeTime = 0.2 + math.Rand(0, ranDelay)
		local canLOD = true
		CreateVFireTrail(follow, startLife, endLife, lifeTime, canLOD)

		if math.Rand(0, 1) < smokeFactor / levels then
			CreateVFireSmokeTrail(
				follow, -- Entity,
				lifeTime, -- Emission lifetime (how long will we be emitting smoke?)
				1, -- Rate
				1000, -- Start radius
				100,  -- End radius
				lifeTime * 10, -- Start Length (what is the lifetime of new particles?)
				0.5, -- End Length (what is the lifetime of old particles?)
				vFireGetWindVector() * math.Rand(1, 5) + Vector(0, 0, math.Rand(2, 6)), -- Gravity
				1, -- Resistance
				0.5, -- Roll
				0, -- Brightness
				100,
				60, -- minAlpha
				255 -- maxAlpha
			)
		end

		levels = levels - 1
		if levels <= 0 then return end

		local size = 300 + 150 * levels
		timer.Simple(math.Rand(0, ranDelay), function()
			local newPos = follow + startVel * size
			local ranVector, ranVector2, newVel, newVel2
			if span then
				ranVector = Vector(span.x * math.Rand(-1, 1), span.y * math.Rand(-1, 1), span.z * math.Rand(-1, 1))
				ranVector2 = Vector(span.x * math.Rand(-1, 1), span.y * math.Rand(-1, 1), span.z * math.Rand(-1, 1))
				ranVector:Normalize()
				ranVector2:Normalize()
			else
				ranVector = VectorRand()
				ranVector2 = VectorRand()
			end
			local newVel = (startVel + ranVector * spread) / (1 + spread)
			local newVel2 = (startVel + ranVector2 * spread) / (1 + spread)
			local newSpread = spread * 0.9
			CreateVFireMushroom(newPos, levels, ranDelay, newSpread, smokeFactor, newVel, span)
			CreateVFireMushroom(newPos, levels - 1, ranDelay, newSpread, smokeFactor, newVel2, span)
		end)
	end

	-- Some old shit
	function CreateVFireExplosionEffect(pos, magnitude)

		local magnitudeSqrd = magnitude * magnitude

		local canLOD = true

		-- Radiating balls

		for i = 1, math.random(1, 4) * magnitude do
			local life = math.Rand(1, 5) * magnitudeSqrd
			local vel = VectorRand() * (50 + math.Rand(90, 325) * magnitude)
			local lifeTime = 0.3 + math.Rand(0.05, 0.3) * magnitude
			CreateCSVFireBall(life, pos, vel, lifeTime, canLOD)
		end

		-- Center explosion ball

		local life = magnitudeSqrd * math.Rand(40, 150)
		local vel = VectorRand() * math.Rand(0, 30)
		local lifeTime = math.Rand(0.6, 1.8) + 0.4 * magnitude
		CreateCSVFireBall(life, pos, vel, lifeTime, canLOD)


		-- Play a sound that reflects the stack
		-- local sndID = math.random(1, math.Min(6, magnitude))
		-- local sndStr = "ambient/explosions/explode_"..sndID..".wav"
		-- sound.Play(
		-- 	sndStr,								-- Sound
		-- 	pos,								-- Position
		-- 	90 + 5 * magnitude,					-- Level
		-- 	math.Max(140 - magnitude * 20, 40),	-- Pitch
		-- 	1									-- Volume
		-- )
	end

	--[[-------------------------------------------------------------------------
	In charge of creating smoke plume effects
	---------------------------------------------------------------------------]]
	function CreateVFireSmokePlume(pos, dir, magnitude, entity)
		local effectData = EffectData()
			effectData:SetOrigin(pos)
			effectData:SetNormal(dir)
			effectData:SetMagnitude(magnitude)
			effectData:SetEntity(entity)
		util.Effect("vfire_smoke_plume", effectData, true, true)
	end

end
