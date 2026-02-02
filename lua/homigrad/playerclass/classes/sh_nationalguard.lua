local CLASS = player.RegClass("nationalguard")

function CLASS.Off(self)
    if CLIENT then return end
end

local models = {}
for i = 1, 9 do
    table.insert(models,"models/dejtriyev/enhancednatguard/male_0"..i..".mdl")
end

local ranks = {
    {name = "PVT", chance = 25},
    {name = "PV2", chance = 20},
    {name = "PFC", chance = 18},
    {name = "SPC", chance = 12},
    {name = "CPL", chance = 8},
    {name = "SGT", chance = 7},
    {name = "SSG", chance = 4},
    {name = "SFC", chance = 2.5},
    {name = "MSG", chance = 1.2},
    {name = "1SG", chance = 0.8},
    {name = "SGM", chance = 0.5},
    {name = "CSM", chance = 0.3},
    {name = "SMA", chance = 0.1},
    {name = "2LT", chance = 0.3},
    {name = "1LT", chance = 0.2},
    {name = "CPT", chance = 0.08},
    {name = "MAJ", chance = 0.02},
}

local clr = Color(5, 65, 0):ToVector()
function CLASS.On(self)
    if CLIENT then return end
    ApplyAppearance(self,nil,nil,nil,true)
    local Appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()
    Appearance.AAttachments = ""
    Appearance.AColthes = ""

    local randomValue = math.random() * 100
    local cumulativeChance = 0
    local rank = "PVT"

    for _, rankInfo in ipairs(ranks) do
        cumulativeChance = cumulativeChance + rankInfo.chance
        if randomValue <= cumulativeChance then
            rank = rankInfo.name
            break
        end
    end

    self:SetNWString("PlayerName", rank .. " " .. Appearance.AName)
    self:SetPlayerColor(clr)
    self:SetModel(models[math.random(#models)])
    self:SetBodygroup(0,14)
    self:SetSubMaterial()
    self.CurAppearance = Appearance
end

local function IsLookingAt(ply, targetVec)
    if not IsValid(ply) or not ply:IsPlayer() then return false end
    local diff = targetVec - ply:GetShootPos()
    return ply:GetAimVector():Dot(diff) / diff:Length() >= 0.8 
end

function CLASS.Guilt(self, Victim)
    if CLIENT then return end

    if Victim:GetPlayerClass() == self:GetPlayerClass() then
        --self:ChatPrint("You killed your teammate!")
        return 1
    end

    if CurrentRound().name == "hmcd" then
        return zb.ForcesAttackedInnocent(self, Victim)
    end

    return 1
end