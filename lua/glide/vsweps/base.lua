VSWEP.Name = "#glide.weapons.mgs"
VSWEP.Icon = "glide/icons/bullets.png"

if SERVER then
    -- How often can this weapon fire?
    VSWEP.FireDelay = 0.5

    -- How long does it take to reload?
    VSWEP.ReloadDelay = 1

    -- Should this weapon enable the lock-on system?
    VSWEP.EnableLockOn = false

    -- Multiply the time it takes to progress through lock-on stages
    VSWEP.LockOnTimeMultiplier = 1.0

    -- Bullet spread (nil for default)
    VSWEP.Spread = nil

    -- Bullet damage (nil for default)
    VSWEP.Damage = nil

    -- Bullet tracer scale (nil for default)
    VSWEP.TracerScale = nil

    -- Set to 0 for unlimited ammo
    VSWEP.MaxAmmo = 0

    -- The "ammo type" of this weapon. It can be any string.
    -- When switching weapons, this is used to copy the reload and fire
    -- cooldowns from the previous weapon, as long as it has the same ammo type.
    VSWEP.AmmoType = ""

    -- Should the ammo capacity be shared with
    -- other weapons that have the same ammo type?
    VSWEP.AmmoTypeShareCapacity = false

    -- Positions (relative to the vehicle) to fire projectiles.
    VSWEP.ProjectileOffsets = {
        Vector( 0, 0, 0 )
    }

    -- A one-shot sound to play when the weapon fires.
    VSWEP.SingleShotSound = ""

    -- A one-shot sound to play when the weapon finishes reloading.
    VSWEP.SingleReloadSound = ""
end

if CLIENT then
    VSWEP.LocalCrosshairOrigin = Vector()
    VSWEP.LocalCrosshairAngle = Angle()

    -- Size relative to screen resolution
    VSWEP.CrosshairSize = 0.05

    -- Path (relative to "materials/") to a image/material file
    VSWEP.CrosshairImage = "glide/aim_dot.png"
end

