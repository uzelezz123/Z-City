local CLASS = player.RegClass("groove")

function CLASS.Off(self)
    if CLIENT then return end
end

local models = {
    "models/gang_groove/gang_1.mdl",
    "models/gang_groove/gang_2.mdl",
    "models/gang_chem/gang_groove_chem.mdl"
}

local subnames = {
	"Big ",
	"Lil ",
	"OG "
}

function CLASS.On(self)
    if CLIENT then return end
    ApplyAppearance(self,nil,nil,nil,true)
    local Appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()
    Appearance.AAttachments = ""
    Appearance.AColthes = ""
	self:SetNWString("PlayerName",subnames[math.random(#subnames)] .. Appearance.AName)
    self:SetPlayerColor(Color(0,165,0):ToVector())
    self:SetModel(models[math.random(#models)])
	for _, bg in ipairs(self:GetBodyGroups()) do
		self:SetBodygroup(bg.id, math.random(0, bg.num))
	end
    
    local inv = self:GetNetVar("Inventory", {})
    inv["Weapons"] = inv["Weapons"] or {}
    inv["Weapons"]["hg_sling"] = true
    self:SetNetVar("Inventory", inv)

    self:SetSubMaterial()
    self.CurAppearance = Appearance
end