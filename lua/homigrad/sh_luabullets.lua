gs = {
	random = include("minstd.lua") -- from https://github.com/Kefta/Lua-MINSTD
}


DEBUG_LENGTH = 3

COORD_EXTENT = 2 * 16384
// Maximum traceable distance (assumes cubic world and trace from one corner to opposite)
// COORD_EXTENT * sqrt(3)
MAX_TRACE_LENGTH = math.sqrt(3) * COORD_EXTENT

SF_BREAK_NO_BULLET_PENETRATION = 0x0800

-- From the math lib
do
	local band = bit.band
	local bnot = bit.bnot
	local bor = bit.bor
	local bxor = bit.bxor
	local rshift = bit.rshift
	local floor = math.floor
	local log = math.log
	local sin = math.sin
	local cos = math.cos
	local rad = math.rad
	local abs = math.abs
	local exp = math.exp

	// The four core functions - F1 is optimized somewhat
	// local function f1(x, y, z) bit.bor(bit.band(x, y), bit.band(bit.bnot(x), z)) end
	// This is the central step in the MD5 algorithm.
	local function Step1(w, x, y, z, flData, iStep)
		w = w + bxor(z, band(x, bxor(y, z))) + flData
		
		return bor((w * 2^iStep) % 0x100000000, floor(w % 0x100000000 / 2^(0x20 - iStep))) + x
	end

	local function Step2(w, x, y, z, flData, iStep)
		w = w + bxor(y, band(z, bxor(x, y))) + flData
		
		return bor((w * 2^iStep) % 0x100000000, floor(w % 0x100000000 / 2^(0x20 - iStep))) + x
	end

	local function Step3(w, x, y, z, flData, iStep)
		w = w + bxor(bxor(x, y), z) + flData
		
		return bor((w * 2^iStep) % 0x100000000, floor(w % 0x100000000 / 2^(0x20 - iStep))) + x
	end

	local function Step4(w, x, y, z, flData, iStep)
		w = w + bxor(y, bor(x, bnot(z))) + flData
		
		return bor((w * 2^iStep) % 0x100000000, floor(w % 0x100000000 / 2^(0x20 - iStep))) + x
	end

	function math.MD5Random(iSeed)
		--gs.CheckType(iSeed, 1, TYPE_NUMBER)
		
		-- FIXME: https://github.com/Facepunch/garrysmod-issues/issues/2820
		local bEnabled = jit.status()
		
		if (bEnabled) then
			jit.off()
		end
		
		iSeed = iSeed % 0x100000000
		
		local a = Step1(0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476, iSeed + 0xd76aa478, 7)
		local d = Step1(0x10325476, a, 0xefcdab89, 0x98badcfe, 0xe8c7b7d6, 12)
		local c = Step1(0x98badcfe, d, a, 0xefcdab89, 0x242070db, 17)
		local b = Step1(0xefcdab89, c, d, a, 0xc1bdceee, 22)
		a = Step1(a, b, c, d, 0xf57c0faf, 7)
		d = Step1(d, a, b, c, 0x4787c62a, 12)
		c = Step1(c, d, a, b, 0xa8304613, 17)
		b = Step1(b, c, d, a, 0xfd469501, 22)
		a = Step1(a, b, c, d, 0x698098d8, 7)
		d = Step1(d, a, b, c, 0x8b44f7af, 12)
		c = Step1(c, d, a, b, 0xffff5bb1, 17)
		b = Step1(b, c, d, a, 0x895cd7be, 22)
		a = Step1(a, b, c, d, 0x6b901122, 7)
		d = Step1(d, a, b, c, 0xfd987193, 12)
		c = Step1(c, d, a, b, 0xa67943ae, 17)
		b = Step1(b, c, d, a, 0x49b40821, 22)
		
		a = Step2(a, b, c, d, 0xf61e25e2, 5)
		d = Step2(d, a, b, c, 0xc040b340, 9)
		c = Step2(c, d, a, b, 0x265e5a51, 14)
		b = Step2(b, c, d, a, iSeed + 0xe9b6c7aa, 20)
		a = Step2(a, b, c, d, 0xd62f105d, 5)
		d = Step2(d, a, b, c, 0x02441453, 9)
		c = Step2(c, d, a, b, 0xd8a1e681, 14)
		b = Step2(b, c, d, a, 0xe7d3fbc8, 20)
		a = Step2(a, b, c, d, 0x21e1cde6, 5)
		d = Step2(d, a, b, c, 0xc33707f6, 9)
		c = Step2(c, d, a, b, 0xf4d50d87, 14)
		b = Step2(b, c, d, a, 0x455a14ed, 20)
		a = Step2(a, b, c, d, 0xa9e3e905, 5)
		d = Step2(d, a, b, c, 0xfcefa3f8, 9)
		c = Step2(c, d, a, b, 0x676f02d9, 14)
		b = Step2(b, c, d, a, 0x8d2a4c8a, 20)

		a = Step3(a, b, c, d, 0xfffa3942, 4)
		d = Step3(d, a, b, c, 0x8771f681, 11)
		c = Step3(c, d, a, b, 0x6d9d6122, 16)
		b = Step3(b, c, d, a, 0xfde5382c, 23)
		a = Step3(a, b, c, d, 0xa4beeac4, 4)
		d = Step3(d, a, b, c, 0x4bdecfa9, 11)
		c = Step3(c, d, a, b, 0xf6bb4b60, 16)
		b = Step3(b, c, d, a, 0xbebfbc70, 23)
		a = Step3(a, b, c, d, 0x289b7ec6, 4)
		d = Step3(d, a, b, c, iSeed + 0xeaa127fa, 11)
		c = Step3(c, d, a, b, 0xd4ef3085, 16)
		b = Step3(b, c, d, a, 0x04881d05, 23)
		a = Step3(a, b, c, d, 0xd9d4d039, 4)
		d = Step3(d, a, b, c, 0xe6db99e5, 11)
		c = Step3(c, d, a, b, 0x1fa27cf8, 16)
		b = Step3(b, c, d, a, 0xc4ac5665, 23)
		
		a = Step4(a, b, c, d, iSeed + 0xf4292244, 6)
		d = Step4(d, a, b, c, 0x432aff97, 10)
		c = Step4(c, d, a, b, 0xab9423c7, 15)
		b = Step4(b, c, d, a, 0xfc93a039, 21)
		a = Step4(a, b, c, d, 0x655b59c3, 6)
		d = Step4(d, a, b, c, 0x8f0ccc92, 10)
		c = Step4(c, d, a, b, 0xffeff47d, 15)
		b = Step4(b, c, d, a, 0x85845e51, 21)
		a = Step4(a, b, c, d, 0x6fa87e4f, 6)
		d = Step4(d, a, b, c, 0xfe2ce6e0, 10)
		c = Step4(c, d, a, b, 0xa3014314, 15)
		b = Step4(b, c, d, a, 0x4e0811a1, 21)
		a = Step4(a, b, c, d, 0xf7537e82, 6)
		d = Step4(d, a, b, c, 0xbd3af235, 10)
		c = Step4(c, d, a, b, 0x2ad7d2bb, 15)
		b = (Step4(b, c, d, a, 0xeb86d391, 21) + 0xefcdab89) % 0x100000000
		
		c = (c + 0x98badcfe) % 0x100000000
		a = floor(b / 0x10000) % 0x100 + floor(b / 0x1000000) % 0x100 * 0x100 + c % 0x100 * 0x10000 + floor(c / 0x100) % 0x100 * 0x1000000
		
		if (bEnabled) then
			jit.on()
		end
		
		return a
	end
