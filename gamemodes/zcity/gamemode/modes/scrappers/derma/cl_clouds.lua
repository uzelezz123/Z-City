local PANEL = {}

local blur = Material("pp/blurscreen")
local scale = 0.02
local scalew = sw / 40
local scaleh = sh / 40

function PANEL:Init()
    self.grid = {}
end

function PANEL:Paint()
    for i = 0, sw / 20 do
        self.grid[i] = self.grid[i] or {}

        for i2 = 0, sh / 20 do
            local time = SysTime() * 0.1

            self.grid[i][i2] = self.grid[i][i2] or 0

            self.grid[i][i2] = Lerp(FrameTime() * 5, self.grid[i][i2], math.Clamp(simplex.Noise3D(i * scale + time, i2 * scale - time * 0.7, time * 0.5), 0, 1))

            if self.grid[i][i2] > 0 then
                surface.SetDrawColor(math.Clamp(self.grid[i][i2] * 184, 15, 255), math.Clamp(self.grid[i][i2] * 184, 15, 255), math.Clamp(self.grid[i][i2] * 184, 15, 255) , 255)
                surface.DrawRect(i * scalew, i2 * scaleh, scalew, scaleh)
            end
        end
    end
end

vgui.Register("ZB_ScrappersClouds", PANEL, "EditablePanel")