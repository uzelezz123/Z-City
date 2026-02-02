--
local ExplosiveSound = {
    Fire = {
        Near = {"ied/ied_detonate_01.wav","ied/ied_detonate_02.wav","ied/ied_detonate_03.wav"},
        Far = {"ied/ied_detonate_dist_01.wav","ied/ied_detonate_dist_02.wav","ied/ied_detonate_dist_03.wav"},
        Effect = "pcf_jack_incendiary_ground_sm2"
    },
    Sharpnel = {
        Near = {"ied/ied_detonate_01.wav","ied/ied_detonate_02.wav","ied/ied_detonate_03.wav"},
        Far = {"ied/ied_detonate_dist_01.wav","ied/ied_detonate_dist_02.wav","ied/ied_detonate_dist_03.wav"},
        Effect = "pcf_jack_groundsplode_medium"
    },
    Normal = {
        Near = {"ied/ied_detonate_01.wav","ied/ied_detonate_02.wav","ied/ied_detonate_03.wav"},
        Far = {"ied/ied_detonate_dist_01.wav","ied/ied_detonate_dist_02.wav","ied/ied_detonate_dist_03.wav"},
        Effect = "pcf_jack_groundsplode_small"
    }
}

local function PlaySndDist(snd,snd2,pos,isOnWater,watersnd)
    if SERVER then return end
    local view = render.GetViewSetup(true)
    local time = pos:Distance(view.origin) / 17836
    --print(time)
    timer.Simple(time, function()
        local owner = Entity(0)
        if not isOnWater then
            EmitSound(snd2, pos, 0, CHAN_WEAPON, 1, 110, 0, 100, 0, nil)
            EmitSound(snd, pos, 0, CHAN_AUTO, 1, time > 0.6 and 140 or 110, 0, 100, 0, nil)
        else
            EmitSound(watersnd, pos, 0, CHAN_WEAPON, 1, 100, 0, 85, 0, nil)
        end
    end)
end
local effectPerMSec = 0
local effectCDCurTime = 0
net.Receive("hg_booom",function()
    local pos = net.ReadVector()
    local type = net.ReadString()
    if effectCDCurTime < CurTime() then
        effectPerMSec = 0
    end
    if effectPerMSec < 10 then
        ParticleEffect(ExplosiveSound[type].Effect,pos,vector_up:Angle())
        effectPerMSec = effectPerMSec + 1
        effectCDCurTime = CurTime() + 0.2
    end
    PlaySndDist(table.Random(ExplosiveSound[type].Near),table.Random(ExplosiveSound[type].Far),pos,false,"huy")
end)