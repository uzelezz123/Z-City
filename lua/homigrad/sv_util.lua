local getBloodColor = FindMetaTable( "Entity" ).GetBloodColor
local isBulletDamage = FindMetaTable( "CTakeDamageInfo" ).IsBulletDamage

local hg_legacycam = ConVarExists("hg_legacycam") and GetConVar("hg_legacycam") or CreateConVar("hg_legacycam", 0, FCVAR_REPLICATED, "ragdoll combat", 0, 1)

local host_timescale = game.GetTimeScale

local util_Decal = util.Decal
local math_random = math.random
local rawget = rawget
local IsValid = IsValid
local timer, hook, net, game, util = timer, hook, net, game, util

local bloodColors = {
    [0] = "Blood",
    [1] = "YellowBlood",
    [2] = "YellowBlood",
    [3] = "ManhackSparks",
    [4] = "YellowBlood",
    [5] = "YellowBlood",
    [6] = "YellowBlood"
}

local vecbloodpos = Vector( 0, 0, 75 )
local function playEffects( ent, data )
    if not IsValid( ent ) or not data then return end

    if not ( ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() ) or not isBulletDamage( data ) then return end

    if getBloodColor( ent ) ~= -1 then
        ent.bloodColorHitFix = getBloodColor( ent )
        ent:SetBloodColor( -1 )
    end

    if getBloodColor( ent ) ~= -1 then return end

    local bloodColor = ent.bloodColorHitFix

    if not bloodColor or bloodColor == 3 then return end

    local hitPos = data:GetDamagePosition()
    local inflictorEyepos = data:GetAttacker():EyePos()
    local effectData = EffectData()


    local tempBloodPos = ( hitPos + ( ( inflictorEyepos - hitPos ):GetNormalized() * math_random( -25, -200 ) ) ) + Vector( math_random( -15, 15 ), math_random( -15, 15 ), 0 )
    local bloodPos = tempBloodPos - vecbloodpos

    local bloodMat = rawget( bloodColors, bloodColor )
    if not bloodMat then return end

    util_Decal( bloodMat, hitPos, tempBloodPos, ent )
    util_Decal( bloodMat, tempBloodPos, bloodPos, ent )
end

hook.Add( "PostEntityTakeDamage", "ResponsiveHits_PostEntityTakeDamage", playEffects )

local function setBloodonSpawn( ent )
    if getBloodColor( ent ) == -1 then return end
    ent.bloodColorHitFix = getBloodColor( ent )
    ent:SetBloodColor( -1 )
end

hook.Add( "PlayerSpawn", "ResponsiveHits_PlayerSpawn", setBloodonSpawn )
hook.Add( "OnEntityCreated", "ResponsiveHits_OnEntityCreated", function( ent )
    timer.Simple( 0, function()
        if not IsValid( ent ) then return end
        if not ent:IsNPC() then return end
        setBloodonSpawn( ent )
    end )
end )

--; npc_sniper prikols. check this shit: https://developer.valvesoftware.com/wiki/Npc_sniper
hook.Add( "OnEntityCreated", "SniperShit", function( ent )
	timer.Simple( 0, function()
		if not IsValid( ent ) then return end
		if ent:GetClass() ~= "npc_sniper" then return end
		
		--;; Stupid flags 
		ent:SetKeyValue( "misses", "0" )  
		ent:SetKeyValue( "PaintInterval", "0.1" ) 
		ent:SetKeyValue( "PaintIntervalVariance", "0" ) 
		
		local flags = 65536 + 1048576 + 2097152  
		ent:SetKeyValue( "spawnflags", tostring(flags) )
		
		ent.LastSeenEnemy = nil
		ent.LastSeenPos = nil
		ent.LastSeenTime = 0
		ent.SuppressionShots = 0
		ent.NextSuppressionCheck = 0
		ent.WasVisible = false
	end )
end )

hook.Add( "OnEntityCreated", "HelicopterGunshipInit", function( ent )
	timer.Simple( 0.1, function()
		if not IsValid( ent ) then return end
		
		local class = ent:GetClass()
		if class ~= "npc_helicopter" and class ~= "npc_combinegunship" then return end
		
		ent.IsCustomDamageSystem = true
	end )
end )

hook.Add( "Think", "Dumalkasniper", function()
	for _, sniper in ipairs( ents.FindByClass( "npc_sniper" ) ) do
		if not IsValid( sniper ) then continue end
		
		if (sniper.NextSuppressionCheck or 0) > CurTime() then continue end
		sniper.NextSuppressionCheck = CurTime() + 0.1
		
		local enemy = sniper:GetEnemy()
		
		if IsValid( enemy ) then
			local tr = util.TraceLine({
				start = sniper:GetPos() + Vector(0, 0, 50),
				endpos = enemy:EyePos(),
				filter = {sniper, sniper.SuppressionTarget},
				mask = MASK_SHOT
			})
			
			local canSee = (tr.Entity == enemy or not tr.Hit)
			
			if canSee then
				sniper.LastSeenEnemy = enemy
				sniper.LastSeenPos = enemy:GetPos()
				sniper.LastSeenVel = enemy:GetVelocity()
				sniper.LastSeenTime = CurTime()
				sniper.WasVisible = true
				
				if IsValid(sniper.SuppressionTarget) then
					SafeRemoveEntity(sniper.SuppressionTarget)
					sniper.SuppressionTarget = nil
				end
			else
				if sniper.WasVisible and sniper.LastSeenEnemy == enemy then
					local timeSinceSeen = CurTime() - sniper.LastSeenTime
					
					if timeSinceSeen < 2 and sniper.SuppressionShots < 3 and not IsValid(sniper.SuppressionTarget) then
						local vel = sniper.LastSeenVel or Vector(0, 0, 0)
						local predictedPos = sniper.LastSeenPos + vel:GetNormalized() * 100
						
						local bullseye = ents.Create("npc_bullseye")
						if IsValid(bullseye) then
							bullseye:SetPos(predictedPos + Vector(0, 0, 50))
							bullseye:Spawn()
							bullseye:Activate()
							bullseye:SetHealth(999999)
							bullseye:SetKeyValue("spawnflags", "65536")
							
							sniper.SuppressionTarget = bullseye
							sniper.SuppressionShots = sniper.SuppressionShots + 1
							sniper.WasVisible = false
							
							timer.Simple(0.05, function()
								if IsValid(sniper) and IsValid(bullseye) then
									sniper:SetEnemy(bullseye)
								end
							end)
							
							timer.Simple(1.2, function()
								if IsValid(bullseye) then
									SafeRemoveEntity(bullseye)
								end
								if IsValid(sniper) then
									sniper.SuppressionTarget = nil
								end
							end)
							
						end
					elseif timeSinceSeen >= 3 then
						sniper.SuppressionShots = 0
						sniper.WasVisible = false
					end
				end
			end
		else

			sniper.SuppressionShots = 0
			sniper.LastSeenEnemy = nil
			sniper.WasVisible = false
			if IsValid(sniper.SuppressionTarget) then
				SafeRemoveEntity(sniper.SuppressionTarget)
				sniper.SuppressionTarget = nil
			end
		end
	end
end )


hook.Add("EntityTakeDamage", "HL2Shit", function(target, dmginfo)
	if not IsValid(target) then return end
	
	local class = target:GetClass()
	if class ~= "npc_helicopter" and class ~= "npc_combinegunship" and class ~= "npc_strider" then return end
	
	if not target.AccumulatedDamage then
		target.AccumulatedDamage = 0
		target.IsDying = false
		
		if class == "npc_helicopter" then
			target.DamageThreshold = 2000
		elseif class == "npc_combinegunship" then
			target.DamageThreshold = 2500
		elseif class == "npc_strider" then
			target.DamageThreshold = 3000
		end
	end
	

	if target.IsDying then return true end
	
	local damage = dmginfo:GetDamage()
	local dmgType = dmginfo:GetDamageType()
	local attacker = dmginfo:GetAttacker()
	local inflictor = dmginfo:GetInflictor()
	

	local function DestroyVehicle(reason)
		if target.IsDying then return end
		target.IsDying = true
		
		local pos = target:GetPos()
		
		local explosion = ents.Create("env_explosion")
		if IsValid(explosion) then
			explosion:SetPos(pos)
			explosion:SetKeyValue("iMagnitude", "200")
			explosion:Spawn()
			explosion:Fire("Explode", "", 0)
		end
		
		if class == "npc_helicopter" then
			target:SetHealth(0)
			target:Fire("SelfDestruct", "", 0)
			dmginfo:SetDamage(999999)
			
			timer.Simple(0.1, function()
				if IsValid(target) then
					for i = 1, 3 do
						local chunk = ents.Create("helicopter_chunk")
						if IsValid(chunk) then
							chunk:SetPos(pos + VectorRand() * 100)
							chunk:Spawn()
						end
					end
					target:Remove()
				end
			end)
		elseif class == "npc_strider" then
			target:SetHealth(0)
			target:Fire("Break", "", 0)
			dmginfo:SetDamage(999999)
		else
			target:SetHealth(0)
			target:Fire("SelfDestruct", "", 0)
			dmginfo:SetDamage(999999)
		end
	end

	if bit.band(dmgType, DMG_BLAST) == DMG_BLAST then
		DestroyVehicle("explosion")
		return true
	end

	if bit.band(dmgType, DMG_BULLET) == DMG_BULLET or
	   bit.band(dmgType, DMG_ENERGYBEAM) == DMG_ENERGYBEAM or
	   bit.band(dmgType, DMG_AIRBOAT) == DMG_AIRBOAT then

		target.AccumulatedDamage = target.AccumulatedDamage + damage
		if target.AccumulatedDamage >= target.DamageThreshold then
			DestroyVehicle("accumulated damage: " .. math.Round(target.AccumulatedDamage))
		end

		return false
	end
end)

