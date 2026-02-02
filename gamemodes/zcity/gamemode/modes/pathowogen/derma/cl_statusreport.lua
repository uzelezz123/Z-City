local PANEL = {}

function PANEL:Init()
    if IsValid(zb.StatusReport ) then
        zb.StatusReport :Remove()
    end

    zb.StatusReport = self

    self:SetSize(ScrW(), ScrH())

    self:RequestFocus()
    self:MakePopup()

    self.MapSize = ScreenScale(300)

    self:SetKeyboardInputEnabled(true)
    self:SetMouseInputEnabled(false)
end

local function NoDrawFunc() return true end

local function DrawMap(origin, scale, x, y, w, h)
    local hookId = "pluvworks"

    hook.Add( "PreDrawSkyBox", hookId, NoDrawFunc )
    hook.Add( "PrePlayerDraw", hookId, NoDrawFunc )
    hook.Add( "PreDrawViewModel", hookId, NoDrawFunc )

	local offset = 50000

    render.SetStencilEnable( false )
    render.SetLightingMode(0)
    render.OverrideAlphaWriteEnable(true)
    render.SetColorMaterial()

    render.PushFilterMin( 3 )
    render.PushFilterMag( 3 )

    render.RenderView( {
        origin = LocalPlayer():GetPos() + Vector( 0, 0, offset),
        angles = Angle( 90, 0, 0 ),
        x = x,
        y = y,
        w = w,
        h = h,
        znear = offset * 0.993,
        zfar = 3000 - -3000 + offset,
        drawhud = false,
        drawmonitors = false,
        drawviewmodel = false,
        dopostprocess = false,
        viewid = 2, -- VIEW_MONITOR

        ortho = {
            top = -5000 / scale,
            left = -5000 / scale,
            right = 5000 / scale,
            bottom = 5000 / scale
        }
    } )

	render.SetLightingMode( 0 )

    render.PopFilterMin()
    render.PopFilterMag()

	hook.Remove( "PreDrawSkyBox", hookId )
    hook.Remove( "PrePlayerDraw", hookId )
    hook.Remove( "PreDrawViewModel", hookId )
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(0, 0, 0)
    surface.DrawRect(0, 0, w, h)

    surface.SetDrawColor(color_white)
    surface.DrawOutlinedRect(w / 2 - self.MapSize / 2 - 8, h / 2 - self.MapSize / 2 - 8, self.MapSize + 16, self.MapSize + 16, 8)

    DrawMap(Vector(0, 0, 0), 1.2, w / 2 - self.MapSize / 2, h / 2 - self.MapSize / 2, self.MapSize, self.MapSize)
end

vgui.Register("ZB_StatusReport", PANEL, "EditablePanel")