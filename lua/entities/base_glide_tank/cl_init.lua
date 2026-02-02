include( "shared.lua" )

DEFINE_BASECLASS( "base_glide_car" )

function ENT:SetupLeftTrack( materialSlot, texture, bumpmap )
    self.leftTrackSlot = materialSlot
    self.leftTrackScroll = Vector()
    self.leftTrackTexture = texture
    self.leftTrackBumpMap = bumpmap
    self:SetSubMaterial( materialSlot, "!glide_tank_track_l" )
end

function ENT:SetupRightTrack( materialSlot, texture, bumpmap )
    self.rightTrackSlot = materialSlot
    self.rightTrackScroll = Vector()
    self.rightTrackTexture = texture
    self.rightTrackBumpMap = bumpmap
    self:SetSubMaterial( materialSlot, "!glide_tank_track_r" )
end

--- Implement this base class function.
function ENT:AllowFirstPersonMuffledSound()
    return false
end

--- Override this base class function.
function ENT:OnActivateWeapon( weapon, slotIndex )
    if slotIndex > 1 then
        BaseClass.OnActivateWeapon( self, weapon, slotIndex )
    else
        -- Disable default cannon crosshair, since we'll draw our own
        weapon.CrosshairImage = ""
        weapon.Name = "#glide.weapons.cannon"
        weapon.Icon = "glide/icons/rocket.png"
    end
end

--- Override this base class function.
function ENT:OnPostInitialize()
    BaseClass.OnPostInitialize( self )

    self.currentTurretAng = Angle()
    self.targetTurretAng = Angle()
end

--- Override this base class function.
function ENT:OnLocalPlayerEnter( seatIndex )
    BaseClass.OnLocalPlayerEnter( self, seatIndex )
    self.isPredicted = seatIndex == 1
end

--- Override this base class function.
function ENT:OnLocalPlayerExit()
    BaseClass.OnLocalPlayerExit( self )
    self.isPredicted = false
end

--- Override this base class function.
function ENT:DeactivateMisc()
    BaseClass.DeactivateMisc( self )

    if self.trackSound then
        self.trackSound:Stop()
        self.trackSound = nil
    end

    if self.turretSound then
        self.turretSound:Stop()
        self.turretSound = nil
    end

    if self.leftTrackSlot then
        self:SetSubMaterial( self.leftTrackSlot, nil )
        self.leftTrackSlot = nil
        self.leftTrackTexture = nil
        self.leftTrackBumpMap = nil
    end

    if self.rightTrackSlot then
        self:SetSubMaterial( self.rightTrackSlot, nil )
        self.rightTrackSlot = nil
        self.rightTrackTexture = nil
        self.rightTrackBumpMap = nil
    end
end

local Abs = math.abs
local Clamp = math.Clamp
local FrameTime = FrameTime
local ExpDecayAngle = Glide.ExpDecayAngle
local GetVolume = Glide.Config.GetVolume

--- Override this base class function.
function ENT:OnUpdateMisc()
    BaseClass.OnUpdateMisc( self )

    if self.leftTrackSlot then
        self:SetSubMaterial( self.leftTrackSlot, "!glide_tank_track_l" )
    end

    if self.rightTrackSlot then
        self:SetSubMaterial( self.rightTrackSlot, "!glide_tank_track_r" )
    end

    local dt = FrameTime()
    local driver = self:GetDriver()
    local lastYaw = self.currentTurretAng[2]

    if self.isPredicted and IsValid( driver ) then
        self.currentTurretAng = self:UpdateTurret( driver, dt, self.currentTurretAng )
    else
        local curAng = self.currentTurretAng
        local targetAng = self:GetTurretAngle()

        curAng[1] = ExpDecayAngle( curAng[1], targetAng[1], 30, dt )
        curAng[2] = ExpDecayAngle( curAng[2], targetAng[2], 30, dt )
    end

    self:ManipulateTurretBones( self.currentTurretAng )

    local speed = Abs( self:GetTrackSpeed() )

    if speed > 1 then
        if self.trackSound then
            self.trackSound:ChangeVolume( Clamp( speed * 0.2, 0, 1 ) * self.TrackVolume * GetVolume( "carVolume" ) )
            self.trackSound:ChangePitch( 70 + Clamp( speed * 0.02, 0, 1 ) * 30 )
        else
            self.trackSound = CreateSound( self, self.TrackSound )
            self.trackSound:SetSoundLevel( 80 )
            self.trackSound:PlayEx( 0.0, 100 )
        end

    elseif self.trackSound then
        self.trackSound:Stop()
        self.trackSound = nil
    end

    local yawSpeed = Abs( lastYaw - self.currentTurretAng[2] ) / dt
    local turretVolume = Clamp( yawSpeed * 0.05, 0, 1 )

    if turretVolume > 0 then
        turretVolume = turretVolume - dt

        if self.turretSound then
            self.turretSound:ChangeVolume( turretVolume * self.TurrentMoveVolume )
        else
            self.turretSound = CreateSound( self, self.TurrentMoveSound )
            self.turretSound:SetSoundLevel( 80 )
            self.turretSound:PlayEx( turretVolume * self.TurrentMoveVolume, 100 )
        end

    elseif self.turretSound then
        self.turretSound:Stop()
        self.turretSound = nil
    end