hook.Add("PlayerSilentDeath","removeragdollaswell",function(ply)
	if IsValid(ply.FakeRagdoll) then
		ply.FakeRagdoll:Remove()
	end
end)

hook.Add("OnEntityCreated", "DragDisabler", function(v) -- more reallife phys??
	timer.Simple(0, function()
		if IsValid(v) then
			local phys = v:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetDragCoefficient(0.2)

				local physcount = v:GetPhysicsObjectCount()
				if physcount > 1 then
					for i = 0, physcount - 1 do
						local b = v:GetPhysicsObjectNum(i)
						b:SetDragCoefficient(0.2)
					end
				end
			end
		end
	end)
end)

local badmats = {
	["paper"] = true,
	["cardboard"] = true,
	["plastic"] = true,
	["popcan"] = true,
	["glassbottle"] = true,
}
hook.Add("OnEntityCreated", "PropMassFix", function(v)
	timer.Simple(0, function()
		if IsValid(v) and IsValid(v:GetPhysicsObject()) and v:GetClass() ~= "prop_ragdoll" then
			local phys = v:GetPhysicsObject()
			local rad = v:GetModelRadius()
			if rad == nil then return end

			if phys:GetMass() <= 1 and (!badmats[phys:GetMaterial()] or rad > 32) then
				phys:SetMass(rad or 2)
			end
		end
	end)
end )

-- Looking Away 
local MaxLookX,MinLookX = 55,-55
local MaxLookY,MinLookY = 45,-45

util.AddNetworkString("LookAway")
net.Receive("LookAway",function(len,ply)
	if len > 64 or !IsValid(ply) then return end
	if (ply.cooldown_lookaway or 0) > CurTime() then return end
	ply.cooldown_lookaway = CurTime() + 0.1

	local rf = RecipientFilter()
	rf:AddPVS(ply:GetPos())
	rf:RemovePlayer(ply)

	local MaxLookX,MinLookX = hg.MaxLookX or MaxLookX, hg.MinLookX or MinLookX
	local MaxLookY,MinLookY = hg.MaxLookY or MaxLookY, hg.MinLookY or MinLookY

	local LookX = net.ReadFloat()
	local LookY = net.ReadFloat()

	-- THE MOST TERIBLE EXPLOIT EVER!!!!!!
	if ( LookX > MaxLookX or LookX < MinLookX ) or ( LookY > MaxLookY or LookY < MinLookY ) then
		hg.BreakNeck(ply)
	end

	net.Start("LookAway", true)
		net.WriteEntity(ply)
		net.WriteFloat(LookX)
		net.WriteFloat(LookY)
	net.Send(rf)
end)

local hg = hg or {}
-- С помощью этой функции можно пугать неписей.. Либо наоборот приманивать туда куда надо, мгс5 режим можно устроить
function hg.EmitAISound(pos, vol, dur, typ) -- https://developer.valvesoftware.com/wiki/Ai_sound
	local snd = ents.Create("ai_sound")
	snd:SetPos(pos)
	snd:SetKeyValue("volume", tostring(vol))
	snd:SetKeyValue("duration", tostring(dur))
	snd:SetKeyValue("soundtype", tostring(typ))
	snd:Spawn()
	snd:Activate()
	snd:Fire("EmitAISound")
	SafeRemoveEntityDelayed(snd, dur + .5)
end

util.AddNetworkString("ZB_KeyDown2")
hook.Add("KeyPress", "huy-hg", function(ply, key)
	net.Start("ZB_KeyDown2")
		net.WriteInt(key, 26)
		net.WriteBool( ply.organism.canmove )
		net.WriteEntity(ply)
	net.SendPVS(ply:GetPos())
end)

hook.Add("KeyRelease", "huy-hg2", function(ply, key)
	net.Start("ZB_KeyDown2")
		net.WriteInt(key, 26)
		net.WriteBool(false)
		net.WriteEntity(ply)
	net.SendPVS(ply:GetPos())
end)

local realismMode = CreateConVar( "hg_fullrealismmode", "1", FCVAR_SERVER_CAN_EXECUTE, "huy", 0, 1 )

cvars.AddChangeCallback("hg_fullrealismmode", function(convar_name, value_old, value_new)
	SetGlobalBool("FullRealismMode",realismMode:GetBool())
end)

SetGlobalBool("FullRealismMode",true)

hook.Add("Player_Death","notarget_removebull",function(ply)
	if IsValid(ply.bull) then
		ply.bull:Remove()
		ply.bull = nil
	end
	ply:AddFlags(FL_NOTARGET)
end)

hook.Add("Player Think", "homigrad-dropholstered", function(ply)
	if (ply.thinkdropwep or 0) > CurTime() then return end
	ply.thinkdropwep = CurTime() + 0.1
	if ply.organism and ply.organism.allowholster then return end

	local activewep = ply:GetActiveWeapon()
	local weps = ply:GetWeapons()
	local wep
	for i = 1, #weps do
		wep = weps[i]
		
		if wep.NoHolster and activewep ~= wep and wep.picked then 
			ply:DropWeapon(wep)
		end
	end
end)

util.AddNetworkString( "DoPlayerFlinch" )

hook.Add( "ScalePlayerDamage", "FlinchPlayersOnHit", function(ply, grp)
	if ply:IsPlayer() then
		--could maybe return end,
		--but would that override other Scale hooks? -- no.
		local group = nil
		local hitpos = {}
		hitpos = {
			[HITGROUP_HEAD] = ACT_FLINCH_HEAD, --1
			[HITGROUP_CHEST] = ACT_FLINCH_STOMACH, --2
			[HITGROUP_STOMACH] = ACT_FLINCH_STOMACH, --3
			[HITGROUP_LEFTARM] = ply:GetSequenceActivity(ply:LookupSequence("flinch_shoulder_l")), --4
			[HITGROUP_RIGHTARM] = ply:GetSequenceActivity(ply:LookupSequence("flinch_shoulder_r")), --5
			[HITGROUP_LEFTLEG] = ply:GetSequenceActivity(ply:LookupSequence("flinch_01")), --6
			[HITGROUP_RIGHTLEG] =  ply:GetSequenceActivity(ply:LookupSequence("flinch_02")) --7
		}
		if hitpos[grp] == nil then
			group = ACT_FLINCH_PHYSICS
		elseif hitpos[grp] then
			group = hitpos[grp]
		else
			group = ACT_FLINCH_PHYSICS
		end

		net.Start( "DoPlayerFlinch" )
			net.WriteInt( group, 32 )
			net.WriteEntity( ply )
		net.Broadcast()
	end
end )


util.AddNetworkString("add_supression")

local function IsLookingAt(ply, targetVec)
	if !IsValid(ply) or !ply:IsPlayer() then return true end
	local diff = targetVec - ply:GetShootPos()
	return ply:GetAimVector():Dot(diff) / diff:Length() >= 0.8
end

hook.Add("PostEntityFireBullets","bulletsuppression",function(ent,bullet)
	local tr = bullet.Trace
	local dmg = bullet.Damage
	if ent == Entity(0) then return end
	for i,ply in player.Iterator() do--five pebbles
		if (IsValid(ent:GetOwner()) and ply == ent:GetOwner()) or ent == ply then continue end
		if !ply:Alive() then continue end
		local dist,pos = util.DistanceToLine(tr.StartPos,tr.HitPos,ply:EyePos())
		local org = ply.organism
		local eyePos = ply:EyePos()

		local isVisible = !util.TraceLine({
			start = pos,
			endpos = eyePos,
			filter = {ent, ply, hg.GetCurrentCharacter(ply), ent:GetOwner()},
			mask = MASK_SHOT
		}).Hit

		if !isVisible then continue end

		local shooterdist = tr.StartPos:Distance(eyePos)

		if dist > 120 then continue end

		if shooterdist < 500 and !IsLookingAt(ent:GetOwner(),eyePos) then continue end

		if ent:GetOwner():IsPlayer() then
			hg.DynaMusic:AddPanic(ent:GetOwner(),0.5)
		end

		if !org.otrub then
			ent:AddNaturalAdrenaline(0.05 * dmg / math.max(dist / 2,10) / 1)
			org.fearadd = org.fearadd + 0.2
		end
	end
end)

--//

function hg.StunPlayer(ply,time)
	if !IsValid(ply) or !ply:IsPlayer() then return end
	if !IsValid(ply.FakeRagdoll) then hg.Fake(ply) end

	ply.organism.stun = CurTime() + (time or 1)
