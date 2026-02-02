--[[-------------------------------------------------------------------------
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

vFire by Vioxtar

<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
---------------------------------------------------------------------------]]



--[[-------------------------------------------------------------------------


Fire Related Overrides


---------------------------------------------------------------------------]]

local entMeta = FindMetaTable("Entity")

--[[-------------------------------------------------------------------------
IsOnFire Override
---------------------------------------------------------------------------]]
local oldIsOnFire = entMeta.IsOnFire
entMeta.IsOnFire = function(ent)
	if vFireIsVFireEnt(ent) then return true end
	if ent.fires then
		if table.Count(ent.fires) > 0 then return true end
	end
	return oldIsOnFire(ent)
end

if SERVER then
	--[[-------------------------------------------------------------------------
	Ignite Override
	---------------------------------------------------------------------------]]
	local vFireIgniteOverrideEnabled = true
	function vFireGetIgniteOverride()
		return vFireIgniteOverrideEnabled
	end
	function vFireIgniteOverride(enabled)
		vFireIgniteOverrideEnabled = enabled
	end

	-- Ignite throttle factors
	local igniteThrottle = 0
	local igniteUnThrottleTime = 1
	local igniteLimit = 15

	local oldIgnite = entMeta.Ignite
	entMeta.Ignite = function(ent, time, radius)

		-- Should we override ignite behavior?
		if vFireGetIgniteOverride() then -- We should

			-- Some addons actually try to ignite the world...
			if not IsValid(ent) then return end
			if ent:IsWorld() then return end
			
			local igniteSuccessful = false
			
			if igniteThrottle < igniteLimit then

				local count = 5

				-- Only create fires if we're not burning enough
				count = count - table.Count(ent.fires or {})
				if count > 0 then

					if vFireIsCharacter(ent) then

						for i = 1, count do
							CreateVFire(ent, ent:GetPos(), VectorRand(), 70)
						end
						igniteSuccessful = true

					else

						igniteSuccessful = CreateVFireEntFires(ent, count)

					end

				end

				if isnumber(radius) then
					if radius > 0 then
						for _, closeEnt in pairs(ents.FindInSphere(ent:GetPos(), radius)) do
							closeEnt:Ignite(time, 0)
						end
					end
				end

			end

			-- Throttle our next ignite calls - we need to do this because a lot of addons like to ignite
			-- a lot of entities at once, and we need to avoid immense lag
			if igniteSuccessful then
				igniteThrottle = igniteThrottle + 1
				timer.Simple(igniteUnThrottleTime, function()
					igniteThrottle = math.Max(igniteThrottle - 1, 0)
				end)
			end

		else -- We're not overriding the ignite function
			-- Trigger the old function, default fire is suppressed by other means
			oldIgnite(ent, time, radius)
			return
		end
	end

	--[[-------------------------------------------------------------------------
	Extinguish Override
	---------------------------------------------------------------------------]]
	local oldExtinguish = entMeta.Extinguish
	entMeta.Extinguish = function(ent)
		
		if vFireIsVFireEnt(ent) then
			if ent:GetClass() == "vfire" then
				ent:ChangeLife(0)
			elseif ent:GetClass() == "vfire_ball" then
				ent:ChangeLife(0)
			end

			return
		end


		if ent.fires then
			for fire, lPos in pairs(ent.fires) do
				if IsValid(fire) then
					fire:Remove()
				end
			end
		end

		-- Nothing bad happens if we also call the normal extinguish function
		oldExtinguish(ent)

	end
end









--[[-------------------------------------------------------------------------


A set of hooks and behavior logic to alter the game in favor of vFires


---------------------------------------------------------------------------]]

