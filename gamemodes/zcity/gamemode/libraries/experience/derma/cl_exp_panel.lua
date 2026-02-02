local PANEL = {}

local gradient_u = Material("vgui/gradient-u")

local function PaintPanel1(self,w,h)
end

local function RenderMedalBox(w,h)
    if w > h then
        surface.SetDrawColor( 0,0,0,155 )
        surface.DrawTexturedRect( (w/2 - h/2) + 5, 0+5, h, h )
        surface.SetDrawColor( 255,255,255,255 )
        surface.DrawTexturedRect( w/2 - h/2, 0, h, h )
    else
        surface.SetDrawColor( 0,0,0,155 )
        surface.DrawTexturedRect( 0+5, ( h/2 - w/2 )+5, w, w )
        surface.SetDrawColor( 255,255,255,255 )
        surface.DrawTexturedRect( 0, h/2 - w/2, w, w )
    end
end

function PANEL:Init()
    self.Player = nil

    self.PlyLabel = vgui.Create( "DLabel", self )
    self.PlyLabel:Dock( TOP )
    self.PlyLabel:SetContentAlignment(8)
    self.PlyLabel:SetSize(0,50)
    self.PlyLabel:SetFont( "ZB_InterfaceMedium" )
    self.PlyLabel:SetColor(color_white)

    self.MedalPanel = vgui.Create( "DPanel", self )
    self.MedalPanel:Dock( FILL )
    self.MedalPanel.Band = nil
    self.MedalPanel.Medal = nil

    function self:Paint( w, h )  
        PaintPanel1( self, w, h )
    end

    function self.MedalPanel:Paint( w, h )
        if not self.Band or not self.Medal then return end
        surface.SetMaterial( self.Band.icon )

        RenderMedalBox(w,h)

        surface.SetMaterial( self.Medal.icon )

        RenderMedalBox(w,h)
    end

    self.ExpLabel = vgui.Create( "DLabel", self )
    self.ExpLabel:Dock( BOTTOM )
    self.ExpLabel:SetContentAlignment(8)
    self.ExpLabel:SetSize(0,50)
    self.ExpLabel:SetFont( "ZB_InterfaceMedium" )
    self.ExpLabel:SetColor(color_white)

end

function PANEL:SetPlayer( ply )
    self.Player = ply
    local Band, Medal = ply:GetAwards()
    
    self.MedalPanel.Band = Band
    self.MedalPanel.Medal = Medal
    self.PlyLabel:SetText( ply:Nick().."'s medal" )
    self.ExpLabel:SetText( (ply.exp or 0).." XP ".. math.Round(ply.skill or 0,3) .. " Skill" )
    local oldexp = 0
    function self.ExpLabel:Think()
        if ply.exp != oldexp then
            local Band, Medal = ply:GetAwards()

            self.Band = Band
            self.Medal = Medal
        end
        self:SetText( (ply.exp or 0).." XP ".. math.Round(ply.skill or 0,3) .. " Skill" )
        oldexp = ply.exp
    end
end


vgui.Register( "ZB_ExpPanel", PANEL, "DPanel" )