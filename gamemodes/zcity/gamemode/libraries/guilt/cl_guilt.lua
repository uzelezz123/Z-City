--[[    TO-DO
    -- Добавить менюшку с прощением! |
    -- Добавить нетворкинг |
    -- Ну и все | 
--]]

hook.Add("OnNetVarSet", "Guilt",function(index, key, var)
    if key == "Karma" then
        Entity(index).Karma = var
    end
end)

hook.Add("Player Spawn", "GuiltKnown",function(ply)
    --if (ply == LocalPlayer()) and ply.Karma then
    --    ply:ChatPrint("Your current karma is "..tostring(math.Round(ply.Karma)).."")
    --end
end)

concommand.Add("hg_getkarma",function(ply)
    if not ply:IsAdmin() then return end

    net.Start("get_karma")
    net.SendToServer()
end)

net.Receive("get_karma",function(len)
    local tbl = net.ReadTable()
    local printTbl = "\nPlayers karma: \n"

    for id,karma in pairs(tbl) do
        printTbl = printTbl.."\t"..(Player(id):Name().."'s karma is "..math.Round(karma,2)).."\n"
    end

    LocalPlayer():PrintMessage(HUD_PRINTCONSOLE,printTbl)
end)

concommand.Add("hg_guilt_menu",function(ply, cmd, args)
    net.Start("open_guilt_menu")
    net.SendToServer()
end)

local OpenMenu

net.Receive("open_guilt_menu", function()
    local tbl = net.ReadTable()
    
    OpenMenu(tbl)
end)

local colGray = Color(122,122,122,255)
local BlurBackground = hg.BlurBackground

local function harmdone(harm)
    if harm >= 9 then
        return "killed you."
    elseif harm >= 5 then
        return "basically killed you."
    elseif harm >= 2 then
        return "seriously injured you."
    elseif harm >= 1 then
        return "mildly injured you."
    else
        return "damaged you a bit."
    end
end

local showstuff = CurTime() + 5
hook.Add("Player_Death","karmacheck",function(ply)
    if ply != LocalPlayer() then return end
    
    showstuff = CurTime() + 5
end)

local pressed
hook.Add("HUDPaint","shownotification",function()
    if LocalPlayer():Alive() then return end

    if showstuff > CurTime() then
        local w, h = ScrW(), ScrH()
        local x, y = w / 2, h / 25 * 24
        local txt = "Press F to open forgiveness menu."
        surface.SetFont( "HomigradFontBig" )
        surface.SetTextColor(255,255,255,255)
        local w, h = surface.GetTextSize(txt)
        surface.SetTextPos(x - w / 2, y - h / 2)
        surface.DrawText(txt)
    end

    if input.IsKeyDown(KEY_F) and not gui.IsGameUIVisible() and not IsValid(vgui.GetKeyboardFocus()) then
        if not pressed then
            showstuff = 0
            RunConsoleCommand("hg_guilt_menu")
            pressed = true
        end
    else
        pressed = nil
    end
end)

OpenMenu = function(tbl)
    if IsValid(guiltMenu) then
		guiltMenu:Remove()
		guiltMenu = nil
	end
    
	local sizeX,sizeY = ScrW() / 2 ,ScrH() / 3
	local posX,posY = ScrW() / 2 - sizeX / 2,ScrH() / 2 - sizeY / 2

	guiltMenu = vgui.Create("DScrollPanel")
	guiltMenu:SetPos(posX, posY)
	guiltMenu:SetSize(sizeX, sizeY)
    guiltMenu:MakePopup()
    guiltMenu:SetKeyboardInputEnabled(false)

    local button = vgui.Create("DButton", guiltMenu)
    button:SetPos(sizeX - ScreenScale(25),ScreenScale(5))
    button:SetSize(ScreenScale(20),ScreenScale(10))
    button:SetText("")

    function button:Paint(w,h)
        BlurBackground(self)

        surface.SetDrawColor( 255, 0, 0, 128)
        surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )

        local x, y = w / 2, h / 2
        local txt = "Exit"
        surface.SetFont("HomigradFont")
        surface.SetTextColor(255,255,255,255)
        local w, h = surface.GetTextSize(txt)
        surface.SetTextPos(x - w / 2, y - h / 2)
        surface.DrawText(txt)
    end

    function button:DoClick()
        if IsValid(guiltMenu) then
            guiltMenu:Remove()
        end
    end

	function guiltMenu:Paint( w, h )
		BlurBackground(self)

		surface.SetDrawColor( 255, 0, 0, 128)
        surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
	end

    local first = true
    for ply, harm in pairs(tbl) do
        if not IsValid(ply) then continue end
        if harm <= 0.01 then continue end

        local but = vgui.Create("DButton", guiltMenu)
		but:SetSize(sizeX / 2,ScreenScaleH(22))
		but:Dock(TOP)
        local mg = ScreenScale(5)
		but:DockMargin(mg, first and ScreenScale(20) or mg / 2, mg, mg / 2)
        first = false
		but:SetText("")
        but.ply = ply
        but.name = ply:Name()
        but.harm = harm
        local txt = "Forgive "..but.name.."? You will forgive him "..math.Round(but.harm,1).." karma."
        local clr = 255
        but.Paint = function(self,w,h)
            BlurBackground(self)
            clr = LerpFT(0.1, clr, self:IsHovered() and 0 or 255)
            surface.SetDrawColor( 255, 0, 0, 128)
            surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )

            local x, y = 0, h / 2
            surface.SetFont("HomigradFont")
            surface.SetTextColor(clr,255,clr,255)
            local w, h = surface.GetTextSize(txt)
            surface.SetTextPos(x + ScreenScale(5), y - h / 2)
            surface.DrawText(txt)
		end

		function but:DoClick()
            net.Start("forgive_player")
            net.WriteEntity(ply)
            net.SendToServer()
            --self:Remove()
            tbl[ply] = nil
            OpenMenu(tbl)
        end

		guiltMenu:AddItem(but)
	end
end