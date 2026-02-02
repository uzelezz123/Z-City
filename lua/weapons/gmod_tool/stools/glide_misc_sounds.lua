TOOL.Category = "Glide"
TOOL.Name = "#tool.glide_misc_sounds.name"

TOOL.Information = {
    { name = "left" },
    { name = "right" },
    { name = "reload" }
}

local presetData = Glide.miscSoundsToolData or {}
Glide.miscSoundsToolData = presetData

local function SetPresetData( key, path )
    if path == "" then
        path = nil
    end

    if path then
        presetData[key] = path
        cookie.Set( "tool.glide_misc_sounds." .. key, path )
    else
        presetData[key] = nil
        cookie.Delete( "tool.glide_misc_sounds." .. key )
    end
end

do
    local GetString = cookie.GetString

    for _, key in ipairs( Glide.GetAllMiscSoundKeys() ) do
        presetData[key] = GetString( "tool.glide_misc_sounds." .. key )
    end
end

local function GetGlideVehicle( trace )
    local ent = trace.Entity

    if Glide.DoesEntitySupportMiscSoundsPreset( ent ) then
        return ent
    end

    return false
end

function TOOL:CanSendData()
    local t = CurTime()

    if self.fireCooldown and t < self.fireCooldown then
        return false
    end

    self.fireCooldown = t + 0.5

    return true
end

function TOOL:LeftClick( trace )
    local veh = GetGlideVehicle( trace )
    if not veh then return false end
    if not self:CanSendData() then return end

    if SERVER and game.SinglePlayer() then
        self:GetOwner():SendLua( "LocalPlayer():GetTool():LeftClick( LocalPlayer():GetEyeTrace() )" )
    end

    if CLIENT then
        if not game.SinglePlayer() and not IsFirstTimePredicted() then return end

        local data = util.Compress( Glide.ToJSON( presetData ) )
        local size = #data

        if size > Glide.MAX_JSON_SIZE then
            Glide.Print( "Tried to write data that was too big! (%d/%d)", size, Glide.MAX_JSON_SIZE )
            return
        end

        Glide.StartCommand( Glide.CMD_UPLOAD_MISC_SOUNDS_PRESET, false )
        net.WriteEntity( veh )
        net.WriteUInt( size, 16 )
        net.WriteData( data )
        net.SendToServer()
    end

    return true
end

function TOOL:RightClick( trace )
    local veh = GetGlideVehicle( trace )
    if not veh then return false end

    if SERVER and game.SinglePlayer() then
        self:GetOwner():SendLua( "LocalPlayer():GetTool():RightClick( LocalPlayer():GetEyeTrace() )" )
    end

    if CLIENT then
        if not game.SinglePlayer() and not IsFirstTimePredicted() then return end

        for _, key in ipairs( Glide.GetAllMiscSoundKeys() ) do
            SetPresetData( key, veh[key] )
        end

        if Glide.miscSoundsToolRefreshPanel then
            Glide.miscSoundsToolRefreshPanel()
        end
    end

    return true
end

function TOOL:Reload( trace )
    local veh = GetGlideVehicle( trace )
    if not veh then return false end
    if not self:CanSendData() then return false end

    if SERVER then
        Glide.ClearMiscSoundsPresetModifier( veh )
    end

    return true
end

local TEXT_COLOR = Color( 255, 255, 255, 255 )
local HEADER_HEIGHT = 28

local function CategoryPaint( s, w, h )
    surface.SetDrawColor( 30, 30, 30, 255 )
    surface.DrawRect( 0, 0, w, h )

    surface.SetDrawColor( 70, 70, 70, 255 )
    surface.DrawRect( 0, 0, w, HEADER_HEIGHT )

    draw.SimpleText( s._name, "Trebuchet18", 4, HEADER_HEIGHT * 0.5, TEXT_COLOR, 0, 1 )
end