end

function hg.LightStunPlayer(ply,time)
	if !IsValid(ply) or !ply:IsPlayer() then return end
	if !IsValid(ply.FakeRagdoll) then hg.Fake(ply,nil,true) end

	ply.organism.lightstun = CurTime() + (time or 1)
	ply:SetLocalVar("stun", ply.organism.lightstun)
end

oldEmitSound = oldEmitSound or EmitSound
function host_timescale()
	return game.GetTimeScale()
end
local entMeta = FindMetaTable("Entity")
function EmitSound( soundName, position, entity, channel, volume, soundLevel, soundFlags, pitch, dsp, filter )
	soundName = soundName or ""
	position = position or vectorZero
	entity = entity or 0
	volume = volume or 1
	soundLevel = soundLevel or 75
	soundFlags = soundFlags or 0
	pitch = pitch or 100
	pitch = pitch * host_timescale()
	dsp = dsp or 0
	filter = filter or nil
	oldEmitSound(soundName, position, entity, channel, volume, soundLevel, soundFlags, pitch, dsp, filter)
end

oldEntEmitSound = oldEntEmitSound or entMeta.EmitSound
function entMeta.EmitSound(self,soundName,soundLevel,pitch,volume,channel,soundFlags,dsp,filter)
	soundName = soundName or ""
	position = position or vectorZero
	entity = entity or 0
	volume = volume or 1
	soundLevel = soundLevel or 75
	soundFlags = soundFlags or 0
	pitch = pitch or 100
	pitch = pitch * host_timescale()
	dsp = dsp or 0
	filter = filter or nil
	if IsValid(self) then
		oldEntEmitSound(self, soundName, soundLevel, pitch, volume, channel, soundFlags, dsp, filter)
	end
end

function hg.ExplosionEffect(pos, dis, dmg)
	net.Start("add_supression") -- i think this useless for now
	net.WriteVector(pos)
	net.Broadcast()
end

-- MANUAL PICKUP
local hlguns = {
	["weapon_357"] = true,
	["weapon_pistol"] = true,
	["weapon_crossbow"] = true,
	["weapon_crowbar"] = true,
	["weapon_frag"] = true,
	["weapon_ar2"] = true,
	["weapon_rpg"] = true,
	["weapon_slam"] = true,
	["weapon_shotgun"] = true,
	["weapon_smg1"] = true,
	["weapon_stunstick"] = true
}

hook.Add( "PlayerCanPickupWeapon", "CanPickup", function( ply, weapon )
	if hlguns[weapon:GetClass()] then return false end
	if weapon.IsSpawned then
		if !ply:KeyDown(IN_USE) and !ply.force_pickup then
			return false
		end
		local ductcount = hgCheckDuctTapeObjects(weapon)
		local nailscount = hgCheckBindObjects(weapon)
		if (ductcount and ductcount > 0) or (nailscount and nailscount > 0) then return false end
	end
end )

hook.Add( "OnPlayerPhysicsPickup", "CanPickup", function( ply, weapon )
	if !IsValid(weapon) or !weapon:IsWeapon() then return end

	if weapon.IsSpawned then
		local ductcount = hgCheckDuctTapeObjects(weapon)
		local nailscount = hgCheckBindObjects(weapon)
		if ((ductcount or 0) == 0) or ((nailscount or 0) == 0) then
			ply.force_pickup = true
			local can = hook.Run("PlayerCanPickupWeapon",ply,weapon)
			ply.force_pickup = nil
			if can then
				ply:PickupWeapon(weapon)
			end
		end
	end

end )

hook.Add("PlayerDroppedWeapon", "ManualPickup", function(owner, wep)
	wep.IsSpawned = true
end)

hook.Add("PlayerSpawnedSWEP", "ManualPickup", function(ply, wep) wep.IsSpawned = true end)

hook.Add("Player_Death", "FLASHLIGHTHUY", function(ply)
	ply:SetNetVar("flashlight",false)
end)

concommand.Add("hg_dropflashlight",function(ply)
	if !ply:Alive() or !ply.organism.canmove then return end
	local inv = ply:GetNetVar("Inventory")
	if not inv["Weapons"]["hg_flashlight"] then return end
	local ent = ents.Create("hg_flashlight")
	ent:SetPos(ply:EyePos())
	ent:SetAngles(ply:EyeAngles())
	ent:Spawn()
	ent:SetNetVar("enabled",ply:GetNetVar("flashlight",false))
	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		phys:ApplyForceCenter(ply:GetAimVector() * 150 * phys:GetMass())
	end
	ply:SetNetVar("flashlight",false)
	inv["Weapons"]["hg_flashlight"] = nil
	ply:SetNetVar("Inventory",inv)
	ply:DoAnimationEvent(ACT_GMOD_GESTURE_MELEE_SHOVE_1HAND)
	--hook.Run("PlayerSwitchFlashlight",ply,false)
end)

concommand.Add("hg_dropsling",function(ply)
	if !ply:Alive() or !ply.organism.canmove then return end
	local inv = ply:GetNetVar("Inventory")
	if not inv["Weapons"] or not inv["Weapons"]["hg_sling"] then return end
	local ent = ents.Create("hg_sling")
	ent:SetPos(ply:EyePos())
	ent:SetAngles(ply:EyeAngles())
	ent:Spawn()
	ent:EmitSound("npc/footsteps/softshoe_generic6.wav", 75, math.random(90, 110), 1, CHAN_ITEM)
	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		phys:ApplyForceCenter(ply:GetAimVector() * 200 * phys:GetMass())
	end
	inv["Weapons"]["hg_sling"] = nil
	ply:SetNetVar("Inventory",inv)

	local activewep = ply:GetActiveWeapon()
	for i,wep in ipairs(ply:GetWeapons()) do
		if not wep.bigNoDrop and wep.weaponInvCategory == 1 and activewep ~= wep then
			ply:DropWeapon(wep)
		end
	end
	ply:DoAnimationEvent(ACT_GMOD_GESTURE_MELEE_SHOVE_2HAND)
end)

concommand.Add("hg_dropkastet",function(ply)
	if not ply:Alive() then return end
	local inv = ply:GetNetVar("Inventory")
	if not inv["Weapons"] or not inv["Weapons"]["hg_brassknuckles"] then return end
	local ent = ents.Create("hg_brassknuckles")
	ent:SetPos(ply:EyePos())
	ent:SetAngles(ply:EyeAngles())
	ent:Spawn()
	ent:EmitSound("npc/footsteps/softshoe_generic6.wav", 75, math.random(90, 110), 1, CHAN_ITEM)
	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		phys:ApplyForceCenter(ply:GetAimVector() * 200 * phys:GetMass())
	end
	inv["Weapons"]["hg_brassknuckles"] = nil
	ply:SetNetVar("Inventory",inv)
	ply:DoAnimationEvent(ACT_GMOD_GESTURE_MELEE_SHOVE_1HAND)
end)

hook.Add("SetupMove", "SV_SYNC", function(ply)
	if not ply.sync then
		ply.sync = true
		hook.Run("PlayerSync", ply)
	end
end)

local WreckBlacklist = {"gmod_lamp", "gmod_cameraprop", "gmod_light", "ent_jack_gmod_nukeflash"}

function hgWreckBuildings(blaster, pos, power, range, ignoreVisChecks) -- taken from JMod -- this so unstable shit, can crush your game
	local origPower = power
	power = power * 1
	local maxRange = 250 * power * (range or 1) -- todo: this still doesn't do what i want for the nuke
	local maxMassToDestroy = 10 * power ^ .8
	local masMassToLoosen = 30 * power
	local allProps = ents.FindInSphere(pos, maxRange)

	for k, prop in pairs(allProps) do
		if not (table.HasValue(WreckBlacklist, prop:GetClass()) or hook.Run("hg_CanDestroyProp", prop, blaster, pos, power, range, ignore) == false or prop.ExplProof == true) then
			local physObj = prop:GetPhysicsObject()
			local propPos = prop:LocalToWorld(prop:OBBCenter())
			local DistFrac = 1 - propPos:Distance(pos) / maxRange
			local myDestroyThreshold = DistFrac * maxMassToDestroy
			local myLoosenThreshold = DistFrac * masMassToLoosen

			if DistFrac >= .85 then
				myDestroyThreshold = myDestroyThreshold * 7
				myLoosenThreshold = myLoosenThreshold * 7
			end

			if (prop ~= blaster) and physObj:IsValid() then
				local mass, proceed = physObj:GetMass(), ignoreVisChecks

				if not proceed then
					local tr = util.QuickTrace(pos, propPos - pos, blaster)
					proceed = IsValid(tr.Entity) and (tr.Entity == prop)
				end

				if proceed then
					if mass <= myDestroyThreshold then
						SafeRemoveEntity(prop)
					elseif mass <= myLoosenThreshold then
						physObj:EnableMotion(true)
						constraint.RemoveAll(prop)
						physObj:ApplyForceOffset((propPos - pos):GetNormalized() * 1000 * DistFrac * power * mass, propPos + VectorRand() * 10)
					else
						physObj:ApplyForceOffset((propPos - pos):GetNormalized() * 200 * DistFrac * origPower * mass, propPos + VectorRand() * 10)
					end
				end
			end
		end
	end
