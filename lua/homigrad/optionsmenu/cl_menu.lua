--

local modes = {}
modes.slider = function(optiondata, panel)
    -- optiondata = {convar = "convarname",desc = "descreption", min = 123, max = 123}
    local DermaNumSlider = vgui.Create( "DNumSlider", panel )
    DermaNumSlider:Dock( TOP )
    DermaNumSlider:DockMargin(10,5,5,2.5)	
    DermaNumSlider:SetSize(50,45)	
    DermaNumSlider:SetText( optiondata.convar .. "\n" .. optiondata.desc )	
    DermaNumSlider:SetMin( optiondata.min )				 	
    DermaNumSlider:SetMax( optiondata.max )				
    DermaNumSlider:SetDecimals( optiondata.decimals or 0 )				
    DermaNumSlider:SetConVar( optiondata.convar )	
    DermaNumSlider:SizeToContents()
end
modes.switcher = function(optiondata, panel)
    -- optiondata = {convar = "convarname",desc = "descreption"}
    local DermaCheckbox = panel:Add( "DCheckBoxLabel" )
	DermaCheckbox:Dock( TOP )
    DermaCheckbox:DockMargin(10,5,10,2.5)
	DermaCheckbox:SetText( optiondata.convar .. "\n" .. optiondata.desc )
	DermaCheckbox:SetConVar( optiondata.convar )
	DermaCheckbox:SetValue( GetConVar(optiondata.convar):GetBool() )
	DermaCheckbox:SizeToContents()		
end
modes.binder = function(optiondata, panel)
    -- optiondata = {convar = "convarname",desc = "descreption"}
end

local options = {}

-- optiondata = {desc = "descreption", and mode vars}
function hg.AddOptionPanel( convarname, mode, optiondata, category )
    optiondata = optiondata or {}
    category = category or "other"
    optiondata.convar = convarname

    options[category] = options[category] or {}

    options[category][convarname] = {mode, optiondata}
end

hg.AddOptionPanel( "hg_potatopc", "switcher", {desc = "Enables weaker effects. Use for weak PCs"}, "optimization" )
hg.AddOptionPanel( "hg_dynamic_mags", "switcher", {desc = "Enables the \"floating Ammo HUD\" feature"}, "other" )
hg.AddOptionPanel( "hg_anims_draw_distance", "slider", {desc = "Changes the rendering distance of animations\nCan help increase FPS | 0 - inf",min = 0,max = 4096}, "optimization" )
hg.AddOptionPanel( "hg_attachment_draw_distance", "slider", {desc = "Changes the rendering distance of attachments\nCan help increase FPS | 0 - inf",min = 0,max = 4096}, "optimization" )
hg.AddOptionPanel( "hg_old_notificate", "switcher", {desc = "Enables old damage notifications (in chat)",min = 0,max = 4096}, "other" )
hg.AddOptionPanel( "hg_weaponshotblur_enable", "switcher", {desc = "Enables blur when you are shooting the weapon",min = 0,max = 4096}, "other" )
hg.AddOptionPanel( "hg_weaponshotblur_mul", "slider", {desc = "Multiplicates the blur that happens when you are shooting the weapon",min = 0,max = 1,decimals = 3}, "other" )
-- hg.AddOptionPanel( "hg_bulletholes", "slider", {desc = "Amount of bullet hole effects (Rainbow Six Siege-like)",min = 0,max = 500,decimals = 0}, "optimization" )
hg.AddOptionPanel( "hg_maxsmoketrails", "slider", {desc = "Max amount of smoke trail effects (lags after 10)",min = 0,max = 30,decimals = 0}, "optimization" )
hg.AddOptionPanel( "hg_optimise_scopes", "slider", {desc = "Enable this if scoping makes your fps cry (1 - lowers quality of props around you, 2 - \"disables\" main render)",min = 0,max = 2,decimals = 0}, "optimization" )

local red = Color(75,25,25)
local redselected = Color(150,0,0)

local blurMat = Material("pp/blurscreen")
local Dynamic = 0
BlurBackground = BlurBackground or hg.DrawBlur

local function CreateOptionsMenu()
    local sizeX,sizeY = ScrW() / 3.2 ,ScrH() / 2.2
	local posX,posY = ScrW() / 2 - sizeX / 2,ScrH() / 2 - sizeY / 2

    local MainFrame = vgui.Create("ZFrame") -- The name of the panel we don't have to parent it.
    MainFrame:SetPos( posX, posY ) -- Set the position to 100x by 100y. 
    MainFrame:SetSize( sizeX, sizeY ) -- Set the size to 300x by 200y.
    MainFrame:SetTitle( "ZCity options" ) -- Set the title in the top left to "Derma Frame".
    MainFrame:MakePopup() -- Makes your mouse be able to move around.
    //function MainFrame:Paint( w, h )
    //    draw.RoundedBox( 0, 2.5, 2.5, w-5, h-5, Color( 0, 0, 0, 140) )
    //    BlurBackground(MainFrame)
    //    surface.SetDrawColor( 255, 0, 0, 128)
    //    surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
    //end

    local DScrollPanel = vgui.Create("DScrollPanel", MainFrame)
	DScrollPanel:SetPos(10, 50)
	DScrollPanel:SetSize(sizeX - 20, sizeY - 60)
	--function DScrollPanel:Paint( w, h )
	--	BlurBackground(self)
--
	--	surface.SetDrawColor( 255, 0, 0, 128)
    --    surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
	--end

    local DLabel = vgui.Create( "DLabel", DScrollPanel )
    DLabel:Dock(TOP)
    DLabel:DockMargin(20,5,5,2.5)
    DLabel:SetText( "Optimization" )

    for k,v in pairs(options["optimization"]) do
       
        modes[v[1]](v[2],DScrollPanel)
    end
    
    local DLabel = vgui.Create( "DLabel", DScrollPanel )
    DLabel:Dock(TOP)
    DLabel:DockMargin(20,15,5,2.5)
    DLabel:SetText( "Other" )

    for k,v in pairs(options["other"]) do
       
        modes[v[1]](v[2],DScrollPanel)
    end
end

if concommand.GetTable()["hg_options"] then return end
options_old = {}

concommand.Add("hg_options",function()
    CreateOptionsMenu()
end)