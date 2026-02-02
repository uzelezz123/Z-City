--[[-------------------------------------------------------------------------
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

		vFire by Vioxtar

<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
---------------------------------------------------------------------------]]



--[[-------------------------------------------------------------------------
vFire Globals
---------------------------------------------------------------------------]]
vFireMaxState = 7

local lifeBase = 2.295 -- Originally 2.5
vFireMaxLife = lifeBase^vFireMaxState

vFireStatesLifeThresholds = {}
	vFireStatesLifeThresholds[1] = lifeBase^1 -- or lower is state 1 else
	vFireStatesLifeThresholds[2] = lifeBase^2 -- or lower is state 2 else
	vFireStatesLifeThresholds[3] = lifeBase^3 -- or lower is state 3 else
	vFireStatesLifeThresholds[4] = lifeBase^4 -- or lower is state 4 else
	vFireStatesLifeThresholds[5] = lifeBase^5 -- or lower is state 5 else
	vFireStatesLifeThresholds[6] = lifeBase^6 -- or lower is state 6 else
	vFireStatesLifeThresholds[7] = vFireMaxLife -- or lower is state 7

vFireStateToSizeTable = {}
	vFireStateToSizeTable[1] = "Tiny"
	vFireStateToSizeTable[2] = "Small"
	vFireStateToSizeTable[3] = "Medium"
	vFireStateToSizeTable[4] = "Big"
	vFireStateToSizeTable[5] = "Huge"
	vFireStateToSizeTable[6] = "Gigantic"
	vFireStateToSizeTable[7] = "Inferno"

vFireClusterSize = 400

vFireDummyModel = "models/hunter/plates/plate.mdl"
util.PrecacheModel(vFireDummyModel)

function vFireStateToSize(state)
	local size = vFireStateToSizeTable[state] or "Tiny"
	return size
end

function vFireLifeToState(life)
	local stateReturn = vFireMaxState
	for stateIndex, lifeThreshold in pairs(vFireStatesLifeThresholds) do
		if life <= lifeThreshold then
			stateReturn = stateIndex
			return stateReturn
		end
	end
	return stateReturn
end

function vFireStateToLife(state)
	return vFireStatesLifeThresholds[state]
end

-- Helper used to determine if we're burning a character or not
function vFireIsCharacter(ent)
	if !IsValid(ent) then return false end
	if ent.vFireIsCharacter != nil then return ent.vFireIsCharacter end
	local isCharacter = ent:IsRagdoll() or ent:IsNPC() or ent:IsPlayer()
	ent.vFireIsCharacter = isCharacter
end

function vFireIsMobile(ent)
	local parent = ent.parent
	if !IsValid(parent) then return false end
	return (parent == NULL or !parent:IsWorld())
end

-- Helper used to determine if an entity is ours or not
function vFireIsVFireEnt(ent)
	if !IsValid(ent) then return false end
	if ent.vFireIsVFireEnt != nil then return ent.vFireIsVFireEnt end
	
	local c = ent:GetClass()
	local isVFireEnt = c == "vfire" or c == "vfire_ball" or c == "vfire_cluster"
	ent.vFireIsVFireEnt = isVFireEnt
	return isVFireEnt
end

local baseRadius = {10, 30, 50, 80, 125, 230, 390}
function vFireBaseRadius(state)
	return baseRadius[state]
end

function vFireGetFires(ent)
	local fires = {}
	local firesTable = ent.fires
	if firesTable then
		for fire, lPos in pairs(firesTable) do 
			table.insert(fires, fire)
		end
	end
	return fires
end

--[[-------------------------------------------------------------------------
Burning Entities Tracking
---------------------------------------------------------------------------]]
local burningEntities = {}
function vFireGetBurningEntities()
	return table.Copy(burningEntities)
end
hook.Add("vFireEntityStartedBurning", "vFireAddBurningEntity", function(ent)
	burningEntities[ent] = ent
end)
hook.Add("vFireEntityStoppedBurning", "vFireRemBurningEntity", function(ent)
	if burningEntities[ent] then
		burningEntities[ent] = nil
	end
end)

--[[-------------------------------------------------------------------------
vFiresCount Tracking
---------------------------------------------------------------------------]]
vFiresCount = 0
hook.Add("vFireCreated", "vFiresCountIncrement", function(fire)
	-- Update vFiresCount
	vFiresCount = vFiresCount + 1

	-- Update whatever else we need to update
	vFireUpdateThinkThrottle()
	
	if SERVER then
		vFireUpdateLifeThrottle()
	end
end)

hook.Add("vFireRemoved", "vFiresCountDecrement", function(fire)
	-- Update vFiresCount
	vFiresCount = math.Max(vFiresCount - 1, 0)

	-- Update whatever else we need to update
	vFireUpdateThinkThrottle()
	
	if SERVER then
		vFireUpdateLifeThrottle()
	end
end)


--[[-------------------------------------------------------------------------
Tickrates Management
---------------------------------------------------------------------------]]
if CLIENT then
	vFireClusterThinkTickRate = 5
	vFireParticlesThinkTickRate = 1.15
	vFireAnimationThinkTickRate = 15
	
	vFireThrottleMultiplier = 0.01
	vFireThinkThrottle = 0
	function vFireUpdateThinkThrottle()
		vFireThinkThrottle = vFiresCount * vFireThrottleMultiplier
	end
end

if SERVER then
	vFireFuelThinkTickRate = 2
	vFireLifeThinkTickRate = 1.15
	vFireEatThinkTickRate = 2
	vFireBurnThinkTickRate = 2
	vFireDropThinkTickRate = 3
	vFireSpreadThinkTickRate = 0.5

	vFireThrottleMultiplier = 0.1
	vFireThinkThrottle = 0
	vFireMaxThinkThrottle = 30 -- Cap the throttling to avoid non-thinking fires (bad at performance heavy scenarios)
	function vFireUpdateThinkThrottle()
		vFireThinkThrottle = math.min(vFiresCount * vFireThrottleMultiplier, vFireMaxThinkThrottle)
	end
