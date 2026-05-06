local greendarker = Color(3, 32, 3)
local green = Color(10, 120, 10)
local notif = 0

function MODE:AddHudPaint()
    local w, h = ScreenScale(60), ScreenScale(10)
    local ply = LocalPlayer()
    local money = ply:GetNWInt("TDM_Money", 0)
    self.DisplayMoney = self.DisplayMoney or 0
    self.LastMoney = self.LastMoney or 0
    self.MoneyAnims = self.MoneyAnims or {}
    
    if !ply:Alive() then return end
    if zb.rtype == "bomb" then

        local pts = zb.ClPoints["BOMB_ZONE_A"]
        local pts2 = zb.ClPoints["BOMB_ZONE_B"]
        if #pts < 2 then
            if notif == 0 then
                ply:PrintMessage(HUD_PRINTTALK,
                "Gamemode is bomb and there's less than 2 points for bomb sites. Ask server admin to make exactly 2 points of each bomb sites using toolgun.")
                notif = 1
            end
        elseif pts and #pts >= 2 then
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

    self.DisplayMoney = Lerp(FrameTime() * 6, self.DisplayMoney, money)

    if money > self.LastMoney then
        table.insert(self.MoneyAnims, {
            amount = money - self.LastMoney,
            startTime = CurTime(),
            life = 1
        })
    end

    self.LastMoney = money

    draw.SimpleTextOutlined("$" .. math.floor(self.DisplayMoney), "ZB_InterfaceMedium",w * 0.1, ScrH() * 0.5,green,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,ScreenScale(0.5),greendarker)

    for k, v in ipairs(self.MoneyAnims) do
        local progress = (CurTime() - v.startTime) / 1

        if progress >= 1 then
            table.remove(self.MoneyAnims, k)
            continue
        end

        local yOffset = Lerp(progress, 0, -40)
        local alpha = 255 * (1 - progress)

        draw.SimpleText("+" .. v.amount,"ZB_InterfaceMedium",w * 0.1,ScrH() * 0.5 + yOffset,Color(0, 200, 0, alpha),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
    end

end