local function OnClickPickPath( s )
    local key = s._key
    local refresh = s._refreshFunction
    local title = language.GetPhrase( "tool.glide_misc_sounds.browse_sound" )

    local browser = StyledTheme.CreateFileBrowser()
    browser:SetIcon( "icon16/sound.png" )
    browser:SetTitle( string.format( title, key ) )
    browser:SetExtensionFilter( { "mp3", "wav" } )
    browser:SetBasePath( "sound/" )
    browser:NavigateTo( Glide.miscSoundsToolLastDir or "/" )

    browser.OnConfirmPath = function( path )
        path = path:sub( 7 ) -- Remove "sound/"
        Glide.miscSoundsToolLastDir = string.GetPathFromFilename( path )

        SetPresetData( key, path )
        refresh()
    end
end

local function OnClickReset( s )
    presetData[s._key] = nil
    SetPresetData( s._key, nil )
    s._refreshFunction()
end

function TOOL.BuildCPanel( panel )
    local RefreshPanel

    local CreateItem = function( key, parent )
        local keyPanel = vgui.Create( "Panel", parent )
        keyPanel:SetTall( 30 )
        keyPanel:Dock( TOP )
        keyPanel:DockMargin( 0, 0, 0, 4 )

        local keyLabel = vgui.Create( "DLabel", keyPanel )
        keyLabel:SetText( key )
        keyLabel:SetWide( 150 )
        keyLabel:Dock( LEFT )

        local pathLabel = vgui.Create( "DLabel", keyPanel )
        pathLabel:SetText( presetData[key] or "#tool.glide_misc_sounds.keep" )
        pathLabel:SetWide( 180 )
        pathLabel:Dock( FILL )

        local pathButton = vgui.Create( "DButton", keyPanel )
        pathButton:SetText( "" )
        pathButton:SetTooltip( "#tool.glide_misc_sounds.pick_file" )
        pathButton:SetIcon( "icon16/sound.png" )
        pathButton:SetWide( 24 )
        pathButton:Dock( RIGHT )

        pathButton.DoClick = OnClickPickPath
        pathButton._refreshFunction = RefreshPanel
        pathButton._key = key

        if presetData[key] then
            local resetButton = vgui.Create( "DButton", keyPanel )
            resetButton:SetText( "" )
            resetButton:SetTooltip( "#tool.glide_misc_sounds.reset_file" )
            resetButton:SetIcon( "icon16/arrow_undo.png" )
            resetButton:SetWide( 24 )
            resetButton:Dock( RIGHT )

            resetButton.DoClick = OnClickReset
            resetButton._refreshFunction = RefreshPanel
            resetButton._key = key
        end
    end

    RefreshPanel = function()
        if not IsValid( panel ) then return end

        panel:Clear()
        panel:Help( "#tool.glide_misc_sounds.desc" )

        for _, category in ipairs( Glide.MISC_SOUND_CATEGORIES ) do
            local categoryPanel = vgui.Create( "DPanel" )
            categoryPanel:DockPadding( 4, HEADER_HEIGHT + 4, 4, 4 )
            categoryPanel.Paint = CategoryPaint
            categoryPanel._name = category.label

            local totalHeight = HEADER_HEIGHT + 4

            for _, key in ipairs( category.keys ) do
                CreateItem( key, categoryPanel )
                totalHeight = totalHeight + 34
            end

            categoryPanel:SetTall( totalHeight )
            panel:AddPanel( categoryPanel )
        end

        local resetAllButton = vgui.Create( "DButton" )
        resetAllButton:SetText( "#tool.glide_misc_sounds.reload" )
        resetAllButton:SetIcon( "icon16/arrow_undo.png" )

        resetAllButton.DoClick = function()
            for _, key in ipairs( Glide.GetAllMiscSoundKeys() ) do
                SetPresetData( key, nil )
            end

            RefreshPanel()
        end

        panel:AddPanel( resetAllButton )
    end

    RefreshPanel()
    Glide.miscSoundsToolRefreshPanel = RefreshPanel
end
