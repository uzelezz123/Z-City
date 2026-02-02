--
hg.PointShop = hg.PointShop or {}

local function AltDonate()
    Derma_Query(
        "We are sorry about that, but for now donation only through sadsalat",
        "Sorry...",
        "Discord",
        function() gui.OpenURL("https://discord.gg/475EmEdTgH") end,
        "Close"
    )
end

local blur = Material("pp/blurscreen")
local hg_potatopc
function hg.DrawBlur(panel, amount, passes, alpha)
	if is3d2d then return end
	amount = amount or 5
	hg_potatopc = hg_potatopc or hg.ConVars.potatopc

	if(hg_potatopc:GetBool())then
		surface.SetDrawColor(0, 0, 0, alpha or (amount * 20))
		surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
	else
		surface.SetMaterial(blur)
		surface.SetDrawColor(0, 0, 0, alpha or 125)
		surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())

		local x, y = panel:LocalToScreen(0, 0)

		for i = -(passes or 0.2), 1, 0.2 do
			blur:SetFloat("$blur", i * amount)
			blur:Recompute()
			
			render.UpdateScreenEffectTexture()
			surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
		end
	end
end

local PLUGIN = hg.PointShop

local PANEL = {}

local color_blacky = Color(15,15,15,254)
local color_reddy = Color(155,0,0,100)
local gradientUp = surface.GetTextureID("vgui/gradient-d")
local gradient_r = surface.GetTextureID("vgui/gradient-r")