end

do
    local Camera = Glide.Camera
    local DrawWeaponCrosshair = Glide.DrawWeaponCrosshair

    local SetColor = surface.SetDrawColor
    local SetMaterial = surface.SetMaterial
    local DrawTexturedRectRotated = surface.DrawTexturedRectRotated

    local crosshairColor = {
        [true] = Color( 255, 255, 255, 255 ),
        [false] = Color( 150, 150, 150, 100 )
    }

    local matBody = Material( "materials/glide/tank_body.png", "smooth" )
    local matTurret = Material( "materials/glide/tank_turret.png", "smooth" )
    local CanUseWeaponry = Glide.CanUseWeaponry

    --- Override this base class function.
    function ENT:DrawVehicleHUD( screenW, screenH )
        BaseClass.DrawVehicleHUD( self, screenW, screenH )

        if CanUseWeaponry( LocalPlayer() ) then
            DrawWeaponCrosshair( screenW * 0.5, screenH * 0.5, "glide/aim_tank.png", 0.14, crosshairColor[self:GetIsAimingAtTarget()] )
        end

        if not Camera.isInFirstPerson then return end

        local ang = 0

        if Camera:IsFixed() then
            ang = -Camera.angles[2]
        else
            ang = -self:WorldToLocalAngles( Camera.angles )[2]
        end

        local x, y = screenW * 0.5, screenH * 0.92
        local size = screenH * 0.15

        SetColor( 255, 255, 255, 255 )

        SetMaterial( matBody )
        DrawTexturedRectRotated( x, y, size, size, ang )

        ang = ang + self.currentTurretAng[2]

        SetMaterial( matTurret )
        DrawTexturedRectRotated( x, y, size, size, ang )
    end
end

local matTrackL = CreateMaterial( "glide_tank_track_l", "VertexLitGeneric", {
    ["$alphatest"] = "1",
    ["$allowdiffusemodulation"] = "false",
    ["$basetexture"] = "models/gta5/vehicles/rhino/tracks"
} )

local matTrackR = CreateMaterial( "glide_tank_track_r", "VertexLitGeneric", {
    ["$alphatest"] = "1",
    ["$allowdiffusemodulation"] = "false",
    ["$basetexture"] = "models/gta5/vehicles/rhino/tracks"
} )

local scrollMatrix = Matrix()

function ENT:Draw()
    if self.leftTrackBumpMap then
        matTrackL:SetTexture( "$bumpmap", self.leftTrackBumpMap )
    end

    if self.leftTrackTexture then
        scrollMatrix:SetTranslation( self.leftTrackScroll )
        matTrackL:SetTexture( "$basetexture", self.leftTrackTexture )
        matTrackL:SetMatrix( "$basetexturetransform", scrollMatrix )
    end

    if self.rightTrackBumpMap then
        matTrackR:SetTexture( "$bumpmap", self.rightTrackBumpMap )
    end

    if self.rightTrackTexture then
        scrollMatrix:SetTranslation( self.rightTrackScroll )
        matTrackR:SetTexture( "$basetexture", self.rightTrackTexture )
        matTrackR:SetMatrix( "$basetexturetransform", scrollMatrix )
    end

    self:DrawModel()
end
