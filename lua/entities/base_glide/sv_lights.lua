function ENT:ChangeHeadlightState( state, dontPlaySound )
    if not self.CanSwitchHeadlights then return end

    state = math.floor( state )

    if state < 0 then state = 2 end
    if state > 2 then state = 0 end

    self:SetHeadlightState( state )

    if dontPlaySound then return end

    local driver = self:GetDriver()
    local soundEnt = IsValid( driver ) and driver or self

    soundEnt:EmitSound( state == 0 and "glide/headlights_off.wav" or "glide/headlights_on.wav", 70, 100, 1.0 )
end

function ENT:ChangeTurnSignalState( state, dontPlaySound )
    if not self.CanSwitchTurnSignals then return end

    state = math.Clamp( math.floor( state ), 0, 3 )
    self:SetTurnSignalState( state )

    if dontPlaySound then return end

    local driver = self:GetDriver()
    local soundEnt = IsValid( driver ) and driver or self

    soundEnt:EmitSound( state == 0 and "glide/headlights_off.wav" or "glide/headlights_on.wav", 70, 60, 0.5 )
end

local lightState = {
    brake = false,
    reverse = false,
    headlight = false,
    brake_or_taillight = false,
    signal_left = false,
    signal_right = false
}

local CurTime = CurTime

--- Update out model's bodygroups depending on which lights are on.
function ENT:UpdateLightBodygroups()
    local headlightState = self:GetHeadlightState()
    local allowLights = self:IsEngineOn() or headlightState > 0

    lightState.brake = allowLights and self:IsBraking()
    lightState.reverse = allowLights and self:IsReversing()
    lightState.headlight = headlightState > 0
    lightState.brake_or_taillight = lightState.brake or lightState.headlight

    local signal = self:GetTurnSignalState()
    local signalBlink = ( CurTime() % self.TurnSignalCycle ) > self.TurnSignalCycle * 0.5

    lightState.signal_left = signal == 1 or signal == 3
    lightState.signal_right = signal == 2 or signal == 3

    local lastBodygroups = self.lastBodygroups
    local enable, targetSubModel

    for _, l in ipairs( self.LightBodygroups ) do
        enable = lightState[l.type]

        -- Blink "signal_*" light types
        if l.type == "signal_left" or l.type == "signal_right" then
            enable = enable and signalBlink
        end

        -- Allow other types of light to blink with turn signals, if "signal" is set.
        if l.signal and signal > 0 then
            if l.signal == "left" and lightState.signal_left then
                enable = signalBlink

            elseif l.signal == "right" and lightState.signal_right then
                enable = signalBlink
            end
        end

        -- If the light has a `beamType` key, only enable the bodygroup
        -- if the value of `beamType` matches the current headlight state.
        if
            ( l.beamType == "low" and headlightState ~= 1 ) or
            ( l.beamType == "high" and headlightState ~= 2 )
        then
            enable = false
        end

        targetSubModel = enable and l.subModelId or 0

        if lastBodygroups[l.bodyGroupId] ~= targetSubModel then
            lastBodygroups[l.bodyGroupId] = targetSubModel
            self:SetBodygroup( l.bodyGroupId, targetSubModel )
        end
    end
end
