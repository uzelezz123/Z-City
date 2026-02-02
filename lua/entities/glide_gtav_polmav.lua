AddCSLuaFile()

if not Glide then return end

ENT.GlideCategory = "GTAV_Helicopters"

ENT.Type = "anim"
ENT.Base = "base_glide_heli"
ENT.PrintName = "Maverick (Police)"

ENT.MainRotorOffset = Vector( 0, 0, 65 )
ENT.TailRotorOffset = Vector( -249, 12, 21 )

if CLIENT then
    ENT.CameraOffset = Vector( -700, 0, 150 )

    ENT.ExhaustPositions = {
        Vector( -37, 14, 30 ),
        Vector( -37, -14, 30 )
    }

    ENT.EngineFireOffsets = {
        { offset = Vector( 0, 0, 50 ), angle = Angle( 300, 0, 0 ) }
    }

    ENT.StrobeLights = {
        { offset = Vector( -290, 0, 70 ), blinkTime = 0 },
        { offset = Vector( -195, 55, 6 ), blinkTime = 0.1 },
        { offset = Vector( -195, -55, 6 ), blinkTime = 0.6 }
    }

    ENT.RotorBeatInterval = 0.09
end

if SERVER then
    ENT.ChassisMass = 500
    ENT.ChassisModel = "models/gta5/vehicles/polmav/polmav_body.mdl"

    ENT.MainRotorRadius = 200
    ENT.TailRotorRadius = 40

    ENT.MainRotorModel = "models/gta5/vehicles/polmav/polmav_rmain_slow.mdl"
    ENT.MainRotorFastModel = "models/gta5/vehicles/polmav/polmav_rmain_fast.mdl"

    ENT.TailRotorModel = "models/gta5/vehicles/polmav/polmav_rrear_slow.mdl"
    ENT.TailRotorFastModel = "models/gta5/vehicles/polmav/polmav_rrear_fast.mdl"

    ENT.ExplosionGibs = {
        "models/gta5/vehicles/gibs/polmav_gib1.mdl",
        "models/gta5/vehicles/gibs/polmav_gib2.mdl"
    }

    ENT.SpotlightOffset = Vector( 120, 0, -40 )

    DEFINE_BASECLASS( "base_glide_heli" )

    local IsValid = IsValid

    function ENT:CreateFeatures()
        self:CreateSeat( Vector( 80, 16, -20 ), nil, Vector( 80, 90, -40 ), true )
        self:CreateSeat( Vector( 80, -16, -20 ), nil, Vector( 80, -90, -40 ), true )

        self:CreateSeat( Vector( 40, 17, -38 ), Angle( 0, 0, 0 ), Vector( 0, 100, 0 ), true )
        self:CreateSeat( Vector( 40, -17, -38 ), Angle( 0, 180, 0 ), Vector( 0, 100, 0 ), true )

        self.isSpotlightOn = false
        self.keyToggle = false
    end

    function ENT:GetSpawnColor()
        return Color( 255, 255, 255 )
    end

    function ENT:TurnOnSpotlight()
        self.isSpotlightOn = true

        if not IsValid( self.lightSprite ) then
            self.lightSprite = ents.Create( "env_sprite" )
            self.lightSprite:SetParent( self )
            self.lightSprite:SetLocalPos( self.SpotlightOffset )
            self.lightSprite:SetKeyValue( "renderfx", "14" )
            self.lightSprite:SetKeyValue( "model", "sprites/glow1.vmt" )
            self.lightSprite:SetKeyValue( "scale", "1.0" )
            self.lightSprite:SetKeyValue( "spawnflags", "1" )
            self.lightSprite:SetKeyValue( "angles", "0 0 0" )
            self.lightSprite:SetKeyValue( "rendermode", "9" )
            self.lightSprite:SetKeyValue( "renderamt", "255" )
            self.lightSprite:SetKeyValue( "rendercolor", "255 255 255" )
            self.lightSprite:Spawn()

            self:DeleteOnRemove( self.lightSprite )
        end

        if not IsValid( self.lightProj ) then
            self.lightProj = ents.Create( "env_projectedtexture" )
            self.lightProj:SetParent( self )
            self.lightProj:SetLocalPos( self.SpotlightOffset )
            self.lightProj:SetKeyValue( "enableshadows", 0 )
            self.lightProj:SetKeyValue( "LightWorld", 1 )
            self.lightProj:SetKeyValue( "LightStrength", 6 )
            self.lightProj:SetKeyValue( "farz", 4096 )
            self.lightProj:SetKeyValue( "nearz", 2 )
            self.lightProj:SetKeyValue( "lightfov", 30 )
            self.lightProj:SetKeyValue( "lightcolor", "255 255 220" )
            self.lightProj:Spawn()
            self.lightProj:Input( "SpotlightTexture", NULL, NULL, "effects/flashlight001" )

            self:DeleteOnRemove( self.lightProj )
        end
    end

    function ENT:TurnOffSpotlight()
        self.isSpotlightOn = false

        if IsValid( self.lightSprite ) then
            self.lightSprite:Remove()
            self.lightSprite = nil
        end

        if IsValid( self.lightProj ) then
            self.lightProj:Remove()
            self.lightProj = nil
        end
    end

    function ENT:Think()
        BaseClass.Think( self )

        local driver = self:GetDriver()
        local keyToggle = false

        if IsValid( driver ) then
            keyToggle = driver:KeyDown( 1 ) -- IN_ATTACK

            if IsValid( self.lightProj ) then
                self.lightProj:SetAngles( driver:GlideGetCameraAngles() )
            end
        end

        if self.keyToggle ~= keyToggle then
            self.keyToggle = keyToggle

            if keyToggle then
                if self.isSpotlightOn then
                    self:TurnOffSpotlight()
                else
                    self:TurnOnSpotlight()
                end
            end
        end

        return true
    end
end
