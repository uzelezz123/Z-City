local PANEL = {} -- ai slop 2026 download online pls

function PANEL:Init()
    self.value = 1
    self.min = 1
    self.max = 10
    self.dragging = false
    self.knobSize = 10
    self.decimals = 0
end

function PANEL:Paint(w, h)

    draw.RoundedBox(0, 0, h/2 - 3, w, 6, Color(40, 40, 40))
    
    local percent = (self.value - self.min) / (self.max - self.min)
    local fillWidth = percent * w
    draw.RoundedBox(0, 0, h/2 - 3, fillWidth, 6, Color(99, 99, 99))
    
    local knobX = percent * (w - self.knobSize)
    draw.RoundedBox(0, knobX, h/2 - self.knobSize/2, self.knobSize, self.knobSize, Color(126, 126, 126))
    
    surface.SetDrawColor(70, 70, 70)
    surface.DrawOutlinedRect(knobX, h/2 - self.knobSize/2, self.knobSize, self.knobSize)
end

function PANEL:OnMousePressed(keyCode)
    if keyCode == MOUSE_LEFT then
        self.dragging = true
        self:UpdateValue()
        self:MouseCapture(true) 
    end
end

function PANEL:OnMouseReleased(keyCode)
    if keyCode == MOUSE_LEFT then
        self.dragging = false
        self:MouseCapture(false) 
    end
end

function PANEL:Think()
    if self.dragging then
        self:UpdateValue()
    end
end

function PANEL:UpdateValue()
    local x, y = self:CursorPos()
    local w = self:GetWide()
    
    -- Ограничиваем x границами слайдера, даже если мышь вне его
    x = math.Clamp(x, 0, w)
    
    local percent = x / w
    local newValue = self.min + percent * (self.max - self.min)
    
    if self.decimals == 0 then
        newValue = math.Round(newValue)
    else
        newValue = math.Round(newValue, self.decimals)
    end
    
    newValue = math.Clamp(newValue, self.min, self.max)
    
    if self.value ~= newValue then
        self.value = newValue
        self:OnValueChanged(newValue)
    end
end

function PANEL:OnValueChanged(val)
end

function PANEL:SetValue(val)
    self.value = math.Clamp(val, self.min, self.max)
    self:OnValueChanged(self.value) 
end

function PANEL:GetValue()
    return self.value
end

function PANEL:SetMin(min)
    self.min = min
    self.value = math.Clamp(self.value, self.min, self.max)
end

function PANEL:SetMax(max)
    self.max = max
    self.value = math.Clamp(self.value, self.min, self.max)
end

function PANEL:SetDecimals(decimals)
    self.decimals = decimals
end

vgui.Register("CustomSlider", PANEL, "DPanel")