end

-- From the Vector lib
do
	local VECTOR = FindMetaTable("Vector")
	
	function VECTOR:Right(vUp --[[= Vector(0, 0, 1)]])
		if (self[1] == 0 and self[2] == 0)then
			// pitch 90 degrees up/down from identity
			return Vector(0, -1, 0)
		end
		
		if (vUp == nil) then
			vUp = vector_up
		end
		
		local vRet = self:Cross(vUp)
		vRet:Normalize()
		
		return vRet
	end

	function VECTOR:Up(vUp --[[= Vector(0, 0, 1)]])
		if (self[1] == 0 and self[2] == 0)then
			return Vector(-self[3], 0, 0)
		end
		
		if (vUp == nil) then
			vUp = vector_up
		end
		
		local vRet = self:Cross(vUp)
		vRet = vRet:Cross(self)
		vRet:Normalize()
		
		return vRet
	end
end

-- From the entity lib
do
	local ENTITY = FindMetaTable("Entity")

	function ENTITY:IsBreakable()
		local sClass = self:GetClass()
		
		return sClass == "func_breakable" or sClass == "func_breakable_surf" or sClass == "func_physbox"
	end

	-- FIXME: Make debugoverlay display transparent
	function ENTITY:DrawHitBoxes(flDuration --[[= 0]])
		local iSet = self:GetHitboxSet()
		
		if (iSet ~= nil) then
			if (flDuration == nil) then
				flDuration = 0
			end
			
			for iGroup = 0, self:GetHitBoxGroupCount() - 1 do
				for iHitBox = 0, self:GetHitBoxCount(iGroup) - 1 do
					local vPos, aRot = self:GetBonePosition(self:GetHitBoxBone(iHitBox, iGroup))
					local vMins, vMaxs = self:GetHitBoxBounds(iHitBox, iGroup)
					debugoverlay.BoxAngles(vPos, vMins, vMaxs, aRot, flDuration, color_debug)
				end
			end
		end
	end
end

local PLAYER = FindMetaTable("Player")
local ENTITY = FindMetaTable("Entity")

function ENTITY:GetMD5Seed()
	--print(self)
	--print(self:EntIndex())
	local iCommandNumber = util.SharedRandom( self:EntIndex(), -65535, 65535 )--self:GetCurrentCommand():CommandNumber() -- FIXME: Change to FrameNumber when it is finally binded serverside
	
	if (self.m_iMD5SeedSavedNumber ~= iCommandNumber) then
		self.m_iMD5SeedSavedNumber = iCommandNumber
		self.m_iMD5Seed = math.MD5Random(iCommandNumber)
	end
	
	return self.m_iMD5Seed or 0
end

-- Equivalent of CBasePlayer::EyeVectors() before AngleVecotrs
function PLAYER:ActualEyeAngles()
	local pVehicle = self:GetVehicle()
	
	if (pVehicle:IsValid()) then
		local _, ang = pVehicle:GetVehicleViewPosition()
		
		return ang
	end
	
	return self:EyeAngles()
end

local vDefaultOffset = Vector(0, 0, -4)

function PLAYER:ComputeTracerStartPosition(vSrc, vOffset, flForwardMul, flRightMul)
	if (vOffset == nil) then
		vOffset = vDefaultOffset
	end
	
	if (flForwardMul == nil) then
		flForwardMul = 16
	end
	
	if (flRightMul == nil) then
		flRightMul = 2
	end
	
	// adjust tracer position for player
	local aEyes = self:ActualEyeAngles()
	
	local vForward = aEyes:Forward()
	vForward:Mul(flForwardMul)
	
	local vRight = aEyes:Right()
	vRight:Mul(flRightMul)
	
	vForward:Add(vSrc)
	vForward:Add(vOffset)
	vForward:Add(vRight)
	
	return vForward
end

AMMO_FORCE_DROP_IF_CARRIED = 0x1
AMMO_INTERPRET_PLRDAMAGE_AS_DAMAGE_TO_PLAYER = 0x2

FIRE_BULLETS_FIRST_SHOT_ACCURATE = 0x1 // Pop the first shot with perfect accuracy
FIRE_BULLETS_DONT_HIT_UNDERWATER = 0x2 // If the shot hits its target underwater, don't damage it
FIRE_BULLETS_ALLOW_WATER_SURFACE_IMPACTS = 0x4 // If the shot hits water surface, still call DoImpactEffect
-- The engine alerts NPCs by pushing a sound onto a static sound manager
-- However, this cannot be accessed from the Lua state
--FIRE_BULLETS_TEMPORARY_DANGER_SOUND = 0x8 // Danger sounds added from this impact can be stomped immediately if another is queued

local ai_debug_shoot_positions = GetConVar("ai_debug_shoot_positions")
local phys_pushscale = GetConVar("phys_pushscale")
local sv_showimpacts = CreateConVar("gs_weapons_showimpacts", "0", bit.bor(FCVAR_REPLICATED, FCVAR_ARCHIVE), "Shows client (red) and server (blue) bullet impact point (1=both, 2=client-only, 3=server-only)")
local sv_showpenetration = CreateConVar("gs_weapons_showpenetration", "0", bit.bor(FCVAR_REPLICATED, FCVAR_ARCHIVE), "Shows penetration trace (if applicable) when the weapon fires")
local sv_showplayerhitboxes = CreateConVar("gs_weapons_showplayerhitboxes", "0", bit.bor(FCVAR_REPLICATED, FCVAR_ARCHIVE), "Show lag compensated hitboxes for the specified player index whenever a player fires.")

local nWhizTracer = bit.bor(0x0002, 0x0001)
local iTracerCount = 0 -- Instance global to interact with FireBullets functions