local function createButton(k,ent,size,Pan,mainpan)
    local but = vgui.Create( "DModelPanel", Pan )
    --but:SetText( k )
    but:SetSize( size, size * 0.8 )
    but:SetModel( ent.MDL )
    --PrintTable(ent)
    but:SetFOV(ent.FOV or 15)
    but:SetLookAt( ent.VPos or Vector(0,0,0) )
    timer.Simple(0.1,function()
        but.Entity:SetSkin((isfunction(ent.SKIN) and ent.SKIN()) or (ent.SKIN or 0))
        but.Entity:SetBodyGroups(ent.BODYGROUP)
        if ent.DATA then
            for k, v in pairs( ent.DATA ) do
                but.Entity:SetSubMaterial( k, v )
            end
        end
    end)
        but.ViewPan = vgui.Create( "DButton", but )
        local VPan = but.ViewPan
        VPan:Dock(LEFT)
        VPan:SetSize( size/2, size*0.15 )
        VPan:DockMargin(0,size*0.65,0,0)
        VPan:SetText( "View" )
        VPan:SetFont( "HomigradFontMedium" )
        function VPan:DoClick()
            mainpan.RPanel:SetModel( ent.MDL )
            mainpan.RPanel.Entity:SetSkin((isfunction(ent.SKIN) and ent.SKIN()) or (ent.SKIN or 0))
            mainpan.RPanel.Entity:SetBodyGroups(ent.BODYGROUP)
            mainpan.RPanel.Name = ent.NAME
            mainpan.RPanel:SetLookAt( ent.VPos or Vector(0,0,0) )
            mainpan.RPanel:SetFOV(ent.FOV or 15)
            if ent.DATA then
                for k, v in pairs( ent.DATA ) do
                    mainpan.RPanel.Entity:SetSubMaterial( k, v )
                end
            end
        end

        function VPan:Paint(w,h)
            surface.SetDrawColor( ColorAlpha(color_blacky,255) )
            surface.DrawRect( 0,0,w,h )
            surface.SetDrawColor( ColorAlpha(color_reddy,225) )
            surface.DrawOutlinedRect(0,0,w,h,1)
        end

        but.BuyPan = vgui.Create( "DButton", but )
        local BPan = but.BuyPan
        BPan:Dock(FILL)
        BPan:SetSize( size/2, size*0.15 )
        BPan:DockMargin(0,size*0.65,0,0)
        BPan:SetText( LocalPlayer():PS_HasItem(ent.ID) and "SOLD" or ent.ISDONATE and "DONATE" or "Buy: "..ent.PRICE.." ZP" )
        BPan:SetFont( "HomigradFontMedium" )
        function BPan:DoClick()
            if ent.ISDONATE then
                AltDonate()
                mainpan:Close()
            return end
            if self.InWait then return end
            if LocalPlayer():PS_HasItem(ent.ID) then 
                self:SetText( LocalPlayer():PS_HasItem(ent.ID) and "SOLD" or "Buy: "..(ent.ISDONATE and "DONATE" or ent.PRICE.." ZP")  ) 
            return end
            self:SetText( "Wait..." )
            self.InWait = true
            PLUGIN:SendNET("BuyItem",{ent.ID},function(data)
                self:SetText( LocalPlayer():PS_HasItem(ent.ID) and "SOLD" or "Buy: "..(ent.ISDONATE and "DONATE" or ent.PRICE.." ZP")  )
                mainpan:Update(data)
                self.InWait = false
            end)
        end
        function BPan:Paint(w,h)
            surface.SetDrawColor( ColorAlpha(color_blacky,255) )
            surface.DrawRect( 0,0,w,h )
            surface.SetDrawColor( ColorAlpha(color_reddy,225) )
            surface.DrawOutlinedRect(0,0,w,h,1)
        end

    function but:Paint(w,h)
        surface.SetDrawColor( color_reddy )
        surface.SetTexture( gradientUp )
        surface.DrawTexturedRect(0,0,w,h)

        surface.SetDrawColor( color_reddy )
        surface.DrawOutlinedRect(0,0,w,h,1)
       
        if ( !IsValid( self.Entity ) ) then return end
        local x, y = self:LocalToScreen( 0, 0 )
        self:LayoutEntity( self.Entity )
        local ang = self.aLookAngle
        if ( !ang ) then
            ang = ( self.vLookatPos - self.vCamPos ):Angle()
        end
        cam.Start3D( self.vCamPos, ang, self.fFOV, x, y, w, h, 5, self.FarZ )
        render.SuppressEngineLighting( true )
        render.SetLightingOrigin( self.Entity:GetPos() )
        render.ResetModelLighting( self.colAmbientLight.r / 255, self.colAmbientLight.g / 255, self.colAmbientLight.b / 255 )
        render.SetColorModulation( self.colColor.r / 255, self.colColor.g / 255, self.colColor.b / 255 )
        render.SetBlend( ( self:GetAlpha() / 255 ) * ( self.colColor.a / 255 ) ) -- * surface.GetAlphaMultiplier()
        for i = 0, 6 do
            local col = self.DirectionalLight[ i ]
            if ( col ) then
                render.SetModelLighting( i, col.r / 255, col.g / 255, col.b / 255 )
            end
        end
        self:DrawModel()
        render.SuppressEngineLighting( false )
        cam.End3D()
        self.LastPaint = RealTime()
    end

    return but
end

