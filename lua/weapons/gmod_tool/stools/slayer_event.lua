TOOL.Category = "ZBattle"
TOOL.Name = "Slayer Event"

TOOL.Information = {
    { name = "left" }
}

if CLIENT then
    language.Add("tool.slayer_event.name", "Slayer Event")
    language.Add("tool.slayer_event.desc", "Spawn a slayer strike event at the aimed location.")
    language.Add("tool.slayer_event.left", "Trigger slayer event")
end

if SERVER then
    hook.Add("PlayerUse", "slayer_event_pickup", function(ply, ent)
        if not IsValid(ply) or not IsValid(ent) then return end
        local class = ent:GetClass()
        if class ~= "prop_dynamic" and class ~= "prop_physics" then return end
        if not ent:GetNWBool("slayer_event_pickup", false) then return end
        if ply:HasWeapon("weapon_hg_slayersword") then
            ent:Remove()
            return false
        end
        ply:Give("weapon_hg_slayersword")
        ent:EmitSound("slayerevent/slayerequip.ogg", 75, 100, 1, CHAN_AUTO)
        ent:Remove()
        return false
    end)
end

local function SpawnTimedPfx(className, pos, ang, lifeTime)
    local ent = ents.Create(className)
    if not IsValid(ent) then return nil end
    ent:SetPos(pos)
    ent:SetAngles(ang or angle_zero)
    ent:Spawn()
    ent:Activate()
    ent:SetMoveType(MOVETYPE_NONE)
    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(false)
        phys:Sleep()
    end
    
    timer.Simple(0.1, function()
        if IsValid(ent) and ent.pfxname then
            ParticleEffect(ent.pfxname, ent:GetPos(), ent:GetAngles(), ent)
        end
    end)
    
    if lifeTime and lifeTime > 0 then
        timer.Simple(lifeTime, function()
            if IsValid(ent) then
                ent:Remove()
            end
        end)
    end
    return ent
end

local function GetSwordFlightAngles(fromPos, toPos)
    local ang = (toPos - fromPos):Angle()
    ang:RotateAroundAxis(ang:Right(), 270)
    ang:RotateAroundAxis(ang:Up(), -90)
    return ang
end

local function SpawnPortalEntity(pos, ang)
    local ent = ents.Create("pfx5_00_alt")
    if not IsValid(ent) then return nil end
    ent:SetPos(pos)
    ent:SetAngles(ang or angle_zero)
    ent:Spawn()
    ent:Activate()
    ent:SetMoveType(MOVETYPE_NONE)
    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(false)
        phys:Sleep()
    end

    timer.Simple(0.1, function()
        if IsValid(ent) then
            ParticleEffect(ent.pfxname or "[5]black_hole_b", ent:GetPos(), ent:GetAngles(), ent)
        end
    end)
    
    return ent
end

local function PortalImpactFlash(pos, radius)
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:Alive() and ply:EyePos():DistToSqr(pos) <= radius * radius then
            ply:ScreenFade(SCREENFADE.IN, Color(255, 255, 255, 90), 0.18, 0)
        end
    end
end

local function PlayGlobalEventSound(soundPath, level, pitch)
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) then
            ply:EmitSound(soundPath, level or 90, pitch or 100, 1, CHAN_AUTO)
        end
    end
end

local function AttachShockPfxToVictim(victim, lifeTime)
    if not IsValid(victim) then return end
    local pfx = ents.Create("pfx4_05")
    if not IsValid(pfx) then return end
    pfx:SetPos(victim:WorldSpaceCenter())
    pfx:Spawn()
    pfx:Activate()
    pfx:SetParent(victim)
    local bone = victim:LookupBone("ValveBiped.Bip01_Spine2") or victim:LookupBone("ValveBiped.Bip01_Spine")
    if bone then
        pfx:FollowBone(victim, bone)
    end
    timer.Simple(lifeTime or 1.2, function()
        if IsValid(pfx) then
            pfx:Remove()
        end
    end)
end

