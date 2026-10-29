-- Deterministic reactions for genuinely strong hits. These are intentionally
-- grounded: no death launch, no blast duplicate, and no random proc chance.
hg = hg or {}
local strong = CreateConVar("hg_strong_hit_threshold", "32", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Damage needed for strong-hit reactions", 10, 100)

local function severity(dmgInfo, harm)
	return math.max(dmgInfo:GetDamage(), harm or 0)
end

local function cooldown(ply, key, delay)
	ply.hgReactionCooldown = ply.hgReactionCooldown or {}
	if (ply.hgReactionCooldown[key] or 0) > CurTime() then return false end
	ply.hgReactionCooldown[key] = CurTime() + delay
	return true
end

local function strongDisarm(ply, amount, hitgroup)
	if amount < strong:GetFloat() or not cooldown(ply, "disarm", 2.5) then return end
	if hitgroup ~= HITGROUP_LEFTARM and hitgroup ~= HITGROUP_RIGHTARM then return end
	local wep = ply:GetActiveWeapon()
	if not IsValid(wep) or wep:GetClass() == "weapon_hands_sh" or wep:GetClass() == "weapon_physgun" then return end
	ply:DropWeapon(wep)
	ply:EmitSound("physics/metal/weapon_impact_soft2.wav", 65, math.random(95, 105))
end

local function strongStumble(ply, amount, hitgroup)
	if amount < strong:GetFloat() or not cooldown(ply, "stumble", 1.5) then return end
	if hitgroup ~= HITGROUP_LEFTLEG and hitgroup ~= HITGROUP_RIGHTLEG then return end
	if hg.LightStunPlayer then hg.LightStunPlayer(ply, math.Clamp(amount / 24, 1, 2.5)) end
end

local function strongAdrenaline(ply, amount)
	if amount < strong:GetFloat() or not cooldown(ply, "adrenaline", 8) then return end
	local org = ply.organism
	if not org or not org.stamina then return end
	org.stamina[1] = math.min((org.stamina[1] or 0) + math.Clamp(amount * 0.65, 20, 45), 100)
	org.adrenaline = math.min((org.adrenaline or 0) + 0.15, 2)
end

local function groundedPush(ply, dmgInfo, amount)
	if amount < strong:GetFloat() or not cooldown(ply, "push", 0.2) then return end
	if IsValid(ply.FakeRagdoll) or dmgInfo:IsDamageType(DMG_BLAST) then return end
	local force = dmgInfo:GetDamageForce()
	if force:LengthSqr() < 1 then return end
	local dir = force:GetNormalized()
	-- Keep ordinary firefights readable: mostly horizontal displacement, no launches.
	dir.z = math.Clamp(dir.z, -0.1, 0.12)
	dir:Normalize()
	local push = math.Clamp(amount * 1.5, 35, 135)
	if not ply:IsOnGround() then push = push * 0.35 end
	ply:SetVelocity(dir * push)
end

hook.Add("HomigradDamage", "GroundedStrongHitReactions", function(ply, dmgInfo, hitgroup, ent, harm)
	if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then return end
	local amount = severity(dmgInfo, harm)
	strongDisarm(ply, amount, hitgroup)
	strongStumble(ply, amount, hitgroup)
	strongAdrenaline(ply, amount)
	groundedPush(ply, dmgInfo, amount)
end)