end













--[[-------------------------------------------------------------------------
ConVars
---------------------------------------------------------------------------]]
if CLIENT or SERVER then
	--[[-------------------------------------------------------------------------
	Wind functionalities
	---------------------------------------------------------------------------]]
	local windVec = Vector(0.7, -1, 0)
	windVec:Normalize()
	function vFireGetWindVector()
		return windVec
	end

	-- Used to calcualte the wind flow of a given position
	local windExposureCheckDist = 10000
	function vFireCalcWindExposure(pos, filter)
		return 1
	end

	--[[-------------------------------------------------------------------------
	Smoke functionalities
	---------------------------------------------------------------------------]]
	local vFireEnableSmokeConVar = CreateConVar("vfire_enable_smoke", "1", FCVAR_REPLICATED + FCVAR_SERVER_CAN_EXECUTE, "Enables fire smoke.")
	vFireEnableSmoke = vFireEnableSmokeConVar:GetBool()
	cvars.AddChangeCallback("vfire_enable_smoke", function(convar, old, new)
		vFireEnableSmoke = vFireEnableSmokeConVar:GetBool()
	end)
end

if CLIENT then
	--[[-------------------------------------------------------------------------
	Toggle fire LODs
	---------------------------------------------------------------------------]]
	local vFireLODsConVar = CreateClientConVar("vfire_lod", "1", true, false, "Set to 0 to disable all fire LODs, 1 for automatic LODs, and 2 to force LODs on.")
	vFireLODs = vFireLODsConVar:GetInt()
	cvars.AddChangeCallback("vfire_lod", function(convar, old, new)
		vFireLODs = math.Clamp(vFireLODsConVar:GetInt(), 0, 2)
	end)

	
	--[[-------------------------------------------------------------------------
	Toggle fire glows
	---------------------------------------------------------------------------]]
	local vFireEnableGlowsConVar = CreateClientConVar("vfire_enable_glows", "1", true, false, "Set to 0 to disable fire glow effects.")
	vFireEnableGlows = vFireEnableGlowsConVar:GetBool()
	cvars.AddChangeCallback("vfire_enable_glows", function(convar, old, new)
		vFireEnableGlows = vFireEnableGlowsConVar:GetBool()
	end)


	--[[-------------------------------------------------------------------------
	Toggle fire dynamic lights
	---------------------------------------------------------------------------]]
	local vFireEnableLightsConVar = CreateClientConVar("vfire_enable_lights", "1", true, false, "Set to 0 to disable all fire light effects for increased performance at the cost of visual fidelity.")
	vFireEnableLights = vFireEnableLightsConVar:GetBool()
	cvars.AddChangeCallback("vfire_enable_lights", function(convar, old, new)
		vFireEnableLights = vFireEnableLightsConVar:GetBool()
	end)


	--[[-------------------------------------------------------------------------
	Set fire light brightness
	---------------------------------------------------------------------------]]
	local vFireLightMulConVar = CreateClientConVar("vfire_light_brightness", "0.4", true, false, "Set the fire light brightness multiplier.")
	vFireLightMul = vFireLightMulConVar:GetFloat()
	cvars.AddChangeCallback("vfire_light_brightness", function(convar, old, new)
		vFireLightMul = vFireLightMulConVar:GetFloat()
	end)




	--[[-------------------------------------------------------------------------
	Reset all ConVars
	---------------------------------------------------------------------------]]
	concommand.Add("vfire_default_visual_settings", function()
		vFireLODsConVar:SetBool(vFireLODsConVar:GetDefault())
		vFireEnableGlowsConVar:SetBool(vFireEnableGlowsConVar:GetDefault())
		vFireEnableLightsConVar:SetBool(vFireEnableLightsConVar:GetDefault())
		vFireLightMulConVar:SetFloat(vFireLightMulConVar:GetDefault())
		vFireMessage("vFire client settings reset to default!")
	end)
end

