local lockRequiredConvar = CreateConVar( "glide_homing_launcher_lock_required", "0", FCVAR_ARCHIVE + FCVAR_REPLICATED, "Should homing launcher require a lock to fire?" )

SWEP.PrintName = "#glide.swep.homing_launcher"
SWEP.Instructions = "#glide.swep.homing_launcher.desc"
SWEP.Author = "StyledStrike"
SWEP.Category = "Glide"

SWEP.Slot = 4
SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.UseHands = true
SWEP.ViewModelFOV = 50
SWEP.BobScale = 0.5
SWEP.SwayScale = 1.0

SWEP.ViewModel = "models/glide/weapons/c_homing_launcher.mdl"
SWEP.WorldModel = "models/glide/weapons/w_homing_launcher.mdl"

if CLIENT then
    SWEP.BounceWeaponIcon = false
    SWEP.WepSelectIcon = surface.GetTextureID( "glide/vgui/glide_homing_launcher_icon" )
    SWEP.IconOverride = "glide/vgui/glide_homing_launcher.png"
end

SWEP.DeployTime = 0.1
SWEP.ReloadTime = 2.3
SWEP.FireTime = 0.5
SWEP.ClipTime = 1
SWEP.HoldType = "rpg"

SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 20
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "RPG_Round"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.LockOnThreshold = 0.95
SWEP.LockOnMaxDistance = 20000

local CurTime = CurTime

function SWEP:SetupDataTables()
    self:NetworkVar( "Float", "NextReload" )
    self:NetworkVar( "Bool", "Reloading" )
    self:NetworkVar( "Int", "LockState" )
    self:NetworkVar( "Entity", "LockTarget" )
end

function SWEP:Initialize()
    self:SetHoldType( self.HoldType )
    self:SetDeploySpeed( 0.7 )

    if CLIENT and self:IsCarriedByLocalPlayer() then
        self.showHint = true
    end
end

function SWEP:Deploy()
    self:SetHoldType( self.HoldType )
    self:SetDeploySpeed( 0.7 )
    self:SetReloading( false )

    self:SendWeaponAnim( ACT_VM_DRAW )
    self:SetNextPrimaryFire( CurTime() + self.DeployTime )
    self:SetNextSecondaryFire( CurTime() + self.DeployTime )

    if SERVER then
        self.lockOnThinkCD = 0
        self.lockOnStateCD = 0
        self.traceFilter = self:GetOwner()
    end

    if CLIENT then
        self:StopAllSounds()
    end

    return true
end

function SWEP:Holster()
    self:SetReloading( false )
    self:SetLockTarget( NULL )
    self:SetLockState( 0 )

    if CLIENT then
        self:StopAllSounds()
    end

    return true
end

function SWEP:GetUserAmmoCount()
    local user = self:GetOwner()

    if user.GetAmmoCount then
        return user:GetAmmoCount( self:GetPrimaryAmmoType() )
    end

    return 1
end

--- We handle reloading manually to allow this weapon
--- to have it's clip be set in the middle of a reload,
--- and to avoid interrupting `SWEP:Think`.
function SWEP:Reload()
    if self:GetUserAmmoCount() == 0 then
        if SERVER and CurTime() > self:GetNextReload() then
            self:SetNextPrimaryFire( CurTime() + 0.5 )
            self:SetNextReload( CurTime() + 0.5 )
            self:GetOwner():EmitSound( "Default.ClipEmpty_Pistol" )
        end
        return
    end

    if
        not self:GetReloading() and
        CurTime() > self:GetNextReload() and
        self:Clip1() < self.Primary.ClipSize and
        self:GetUserAmmoCount() > 0
    then
        self:SetReloading( true )
        self:SendWeaponAnim( ACT_VM_RELOAD )
        self:GetOwner():SetAnimation( PLAYER_RELOAD )

        self:SetNextReload( CurTime() + self.ClipTime )
        self:SetNextPrimaryFire( CurTime() + self.ReloadTime )
        self:SetNextSecondaryFire( CurTime() + self.ReloadTime )
    end
end