function PANEL:Init()
    self.Itensens = {}
    self:SetAlpha( 0 )
    self:SetSize( ScrW(), ScrH() )
    self:SetY( ScrH() )
    self:SetX( ScrW() / 2 - self:GetWide() / 2 )
    self:SetTitle( "" )
    self:SetDraggable( false )

    local mainpan = self

    -- UP Panel Start
    self.UpPanel = vgui.Create("DPanel",self)
    local UPan = self.UpPanel
    UPan:Dock(TOP)
    UPan:SetSize(self:GetWide(),ScreenScale(30))

        local lbl = vgui.Create( "DLabel", UPan )
        lbl:SetText( "Z-City Appearance Shop" )
        lbl:SetFont( "HomigradFontGigantoNormous" )
        lbl:SetContentAlignment(9)
        
        lbl:Dock( LEFT )
        lbl:DockMargin( UPan:GetWide()*0.04, 0, 0, 0 )
        lbl:SizeToContents()

        local lbl = vgui.Create( "DButton", UPan )
        lbl:SetText( "Buy points" )
        lbl:SetFont( "HomigradFontLarge" )
        lbl:SetContentAlignment(5)
        
        lbl:Dock( RIGHT )
        lbl:DockMargin( 0, 5, UPan:GetWide()*0.07, 25 )
        lbl:SizeToContents()
        lbl:SetWide(lbl:GetWide()*1.2)
        --lbl:SetMouseInputEnabled( true ) -- We must accept mouse input
        function lbl:DoClick() -- Defines what should happen when the label is clicked
            --print("I was clicked!")
            --self:Remove()
            AltDonate()
            --RunConsoleCommand("say","/donate")
            mainpan:Close()
        end

        function lbl:Paint(w,h)
            surface.SetDrawColor( color_reddy )
            surface.DrawRect(0,0,w,h)
            surface.DrawOutlinedRect(0,0,w,h,2)
        end

        --self.DmoneyTxt = vgui.Create( "DLabel", UPan )
        --local DmoneyTxt = self.DmoneyTxt
        --DmoneyTxt:SetContentAlignment(6)
        --DmoneyTxt:SetText( " | DZP" )
        --DmoneyTxt:SetFont( "HomigradFontLarge" )
        --
        --DmoneyTxt:DockMargin( 0, 0, 25, 0 )
        --DmoneyTxt:SizeToContents()
        --DmoneyTxt:Dock( TOP )

        self.moneyTxt = vgui.Create( "DLabel", UPan )
        local moneyTxt = self.moneyTxt
        moneyTxt:SetContentAlignment(6)
        moneyTxt:SetText( " | ZP" )
        moneyTxt:SetFont( "HomigradFontLarge" )
        
        moneyTxt:DockMargin( 0, 0, 25, 0 )
        moneyTxt:SizeToContents()
        moneyTxt:Dock( TOP )

        --local money = vgui.Create( "DLabel", UPan )
        --money:SetContentAlignment(6)
        --money:SetText( "1000000\n1000" )
        --money:SetFont( "HomigradFontLarge" )
        --
        --money:DockMargin( 0, 0, 0, 0 )
        --money:SizeToContents()
        --money:Dock( FILL )
--
    function UPan:Paint(w,h)
        --draw.RoundedBox(0,0,0,w,h,color_blacky)
    end
    -- UP Panel End


    self.RPanel = vgui.Create("DModelPanel", self )
    local RPan = self.RPanel
    RPan:Dock( LEFT )
    RPan:DockMargin( 5, 0, 0, 0 )
    RPan:SetSize( self:GetWide()/3.5, self:GetTall() )
    RPan:SetModel( "models/modified/hat07.mdl" )
    RPan:SetLookAt( Vector( 0, 0, 0 ) )
    RPan:SetFOV(15)
    function RPan:PaintOver(w,h)
        if self.Name then
            draw.DrawText(self.Name, "HomigradFontLarge", RPan:GetWide() / 2 + 2 ,self:GetTall() * 0.9 + 2, color_black,TEXT_ALIGN_CENTER)
            draw.DrawText(self.Name, "HomigradFontLarge", RPan:GetWide() / 2 ,self:GetTall() * 0.9, color_white,TEXT_ALIGN_CENTER)
        end
    end

    --function RPan.Entity:GetPlayerColor() return Vector (0, 0, 0) end

    -- Fill Panel Start
    self.Collona = vgui.Create( "DColumnSheet", self )
    local col = self.Collona
    col:SetSize( self:GetWide()/1.4, self:GetTall() )
    col:Dock( FILL )
    col:DockMargin(0,45,0,0)
    col.Navigation:SetWidth(ScreenScale(75))
        self.ScrollPanel = vgui.Create("DScrollPanel",col)
        local SPan = self.ScrollPanel
        SPan:Dock( FILL )
        SPan:DockMargin( 10, 0, 0, 0 )
        SPan:SetSize( col:GetWide()/1.4, col:GetTall() )

            self.FillPanel = vgui.Create("DGrid",SPan)
            local Pan = self.FillPanel
            Pan:SetSize( SPan:GetWide(), SPan:GetTall() )
            Pan:Dock( FILL )

            local size = Pan:GetWide() / 4.2
            Pan:SetCols( Pan:GetWide() / size )
            Pan:SetColWide( size * 1.01 )
            Pan:SetRowHeight( size * 0.805 )

                for k, ent in pairs(PLUGIN.Items) do
                    --if ent.ISDONATE then continue end
                    local but = createButton(k,ent,size,Pan,mainpan)
                    Pan:AddItem(but)
                end

            Pan:SizeToContents()


            function Pan:Paint(w,h)
            end

        function SPan:Paint(w,h)
        end
    //local tbl = col:AddSheet( "DZP-Shop", SPan, "icon16/money.png" )
    //tbl["Button"]:SetFont("HomigradFontBig")
    //tbl["Button"]:SizeToContents()
    //tbl["Button"]:SetContentAlignment(6)
    //--tbl["Button"]:Set
