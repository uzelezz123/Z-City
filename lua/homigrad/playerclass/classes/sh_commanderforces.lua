local CLASS = player.RegClass("commanderforces")

function CLASS.Off(self)
    if CLIENT then return end
end

local models = {}
for i = 1, 9 do
    table.insert(models,"models/dejtriyev/enhancednatguard/male_0"..i..".mdl")
end


function CLASS.On(self)
    if CLIENT then return end
    ApplyAppearance(self,nil,nil,nil,true)
    local Appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()
    Appearance.AAttachments = ""
    Appearance.AClothes = ""
    self:SetPlayerColor(Color(100,37,54):ToVector())
    self:SetModel(models[math.random(#models)])
    self:SetBodyGroups("000000000")
    self:SetBodygroup(1,14)
    self:SetBodygroup(3,12)
    self:SetBodygroup(4,12)
    self:SetSubMaterial()
    self.CurAppearance = Appearance
end

-- local function IsLookingAt(ply, targetVec)
--     if not IsValid(ply) or not ply:IsPlayer() then return false end
--     local diff = targetVec - ply:GetShootPos()
--     return ply:GetAimVector():Dot(diff) / diff:Length() >= 0.8 
-- end

function CLASS.Guilt(self, Victim)
    if CLIENT then return end

    if Victim:GetPlayerClass() == self:GetPlayerClass() then
        --self:ChatPrint("You killed your teammate!")
        return 1
    end
end