if SERVER then
	--[[-------------------------------------------------------------------------
	Set throttle multiplier
	---------------------------------------------------------------------------]]
	local vFireThrottleMultiplierConVar = CreateConVar("vfire_throttle_multiplier", tostring(vFireThrottleMultiplier), FCVAR_ARCHIVE, "Performance Warning: advanced setting, may result in unexpected behavior! Set the fire throttle multiplier - lower values will result in more responsive fires at the cost of performance.")
	vFireThrottleMultiplier = vFireThrottleMultiplierConVar:GetFloat()
	cvars.AddChangeCallback("vfire_throttle_multiplier", function(convar, old, new)
		vFireThrottleMultiplier = vFireThrottleMultiplierConVar:GetFloat()
		vFireUpdateThinkThrottle()
	end)


	--[[-------------------------------------------------------------------------
	Toggle fire damage
	---------------------------------------------------------------------------]]
	local vFireEnableDamageConVar = CreateConVar("vfire_enable_damage", "1", FCVAR_ARCHIVE, "Set to 0 to disable fire damage.")
	vFireEnableDamage = vFireEnableDamageConVar:GetBool()
	cvars.AddChangeCallback("vfire_enable_damage", function(convar, old, new)
		vFireEnableDamage = vFireEnableDamageConVar:GetBool()
	end)

	
	--[[-------------------------------------------------------------------------
	Toggle fire damage for players in vehicles
	---------------------------------------------------------------------------]]
	local vFireEnableDamageInVehiclesConVar = CreateConVar("vfire_enable_damage_in_vehicles", "0", FCVAR_ARCHIVE, "Set to 1 to enable fire damage to players inside vehicles.")
	vFireEnableDamageInVehicles = vFireEnableDamageInVehiclesConVar:GetBool()
	cvars.AddChangeCallback("vfire_enable_damage_in_vehicles", function(convar, old, new)
		vFireEnableDamageInVehicles = vFireEnableDamageInVehiclesConVar:GetBool()
	end)


	--[[-------------------------------------------------------------------------
	Set fire damage multiplier
	---------------------------------------------------------------------------]]
	local vFireDamageMultiplierConVar = CreateConVar("vfire_damage_multiplier", "1", FCVAR_ARCHIVE, "Set the damage multiplier for fires, 0 disables all damage.")
	vFireDamageMultiplier = 2.5
	cvars.AddChangeCallback("vfire_damage_multiplier", function(convar, old, new)
		vFireDamageMultiplier = vFireDamageMultiplierConVar:GetFloat()
	end)


	--[[-------------------------------------------------------------------------
	Toggle explosion fire balls
	---------------------------------------------------------------------------]]
	local vFireEnableExplosionFiresConVar = CreateConVar("vfire_enable_explosion_fires", "1", FCVAR_ARCHIVE, "Set to 0 to disable explosion fires.")
	vFireEnableExplosionFires = vFireEnableExplosionFiresConVar:GetBool()
	cvars.AddChangeCallback("vfire_enable_explosion_fires", function(convar, old, new)
		vFireEnableExplosionFires = vFireEnableExplosionFiresConVar:GetBool()
	end)


	--[[-------------------------------------------------------------------------
	Toggle enhanced explosion effects
	---------------------------------------------------------------------------]]
	local vFireEnableExplosionEffectsConVar = CreateConVar("vfire_enable_explosion_effects", "1", FCVAR_ARCHIVE, "Set to 0 to disable fancy explosion effects.")
	vFireEnableExplosionEffects = vFireEnableExplosionEffectsConVar:GetBool()
	cvars.AddChangeCallback("vfire_enable_explosion_effects", function(convar, old, new)
		vFireEnableExplosionEffects = vFireEnableExplosionEffectsConVar:GetBool()
	end)


	--[[-------------------------------------------------------------------------
	Toggle fire decals
	---------------------------------------------------------------------------]]
	local vFireEnableDecalsConVar = CreateConVar("vfire_enable_decals", "1", FCVAR_ARCHIVE, "Set to 0 to disable fire decals.")
	vFireEnableDecals = vFireEnableDecalsConVar:GetBool()
	cvars.AddChangeCallback("vfire_enable_decals", function(convar, old, new)
		vFireEnableDecals = vFireEnableDecalsConVar:GetBool()
	end)


	--[[-------------------------------------------------------------------------
	Set fire decal probability
	---------------------------------------------------------------------------]]
	local vFireDecalProbabilityConVar = CreateConVar("vfire_decal_probability", "0.4", FCVAR_ARCHIVE, "Set the probability (a value between 0 and 1) of creating fire decals.")
	vFireDecalProbability = vFireDecalProbabilityConVar:GetFloat()
	cvars.AddChangeCallback("vfire_decal_probability", function(convar, old, new)
		vFireDecalProbability = vFireDecalProbabilityConVar:GetFloat()
	end)


	--[[-------------------------------------------------------------------------
	Toggle fire spread
	---------------------------------------------------------------------------]]
	local vFireEnableSpreadConVar = CreateConVar("vfire_enable_spread", "1", FCVAR_ARCHIVE, "Set to 0 to disable fire spread.")
	vFireEnableSpread = vFireEnableSpreadConVar:GetBool()
	cvars.AddChangeCallback("vfire_enable_spread", function(convar, old, new)
		vFireEnableSpread = vFireEnableSpreadConVar:GetBool()
	end)


	--[[-------------------------------------------------------------------------
	Set fire spread rate
	---------------------------------------------------------------------------]]
	local vFireSpreadRateConVar = CreateConVar("vfire_spread_delay", tostring(vFireSpreadThinkTickRate), FCVAR_ARCHIVE, "Set fire spread delay in seconds - the smaller the number the faster fires will spread. Performance Warning: use this to limit spread, not increase it! If you want to increase spread, use vfire_spread_boost!")
	vFireSpreadThinkTickRate = math.Max(vFireSpreadRateConVar:GetFloat(), 0.0001)
	cvars.AddChangeCallback("vfire_spread_delay", function(convar, old, new)
		vFireSpreadThinkTickRate = math.Max(vFireSpreadRateConVar:GetFloat(), 0.0001)
	end)


	--[[-------------------------------------------------------------------------
	Set fire decay rate
	---------------------------------------------------------------------------]]
	local vFireDecayRateConVar = CreateConVar("vfire_decay_rate", "0.1", FCVAR_ARCHIVE, "Set fire decay rate, 1 is max decay rate, 0 is no decay rate. Performance Warning: removing decay entirely may increase load as fires accumulate.")
	vFireDecayRate = vFireDecayRateConVar:GetFloat()
	cvars.AddChangeCallback("vfire_decay_rate", function(convar, old, new)
		vFireDecayRate = math.Clamp(vFireDecayRateConVar:GetFloat(), 0, 1)
	end)


	--[[-------------------------------------------------------------------------
	Toggle custom NPC behavior
	---------------------------------------------------------------------------]]
	local vFireEnableNPCBehaviorConVar = CreateConVar("vfire_affect_npcs", "1", FCVAR_ARCHIVE, "Set to 0 to disable custom NPC behavior.")
	vFireEnableNPCBehavior = vFireEnableNPCBehaviorConVar:GetBool()
	cvars.AddChangeCallback("vfire_affect_npcs", function(convar, old, new)
		vFireEnableNPCBehavior = vFireEnableNPCBehaviorConVar:GetBool()
	end)


	--[[-------------------------------------------------------------------------
	Add cluster feed - in the 'prettified' name of spread boost
	---------------------------------------------------------------------------]]
	local vFireClusterFeedConVar = CreateConVar("vfire_spread_boost", "0", FCVAR_ARCHIVE, "Set the spread boost of new fires. Higher values will achieve faster, and stronger spread. Performance Warning: excessively high values may result in endless spreading.")
	vFireClusterFeed = vFireClusterFeedConVar:GetFloat()
	cvars.AddChangeCallback("vfire_spread_boost", function(convar, old, new)
		vFireClusterFeed = math.Max(vFireClusterFeedConVar:GetFloat(), 0)
	end)


	--[[-------------------------------------------------------------------------
	Remove all fires
	---------------------------------------------------------------------------]]
	concommand.Add("vfire_remove_all", function(ply)

		if IsValid(ply) and !ply:IsAdmin() then return end

		for k, fire in pairs(ents.FindByClass("vfire")) do
			fire:Remove()
		end
	end)




	--[[-------------------------------------------------------------------------
	Reset all ConVars
	---------------------------------------------------------------------------]]
	concommand.Add("vfire_default_settings", function(ply)

		if IsValid(ply) and !ply:IsAdmin() then return end

		vFireThrottleMultiplierConVar:SetFloat(vFireThrottleMultiplierConVar:GetDefault())
		vFireEnableDamageConVar:SetBool(vFireEnableDamageConVar:GetDefault())
		vFireDamageMultiplierConVar:SetFloat(vFireDamageMultiplierConVar:GetDefault())
		vFireEnableExplosionEffectsConVar:SetFloat(vFireEnableExplosionEffectsConVar:GetDefault())
		vFireEnableDecalsConVar:SetBool(vFireEnableDecalsConVar:GetDefault())
		vFireDecalProbabilityConVar:SetFloat(vFireDecalProbabilityConVar:GetDefault())
		vFireEnableSpreadConVar:SetBool(vFireEnableSpreadConVar:GetDefault())
		vFireSpreadRateConVar:SetFloat(vFireSpreadRateConVar:GetDefault())
		vFireDecayRateConVar:SetFloat(vFireDecayRateConVar:GetDefault())
		vFireEnableNPCBehaviorConVar:SetBool(vFireEnableNPCBehaviorConVar:GetDefault())
		vFireClusterFeedConVar:SetFloat(vFireClusterFeedConVar:GetDefault())
		
		vFireMessage("vFire settings reset to default!")
	end)
