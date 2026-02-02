local PLUGIN = hg.PluvTown

PLUGIN.AddHook("ShowTeam", function(ply)
    if (ply.PluviskiCD or 0) > CurTime() then return end

    ply:Say("Я ЛЮБЛЮ ПЛЫВИСКИ")
    ply.PluviskiCD = CurTime() + 0.5
end)

PLUGIN.AddHook("PlayerDeath", function(ply)
    local ragdoll = ply.RagdollDeath

    if IsValid(ragdoll) then
        ragdoll:SetNetVar("CurPluvLayer", "dead")
        ragdoll:SetNetVar("CurPluv", ply:GetNetVar("CurPluv", "pluv"))
    end
end)

PLUGIN.AddHook("Fake", function(ply, ragdoll)
    ragdoll:SetNetVar("CurPluv", ply:GetNetVar("CurPluv", "pluv"))
end)

PLUGIN.AddHook("Org Think", function(ply, org)
    if ply:GetNetVar("CurPluvLayer") != "cry" and ply:GetNetVar("CurPluvLayer") != "dead" and org.pain >= 20 then
        ply:SetNetVar("CurPluvLayer", "cry")

        if IsValid(ply.FakeRagdoll) then
            ply.FakeRagdoll:SetNetVar("CurPluvLayer", "cry")
        end
    elseif ply:GetNetVar("CurPluvLayer") == "cry" and ply:GetNetVar("CurPluvLayer") != "dead" and org.pain < 20 then
        ply:SetNetVar("CurPluvLayer", nil)

        if IsValid(ply.FakeRagdoll) then
            ply.FakeRagdoll:SetNetVar("CurPluvLayer", nil)
        end
    end
end)