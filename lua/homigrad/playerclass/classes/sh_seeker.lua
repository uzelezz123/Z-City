local CLASS = player.RegClass("seeker")

function CLASS.Off(self)
    if CLIENT then return end
end

function CLASS.On(self)
    if CLIENT then return end
    ApplyAppearance(self)
    local Appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()
    Appearance.AAttachments = ""
    Appearance.AColthes = ""
    self.CurAppearance = Appearance

    local inv = self:GetNetVar("Inventory", {})
    inv["Weapons"] = inv["Weapons"] or {}
    inv["Weapons"]["hg_sling"] = true
    self:SetNetVar("Inventory", inv)

    self:SetNWString("PlayerName","Seeker "..Appearance.AName)
end

function CLASS.Guilt(self, Victim)
    if CLIENT then return end

    if Victim:GetPlayerClass() == self:GetPlayerClass() then
        return 1
    end
end