if SERVER then
    local CurTime = CurTime

    function VSWEP:Initialize()
        self.ammo = self.MaxAmmo
        self.nextFire = 0
        self.nextReload = 0
        self.isFiring = false
        self.isReloading = false
        self.projectileOffsetIndex = 0

        -- Compatibility with vehicles that use `ENT.WeaponSlots`, and
        -- access the weapon's `ammoType` (lowercase "a") on `ENT:OnWeaponFire`.
        self.ammoType = self.AmmoType
    end

    -- You can override these on children classes.
    function VSWEP:Think() end
    function VSWEP:OnRemove() end
    function VSWEP:OnDeploy() end
    function VSWEP:OnHolster() end

    -- You can override this on children classes.
    function VSWEP:PrimaryAttack()
        self:TakePrimaryAmmo( 1 )
        self:SetNextPrimaryFire( CurTime() + self.FireDelay )
        self:IncrementProjectileIndex()
        self:ShootEffects()

        local vehicle = self.Vehicle

        vehicle:FireBullet( {
            pos = vehicle:LocalToWorld( self.ProjectileOffsets[self.projectileOffsetIndex] ),
            ang = vehicle:GetAngles(),
            attacker = vehicle:GetSeatDriver( 1 ),
            spread = self.Spread,
            damage = self.Damage,
            scale = self.TracerScale
        } )
    end

    -- You can override this on children classes.
    function VSWEP:Reload()
        self.ammo = self.MaxAmmo

        if self.SingleReloadSound ~= "" then
            self.Vehicle:EmitSound( self.SingleReloadSound )
        end
    end

    -- You can override this on children classes.
    function VSWEP:ShootEffects()
        if self.SingleShotSound ~= "" then
            self.Vehicle:EmitSound( self.SingleShotSound )
        end
    end

    function VSWEP:SetNextPrimaryFire( time )
        self.nextFire = time
    end

    function VSWEP:TakePrimaryAmmo( amount )
        self.ammo = math.max( 0, self.ammo - amount )
        self.Vehicle:MarkWeaponDataAsDirty()
    end

    function VSWEP:IncrementProjectileIndex()
        self.projectileOffsetIndex = self.projectileOffsetIndex + 1

        if self.projectileOffsetIndex > #self.ProjectileOffsets then
            self.projectileOffsetIndex = 1
        end
    end

    function VSWEP:PrimaryAttackInternal()
        -- Check if the vehicle is going to override the weapon fire event first.
        local allowDefaultBehaviour = self.Vehicle:OnWeaponFire( self, self.SlotIndex )

        -- If the vehicle did not block the event,
        -- then run `VSWEP:PrimaryAttack`.
        if allowDefaultBehaviour then
            self:PrimaryAttack()
        else
            -- If the vehicle does block the event,
            -- do this to keep backwards compatibility.
            self:TakePrimaryAmmo( 1 )
            self:SetNextPrimaryFire( CurTime() + self.FireDelay )
            self:IncrementProjectileIndex()
        end

        -- If we ran out of ammo, set the nextReload timer.
        if self.ammo < 1 and self.MaxAmmo > 0 then
            self.nextReload = CurTime() + self.ReloadDelay
        end
    end

    local CanUseWeaponry = Glide.CanUseWeaponry

    function VSWEP:InternalThink()
        local time = CurTime()
        local vehicle = self.Vehicle

        -- Reload if it is the time to do so
        self.isReloading = self.ammo < 1 and self.MaxAmmo > 0

        if self.isReloading then
            if time > self.nextReload then
                self:Reload()
            end

            vehicle:MarkWeaponDataAsDirty()
        end

        local driver = vehicle:GetDriver()
        local shouldFire = vehicle:GetInputBool( 1, "attack" )

        shouldFire = shouldFire and ( self.MaxAmmo == 0 or self.ammo > 0 )

        if shouldFire and IsValid( driver ) then
            shouldFire = shouldFire and CanUseWeaponry( driver )
        end

        if shouldFire and time > self.nextFire then
            self:PrimaryAttackInternal()
        end

        if self.isFiring ~= shouldFire then
            self.isFiring = shouldFire

            if shouldFire then
                vehicle:OnWeaponStart( self, self.SlotIndex )
            else
                vehicle:OnWeaponStop( self, self.SlotIndex )
            end
        end

        self:Think()
    end

    --- You can override this function to add/change
    --- the data to be send to the driver's client.
    ---
    --- If you do override it, please remember to call
    --- `self.BaseClass.OnWriteData( self )` first, if you
    --- still plan to draw the original HUD from this base class.
    function VSWEP:OnWriteData()
        net.WriteUInt( self.MaxAmmo, 16 )
        net.WriteUInt( self.ammo, 16 )
        net.WriteFloat( self.isReloading and 1 - ( self.nextReload - CurTime() ) / self.ReloadDelay or 0 )
    end
end

