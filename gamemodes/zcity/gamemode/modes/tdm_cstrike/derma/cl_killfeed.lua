local PANEL = {}
local sw, sh = ScrW(), ScrH()

local color_white = Color(255,255,255)
local ctcolor = Color(0,138,193)
local tcolor = Color(164,118,0)
local color_bg = Color(0,0,0,186)

killfeedtbl = killfeedtbl or {}

net.Receive("CS_Killfeed", function()
    local plyteam = net.ReadBool()
    local victimteam = net.ReadBool()
    local killer = net.ReadString()
    local victim = net.ReadString()

    vgui.Create("CS_Killfeed"):Setup(plyteam, victimteam, killer, victim)
end)

function PANEL:Setup(plyteam, victimteam, killer, victim)
    self.plyteam = plyteam
    self.victimteam = victimteam
    self.killer = killer
    self.victim = victim
end

function PANEL:UpdateStack()
    for i, panel in ipairs(killfeedtbl) do
        if !IsValid(panel) then return end
        panel:SetPos(sw * 0.78, sh * 0.02 + (i - 1) * (panel:GetTall() + 4))
    end
end

function PANEL:Init()
    self:SetSize(sw * 0.2, sh * 0.03)
    self:SetAlpha(255)

    table.insert(killfeedtbl, 1, self)
    self:UpdateStack()

    local margin = 10

    self.leftName = vgui.Create("DLabel", self)
    self.leftName:Dock(LEFT)
    self.leftName:DockMargin(margin, 0, 0, 0)
    self.leftName:SetWide(200)
    self.leftName:SetFont("ZB_InterfaceSmall")
    self.leftName:SetContentAlignment(4)

    self.centerSkull = vgui.Create("DLabel", self)
    self.centerSkull:Dock(FILL)
    self.centerSkull:SetFont("ZB_InterfaceSmall")
    self.centerSkull:SetContentAlignment(5)

    self.rightName = vgui.Create("DLabel", self)
    self.rightName:Dock(RIGHT)
    self.rightName:DockMargin(0, 0, margin, 0)
    self.rightName:SetWide(200)
    self.rightName:SetFont("ZB_InterfaceSmall")
    self.rightName:SetContentAlignment(6)

    timer.Simple(0, function()
        if !IsValid(self) then return end

        self.leftName:SetText(self.killer)
        self.leftName:SetTextColor(!self.plyteam and ctcolor or tcolor)

        self.centerSkull:SetText("☠")
        self.centerSkull:SetTextColor(color_white)

        self.rightName:SetText(self.victim)
        self.rightName:SetTextColor(!self.victimteam and ctcolor or tcolor)
    end)
	sound.PlayFile("homigrad/vgui/deathnotice.wav", "", function() end)

    

    timer.Simple(6, function()
        if IsValid(self) then
            self:Close()
        end
    end)
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(color_bg)
    surface.DrawRect(0, 0, w, h)
end

function PANEL:Close()
    self:AlphaTo(0, 0.3, 0, function()
        if !IsValid(self) then return end

        table.RemoveByValue(killfeedtbl, self)
        self:Remove()

        for _, panel in ipairs(killfeedtbl) do
            if IsValid(panel) then
                panel:UpdateStack()
            end
        end
    end)
end

vgui.Register("CS_Killfeed", PANEL, "EditablePanel")
