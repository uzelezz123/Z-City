AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "#glide.engine_stream_chip"
ENT.Category = "Glide"
ENT.IconOverride = "styledstrike/icons/speaker.png"

ENT.Spawnable = true
ENT.AdminOnly = false
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
    self:NetworkVar( "Bool", "IsActive" )
    self:NetworkVar( "Bool", "IsRedlining" )
    self:NetworkVar( "Float", "Throttle" )
    self:NetworkVar( "Float", "RPMFraction" )
end

if CLIENT then
    function ENT:Initialize()
        -- Create a RangedFeature to handle the engine steam sound
        self.rfSounds = Glide.CreateRangedFeature( self, 5000 )
        self.rfSounds:SetTestCallback( "ShouldActivateSounds" )
        self.rfSounds:SetDeactivateCallback( "DeactivateSounds" )
        self.rfSounds:SetUpdateCallback( "UpdateSounds" )

        self.streamJSONOverride = nil
        self.doWobble = false
    end

    function ENT:OnRemove( fullUpdate )
        if fullUpdate then return end

        if self.rfSounds then
            self.rfSounds:Destroy()
            self.rfSounds = nil
        end
    end

    function ENT:Think()
        self:SetNextClientThink( CurTime() )

        if self.rfSounds then
            self.rfSounds:Think()
        end

        return true
    end

    function ENT:ShouldActivateSounds()
        return self:GetIsActive()
    end

    function ENT:DeactivateSounds()
        if self.stream then
            self.stream:Destroy()
            self.stream = nil
        end
    end

    local Pow = math.pow

    function ENT:UpdateSounds()
        local stream = self.stream

        if not stream then
            self.stream = Glide.CreateEngineStream( self )

            if self.streamJSONOverride then
                self.stream:LoadJSON( self.streamJSONOverride )
            else
                self:OnCreateEngineStream( self.stream )
            end

            self.stream:Play()
            self.stream.firstPerson = false

            return
        end

        local throttle = self:GetThrottle()
        local inputs = stream.inputs

        if throttle > inputs.throttle and self.doWobble then
            stream.wobbleTime = 1
        end

        inputs.throttle = Pow( throttle, 0.6 )
        inputs.rpmFraction = self:GetRPMFraction()
        stream.isRedlining = self:GetIsRedlining() and inputs.throttle > 0.95
    end

    function ENT:OnCreateEngineStream( stream )
        stream:LoadPreset( "wolfsbane" )
    end
end

if not SERVER then return end

function ENT:OnEntityCopyTableFinish( data )
    Glide.FilterEntityCopyTable( data, nil, {} )
end

function ENT:PreEntityCopy()
    Glide.PreEntityCopy( self )
end

function ENT:PostEntityPaste( ply, ent, createdEntities )
    Glide.PostEntityPaste( ply, ent, createdEntities )
end

local function MakeSpawner( ply, data )
    if IsValid( ply ) and not ply:CheckLimit( "glide_engine_stream_chips" ) then return end

    local ent = ents.Create( data.Class )
    if not IsValid( ent ) then return end

    ent:SetPos( data.Pos )
    ent:SetAngles( data.Angle )
    ent:SetCreator( ply )
    ent:Spawn()
    ent:Activate()

    ply:AddCount( "glide_engine_stream_chips", ent )
    cleanup.Add( ply, "glide_engine_stream_chips", ent )

    return ent
end

duplicator.RegisterEntityClass( "glide_engine_stream_chip", MakeSpawner, "Data" )

function ENT:SpawnFunction( ply, tr )
    if tr.Hit then
        return MakeSpawner( ply, {
            Pos = tr.HitPos,
            Angle = Angle(),
            Class = self.ClassName
        } )
    end
end

function ENT:Initialize()
    self:SetModel( "models/cheeze/wires/speaker.mdl" )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
    self:DrawShadow( false )

    if WireLib then
        WireLib.CreateSpecialInputs( self,
            { "Active", "IsRedlining", "Throttle", "RPMFraction" },
            { "NORMAL", "NORMAL", "NORMAL", "NORMAL" },
            {
                "Should the engine audio play? (>0 to play)",
                "Should the 'redline' audio effect be applied? (>0 to apply)",
                "Engine throttle (0.0 - 1.0)",
                "Engine RPM fraction (0.0 - 1.0)"
            }
        )
    end
end

local Clamp = math.Clamp

function ENT:TriggerInput( name, value )
    if name == "Active" then
        self:SetIsActive( value > 0 )

    elseif name == "IsRedlining" then
        self:SetIsRedlining( value > 0 )

    elseif name == "Throttle" then
        self:SetThrottle( Clamp( value, 0, 1 ) )

    elseif name == "RPMFraction" then
        self:SetRPMFraction( Clamp( value, 0, 1 ) )
    end
end