end
















--[[-------------------------------------------------------------------------
Life Throttle Calculation
---------------------------------------------------------------------------]]
if SERVER then
	vFireLifeThrottle = 0
	function vFireUpdateLifeThrottle()
		vFireLifeThrottle = math.Max(vFiresCount * 1.5, 10) * vFireDecayRate * vFireThrottleMultiplier
	end
end


if SERVER then
	--[[-------------------------------------------------------------------------
	How much fuel does each prop material give?
	We don't use material types here to give fueling mechanics more variation
	---------------------------------------------------------------------------]]
	local matsFuelAmount = {
		wood_crate = 40,
		wood = 40,
		plastic_barrel = 15,
		plastic = 10,
		wood_furniture = 40,
		rubbertire = 20,
		cardboard = 8,
		paper = 6,
		rubber = 18,
		alienflesh = 7,
		wood_solid = 40,
		tile = 1
	}

	--[[-------------------------------------------------------------------------
	How quickly does each material give fuel?
	---------------------------------------------------------------------------]]
	local matsFuelRate = {
		wood_crate = 0.5,
		wood = 0.5,
		plastic_barrel = 1.8,
		plastic = 1.8,
		wood_furniture = 0.5,
		rubbertire = 1.5,
		cardboard = 9,
		paper = 13,
		rubber = 0.6,
		alienflesh = 0.7,
		wood_solid = 0.5,
		tile = 0.2
	}
	
	local matTypesFuelRate = {}
		matTypesFuelRate[MAT_ANTLION] = 0.8
		matTypesFuelRate[MAT_BLOODYFLESH] = 0.4
		matTypesFuelRate[MAT_DIRT] = 0.3
		matTypesFuelRate[MAT_FLESH] = 0.45
		matTypesFuelRate[MAT_ALIENFLESH] = 0.8
		matTypesFuelRate[MAT_PLASTIC] = 0.7
		matTypesFuelRate[MAT_FOLIAGE] = 0.375
		matTypesFuelRate[MAT_GRASS] = 0.375
		matTypesFuelRate[MAT_WOOD] = 1.2

	function vFireMatToFuelRate(mat)
		return matsFuelRate[mat] or matTypesFuelRate[mat] or 0.5
	end


	--[[-------------------------------------------------------------------------
	Feeding materials - what feed will each material give?
	Used primarily for cluster feeds
	We use material types because that's all the information we've got when burning
	the world
	---------------------------------------------------------------------------]]
	local matTypesFeed = {}
		matTypesFeed[MAT_ANTLION] = 100
		matTypesFeed[MAT_BLOODYFLESH] = 40 
		matTypesFeed[MAT_DIRT] = 165
		matTypesFeed[MAT_FLESH] = 200
		matTypesFeed[MAT_ALIENFLESH] = 200
		matTypesFeed[MAT_PLASTIC] = 500
		matTypesFeed[MAT_FOLIAGE] = 575
		matTypesFeed[MAT_COMPUTER] = 40
		matTypesFeed[MAT_GRASS] = 300
		matTypesFeed[MAT_WOOD] = 4000

	function vFireMatToFeed(mat)
		return matTypesFeed[mat] or 0
	end

	--[[-------------------------------------------------------------------------
	Material damage multipliers - how much are we damaging each material?
	We need this for balancing purposes, for example: explosive barrels should take
	more damage so they explode faster, while burning wood should be kept alive
	longer so fires can grow off of it. Using material types because we don't really
	need to be more specific
	---------------------------------------------------------------------------]]
	local matTypesDamageMul = {}
		matTypesDamageMul[MAT_PLASTIC] = 2
		matTypesDamageMul[MAT_METAL] = 8
		matTypesDamageMul[MAT_COMPUTER] = 3
		matTypesDamageMul[MAT_SLOSH] = 2
		matTypesDamageMul[MAT_GLASS] = 2
		matTypesDamageMul[MAT_FLESH] = 10

	function vFireMatToDamageMultiplier(mat)
		return matTypesDamageMul[mat] or 1
	end

	--[[-------------------------------------------------------------------------
	Damage data cacher for fast damage info builds
	---------------------------------------------------------------------------]]
	function vFireSetDamageData(ent)
		if ent.IsPlayer() then
			ent.vFireDamageData = {dmgMul = 10, dmgType = DMG_BURN}
		elseif ent:IsNPC() then
			ent.vFireDamageData = {dmgMul = 5, dmgType = DMG_DIRECT}
		elseif string.StartWith(ent:GetClass(), "func") then
			ent.vFireDamageData = {dmgMul = vFireMatToDamageMultiplier(ent:GetMaterialType()), dmgType = DMG_BURN, inflict = true}
		elseif ent:IsVehicle() then
			if vFireEnableDamageInVehicles then
				ent.vFireDamageData = {dmgMul = 5, dmgType = DMG_BURN, inflict = true}
			else
				ent.vFireDamageData = {dmgMul = 5, dmgType = DMG_CRUSH, inflict = true}
			end
		else
			ent.vFireDamageData = {dmgMul = vFireMatToDamageMultiplier(ent:GetMaterialType()), dmgType = DMG_BURN, inflict = true}
		end
	end


	--[[-------------------------------------------------------------------------

	
	Main fuel taking function


	---------------------------------------------------------------------------]]
	function vFireTakeFuel(ent, fuelTake)

		-- Return no fuel if our entity isn't valid or is the world
		if !ent:IsValid() then return 0 end

		-- Return our cache if we have it
		if ent.vFireFuelAmount != nil and ent.vFireFuelRate != nil then
			local take = math.Min(fuelTake * ent.vFireFuelRate, ent.vFireFuelAmount)
			ent.vFireFuelAmount = ent.vFireFuelAmount - take
			return take
		end
		


		-- We don't have a fuel factor cached, initialize it
		ent.vFireFuelAmount = 0
		ent.vFireFuelRate = 0

		if vFireIsCharacter(ent) then

			if ent:IsPlayer() then
				ent.vFireFuelAmount = math.huge
			else
				ent.vFireFuelAmount = 50
			end
			ent.vFireFuelRate = 1.5

		elseif ent:IsVehicle() then

			ent.vFireFuelAmount = 1650
			ent.vFireFuelRate = 1

		elseif ent:GetClass() == "vfire_cluster" then

			
			local parent = ent.parent

			local feedMul -- Main purpose is to avoid feed cycles when clusters transition from entities that lost their fuel
			if parent:IsWorld() or !IsValid(parent) then
				feedMul = 1 -- We're probably the world, act normally
			else
				-- We're an entity, don't add any fuel if said entity is out of fuel
				feedMul = vFireTakeFuel(parent, 1)
			end

			-- Find out what feed we should be giving to the cluster
			local matFeed = vFireMatToFeed(ent.matType)
			
			-- Randomize the matFeed, multiply by our feed multiplier to avoid endless fuels, and add our cluster feed ConVar
			ent.vFireFuelAmount = matFeed * math.Rand(0.5, 1) * feedMul + vFireClusterFeed

			-- What is the fuel rate of this cluster?
			local fuelRate
			if IsValid(parent) then
				local phys = parent:GetPhysicsObject()
				if IsValid(phys) then
					-- We have access to a material string, use it to be more specific
					fuelRate = vFireMatToFuelRate(phys:GetMaterial())
				end
			end
			-- We couldn't find a material string, use the material type
			if !fuelRate then fuelRate = vFireMatToFuelRate(ent.matType) end

			ent.vFireFuelRate = fuelRate


		else


			local phys = ent:GetPhysicsObject()
			if IsValid(phys) then
				local mat = phys:GetMaterial()

				local volume = phys:GetVolume()
				if !isnumber(volume) then volume = 0 end

				local matGive = matsFuelAmount[mat] or 0
				local give = matGive * volume^0.5 / 5

				local fuelRate = vFireMatToFuelRate(mat)

				if give then
					ent.vFireFuelAmount = give
					ent.vFireFuelRate = fuelRate
				end
			end


		end

		-- We're done with initialization, don't forget to return a value
		local take = math.Min(fuelTake * ent.vFireFuelRate, ent.vFireFuelAmount)
		ent.vFireFuelAmount = ent.vFireFuelAmount - take
		return take

	end

