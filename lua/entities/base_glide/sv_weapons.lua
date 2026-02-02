function ENT:WeaponInit()
    self.weapons = {}
    self.weaponCount = 0
    self.turretCount = 0

    self.weaponState = {
        index = 0, -- Current weapon slot index
        lockOnThinkCD = 0, -- Lock-on logic update cooldown
        lockOnStateCD = 0, -- Lock-on state change cooldown

        earlySync = false, -- Should a weapon data sync happen early?
        lastSyncT = 0 -- Last time a weapon data sync happened
    }

    -- Backwards compatibility with `ENT.WeaponSlots`
    if self.WeaponSlots then
        for _, data in ipairs( self.WeaponSlots ) do
            self:CreateWeapon( "base", {
                AmmoType = data.ammoType,
                MaxAmmo = data.maxAmmo,
                FireDelay = data.fireRate,
                ReloadDelay = data.replenishDelay,
                EnableLockOn = data.lockOn == true
            } )
        end
    end
end

--- Returns the total count of weapons on this vehicle.
--- This counts weapons created with `ENT:CreateWeapon` and `Glide.CreateTurret`.
function ENT:GetWeaponCount()
    return self.weaponCount + self.turretCount
end

--- Returns the index of the active weapon.
function ENT:GetWeaponIndex()
    return self.weaponState.index
end

--- Force a weapon data sync to happen early.
function ENT:MarkWeaponDataAsDirty()
    self.weaponState.earlySync = true
end

function ENT:ClearLockOnTarget()
    self:SetLockOnTarget( NULL )
    self:SetLockOnState( 0 )
end

function ENT:ClearWeapons()
    local myWeapons = self.weapons
    if not myWeapons then return end

    for i = #myWeapons, 1, -1 do
        myWeapons[i]:OnRemove()
        myWeapons[i] = nil
    end

    self.weapons = {}
    self.weaponCount = 0
end

--- Add a VSWEP to this vehicle's weapon slots.
--- `data` is a optional key-value table for the server-side
--- properties of the weapon, like `FireDelay` and `MaxAmmo`. 
function ENT:CreateWeapon( class, data )
    local weapon = Glide.CreateVehicleWeapon( class, data )
    local index = self.weaponCount + 1

    self.weaponCount = index
    self.weapons[index] = weapon

    weapon.SlotIndex = index
    weapon.Vehicle = self
    weapon:Initialize()

    if self.weaponCount == 1 then
        self:SelectWeaponIndex( 1 )
    end
end

local CanUseWeaponry = Glide.CanUseWeaponry

--- Switch the current active weapon.
function ENT:SelectWeaponIndex( index )
    if self.weaponCount == 0 then return end

    local driver = self:GetDriver()

    if IsValid( driver ) and not CanUseWeaponry( driver ) then
        return
    end

    -- Wrap the index around if outside limits
    if index > self.weaponCount then
        index = 1

    elseif index < 1 then
        index = self.weaponCount
    end

    local weapon = self.weapons[index]
    if not weapon then return end

    local lastIndex = self.weaponState.index
    local lastWeapon = self.weapons[lastIndex]

    if lastWeapon then
        if lastWeapon.isFiring then
            lastWeapon.isFiring = false
            self:OnWeaponStop( lastWeapon, lastWeapon.SlotIndex )
        end

        local lastAmmoType = lastWeapon.AmmoType

        if lastAmmoType ~= "" then
            for i, otherWeapon in ipairs( self.weapons ) do
                if i ~= lastIndex and lastAmmoType == otherWeapon.AmmoType then
                    -- Share the reload and fire cooldowns to all
                    -- other weapons with the same ammo type.
                    otherWeapon.nextFire = lastWeapon.nextFire
                    otherWeapon.nextReload = lastWeapon.nextReload

                    -- Share the ammo count to all other weapons with the same
                    -- ammo type AND that have `AmmoTypeShareCapacity` set to `true`.
                    if otherWeapon.AmmoTypeShareCapacity then
                        otherWeapon.ammo = lastWeapon.ammo
                        otherWeapon.projectileOffsetIndex = lastWeapon.projectileOffsetIndex
                    end
                end
            end
        end

        -- Let the last weapon know it's no longer active
        lastWeapon:OnHolster()
    end

    -- Let the current weapon know it's active
    weapon:OnDeploy()

    self:ClearLockOnTarget()
    self:MarkWeaponDataAsDirty()
    self.weaponState.index = index
