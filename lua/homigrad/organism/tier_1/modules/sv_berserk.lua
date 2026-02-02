hook.Add("Player Think", "Berserk", function(ply, time, dtime)
    if !ply:IsBerserk() or ply:GetMoveType() == MOVETYPE_NOCLIP then return end
    local velocity = ply:GetVelocity():Length2DSqr()
    if velocity > 100000 then
        for _, v in ipairs(ents.FindInSphere(ply:GetPos(), 64)) do
            if v == ply then continue end
            local Phys = v:IsPlayer() and v:GetPhysicsObject() or v:GetPhysicsObjectNum(0)

            if v:IsPlayer() then
                v:ViewPunch(Angle(-5,0,0))
            end

            local AimVec = (v:GetPos() - ply:GetPos()):GetNormalized()
            local force = velocity / 800000

            if IsValid(Phys) then
                if v:IsPlayer() then v:SetVelocity(AimVec * 500 * force) end
                Phys:ApplyForceOffset(AimVec * 500 * force, ply:GetPos())

                v:SetPhysicsAttacker(ply, 5)
            end
        end
    end
end)