AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

SWEP.CurState = -1 -- -1 = idle; 0 = period between ready and idle; 1 = ready

function SWEP:SoundEmit(snd, vol, pitch, volstupid) -- хо ро шо я тебя услышал
	sound.Play(snd, self:GetPos(), vol, pitch, volstupid)
end


local bashvpang = Angle(-8,0,0)
-- self:PlayAnim(anim,time,cycling,callback,reverse,sendtoclient)
function SWEP:PrimaryAttack()
	if self.CurState == 0.5 then return end
	local ply = self:GetOwner()

	if self.CurState == 1 and ply:GetAmmoCount("Arrow") > 0 then
		self.CurState = 0.5
		self:PlayAnim(ply:GetAmmoCount("Arrow") == 1 and "attack_last" or "attack")

		ply:SetAmmo(ply:GetAmmoCount("Arrow") - 1, "Arrow")

		local tr = hg.eyeTrace(ply)
		local pos, ang = tr.StartPos, ply:EyeAngles()
		local dist, point = util.DistanceToLine(pos, pos, ply:EyePos())
		local bullet = {}
		bullet.Pos = point
		bullet.Dir = ang:Forward()
		bullet.Speed = 80
		bullet.Damage = 35
		bullet.Force = 80
		bullet.AmmoType = "Arrow"
		bullet.Attacker = ply.suiciding and Entity(0) or ply
		--bullet.Shooter = ply
		bullet.IgnoreEntity = not ply.suiciding and (ply.InVehicle and ply:InVehicle() and ply:GetVehicle() or hg.GetCurrentCharacter(ply)) or nil
		bullet.Penetration = 1
		--ply:LagCompensation(true)
		hg.PhysBullet.CreateBullet(bullet)
		--ply:LagCompensation(false)

		self:SoundEmit("weapons/bow_deerhunter/bow_fire_01.wav", 60, math.random(90, 115), 1)
		self:SetNextPrimaryFire(CurTime() + 1.1)
	elseif self.CurState == -1 and not ply:IsSprinting() then --and hg.KeyDown(ply, IN_USE)
		self.CurState = 0.5
		self:PlayAnim(ply:GetAmmoCount("Arrow") == 0 and "meleeattack_empty" or "meleeattack")
		self:SoundEmit("weapons/slam/throw.wav", 50, math.random(95, 105), 1)

		ply:LagCompensation(true)
		local tr = hg.eyeTrace(ply)
		if IsValid(tr.Entity) or tr.Entity:IsWorld() then
			local ent = tr.Entity
			local dmgInfo = DamageInfo()
			dmgInfo:SetDamage((ply:GetAmmoCount("Arrow") > 0 and 15 or 9) * (ply.organism.superfighter and 5 or 1))
			dmgInfo:SetDamageType(ply:GetAmmoCount("Arrow") > 0 and DMG_SLASH or DMG_CLUB)
			dmgInfo:SetAttacker(ply)
			dmgInfo:SetInflictor(self)
			dmgInfo:SetDamagePosition(tr.HitPos)
			dmgInfo:SetDamageForce(tr.Normal * 50)

			ent:TakeDamageInfo(dmgInfo)

			if ent:IsPlayer() or ent:IsRagdoll() or ent:IsNPC() then
				ply:EmitSound("weapons/tfa/melee_hit_world"..math.random(1,3)..".wav", 65)
			else
				ply:EmitSound("physics/metal/weapon_impact_hard3.wav", 65)
			end

			if ent:IsPlayer() then
				ent:ViewPunch(bashvpang)
			end

			local phys = ent:GetPhysicsObject()
			if IsValid(phys) then
				if ent:IsPlayer() then ent:SetVelocity(tr.Normal * 50 * 1.5 * (ply.organism.superfighter and 5 or 1)) end
				phys:ApplyForceOffset(tr.Normal * 5000, tr.HitPos)
				ply:SetVelocity(tr.Normal * 50 * .8 * (ply.organism.superfighter and 2 or 1))
			end
		end

		ply.organism.stamina.subadd = ply.organism.stamina.subadd + 15

		ply:ViewPunch(bashvpang / 2)

		ply:LagCompensation(false)

		self:SetNextPrimaryFire(CurTime() + 0.8)
	end
end

SWEP.Holding = 0

function SWEP:ThinkAdd()
	local ply = self:GetOwner()
	local tr = hg.eyeTrace(ply)

	local wallblock = tr.Fraction <= 0.4
	if (ply:IsSprinting() or wallblock) and self.CurState == 1 then
		self.CurState = 0
	end

	if string.find(self.anim, "empty") and ply:GetAmmoCount("Arrow") > 0 then
		self:PlayAnim("deploy")
	end

	if !string.find(self.anim, "empty") and ply:GetAmmoCount("Arrow") == 0 then
		self:PlayAnim("deploy_empty")
	end

	if hg.KeyDown(ply, IN_ATTACK2) and not ply:IsSprinting() and not wallblock then
		if self.CurState == -1 and self.CurState ~= 0.5 then
			self.CurState = 0.5
			self:PlayAnim(ply:GetAmmoCount("Arrow") == 0 and "idle_to_aim_empty" or "idle_to_aim")
			--self:SoundEmit("weapons/bow_deerhunter/bow_pullback_0".. (math.random(2) == 2 and 3 or 1) ..".wav")
		end
	else
		if self.CurState == 1 and self.CurState ~= 0.5 and not ply:IsSprinting() then
			self.CurState = 0.5
			self:PlayAnim(ply:GetAmmoCount("Arrow") == 0 and "aim_to_idle_empty" or "aim_to_idle")
			self:SoundEmit("weapons/bow_deerhunter/bow_pullback_0".. (math.random(2) == 2 and 2 or 4) ..".wav", 55)
		end

		if self.CurState == 0 then
			self.CurState = 0.5
			self:PlayAnim(ply:GetAmmoCount("Arrow") == 0 and "aim_to_idle_empty" or "aim_to_idle")
			self:SoundEmit("weapons/bow_deerhunter/bow_pullback_0".. (math.random(2) == 2 and 2 or 4) ..".wav", 55)
		end
		if self.CurState == -1 and ply:IsSprinting() then
			self:PlayAnim(ply:GetAmmoCount("Arrow") == 0 and "idle_empty" or "idle")
		end
	end

	if self.AnimArHoldtypes[self.seq] then
        self.HoldType = "ar2"
    else
        self.HoldType = "slam"
    end
end

function SWEP:InitAdd()
	local ply = self:GetOwner()

	if IsValid(ply) and ply:IsPlayer() then
		self:PlayAnim(ply:GetAmmoCount("Arrow") == 0 and "deploy_empty" or "deploy")
	end
end