end



































if CLIENT then

	--[[-------------------------------------------------------------------------
	LOD functionalities
	---------------------------------------------------------------------------]]

	-- The higher these values are, the closer fires will LODify
	vFireLODMaxDetailThreshold = 120 -- LOD level 2
	vFireLODMedDetailThreshold = 3 -- LOD level 1

	--[[-------------------------------------------------------------------------
	Returns:
		false for max detail
		2 for medium detail
		1 for minimum detail
	---------------------------------------------------------------------------]]
	function vFireGetLOD(data)

		-- Allow inputting both a position vector or an entity
		local pos
		if isvector(data) then
			pos = data
		else
			pos = data:GetPos()
		end

		-- Are we forcing our LOD settings via ConVars?
		if vFireLODs == 0 then
			-- All LODs are disabled
			return false
		elseif vFireLODs == 2 then
			-- All LODs are forced
			return 1
		end

		-- Proceed as normal
		local dist = GetViewEntity():GetPos():DistToSqr(pos)
		local fov = LocalPlayer():GetFOV()

		-- The higher LODVal the more detail we should see
		local LODVal = 1000000000 / (dist * fov)

		local LOD = false
		if LODVal < vFireLODMaxDetailThreshold then
			if LODVal < vFireLODMedDetailThreshold then
				LOD = 1
			else
				LOD = 2
			end
		end

		return LOD
	end






	--[[-------------------------------------------------------------------------
	Particle systems control point manipulation
	---------------------------------------------------------------------------]]
	vFirePullForceControlPointIndex = 2

	function vFirePullParticlesToPos(particles, pos)
		if IsValid(particles) then
			particles:SetControlPoint(vFirePullForceControlPointIndex, pos)
		end
	end
end






--[[-------------------------------------------------------------------------
Console notifications
---------------------------------------------------------------------------]]

function vFireMessage(string)
	if SERVER then
		MsgC(Color(250,115,35),"[vFire] ",Color(255,255,255), string, "\n")
	else
		MsgC(Color(250,175,75),"[vFire] ",Color(255,255,255), string, "\n")
	end
