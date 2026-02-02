local PlayerMeta = FindMetaTable( "Player" )
local EntityMeta = FindMetaTable( "Entity" )

do
    local GetNWEntity = EntityMeta.GetNWEntity
    local GetNWInt = EntityMeta.GetNWInt

    function PlayerMeta:GlideGetVehicle()
        return GetNWEntity( self, "GlideVehicle", NULL )
    end

    function PlayerMeta:GlideGetSeatIndex()
        return GetNWInt( self, "GlideSeatIndex", 0 )
    end
end

if SERVER then
    --- Get the player's Glide camera angles.
    function PlayerMeta:GlideGetCameraAngles()
        return self:GetAimVector():Angle()//self:LocalEyeAngles()
    end

    local TraceLine = util.TraceLine
    local eyePos = EntityMeta.EyePos

    function PlayerMeta:GlideGetAimPos()
        local origin = eyePos( self )

        return TraceLine( {
            start = origin,
            endpos = origin + self:GlideGetCameraAngles():Forward() * 50000,
            filter = { self, self:GlideGetVehicle() }
        } ).HitPos
    end

    --- Utility function to get the entity creator
    --- or CPPI owner from a entity.
    function Glide.GetEntityCreator( source )
        local ply

        if source.CPPIGetOwner then
            ply = source:CPPIGetOwner()
        end

        if type( ply ) == "number" then
            ply = nil
        end

        if not IsValid( ply ) then
            ply = source:GetCreator()
        end

        return ply
    end

    --- Utility function to set the entity creator
    --- or CPPI owner for a entity.
    function Glide.SetEntityCreator( target, ply )
        target:SetCreator( ply or NULL )

        if target.CPPISetOwner then
            target:CPPISetOwner( ply )
        end
    end

    --- Utility function to copy the entity creator
    --- or CPPI owner from one entity to another.
    function Glide.CopyEntityCreator( source, target )
        local ply = Glide.GetEntityCreator( source )
        Glide.SetEntityCreator( target, ply )
    end
end
