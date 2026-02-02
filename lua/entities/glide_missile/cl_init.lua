include( "shared.lua" )

function ENT:Initialize()
    self.smokeSpinSpeed = math.random( 60, 110 )

    -- Create a RangedFeature to handle missile sounds
    self.missileSounds = Glide.CreateRangedFeature( self, 5000 )
    self.missileSounds:SetActivateCallback( "ActivateSound" )
    self.missileSounds:SetDeactivateCallback( "DeactivateSound" )

    -- Assume we have one for now, to avoid issues with the lock-on warnings clientside
    self:SetHasTarget( true )

    -- Update model angle/offset right away
    self:UpdateModelRenderMultiply()
end

function ENT:OnRemove()
    if self.missileSounds then
        self.missileSounds:Destroy()
        self.missileSounds = nil
    end
end

function ENT:ActivateSound()
    if not self.missileLoop then
        self.missileLoop = CreateSound( self, "glide/weapons/missile_loop.wav" )
        self.missileLoop:SetSoundLevel( 85 )
        self.missileLoop:Play()
    end
end

function ENT:DeactivateSound()
    if self.missileLoop then
        self.missileLoop:Stop()
        self.missileLoop = nil
    end
end

function ENT:UpdateModelRenderMultiply()
    local model = self:GetModel()
    self.lastModel = model

    local data = list.Get( "GlideProjectileModels" )[model]

    if not data then
        self:DisableMatrix( "RenderMultiply" )
        return
    end

    local scale = data.scale or 1
    local modelScale = self:GetModelScale()
    local m = Matrix()
    m:SetScale( Vector( scale, scale, scale ) )

    if data.offset then
        m:SetTranslation( data.offset * modelScale * scale )
    end

    if data.angle then
        m:SetAngles( data.angle )
    end

    self:EnableMatrix( "RenderMultiply", m )
end

local Effect = util.Effect
local EffectData = EffectData
local CurTime = CurTime

function ENT:Think()
    if self.missileSounds then
        self.missileSounds:Think()
    end

    if self:WaterLevel() > 0 then
        self.smokeSpinSpeed = nil

    elseif self.smokeSpinSpeed then
        local eff = EffectData()
        eff:SetOrigin( self:GetPos() )
        eff:SetNormal( -self:GetForward() )
        eff:SetColor( self.smokeSpinSpeed )
        eff:SetScale( self:GetEffectiveness() )
        Effect( "glide_missile", eff )
    end

    local model = self:GetModel()

    if model ~= self.lastModel then
        self:UpdateModelRenderMultiply()
    end

    self:SetNextClientThink( CurTime() + 0.02 )

    return true
end