local function DamageAndShockVictim(owner, victim, impactPos)
    if not IsValid(victim) then return end
    local dmg = DamageInfo()
    dmg:SetDamage(35)
    dmg:SetDamageType(bit.bor(DMG_SHOCK, DMG_BLAST))
    dmg:SetDamagePosition(impactPos)
    dmg:SetAttacker(IsValid(owner) and owner or game.GetWorld())
    dmg:SetInflictor(IsValid(owner) and owner or game.GetWorld())
    victim:TakeDamageInfo(dmg)
    if victim:IsPlayer() and hg and hg.LightStunPlayer then
        hg.LightStunPlayer(victim, 1.5)
    end
    AttachShockPfxToVictim(victim, 1.2)
end

local function RunExplosion(owner, impactPos, startPos)
    util.BlastDamage(IsValid(owner) and owner or game.GetWorld(), IsValid(owner) and owner or game.GetWorld(), impactPos, 280, 95)
    util.ScreenShake(impactPos, 12, 130, 0.9, 1400)
    sound.Play("slayerevent/SlayerGotExplosion.wav", impactPos, 150, 100, 1)
    if hg and hg.PlayExtraExplosionSound then
        hg.PlayExtraExplosionSound(impactPos, 0, 1)
    else
        EmitSound("explosionextra/explode_" .. math.random(1, 9) .. ".wav", impactPos, 900, CHAN_ITEM, 1, 145, 0, math.random(95, 105))
    end

    SpawnTimedPfx("pfx8_03", impactPos, angle_zero, 0.4)

    local bursts = 10
    for i = 1, bursts do
        local angle = Angle(0, (i / bursts) * 360, 0)
        local offset = angle:Forward() * math.Rand(35, 130)
        offset.z = math.Rand(0, 45)
        SpawnTimedPfx("pfx4_05", impactPos + offset, angle_zero, 0.4)
    end

    for _, ent in ipairs(ents.FindInSphere(impactPos, 280)) do
        if not (ent:IsPlayer() or ent:IsNPC()) then continue end
        local pushDir = ent:WorldSpaceCenter() - impactPos
        if pushDir:LengthSqr() <= 1 then
            pushDir = VectorRand()
        end
        pushDir:Normalize()
        ent:SetVelocity(pushDir * 250 + Vector(0, 0, 145))
        DamageAndShockVictim(owner, ent, impactPos)
    end

    local dropped = ents.Create("prop_physics")
    if IsValid(dropped) then
        dropped:SetModel("models/berserk/dragonslayer/dragonslayer.mdl")
        local fallDir = (impactPos - (startPos or (impactPos - Vector(0, 0, 1))))
        if fallDir:LengthSqr() <= 0.001 then
            fallDir = Vector(1, 0, 0)
        else
            fallDir:Normalize()
        end
        local groundTrace = util.TraceLine({
            start = impactPos + Vector(0, 0, 24),
            endpos = impactPos - Vector(0, 0, 96),
            mask = MASK_SOLID_BRUSHONLY
        })
        local groundPos = groundTrace.Hit and groundTrace.HitPos or impactPos
        local lodgedAng = GetSwordFlightAngles(impactPos - fallDir * 16, impactPos)
        lodgedAng.p = lodgedAng.p + 14
        dropped:SetPos(groundPos + Vector(0, 0, 35))
        dropped:SetAngles(lodgedAng)
        dropped:Spawn()
        dropped:Activate()
        dropped:SetUseType(SIMPLE_USE)
        dropped:SetNWBool("slayer_event_pickup", true)
        local phys = dropped:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(false)
            phys:Sleep()
        end
    else
        local fallback = ents.Create("prop_physics")
        if IsValid(fallback) then
            fallback:SetModel("models/berserk/dragonslayer/dragonslayer.mdl")
            fallback:SetPos(impactPos + Vector(0, 0, 24))
            fallback:SetAngles(Angle(0, math.random(0, 360), 0))
            fallback:Spawn()
            fallback:Activate()
        end
    end
end

