local CLASS = player.RegClass("terrorist")

function CLASS.Off(self)
    if CLIENT then return end
end

local masks = {
    "arctic_balaclava",
    "phoenix_balaclava",
    "bandana"
}

function CLASS.On(self)
    if CLIENT then return end
    ApplyAppearance(self,nil,nil,nil,true)
    timer.Simple(.1,function()
        local Appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()

        Appearance.AAttachments = {
            masks[math.random(#masks)],
            "terrorist_band"
        }
        self:SetNetVar("Accessories", Appearance.AAttachments or "none")
        
        self.CurAppearance = Appearance
    end)
end

function CLASS.Guilt(self, victim)
    if CLIENT then return end

    if victim:GetPlayerClass() == self:GetPlayerClass() then
        return 1
    end
    
    if victim == zb.hostage then
        return 1
    end
end