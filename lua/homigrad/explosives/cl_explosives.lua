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
    },
    CustomBarrel = {
        Near = {"ied/ied_detonate_01.wav","ied/ied_detonate_02.wav","ied/ied_detonate_03.wav"},
        Far = {"ied/ied_detonate_dist_01.wav","ied/ied_detonate_dist_02.wav","ied/ied_detonate_dist_03.wav"},
        Effect = "pcf_jack_groundsplode_medium"
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
local GasTankEffects = {}
PrecacheParticleSystem("fire_jet_01")
net.Receive("hg_booom",function()
    local pos = net.ReadVector()
    local type = net.ReadString()
    local explosionData = ExplosiveSound[type] or ExplosiveSound.Normal
    if effectCDCurTime < CurTime() then
        effectPerMSec = 0
    end
    if effectPerMSec < 10 then
        ParticleEffect(explosionData.Effect,pos,vector_up:Angle())
        effectPerMSec = effectPerMSec + 1
        effectCDCurTime = CurTime() + 0.2
    end
    PlaySndDist(table.Random(explosionData.Near),table.Random(explosionData.Far),pos,false,"huy")
end)

net.Receive("hg_gastank_leak", function()
    local ent = net.ReadEntity()
    local localHolePos = net.ReadVector()
    local localNormal = net.ReadVector()
    local mode = net.ReadString()
    if not IsValid(ent) then return end

    local idx = ent:EntIndex()
    local data = GasTankEffects[idx]
    if not data then
        data = { Entity = ent, Leaks = {} }
        GasTankEffects[idx] = data
    end
    if mode == "fire" and not data.FireSound then
        data.FireSound = CreateSound(ent, "tankfire.mp3")
        if data.FireSound then
            data.FireSound:SetSoundLevel(70)
            data.FireSound:Play()
        end
    end
    if mode == "smoke" and not data.SmokeSound then
        data.SmokeSound = CreateSound(ent, "ambient/gas/cannister_loop.wav")
        if data.SmokeSound then
            data.SmokeSound:SetSoundLevel(65)
            data.SmokeSound:Play()
            data.SmokeSound:ChangePitch(130, 0)
        end
    end

    local holePosWorld = ent:LocalToWorld(localHolePos)
    local normalWorld = (ent:LocalToWorld(localHolePos + localNormal) - holePosWorld):GetNormalized()

    local dummy = ClientsideModel("models/props_junk/PopCan01a.mdl", RENDERGROUP_NONE)
    dummy:SetPos(holePosWorld)
    dummy:SetAngles(normalWorld:Angle())
    dummy:SetParent(ent)
    dummy:SetRenderMode(RENDERMODE_TRANSCOLOR)
    dummy:SetColor(Color(0, 0, 0, 0))
    if mode == "fire" then
        ParticleEffectAttach("fire_jet_01", PATTACH_ABSORIGIN_FOLLOW, dummy, 0)
    end

    table.insert(data.Leaks, { Dummy = dummy, Mode = mode })
end)

net.Receive("hg_gastank_stop", function()
    local entIndex = net.ReadUInt(16)
    local data = GasTankEffects[entIndex]
    if not data then return end
    if data.FireSound then data.FireSound:Stop() end
    if data.SmokeSound then data.SmokeSound:Stop() end
    if istable(data.Leaks) then
        for _, leak in ipairs(data.Leaks) do
            if leak.Dummy and IsValid(leak.Dummy) then leak.Dummy:Remove() end
        end
    end
    GasTankEffects[entIndex] = nil
end)

hook.Add("Think", "hg_gastank_client_cleanup", function()
    for idx, data in pairs(GasTankEffects) do
        if IsValid(data.Entity) then continue end
        if data.FireSound then data.FireSound:Stop() end
        if data.SmokeSound then data.SmokeSound:Stop() end
        if istable(data.Leaks) then
            for _, leak in ipairs(data.Leaks) do
                if leak.Dummy and IsValid(leak.Dummy) then leak.Dummy:Remove() end
            end
        end
        GasTankEffects[idx] = nil
    end
end)