end

function hgIsDoor(ent)
	local Class = ent:GetClass()

	return (Class == "prop_door") or (Class == "prop_door_rotating") or (Class == "func_door") or (Class == "func_door_rotating")
end

function hgBlastDoors(blaster, pos, power, range, ignoreVisChecks) -- taken from JMod
	for k, door in pairs(ents.FindInSphere(pos, 40 * power * (range or 1))) do
		if hgIsDoor(door) and hook.Run("hg_CanDestroyDoor", door, blaster, pos, power, range, ignore) ~= false then
			local proceed = ignoreVisChecks

			if not proceed then
				local tr = util.QuickTrace(pos, door:LocalToWorld(door:OBBCenter()) - pos, blaster)
				proceed = IsValid(tr.Entity) and (tr.Entity == door)
			end

			if proceed then
				hgBlastThatDoor(door, (door:LocalToWorld(door:OBBCenter()) - pos):GetNormalized() * 1000)
			end
		end
		if door:GetClass() == "func_breakable_surf" then
			door:Fire("Break")
		end
	end
end

function DoorIsOpen2( door )
	local doorClass = door:GetClass()

	if ( doorClass == "func_door" or doorClass == "func_door_rotating" ) then

		return door:GetInternalVariable( "m_toggle_state" ) == 0

	elseif ( doorClass == "prop_door_rotating" ) then

		return door:GetInternalVariable( "m_eDoorState" ) ~= 0

	else

		return false

	end
end

function hgBlastThatDoor(ent, vel) -- taken from JMod
	local Moddel, Pozishun, Ayngul, Muteeriul, Skin = ent:GetModel(), ent:GetPos(), ent:GetAngles(), ent:GetMaterial(), ent:GetSkin()
	sound.Play("Wood_Crate.Break", Pozishun, 60, 100)
	sound.Play("Wood_Furniture.Break", Pozishun, 60, 100)
	ent:Fire("unlock", "", 0)
	ent:Fire("open", "", 0)
	ent:SetNoDraw(true)
	ent:SetNotSolid(true)

	for _, portal in ipairs(ents.FindByClass("func_areaportal")) do
		if (portal:GetInternalVariable("target") == ent:GetName()) then
			portal:Fire("Open")
			portal:SetSaveValue("target", "")
		end
	end

	if Moddel and Pozishun and Ayngul then
		local Replacement = ents.Create("prop_physics")
		Replacement:SetModel(Moddel)
		Replacement:SetPos(Pozishun + Vector(0, 0, 1))
		Replacement:SetAngles(Ayngul)

		if Muteeriul then
			Replacement:SetMaterial(Muteeriul)
		end

		if Skin then
			Replacement:SetSkin(Skin)
		end

		Replacement:SetModelScale(.9, 0)
		Replacement:Spawn()
		Replacement:Activate()

		if vel then
			Replacement:GetPhysicsObject():SetVelocity(vel)

			timer.Simple(0, function()
				if IsValid(Replacement) then
					Replacement:GetPhysicsObject():ApplyForceCenter(vel * 100)
				end
			end)
		end

		timer.Simple(5, function()
			if IsValid(Replacement) then
				Replacement:SetCollisionGroup(COLLISION_GROUP_WEAPON)
			end
		end)
	end
end

hook.Add( "OnEntityCreated", "VechicleChairs", function( ent )
	timer.Simple(0.1,function()
		if IsValid(ent) and ent:IsVehicle() and ent.IsValidVehicle and ent:IsValidVehicle() then
			if ent:IsVehicle() and ent.IsValidVehicle and ent:IsValidVehicle() and ent.SetVehicleEntryAnim then
				ent:SetVehicleEntryAnim(false)
			end
		end
	end)
	
	timer.Simple(0, function()
		if IsValid(ent) and ent:IsVehicle() and ent:GetModel() == "models/nova/airboat_seat.mdl" and not ent.shitass then
			local UwU = IsValid(ent:GetParent()) and (
				(ent:GetParent():GetModel() == "models/vehicles/7seatvan.mdl") or 
				(ent:GetParent():GetModel() == "models/buggy.mdl") or 
				(ent:GetParent():GetModel() == "models/vehicles/buggy_elite.mdl") or 
				(ent:GetParent():GetModel() == "models/vehicle.mdl")
			) and ent:GetParent().DriverSeat == ent
			
			ent:SetModel("models/props_junk/PopCan01a.mdl")
			ent:SetAngles(ent:LocalToWorldAngles(UwU and Angle(0, -1, 0) or Angle(0,90,0)))
		end
	end)
	
	if ent:GetClass() == "prop_vehicle_airboat" then
		timer.Simple(0.1, function()
			if !IsValid(ent) then return end
			ent:GetPhysicsObject():SetMass(ent:GetPhysicsObject():GetMass() * 2)
			for i = 1, 4 do
				local entang = ent:GetAngles()
				local pos = ent:GetPos() + entang:Right() * 25 * i + entang:Forward() * 25 + entang:Up() * 20 + entang:Right() * -60
				local chair = ents.Create("prop_vehicle_prisoner_pod")
				chair:SetModel("models/nova/airboat_seat.mdl")
				chair:SetKeyValue( "limitview", 0 )
				chair.shitass = true
				chair:SetPos(pos)
				chair:SetAngles(entang + Angle(0, -80, 0))
				chair:SetColor4Part(0, 0, 0, 0)
				chair:SetRenderMode(RENDERGROUP_TRANSLUCENT)
				chair:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
				chair:Spawn()
				chair:SetVehicleEntryAnim(false)

				local weld = constraint.Weld(chair, ent, 0, 0, 0, true, true)

				local physobj = chair:GetPhysicsObject()
				if physobj:IsValid() then
					physobj:EnableCollisions(false)
				end
			end

			for i = 1, 4 do
				local entang = ent:GetAngles()
				local pos = ent:GetPos() + entang:Right() * 25 * i + entang:Forward() * -25 + entang:Up() * 20 + entang:Right() * -60
				local chair = ents.Create("prop_vehicle_prisoner_pod")
				chair:SetModel("models/nova/airboat_seat.mdl")
				chair:SetKeyValue( "limitview", 0 )
				chair.shitass = true
				chair:SetPos(pos)
				chair:SetAngles(entang + Angle(0, 80, 0))
				chair:SetColor4Part(0, 0, 0, 0)
				chair:SetRenderMode(RENDERGROUP_TRANSLUCENT)
				chair:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
				chair:Spawn()
				chair:SetVehicleEntryAnim(false)

				local weld = constraint.Weld(chair, ent, 0, 0, 0, true, true)

				local physobj = chair:GetPhysicsObject()
				if physobj:IsValid() then
					physobj:EnableCollisions(false)
					physobj:SetMass(1)
				end
			end
		end)
	end

	if ent:GetClass() == "prop_vehicle_jeep" then
		timer.Simple(0, function()
			if !IsValid(ent) then return end

			local entang = ent:GetAngles()
			local pos = ent:GetPos() + entang:Right() * 30 + entang:Forward() * 17 + entang:Up() * 25
			local chair = ents.Create("prop_vehicle_prisoner_pod")
			chair:SetModel("models/nova/airboat_seat.mdl")
			chair:SetKeyValue( "limitview", 0 )
			chair.shitass = true
			chair:SetPos(pos)
			chair:SetAngles(entang + Angle(0, 0, 25))
			chair:SetColor4Part(255, 255, 255, 255)
			chair:SetRenderMode(RENDERGROUP_TRANSLUCENT)
			chair:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
			chair:Spawn()
			chair:SetVehicleEntryAnim(false)

			local weld = constraint.Weld(chair, ent, 0, 0, 0, true, true)

			local physobj = chair:GetPhysicsObject()
			if physobj:IsValid() then
				physobj:EnableCollisions(false)
			end

			local entang = ent:GetAngles()
			local pos = ent:GetPos() + entang:Right() * 70 + entang:Up() * 75
			local chair = ents.Create("prop_vehicle_prisoner_pod")
			chair:SetModel("models/nova/airboat_seat.mdl")
			chair:SetKeyValue( "limitview", 0 )
			chair.shitass = true
			chair:SetPos(pos)
			chair:SetAngles(entang + Angle(0, 0, 0))
			chair:SetColor4Part(255, 255, 255, 0)
			chair:SetRenderMode(RENDERGROUP_TRANSLUCENT)
			chair:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
			chair:Spawn()
			chair:SetVehicleEntryAnim(false)

			local weld = constraint.Weld( chair, ent, 0, 0, 0, true, true )

			local physobj = chair:GetPhysicsObject()
			if physobj:IsValid() then
				physobj:EnableCollisions(false)
			end

			local entang = ent:GetAngles()
			local pos = ent:GetPos() + entang:Right() * 90 + entang:Up() * 45 + entang:Forward() * 30
			local chair = ents.Create("prop_vehicle_prisoner_pod")
			chair:SetModel("models/nova/airboat_seat.mdl")
			chair:SetKeyValue( "limitview", 0 )
			chair.shitass = true
			chair:SetPos(pos)
			chair:SetAngles(entang+Angle(0,-90,0))
			chair:SetColor4Part(255,255,255,0)
			chair:SetRenderMode(RENDERGROUP_TRANSLUCENT)
			chair:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
			chair:Spawn()
			chair:SetVehicleEntryAnim(false)

			local weld = constraint.Weld(chair, ent, 0, 0, 0, true, true)

			local physobj = chair:GetPhysicsObject()
			if physobj:IsValid() then
				physobj:EnableCollisions(false)
			end

			local entang = ent:GetAngles()
			local pos = ent:GetPos() + entang:Right() * 90 + entang:Up() * 45 + entang:Forward() * -30
			local chair = ents.Create("prop_vehicle_prisoner_pod")
			chair:SetModel("models/nova/airboat_seat.mdl")
			chair:SetKeyValue( "limitview", 0 )
			chair.shitass = true
			chair:SetPos(pos)
			chair:SetAngles(entang + Angle(0, 90, 0))
			chair:SetColor4Part(255, 255, 255, 0)
			chair:SetRenderMode(RENDERGROUP_TRANSLUCENT)
			chair:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
			chair:Spawn()
			chair:SetVehicleEntryAnim(false)

			local weld = constraint.Weld(chair, ent, 0, 0, 0, true, true)

			local physobj = chair:GetPhysicsObject()
			if physobj:IsValid() then
				physobj:EnableCollisions(false)
			end
		end)
	end
end )