if CLIENT then
    --[[
        NOTE! NOTE! NOTE!

        Client-side, instances (or copies) of VWEPS are
        only created/updated on the local client when:

        - The local player is the driver of the vehicle that has this weapon
        - The weapon is the current active weapon

        Client-side weapon instances are destroyed as soon
        as the local player leaves the vehicle.
    ]]

    --- Called when this weapon is created locally,
    --- when the conditions mentioned above are met.
    function VSWEP:Initialize()
        self.maxAmmo = 0
        self.ammo = 0
        self.progressBar = 0
        self.reloadProgress = 0
    end

    --- Called when we're receiving a data sync event for this weapon.
    ---
    --- You must use `net.Read*` functions in the same order
    --- as you wrote them on `VSWEP:OnWriteData`.
    ---
    --- If you do override this function, please remember to call
    --- `self.BaseClass.OnReadData( self )` first, if you
    --- still plan to draw the original HUD from this base class.
    function VSWEP:OnReadData()
        self.maxAmmo = net.ReadUInt( 16 )
        self.ammo = net.ReadUInt( 16 )
        self.reloadProgress = net.ReadFloat()
    end

    local Floor = math.floor
    local Clamp = math.Clamp
    local ExpDecay = Glide.ExpDecay

    local SetColor = surface.SetDrawColor
    local DrawRect = surface.DrawRect
    local DrawSimpleText = draw.SimpleText
    local DrawIcon = Glide.DrawIcon

    local colors = {
        accent = Glide.THEME_COLOR,
        text = Color( 255, 255, 255 ),
        lowAmmo = Color( 255, 115, 0 ),
        noAmmo = Color( 255, 50, 50 )
    }

    local ammoText = "%d / %d"

    --- Draw the weapon HUD.
    function VSWEP:DrawHUD( _screenW, screenH )
        self:DrawCrosshair()

        local h = Floor( screenH * 0.04 )
        local y = screenH - Floor( screenH * 0.03 ) - h
        local margin = Floor( screenH * 0.005 )
        local iconSize = h * 0.8

        local ammo = self.ammo or 0
        local maxAmmo = self.maxAmmo or 0
        local text = maxAmmo > 0 and ammoText:format( ammo, maxAmmo ) or "ꝏ"

        surface.SetFont( "GlideHUD" )
        local w = surface.GetTextSize( text )

        w = w + iconSize + margin * 4

        SetColor( 30, 30, 30, 230 )
        DrawRect( 0, y, w, h )

        -- Draw a progress bar if this weapon is reloading or does not have infinite ammo.
        local progressBar = self.reloadProgress > 0 and self.reloadProgress or ( maxAmmo > 0 and ammo / maxAmmo or 0 )

        self.progressBar = ExpDecay( self.progressBar, Clamp( progressBar, 0, 1 ), 6, FrameTime() )

        if self.progressBar > 0 then
            SetColor( colors.accent:Unpack() )
            DrawRect( 1, y + 1, ( w - 2 ) * self.progressBar, h - 2 )
        end

        local ammoColor = colors.text

        if maxAmmo > 0 then
            ammoColor = ammo > 0 and ( ammo > maxAmmo * 0.3 and colors.text or colors.lowAmmo ) or colors.noAmmo
        end

        DrawSimpleText( text, "GlideHUD", iconSize + margin * 2, y + h * 0.5, ammoColor, 0, 1 )
        DrawIcon( margin + iconSize * 0.5, y + h * 0.5, self.Icon, iconSize, colors.text, 0 )
    end

    local LOCKON_STATE_COLORS = {
        [0] = Color( 255, 255, 255 ),
        [1] = Color( 100, 255, 100 ),
        [2] = Color( 255, 0, 0 ),
    }

    local DrawWeaponCrosshair = Glide.DrawWeaponCrosshair
    local TraceLine = util.TraceLine
    local IsValid = IsValid

    local traceData = {
        filter = { NULL, "glide_missile", "glide_projectile" }
    }

    function VSWEP:DrawCrosshair()
        if self.CrosshairImage == "" then return end

        local vehicle = self.Vehicle
        local lockOnTarget = vehicle:GetLockOnTarget()
        local origin, color

        if IsValid( lockOnTarget ) then
            origin = lockOnTarget:GetPos()
            color = LOCKON_STATE_COLORS[vehicle:GetLockOnState()]
        else
            origin = vehicle:LocalToWorld( self.LocalCrosshairOrigin )
            color = LOCKON_STATE_COLORS[0]

            local ang = vehicle:LocalToWorldAngles( self.LocalCrosshairAngle )

            traceData.start = origin
            traceData.endpos = origin + ang:Forward() * 10000
            traceData.filter[1] = vehicle

            origin = TraceLine( traceData ).HitPos
        end

        local pos = origin:ToScreen()

        if pos.visible then
            DrawWeaponCrosshair( pos.x, pos.y, self.CrosshairImage, self.CrosshairSize, color )
        end
    end
end