//
    //    self.ZScrollPanel = vgui.Create("DScrollPanel",col)
    //    local SPan = self.ZScrollPanel
    //    SPan:Dock( FILL )
    //    SPan:DockMargin( 10, 0, 0, 0 )
    //    SPan:SetSize( col:GetWide()/1.4, col:GetTall() )
//
    //        self.FillPanel = vgui.Create("DGrid",SPan)
    //        local Pan = self.FillPanel
    //        Pan:SetSize( SPan:GetWide(), SPan:GetTall() )
    //        Pan:Dock( FILL )
//
    //        local size = Pan:GetWide() / 4.2
    //        Pan:SetCols( Pan:GetWide() / size )
    //        Pan:SetColWide( size * 1.01 )
    //        Pan:SetRowHeight( size * 0.805 )
//
    //            for k, ent in pairs(PLUGIN.Items) do
    //                if ent.ISDONATE then continue end
    //                local but = createButton(k,ent,size,Pan,mainpan)
    //                Pan:AddItem(but)
    //            end
//
    //        Pan:SizeToContents()
//
//
    //        function Pan:Paint(w,h)
    //        end
//
    //    function SPan:Paint(w,h)
    //    end
    local tbl = col:AddSheet( "ZP-Shop", SPan, "icon16/basket.png" )
    tbl["Button"]:SetFont("HomigradFontBig")
    tbl["Button"]:SizeToContents()
    tbl["Button"]:SetContentAlignment(6)
    -- Fill Panel End

    self:First( LocalPlayer() )
end

function PANEL:Update( data )
    self.Itensens = data or self.Itensens

    self.moneyTxt:SetText(self.Itensens.points.." | ZP")
    --self.DmoneyTxt:SetText(self.Itensens.donpoints.." | DZP")
    --PrintTable(data)
end

function PANEL:Paint(w,h)
    draw.RoundedBox(0,0,0,w,h,color_blacky)
    hg.DrawBlur(self, 10)
end

function PANEL:First( ply )

    self:MoveTo(self:GetX(), ScrH() / 2 - self:GetTall() / 2, 0.5, 0, 0.2, function() end)
    self:AlphaTo( 255, 0.2, 0.1, nil )
end

function PANEL:Close()
    self:MoveTo(self:GetX(), ScrH() / 2 + self:GetTall(), 5, 0, 0.3, function()
    end)
    self:AlphaTo( 0, 0.2, 0, function() self:Remove() end)
    self:SetKeyboardInputEnabled(false)
    self:SetMouseInputEnabled(false)
end

vgui.Register( "HG_PointShop", PANEL, "ZFrame")

concommand.Add("hg_pointshop",function()
    PLUGIN:SendNET( "SendPointShopVars", nil, function( data )
        if PLUGIN.MenuPanel then
            PLUGIN.MenuPanel:Remove()
            PLUGIN.MenuPanel = nil
        end
        PLUGIN.MenuPanel = vgui.Create("HG_PointShop")
        --PLUGIN.MenuPanel:Center()
        PLUGIN.MenuPanel:MakePopup()
        PLUGIN.MenuPanel:Update( data )
    end)
end)