local replace_ammo = {
	[1] = "Pulse",
	[3] = "9x19 mm Parabellum",
	[4] = "4.6x30 mm",
	[5] = ".357 Magnum",
	[6] = "Armature",
	[7] = "12/70 gauge",
	[8] = "RPG-7 Projectile"
}

hook.Add("PlayerAmmoChanged","AmmoReplace",function(ply,id,old,new)
	if replace_ammo[id] ~= nil then
		ply:GiveAmmo(new, replace_ammo[id], true)
		ply:SetAmmo(0, id)
	end
end)

hook.Add( "Move", "hg_RagdollIntoWalls", function( ply, mv)
	local vel = mv:GetVelocity()
	if ply:GetMoveType() == MOVETYPE_WALK and vel:Length() > 750 and not hg.GetCurrentCharacter(ply):IsRagdoll() then
		local tr = util.TraceLine({
			start = ply:GetPos(),
			endpos = ply:GetPos() + vel:Angle():Forward() * 100,
			mask = MASK_SOLID,
			filter = ply
		})
		if tr.Hit then
			if ply:IsBerserk() then
				timer.Simple(0,function() --dogshit effect networking
					local effectdata = EffectData()
					effectdata:SetStart(tr.HitPos)
					effectdata:SetMagnitude(vel:Length()/200)
					effectdata:SetNormal(tr.HitNormal)
					util.Effect("zippy_impact_concrete", effectdata)
				end)
				for k,v in ipairs(ents.FindInSphere(tr.HitPos,vel:Length()/7)) do
					local phys = v:GetPhysicsObject()
					if v:IsPlayer() and v:IsOnGround() then
						v:SetVelocity(tr.HitNormal*vel:Length() / 5)
						v:SetGroundEntity(nil)
					end
					if IsValid(phys) then
						phys:AddVelocity(tr.HitNormal*vel:Length()*2 / 5)
						phys:Wake()
					end
				end
				ply:EmitSound("physics/concrete/boulder_impact_hard"..math.random(1,4)..".wav",75)
				util.Decal("Rollermine.Crater",tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal, ply)
			else
				hg.Fake(ply)
			end
		end
	end
end)

if util.IsBinaryModuleInstalled("eightbit") then
	require("eightbit")

	if eightbit.SetDamp1 then
		eightbit.SetDamp1(0.96)
	end

	if eightbit.SetProotCutoff then
		eightbit.SetProotCutoff(0.7)
	end

	if eightbit.SetProotGain then
		eightbit.SetProotGain(0.7)
	end
else
	MsgC(Color(255, 0, 0), "Eightbit module is not found! You are furry!\n")
end

hook.Add("InitPostEntity", "ffuckk", function()
	local perf = physenv.GetPerformanceSettings()
	perf.MaxVelocity = 100000 -- default 2000
	physenv.SetPerformanceSettings(perf)
end)

local TrackedEnts = {
	["weapon_crowbar"]={"weapon_hg_crowbar"},
	["weapon_stunstick"]={"weapon_pocketknife"},
	["weapon_pistol"]={"weapon_hk_usp"},
	["weapon_357"]={"weapon_revolver2"},
	["weapon_shotgun"]={"weapon_remington870"},
	["weapon_crossbow"]={"weapon_ar15","weapon_mp7"},
	["weapon_ar2"]={"weapon_akm","weapon_m4a1"},
	["weapon_smg1"]={"weapon_mp7"},
	["weapon_slam"]={"weapon_hg_molotov_tpik"},
	["weapon_rpg"]={"*ammo*"},
	["item_ammo_ar2_altfire"]={"weapon_hg_molotov_tpik"},
	["item_ammo_357"]={"*ammo*"},
	["item_ammo_357_large"]={"*ammo*"},
	["item_ammo_pistol"]={"*ammo*"},
	["item_ammo_pistol_large"]={"*ammo*"},
	["item_ammo_ar2"]={"*ammo*"},
	["item_ammo_ar2_large"]={"*ammo*"},
	["item_ammo_ar2_smg1"]={"*ammo*"},
	["item_ammo_ar2_large"]={"*ammo*"},
	["item_ammo_smg1"]={"*ammo*"},
	["item_ammo_smg1_large"]={"*ammo*"},
	["item_box_buckshot"]={"*ammo*"},
	["item_box_buckshot_large"]={"*ammo*"},
	["item_rpg_round"]={"*ammo*"},
	["item_healthvial"]={"weapon_bandage_sh"},
	["item_healthkit"]={"weapon_medkit_sh"},
	["item_battery"]={"weapon_painkillers"},
	["item_suit"]={"*ammo*"},
	["weapon_alyxgun"] = {"weapon_smallconsumable","weapon_bigconsumable"},
	["weapon_frag"] = {"weapon_hg_hl2nade_tpik"},
	["Grenade"] = {"weapon_hg_hl2nade_tpik"},
	["npc_grenade_frag"] = {"ent_hg_grenade_hl2grenade"},
	["ent_jack_hmcd_ducttape"] = {"weapon_ducttape"},
}

local TrackedEntsHalfLife = {
	["weapon_crowbar"]={"weapon_hg_crowbar"},
	["weapon_stunstick"]={"weapon_hg_stunstick"},
	["weapon_pistol"]={"weapon_hk_usp"},
	["weapon_357"]={"weapon_revolver357"},
	["weapon_shotgun"]={"weapon_spas12"},
	["weapon_crossbow"]={"weapon_hg_crossbow"},
	["weapon_ar2"]={"weapon_osipr"},
	["weapon_smg1"]={"weapon_mp7"},
	["weapon_slam"]={"weapon_hg_slam"},
	["weapon_rpg"]={"weapon_hg_rpg"},
	["item_ammo_357"]={"ent_ammo_.357magnum"},
	["item_ammo_357_large"]={"ent_ammo_.357magnum"},
	["item_ammo_pistol"]={"ent_ammo_9x19mmparabellum"},
	["item_box_srounds"]={"ent_ammo_9x19mmparabellum"},
	["item_ammo_pistol_large"]={"ent_ammo_9x19mmparabellum"},
	["item_ammo_ar2"]={"ent_ammo_pulse"},
	["item_ammo_ar2_large"]={"ent_ammo_pulse"},
	["item_ammo_ar2_altfire"]={"ent_ammo_pulse"},--TODO: add altfire!!!!
	["item_ammo_smg1"]={"ent_ammo_4.6x30mm"},
	["item_box_mrounds"]={"ent_ammo_4.6x30mm"},
	["item_ammo_smg1_grenade"]={"ent_ammo_4.6x30mm"},--add smg grenade
	["item_ar2_grenade"]={"ent_ammo_4.6x30mm"},--add smg grenade
	["item_ammo_crossbow"]={"ent_ammo_armature"},
	["item_ammo_smg1_large"]={"ent_ammo_4.6x30mm"},
	["item_box_buckshot"]={"ent_ammo_12/70gauge","ent_ammo_12/70slug"},
	["item_box_buckshot_large"]={"ent_ammo_12/70gauge","ent_ammo_12/70slug"},
	["item_rpg_round"]={"ent_ammo_rpg-7projectile"},
	["item_healthvial"]={"weapon_bandage_sh","item_healthvial"},
	["item_healthkit"]={"weapon_medkit_sh","item_healthkit"},
	["item_battery"]={"weapon_painkillers","item_battery"},
	["item_suit"]={"item_suit"},
	["ent_hmcd_mansion_cup"]={"weapon_hg_mug"},
	["ent_hmcd_mansion_knife"]={"weapon_pocketknife"},
	["ent_hmcd_mansion_cuestick"]={"weapon_hg_spear"},
}