end

-- Fire performs best with multicore rendering, let clients know of this in case they have it disabled
if CLIENT then
	if GetConVar("gmod_mcore_test"):GetInt() == 0 then
		vFireMessage("vFire performs best with gmod_mcore_test set to 1, enable it and restart your game for changes to take effect.")
	end
end











--[[-------------------------------------------------------------------------
Content Loading
---------------------------------------------------------------------------]]

if SERVER then
	resource.AddWorkshop("1525218777")
end

game.AddParticles("particles/vFire_Base_Tiny.pcf")
game.AddParticles("particles/vFire_Base_Small.pcf")
game.AddParticles("particles/vFire_Base_Medium.pcf")
game.AddParticles("particles/vFire_Base_Big.pcf")
game.AddParticles("particles/vFire_Base_Huge.pcf")
game.AddParticles("particles/vFire_Base_Gigantic.pcf")
game.AddParticles("particles/vFire_Base_Inferno.pcf")

game.AddParticles("particles/vFire_Base_Tiny_LOD.pcf")
game.AddParticles("particles/vFire_Base_Small_LOD.pcf")
game.AddParticles("particles/vFire_Base_Medium_LOD.pcf")
game.AddParticles("particles/vFire_Base_Big_LOD.pcf")
game.AddParticles("particles/vFire_Base_Huge_LOD.pcf")
game.AddParticles("particles/vFire_Base_Gigantic_LOD.pcf")
game.AddParticles("particles/vFire_Base_Inferno_LOD.pcf")

game.AddParticles("particles/vFire_Flames_Tiny.pcf")
game.AddParticles("particles/vFire_Flames_Small.pcf")
game.AddParticles("particles/vFire_Flames_Medium.pcf")
game.AddParticles("particles/vFire_Flames_Big.pcf")
game.AddParticles("particles/vFire_Flames_Huge.pcf")
game.AddParticles("particles/vFire_Flames_Gigantic.pcf")
game.AddParticles("particles/vFire_Flames_Inferno.pcf")

game.AddParticles("particles/vFire_Flames_Tiny_LOD.pcf")
game.AddParticles("particles/vFire_Flames_Small_LOD.pcf")
game.AddParticles("particles/vFire_Flames_Medium_LOD.pcf")
game.AddParticles("particles/vFire_Flames_Big_LOD.pcf")
game.AddParticles("particles/vFire_Flames_Huge_LOD.pcf")
game.AddParticles("particles/vFire_Flames_Gigantic_LOD.pcf")
game.AddParticles("particles/vFire_Flames_Inferno_LOD.pcf")


game.AddParticles("particles/vFire_Burst_Infant.pcf")
game.AddParticles("particles/vFire_Burst_Lines.pcf")
game.AddParticles("particles/vFire_Burst_Main.pcf")
game.AddParticles("particles/vFire_Burst_Main_Big.pcf")
game.AddParticles("particles/vFire_Burst_Plume.pcf")
game.AddParticles("particles/vFire_Burst_Trail.pcf")
game.AddParticles("particles/vFire_Burst_Trail_Plume.pcf")


PrecacheParticleSystem("vFire_Base_Tiny")
PrecacheParticleSystem("vFire_Base_Small")
PrecacheParticleSystem("vFire_Base_Medium")
PrecacheParticleSystem("vFire_Base_Big")
PrecacheParticleSystem("vFire_Base_Huge")
PrecacheParticleSystem("vFire_Base_Gigantic")
PrecacheParticleSystem("vFire_Base_Inferno")

PrecacheParticleSystem("vFire_Base_Tiny_LOD")
PrecacheParticleSystem("vFire_Base_Small_LOD")
PrecacheParticleSystem("vFire_Base_Medium_LOD")
PrecacheParticleSystem("vFire_Base_Big_LOD")
PrecacheParticleSystem("vFire_Base_Huge_LOD")
PrecacheParticleSystem("vFire_Base_Gigantic_LOD")
PrecacheParticleSystem("vFire_Base_Inferno_LOD")

PrecacheParticleSystem("vFire_Flames_Tiny")
PrecacheParticleSystem("vFire_Flames_Small")
PrecacheParticleSystem("vFire_Flames_Medium")
PrecacheParticleSystem("vFire_Flames_Big")
PrecacheParticleSystem("vFire_Flames_Huge")
PrecacheParticleSystem("vFire_Flames_Gigantic")
PrecacheParticleSystem("vFire_Flames_Inferno")

PrecacheParticleSystem("vFire_Flames_Tiny_LOD")
PrecacheParticleSystem("vFire_Flames_Small_LOD")
PrecacheParticleSystem("vFire_Flames_Medium_LOD")
PrecacheParticleSystem("vFire_Flames_Big_LOD")
PrecacheParticleSystem("vFire_Flames_Huge_LOD")
PrecacheParticleSystem("vFire_Flames_Gigantic_LOD")
PrecacheParticleSystem("vFire_Flames_Inferno_LOD")


PrecacheParticleSystem("vFire_Burst_Infant")
PrecacheParticleSystem("vFire_Burst_Lines")
PrecacheParticleSystem("vFire_Burst_Main")
PrecacheParticleSystem("vFire_Burst_Main_Big")
PrecacheParticleSystem("vFire_Burst_Plume")
PrecacheParticleSystem("vFire_Burst_Trail")
PrecacheParticleSystem("vFire_Burst_Trail_Plume")



--[[-------------------------------------------------------------------------
Loop sounds
---------------------------------------------------------------------------]]
list.Add("vFireLoopSounds", "ambient/fire/firebig.wav")
list.Add("vFireLoopSounds", "ambient/fire/fire_big_loop1.wav")
list.Add("vFireLoopSounds", "ambient/fire/fire_med_loop1.wav")
list.Add("vFireLoopSounds", "ambient/fire/fire_small1.wav")
list.Add("vFireLoopSounds", "ambient/fire/fire_small_loop2.wav")


--[[-------------------------------------------------------------------------
Decal loading
---------------------------------------------------------------------------]]

