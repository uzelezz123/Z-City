-- HUY
function hg.DermaPlayerQuery( fSelected, strName, strDesc )
    local query = vgui.Create("ZFrame")
    query:SetSize(300,150)
    query:SetTitle( strName or "Player Query")
    query.Label= vgui.Create("DLabel",query)
    local lbl = query.Label
    lbl:SetText( strDesc or "Select player" )
    lbl:SetContentAlignment(5)
    lbl:DockMargin(5,5,5,5)
    lbl:SizeToContents()
    lbl:Dock(TOP)

    local comboBox = vgui.Create( "DComboBox", query )
    comboBox:Dock( TOP )
    comboBox:DockMargin(15,5,15,5)
    comboBox:SetSize( 200, 30 )
    comboBox:SetValue( "All Players" )
    comboBox:SetContentAlignment(5)

    comboBox.OnSelect = function( _, _, _, value )
        query.Selected = value
    end

    for _, v in ipairs( player.GetAll() ) do
        comboBox:AddChoice( v:Name(), v )
    end

    local DButton = vgui.Create( "DButton", query )
    DButton:SetText( "Select" )
    DButton:Dock( BOTTOM )
    DButton:DockMargin(15,5,15,5)
    DButton:SetSize( 200, 30 )
    DButton.DoClick = function()
        fSelected( query.Selected )
        query:Close()
    end

    --query:InvalidateLayout()
    --query:SizeToChildren( true, true )
    query:Center()
    query:MakePopup()

    return query
end