local function Splash(vHitPos, bStartedInWater, bEndNotWater, vSrc, pWeapon, bFirstTimePredicted, iAmmoDamageType, iAmmoMinSplash, iAmmoMaxSplash, sSplashEffect)
	local trSplash = bStartedInWater and bEndNotWater and
		util.TraceLine({
			start = vHitPos,
			endpos = vSrc,
			mask = MASK_WATER
		})
	// See if the bullet ended up underwater + started out of the water
	or not (bStartedInWater or bEndNotWater) and
		util.TraceLine({
			start = vSrc,
			endpos = vHitPos,
			mask = MASK_WATER
		})
	
	if (trSplash and not (pWeapon and pWeapon.DoSplashEffect and pWeapon:DoSplashEffect(trSplash)) and bFirstTimePredicted) then
		local data = EffectData()
			data:SetOrigin(trSplash.HitPos)
			data:SetStart(vSrc)
			data:SetNormal(trSplash.HitNormal)
			data:SetSurfaceProp(trSplash.SurfaceProps)
			data:SetDamageType(iAmmoDamageType)
			data:SetHitBox(trSplash.HitBox)
			data:SetEntity(trSplash.Entity)
			
			if (SERVER) then
				data:SetEntIndex(trSplash.Entity:EntIndex())
			end
			
			data:SetScale(gs.random:RandomFloat(iAmmoMinSplash, iAmmoMaxSplash))
			
			if (bit.band(util.PointContents(trSplash.HitPos), CONTENTS_SLIME) ~= 0) then
				data:SetFlags(FX_WATER_IN_SLIME)
			end
		util.Effect(sSplashEffect, data) -- FIXME: Add settings to send in custom effects
	end
end

local function Impact(Weapon, iAmmoDamageType, bFirstTimePredicted, vSrc, tr, sImpactEffect, sRagdollImpactEffect)
	if (not (Weapon and Weapon.DoImpactEffect and Weapon:DoImpactEffect(tr, iAmmoDamageType))) then
		if (bFirstTimePredicted) then
			local data = EffectData()
				data:SetOrigin(tr.HitPos)
				data:SetStart(vSrc)
				data:SetNormal(tr.HitNormal)
				data:SetSurfaceProp(tr.SurfaceProps)
				data:SetDamageType(iAmmoDamageType)
				data:SetHitBox(tr.HitBox)
				data:SetEntity(tr.Entity)
				
				if (SERVER) then
					data:SetEntIndex(tr.Entity:EntIndex())
				end
			
			util.Effect(sImpactEffect, data, true, true)
		end
	elseif (bFirstTimePredicted) then
		// We may not impact, but we DO need to affect ragdolls on the client
		-- FIXME: Should we?
		local data = EffectData()
			data:SetOrigin(tr.HitPos)
			data:SetStart(vSrc)
			data:SetNormal(tr.HitNormal)
			data:SetSurfaceProp(tr.SurfaceProps)
			data:SetDamageType(iAmmoDamageType)
			data:SetHitBox(tr.HitBox)
			data:SetEntity(tr.Entity)
			
			if (SERVER) then
				data:SetEntIndex(tr.Entity:EntIndex())
			end
		util.Effect(sRagdollImpactEffect, data)
	end
end

local function Damage(bDoDebugHit, bStartedWater, bEndNotWater, iFlags, iDamage, iPlayerDamage, iNPCDamage, iAmmoDamage, pAttacker, pInflictor,
	iAmmoDamageType, tr, Weapon, vShotDir, flAmmoForce, flForce, flPhysPush, iAmmoType, vSrc, fCallback, bFirstTimePredicted, bDrop, sImpactEffect, sRagdollImpactEffect, tInfo)
	
	local vHitPos = tr.HitPos
	local pEntity = tr.Entity
	
	// draw server impact markers
	if (bDoDebugHit) then
		debugoverlay.Box(vHitPos, vector_debug_min, vector_debug_max, DEBUG_LENGTH, color_debug)
	end
	
	if (not bStartedWater and bEndNotWater or bit.band(iFlags, FIRE_BULLETS_DONT_HIT_UNDERWATER) == 0) then
		-- The engine considers this a float
		-- Even though no values assigned to it are
		-- FIXME: Update these typedefs
		local iActualDamage = iDamage
		
		// If we hit a player, and we have player damage specified, use that instead
		// Adrian: Make sure to use the currect value if we hit a vehicle the player is currently driving.
		-- We don't check for vehicle passengers since GMod has no C++ vehicles with them
		if (pEntity:IsPlayer()) then
			if (iPlayerDamage ~= 0) then
				iActualDamage = iPlayerDamage
			end
		elseif (pEntity:IsNPC()) then
			if (iNPCDamage ~= 0) then
				iActualDamage = iNPCDamage
			end
		-- https://github.com/Facepunch/garrysmod-requests/issues/760
		elseif (SERVER and pEntity:IsVehicle()) then
			local pDriver = pEntity:GetDriver()
			
			if (iPlayerDamage ~= 0 and pDriver:IsPlayer()) then
				iActualDamage = iPlayerDamage
			elseif (iNPCDamage ~= 0 and pDriver:IsNPC()) then
				iActualDamage = iNPCDamage
			end
		end
		
		if (iActualDamage == 0 and iAmmoDamage ~= 0) then
			iActualDamage = iAmmoDamage
		end
		
		// Damage specified by function parameter
		local info = DamageInfo()
			info:SetAttacker(IsValid(pAttacker) and pAttacker or game.GetWorld())
			info:SetInflictor(IsValid(pInflictor) and pInflictor or info:GetAttacker())
			info:SetDamage(iActualDamage)
			info:SetDamageType(iAmmoDamageType)
			info:SetDamagePosition(vHitPos)
			info:SetDamageForce(vShotDir * flAmmoForce * flForce * flPhysPush)
			info:SetAmmoType(iAmmoType)
			info:SetReportedPosition(vSrc)
		pEntity:DispatchTraceAttack(info, tr, vShotDir)
		
		if (fCallback) then
			fCallback(info:GetAttacker(), tr, info, tInfo, Weapon)
		end
		
		if (bEndNotWater or bit.band(iFlags, FIRE_BULLETS_ALLOW_WATER_SURFACE_IMPACTS) ~= 0) then
			Impact(Weapon, iAmmoDamageType, bFirstTimePredicted, vSrc, tr, sImpactEffect, sRagdollImpactEffect)
		end
	end
	
	if (bDrop and SERVER) then
		// Make sure if the player is holding this, he drops it
		DropEntityIfHeld(pEntity)
	end
end