list.Add("VScorches_Tiny", "Decals/vFireScorch1_Tiny")
list.Add("VScorches_Tiny", "Decals/vFireScorch2_Tiny")
list.Add("VScorches_Tiny", "Decals/vFireScorch3_Tiny")
list.Add("VScorches_Tiny", "Decals/vFireScorch4_Tiny")
list.Add("VScorches_Tiny", "Decals/vFireScorch5_Tiny")
game.AddDecal("VScorch_Tiny", list.Get("VScorches_Tiny"))


list.Add("VScorches_Small", "Decals/vFireScorch1_Small")
list.Add("VScorches_Small", "Decals/vFireScorch2_Small")
list.Add("VScorches_Small", "Decals/vFireScorch3_Small")
list.Add("VScorches_Small", "Decals/vFireScorch4_Small")
list.Add("VScorches_Small", "Decals/vFireScorch5_Small")
game.AddDecal("VScorch_Small", list.Get("VScorches_Small"))


list.Add("VScorches_Medium", "Decals/vFireScorch1_Medium")
list.Add("VScorches_Medium", "Decals/vFireScorch2_Medium")
list.Add("VScorches_Medium", "Decals/vFireScorch3_Medium")
list.Add("VScorches_Medium", "Decals/vFireScorch4_Medium")
list.Add("VScorches_Medium", "Decals/vFireScorch5_Medium")
game.AddDecal("VScorch_Medium", list.Get("VScorches_Medium"))


list.Add("VScorches_Big", "Decals/vFireScorch1_Big")
list.Add("VScorches_Big", "Decals/vFireScorch2_Big")
list.Add("VScorches_Big", "Decals/vFireScorch3_Big")
list.Add("VScorches_Big", "Decals/vFireScorch4_Big")
list.Add("VScorches_Big", "Decals/vFireScorch5_Big")
game.AddDecal("VScorch_Big", list.Get("VScorches_Big"))


list.Add("VScorches_Huge", "Decals/vFireScorch1_Huge")
list.Add("VScorches_Huge", "Decals/vFireScorch2_Huge")
list.Add("VScorches_Huge", "Decals/vFireScorch3_Huge")
list.Add("VScorches_Huge", "Decals/vFireScorch4_Huge")
list.Add("VScorches_Huge", "Decals/vFireScorch5_Huge")
game.AddDecal("VScorch_Huge", list.Get("VScorches_Huge"))


list.Add("VScorches_Gigantic", "Decals/vFireScorch1_Gigantic")
list.Add("VScorches_Gigantic", "Decals/vFireScorch2_Gigantic")
list.Add("VScorches_Gigantic", "Decals/vFireScorch3_Gigantic")
list.Add("VScorches_Gigantic", "Decals/vFireScorch4_Gigantic")
list.Add("VScorches_Gigantic", "Decals/vFireScorch5_Gigantic")
game.AddDecal("VScorch_Gigantic", list.Get("VScorches_Gigantic"))


list.Add("VScorches_Inferno", "Decals/vFireScorch1_Inferno")
list.Add("VScorches_Inferno", "Decals/vFireScorch2_Inferno")
list.Add("VScorches_Inferno", "Decals/vFireScorch3_Inferno")
list.Add("VScorches_Inferno", "Decals/vFireScorch4_Inferno")
list.Add("VScorches_Inferno", "Decals/vFireScorch5_Inferno")
game.AddDecal("VScorch_Inferno", list.Get("VScorches_Inferno"))


-- Edit our decal materials through Lua because we have a lot of VMTs and I'm lazy
if CLIENT then
	hook.Add("InitPostEntity", "vFireEditDecals", function()
		for s = 1, vFireMaxState do
			local sizeStr = vFireStateToSize(s)
			for i = 1, 5 do
				local matName = "Decals/vFireScorch"..i.."_"..sizeStr
				local mat = Material(matName)
				-- Change our decal size to reflect the size of our fire
				mat:SetFloat("$decalscale", s * s * 0.04)

				-- -- Create a model material as well...

				-- -- Create the keyVal table
				-- local keyVals = mat:GetKeyValues()
				-- for k, v in pairs(keyVals) do
				-- 	if type(v) == "ITexture" then
				-- 		keyVals[k] = v:GetName()
				-- 	end
				-- 	if k == "$flags" or k == "$flags2" or k == "$flags_defined" or k == "$flags_defined2" then keyVals[k] = nil end
				-- end

				-- -- Create the material
				-- local modelMatName = matName.."_model"
				-- local modelMat = CreateMaterial(modelMatName, "VertexLitGeneric", keyVals)

				-- -- Form the link
				-- mat:SetTexture("$modelmaterial", modelMatName)
				
				-- Finalize the edit
				mat:Recompute()
				-- modelMat:Recompute()
			end
		end
	end)
end


list.Add("vFireSmoke", "particle/smokesprites_0001")
list.Add("vFireSmoke", "particle/smokesprites_0002")
list.Add("vFireSmoke", "particle/smokesprites_0003")
list.Add("vFireSmoke", "particle/smokesprites_0004")
list.Add("vFireSmoke", "particle/smokesprites_0005")
list.Add("vFireSmoke", "particle/smokesprites_0006")
list.Add("vFireSmoke", "particle/smokesprites_0007")
list.Add("vFireSmoke", "particle/smokesprites_0008")
list.Add("vFireSmoke", "particle/smokesprites_0009")
list.Add("vFireSmoke", "particle/smokesprites_0010")
list.Add("vFireSmoke", "particle/smokesprites_0011")
list.Add("vFireSmoke", "particle/smokesprites_0012")
list.Add("vFireSmoke", "particle/smokesprites_0013")
list.Add("vFireSmoke", "particle/smokesprites_0014")
list.Add("vFireSmoke", "particle/smokesprites_0015")
list.Add("vFireSmoke", "particle/smokesprites_0016")
list.Add("vFireSmoke", "particle/particle_smokegrenade1")
list.Add("vFireSmoke", "particle/particle_smokegrenade")