function SWEP:CanAttack()
    if self:GetReloading() then
        return false
    end

    if self:Clip1() < 1 then
        if self:GetUserAmmoCount() > 0 then
            self:Reload()
        end

        return false
    end

    if self:GetNextPrimaryFire() > CurTime() then
        return false
    end

    return true
end

function SWEP:PrimaryAttack()
    if not self:CanAttack() then return end

    if lockRequiredConvar:GetBool() and not ( IsValid( self:GetLockTarget() ) and self:GetLockState() == 3 ) then return end

    local fireDelay = CurTime() + self.FireTime

    self:SetNextPrimaryFire( fireDelay )
    self:SetNextSecondaryFire( fireDelay )
    self:SetNextReload( fireDelay )

    self:TakePrimaryAmmo( 1 )
    self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
    self:EmitSound( "glide/weapons/homing_launcher/launch.wav", 80, math.random( 95, 105 ), 1, CHAN_WEAPON )

    local user = self:GetOwner()

    user:SetAnimation( PLAYER_ATTACK1 )

    if user.ViewPunch then
        user:ViewPunch( Angle( -4, util.SharedRandom( "HomingLauncherRecoil", -2, 2 ), 0 ) )
    end

    if SERVER then
        local ang = user:EyeAngles()
        local tr = user:GetEyeTrace()

        -- Spawn the missile a bit ahead of the player,
        -- except when close to walls.
        local dist = ( tr.HitPos - tr.StartPos ):Length()
        local offsetF = math.Clamp( dist - 15, 0, 30 )

        -- Make the missile look like it came out of the weapon
        local startPos = user:GetShootPos()
            + ang:Forward() * offsetF
            + ang:Right() * 10
            - ang:Up() * 4

        local dir = tr.HitPos - startPos
        dir:Normalize()

        local missile = ents.Create( "glide_missile" )
        missile:SetPos( startPos )
        missile:SetAngles( dir:Angle() )
        missile:Spawn()
        missile:SetupMissile( user, user )
        missile.lifeTime = CurTime() + 10
        missile.turnRate = 200
        missile.damage = 115

        local target = self:GetLockTarget()

        if IsValid( target ) and self:GetLockState() == 3 then
            missile:SetTarget( target )
        end
    end
end

function SWEP:SecondaryAttack() end

function SWEP:Think()
    if self:GetReloading() then
        -- Check if we've finished reloading
        if CurTime() > self:GetNextReload() then
            self:SetReloading( false )
            self:SetClip1( self.Primary.ClipSize )

            -- Take the player's ammo
            self:GetOwner():SetAmmo( self:GetUserAmmoCount() - 1, self.Primary.Ammo )
        end

    elseif self:Clip1() == 0 and self:GetUserAmmoCount() > 0 and CurTime() > self:GetNextReload() then
        -- Auto-reload
        self:Reload()
    end

    if SERVER then
        self:UpdateTarget()
    end

    if CLIENT and self.showHint then
        self.showHint = false
        Glide.ShowTip( "#glide.notify.tip.homing_launcher", "materials/glide/icons/rocket.png" )
    end
end

