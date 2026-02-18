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

    self:SetPlayerColor(Color(205,0,0):ToVector())

    self:SetNWString("PlayerName","Seeker "..Appearance.AName)
end

CLASS.CanUseDefaultPhrase = true
CLASS.CanEmitRNDSound = false
CLASS.CanUseGestures = true

function CLASS.Guilt(self, Victim)
    if CLIENT then return end
    
    if Victim:GetPlayerClass() == self:GetPlayerClass() then
        return 1
    end
end