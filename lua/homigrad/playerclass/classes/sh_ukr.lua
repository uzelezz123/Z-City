local CLASS = player.RegClass("ukr")

function CLASS.Off(self)
    if CLIENT then return end
    self:SetNetVar("HideArmorRender", false)
end

local ukrnames = {
    "Яків", "Федiр", "Добромисл", "Тімох", "Еміль",
    "Цвітан", "Світослав", "Явір", "Євлампій", "Георгій",
    "Світовид", "Світлогор", "Турбрід", "Юліан", "Юрій"
}

local models = {
    "models/dejtriyev/mm14/ukrainian_soldier.mdl",
}

function CLASS.On(self)
    if CLIENT then return end
    ApplyAppearance(self,nil,nil,nil,true)
    local Appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()
    Appearance.AAttachments = ""
    Appearance.AColthes = ""
    self:SetNWString("PlayerName","")
    self:SetPlayerColor(Color(90,75,0):ToVector())
    self:SetModel(table.Random(models))

    self:SetNetVar("Accessories", Appearance.AAttachments or "none")

    self:SetSubMaterial()
    self:SetNWString("PlayerName",ukrnames[ math.random(#ukrnames) ])
    self.CurAppearance = Appearance
    
    self:SetNetVar("HideArmorRender", true)
end