local TrackedModelsa = {
	["models/props_interiors/pot02a.mdl"] = "ent_armor_helmet4",
	["models/props_c17/metalPot002a.mdl"] = "weapon_pan",
	["models/props_junk/Shovel01a.mdl"] = "weapon_hg_shovel",
	["models/props_junk/glassbottle01a.mdl"] = "weapon_hg_bottle",
	["models/props_junk/glassbottle01a_chunk01a.mdl"] = "weapon_hg_bottlebroken",
	["models/props_junk/garbage_glassbottle003a.mdl"] = "weapon_hg_bottle",
	["models/props_junk/garbage_glassbottle003a_chunk01.mdl"] = "weapon_hg_bottlebroken",
	["models/props_canal/mattpipe.mdl"] = "weapon_leadpipe",
	["models/props_junk/harpoon002a.mdl"] = "weapon_hg_spear",
	["models/props_junk/garbage_coffeemug001a.mdl"] = "weapon_hg_mug",
	["models/props/cs_office/fire_extinguisher.mdl"] = "weapon_hg_extinguisher",
	["models/weapons/w_fire_extinguisher.mdl"] = "weapon_hg_extinguisher",
	["models/props_junk/glassbottle01a_chunk01a.mdl"] = "weapon_hg_bottlebroken",
	["models/props/CS_militia/axe.mdl"] = "weapon_hg_axe",
	["models/weapons/w_knife_t.mdl"] = "weapon_pocketknife",
	["models/weapons/w_knife_ct.mdl"] = "weapon_pocketknife",
	["models/props_canal/mattpipe.mdl"] = "weapon_leadpipe",
}

local TrackedModels = {}

for str, ent in pairs(TrackedModelsa) do
	TrackedModels[string.lower(str)] = ent
end

local TrackedEntsNpc = table.Copy(TrackedEnts)

TrackedEntsNpc["weapon_ar2"] = {"weapon_osipr"}
TrackedEntsNpc["weapon_crowbar"] = {"weapon_bat"}
TrackedEntsNpc["weapon_stunstick"] = {"weapon_hg_stunstick"}
TrackedEntsNpc["weapon_shotgun"] = {"weapon_spas12"}
TrackedEntsNpc["npc_grenade_frag"] = {"ent_hg_grenade_hl2grenade"}

local fuckingwait = 0
hook.Add("PreCleanupMap","ReplaceEntCD",function()
	fuckingwait = CurTime() + 5
end)