list.Add("vFireDebris", "effects/fleck_cement1")
list.Add("vFireDebris", "effects/fleck_cement2")
list.Add("vFireDebris", "effects/fleck_tile1")
list.Add("vFireDebris", "effects/fleck_tile2")

list.Add("vFireExplosionSounds", "weapons/explode3.wav")
list.Add("vFireExplosionSounds", "weapons/explode4.wav")
list.Add("vFireExplosionSounds", "weapons/explode5.wav")

list.Add("vFireDirt", "particle/particle_debris_01")
list.Add("vFireDirt", "particle/particle_debris_02")




--[[-------------------------------------------------------------------------
Create a refract material -- Unused for performance reasons
---------------------------------------------------------------------------]]
-- if CLIENT then

-- 	local newName = "vfire_refract_mat"
-- 	vFireRefractMatName = "!"..newName

-- 	local waterMat = Material("effects/water_warp01")
-- 	local keyVals = table.Copy(waterMat:GetKeyValues())
-- 	for k, v in pairs(keyVals) do
-- 		if type(v) == "ITexture" then
-- 			keyVals[k] = v:GetName()
-- 		end
-- 		if k == "$flags" or k == "$flags2" or k == "$flags_defined" or k == "$flags_defined2" then keyVals[k] = nil end
-- 	end
-- 	vFireRefractMat = CreateMaterial(newName, waterMat:GetShader(), {})
	
-- 	-- Edit the material
-- 	vFireRefractMat:SetFloat("$bluramount", 0)
-- 	vFireRefractMat:SetFloat("$refractamount", 0.025)

-- 	vFireRefractMat:Recompute()

-- end















--[[-------------------------------------------------------------------------


Specifics & External Support


---------------------------------------------------------------------------]]


	--[[-------------------------------------------------------------------------
	Make it easy for other addons to check if we're installed
	---------------------------------------------------------------------------]]
	vFireInstalled = true
	vFireVersion = 1


	--[[-------------------------------------------------------------------------
	Provide lower light brightness in HL2 maps
	---------------------------------------------------------------------------]]--
	if CLIENT then
		local map = game.GetMap()
		local isHL2Map = string.StartWith(map, "d1_") or string.StartWith(map, "d2_") or string.StartWith(map, "d3_")
		if isHL2Map then
			vFireLightMul = vFireLightMul * 0.165
		end
	end


	--[[-------------------------------------------------------------------------
	Soft extinguishing support for 'Fire Extinguisher' https://steamcommunity.com/sharedfiles/filedetails/?id=104607228
	---------------------------------------------------------------------------]]
	if SERVER then
		hook.Add("ExtinguisherDoExtinguish", "vFireSoftExtinguishFires", function(prop)
			if vFireIsVFireEnt(prop) then
				if prop:GetClass() == "vfire" then
					prop:SoftExtinguish(2)
					prop:Prioritize(2)
				end
				return true
			end
		end)
	end

	--[[-------------------------------------------------------------------------
	ULX Support
	---------------------------------------------------------------------------]]
	if SERVER or CLIENT then
		hook.Add("InitPostEntity", "vFireULXSupport", function()

			local ulxInstalled = istable(ulx)
			if !ulxInstalled then return end

			local CATEGORY = "vFire"

			
			--[[-------------------------------------------------------------------------
			Remove all fires the player is looking at
			---------------------------------------------------------------------------]]
			function ulx.vextinguish(ply)
				
				local lookedAt = ents.FindInCone(ply:EyePos(), ply:EyeAngles():Forward(), 30000, 0.9)
				local removeCount = 0
				for k, v in pairs(lookedAt) do
					local class = v:GetClass()
					if class == "vfire" or class == "vfire_ball" then
						v:Remove()
						removeCount = removeCount + 1
					end
				end

				ulx.fancyLogAdmin(ply, "#A extinguished "..removeCount.." fires.")
			end

			local vextinguish = ulx.command(CATEGORY, "ulx vextinguish", ulx.vextinguish, "!vextinguish")
			vextinguish:defaultAccess(ULib.ACCESS_ADMIN)
			vextinguish:help("Extinguish fires you're looking at.")

			
			--[[-------------------------------------------------------------------------
			Remove all fires
			---------------------------------------------------------------------------]]
			function ulx.vextinguishall(ply)
				local removeCount = 0
				for k, v in pairs(ents.FindByClass("vfire")) do
					v:Remove()
					removeCount = removeCount + 1
				end

				ulx.fancyLogAdmin(ply, "#A extinguished all "..removeCount.." fires.")
			end

			local vextinguishall = ulx.command(CATEGORY, "ulx vextinguishall", ulx.vextinguishall, "!vextinguishall")
			vextinguishall:defaultAccess(ULib.ACCESS_ADMIN)
			vextinguishall:help("Extinguish all fires.")


			--[[-------------------------------------------------------------------------
			Place fires
			---------------------------------------------------------------------------]]
			function ulx.vstartfire(ply, size)
				local tr = ply:GetEyeTrace()
				local life = size
				local feedCarry = size
				local pos = tr.HitPos - tr.Normal * 250
				local vel = tr.Normal * 1000
				local owner = ply
				CreateVFireBall(life, feedCarry, pos, vel, owner)

				ulx.fancyLogAdmin(ply, "#A started a fire.")
			end

			local vstartfire = ulx.command(CATEGORY, "ulx vstartfire", ulx.vstartfire, "!vstartfire")
			vstartfire:addParam{ type=ULib.cmds.NumArg, min=1, default=30, hint="size", ULib.cmds.optional, ULib.cmds.round }
			vstartfire:defaultAccess(ULib.ACCESS_ADMIN)
			vstartfire:help("Place a fire wherever you're looking at with a given size.")

		end)
	end

	--[[-------------------------------------------------------------------------
	StormFox "Support"
	---------------------------------------------------------------------------]]
	if SERVER then
		hook.Add("vFire - StormFox Handeshake", "vFire - StormFox Handeshake", function()
			vFireMessage("The same thing we do every night StormFox. Try to take over the world! >:D")
		end)
	end