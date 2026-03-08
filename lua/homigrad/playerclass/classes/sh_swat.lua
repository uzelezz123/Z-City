local CLASS = player.RegClass("swat")

function CLASS.Off(self)
    if CLIENT then return end
end

local models = {
    "models/css_seb_swat/css_swat.mdl",
}

function CLASS.On(self)
    if CLIENT then return end
    ApplyAppearance(self,nil,nil,nil,true)
    self:SetPlayerColor(Color(10,10,100):ToVector())
    self:SetModel(models[math.random(#models)])
    self:SetSubMaterial()
    timer.Simple(0,function()
        self:SetBodyGroups("00000000000")
    end)
    local Appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()
    Appearance.AAttachments = ""
    Appearance.AColthes = ""
    self:SetNetVar("Accessories", "")
    self.CurAppearance = Appearance
    local inv = self:GetNetVar("Inventory", {})
    inv["Weapons"] = inv["Weapons"] or {}
    inv["Weapons"]["hg_sling"] = true
    self:SetNetVar("Inventory", inv)

    self:SetNWString("PlayerName","SWAT "..Appearance.AName)
end

function CLASS.Guilt(self, Victim)
    if CLIENT then return end

    if Victim:GetPlayerClass() == self:GetPlayerClass() then
        return 1
    end

    if CurrentRound().name == "hmcd" then
        return zb.ForcesAttackedInnocent(self, Victim)
    end

    if Victim == zb.hostage then
        return 1
    end

    return 1
end

hook.Add("HG_PlayerFootstep", "swat_footsteps", function(ply, pos, foot, sound, volume, rf)
	local chr = hg.GetCurrentCharacter(ply)
	if ply:Alive() and ply.PlayerClassName == "swat" then
		local ent = hg.GetCurrentCharacter(ply)

		if not (ply:IsWalking() or ply:Crouching()) and ent == ply then
			local snd = "zcitysnd/" .. string.Replace(sound, "player/footsteps", "player/footsteps_military/")
			if SoundDuration(snd) <= 0 then
				snd = sound -- missing footsteps fix
			end

			EmitSound(snd, pos, ply:EntIndex(), CHAN_AUTO, volume, 75, nil, changePitch(math.random(95,105)) )

			return true
		end
	end
end)