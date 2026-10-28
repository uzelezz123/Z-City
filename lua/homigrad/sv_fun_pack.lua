-- Optional collection of small, chaotic combat reactions.
-- Each feature is deliberately self-contained so servers can override it with hooks.
hg = hg or {}
hg.fun = hg.fun or {}

local enabled = CreateConVar("hg_fun_pack", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Enable extra combat reactions", 0, 1)
local intensity = CreateConVar("hg_fun_pack_intensity", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Extra combat reaction intensity", 0.25, 2)

local function Ready(ply, key, delay)
	if not enabled:GetBool() or not IsValid(ply) or not ply:IsPlayer() then return false end
	ply.hgFunCooldowns = ply.hgFunCooldowns or {}
	if (ply.hgFunCooldowns[key] or 0) > CurTime() then return false end
	ply.hgFunCooldowns[key] = CurTime() + delay
	return true
end

-- 1. A hard arm hit can knock a non-essential weapon out of your hands.
function hg.fun.TryDisarm(ply, severity)
	if severity < 28 or math.random(100) > math.min(55, severity) or not Ready(ply, "disarm", 7) then return end
	local wep = ply:GetActiveWeapon()
	if not IsValid(wep) or wep:GetClass() == "weapon_hands" or wep:GetClass() == "weapon_physgun" then return end
	ply:DropWeapon(wep)
	ply:EmitSound("physics/metal/weapon_impact_soft2.wav", 65, math.random(95, 110))
	hook.Run("HG_FunDisarmed", ply, wep)
end

-- 2. Heavy leg wounds briefly spoil balance without forcing permanent ragdoll combat.
function hg.fun.TryStumble(ply, severity)
	if severity < 18 or math.random(100) > 45 or not Ready(ply, "stumble", 3) then return end
	if hg.LightStunPlayer then hg.LightStunPlayer(ply, math.Clamp(severity / 18, 1, 3)) end
	ply:ViewPunch(Angle(math.Rand(-7, -3), math.Rand(-4, 4), math.Rand(-5, 5)))
	hook.Run("HG_FunStumbled", ply)
end

-- 3. Strong hits physically shove standing players in the direction of the blow.
function hg.fun.ApplyHitPush(ply, dmgInfo, severity)
	if severity < 20 or not Ready(ply, "push", 0.25) then return end
	local force = dmgInfo:GetDamageForce()
	if force:LengthSqr() <= 1 then return end
	ply:SetVelocity(force:GetNormalized() * math.min(severity * 3.5 * intensity:GetFloat(), 240))
end

-- 4. Surviving a near-fatal hit grants a short, modest adrenaline reserve.
function hg.fun.AdrenalineKick(ply, severity)
	local org = ply.organism
	if severity < 35 or not org or not org.stamina or not Ready(ply, "adrenaline", 25) then return end
	org.stamina[1] = math.min((org.stamina[1] or 0) + 22 * intensity:GetFloat(), 100)
	org.pain = math.max((org.pain or 0) - 4, 0)
	ply:EmitSound("player/heartbeat1.wav", 58, 115)
	hook.Run("HG_FunAdrenaline", ply, org)
end

-- 5. Nearby explosions throw the victim into a short conventional ragdoll stun.
function hg.fun.TryBlastFall(ply, dmgInfo, severity)
	if not dmgInfo:IsDamageType(DMG_BLAST) or severity < 16 or not Ready(ply, "blastfall", 4) then return end
	if hg.StunPlayer then hg.StunPlayer(ply, math.Clamp(severity / 25, 0.7, 2.5)) end
	hook.Run("HG_FunBlastFall", ply)
end

-- 6. Blunt trauma gets a distinct breath/impact reaction between spoken phrases.
function hg.fun.PlayImpactGrunt(ply, dmgInfo, severity)
	if severity < 10 or not dmgInfo:IsDamageType(DMG_CLUB + DMG_CRUSH) or not Ready(ply, "grunt", 2.5) then return end
	local gender = ThatPlyIsFemale(ply) and "female" or "male"
	ply:EmitSound("vo/npc/" .. gender .. "01/hitingut0" .. math.random(1, 3) .. ".wav", 72, ply.VoicePitch or 100)
end

-- 7. Head impacts create an audiovisual-feeling jolt using stock ringing and view punch.
function hg.fun.HeadRinging(ply, severity)
	if severity < 14 or not Ready(ply, "ringing", 8) then return end
	ply:EmitSound("ambient/levels/citadel/weapon_disintegrate2.wav", 48, 180, 0.35)
	ply:ViewPunch(Angle(math.Rand(-12, 5), math.Rand(-8, 8), math.Rand(-8, 8)))
	hook.Run("HG_FunHeadRinging", ply, severity)
end

-- 8. Serious wounds warn the player in-world instead of requiring a statistics menu.
function hg.fun.BloodLossWarning(ply)
	local org = ply.organism
	if not org or (org.blood or 5000) > 3600 or not Ready(ply, "bloodwarning", 18) then return end
	ply:Notify(table.Random({
		"I feel cold... I'm losing too much blood.",
		"My vision is getting heavy. I need a bandage.",
		"I'm getting weaker with every heartbeat."
	}), true, "bloodloss", 0)
end

-- 9. The final blow carries its direction into the corpse for livelier deaths.
function hg.fun.RememberDeathImpulse(ply, dmgInfo, severity)
	if severity < 8 then return end
	ply.hgLastDamageForce = dmgInfo:GetDamageForce()
	ply.hgLastDamagePos = dmgInfo:GetDamagePosition()
end

-- 10. Newly-created death ragdolls receive a one-shot impulse instead of dropping flat.
function hg.fun.ApplyDeathImpulse(ply)
	local force = ply.hgLastDamageForce
	if not force or force:LengthSqr() <= 1 then return end
	timer.Simple(0.05, function()
		if not IsValid(ply) then return end
		local rag = ply:GetNWEntity("RagdollDeath")
		if not IsValid(rag) then rag = ply.RagdollDeath end
		if not IsValid(rag) then return end
		local phys = rag:GetPhysicsObject()
		if IsValid(phys) then phys:ApplyForceCenter(force:GetNormalized() * math.min(force:Length() * 0.35, 9000) * intensity:GetFloat()) end
	end)
end

hook.Add("HomigradDamage", "HG_FunPackDamage", function(ply, dmgInfo, hitgroup, ent, harm)
	if not enabled:GetBool() or not IsValid(ply) or not ply:IsPlayer() then return end
	local severity = math.max(harm or 0, dmgInfo:GetDamage())
	hg.fun.RememberDeathImpulse(ply, dmgInfo, severity)
	hg.fun.ApplyHitPush(ply, dmgInfo, severity)
	hg.fun.AdrenalineKick(ply, severity)
	hg.fun.TryBlastFall(ply, dmgInfo, severity)
	hg.fun.PlayImpactGrunt(ply, dmgInfo, severity)
	hg.fun.BloodLossWarning(ply)

	if hitgroup == HITGROUP_LEFTARM or hitgroup == HITGROUP_RIGHTARM then hg.fun.TryDisarm(ply, severity) end
	if hitgroup == HITGROUP_LEFTLEG or hitgroup == HITGROUP_RIGHTLEG then hg.fun.TryStumble(ply, severity) end
	if hitgroup == HITGROUP_HEAD then hg.fun.HeadRinging(ply, severity) end
end)

hook.Add("PlayerDeath", "HG_FunPackDeathImpulse", function(ply)
	if enabled:GetBool() then hg.fun.ApplyDeathImpulse(ply) end
end)