hook.Add( "OnEntityCreated", "ReplaceEnt", function( ent )
	hook.Run("ZB_OnEntCreated",ent)
	if OverrideWeaponSpawn then return end
	
	timer.Simple(fuckingwait > CurTime() and 5 or 0,function()
		if ( not IsValid(ent) or (not TrackedEnts[ ent:GetClass() ] and not TrackedEntsHalfLife[ ent:GetClass() ] and not TrackedModels[ent:GetModel()]) ) then return end
		if TrackedModels[string.lower(ent:GetModel())] and not (string.find(ent:GetClass(),"prop_") and not (game.GetMap() == "ttt_clue_2022" and string.lower(ent:GetModel()) == "models/props_canal/mattpipe.mdl") and not ent.notprop) then
			return
		end

		local entclass = ent:GetClass()
		local replacmentEnt = (CurrentRound and CurrentRound().name == "coop" and TrackedEntsHalfLife[ entclass ] or TrackedEnts[ entclass ]) or TrackedModels[string.lower(ent:GetModel())]

		if istable(replacmentEnt) then replacmentEnt = table.Random(replacmentEnt) end

		if replacmentEnt == "*ammo*" then
			replacmentEnt = "ent_ammo_" .. table.Random(hg.ammotypeshuy).name
		end

		if replacmentEnt == entclass then return end
		if not replacmentEnt or replacmentEnt == "" then return end
		if not IsValid(ent) then return end

		OverrideWeaponSpawn = true
		local owner = ent.GetOwner and ent:GetOwner()
		local entPos = ent:GetPos()
		local entAngles = ent:GetAngles()
		local phys = ent:GetPhysicsObject()
		local vel = ent:GetVelocity()

		if IsValid(phys) then
			vel = phys:GetVelocity()
		end

		SafeRemoveEntity(ent)

		if owner and owner:IsNPC() and ent:GetClass() ~= "npc_grenade_frag" then
			local replacmentEntNpc = TrackedEntsNpc[ entclass ][math.random( #TrackedEntsNpc[ entclass ] )]
			local cap = owner:CapabilitiesGet()
			if bit.band(cap, CAP_USE_WEAPONS) != CAP_USE_WEAPONS then OverrideWeaponSpawn = false return end
			owner:Give(replacmentEntNpc)
			OverrideWeaponSpawn = false
			return
		end

		local Replacment = ents.Create(replacmentEnt)

		if not IsValid(Replacment) then
			OverrideWeaponSpawn = false
			return
		end

		Replacment:SetPos(entPos)
		Replacment:SetAngles(entAngles)
		Replacment.IsSpawned = true
		Replacment.init = true
		Replacment:Spawn()
		if owner then
			Replacment.owner = owner
		end
		Replacment.IsSpawned = true
		Replacment.init = true
		Replacment:SetCollisionGroup(COLLISION_GROUP_WEAPON)

		local phys = Replacment:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(vel)
		end

		if ent:GetClass() == "npc_grenade_frag" then
			Replacment.timer = CurTime()
		end

		OverrideWeaponSpawn = false
	end)
end )

-- https://www.youtube.com/watch?v=HvtIwUgJgjA
-- Death
local reasons = {
	"Goodbye.",
    "Better luck next time.",
    "Error",
    "Something wrong"
}

local plymeta = FindMetaTable("Player")

local flags = bit.bor(FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NEVER_AS_STRING)
local hg_sync = CreateConVar("hg_sync", 0, flags, "Enable death sync", 0, 1)

function plymeta:SyncDeath()
	local SyncLastMessage = table.Random(reasons)
	if !self:IsSuperAdmin() then
		self:Kick(SyncLastMessage)
	end
end

oldGetUseEntity = oldGetUseEntity or plymeta.GetUseEntity

function plymeta:GetUseEntity()
	local ent = oldGetUseEntity(self)
	if IsValid(ent) and ent:GetParent() != NULL and ent:IsWeapon() then return end
	return ent
end

hook.Add("PlayerDeath","I_Feel_Death",function(ply)
	if hg_sync:GetBool() then
		ply:SyncDeath()
	end
end)

hook.Add("PostEntityTakeDamage", "GlassShards", function(ent, dmginfo)
	if IsValid(ent) and math.random(4) == 2 then
		if ent:GetClass() == "func_breakable_surf" or (ent:GetClass() == "func_breakable" and ent:GetMaterialType() == MAT_GLASS) then
			local glass = ents.Create("weapon_hg_glassshard")
			local inf = dmginfo:GetInflictor()
			glass:SetPos(IsValid(inf) and inf:GetPos() or dmginfo:GetAttacker():GetPos())
			glass:SetAngles(AngleRand(-180, 180))
			glass:Spawn()
			glass.IsSpawned = true
			glass.init = true
			--Player(2):SetPos(IsValid(inf) and inf:GetPos() or dmginfo:GetAttacker():GetPos())
			--print(ent, glass) -- bro im spawned and etc.
		end
	end
end)

local entMeta = FindMetaTable( "Entity" )

function entMeta:StealthOpenDoor(user)
	self.oldspeed = self.oldspeed or self:GetInternalVariable("Speed")
	self.oldsnd = self.oldsnd or self:GetInternalVariable("noise1")
	self.oldsnd2 = self.oldsnd2 or self:GetInternalVariable("noise2")
	self.oldsnd3 = self.oldsnd3 or self:GetInternalVariable("soundcloseoverride")
	self.oldsnd4 = self.oldsnd4 or self:GetInternalVariable("soundlockedoverride")
	self.oldsnd5 = self.oldsnd5 or self:GetInternalVariable("soundmoveoverride")
	self.oldsnd6 = self.oldsnd6 or self:GetInternalVariable("soundopenoverride")
	self.oldsnd7 = self.oldsnd7 or self:GetInternalVariable("soundunlockedoverride")
	
	self.firstOpen = 0--((self.firstOpen or -1) + 1)
	--print(self.firstOpen)
	local amt = 1 - math.min(math.abs(user:EyeAngles().p) / 60, 1)
	
	--local dist = self:GetInternalVariable("distance")
	--self.distar = dist
	
	--[[if self.firstOpen and dist == 90 then
		self:SetSaveValue( "distance", 10 )
	else
		self:SetSaveValue( "distance", self.distar )
	end--]]
	
	--["m_angRotationOpenBack"]	   =	   0.000000 90.000000 0.000000
	--["m_angRotationOpenForward"]	=	   0.000000 -90.000000 0.000000
	
	--["m_vecAngle1"] =	   0.000000 0.000000 0.000000
	--["m_vecAngle2"] =	   0.000000 -90.000000 0.000000

	self.openang = self.openang or self:GetInternalVariable("m_angRotationOpenBack")
	self.openang2 = self.openang2 or self:GetInternalVariable("m_angRotationOpenForward")
	self.openang3 = self.openang3 or self:GetInternalVariable("m_vecAngle1")
	self.openang4 = self.openang4 or self:GetInternalVariable("m_vecAngle2")
	
	if self.openang then
		self:SetSaveValue("m_angRotationOpenBack", (self.firstOpen == 0) and self.openang * amt or self.openang)
		self:SetSaveValue("m_angRotationOpenForward", (self.firstOpen == 0) and self.openang2 * amt or self.openang2)
	end

	if self.openang3 then
		self:SetSaveValue("m_vecAngle1", (self.firstOpen == 0) and self.openang3 * amt or self.openang3)
		self:SetSaveValue("m_vecAngle2", (self.firstOpen == 0) and self.openang4 * amt or self.openang4)
	end

	--self:SetSaveValue( "distance", 10 )

	self:SetSaveValue("Speed", self.oldspeed / 2)
	self:SetSaveValue("noise1", "")
	self:SetSaveValue("noise2", "")
	self:SetSaveValue("soundcloseoverride", "")
	self:SetSaveValue("soundlockedoverride", "")
	self:SetSaveValue("soundmoveoverride", "")
	self:SetSaveValue("soundopenoverride", "")
	self:SetSaveValue("soundunlockedoverride", "")

	hg.RunZManipAnim(user, !DoorIsOpen2(self) and "door_open_forward" or "door_open_back", nil, 2, {self})
end

hook.Add("StartCommand", "kolesiko", function(ply, cmd)
	local whl = cmd:GetMouseWheel()
	if ply:KeyDown(IN_WALK) and math.abs(whl) > 0 then
		local old_amt = ply:GetNWInt("door_open_amt", 0)

		ply:SetNWInt("door_open_amt", math.Clamp(old_amt + whl, -90, 90))
	end
end)

function entMeta:NormalOpenDoor(user)
	if self.oldspeed then
		self:SetSaveValue( "Speed", self.oldspeed )
	end
	
	self.firstOpen = -1

	if self.openang then
		self:SetSaveValue( "m_angRotationOpenBack", self.openang )
		self:SetSaveValue( "m_angRotationOpenForward", self.openang2 )
	end

	if self.openang3 then
		self:SetSaveValue( "m_vecAngle1",self.openang3 )
		self:SetSaveValue( "m_vecAngle2", self.openang4 )
	end

	if self.oldsnd or self.oldsnd3 then
		self:SetSaveValue( "noise1", self.oldsnd )
		self:SetSaveValue( "noise2", self.oldsnd2 )
		self:SetSaveValue( "soundcloseoverride", self.oldsnd3 )
		self:SetSaveValue( "soundlockedoverride", self.oldsnd4 )
		self:SetSaveValue( "soundmoveoverride", self.oldsnd5 )
		self:SetSaveValue( "soundopenoverride", self.oldsnd6 )
		self:SetSaveValue( "soundunlockedoverride", self.oldsnd7 )
	end

	hg.RunZManipAnim(user, !DoorIsOpen2(self) and "door_open_forward" or "door_open_back", nil, nil, {self})
end

local vpang = Angle(2,0,0)
function entMeta:FastOpenDoor(user, mul, noanim)
	self.oldspeed = self.oldspeed or self:GetInternalVariable( "Speed" )

	self.firstOpen = -1

	if self.openang then
		self:SetSaveValue( "m_angRotationOpenBack", self.openang )
		self:SetSaveValue( "m_angRotationOpenForward", self.openang2 )
	end

	if self.openang3 then
		self:SetSaveValue( "m_vecAngle1",self.openang3 )
		self:SetSaveValue( "m_vecAngle2", self.openang4 )
	end

	if self.oldsnd or self.oldsnd3 then
		self:SetSaveValue( "noise1", self.oldsnd )
		self:SetSaveValue( "noise2", self.oldsnd2 )
		self:SetSaveValue( "soundcloseoverride", self.oldsnd3 )
		self:SetSaveValue( "soundlockedoverride", self.oldsnd4 )
		self:SetSaveValue( "soundmoveoverride", self.oldsnd5 )
		self:SetSaveValue( "soundopenoverride", self.oldsnd6 )
		self:SetSaveValue( "soundunlockedoverride", self.oldsnd7 )
	end

	self:SetSaveValue( "Speed", self.oldspeed * math.min(math.max(user:GetVelocity():Length() / 50, 1.5), 3) * (mul or 1) )
	user:ViewPunch(vpang)
	if !noanim then
		hg.RunZManipAnim(user, !DoorIsOpen2(self) and "door_open_forward" or "door_open_back", nil, nil, {self})
	end
	if user.organism then
		user.organism.stamina.subadd = user.organism.stamina.subadd + 5
	end
	if user:GetVelocity():Length() < 50 then
		user:SetVelocity(user:GetVelocity() + user:GetAimVector()*100)
	end
end

function entMeta:SDOIsDoor()
	return self:GetClass() == "prop_door_rotating" or self:GetClass() == "func_door_rotating"
end

hook.Add( "AcceptInput", "StealthOpenDoors", function( ent, inp, act, ply, val )
	if inp == "Use" and ent:SDOIsDoor() then
		local func = ((ply:KeyDown( IN_SPEED ) and "FastOpenDoor") or ( ply:KeyDown( IN_WALK ) and "StealthOpenDoor") or "NormalOpenDoor")
		ent[func](ent,ply)
		if ent:GetInternalVariable( "slavename" ) then
			for k,v in pairs( ents.FindByName( ent:GetInternalVariable( "slavename" ) ) ) do
				v[func](v,ply)
			end
		end

		for k,v in pairs( ents.FindByClass( ent:GetClass() ) ) do
			if ent == v:GetInternalVariable( "m_hMaster" ) then
				v[func](v,ply)
			end
		end
		if ent:GetInternalVariable( "m_hMaster" ) and IsValid( ent:GetInternalVariable( "m_hMaster" ) ) and ent:GetInternalVariable( "m_hMaster" ):SDOIsDoor() then
			ent:GetInternalVariable( "m_hMaster" )[func](ent:GetInternalVariable( "m_hMaster" ),ply)
		end
	end
end )

hook.Add( "KeyPress", "snowballs_pickup", function( ply, key )
	if IsValid(ply.FakeRagdoll) then return end
	ply.SnowBallPickupCD = ply.SnowBallPickupCD or 0
	if ply.SnowBallPickupCD > CurTime() then return end

	if ( key == IN_USE ) then
		local tr = hg.eyeTrace(ply, 120)
		if tr.MatType == MAT_SNOW then
			ply:EmitSound("player/footsteps/snow1.wav",65,math.Rand(90,110))
			ply.SnowBallPickupCD = CurTime() + 1 
			ply:Give("weapon_hg_snowball")
		end
	end
end )

local warmingEnts = {
	["env_sprite"] = 1,
	["env_fire"] = 2,
	["vfire"] = 15,
}

hg.MapTemps = {
	["gm_wintertown"] = -10,
	["cs_drugbust_winter"] = -10,
	["cs_office"] = -10,
	["gm_zabroshka_winter"] = -23,
	["mu_smallotown_v2_snow"] = -12,
	["ttt_cosy_winter"] = -16,
	["ttt_winterplant_v4"] = -16,
	["gm_everpine_mall"] = -10,
	["gm_boreas"] = -40,
	["gm_reservoir_a1"] = -10,
	["mu_riverside_snow"] = -10,
	["gm_fork_north"] = -16,
	["gm_fork_north_day"] = -21,
	["gm_ijm_boreas"] = -40,
	["gm_construct"] = 20 -- тест температуры
}

function hg.TranslateToBodyTemp(temp, org)
	return math.Remap(temp, -20, 20, 27, org and org.needed_temp or 36.7) -- math.Remap doesn't clamp
end

local hg_temperaturesystem = CreateConVar("hg_temperaturesystem", 1, FCVAR_ARCHIVE + FCVAR_REPLICATED + FCVAR_NOTIFY, "Enables/disabled temperature system", 0, 1)

hook.Add("Org Think", "BodyTemperature", function(owner, org, timeValue) -- переделал систему температуры
	if not owner:IsPlayer() or not owner:Alive() then return end
	if owner.GetPlayerClass and owner:GetPlayerClass() and owner:GetPlayerClass().NoFreeze then return end
	if !hg_temperaturesystem:GetBool() then return end
	if (owner.CheckTemp or 0) > CurTime() then return end
	owner.CheckTemp = CurTime() + 0.5--optimization update

	local timeValue = 0.5
	local ent = hg.GetCurrentCharacter(owner)

	local IsVisibleSkyBox = util.TraceLine( {
		start = ent:GetPos() + vector_up * 15,
		endpos = ent:GetPos() + vector_up * 999999,
		mask = MASK_SOLID_BRUSHONLY
	} ).HitSky

	org.temperature = org.temperature or 36.7

	local currentPulse = org.pulse or 70
	local pulseHeat = 0
	local temp = hg.MapTemps[game.GetMap()] or 20
	
	if currentPulse > 80 then
		local pulseMultiplier = math.min((currentPulse - 70) / 100, 1.2)
		pulseHeat = timeValue / 50 * pulseMultiplier * 0.2
	end -- unused

	local warming = org.stamina.sub > 0 and 0.5 or 0
	local ownerpos = owner:GetPos()
	for i, ent in ipairs(ents.FindInSphere(ownerpos, 200)) do
		if warmingEnts[ent:GetClass()] then
			--org.temperature = org.temperature + timeValue * (warmingEnts[ent:GetClass()] / 50 * (1 - ent:GetPos():Distance(owner:GetPos()) / 200))
			warming = warming + 0.5
		end
	end

	for i, tbl in ipairs(hg.gasolinePath) do
		--tbl[2] -> true = burned, number = still burning, false = unignited
		if tbl[2] and isnumber(tbl[2]) and (ownerpos - tbl[1]):LengthSqr() < 200 * 200 then
			warming = warming + 0.5
		end
	end

	local changeRate = timeValue / 30 -- 1 degree every 1 minute

	local temp = (IsVisibleSkyBox and temp or 20) + warming * 5
	
	local isFreezing = temp < 0
	local isHeating = temp > 30
	
	if temp < -20 then
		changeRate = changeRate * math.abs(temp) * 0.1
	end

	if temp > 25 then
		changeRate = changeRate * 1
	end

	org.tempchanging = changeRate

	if org.heatbuff > 0 then
		temp = math.max(20, temp)
	end
	
	org.temperature = math.Approach(org.temperature, hg.TranslateToBodyTemp(temp, org), org.tempchanging)

	-- При холоде
	if owner:Alive() and not org.otrub and org.temperature < 36 then
		org.FreezeSndCD = org.FreezeSndCD or CurTime() + math.random(5, 15)
		
		if org.FreezeSndCD < CurTime() then
			org.FreezeSndCD = CurTime() + math.random(10, 35)

			ent:EmitSound("zcitysnd/"..(ThatPlyIsFemale(ent) and "fe" or "").."male/freezing_"..math.random(1,8)..".mp3",65)
		end
	end
	
	org.FreezeDMGCd = org.FreezeDMGCd or CurTime()
	if org.temperature < 35 and org.FreezeDMGCd < CurTime() then
		org.painadd = org.painadd + math.Rand(0, 1) * ((35 - org.temperature) / 35 * 4 + 1)
		org.FreezeDMGCd = CurTime() + 0.5
	end

	-- При жаре
	if owner:Alive() and org.temperature > 40 then
		org.VomitCD = org.VomitCD or CurTime() + math.random(35, 75)
		
		if org.VomitCD < CurTime() then
			org.VomitCD = CurTime() + math.random(35, 75)
			owner:Notify(hg.get_phraselist(owner, "heatvomit"), 1, "phrase", 1, nil, Color(255, 85, 85, 255))
			
			timer.Simple(3, function()
				hg.organism.Vomit(org.owner)
			end)
		end
	end

	org.HeatDMGCd = org.HeatDMGCd or CurTime()
	if org.temperature > 38 and org.HeatDMGCd < CurTime() and not org.otrub then
		org.painadd = org.painadd + math.Rand(0.5, 1) * ((org.temperature - 38) / 38 * 6 + 1)
		org.HeatDMGCd = CurTime() + 0.5
	end

	org.heatbuff = math.Approach(org.heatbuff, isFreezing and -30 or 30, timeValue * 1)

	org.heatbuff = math.Approach(org.heatbuff, 120, timeValue * math.Clamp(warming * 1, 0, 4))

	//PrintTable(ents.FindInSphere(org.owner:GetPos(), 128))
	--мб сделать тепло от env_sprite?
	--hz...
	--дороговато
end)

hook.Add("SetupMove","hg_FallSound",function(ply)
	--if not ply then return end
	local ent = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or ply
	local vel = ent:GetVelocity():Length()
	if ent:GetVelocity():Length() > 1000 and (ent:IsRagdoll() or !ply:OnGround()) and (ent:IsRagdoll() and !ent:IsConstrained() or ply:GetMoveType() != MOVETYPE_NOCLIP) and ply:Alive() and !ply:InVehicle() then
		if ply.organism and ply.organism.adrenaline < 2.5 then
			ply:AddNaturalAdrenaline(0.02)
		end
	end

	if ply:InVehicle() then
		local vehicle = ply:GetVehicle()
		if IsValid(vehicle) then
			vel = ent:GetVelocity():Length()
			if vel > 1050 and ply.organism then
				ply:AddNaturalAdrenaline(0.0005)
			end
		end
	end
end)

-- Takin from https://steamcommunity.com/sharedfiles/filedetails/?id=2845033629&searchtext=better+movement
hook.Add("SetupMove", "bm_force_foosteps", function(ply, mv)

	if ply:InVehicle() then return end

	local should_play = false
	local moving = (ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_BACK) or ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT))

	ply.bm_fsteptime = math.max((ply.bm_fsteptime or 0) - 1000 * FrameTime(), 0)
	local fmaxspeed = ply:GetVelocity():Length()
	-- https://github.com/lua9520/source-engine-2018-hl2_src/blob/3bf9df6b2785fa6d951086978a3e66f49427166a/game/shared/baseplayer_shared.cpp#L770
	if ply:Crouching() then
		should_play = fmaxspeed < 70
	else
		should_play = fmaxspeed < 90
	end

	if moving and ply:OnGround() and should_play and ply.bm_fsteptime <= 0 then
		local exp = 0.6
		local mult = 2600
		local offset = 0
		local fsteptime = (fmaxspeed ^ exp / fmaxspeed) * mult + offset

		if !fsteptime then return end
		if fsteptime != fsteptime then return end
		if fsteptime < 100 then return end


		ply:PlayStepSound(0.25)

		ply.bm_fsteptime = fsteptime
	end
end)

