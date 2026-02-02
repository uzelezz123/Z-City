local PANEL = {}
local red = Color(239, 47, 47)

function PANEL:Init()
    self.text = "Разное"
end

function PANEL:SetWeapon(weapon)
    if istable(weapon) then
        local slots = {}

        self.scroll = self:Add("DScrollPanel")
        self.scroll:Dock(FILL)
        self.scroll:DockMargin(0, 0, 0, ScreenScale(10))

        self.scroll:GetVBar():SetSize(0, 0)
        
        for k, v in pairs(weapon) do
            local weapon2 = weapons.Get(v) or scripted_ents.Get(v) or {}

            slots[k] = self.scroll:Add("ZB_ScrappersButton")
            slots[k]:Dock(TOP)
            slots[k]:DockMargin(ScreenScale(1), ScreenScale(1), ScreenScale(1), 0)
            slots[k]:SetTall(ScreenScale(11))
            slots[k]:SetFont("ZB_ScrappersMedium")
            slots[k]:SetText(weapon2.PrintName or "fail")

            slots[k].DoClick = function(this)
                self:DoClick(k)
            end
        end

        self.Paint = function(this, w, h)
            surface.SetDrawColor(red)
            surface.DrawOutlinedRect(0, 0, w, h, 2)

            surface.DrawRect(0, h - ScreenScale(10), w, ScreenScale(10))
            draw.SimpleText(self.text, "ZB_ScrappersMedium", ScreenScale(4), h - ScreenScale(11))
        end
    elseif weapon then
        local weapon2 = weapons.Get(weapon)

        self.model = self:Add("DModelPanel")
        self.model:Dock(FILL)
        self.model:SetModel(weapon2.WorldModel)
        self.model:SetCamPos(Vector(40, 50, 55))
        self.model:SetLookAng(Vector(-48,-48,-48):Angle())
        self.model:SetFOV(20)
        self.model.LayoutEntity = function(this,ent) end
        self.model.DoClick = function(this)
            self:DoClick()
        end

        DEFINE_BASECLASS("DModelPanel")

        self.model.Paint = function(this, w, h)
            BaseClass.Paint(this, w, h)

            surface.SetDrawColor(red)
            surface.DrawOutlinedRect(0, 0, w, h, 2)

            if weapon2 then
                draw.SimpleText(weapon2.PrintName, "ZB_ScrappersMedium", ScreenScale(4), ScreenScale(4))
            end

            surface.DrawRect(0, h - ScreenScale(10), w, ScreenScale(10))
            draw.SimpleText(self.text, "ZB_ScrappersMedium", ScreenScale(4), h - ScreenScale(11))
        end
    else
        self.Paint = function(this, w, h)
            surface.SetDrawColor(red)
            surface.DrawOutlinedRect(0, 0, w, h, 2)

            surface.DrawRect(0, h - ScreenScale(10), w, ScreenScale(10))
            draw.SimpleText(self.text, "ZB_ScrappersMedium", ScreenScale(4), h - ScreenScale(11))
        end
    end
end

vgui.Register("ZB_MainSlot", PANEL, "EditablePanel")