local function Tracer(bDebugShoot, vSrc, vFinalHit, bFirstTimePredicted, iTracerFreq, Weapon, owner, iAmmoTracerType, iAmmoDamageType, sTracerName)
	if (bDebugShoot) then
		debugoverlay.Line(vSrc, vFinalHit, DEBUG_LENGTH, color_debug)
	end
	
	if (bFirstTimePredicted and iTracerFreq > 0) then
		if (iTracerCount % iTracerFreq == 0) then
			local data = EffectData()
				data:SetOrigin(vFinalHit)
				
				if (Weapon) then
					local iAttachment = Weapon.GetMuzzleAttachment and Weapon:GetMuzzleAttachment() or 1
					data:SetStart(Weapon.GetTracerOrigin and Weapon:GetTracerOrigin() or vSrc)
					data:SetAttachment(iAttachment)
				else
					data:SetStart(vSrc)
					data:SetAttachment(1)
				end
				
				data:SetDamageType(iAmmoDamageType)
				data:SetEntity(Weapon or owner)
				
				if (SERVER) then
					data:SetEntIndex((Weapon or owner):EntIndex())
				end
				
				data:SetScale(0) -- FIXME: This was in the source code, but I'm pretty sure this is unnecessary + will potentially ruin custom effects
				data:SetFlags(iAmmoTracerType == TRACER_LINE_AND_WHIZ and nWhizTracer or 0x0002)
			util.Effect(sTracerName, data)
		end
		
		iTracerCount = iTracerCount + 1
	end
end

-- Defaults from ammodef.cpp
local tDefaultAmmoTable = {
	name = "",
	plydmg = 0,
	npcdmg = 0,
	maxcarry = 0,
	dmgtype = DMG_GENERIC,
	flags = 0,
	minsplash = 4,
	maxsplash = 8,
	tracer = TRACER_NONE,
	force = 0
}

local numbullets = 0

hg.vehicles = hg.vehicles or {}

