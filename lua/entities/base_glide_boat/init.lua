AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

DEFINE_BASECLASS( "base_glide" )

--- Implement this base class function.
function ENT:OnPostInitialize()
    self:SetEngineThrottle( 0 )
    self:SetEnginePower( 0 )
    self:SetIsHonking( false )

    -- Make boats more slidey on land
    local phys = self:GetPhysicsObject()

    if IsValid( phys ) then
        phys:SetMaterial( "glass" )
    end

    -- Trigger wire outputs
    if WireLib then
        WireLib.TriggerOutput( self, "EngineThrottle", 0 )
        WireLib.TriggerOutput( self, "EnginePower", 0 )
    end
end

--- Implement this base class function.
function ENT:OnDriverEnter()
    if self.startupTimer then return end

    if self:GetEngineState() < 2 then
        self:TurnOn()
    end
end

--- Implement this base class function.
function ENT:OnDriverExit()
    self:SetIsHonking( false )

    if self.hasRagdolledAllPlayers then
        BaseClass.OnDriverExit( self )
    else
        self:TurnOff()
    end
end

--- Implement this base class function.
function ENT:OnSeatInput( seatIndex, action, pressed )
    if seatIndex > 1 then return end

    if action == "horn" then
        self:SetIsHonking( pressed )
    end
end

--- Override this base class function.
function ENT:OnTakeDamage( dmginfo )
    BaseClass.OnTakeDamage( self, dmginfo )

    if self:GetEngineHealth() <= 0 and self:GetEngineState() == 2 then
        self:TurnOff()
    end
end

--- Override this base class function.
function ENT:TurnOn()
    BaseClass.TurnOn( self )
end

--- Override this base class function.
function ENT:TurnOff()
    BaseClass.TurnOff( self )

    self:SetEnginePower( 0 )
    self:SetEngineThrottle( 0 )
    self:SetIsHonking( false )

    self.startupTimer = nil
end

local Abs = math.abs
local Clamp = math.Clamp
local WORLD_UP = Vector( 0, 0, 1 )

local ExpDecay = Glide.ExpDecay
local TriggerOutput = WireLib and WireLib.TriggerOutput or nil

--- Implement this base class function.
function ENT:OnPostThink( dt, selfTbl )
    local state = self:GetEngineState()
    local health = self:GetEngineHealth()

    -- Attempt to start the engine
    if state == 1 then
        if selfTbl.startupTimer then
            if CurTime() > selfTbl.startupTimer then
                selfTbl.startupTimer = nil

                if health > 0 then
                    self:SetEngineState( 2 )
                else
                    self:SetEngineState( 0 )
                end
            end
        else
            local startupTime = health < 0.5 and math.Rand( 1, 2 ) or selfTbl.StartupTime
            selfTbl.startupTimer = CurTime() + startupTime
        end

    elseif state == 3 then
        -- This vehicle does not do a "shutdown" sequence.
        self:SetEngineState( 0 )
    end

    if self:IsEngineOn() then
        self:UpdateEngine( dt, selfTbl )
    end

    -- Update steer input
    self:SetSteering( ExpDecay( self:GetSteering(), self:GetInputFloat( 1, "steer" ), 8, dt ) )

    -- Check if the vehicle is fully upside down on water
    if self:GetWaterState() > 1 and self:GetUp():Dot( WORLD_UP ) < 0 then
        self:SetEngineThrottle( 0 )
        self:SetEnginePower( 0 )

        -- Damage the engine over time
        if health > 0 then
            self:TakeEngineDamage( dt * 0.2 )

        elseif self:GetEngineState() == 2 then
            self:TurnOff()
        end

        -- Kick passengers
        if #self:GetAllPlayers() > 0 then
            self:RagdollPlayers()
        end
    end

    if TriggerOutput then
        TriggerOutput( self, "EngineThrottle", self:GetEngineThrottle() )
        TriggerOutput( self, "EnginePower", self:GetEnginePower() )

        if selfTbl.wireSetEngineOn ~= nil then
            if selfTbl.wireSetEngineOn then
                if state < 1 then
                    self:TurnOn()
                end

            elseif state > 0 then
                self:TurnOff()
            end

            selfTbl.wireSetEngineOn = nil
        end
    end
end

function ENT:UpdateEngine( dt, selfTbl )
    local waterState = self:GetWaterState()
    local speed = selfTbl.forwardSpeed

    local inputThrottle = self:GetInputFloat( 1, "accelerate" )
    local throttle = 0

    if Abs( speed ) > 20 or waterState > 0 then
        throttle = inputThrottle - self:GetInputFloat( 1, "brake" )
    end

    self:SetEngineThrottle( ExpDecay( self:GetEngineThrottle(), throttle, 5, dt ) )

    local power = Abs( throttle )

    if throttle < 0 then
        power = power * Clamp( -speed / self.BoatParams.maxSpeed * 4, 0, 1 )
        power = power * 0.4

    elseif waterState > 0 then
        power = power * ( waterState > 1 and ( 0.4 + Clamp( Abs( speed ) / self.BoatParams.maxSpeed, 0, 1 ) * 0.6 ) or 1.0 )
        power = power * ( waterState > 1 and 0.6 or 1 )
    end

    self:SetEnginePower( ExpDecay( self:GetEnginePower(), power, 2 + power * 2, dt ) )
end

--- Implement this base class function.
function ENT:OnSimulatePhysics( phys, dt, outLin, outAng )
    self:SimulateBoat( phys, dt, outLin, outAng, self:GetEngineThrottle(), self:GetInputFloat( 1, "steer" ) )
end

--- Override this base class function.
function ENT:TriggerInput( name, value )
    BaseClass.TriggerInput( self, name, value )

    if name == "Ignition" then
        -- Avoid continuous triggers
        self.wireSetEngineOn = value > 0

    elseif name == "Throttle" then
        self:SetInputFloat( 1, "accelerate", Clamp( value, 0, 1 ) )

    elseif name == "Steer" then
        self:SetInputFloat( 1, "steer", Clamp( value, -1, 1 ) )

    elseif name == "Brake" then
        self:SetInputFloat( 1, "brake", Clamp( value, 0, 1 ) )

    elseif name == "TightTurn" then
        self:SetInputBool( 1, "handbrake", value > 0 )

    elseif name == "Horn" then
        self:SetIsHonking( value > 0 )

    end
end

--- Override this base class function.
function ENT:SetupWiremodPorts( inputs, outputs )
    BaseClass.SetupWiremodPorts( self, inputs, outputs )

    inputs[#inputs + 1] = { "Ignition", "NORMAL", "1: Turn the engine on\n0: Turn the engine off" }
    inputs[#inputs + 1] = { "Steer", "NORMAL", "A value between -1.0 and 1.0" }
    inputs[#inputs + 1] = { "Throttle", "NORMAL", "A value between 0.0 and 1.0\nAlso acts as brake input when reversing." }
    inputs[#inputs + 1] = { "Brake", "NORMAL", "A value between 0.0 and 1.0\nAlso acts as throttle input when reversing." }
    inputs[#inputs + 1] = { "TightTurn", "NORMAL", "A value larger than 0 will let the boat do tight turns" }
    inputs[#inputs + 1] = { "Horn", "NORMAL", "Set to 1 to sound the horn" }

    outputs[#outputs + 1] = { "EngineThrottle", "NORMAL", "Current engine throttle" }
    outputs[#outputs + 1] = { "EnginePower", "NORMAL", "Current engine power" }
end