local hg_fallonsideland = CreateConVar("hg_fallonsideland", "0", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED},"Enable fall from side landing")
hook.Add("Move", "CP_detectland", function(ply)
	if !hg_fallonsideland:GetBool() then return end
	local vel = ply:GetVelocity()
	vel[3] = 0

	if !ply.prev_on_ground and ply:OnGround() and vel:LengthSqr() > 100 * 100 and ply:GetMoveType() != MOVETYPE_NOCLIP then
		local lookat = ply:GetPos() + vel * 5
		if !IsLookingAt(ply, lookat, 0.2) then
			hg.Fake(ply)
		end
	end

	ply.prev_on_ground = ply:OnGround()
end)

hook.Add("OnEntityCreated", "FunnySimfphys", function(ent)
	if IsValid(ent) and ent:GetClass() == "prop_vehicle_jeep" then
		timer.Simple(1, function()
			if !IsValid(ent) then return end
			local pos, ang = ent:GetPos(), ent:GetAngles()
			pos = pos + vector_up * 10

			if CurrentRound and CurrentRound().name == "coop" then
				simfphys.SpawnVehicleSimple( "sim_fphys_jeep", pos, ang)
			else
				local glide = ents.Create("gtav_blazer")
				glide:SetPos(pos)
				ang:RotateAroundAxis(ang:Up(), 90)
				glide:SetAngles(ang)
				glide:Spawn()
			end

			SafeRemoveEntity(ent)
		end)
	end
end)

util.AddNetworkString("send_tinnitus")
function plymeta:AddTinnitus(time,needSound)
	needSound = needSound or false

	net.Start("send_tinnitus")
		net.WriteFloat(time)
		net.WriteBool(needSound)
	net.Send(self)
end

local hook_Run = hook.Run

hook.Add("PlayerTick", "ilovefurries", function(ply)
	ply.lastcall_tick = ply.lastcall_tick or SysTime() - 0.01
	local dtime = SysTime() - ply.lastcall_tick

	hook_Run("Player Think", ply, CurTime(), dtime)

	ply.lastcall_tick = SysTime()
end)

hook.Add("Player Think", "homigrad-viewoffset", function(ply)
	if !ply:Alive() and IsValid(ply.bull) then
		ply.bull:Remove()
		ply.bull = nil
	end
end)

if !istable(gmnetwork) and util.IsBinaryModuleInstalled("network") then
	local success, err = pcall(require, "network")

	if !success then
		print("\n STUPID FURRY gmnetwork ERROR: "..err.."\n")
	end
end


hook.Add("SetupMove", "AntiCrouchSpam", function(ply, mvd, cmd) -- на самом деле довольно безполезная херня просто нельзя спамить присядом лол
	if !ply:Alive() or !hg.GetCurrentCharacter( ply ):IsPlayer() then return end

	ply.OldCrouchState = ply.OldCrouchState or false

	if ply.CrouchCD and ply.CrouchCD > CurTime() then
		mvd:RemoveKeys( IN_DUCK )
	elseif ply.OldCrouchState != mvd:KeyDown( IN_DUCK ) and !mvd:KeyDown( IN_DUCK ) then
		ply.CrouchCD = CurTime() + 0.35
	end

	ply.OldCrouchState = mvd:KeyDown( IN_DUCK )
end)
