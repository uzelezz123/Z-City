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

hook.Add("HG_PlayerFootstep", "terrorist_footsteps", function(ply, pos, foot, sound, volume, rf)
	local chr = hg.GetCurrentCharacter(ply)
	if ply:Alive() and ply.PlayerClassName == "terrorist" then
		local ent = hg.GetCurrentCharacter(ply)

		if not (ply:IsWalking() or ply:Crouching()) and ent == ply then
			local snd = "homigrad/" .. sound
			if SoundDuration(snd) <= 0 then
				snd = sound -- missing footsteps fix
			end

			EmitSound("homigrad/player/footsteps/new/bass_0"..math.random(9)..".wav", pos, ply:EntIndex(), CHAN_AUTO, volume, 75, nil, changePitch(math.random(95,105)))
			EmitSound(snd, pos, ply:EntIndex(), CHAN_AUTO, volume, 75, nil, changePitch(math.random(95,105)))
		end
	end
end)