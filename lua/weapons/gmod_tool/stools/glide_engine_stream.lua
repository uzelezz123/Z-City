TOOL.Category = "Glide"
TOOL.Name = "#tool.glide_engine_stream.name"

TOOL.Information = {
    { name = "left" },
    { name = "right" },
    { name = "reload" }
}

local function GetGlideVehicle( trace )
    local ent = trace.Entity

    if Glide.DoesEntitySupportEngineStreamPreset( ent ) then
        return ent
    end

    return false
end

function TOOL:CanSendData( veh )
    if CLIENT and not veh.OnCreateEngineStream then
        return false
    end

    local t = CurTime()

    if self.fireCooldown and t < self.fireCooldown then
        return false
    end

    self.fireCooldown = t + 0.5

    return true
end

function TOOL:LeftClick( trace )
    if not game.SinglePlayer() and not IsFirstTimePredicted() then return end

    local veh = GetGlideVehicle( trace )
    if not veh then return false end
    if not self:CanSendData( veh ) then return end

    if SERVER and game.SinglePlayer() then
        self:GetOwner():SendLua( "LocalPlayer():GetTool():LeftClick( LocalPlayer():GetEyeTrace() )" )
    end

    if CLIENT then
        local data = Glide.lastStreamPresetData

        if not data then
            Glide.Notify( {
                text = "#tool.glide_engine_stream.no_data",
                icon = "materials/icon16/cancel.png",
                sound = "glide/ui/radar_alert.wav",
                immediate = true
            } )

            return false
        end

        data = util.Compress( data )

        local size = #data

        if size > Glide.MAX_JSON_SIZE then
            Glide.Print( "Tried to write data that was too big! (%d/%d)", size, Glide.MAX_JSON_SIZE )
            return
        end

        Glide.StartCommand( Glide.CMD_UPLOAD_ENGINE_STREAM_PRESET, false )
        net.WriteEntity( veh )
        net.WriteUInt( size, 16 )
        net.WriteData( data )
        net.SendToServer()
    end

    return true
end

function TOOL:RightClick( _trace )
    if not game.SinglePlayer() and not IsFirstTimePredicted() then return end

    if SERVER and game.SinglePlayer() then
        self:GetOwner():SendLua( "LocalPlayer():GetTool():RightClick()" )
    end

    if CLIENT then
        Glide:OpenSoundEditor()
    end

    return false
end

function TOOL:Reload( trace )
    local veh = GetGlideVehicle( trace )
    if not veh then return false end
    if not self:CanSendData( veh ) then return false end

    if SERVER then
        Glide.ClearEngineStreamPresetModifier( veh )
    end

    return true
end

function TOOL.BuildCPanel( panel )
    panel:Help( "#tool.glide_engine_stream.desc" )
end
