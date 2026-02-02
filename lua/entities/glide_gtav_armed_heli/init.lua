if not Glide then return end

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

DEFINE_BASECLASS( "base_glide_heli" )

function ENT:WeaponInit()
    BaseClass.WeaponInit( self )

    self.missileIndex = 0
    self.bulletIndex = 0
end

function ENT:OnWeaponFire( weapon )
    local attacker = self:GetSeatDriver( 1 )

    if weapon.ammoType == "missile" or weapon.ammoType == "barrage" then
        self.missileIndex = self.missileIndex + 1

        if self.missileIndex > #self.MissileOffsets then
            self.missileIndex = 1
        end

        local target

        -- Only make the missile follow the target when
        -- using the homing missiles and with a "hard" lock-on
        if weapon.lockOn and self:GetLockOnState() == 2 then
            target = self:GetLockOnTarget()
        end

        local pos = self:LocalToWorld( self.MissileOffsets[self.missileIndex] )
        self:FireMissile( pos, self:GetAngles(), attacker, target )
    else
        self.bulletIndex = self.bulletIndex + 1

        if self.bulletIndex > #self.BulletOffsets then
            self.bulletIndex = 1
        end

        self:SetFiringMinigun( true )

        self:FireBullet( {
            pos = self:LocalToWorld( self.BulletOffsets[self.bulletIndex] ),
            ang = self:LocalToWorldAngles( self.BulletAngles[self.bulletIndex] ),
            attacker = attacker,
            isExplosive = weapon.ammoType == "explosive_cannon"
        } )
    end
end

function ENT:OnWeaponStop( weapon )
    if weapon.ammoType ~= "missile" then
        self:SetFiringMinigun( false )
    end
end