if SERVER then

	local defaultFireRemoveTime = 0.1


	--[[-------------------------------------------------------------------------
	
	Hooks to suppress default ignites as much as possible
	
	---------------------------------------------------------------------------]]
	hook.Add("EntityEmitSound", "vFireSuppressDefaultIngiteSound", function(data)
		-- If we're not overriding, then do nothing (current disabled because default fire sounds have weird activations)
		-- if !vFireGetIgniteOverride() then return end
		
		local ent = data.Entity
		if IsValid(ent) then
			if ent:GetClass() == "entityflame" then return false end
		end
	end)
	hook.Add("OnEntityCreated", "vFireRemoveDefaultFires", function(oldFire)
		-- If we're not overriding, then do nothing
		if !vFireGetIgniteOverride() then return end

		if oldFire:GetClass() != "entityflame" then return end
		timer.Simple(defaultFireRemoveTime, function()
			if IsValid(oldFire) then
				oldFire:Remove()
			end
		end)
	end)




	--[[-------------------------------------------------------------------------
	Have fires fall off of dying players
	---------------------------------------------------------------------------]]
	hook.Add("PlayerDeath", "vFireDropFiresFromPlayer", function(ply)
		if ply.fires then
			for fire, pos in pairs(ply.fires) do
				if IsValid(fire) then
					local fireBall = fire:Drop()
					if !IsValid(fireBall) then
						fire:Remove()
					end
				end
			end
		end
	end)

	--[[-------------------------------------------------------------------------
	Make sure players are no longer buning after a respawn
	---------------------------------------------------------------------------]]
	hook.Add("PlayerSpawn", "vFireRemoveFiresFromPlayer", function(ply)
		if ply.fires then
			for fire, pos in pairs(ply.fires) do
				fire:Remove()
			end
		end
	end)

	--[[-------------------------------------------------------------------------
	Handle fires of a burning NPC's death
	---------------------------------------------------------------------------]]
	hook.Add("OnNPCKilled", "vFireDropFiresFromNPC", function(npc, attacker, inflictor)
		if npc.fires then
			for fire, pos in pairs(npc.fires) do
				if IsValid(fire) then
					local fireBall = fire:Drop()
					if IsValid(fireBall) then
						fireBall:Ignore(npc)
					else
						fire:Remove()
					end
				end
			end
		end
	end)

	--[[-------------------------------------------------------------------------
	Handle fires on props that break
	---------------------------------------------------------------------------]]
	hook.Add("PropBreak", "vFireDropFiresFromProp", function(attacker, prop)
		if prop.fires then
			for fire, pos in pairs(prop.fires) do
				if IsValid(fire) then
					-- We'd like to 'reward' the fire's life for breaking the prop
					fire:ChangeLife(fire.life * 1.15)
					
					fire:Drop()
				end
			end
		end
	end)




	--[[-------------------------------------------------------------------------
	Fix fire dependent entities' behaviors, for instance:
	Explosive barrels rely on being ignited to explode after damaged by an explosion themselves
	Because vFire removes default fires, we need to encourage more chain explosions
	---------------------------------------------------------------------------]]
	hook.Add("EntityTakeDamage", "vFireFixExplosion", function(ent, dmg)

		if hook.Call("vFireSuppressExplosionBehavior") then return end

		if !dmg:IsExplosionDamage() then return end
		local hp = ent:Health()
		if hp < dmg:GetDamage() and hp > 0 then
			if math.random(1, 3) == 1 then
				ent:SetHealth(0)
			end
		end
	end)





	--[[-------------------------------------------------------------------------
	Create fire balls from explosions
	---------------------------------------------------------------------------]]
	hook.Add("AcceptInput", "vFireFireBallByExplosion", function(explosion, name)
		if explosion:GetClass() != "env_explosion" then return end
		if !vFireEnableExplosionFires then return end
		if name != "Explode" then return end -- Sometimes env_explosions don't directly mean explosions happen

		if hook.Call("vFireSuppressExplosionBehavior") then return end

		-- Let the explosion settle in its position
		timer.Simple(0, function()

			if !IsValid(explosion) then return end

			local count
			if game.SinglePlayer() then
				count = math.random(3, 5)
			else
				count = math.random(2, 3)
			end

			local pos = explosion:GetPos()

			for i = 1, count do
				local life = math.Rand(10, 50)
				local feed = life / 200
				if math.random(1, 10) == 1 then
					feed = feed * 6
				end
				-- The bigger the fire the smaller the reach
				local vel = VectorRand() * math.Rand(20000, 80000) / life
				CreateVFireBall(life, feed, pos, vel)
			end

			-- We'd also like to send clients information about the explosion so they can stack them
			-- if vFireEnableExplosionEffects then
			-- 	local plyCnt = player.GetCount()
			-- 	if plyCnt > 0 then
			-- 		net.Start("vFireExplosion")
			-- 			net.WriteVector(pos)
			-- 		net.SendPVS(pos)
			-- 	end
			-- end

		end)
	end)


	--[[-------------------------------------------------------------------------
	Support ignite calls via inputs
	---------------------------------------------------------------------------]]
	hook.Add("AcceptInput", "vFireIgniteByInput", function(ent, name)
		if (name != "Ignite") then return end
		vFireIgniteOverride(true)
		ent:Ignite()
	end)



	--[[-------------------------------------------------------------------------
	

	NPC Behaviors
	

	---------------------------------------------------------------------------]]


	--[[-------------------------------------------------------------------------
	NPC on fire behaviors
	---------------------------------------------------------------------------]]
	local NPCOnFireActs = {
		-- 3,
		-- 4,
		-- 5,
		-- 6,
		-- 8,
		-- 10, -- ACT_RUN
		-- 12,
		-- 14,
		-- 23,
		-- 41,
		-- 42,
		61, -- ACT_COWER
		-- 62,
		-- 63,
		-- 72,
		-- 78,
		-- 79,
		-- 81,
		-- 83, -- ACT_WALK_STIMULATED
		-- 84, -- ACT_WALK_AGITATED
		-- 87, -- ACT_RUN_STIMULATED
		-- 88, -- ACT_RUN_AGITATED
		-- 105, -- ACT_WALK_HURT
		-- 106, -- ACT_RUN_HURT
		-- 111, -- ACT_RUN_SCARED
		-- 117,
		-- 118,
		-- 119,
		-- 120,
		-- 121,
		-- 122,
		-- 123,
		-- 124,
		125, -- ACT_IDLE_ON_FIRE
		126, -- ACT_WALK_ON_FIRE
		127, -- ACT_RUN_ON_FIRE
		-- 144,
		-- 145,
		-- 146,
		-- 147,
		-- 148,
		-- 149,
		-- 150,
		-- 151,
		-- 152,
		-- 153,
		-- 154,
		-- 155,
		-- 156,
		-- 428,
		-- 429,
		-- 430,
		-- 435,
		-- 436,
		-- 437,
		-- 1930,
		-- 1932,
		-- 1933,
		-- 1934
	}

	local NPCClassAvailableFireActs = {}

	function StopNPCBurningBehavior(npc)
		npc:SetSchedule(0)
	end

	function NPCBurningBehavior(npc, behavior, fireAct)
		if !IsValid(npc) then return end
		if !npc.isBurning then return end
		if !vFireEnableNPCBehavior then return end

		local nextCall = 3.5

		
		if behavior == 1 then

			--[[-------------------------------------------------------------------------
			Run around to random positions
			---------------------------------------------------------------------------]]

			-- Can't aim well when you're burning alive
			npc:SetCurrentWeaponProficiency(1)

			if math.random(1, 8) == 1 then
				-- Have the NPC walk backwards in a retarded manner
				npc:SetEnemy(npc)
			end
			
			-- Play a death sound
			if math.random(1, 3) == 1 then
				npc:SetSchedule(SCHED_DIE_RAGDOLL)
			end

			-- Run around
			timer.Simple(0.1, function()
				if !IsValid(npc) then return end
				npc:SetSchedule(SCHED_RUN_RANDOM)
			end)

			nextCall = math.Rand(1, 2)

		elseif behavior == 2 then

			--[[-------------------------------------------------------------------------
			Utilize default ignition behavior
			---------------------------------------------------------------------------]]
			
			if !npc.lastSound or math.random(1, 10) == 1 then -- The NPC is silent, play a dying sound every once in a while
				npc:SetSchedule(SCHED_DIE_RAGDOLL)
			end

			timer.Simple(0.1, function()
				if !IsValid(npc) then return end
				npc:SetSchedule(77)

				vFireIgniteOverride(false)
					npc:Ignite(defaultFireRemoveTime)
				vFireIgniteOverride(true)
				
			end)

			nextCall = math.Rand(3, 14)

		elseif behavior == 3 then

			--[[-------------------------------------------------------------------------
			Do a fire act animation - currently disabled
			---------------------------------------------------------------------------]]

			-- Play a death sound
			if math.random(1, 1) == 1 then
				npc:SetSchedule(SCHED_DIE_RAGDOLL)
			end

			timer.Simple(0.1 , function()

				if !IsValid(npc) then return end

				-- Perform a fire act
				local class = npc:GetClass()
				-- Every class will have its own subset of availabe fire acts, find them and use them
				if !NPCClassAvailableFireActs[class] then
					local availableFireActs = {}
					for k, actID in pairs(NPCOnFireActs) do
						local seqID = npc:SelectWeightedSequence(actID)
						if seqID != -1 then
							availableFireActs[#availableFireActs + 1] = {actID, seqID}
						end
					end
					NPCClassAvailableFireActs[class] = availableFireActs
				end

				if !fireAct then fireAct = table.Random(NPCClassAvailableFireActs[class]) end

				if fireAct then
					local actID = fireAct[1]
					local seqID = fireAct[2]

					npc:SetMovementActivity(actID)
					npc:SetMovementSequence(seqID)

				end
			end)

			nextCall = math.Rand(1, 2)

		end

		-- Have a slight chance of changing the behavior
		-- if math.random(1, 4) == 1 then
			-- behavior = math.random(1, 2)
			-- if behavior != 3 then fireAct = nil end
		-- end
		-- Start a timed loop while the NPC is burning
		timer.Simple(nextCall, function()
			NPCBurningBehavior(npc, behavior, fireAct)
		end)
	end

	local defaultNPCs = {}
	defaultNPCs["npc_crow"] = true
	defaultNPCs["npc_monk"] = true
	defaultNPCs["npc_pigeon"] = true
	defaultNPCs["npc_seagull"] = true
	defaultNPCs["npc_cscanner"] = true
	defaultNPCs["npc_combinedropship"] = true
	defaultNPCs["npc_combine_s"] = true
	defaultNPCs["npc_combinegunship"] = true
	defaultNPCs["npc_hunter"] = true
	defaultNPCs["npc_helicopter"] = true
	defaultNPCs["npc_manhack"] = true
	defaultNPCs["npc_metropolice"] = true
	defaultNPCs["npc_rollermine"] = true
	defaultNPCs["npc_clawscanner"] = true
	defaultNPCs["npc_stalker"] = true
	defaultNPCs["npc_strider"] = true
	defaultNPCs["bullseye_strider_focus"] = true
	defaultNPCs["npc_turret_floor"] = true
	defaultNPCs["npc_alyx"] = true
	defaultNPCs["npc_barney"] = true
	defaultNPCs["npc_citizen"] = true
	defaultNPCs["npc_dog"] = true
	defaultNPCs["npc_magnusson"] = true
	defaultNPCs["npc_kleiner"] = true
	defaultNPCs["npc_mossman"] = true
	defaultNPCs["npc_eli"] = true
	defaultNPCs["npc_gman"] = true
	defaultNPCs["npc_vortigaunt"] = true
	defaultNPCs["npc_breen"] = true
	defaultNPCs["npc_antlion"] = true
	defaultNPCs["npc_antlionguard"] = true
	defaultNPCs["npc_antlion_worker"] = true
	defaultNPCs["npc_headcrab_fast"] = true
	defaultNPCs["npc_fastzombie"] = true
	defaultNPCs["npc_fastzombie_torso"] = true
	defaultNPCs["npc_headcrab"] = true
	defaultNPCs["npc_headcrab_black"] = true
	defaultNPCs["npc_poisonzombie"] = true
	defaultNPCs["npc_headcrab_poison"] = true
	defaultNPCs["npc_zombie"] = true
	defaultNPCs["npc_zombie_torso"] = true
	defaultNPCs["npc_zombine"] = true

	local function shouldDoBehavior(npc)
		if !IsValid(npc) then return false end
		if npc.vFireCustomBehavior != nil then return npc.vFireCustomBehavior end
		local class = npc:GetClass()
		
		npc.vFireCustomBehavior = defaultNPCs[class] or false
		
		return npc.vFireCustomBehavior
	end

	hook.Add("vFireEntityStoppedBurning", "vFireStopNPCBurningBehavior", function(npc)
		if !IsValid(npc) then return end
		if !npc:IsNPC() then return end
		if !vFireEnableDamage then return end
		if !vFireEnableNPCBehavior then return end
		if !shouldDoBehavior(npc) then return end

		npc.isBurning = false
		StopNPCBurningBehavior(npc)
	end)
	
	hook.Add("vFireEntityStartedBurning", "vFireStartNPCBurningBehavior", function(npc)
		if !IsValid(npc) then return end
		if !npc:IsNPC() then return end
		if !vFireEnableDamage then return end
		if !vFireEnableNPCBehavior then return end
		if !shouldDoBehavior(npc) then return end
		
		npc.isBurning = true

		-- Choose a random behavior and start behavior loop
		local behavior = 2
		NPCBurningBehavior(npc, behavior)
	end)

end