local function SpawnFlyingSword(owner, startPos, impactPos, portalPos, portalEnt)
    local sword = ents.Create("prop_dynamic")
    if not IsValid(sword) then
        RunExplosion(owner, impactPos, startPos)
        return
    end

    sword:SetModel("models/berserk/dragonslayer/dragonslayer.mdl")
    sword:SetPos(startPos)
    sword:SetAngles(GetSwordFlightAngles(startPos, impactPos))
    sword:Spawn()
    sword:Activate()

    local swordPfx = ents.Create("pfx4_05")
    if IsValid(swordPfx) then
        swordPfx:SetPos(startPos)
        swordPfx:SetAngles(angle_zero)
        swordPfx:Spawn()
        swordPfx:Activate()
        swordPfx:SetParent(sword)
        timer.Simple(0.1, function()
            if IsValid(swordPfx) then
                ParticleEffect(swordPfx.pfxname or "[4]arcs_electric_1", swordPfx:GetPos(), swordPfx:GetAngles(), swordPfx)
            end
        end)
    end

    local travelTime = 1.1
    if portalPos then
        local beam = SpawnTimedPfx("pfx4_08", portalPos, (impactPos - portalPos):Angle(), 0.15)
        timer.Simple(0.1, function()
            if IsValid(beam) then
                ParticleEffect("[4]electric_beam", beam:GetPos(), beam:GetAngles(), beam)
            end
        end)
    end
    local step = 0.02
    local steps = math.max(1, math.floor(travelTime / step))
    local timerId = "slayer_event_flight_" .. sword:EntIndex() .. "_" .. math.random(1000, 999999)
    local currentStep = 0

    timer.Create(timerId, step, steps, function()
        if not IsValid(sword) then
            timer.Remove(timerId)
            return
        end
        currentStep = currentStep + 1
        local fraction = math.Clamp(currentStep / steps, 0, 1)
        local pos = LerpVector(fraction, startPos, impactPos)
        sword:SetPos(pos)
        sword:SetAngles(GetSwordFlightAngles(pos, impactPos))
    end)

    timer.Simple(travelTime, function()
        if IsValid(sword) then
            sword:Remove()
        end
        if IsValid(swordPfx) then
            swordPfx:Remove()
        end
        if IsValid(portalEnt) then
            portalEnt:Remove()
        end
        RunExplosion(owner, impactPos, startPos)
    end)
end

local function TriggerSlayerEvent(owner, hitPos)
    local impactPos = hitPos + Vector(0, 0, 2)
    local approachDir = owner:GetForward()
    approachDir.z = 0
    if approachDir:LengthSqr() <= 0.001 then
        approachDir = owner:GetAimVector()
        approachDir.z = 0
    end
    if approachDir:LengthSqr() <= 0.001 then
        approachDir = Vector(1, 0, 0)
    else
        approachDir:Normalize()
    end
    local portalPos = owner:GetPos()
    local startPos = portalPos
    local portalAng = angle_zero

    local portalEnt
    PlayGlobalEventSound("slayerevent/SlayerSpawnIn.wav", 90, 100)

    timer.Simple(0.5, function()
        if not IsValid(owner) then return end
        SpawnTimedPfx("pfx5_00_alt_s", portalPos, portalAng, 0.22)
        util.ScreenShake(portalPos, 18, 140, 1.4, 2300)
        PortalImpactFlash(portalPos, 1600)
        timer.Simple(2, function()
            if not IsValid(owner) then return end
            PortalImpactFlash(portalPos, 1600)
            util.ScreenShake(portalPos, 16, 135, 1.2, 2300)
        end)
        timer.Simple(0.18, function()
            if not IsValid(owner) then return end
            portalEnt = SpawnPortalEntity(portalPos, portalAng)
        end)
    end)

    timer.Simple(3, function()
        if not IsValid(owner) then return end
        SpawnFlyingSword(owner, startPos, impactPos, portalPos, portalEnt)
    end)
end

function TOOL:LeftClick(trace)
    if CLIENT then return true end
    local owner = self:GetOwner()
    if not IsValid(owner) then return false end
    TriggerSlayerEvent(owner, trace.HitPos)
    return true
end

function TOOL.BuildCPanel(panel)
    panel:AddControl("Header", { Description = "Calls down a slayer sword strike event." })
end