function ENTITY:FireLuaBullets(tInfo)
    if (hook.Run("EntityFireBullets", self, tInfo) == false) then
		return
	end
	
    local owner = tInfo.Attacker and tInfo.Attacker:IsValid() and tInfo.Attacker or IsValid(self) and self:GetOwner() and self:GetOwner():IsValid() and self:GetOwner() or self
	local bIsPlayer = owner:IsPlayer()
	
	if (bIsPlayer and !tInfo.DisableLagComp) then
		owner:LagCompensation(true)
	end
	
	local pWeapon = tInfo.Inflictor and tInfo.Inflictor:IsValid() and tInfo.Inflictor or IsValid(owner) and owner.GetActiveWeapon and owner:GetActiveWeapon()
	local bWeaponValid = IsValid(pWeapon)
	
	-- FireBullets info
	local iAmmoType
	
	if (tInfo.AmmoType == nil) then
		iAmmoType = -1
	elseif (isstring(tInfo.AmmoType)) then
		iAmmoType = game.GetAmmoID(tInfo.AmmoType)
	else
		iAmmoType = tInfo.AmmoType
	end
	
	local pAttacker = tInfo.Attacker or self
	local fCallback = tInfo.Callback
	local iDamage = tInfo.Damage or 0
	local vDir = tInfo.Dir and tInfo.Dir:GetNormal() or owner:GetAimVector()
	local flDistance = tInfo.Distance or MAX_TRACE_LENGTH
	local Filter = tInfo.Filter or owner
	
	table.Add(Filter, hg.vehicles)

	local iFlags = tInfo.Flags or 0
	local flForce = tInfo.Force or 1
	local bHullTrace = tInfo.HullTrace
	
	if (bHullTrace == nil) then
		bHullTrace = true
	end
	
	local pInflictor = tInfo.Inflictor and tInfo.Inflictor:IsValid() and tInfo.Inflictor or bWeaponValid and pWeapon or owner
	local iMask = tInfo.Mask or MASK_SHOT
	local iNPCDamage = tInfo.NPCDamage or 0
	local iNum = tInfo.Num or 1
	local iPlayerDamage = tInfo.PlayerDamage or 0
	local vSrc = tInfo.Src or owner:GetShootPos()
	local iTracerFreq = tInfo.Tracer or 1
	local sTracerName = tInfo.TracerName or "Tracer"
	
	-- Effects
	local sSplashEffect = tInfo.SplashEffect or "gunshotsplash"
	local sImpactEffect = tInfo.ImpactEffect or "Impact"
	local sRagdollImpactEffect = tInfo.RagdollImpactEffect or "RagdollImpact"
	
	-- Ammo
	local tAmmoData = game.GetAmmoData(iAmmoType) or tDefaultAmmoTable
	local iAmmoFlags = tAmmoData.flags
	local flAmmoForce = tAmmoData.force
	local iAmmoDamageType = tAmmoData.dmgtype
	local iAmmoMinSplash = tAmmoData.minsplash
	local iAmmoMaxSplash = tAmmoData.maxsplash
	local iAmmoTracerType = tAmmoData.tracer
	
	local iAmmoNPCDamage = tAmmoData.npcdmg
	
	if pWeapon then pWeapon.bullet = tInfo end

	if (isstring(iAmmoNPCDamage)) then
		iAmmoNPCDamage = GetConVar(iAmmoNPCDamage):GetFloat()
	end
	
	local iAmmoPlayerDamage = tAmmoData.plydmg
	
	if (isstring(iAmmoPlayerDamage)) then
		iAmmoPlayerDamage = GetConVar(iAmmoPlayerDamage):GetFloat()
	end
	
	if (bit.band(iAmmoFlags, AMMO_INTERPRET_PLRDAMAGE_AS_DAMAGE_TO_PLAYER) ~= 0) then
		if (iPlayerDamage == 0) then
			iPlayerDamage = iAmmoPlayerDamage
		end
		
		if (iNPCDamage == 0) then
			iNPCDamage = iAmmoNPCDamage
		end
	end
	
	local iAmmoDamage = bIsPlayer and iAmmoPlayerDamage or iAmmoNPCDamage
	
	-- Loop values
	local bDrop = bit.band(iAmmoFlags, AMMO_FORCE_DROP_IF_CARRIED) ~= 0
	local bDebugShoot = ai_debug_shoot_positions:GetBool()
	local bFirstShotInaccurate = bit.band(iFlags, FIRE_BULLETS_FIRST_SHOT_ACCURATE) == 0
	local flPhysPush = phys_pushscale:GetFloat()
	local bShowPenetration = sv_showpenetration:GetBool()
	local bStartedInWater = bit.band(util.PointContents(vSrc), MASK_WATER) ~= 0
	local bFirstTimePredicted = IsFirstTimePredicted()
	local flSpreadBias, flFlatness, bNegBias, vFireBulletMax, vFireBulletMin, vSpreadRight, vSpreadUp, tEnts, iEntsLen
	
	// Wrap it for network traffic so it's the same between client and server
    
	local iSeed = owner:GetMD5Seed() % 0x100 - 1
	
	-- Don't calculate stuff we won't end up using
	if (bFirstShotInaccurate or iNum ~= 1) then
		flSpreadBias = tInfo.SpreadBias or 0.5
		
		if (flSpreadBias > 1) then
			flSpreadBias = 1
			bNegBias = false
		elseif (flSpreadBias < -1) then
			flSpreadBias = -1
			bNegBias = true
		else
			bNegBias = flSpreadBias < 0
			
			if (bNegBias) then
				flSpreadBias = -flSpreadBias
			end
		end
		
		local vSpread = tInfo.Spread or vector_origin

        if isnumber(vSpread) then
            vSpread = Vector(vSpread,vSpread,0)
        end

		vSpreadRight = vDir:Right()
		vSpreadRight:Mul(vSpread[1])
		vSpreadUp = vDir:Up()
		vSpreadUp:Mul(vSpread[2])
		
		if (bHullTrace and iNum ~= 1) then
			local flHullSize = tInfo.HullSize
			vFireBulletMax = flHullSize and Vector(flHullSize, flHullSize, flHullSize) or Vector(3, 3, 3)
			vFireBulletMin = -vFireBulletMax
		end
	end
	
	local bDoDebugHit
	
	do
		//Adrian: visualize server/client player positions
		//This is used to show where the lag compesator thinks the player should be at.
		local iHitNum = sv_showplayerhitboxes:GetInt()
		
		if (iHitNum > 0) then
			local pLagPlayer = Player(iHitNum)
			
			if (pLagPlayer:IsValid()) then
				pLagPlayer:DrawHitBoxes(DEBUG_LENGTH)
			end
		end
		
		iHitNum = sv_showimpacts:GetInt()
		bDoDebugHit = iHitNum == 1 or (CLIENT and iHitNum == 2) or (SERVER and iHitNum == 3)
	end
	
    numbullets = numbullets + 1

	for iShot = 1, iNum do
		local vShotDir
		iSeed = iSeed + numbullets // use new seed for next bullet
		gs.random:SetSeed(iSeed) // init random system with this seed
		
		// If we're firing multiple shots, and the first shot has to be ba on target, ignore spread
		if (bFirstShotInaccurate or iShot ~= 1) then
			local x
			local y
			local z

			repeat
				x = gs.random:RandomFloat(-flSpreadBias, flSpreadBias) + gs.random:RandomFloat(flSpreadBias - 1, 1 - flSpreadBias)
				y = gs.random:RandomFloat(-flSpreadBias, flSpreadBias) + gs.random:RandomFloat(flSpreadBias - 1, 1 - flSpreadBias)

				if (bNegBias) then
					x = x < 0 and -(1 + x) or 1 - x
					y = y < 0 and -(1 + y) or 1 - y
				end

				z = x * x + y * y
			until (z <= 1)

			vShotDir = vDir + x * vSpreadRight + y * vSpreadUp
			vShotDir:Normalize()
		else
			vShotDir = vDir
		end
		
		local bHitGlass
		local vEnd = vSrc + vShotDir * flDistance
		local vNewSrc = vSrc
		local vFinalHit
		
		repeat
			local tr = bHullTrace and iShot % 2 == 0 and
				// Half of the shotgun pellets are hulls that make it easier to hit targets with the shotgun.
				util.TraceHull({
					start = vNewSrc,
					endpos = vEnd,
					mins = vFireBulletMin,
					maxs = vFireBulletMax,
					mask = iMask,
					filter = Filter
				})
			or
				util.TraceLine({
					start = vNewSrc,
					endpos = vEnd,
					mask = iMask,
					filter = Filter
				})
			
			while (IsValid(tr.Entity) and tr.Entity.organism) do
				local ent = tr.Entity

				--table.insert(Filter, ent)

				local bonename = ent:GetBoneName(ent:TranslatePhysBoneToBone(tr.PhysicsBone))
				local hitgroup = hg.bonetohitgroup[bonename]--( ent:IsPlayer() and tr.HitGroup or hg.bonetohitgroup[bonename])
				
				if (tr.PhysicsBone != 0 or !tr.StartSolid) and (!hg.amputeetable[bonename] or !ent.organism[hg.amputeetable[bonename].."amputated"]) then break end

				tr = bHullTrace and iShot % 2 == 0 and
					// Half of the shotgun pellets are hulls that make it easier to hit targets with the shotgun.
					util.TraceHull({
						start = tr.HitPos + vShotDir * 1,
						endpos = vEnd,
						mins = vFireBulletMin,
						maxs = vFireBulletMax,
						mask = iMask,
						filter = Filter
					})
				or
					util.TraceLine({
						start = tr.HitPos + vShotDir * 1,
						endpos = vEnd,
						mask = iMask,
						filter = Filter
					})
				--print(tr.FractionLeftSolid)
				--print(tr.Entity, tr.HitGroup, hitgroup, tr.PhysicsBone, tr.StartSolid)
			end

			local data = {}
			data.Trace = tr
			data.AmmoType = tInfo.AmmoType
			data.Tracer = tInfo.Tracer
			data.Damage = tInfo.Damage
			data.Force = tInfo.Force
			data.Attacker = tInfo.Attacker
			data.TracerName = tInfo.TracerName
			
			if (hook.Run("PostEntityFireBullets", self, data) == false) then
				return
			end
				
			--[[if (SERVER) then
				if (bStartedInWater) then
					local flLengthSqr = vSrc:DistToSqr(tr.HitPos)
					
					if (flLengthSqr > SHOT_UNDERWATER_BUBBLE_DIST * SHOT_UNDERWATER_BUBBLE_DIST) then
						util.BubbleTrail(self:ComputeTracerStartPosition(vSrc),
						vSrc + SHOT_UNDERWATER_BUBBLE_DIST * vShotDir,
						WATER_BULLET_BUBBLES_PER_INCH * SHOT_UNDERWATER_BUBBLE_DIST)
					else
						local flLength = math.sqrt(flLengthSqr) - 0.1
						util.BubbleTrail(self:ComputeTracerStartPosition(vSrc),
						vSrc + flLength * vShotDir,
						SHOT_UNDERWATER_BUBBLE_DIST * flLength)
					end
				end
				
				// Now hit all triggers along the ray that respond to shots...
				// Clip the ray to the first collided solid returned from traceline
				-- https://github.com/Facepunch/garrysmod-requests/issues/755
				local triggerInfo = DamageInfo()
					triggerInfo:SetAttacker(pAttacker)
					triggerInfo:SetInflictor(pAttacker)
					triggerInfo:SetDamage(iDamage)
					triggerInfo:SetDamageType(iAmmoDamageType)
					triggerInfo:CalculateBulletDamageForce(sAmmoType, vShotDir, tr.HitPos, tr.HitPos, flForce)
					triggerInfo:SetAmmoType(iAmmoType)
				triggerInfo:TraceAttackToTriggers(triggerInfo, vSrc, tr.HitPos, vShotDir)
			end]]
			
			local vHitPos = tr.HitPos
			vFinalHit = vHitPos
			
			local bEndNotWater = bit.band(util.PointContents(vHitPos), MASK_WATER) == 0
			Splash(vHitPos, bStartedInWater, bEndNotWater, vSrc, bWeaponValid and pWeapon, bFirstTimePredicted, iAmmoDamageType, iAmmoMinSplash, iAmmoMaxSplash, sSplashEffect)
			
			if (not tr.Hit or tr.HitSky) then
				break // we didn't hit anything, stop tracing shoot
			end
			
			Damage(bDoDebugHit, bStartedWater, bEndNotWater, iFlags, iDamage, iPlayerDamage, iNPCDamage, iAmmoDamage, pAttacker, pInflictor, iAmmoDamageType,
				tr, bWeaponValid and pWeapon, vShotDir, flAmmoForce, flForce, flPhysPush, iAmmoType, vSrc, fCallback, bFirstTimePredicted, bDrop, sImpactEffect, sRagdollImpactEffect, tInfo)
			// do damage, paint decals
			-- https://github.com/Facepunch/garrysmod-issues/issues/2741
			local pEntity = tr.Entity
			bHitGlass = false --tr.MatType == MAT_GLASS and pEntity:IsBreakable() and not pEntity:HasSpawnFlags(SF_BREAK_NO_BULLET_PENETRATION)
			
			// See if we hit glass
			// Query the func_breakable for whether it wants to allow for bullet penetration
			if (bHitGlass) then
				if (tEnts == nil) then
					tEnts = ents.GetAll()
					iEntsLen = #tEnts
				end
				
				local bReplace = false
				
				-- Trace for only the entity we hit
				for i = iEntsLen, 1, -1 do
					if (tEnts[i] == pEntity) then
						tEnts[i] = tEnts[iEntsLen]
						tEnts[iEntsLen] = nil
						bReplace = true
						
						break
					end
				end
				
				util.TraceLine({
					start = vEnd,
					endpos = vHitPos,
					mask = iMask,
					filter = tEnts,
					ignoreworld = true,
					output = tr
				})
				// bullet did penetrate object, exit Decal
				Impact(bWeaponValid and pWeapon, iAmmoDamageType, bFirstTimePredicted, vSrc, tr, sImpactEffect, sRagdollImpactEffect)
				
				vNewSrc = tr.HitPos
				
				if (bShowPenetration) then
					debugoverlay.Line(vHitPos, vNewSrc, DEBUG_LENGTH, color_altdebug)
				end
				
				if (bDoDebugHit) then
					debugoverlay.Box(vNewSrc, vector_debug_min, vector_debug_max, DEBUG_LENGTH, color_altdebug)
				end
				
				-- Should never be false
				if (bReplace) then
					tEnts[iEntsLen] = pEntity
				end
			end
		until (not bHitGlass)
		
		if tInfo.TracerName and tInfo.TracerName ~= "nil" then
			Tracer(bDebugShoot, vSrc, vFinalHit, bFirstTimePredicted, iTracerFreq, bWeaponValid and pWeapon, owner, iAmmoTracerType, iAmmoDamageType, sTracerName)
		end
	end
	
	if (bIsPlayer and !tInfo.DisableLagComp) then
		owner:LagCompensation(false)
	end
