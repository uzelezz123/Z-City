local CLASS = player.RegClass("police")

function CLASS.Off(self)
    if CLIENT then return end
end

local models = {
    -- Male
    ["male 01"] = "models/monolithservers/mpd/male_01.mdl",
    ["male 03"] = "models/monolithservers/mpd/male_03.mdl",
    ["male 04"] = "models/monolithservers/mpd/male_04_2.mdl",
    ["male 05"] = "models/monolithservers/mpd/male_05.mdl",
    ["male 07"] = "models/monolithservers/mpd/male_07_2.mdl",
    ["male 08"] = "models/monolithservers/mpd/male_08.mdl",
    ["male 09"] = "models/monolithservers/mpd/male_09_2.mdl",
    -- FEMKI
}

local ranks = {
    {name = "Chief", chance = 5},
    {name = "Cmdr.", chance = 5},
    {name = "Cpt.", chance = 15},
    {name = "Lt.", chance = 35},
    {name = "Sgt.", chance = 45},
    {name = "Officer", chance = 80}
}

local clr = Color(10, 10, 100):ToVector()
function CLASS.On(self)
    if CLIENT then return end
    ApplyAppearance(self,nil,nil,nil,true)
    local Appearance = self.CurAppearance
    Appearance.AAttachments = ""
    Appearance.AColthes = ""

    local randomValue = math.random(100)
    local cumulativeChance = 0
    local rank = "Officer"

    for _, rankInfo in ipairs(ranks) do
        cumulativeChance = cumulativeChance + rankInfo.chance
        if randomValue <= cumulativeChance then
            rank = rankInfo.name
            break
        end
    end

    self:SetNWString("PlayerName", rank .. " " .. Appearance.AName)
    self:SetPlayerColor(clr)
    self:SetModel(models[string.lower(Appearance.AModel)] or table.Random(models))
    self:SetBodyGroups("000000000000000000")
    self:SetSubMaterial()
    self:SetNetVar("Accessories", Appearance.AAttachmets or "none")
    self.CurAppearance = Appearance
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

