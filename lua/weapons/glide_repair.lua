local repairSpeedMulCvar = CreateConVar( "glide_repairswep_speedmul", 1, { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "Changes the repair speed of the glide Vehicle Repair SWEP", 0, 100 )

SWEP.PrintName = "#glide.swep.repair"
SWEP.Instructions = "#glide.swep.repair.desc"
SWEP.Author = "StyledStrike"
SWEP.Category = "Glide"

SWEP.Slot = 0
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.UseHands = true
SWEP.ViewModelFOV = 60
SWEP.BobScale = 0.5
SWEP.SwayScale = 1.0

SWEP.ViewModel = ""
SWEP.WorldModel = "models/props_c17/tools_wrench01a.mdl"
SWEP.offsetVec = Vector(3.5, -1.8, -2)
SWEP.offsetAng = Angle(0, 90, -90)

if CLIENT then
    SWEP.DrawCrosshair = false
    SWEP.BounceWeaponIcon = false
    SWEP.WepSelectIcon = surface.GetTextureID( "glide/vgui/glide_repair_wrench_icon" )
    SWEP.IconOverride = "glide/vgui/glide_repair_wrench.png"
end

SWEP.DrawAmmo = false
SWEP.HoldType = "slam"

SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = true

SWEP.Secondary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.WorkWithFake = true

function SWEP:Initialize()
    self:SetHoldType( self.HoldType )
    self:SetDeploySpeed( 1.5 )
end

function SWEP:Deploy()
    self:SetHoldType( self.HoldType )
    self:SetDeploySpeed( 1.5 )
    self:SetNextPrimaryFire( CurTime() + 0.5 )

    self.repairTarget = NULL
    self.repairTrace = nil

    return true
end

function SWEP:Holster()
    self.repairTarget = NULL
    self.repairTrace = nil

    return true
end

function SWEP:GetVehicleFromTrace( trace, user )
    if user:EyePos():DistToSqr( trace.HitPos ) > 8000 then
        return
    end

    local ent = trace.Entity

    if IsValid( ent ) and ent.IsGlideVehicle and ent:WaterLevel() < 3 then
        return ent, trace
    end
end

function SWEP:GetEyeTrace()
	return hg.eyeTrace(self:GetOwner())
end

function SWEP:Think()
    local user = self:GetOwner()

    if IsValid( user ) then
        self.repairTarget, self.repairTrace = self:GetVehicleFromTrace( self:GetEyeTrace(), user )
    end
end

local CurTime = CurTime
local anims_rnd = {
	ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE,
	ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE,
	ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST,
	ACT_HL2MP_GESTURE_RANGE_ATTACK_SLAM,
	ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL
}

local sounds_rnd = {
	"snds_jack_gmod/ez_tools/1.wav",
	"snds_jack_gmod/ez_tools/10.wav",
	"snds_jack_gmod/ez_tools/11.wav",
	"snds_jack_gmod/ez_tools/12.wav",
	"snds_jack_gmod/ez_tools/13.wav",
	"snds_jack_gmod/ez_tools/2.wav",
	"snds_jack_gmod/ez_tools/21.wav",
	"snds_jack_gmod/ez_tools/22.wav",
	"snds_jack_gmod/ez_tools/23.wav",
	"snds_jack_gmod/ez_tools/24.wav",
	"snds_jack_gmod/ez_tools/9.wav",
	"snds_jack_gmod/ez_tools/hit.wav"
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

    local repairMul = repairSpeedMulCvar:GetFloat()

    local engineHealth = ent:GetEngineHealth()
    local chassisHealth = ent:GetChassisHealth()

    if chassisHealth >= ent.MaxChassisHealth and engineHealth >= 1 then
        local rotors = ent.rotors
        if not rotors then return end

        for i = 1, #rotors do
            if not IsValid( rotors[i] ) then
                ent:Repair()
                user:EmitSound( "snds_jack_gmod/ez_tools/25.wav", 75, math.random(90, 110), 0.5 )
                break
            end
        end

        return
    end

    if chassisHealth < ent.MaxChassisHealth then
        chassisHealth = chassisHealth + ( 20 * repairMul )
        engineHealth = math.Clamp( engineHealth + ( 0.03 * repairMul ), 0, 1 )

        if user.ViewPunch then
            user:ViewPunch( AngleRand( -3, 3 ) )
        end

        if chassisHealth > 0.3 and ent.SetIsEngineOnFire then
            ent:SetIsEngineOnFire( false )
        end

        user:EmitSound( sounds_rnd[math.random(#sounds_rnd)], 75, math.random(95, 115), 0.5 )
    end

    if chassisHealth > ent.MaxChassisHealth then
        chassisHealth = ent.MaxChassisHealth
        engineHealth = 1

        ent:Repair()
        user:EmitSound( "snds_jack_gmod/ez_tools/25.wav", 75, math.random(90, 105), 0.8 )
    end

    if chassisHealth >= ent.MaxChassisHealth then
        engineHealth = 1
    end

    ent:SetChassisHealth( chassisHealth )
    ent:SetEngineHealth( engineHealth )

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

function SWEP:SecondaryAttack()
end

if not CLIENT then return end

local SetColor = surface.SetDrawColor
local ICON_AIM = Material( "glide/aim_area.png", "smooth" )

function SWEP:DrawHUD()
    if not self:IsWeaponVisible() then return end

    local ent = self.repairTarget
    if not IsValid( ent ) then return end

    local x, y = ScrW() * 0.5, ScrH() * 0.5
    local size = math.floor( ScrH() * 0.07 )

    SetColor( 255, 255, 255, 255 )
    surface.SetMaterial( ICON_AIM )
    surface.DrawTexturedRectRotated( x, y, size, size, 0 )

    local w = math.floor( ScrH() * 0.4 )
    local h = math.floor( ScrH() * 0.03 )

    x = x - w * 0.5
    y = y + h * 2

    Glide.DrawVehicleHealth( x, y, w, h, ent.VehicleType, ent:GetChassisHealth() / ent.MaxChassisHealth, ent:GetEngineHealth() )

    return true
end

function SWEP:DrawWorldModel()
	if not IsValid(self:GetOwner()) then
		self:DrawWorldModel2()
	end
end

function SWEP:DrawWorldModel2()
	self.model = IsValid(self.model) and self.model or ClientsideModel(self.WorldModel)
	local WorldModel = self.model
	local owner = self:GetOwner()
	WorldModel:SetNoDraw(true)
	WorldModel:SetModelScale(self.ModelScale or 1)
	local renderGuy = hg.GetCurrentCharacter(owner)
	if IsValid(owner) then
		local offsetVec = self.offsetVec
		local offsetAng = self.offsetAng

		local boneid = renderGuy:LookupBone("ValveBiped.Bip01_R_Hand")
		if not boneid then return end
		local matrix = renderGuy:GetBoneMatrix(boneid)
		if not matrix then return end
		local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())

		WorldModel:SetPos(newPos)
		WorldModel:SetAngles(newAng)
		WorldModel:SetupBones()
	else
		WorldModel:SetPos(self:GetPos())
		WorldModel:SetAngles(self:GetAngles())
	end

	WorldModel:DrawModel()
end
