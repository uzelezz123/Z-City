AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_glide_boat"
ENT.PrintName = "Dinghy"

ENT.GlideCategory = "Default"
ENT.ChassisModel = "models/gta5/vehicles/dinghy/chassis.mdl"

-- Override the default first person offset
function ENT:GetFirstPersonOffset( _, localEyePos )
    localEyePos[1] = localEyePos[1] + 5
    localEyePos[3] = localEyePos[3] + 10

    return localEyePos
end

if CLIENT then
    ENT.CameraOffset = Vector( -400, 0, 100 )

    ENT.PropellerPositions = {
        Vector( -150, 14, -15 ),
        Vector( -150, -14, -15 )
    }

    ENT.EngineFireOffsets = {
        { offset = Vector( -155, 16, 32 ), angle = Angle( 0, 90, 0 ), scale = 1 },
        { offset = Vector( -155, -16, 32 ), angle = Angle( 0, 90, 0 ), scale = 1 }
    }

    ENT.EngineSmokeStrips = {
        { offset = Vector( -154, 16, 32 ), angle = Angle( 0, 180, 0 ), width = 15 },
        { offset = Vector( -154, -16, 32 ), angle = Angle( 0, 180, 0 ), width = 15 }
    }

    ENT.Headlights = {
        { offset = Vector( 170, 20.5, 27 ) },
        { offset = Vector( 170, -20.5, 27 ) },
        { offset = Vector( -131, -12.5, 105.5 ) }
    }

    ENT.LightSprites = {
        { type = "headlight", offset = Vector( 152, 18, 24.3 ), dir = Vector( 1, 0, 0 ) },
        { type = "headlight", offset = Vector( 152, -18, 24.3 ), dir = Vector( 1, 0, 0 ) },
        { type = "headlight", offset = Vector( -117, -11.5, 93.9 ), dir = Vector( 1, 0, 0 ) }
    }

    function ENT:OnCreateEngineStream( stream )
        stream:LoadPreset( "asea" )
    end

    function ENT:OnActivateMisc()
        self.propellerL = self:LookupBone( "propeller_l" )
        self.propellerR = self:LookupBone( "propeller_r" )
    end

    DEFINE_BASECLASS( "base_glide_boat" )

    local spinAng = Angle()

    -- Override this function to animate the propellers.
    function ENT:OnUpdateAnimations()
        -- Call the base class' `OnUpdateAnimations`
        -- to automatically update the steering pose parameter.
        BaseClass.OnUpdateAnimations( self )

        if not self.propellerL then return end

        local spinSpeed = self:GetEngineThrottle() + self:GetEnginePower()

        spinAng[1] = ( spinAng[1] + FrameTime() * spinSpeed * 2000 ) % 360

        self:ManipulateBoneAngles( self.propellerL, spinAng )
        self:ManipulateBoneAngles( self.propellerR, spinAng )
    end
end

if SERVER then
    ENT.SpawnPositionOffset = Vector( 0, 0, 50 )

    ENT.LightBodygroups = {
        { type = "headlight", bodyGroupId = 6, subModelId = 1 }
    }

    function ENT:CreateFeatures()
        self:CreateSeat( Vector( -36, 13, 13 ), Angle( 0, 270, 0 ), Vector( -36, 13, 55 ), true )
        self:CreateSeat( Vector( -27, -13, 15 ), Angle( 0, 270, 0 ), Vector( -36, -13, 55 ), true )
        self:CreateSeat( Vector( -72, 13, 15 ), Angle( 0, 270, 0 ), Vector( -80, 13, 55 ), true )
        self:CreateSeat( Vector( -72, -13, 15 ), Angle( 0, 270, 0 ), Vector( -80, -13, 55 ), true )
    end
end
