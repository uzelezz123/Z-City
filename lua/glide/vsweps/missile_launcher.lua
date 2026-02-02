VSWEP.Base = "base"
VSWEP.Name = "#glide.weapons.missiles"
VSWEP.Icon = "glide/icons/rocket.png"

if SERVER then
    VSWEP.FireDelay = 1
    VSWEP.EnableLockOn = false

    -- If not empty, use this as the missile model
    VSWEP.MissileModel = ""

    -- Missile model scale
    VSWEP.MissileModelScale = 1.0
end

if CLIENT then
    VSWEP.CrosshairImage = "glide/aim_square.png"
end

if SERVER then
    function VSWEP:PrimaryAttack()
        self:TakePrimaryAmmo( 1 )
        self:SetNextPrimaryFire( CurTime() + self.FireDelay )
        self:IncrementProjectileIndex()
        self:ShootEffects()

        local vehicle = self.Vehicle
        local target

        -- Only make the missile follow the target when
        -- using the homing missiles and with a "hard" lock-on
        if self.EnableLockOn and vehicle:GetLockOnState() == 2 then
            target = vehicle:GetLockOnTarget()
        end

        local pos = vehicle:LocalToWorld( self.ProjectileOffsets[self.projectileOffsetIndex] )
        local missile = vehicle:FireMissile( pos, vehicle:GetAngles(), vehicle:GetSeatDriver( 1 ), target )
        missile:SetModelScale( self.MissileModelScale )

        if self.MissileModel ~= "" then
            missile:SetModel( self.MissileModel )
        end
    end
end