end

local IsValid = IsValid
local CurTime = CurTime
local CanLockOnEntity = Glide.CanLockOnEntity
local FindLockOnTarget = Glide.FindLockOnTarget

function ENT:WeaponThink()
    local time = CurTime()
    local state = self.weaponState

    local weapon = self.weapons[state.index]
    if not weapon then return end

    weapon:InternalThink()

    local driver = self:GetDriver()

    if IsValid( driver ) then
        -- Periodically sync the current weapon state with the driver.
        if time > state.lastSyncT + ( state.earlySync and 0.15 or 0.5 ) then
            state.lastSyncT = time
            state.earlySync = false

            -- Write some metadata
            net.Start( "glide.sync_weapon_data", true )
            net.WriteUInt( state.index, 5 )
            net.WriteString( weapon.ClassName )

            -- Let the weapon class write custom data
            weapon:OnWriteData()

            net.Send( driver )
        end
    else
        -- Don't run the lock-on logic without a driver
        return
    end

    -- Periodically update lock-on state, if this weapon uses it.
    if not weapon.EnableLockOn or time < state.lockOnThinkCD then return end

    state.lockOnThinkCD = time + 0.1

    local target = self:GetLockOnTarget()
    local myPos = self:GetPos()
    local myDir = self:GetForward()

    if IsValid( target ) then
        local targetPos = target:GetPos()
        local targetDir = targetPos - myPos
        targetDir:Normalize()

        if time > state.lockOnStateCD then
            self:SetLockOnState( 2 ) -- Hard lock
        end

        -- Stick to the same target for as long as possible
        if CanLockOnEntity( target, myPos, myDir, self.LockOnThreshold, self.LockOnMaxDistance, driver, true, self.selfTraceFilter ) then
            return
        end
    end

    -- Find a new target
    target = FindLockOnTarget( myPos, myDir, self.LockOnThreshold, self.LockOnMaxDistance, driver, self.selfTraceFilter, self.seats )

    if target ~= self:GetLockOnTarget() then
        self:SetLockOnTarget( target )

        if IsValid( target ) then
            self:SetLockOnState( 1 ) -- Soft lock
            state.lockOnStateCD = time + 0.45 * weapon.LockOnTimeMultiplier

            if target.IsGlideVehicle then
                -- If the target is a Glide vehicle, notify the passengers
                Glide.SendLockOnDanger( target:GetAllPlayers() )

            elseif target.GetDriver then
                -- If the target is another type of vehicle, notify the driver
                local ply = target:GetDriver()

                if IsValid( ply ) then
                    Glide.SendLockOnDanger( ply )
                end
            end
        else
            self:SetLockOnState( 0 )
            state.lockOnStateCD = 0
        end
    end
end

--- Utility function to create a missile.
function ENT:FireMissile( pos, ang, attacker, target )
    Glide.PlaySoundSet( "Glide.MissileLaunch", self, 1.0 )

    local missile = Glide.FireMissile( pos, ang, attacker, self, target )

    if IsValid( missile ) then
        local phys = missile:GetPhysicsObject()

        if IsValid( phys ) then
            phys:SetVelocityInstantaneous( self:GetVelocity() )
        end
    end

    return missile
end

local FireBullet = Glide.FireBullet

--- Utility function to fire a bullet.
function ENT:FireBullet( params )
    params = params or {}
    params.inflictor = self

    if not IsValid( params.attacker ) then
        params.attacker = self:GetCreator()
    end

    if not params.shellDirection then
        params.shellDirection = params.pos - self:GetPos()
        params.shellDirection:Normalize()
    end

    FireBullet( params, self.selfTraceFilter )
end
