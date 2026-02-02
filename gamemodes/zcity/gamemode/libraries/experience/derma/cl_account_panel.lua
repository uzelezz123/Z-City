--
local PANEL = {}

local Statics = {
    {"Kills", "Kills"},
    {"Suicides", "Suicides"},
    {"Deaths", "Deaths"},
    --{"Victories being a traitor", "zb_hmcd_t_wins"},
   -- {"Neutralizings a traitor", "zb_hmcd_ino_t_kills"}
}

function PANEL:Init()
    self:SetSize(ScrW()/2,ScrH()*0.6)
    self:Center()
    
    self.MainInfo = vgui.Create("ZB_ExpPanel",self)
    local MInfo = self.MainInfo
    MInfo:Dock(LEFT)
    MInfo:SetSize(self:GetWide()*0.35,self:GetTall())

    self.SecInfo = vgui.Create( "DPropertySheet", self )
    local SInfo = self.SecInfo
    SInfo:Dock( FILL )

    local panel1 = vgui.Create( "DScrollPanel", SInfo )
    self.StatPanel = panel1
    function panel1:Paint() end

    SInfo:AddSheet( "Statistics", panel1, "icon16/chart_bar.png" )

    --local panel1 = vgui.Create( "DPanel", SInfo )
    --function panel1:Paint() end
    --SInfo:AddSheet( "Achievements", panel1, "icon16/award_star_silver_3.png" )
end

function PANEL:SetPlayer(ply)
    self.MainInfo:SetPlayer(ply)
    self.MainInfo.PlyLabel:SetText( ply:Nick() )

    for i,stats in pairs(Statics) do
        self.StatPanel[i] = vgui.Create("DLabel",self.StatPanel)
        local Stat = self.StatPanel[i]
        Stat:SetText( stats[1]..": "..ply:GetStatVal(stats[2], 0) )
        Stat:Dock(TOP)
        Stat:DockMargin(5,5,5,5)
        Stat:SetSize(0,self:GetTall()*0.05)
        Stat:SetFont("ZB_InterfaceMedium")
    end
end

function PANEL:Udpate(ply)
    for i,stats in pairs(Statics) do
        self.StatPanel[i] = self.StatPanel[i] or vgui.Create("DLabel",self.StatPanel)
        local Stat = self.StatPanel[i]
        Stat:SetText( stats[1]..": "..(ply.SvDB and ply.SvDB[ stats[2] ] or 0) )
        Stat:Dock(TOP)
        Stat:DockMargin(5,5,5,5)
        Stat:SetSize(0,self:GetTall()*0.05)
        Stat:SetFont("ZB_InterfaceMedium")
    end
end

local gradient_d = Material("vgui/gradient-d")

local blurMat = Material("pp/blurscreen")
local Dynamic = 0

BlurBackground = hg.DrawBlur

local function PaintFrame(self,w,h)
	BlurBackground(self)
    surface.SetDrawColor(155, 0, 0, 155)
    surface.SetMaterial(gradient_d)
    surface.DrawTexturedRect( 0, 0, w, h )

	surface.SetDrawColor( 255, 0, 0, 128)
    surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
end

function PANEL:Paint( w, h )  
    PaintFrame( self, w, h )
end

vgui.Register( "ZB_AccountFrame", PANEL, "ZFrame" )


--vgui.Create("ZB_AccountFrame"):MakePopup()