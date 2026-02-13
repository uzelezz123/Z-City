hook.Add("RenderScreenspaceEffects","hg-headcrab",function()
    if lply:GetNetVar("headcrab") and lply == GetViewEntity() and lply.PlayerClassName ~= "headcrabzombie" then
        lply:ScreenFade(SCREENFADE.IN, color_black, 1, 1)
    end
end)

hook.Add("Player Spawn", "removecrab", function(ply)
    if IsValid(ply.headcrabmodel) then
        ply.headcrabmodel:Remove()
        ply.headcrabmodel = nil
    end
end)

local offsetVec = Vector(-1,0,0)
local offsetAng = Angle(-90,-90,-20)
--hook.Add("PostDrawPlayerRagdoll","hg-drawplayer",function(ent,ply)
function hg.RenderHeadcrab(ent, ply)
    if not IsValid(ply.headcrabmodel) then
        ply.headcrabmodel = ClientsideModel(ply:GetNetVar("headcrab"))
        
        local model = ply.headcrabmodel
        model:SetNoDraw(true)
        
        ent:CallOnRemove("removefunc",function()
            if IsValid(model) then
                model:Remove()
                model = nil
            end
        end)
    end
    local model = ply.headcrabmodel

    local head = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Head1"))
    if not head then
        if IsValid(model) then
            model:Remove()
            model = nil
        end
        return
    end
    local pos,ang = LocalToWorld(offsetVec,offsetAng,head:GetTranslation(),head:GetAngles())
    
    if not IsValid(model) then return end
    model:SetRenderOrigin(pos)
    model:SetRenderAngles(ang)
    model:DrawModel()
end
--end)