local IsValid = IsValid
local GetVolume = Glide.Config.GetVolume
local stallSound = Glide.stallSound

local function ProcessStallSound()
    local vehicle = Glide.currentVehicle
    if not IsValid( vehicle ) then return end

    if vehicle:GetIsStalling() then
        stallSound:SetVolume( GetVolume( "warningVolume" ) * vehicle.StallHornVolume )
    else
        stallSound:SetVolume( 0.0 )
    end
end

hook.Add( "Glide_OnLocalEnterVehicle", "Glide.StallNoise", function( vehicle, _ )
    if vehicle.VehicleType ~= Glide.VEHICLE_TYPE.PLANE then return end
    if not vehicle.StallHornSound or vehicle.StallHornSound == "" then return end

    sound.PlayFile( "sound/" .. vehicle.StallHornSound, "noplay noblock", function( snd )
        if not IsValid( snd ) then return end

        if not IsValid( vehicle ) then
            snd:Stop()
            return
        end

        stallSound = snd
        Glide.stallSound = snd

        snd:EnableLooping( true )
        snd:SetVolume( 0.0 )
        snd:Play()

        timer.Create( "Glide.StallNoise", 0.1, 0, ProcessStallSound )
    end )
end )

hook.Add( "Glide_OnLocalExitVehicle", "Glide.StallNoise", function()
    timer.Remove( "Glide.StallNoise" )

    if IsValid( stallSound ) then
        stallSound:Stop()
    end

    stallSound = nil
    Glide.stallSound = nil
end )
