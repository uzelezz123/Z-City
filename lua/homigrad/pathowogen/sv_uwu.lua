function hg.Furrify(ply)
    if !IsValid(ply) or !ply.SetPlayerClass then return end
    ply:SetPlayerClass("furry")
end