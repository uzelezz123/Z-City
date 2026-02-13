zb = zb or {}
zb.Points = zb.Points or {}

zb.Points.Example = zb.Points.Example or {}
zb.Points.Example.Color = Color(255,255,0)
zb.Points.Example.Name = "example point"

zb.Points.Spawnpoint = zb.Points.Spawnpoint or {}
zb.Points.Spawnpoint.Color = Color(250,250,250)
zb.Points.Spawnpoint.Name = "Spawnpoint"

zb.Points.RandomSpawns = zb.Points.RandomSpawns or {}
zb.Points.RandomSpawns.Color = Color(122,122,0)
zb.Points.RandomSpawns.Name = "RandomSpawns"

if SERVER then
    util.AddNetworkString("zb_getallpoints")
    util.AddNetworkString("zb_getspecificpoints")
end

if CLIENT then
    function zb.GetAllPoints()
        if not LocalPlayer():IsAdmin() then return false end
        net.Start("zb_getallpoints")
        net.SendToServer()
    end

    zb.ClPoints = zb.ClPoints or {}

    net.Receive("zb_getallpoints",function()
        zb.ClPoints = net.ReadTable()
    end)

    net.Receive("zb_getspecificpoints", function()
        local pointGroup = net.ReadString()
        zb.ClPoints[pointGroup] = net.ReadTable()
    end)

    local showpointnames = CreateConVar( "zb_drawpoints_names", "1", FCVAR_PROTECTED, "Draw point names if zb_drawpoints enabled", 0, 1 )

    function zb.DrawPoints()
        if not LocalPlayer():IsAdmin() then return end
        local radius = 4
        local wideSteps = 10
        local tallSteps = 10
        
        local angeye = LocalPlayer():EyeAngles()
        
        angeye:RotateAroundAxis( angeye:Forward(), 90 )
        angeye:RotateAroundAxis( angeye:Right(), 90 )
    
        for id, points in ipairs(zb.ClPoints) do
            for id2, point in ipairs(points) do
                local pos = point.pos
                local ang = point.ang
    
                render.SetColorMaterial() -- white material for easy coloring
    
                local color = zb.Points[id].Color
                local name = zb.Points[id].Name
                local text = name .. " #" .. id2
                local txtsize = surface.GetTextSize(text)
                
                cam.IgnoreZ( true ) -- makes next draw calls ignore depth and draw on top
                    render.DrawWireframeBox( pos, ang, Vector(15,1,1), -Vector(0,1,1), color ) -- draws the box 
                    render.DrawWireframeSphere( pos, radius, wideSteps, tallSteps, color )
    
                    if showpointnames:GetBool() then
                        cam.Start3D2D( pos, angeye, 0.2 )
                            surface.SetDrawColor(0,0,0,235)
                            surface.DrawRect(-txtsize/2 -20, -7.5, 15, 15)
    
                            surface.SetDrawColor(color.r,color.g,color.b,255)
                            surface.DrawRect(-txtsize/2 -19, -6, 13, 13)
    
                            draw.SimpleTextOutlined( text, "ChatFont", 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black )
                        cam.End3D2D()
                    end
    
                cam.IgnoreZ( false ) -- disables previous call
            end
        end
    end

    local drawpoints = CreateConVar( "zb_drawpoints", "0", FCVAR_PROTECTED, "Draw map points if player is admin", 0, 1 )
    cvars.AddChangeCallback("zb_drawpoints", function(convar_name, value_old, value_new)
        if tobool(value_new) then 
            hook.Add("PostDrawOpaqueRenderables", "RenderPoints", zb.DrawPoints)
            zb.GetAllPoints()
        else
            hook.Remove("PostDrawOpaqueRenderables", "RenderPoints" )
        end
    end, "huy")

    concommand.Add( "zb_pointsupdate", function( ply, cmd, args )
        if not ply:IsAdmin() then return end
        zb.GetAllPoints()
    end )
    
end

--PrintTable(zb.GetAllPoints())