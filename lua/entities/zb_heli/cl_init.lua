include("shared.lua")

if not net then 
    timer.Simple(1, function()
        if net then
            net.Receive("zb_heli_phase_update", function()
                local ent = net.ReadEntity()
                local phase = net.ReadString()
                local waitStartTime = net.ReadFloat()
                
                if IsValid(ent) then
                    ent.Phase = phase
                    ent.WaitingStartTime = waitStartTime > 0 and waitStartTime or nil
                end
            end)
        end
    end)
else
    net.Receive("zb_heli_phase_update", function()
        local ent = net.ReadEntity()
        local phase = net.ReadString()
        local waitStartTime = net.ReadFloat()
        
        if IsValid(ent) then
            ent.Phase = phase
            ent.WaitingStartTime = waitStartTime > 0 and waitStartTime or nil
        end
    end)
end

function ENT:DrawTranslucent(flags)
    self:DrawModel(flags)
end
