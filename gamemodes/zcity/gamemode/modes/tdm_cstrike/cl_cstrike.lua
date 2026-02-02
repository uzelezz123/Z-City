
function MODE:AddHudPaint()
    local w, h = ScreenScale(60), ScreenScale(10)
    
    if zb.rtype == "bomb" then
        local pts = zb.ClPoints["BOMB_ZONE_A"]
        local pts2 = zb.ClPoints["BOMB_ZONE_B"]
        
        if pts and #pts >= 2 then
            local center = pts[2].pos - pts[1].pos
            center = center / 2
            local pos = pts[1].pos + center

            local tscr = pos:ToScreen()

            local clr = zb.Points["BOMB_ZONE_A"].Color
            
            if BombInSite(LocalPlayer():EyePos(),1) then
                surface.SetDrawColor(122,0,0,255)
                surface.DrawRect(tscr.x - w / 2, 0, w, h * 2)
        
                local txt = "You're on site!"
                surface.SetFont( "ZB_InterfaceMedium" )
                surface.SetTextColor(color_white:Unpack())
                local lx, ly = surface.GetTextSize(txt)
                surface.SetTextPos(tscr.x - lx / 2, h / 2 + ly / 2)
                surface.DrawText(txt)
            end

            surface.SetDrawColor(clr:Unpack())
            surface.DrawRect(tscr.x - w / 2, 0, w, h)
        
            local txt = "SITE A: "..math.Round(pos:Distance(LocalPlayer():EyePos()) * 0.0254,0).." meters"
            surface.SetFont( "ZB_InterfaceMedium" )
            surface.SetTextColor(color_white:Unpack())
            local lx, ly = surface.GetTextSize(txt)
            surface.SetTextPos(tscr.x - lx / 2, h / 2 - ly / 2)
            surface.DrawText(txt)
        end

        if pts2 and #pts2 >= 2 then
            local center = pts2[2].pos - pts2[1].pos
            center = center / 2
            local pos = pts2[1].pos + center

            local tscr = pos:ToScreen()

            local clr = zb.Points["BOMB_ZONE_B"].Color
            
            if BombInSite(LocalPlayer():EyePos(),2) then
                surface.SetDrawColor(122,0,0,255)
                surface.DrawRect(tscr.x - w / 2, 0, w, h * 2)
        
                local txt = "You're on site!"
                surface.SetFont( "ZB_InterfaceMedium" )
                surface.SetTextColor(color_white:Unpack())
                local lx, ly = surface.GetTextSize(txt)
                surface.SetTextPos(tscr.x - lx / 2, h / 2 + ly / 2)
                surface.DrawText(txt)
            end

            surface.SetDrawColor(clr:Unpack())
            surface.DrawRect(tscr.x - w / 2, 0, w, h)
        
            local txt = "SITE B: "..math.Round(pos:Distance(LocalPlayer():EyePos()) * 0.0254,0).." meters"
            surface.SetFont( "ZB_InterfaceMedium" )
            surface.SetTextColor(color_white:Unpack())
            local lx, ly = surface.GetTextSize(txt)
            surface.SetTextPos(tscr.x - lx / 2, h / 2 - ly / 2)
            surface.DrawText(txt)
        end
    elseif zb.rtype == "hostage" then
        local pts = zb.ClPoints["HOSTAGE_DELIVERY_ZONE"]
        if not pts or #pts < 2 then return end
        local center = pts[2].pos + pts[1].pos + (#pts >= 4 and (pts[3].pos + pts[4].pos) or vector_origin)
        local pos = center / #pts

        local tscr = pos:ToScreen()

        local clr = zb.Points["HOSTAGE_DELIVERY_ZONE"].Color

        surface.SetDrawColor(clr:Unpack())
        surface.DrawRect(tscr.x - w * 1.15, 0, w * 1.15 * 2, h)
    
        local txt = "HOSTAGE DELIVERY ZONE: "..math.Round(pos:Distance(LocalPlayer():EyePos()) * 0.0254,0).." meters"
        surface.SetFont( "ZB_InterfaceMedium" )
        surface.SetTextColor(color_white:Unpack())
        local lx, ly = surface.GetTextSize(txt)
        surface.SetTextPos(tscr.x - lx / 2, h / 2 - ly / 2)
        surface.DrawText(txt)
    end
end