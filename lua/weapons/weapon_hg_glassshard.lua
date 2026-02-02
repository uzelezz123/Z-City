if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Glass Shard"
SWEP.Instructions = "A piece of a broken glass.\n\nLMB to attack.\nRMB to block."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.HoldType = "knife"

SWEP.WorldModel = "models/z_city/wep_glass_shard.mdl"
SWEP.WorldModelReal = "models/weapons/salat/reanim/c_s&wch0014.mdl"
SWEP.WorldModelExchange = "models/z_city/wep_glass_shard.mdl"

SWEP.SuicidePos = Vector(-12, 5, -7)
SWEP.SuicideAng = Angle(-30, 0, 0)
SWEP.SuicideCutVec = Vector(-1, -5, 1)
SWEP.SuicideCutAng = Angle(10, 0, 0)
SWEP.SuicideTime = 0.5
SWEP.CanSuicide = true
SWEP.SuicideNoLH = true

SWEP.BreakBoneMul = 0.1

SWEP.AnimTime1 = 1.0
SWEP.AttackTime = 0.2
SWEP.WaitTime1 = 0.5

SWEP.modelscale = 0.5
SWEP.modelscale2 = 1

if CLIENT then
	SWEP.WepSelectIcon = Material("entities/zcity/glassshard.png")
	SWEP.IconOverride = "entities/zcity/glassshard.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = false
SWEP.setrh = true
SWEP.TwoHanded = false

SWEP.NoHolster = true

SWEP.DamagePrimary = 7

SWEP.PenetrationPrimary = 1.1

SWEP.StaminaPrimary = 10

SWEP.BleedMultiplier = 1.8

SWEP.AttackLen1 = 40

SWEP.AttackHit = "GlassBottle.ImpactHard"
SWEP.AttackHitFlesh = "snd_jack_hmcd_knifestab.wav"

SWEP.DeploySnd = "GlassBottle.ImpactSoft"

SWEP.DamageType = DMG_SLASH
SWEP.PainMultiplier = .4
SWEP.MaxPenLen = 0.5
SWEP.PenetrationSizePrimary = 0.8

SWEP.AnimList = {
    ["idle"] = "idle",
    ["deploy"] = "draw",
    ["attack"] = "midslash1",
    ["attack2"] = "midslash1",
    ["duct_cut"] = "cut",
    ["inspect"] = "inspect"
}

SWEP.HoldPos = Vector(-4,0,-1)
SWEP.HoldAng = Angle(0,0,0)
SWEP.weaponPos = Vector(-0.2,1.8,0.2)
SWEP.weaponAng = Angle(10,-20,0)
SWEP.basebone = 39

SWEP.AttackPos = Vector(-3,8,-20)

function SWEP:CustomAttack2()
    local ent = ents.Create("ent_throwable")
    ent.WorldModel = self.WorldModelExchange or self.WorldModel

    local ply = self:GetOwner()

    ent:SetPos(select(1, hg.eye(ply,60,hg.GetCurrentCharacter(ply))) - ply:GetAimVector() * 2)
    ent:SetAngles(ply:EyeAngles())
    ent:SetOwner(self:GetOwner())
    ent:Spawn()

    ent.localshit = Vector(0,0,0)
    ent.wep = self:GetClass()
    ent.owner = ply
    ent.damage = self.DamagePrimary * 0.7
    ent.MaxSpeed = 1200
    ent.DamageType = self.DamageType
    ent.AttackHit = "GlassBottle.ImpactHard"
    ent.AttackHitFlesh = "Flesh.ImpactHard"
    ent:PrecacheGibs()

    ent.func = function(data)
        if ent.removed then return end
        ent.removed = true
        timer.Simple(0, function()
            ent:GibBreakServer(vector_origin)
            ent:EmitSound("physics/glass/glass_pottery_break"..math.random(1,4)..".wav")
            ent:Remove()
        end)
    end

    local phys = ent:GetPhysicsObject()

    if IsValid(phys) then
        phys:SetVelocity(ply:GetAimVector() * ent.MaxSpeed)
        phys:AddAngleVelocity(VectorRand() * 500)
    end

    //ply:EmitSound("weapons/slam/throw.wav",50,math.random(95,105))
    ply:ViewPunch(self.ViewPunch1 * 0.6)
    ply:SelectWeapon("weapon_hands_sh")

    self:Remove()

    return true
end

function SWEP:CanSecondaryAttack()
    return true
end

function SWEP:PrimaryAttackAdd(ent, trace)
    if SERVER then
		local dmg = self.DamagePrimary
		local owner = self:GetOwner()

		hg.organism.AddWoundManual(owner, dmg * 2, vector_origin, angle_zero,"ValveBiped.Bip01_R_Hand", CurTime() + (dmg * 220))
        owner:Notify("This glass shard is cutting through my hand!..", 30)

		if ent and math.random(1, self:IsEntSoft(ent) and 10 or 5) == 1 then
			self:PrecacheGibs()
			self:GibBreakServer(trace.HitNormal * -100)
			owner:EmitSound("physics/glass/glass_pottery_break" .. math.random(1, 4) .. ".wav")
			self:Remove()
		end
    end
end

SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.01

SWEP.AttackRads = 65
SWEP.AttackRads2 = 0

SWEP.SwingAng = -35
SWEP.SwingAng2 = 0

local function tapeShard()
	RunConsoleCommand("hg_tape_shard")
end

if SERVER then
	concommand.Add("hg_tape_shard", function(ply)
		if ply:Alive() and not ply.organism.otrub then
			local have_tape = ply:HasWeapon("weapon_ducttape")
			local have_shard = ply:HasWeapon("weapon_hg_glassshard")

			if have_tape and have_shard then
				if ply:HasWeapon("weapon_ducttape") then
					ply:StripWeapon("weapon_ducttape")
				end

				if ply:HasWeapon("weapon_hg_glassshard") then
					ply:StripWeapon("weapon_hg_glassshard")
				end

				ply:Give("weapon_hg_glassshard_taped")
				ply:EmitSound("snd_jack_hmcd_ducttape.wav", 70, math.random(110, 120))
			end
		end
	end)
end

hook.Add("radialOptions","tape_shard",function()
    local ply = LocalPlayer()
	local organism = ply.organism or {}
	if organism.otrub then return end

	local have_tape = ply:HasWeapon("weapon_ducttape")
	local have_shard = ply:HasWeapon("weapon_hg_glassshard")

	if have_tape and have_shard then
		local tbl = {tapeShard, "Tape glass shard"}
		hg.radialOptions[#hg.radialOptions + 1] = tbl
	end
end)