end

local tMaterialParameters = {
	[MAT_METAL] = {
		Penetration = 0.5,
		Damage = 0.3
	},
	[MAT_DIRT] = {
		Penetration = 0.5,
		Damage = 0.3
	},
	[MAT_CONCRETE] = {
		Penetration = 0.4,
		Damage = 0.25
	},
	[MAT_GRATE] = {
		Penetration = 1,
		Damage = 0.99
	},
	[MAT_VENT] = {
		Penetration = 0.5,
		Damage = 0.45
	},
	[MAT_TILE] = {
		Penetration = 0.65,
		Damage = 0.3
	},
	[MAT_COMPUTER] = {
		Penetration = 0.4,
		Damage = 0.45
	},
	[MAT_WOOD] = {
		Penetration = 1,
		Damage = 0.6
	},
	[MAT_GLASS] = {
		Penetration = 1,
		Damage = 0.99
	}
}

local tDoublePenetration = {
	[MAT_WOOD] = true,
	[MAT_METAL] = true,
	[MAT_GRATE] = true,
	[MAT_GLASS] = true
}

local MASK_HITBOX = bit.bor(MASK_SOLID, CONTENTS_DEBRIS, CONTENTS_HITBOX)

function PLAYER:FireCSSBullets(tInfo)
	if (hook.Run("EntityFireBullets", self, tInfo) == false) then
		return
	end
	
	local bIsPlayer = self:IsPlayer()
	
	if (bIsPlayer) then
		self:LagCompensation(true)
	end
	
	local pWeapon = self:GetActiveWeapon()
	local bWeaponValid = pWeapon:IsValid()
	
	-- FireCSSBullets info
	local iAmmoType
	
	if (tInfo.AmmoType == nil) then
		iAmmoType = -1
	elseif (isstring(tInfo.AmmoType)) then
		iAmmoType = game.GetAmmoID(tInfo.AmmoType)
	else
		iAmmoType = tInfo.AmmoType
	end
	
	local pAttacker = tInfo.Attacker and tInfo.Attacker:IsValid() and tInfo.Attacker or self
	local fCallback = tInfo.Callback
	local iDamage = tInfo.Damage or 0
	local flDecayRate = tInfo.DecayRate or 1/500
	local vDir = tInfo.Dir and tInfo.Dir:GetNormal() or self:GetAimVector()
	local flDistance = tInfo.Distance or MAX_TRACE_LENGTH
	local flExitMaxDistance = tInfo.ExitMaxDistance or 128
	local flExitStepSize = tInfo.ExitStepSize or 24
	
	local bFilterIsFunction
	local iFilterEnd
	local Filter = tInfo.Filter
	
	-- Yes, this is dirty
	-- But this prevents tables from being created when it's not necessary
	-- Also supports functional filters
	if (isentity(Filter)) then
		iFilterEnd = -1
		bFilterIsFunction = false
	elseif (istable(Filter)) then
		-- Length of the table will be found if penetration happens
		--iFilterEnd = #Filter
		bFilterIsFunction = false
	elseif (isfunction(Filter)) then
		bFilterIsFunction = true
	else
		Filter = self
		iFilterEnd = -1
		bFilterIsFunction = false
	end
	
	local iFlags = tInfo.Flags or 0
	local flForce = tInfo.Force or 1
	--local flHitboxTolerance = tInfo.HitboxTolerance or 40
	local bHullTrace = tInfo.HullTrace or false
	local pInflictor = tInfo.Inflictor and tInfo.Inflictor:IsValid() and tInfo.Inflictor or bWeaponValid and pWeapon or self
	local iMask = tInfo.Mask or MASK_HITBOX
	local iNPCDamage = tInfo.NPCDamage or 0
	local iNum = tInfo.Num or 1
	local iPenetration = tInfo.Penetration or 0
	local iPlayerDamage = tInfo.PlayerDamage or 0
	local flRangeModifier = tInfo.RangeModifier or 1
	local vSrc = tInfo.Src or self:GetShootPos()
	local iTracerFreq = tInfo.Tracer or 1
	local sTracerName = tInfo.TracerName or "Tracer"
	
	-- Effects
	local sSplashEffect = tInfo.SplashEffect or "gunshotsplash"
	local sImpactEffect = tInfo.ImpactEffect or "Impact"
	local sRagdollImpactEffect = tInfo.RagdollImpactEffect or "RagdollImpact"
	
	-- Ammo
	local tAmmoData = game.GetAmmoData(iAmmoType) or tDefaultAmmoTable
	local iAmmoFlags = tAmmoData.flags
	local flAmmoForce = tAmmoData.force
	local iAmmoDamageType = tAmmoData.dmgtype
	local iAmmoMinSplash = tAmmoData.minsplash
	local iAmmoMaxSplash = tAmmoData.maxsplash
	local iAmmoTracerType = tAmmoData.tracer
	
	local iAmmoNPCDamage = tAmmoData.npcdmg
	
	if (isstring(iAmmoNPCDamage)) then
		iAmmoNPCDamage = GetConVar(iAmmoNPCDamage):GetFloat()
	end
	
	local iAmmoPlayerDamage = tAmmoData.plydmg
	
	if (isstring(iAmmoPlayerDamage)) then
		iAmmoPlayerDamage = GetConVar(iAmmoPlayerDamage):GetFloat()
	end
	
	-- FIXME: These should be tied to ammo types
	local flPenetrationDistance = tInfo.PenetrationDistance or 0
	local flPenetrationPower = tInfo.PenetrationPower or 0
	
	-- Loop values
	local bDrop = bit.band(iAmmoFlags, AMMO_FORCE_DROP_IF_CARRIED) ~= 0
	local bDebugShoot = ai_debug_shoot_positions:GetBool()
	local bFirstShotInaccurate = bit.band(iFlags, FIRE_BULLETS_FIRST_SHOT_ACCURATE) == 0
	local flPhysPush = phys_pushscale:GetFloat()
	local bShowPenetration = sv_showpenetration:GetBool()
	local bStartedInWater = bit.band(util.PointContents(vSrc), MASK_WATER) ~= 0
	local bFirstTimePredicted = IsFirstTimePredicted()
	local flSpreadBias, vShootRight, vShootUp, vFireBulletMin, vFireBulletMax, tEnts, iEntsLen
	
	// Wrap it for network traffic so it's the same between client and server
	local iSeed = self:GetMD5Seed() % 0x100
	
	-- Don't calculate stuff we won't end up using
	if (bFirstShotInaccurate or iNum ~= 1) then
		local vSpread = tInfo.Spread or vector_origin
		flSpreadBias = tInfo.SpreadBias or 0.5
		vShootRight = vDir:Right()
		vShootRight:Mul(vSpread[1])
		vShootUp = vDir:Up()
		vShootUp:Mul(vSpread[2])
		
		if (bHullTrace and iNum ~= 1) then
			local flHullSize = tInfo.HullSize
			vFireBulletMax = flHullSize and Vector(flHullSize, flHullSize, flHullSize) or Vector(3, 3, 3)
			vFireBulletMin = -vFireBulletMax
		end
	end
	
	local bDoDebugHit
	
	do
		//Adrian: visualize server/client player positions
		//This is used to show where the lag compesator thinks the player should be at.
		local iHitNum = sv_showplayerhitboxes:GetInt()
		
		if (iHitNum > 0) then
			local pLagPlayer = Player(iHitNum)
			
			if (pLagPlayer:IsValid()) then
				pLagPlayer:DrawHitBoxes(DEBUG_LENGTH)
			end
		end
		
		iHitNum = sv_showimpacts:GetInt()
		bDoDebugHit = iHitNum == 1 or (CLIENT and iHitNum == 2) or (SERVER and iHitNum == 3)
	end
	
	for iShot = 1, iNum do
		local vShotDir
		iSeed = iSeed + 1 // use new seed for next bullet
		gs.random:SetSeed(iSeed) // init random system with this seed
		
		-- Loop values
		local flCurrentDamage = iDamage	// damage of the bullet at it's current trajectory
		local flCurrentPlayerDamage = iPlayerDamage
		local flCurrentNPCDamage = iNPCDamage
		local flCurrentDistance = 0	// distance that the bullet has traveled so far
		local vNewSrc = vSrc
		local vFinalHit
		
		// add the spray 
		if (bFirstShotInaccurate or iShot ~= 1) then
			vShotDir = vDir + vShootRight * (gs.random:RandomFloat(-flSpreadBias, flSpreadBias) + gs.random:RandomFloat(-flSpreadBias, flSpreadBias))
			+ vShootUp * (gs.random:RandomFloat(-flSpreadBias, flSpreadBias) + gs.random:RandomFloat(-flSpreadBias, flSpreadBias))
			vShotDir:Normalize()
		else
			vShotDir = vDir
		end
		
		local vEnd = vNewSrc + vShotDir * flDistance
		
		repeat
			local tr = bHullTrace and iShot % 2 == 0 and
				// Half of the shotgun pellets are hulls that make it easier to hit targets with the shotgun.
				util.TraceHull({
					start = vNewSrc,
					endpos = vEnd,
					mins = vFireBulletMin,
					maxs = vFireBulletMax,
					mask = iMask,
					filter = Filter
				})
			or
				util.TraceLine({
					start = vNewSrc,
					endpos = vEnd,
					mask = iMask,
					filter = Filter
				})
			
			// Check for player hitboxes extending outside their collision bounds
			--util.ClipTraceToPlayers(tr, vNewSrc, vEnd + vShotDir * flHitboxTolerance, Filter, iMask)
			
			local vHitPos = tr.HitPos
			vFinalHit = vHitPos
			
			local bEndNotWater = bit.band(util.PointContents(vHitPos), MASK_WATER) == 0
			Splash(vHitPos, bStartedInWater, bEndNotWater, vSrc, bWeaponValid and pWeapon, bFirstTimePredicted, iAmmoDamageType, iAmmoMinSplash, iAmmoMaxSplash, sSplashEffect)
			
			if (not tr.Hit or tr.HitSky) then
				break // we didn't hit anything, stop tracing shoot
			end
			
			/************* MATERIAL DETECTION ***********/
			-- https://github.com/Facepunch/garrysmod-requests/issues/923
			local iEnterMaterial = tr.MatType
			
			-- https://github.com/Facepunch/garrysmod-requests/issues/787
			// since some railings in de_inferno are CONTENTS_GRATE but CHAR_TEX_CONCRETE, we'll trust the
			// CONTENTS_GRATE and use a high damage modifier.
			// If we're a concrete grate (TOOLS/TOOLSINVISIBLE texture) allow more penetrating power.
			local bHitGrate = iEnterMaterial == MAT_GRATE or bit.band(util.PointContents(vHitPos), CONTENTS_GRATE) ~= 0
			
			// calculate the damage based on the distance the bullet travelled.
			flCurrentDistance = flCurrentDistance + tr.Fraction * flDistance
			local flDecay = flRangeModifier ^ (flCurrentDistance * flDecayRate)
			flCurrentDamage = flCurrentDamage * flDecay
			flCurrentPlayerDamage = flCurrentPlayerDamage * flDecay
			flCurrentNPCDamage = flCurrentNPCDamage * flDecay
			
			Damage(bDoDebugHit, bStartedWater, bEndNotWater, iFlags, flCurrentDamage, flCurrentPlayerDamage, flCurrentNPCDamage, bIsPlayer and iAmmoPlayerDamage or iAmmoNPCDamage, pAttacker,
				pInflictor, iAmmoDamageType, tr, bWeaponValid and pWeapon, vShotDir, flAmmoForce, flForce, flPhysPush, iAmmoType, vSrc, fCallback, bFirstTimePredicted, bDrop, sImpactEffect, sRagdollImpactEffect)
			
			// check if we reach penetration distance, no more penetrations after that
			if (flCurrentDistance > flPenetrationDistance and iPenetration > 0) then
				iPenetration = 0
			end
			
			// check if bullet can penetrate another entity
			// If we hit a grate with iPenetration == 0, stop on the next thing we hit
			if (iPenetration == 0 and not bHitGrate or iPenetration < 0) then
				break
			end
			
			local pEntity = tr.Entity
			
			if (pEntity:IsBreakable() and pEntity:HasSpawnFlags(SF_BREAK_NO_BULLET_PENETRATION)) then
				break // no, stop
			end
			
			if (tEnts == nil) then
				tEnts = ents.GetAll()
				iEntsLen = #tEnts
			end
			
			if (pEntity:IsWorld()) then
				local flExitDistance = 0
				
				local tr = tr
				local tTrace = {
					mask = iMask,
					filter = tEnts,
					output = tr
				}
				
				// try to penetrate object, maximum penetration is 128 inch
				while (flExitDistance < flExitMaxDistance) do
					flExitDistance = math.min(flExitMaxDistance, flExitDistance + flExitStepSize)
					
					local vHit = vHitPos + flExitDistance * vShotDir
					tTrace.start = vHit
					tTrace.endpos = vHit
					util.TraceLine(tTrace)
					
					if (not tr.Hit) then
						// found first free point
						goto PositionFound
					end
				end
				
				-- Nowhere to penetrate
				do break end
				
				::PositionFound::
				
				tTrace.endpos = vHitPos
				util.TraceLine(tTrace)
			else
				local bReplace = false
				
				-- Trace for only the entity we hit
				for i = iEntsLen, 1, -1 do
					if (tEnts[i] == pEntity) then
						tEnts[i] = tEnts[iEntsLen]
						tEnts[iEntsLen] = nil
						bReplace = true
						
						break
					end
				end
				
				util.TraceLine({
					start = vEnd,
					endpos = vHitPos,
					mask = iMask,
					filter = tEnts,
					ignoreworld = true,
					output = tr
				})
				
				-- Should never be false
				if (bReplace) then
					tEnts[iEntsLen] = pEntity
				end
			end
			
			vNewSrc = tr.HitPos
			vEnd = vNewSrc + vShotDir * flDistance
			
			if (bShowPenetration) then
				debugoverlay.Line(vHitPos, vNewSrc, DEBUG_LENGTH, color_altdebug)
			end
			
			local iExitMaterial = tr.MatType
			local tMatParams = tMaterialParameters[iEnterMaterial]
			local flPenetrationModifier = bHitGrate and 1 or tMatParams and tMatParams.Penetration or 1
			local flDamageModifier = bHitGrate and 0.99 or tMatParams and tMatParams.Damage or 0.5
			local flTraceDistance = (vNewSrc - vHitPos):LengthSqr()
			
			// if enter & exit point is wood or metal we assume this is 
			// a hollow crate or barrel and give a penetration bonus
			if (bHitGrate and (iExitMaterial == MAT_GRATE or bit.band(util.PointContents(tr.HitPos), CONTENTS_GRATE) ~= 0) or iEnterMaterial == iExitMaterial and tDoublePenetration[iExitMaterial]) then
				flPenetrationModifier = flPenetrationModifier * 2	
			end

			local flPenetrationDistance = flPenetrationPower * flPenetrationModifier
			
			// check if bullet has enough power to penetrate this distance for this material
			if (flTraceDistance > flPenetrationDistance * flPenetrationDistance) then
				break // bullet hasn't enough power to penetrate this distance
			end
			
			if (bDoDebugHit) then
				debugoverlay.Box(tr.HitPos, vector_debug_min, vector_debug_max, DEBUG_LENGTH, color_altdebug)
			end
			
			// bullet did penetrate object, exit Decal
			Impact(bWeaponValid and pWeapon, iAmmoDamageType, bFirstTimePredicted, vSrc, tr, sImpactEffect, sRagdollImpactEffect)
			
			// penetration was successful
			flTraceDistance = math.sqrt(flTraceDistance)
			
			// setup new start end parameters for successive trace
			flPenetrationPower = flPenetrationPower - flTraceDistance / flPenetrationModifier
			flCurrentDistance = flCurrentDistance + flTraceDistance
			
			// reduce damage power each time we hit something other than a grate
			flCurrentDamage = flCurrentDamage * flDamageModifier
			flDistance = (flDistance - flCurrentDistance) * 0.5
			
			// reduce penetration counter
			iPenetration = iPenetration - 1
			
			-- Can't hit players more than once
			if (pEntity:IsPlayer() or pEntity:IsNPC()) then
				if (bFilterIsFunction) then
					local fOldFilter = Filter
					Filter = function(pTest)
						return fOldFilter(pTest) and pTest ~= pEntity
					end
				elseif (iFilterEnd == -1) then
					Filter = {Filter, pEntity}
					iFilterEnd = 2
				else
					iFilterEnd = (iFilterEnd or #Filter) + 1
					Filter[iFilterEnd] = pEntity
				end
			end
		until (flCurrentDamage <= 0)
		
		Tracer(bDebugShoot, vSrc, vFinalHit, bFirstTimePredicted, iTracerFreq, bWeaponValid and pWeapon, self, iAmmoTracerType, iAmmoDamageType, sTracerName)
	end
	
	if (bIsPlayer) then
		self:LagCompensation(false)
	end
end