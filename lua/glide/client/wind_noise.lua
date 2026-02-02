local IsValid = IsValid
local Clamp = math.Clamp
local GetVolume = Glide.Config.GetVolume
local windSound = Glide.windSound

local function ProcessWindSound()
    local vehicle = Glide.currentVehicle

    if IsValid( vehicle ) then
        local _, volume = vehicle:AllowWindSound( Glide.currentSeatIndex )
        local mult = vehicle:GetVelocity():LengthSqr() - 1000
        mult = Clamp( mult / 2500000, 0, 1 )

        windSound:SetVolume( GetVolume( "windVolume" ) * mult * Clamp( volume, 0, 1 ) )
        windSound:SetPlaybackRate( 0.7 + mult * 0.3 )
    end
end

hook.Add( "Glide_OnLocalEnterVehicle", "Glide.WindNoise", function( vehicle, seatIndex )
    local allow = vehicle:AllowWindSound( seatIndex )
    if not allow then return end
    if windSound then return end

    sound.PlayFile( "sound/glide/streams/wind.ogg", "noplay noblock", function( snd )
        if not IsValid( snd ) then return end

        if not IsValid( vehicle ) then
            snd:Stop()
            return
        end

        windSound = snd
        Glide.windSound = snd

        snd:EnableLooping( true )
        snd:SetVolume( 0.0 )
        snd:Play()

        hook.Add( "Tick", "Glide.WindNoise", ProcessWindSound )
    end )
end )

hook.Add( "Glide_OnLocalExitVehicle", "Glide.WindNoise", function()
    hook.Remove( "Tick", "Glide.WindNoise" )

    if IsValid( windSound ) then
        windSound:Stop()
    end

    windSound = nil
    Glide.windSound = nil
end )