if CLIENT then
    sound.Add( {
        name = "Glide.HomingLauncher.Insert",
        channel = CHAN_STATIC,
        volume = 1.0,
        level = 60,
        pitch = { 95, 105 },
        sound = "glide/weapons/homing_launcher/rocket_insert.wav"
    } )

    sound.Add( {
        name = "Glide.HomingLauncher.Draw",
        channel = CHAN_STATIC,
        volume = 1.0,
        level = 60,
        pitch = { 95, 105 },
        sound = {
            "glide/weapons/homing_launcher/homing_draw_1.wav",
            "glide/weapons/homing_launcher/homing_draw_2.wav"
        }
    } )

    sound.Add( {
        name = "Glide.HomingLauncher.Move",
        channel = CHAN_STATIC,
        volume = 1.0,
        level = 60,
        pitch = { 95, 105 },
        sound = {
            "glide/weapons/homing_launcher/homing_move_1.wav",
            "glide/weapons/homing_launcher/homing_move_2.wav"
        }
    } )

    local AREA_MAT = Material( "glide/aim_area.png", "smooth" )
    local AIM_ICON = "glide/aim_square.png"

    local LOCKON_STATE_COLORS = {
        [-1] = Color( 220, 220, 220, 100 ),
        [0] = Color( 255, 255, 255 ),
        [1] = Color( 255, 255, 255 ),
        [2] = Color( 100, 255, 100 ),
        [3] = Color( 255, 0, 0 )
    }

    local LOCKON_STATE_SOUNDS = {
        [1] = "glide/weapons/homing_launcher/homing_lock_1.wav",
        [2] = "glide/weapons/homing_launcher/homing_lock_2.wav",
        [3] = "glide/weapons/homing_launcher/homing_lock_3.wav"
    }

    function SWEP:OnRemove()
        self:StopAllSounds()
    end

    function SWEP:StopAllSounds()
        if self.lockOnSound then
            self.lockOnSound:Stop()
            self.lockOnSound = nil
        end
    end

    function SWEP:DoDrawCrosshair()
        return true
    end

    local DrawWeaponCrosshair = Glide.DrawWeaponCrosshair

    function SWEP:DrawHUD()
        if not self:IsWeaponVisible() then return end

        local user = LocalPlayer()
        local screenH = ScrH()
        local size = screenH * 0.5

        local state = self:GetLockState()

        if self.lastState ~= state then
            self.lastState = state
            self:StopAllSounds()

            if LOCKON_STATE_SOUNDS[state] then
                self.lockOnSound = CreateSound( self, LOCKON_STATE_SOUNDS[state] )
                self.lockOnSound:SetSoundLevel( 90 )
                self.lockOnSound:PlayEx( 1.0, 100 )
            end
        end

        if user:KeyDown( IN_ATTACK2 ) then
            surface.SetMaterial( AREA_MAT )
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.DrawTexturedRectRotated( ScrW() * 0.5, ScrH() * 0.5, size, size, 0 )
        end

        local target = self:GetLockTarget()
        local targetPos = IsValid( target ) and target:LocalToWorld( target:OBBCenter() ) or
            ( user:GetShootPos() + user:GetAimVector() * self.LockOnMaxDistance )

        local data = targetPos:ToScreen()
        if data.visible then
            DrawWeaponCrosshair( data.x, data.y, AIM_ICON, 0.07, LOCKON_STATE_COLORS[state] )
        end

        return true
    end
end

if not SERVER then return end

local CanLockOnEntity = Glide.CanLockOnEntity
local FindLockOnTarget = Glide.FindLockOnTarget

function SWEP:UpdateTarget()
    local user = self:GetOwner()
    if not IsValid( user ) then return end
    if user:IsBot() then return end

    local t = CurTime()

    if not self:CanAttack() then
        self:SetLockTarget( NULL )
        self:SetLockState( -1 )
        return
    end

    if not user:KeyDown( IN_ATTACK2 ) then
        self:SetLockTarget( NULL )
        self:SetLockState( 0 )
        return
    end

    if t < self.lockOnThinkCD then return end
    self.lockOnThinkCD = t + 0.2

    local target = self:GetLockTarget()
    local myPos = user:GetShootPos()
    local myDir = user:GetAimVector()

    if IsValid( target ) then
        local state = self:GetLockState()

        if t > self.lockOnStateCD and state < 3 then
            self.lockOnStateCD = t + 1
            self:SetLockState( state + 1 )
        end

        -- Stick to the same target for as long as possible
        if CanLockOnEntity( target, myPos, myDir, self.LockOnThreshold, self.LockOnMaxDistance, user, true, self.traceFilter ) then
            return
        end
    end

    -- Find a new target
    target = FindLockOnTarget( myPos, myDir, self.LockOnThreshold, self.LockOnMaxDistance, user, self.traceFilter )

    if target ~= self:GetLockTarget() then
        self:SetLockTarget( target )
        self:SetLockState( 0 )
        self.lockOnStateCD = 0

        if IsValid( target ) then
            if target.IsGlideVehicle then
                -- If the target is a Glide vehicle, notify the passengers
                Glide.SendLockOnDanger( target:GetAllPlayers() )

            elseif target.GetDriver then
                -- If the target is another type of vehicle, notify the driver
                local driver = target:GetDriver()

                if IsValid( driver ) and driver:IsPlayer() then
                    Glide.SendLockOnDanger( driver )
                end
            end
        end
    end
end
