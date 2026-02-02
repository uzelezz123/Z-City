local CLASS = player.RegClass("sc_guard")

function CLASS.Off(self)
    if CLIENT then return end
end

local subnames = {
	"Operator ",
	"Unit ",
	"Security Guard ",
	"Security Officer ",
	"Guard "
}

function CLASS.On(self)
    if CLIENT then return end
    self:SetPlayerColor(Color(0,0,190):ToVector())
    self:SetModel("models/pms/quantum_break/characters/operators/monarchoperator01playermodel.mdl")
    self:SetSubMaterial()
    
    ApplyAppearance(self,nil,nil,nil,true)
    local Appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()
    Appearance.AAttachments = ""
    Appearance.AColthes = ""
    self:SetNetVar("Accessories", "")
    self.CurAppearance = Appearance

    self:SetNWString("PlayerName",subnames[math.random(#subnames)] .. Appearance.AName)
end

function CLASS.Guilt(self, victim)
    if CLIENT then return end

    if victim:GetPlayerClass() == self:GetPlayerClass() then
        return 1
    end
end