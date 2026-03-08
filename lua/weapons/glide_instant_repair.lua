SWEP.Base = "glide_repair"

SWEP.PrintName = "#glide.swep.instant_repair"
SWEP.Instructions = "#glide.swep.repair.desc"
SWEP.Author = "StyledStrike"
SWEP.Category = "Glide"

SWEP.Slot = 0
SWEP.Spawnable = true
SWEP.AdminOnly = true

if CLIENT then
    SWEP.WepSelectIcon = surface.GetTextureID( "glide/vgui/glide_repair_wrench_icon" )
    SWEP.IconOverride = "glide/vgui/glide_repair_wrench_admin.png"
end

local CurTime = CurTime
local REPAIR_SOUND = "glide/train/track_clank_%d.wav"
local anims_rnd = {
	ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE,
	ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE,
	ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST,
	ACT_HL2MP_GESTURE_RANGE_ATTACK_SLAM,
	ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL
}

function SWEP:PrimaryAttack()
    local user = self:GetOwner()
    if not IsValid( user ) then return end

    self:SetNextPrimaryFire( CurTime() + 0.5 )
	if user:IsPlayer() then
		user:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, anims_rnd[math.random(#anims_rnd)], true )
	end

    if not SERVER then return end

    local ent = self.repairTarget
    if not ent then return end

    local engineHealth = ent:GetEngineHealth()
    local chassisHealth = ent:GetChassisHealth()

    if chassisHealth < ent.MaxChassisHealth then
        if user.ViewPunch then
            user:ViewPunch( AngleRand( -3, 3 ) )
        end

        if ent.SetIsEngineOnFire then
            ent:SetIsEngineOnFire( false )
        end

		ent:Repair()
		user:EmitSound( "buttons/lever6.wav", 75, math.random( 110, 120 ), 0.5 ) 
		ent:SetChassisHealth( ent.MaxChassisHealth )
		ent:SetEngineHealth( ent.MaxEngineHealth )
    end

    if ent.UpdateHealthOutputs then
        ent:UpdateHealthOutputs()
    end

    local trace = self.repairTrace

    if trace then
		if math.random(4) == 2 then
			local data = EffectData()
			data:SetOrigin( trace.HitPos + trace.HitNormal * 5 )
			data:SetNormal( trace.HitNormal )
			data:SetScale( 1 )
			data:SetMagnitude( 1 )
			data:SetRadius( 2 )
			util.Effect( "cball_bounce", data, false, true )
		end

		local Poof = EffectData()
		Poof:SetOrigin( trace.HitPos )
		Poof:SetScale( math.random(1, 5) )
		Poof:SetNormal( -trace.HitNormal )
		util.Effect( "eff_jack_hmcd_poof", Poof, true, true )
    end
end