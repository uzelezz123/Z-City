TOOL.Category = "Glide"
TOOL.Name = "#tool.glide_transmission_editor.name"

TOOL.Information = {
    { name = "left" },
    { name = "right" },
    { name = "reload" },
}

TOOL.ClientConVar = {
    data = [[{"-1": 2.5, "1": 2.8, "2": 1.7, "3": 1.2,"4": 0.9, "5": 0.75, "6": 0.7 }]]
}

local IsValid = IsValid

local function IsGlideVehicleWithTransmission( ent )
    return IsValid( ent ) and ent.IsGlideVehicle and ent.GetGear
end

local ApplyTransmissionData

if SERVER then
    ApplyTransmissionData = function( _ply, ent, data )
        if not IsGlideVehicleWithTransmission( ent ) then return false end

        -- Make sure we've valid transmission data
        data = Glide.ValidateTransmissionData( data )

        duplicator.ClearEntityModifier( ent, "glide_transmission_overrides" )

        if data[1] then
            duplicator.StoreEntityModifier( ent, "glide_transmission_overrides", data )
        end

        ent:UpdateGearList()

        return true
    end

    duplicator.RegisterEntityModifier( "glide_transmission_overrides", ApplyTransmissionData )
end

local function GetGlideVehicle( trace )
    local ent = trace.Entity

    if IsGlideVehicleWithTransmission( ent ) then
        return ent
    end

    return false
end

function TOOL:LeftClick( trace )
    local vehicle = GetGlideVehicle( trace )
    if not vehicle then return false end

    if SERVER then
        local data = Glide.FromJSON( self:GetClientInfo( "data" ) )
        return ApplyTransmissionData( self:GetOwner(), vehicle, data )
    end

    return true
end

function TOOL:RightClick( trace )
    local vehicle = GetGlideVehicle( trace )
    if not vehicle then return false end

    if SERVER then
        local gears = vehicle:GetGearList()
        gears = Glide.ToJSON( gears, false )

        self:GetOwner():ConCommand( "glide_transmission_editor_data " .. gears )
    end

    return true
end

function TOOL:Reload( trace )
    local vehicle = GetGlideVehicle( trace )
    if not vehicle then return false end

    if SERVER then
        duplicator.ClearEntityModifier( vehicle, "glide_transmission_overrides" )
        vehicle:UpdateGearList()
    end

    return true
end

if not CLIENT then return end

function Glide.RefreshTransmissionToolPanel()
    local panel = Glide.transmissionToolPanel
    if not IsValid( panel ) then return end

    panel:Clear()

    local cvarData = GetConVar( "glide_transmission_editor_data" )
    if not cvarData then return end

    panel:Help( "#tool.glide_transmission_editor.desc" )

    local data = Glide.FromJSON( cvarData:GetString() )

    -- Make sure we've valid transmission data
    data = Glide.ValidateTransmissionData( data )

    local function OnDataChanged( updateUI )
        local jsonData = Glide.ToJSON( data, false )

        if jsonData then
            Glide._isChangingTransmissionToolCvar = true
            cvarData:SetString( jsonData )
            Glide._isChangingTransmissionToolCvar = nil
        end

        if updateUI then
            Glide.RefreshTransmissionToolPanel()
        end
    end

    local function OnChangeCheckbox( s, checked )
        data[s._gearIndex] = checked and s._gearSlider:GetValue() or nil
        OnDataChanged( false )
    end

    local function OnChangeRatio( s, value )
        data[s._gearIndex] = math.Round( value, 2 )
        OnDataChanged( false )
    end

    local function OnClickRemove( s )
        local removeIndex = s._gearIndex
        local newData = { [-1] = data[-1], [0] = 0 }
        local newIndex = 0

        for oldIndex, ratio in SortedPairs( data ) do
            if oldIndex > 0 and oldIndex ~= removeIndex then
                newIndex = newIndex + 1
                newData[newIndex] = ratio
            end
        end

        data = newData
        OnDataChanged( true )
    end

    local PerformSliderLayout = function( s )
        s.Label:SetWide( 30 )
    end

    local labelColor = Color( 255, 255, 255 )
    local fixedBgColor = Color( 50, 50, 50 )
    local removableBgColor = Color( 30, 30, 30 )

    local function AddRow( index, ratio, removable )
        local row = vgui.Create( "DPanel", panel )
        row:SetTall( 30 )
        row:SetPaintBackground( true )
        row:SetBackgroundColor( removable and removableBgColor or fixedBgColor )
        row:Dock( TOP )
        row:DockMargin( 0, 0, 0, 0 )
        row:DockPadding( 6, 0, 0, 0 )
        panel:AddItem( row )

        local ratioSlider = vgui.Create( "DNumSlider", row )
        ratioSlider:SetMin( 0.05 )
        ratioSlider:SetMax( Glide.MAX_GEAR_RATIO )
        ratioSlider:SetValue( ratio or 2.5 )
        ratioSlider:SetText( ( index == -1 ) and "R" or ( "#" .. index ) )
        ratioSlider:SetWide( 150 )
        ratioSlider:Dock( FILL )

        ratioSlider.TextArea:SetTextColor( labelColor )
        ratioSlider.Label:SetColor( labelColor )

        ratioSlider._gearIndex = index
        ratioSlider.PerformLayout = PerformSliderLayout
        ratioSlider.OnValueChanged = OnChangeRatio

        if removable then
            local buttonRemove = vgui.Create( "DButton", row )
            buttonRemove:SetText( "" )
            buttonRemove:SetIcon( "icon16/delete.png" )
            buttonRemove:Dock( RIGHT )
            buttonRemove:SizeToContentsX( -4 )

            buttonRemove._gearIndex = index
            buttonRemove.DoClick = OnClickRemove

        elseif index == -1 then
            local checkEnableRev = vgui.Create( "DCheckBox", row )
            checkEnableRev:SetValue( ratio ~= nil )
            checkEnableRev:Dock( RIGHT )
            checkEnableRev:DockMargin( 0, 8, 9, 6 )

            checkEnableRev._gearIndex = index
            checkEnableRev._gearSlider = ratioSlider
            checkEnableRev.OnChange = OnChangeCheckbox
        else
            row:DockPadding( 6, 0, 24, 0 )
        end

        return row
    end

    AddRow( -1, data[-1], false )

    local largestGear = 0

    for index, ratio in SortedPairs( data ) do
        if index > 0 then
            largestGear = index
            AddRow( index, ratio, index > 1 )
        end
    end

    local buttonAdd = panel:Button( "#tool.glide_transmission_editor.add_gear" )
    buttonAdd:SetIcon( "icon16/add.png" )

    if data[Glide.MAX_GEAR] then
        buttonAdd:SetEnabled( false )
    else
        buttonAdd.DoClick = function()
            data[largestGear + 1] = 1.0
            OnDataChanged( true )
        end
    end

    local buttonReset = panel:Button( "#glide.misc.reset_settings" )
    buttonReset:SetIcon( "icon16/arrow_refresh.png" )

    buttonReset.DoClick = function()
        data = Glide.FromJSON( cvarData:GetDefault() )
        OnDataChanged( true )
    end
end

Glide.RefreshTransmissionToolPanel()

function TOOL.BuildCPanel( panel )
    Glide.transmissionToolPanel = panel
    Glide.RefreshTransmissionToolPanel()
end

cvars.AddChangeCallback( "glide_transmission_editor_data", function()
    -- Ignore changes done by the tool panel
    if not Glide._isChangingTransmissionToolCvar then
        Glide.RefreshTransmissionToolPanel()
    end
end, "refresh_transmission_panel" )
