
hg.organism = hg.organism or {}
hg.organism.module = hg.organism.module or {}
local module = hg.organism.module

hg.organism.nNextEntIndex = hg.organism.nNextEntIndex or 1000000

util.AddNetworkString("organism_send")
util.AddNetworkString("organism_sendply")

-- Вобще бы сделать функцию глобальной и везде юзать, одно и тоже пишите
local function GetOrCreateConVar( name, default, flags, help, min, max )
    if ConVarExists( name ) then
        return GetConVar( name )
    end
    return CreateConVar( name, default, flags, help, min, max )
end

local hg_unreliable_nets = GetOrCreateConVar( "hg_unreliable_nets", 0, {FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE}, "Toggle unreliable net messages", 0, 1 )
local hg_developer       = GetOrCreateConVar( "hg_developer",       0, {FCVAR_SERVER_CAN_EXECUTE},                "Toggle developer mode (enables damage traces)", 0, 1 )
local CurTime = CurTime
local IsValid = IsValid
local math_Rand = math.Rand
local math_random = math.random
local math_max = math.max
local math_min = math.min
local math_Approach = math.Approach


hook.Add("Org Clear", "Main", function(org)
    if not org.owner then return end

    local pOwner = org.owner
    local bIsValidOwner = IsValid(pOwner)

    org.alive = true
    org.otrub = false
    org.entindex = bIsValidOwner and pOwner:EntIndex() or hg.organism.nNextEntIndex
    if not bIsValidOwner then
        hg.organism.nNextEntIndex = hg.organism.nNextEntIndex + 1
    end

    if module.pulse then module.pulse[1](org) end
    if module.blood then module.blood[1](org) end
    if module.pain then module.pain[1](org) end
    if module.stamina then module.stamina[1](org) end
    if module.lungs then module.lungs[1](org) end
    if module.liver then module.liver[1](org) end
    if module.metabolism then module.metabolism[1](org) end
    if module.random_events then module.random_events[1](org) end

    org.brain = 0
    org.consciousness = 1
    org.disorientation = 0
    org.jaw = 0
    org.spine1 = 0
    org.spine2 = 0
    org.spine3 = 0
    org.chest = 0
    org.pelvis = 0
    org.skull = 0
    org.stomach = 0
    org.intestines = 0
    org.thiamine = 0

    org.lleg = 0
    org.rleg = 0
    org.larm = 0
    org.rarm = 0

    org.llegdislocation = false
    org.rlegdislocation = false
    org.rarmdislocation = false
    org.larmdislocation = false
    org.jawdislocation = false

    org.llegamputated = false
    org.rlegamputated = false
    org.rarmamputated = false
    org.larmamputated = false
    org.headamputated = false

    org.furryinfected = false

    org.health = 100
    org.canmove = true
    org.recoilmul = 1
    org.legstrength = 1
    org.meleespeed = 1
    org.temperature = 36.7
    org.superfighter = false
    org.CantCheckPulse = nil
    org.HEV = nil
    org.bleedingmul = 1

    org.last_heartbeat = CurTime()
    org.bulletwounds = 0
    org.stabwounds = 0
    org.slashwounds = 0
    org.bruises = 0
    org.burns = 0
    org.explosionwounds = 0

    org.fear = 0
    org.fearadd = 0

    org.assimilated = 0
    org.berserk = 0
    org.noradrenaline = 0
    org.blindness = nil

    if bIsValidOwner then
        if pOwner:IsPlayer() and pOwner:Alive() then
            pOwner:SetHealth(100)
            pOwner:SetNetVar("wounds", {})
            pOwner:SetNetVar("arterialwounds", {})
        end
        pOwner:SetNetVar("zableval_masku", false)
    end

    org.allowholster = false
    org.just_damaged_bone = nil
    org.LodgedEntities = nil
    org.dmgstack = {}
    org.SpawnedBrainChunks = nil
end)

--Вернул true когда персонаж может стоять чтобы гарантом значение было вместо нил я не знаю как это но типо оно и так работало но так нельзя типо хз
hook.Add("Should Fake Up", "organism", function(ply)
    local org = ply.organism
    if not org then return end

    if org.otrub or org.fake then return false end
    if org.spine1 >= hg.organism.fake_spine1 then return false end
    if org.spine2 >= hg.organism.fake_spine2 then return false end
    if org.spine3 >= hg.organism.fake_spine3 then return false end
    if (org.lleg == 1 and org.rleg == 1) and org.berserk <= 0.3 then return false end
    if org.blood < 2900 then return false end
    if org.consciousness <= 0.4 then return false end

    return true 
end)

local function SendFullOrganism(org, pTargetPlayer)
    if not IsValid(org.owner) then return end

    local sendtable = {}
    sendtable.alive = org.alive
    sendtable.otrub = org.otrub
    sendtable.owner = org.owner
    sendtable.stamina = org.stamina
    sendtable.immobilization = org.immobilization
    sendtable.adrenaline = org.adrenaline
    sendtable.adrenalineAdd = org.adrenalineAdd
    sendtable.analgesia = org.analgesia
    sendtable.lleg = org.lleg
    sendtable.rleg = org.rleg
    sendtable.rarm = org.rarm
    sendtable.larm = org.larm
    sendtable.pelvis = org.pelvis
    sendtable.skull = org.skull
    sendtable.chest = org.chest
    sendtable.internalBleed = org.internalBleed
    sendtable.internalBleedHeal = org.internalBleedHeal
    sendtable.disorientation = org.disorientation
    sendtable.brain = org.brain
    sendtable.o2 = org.o2
    sendtable.CO = org.CO
    sendtable.blood = org.blood
    sendtable.bloodtype = org.bloodtype
    sendtable.bleed = org.bleed
    sendtable.hurt = org.hurt
    sendtable.pain = org.pain
    sendtable.shock = org.shock
    sendtable.pulse = org.pulse
    sendtable.heartbeat = org.heartbeat
    sendtable.timeValue = org.timeValue
    sendtable.holdingbreath = org.holdingbreath
    sendtable.arteria = org.arteria
    sendtable.recoilmul = org.recoilmul
    sendtable.meleespeed = org.meleespeed
    sendtable.temperature = org.temperature
    sendtable.canmove = org.canmove
    sendtable.fear = org.fear
    sendtable.llegdislocation = org.llegdislocation
    sendtable.rlegdislocation = org.rlegdislocation
    sendtable.rarmdislocation = org.rarmdislocation
    sendtable.larmdislocation = org.larmdislocation
    sendtable.jawdislocation = org.jawdislocation
    sendtable.llegamputated = org.llegamputated
    sendtable.rlegamputated = org.rlegamputated
    sendtable.rarmamputated = org.rarmamputated
    sendtable.larmamputated = org.larmamputated
    sendtable.headamputated = org.headamputated
    sendtable.lungsfunction = org.lungsfunction
    sendtable.consciousness = org.consciousness
    sendtable.assimilated = org.assimilated
    sendtable.berserk = org.berserk
    sendtable.noradrenaline = org.noradrenaline
    sendtable.LodgedEntities = org.LodgedEntities
    sendtable.CantCheckPulse = org.CantCheckPulse
    sendtable.blindness = org.blindness
    sendtable.critical = org.critical
    sendtable.incapacitated = org.incapacitated
    sendtable.berserkActive2 = org.berserkActive2
    sendtable.noradrenalineActive = org.noradrenalineActive
    sendtable.superfighter = org.superfighter

    net.Start("organism_send", hg_unreliable_nets:GetBool())
    net.WriteTable(hg_developer:GetBool() and org or sendtable) -- In dev mode send full state for debugging
    net.WriteBool(org.owner.fullsend or false)
    net.WriteBool(false)
    net.WriteBool(true) 
    net.WriteBool(false) 

    if IsValid(pTargetPlayer) and pTargetPlayer:IsPlayer() then
        net.Send(pTargetPlayer)
    else
        net.Broadcast()
    end

    if org.owner == pTargetPlayer or not IsValid(pTargetPlayer) then
        org.owner.fullsend = nil
    end
end

local function SendBareInfo(org)
    if not IsValid(org.owner) then return end

    local sendtable = {}
    sendtable.alive = org.alive
    sendtable.otrub = org.otrub
    sendtable.owner = org.owner
    sendtable.bloodtype = org.bloodtype
    sendtable.pulse = org.pulse
    sendtable.blood = org.blood
    sendtable.heartbeat = org.heartbeat
    sendtable.analgesia = org.analgesia
    sendtable.o2 = org.o2
    sendtable.timeValue = org.timeValue
    sendtable.superfighter = org.superfighter
    sendtable.lungsfunction = org.lungsfunction
    sendtable.lleg = org.lleg
    sendtable.rleg = org.rleg
    sendtable.rarm = org.rarm
    sendtable.larm = org.larm
    sendtable.llegdislocation = org.llegdislocation
    sendtable.rlegdislocation = org.rlegdislocation
    sendtable.rarmdislocation = org.rarmdislocation
    sendtable.larmdislocation = org.larmdislocation
    sendtable.jawdislocation = org.jawdislocation
    sendtable.llegamputated = org.llegamputated
    sendtable.rlegamputated = org.rlegamputated
    sendtable.rarmamputated = org.rarmamputated
    sendtable.larmamputated = org.larmamputated
    sendtable.headamputated = org.headamputated
    sendtable.LodgedEntities = org.LodgedEntities
    sendtable.berserkActive2 = org.berserkActive2
    sendtable.CantCheckPulse = org.CantCheckPulse
    sendtable.noradrenalineActive = org.noradrenalineActive

    local rf = RecipientFilter()
    rf:AddPVS(org.owner:GetPos())
    if org.owner:IsPlayer() then
        rf:RemovePlayer(org.owner)
    end

    net.Start("organism_send", hg_unreliable_nets:GetBool())
    net.WriteTable(hg_developer:GetBool() and org or sendtable)
    net.WriteBool(org.owner.fullsend or false)
    net.WriteBool(true)
    net.WriteBool(false)
    net.WriteBool(false)
    net.Send(rf)
end

-- Expose network functions
hg.send_organism = SendFullOrganism
hg.send_bareinfo = SendBareInfo

-- Player meta helpers (added safely)
local metaPlayer = FindMetaTable("Player")
if metaPlayer then
    function metaPlayer:IsBerserk()
        if not IsValid(self) or not self:IsPlayer() or not self:Alive() then return false end
        local org = self.organism
        return org and org.berserkActive2 or false
    end

    function metaPlayer:IsStimulated()
        if not IsValid(self) or not self:IsPlayer() or not self:Alive() then return false end
        local org = self.organism
        return org and org.noradrenalineActive or false
    end
end

function hg.IsBerserk(ent)
    if not IsValid(ent) then return false end
    if ent:IsPlayer() then return ent:IsBerserk() end
    return false
end

function hg.IsStimulated(ent)
    if not IsValid(ent) then return false end
    if ent:IsPlayer() then return ent:IsStimulated() end
    return false
end

local numerical = {
    "One.", "Two.", "Three.", "Four.", "Five.",
    "Six.", "Seven.", "Eight.", "Nine.", "Ten.",
    "Eleven.", "Twelve.", "Thirteen.", "Fourteen.", "Fifteen.",
    "Sixteen.", "Seventeen.", "Eighteen.", "Nineteen.", "Twenty."
}

hook.Add("HomigradDamage", "Berserk", function(ply, dmgInfo, hitgroup, ent)
    local attacker = dmgInfo:GetAttacker()
    if not IsValid(attacker) or not attacker:IsPlayer() then
        attacker = ply:GetPhysicsAttacker()
    end
    if not IsValid(attacker) or not attacker:IsPlayer() then return end
    if not IsValid(ply) or not ply:IsPlayer() then return end
    if attacker == ply then return end
    if not attacker:IsBerserk() then return end

    timer.Simple(0, function()
        if not IsValid(attacker) or not IsValid(ply) then return end
        if ply:Alive() then return end -- Only count if victim dies
        attacker.BerserkKills = (attacker.BerserkKills or 0) + 1
        attacker:NotifyBerserk(numerical[attacker.BerserkKills] or (attacker.BerserkKills .. "."))
        attacker.organism.berserk = attacker.organism.berserk + 0.5
    end)
end)


hook.Add("Org Think", "Main", function(owner, org, flTimeValue)
    if not IsValid(owner) then
        hg.organism.list[owner] = nil
        return
    end

    local bIsPlayer = owner:IsPlayer()
    org.isPly = bIsPlayer

    if bIsPlayer or org.fakePlayer then
        if not org.fakePlayer then
            org.alive = owner:Alive()
        end
    else
        org.alive = false
    end

    org.needotrub = false
    org.needfake = false
    if bIsPlayer then
        org.ownerFake = org.FakeRagdoll and true or false
    else
        org.ownerFake = false
    end

    org.timeValue = flTimeValue
    org.incapacitated = false
    org.critical = false

    if bIsPlayer and module.stamina then module.stamina[2](owner, org, flTimeValue) end
    if (bIsPlayer or org.fakePlayer) and module.lungs then module.lungs[2](owner, org, flTimeValue) end
    if bIsPlayer and module.liver then module.liver[2](owner, org, flTimeValue) end
    if module.blood then module.blood[2](owner, org, flTimeValue) end
    if module.pain then module.pain[2](owner, org, flTimeValue) end
    if bIsPlayer and module.metabolism then module.metabolism[2](owner, org, flTimeValue) end
    if bIsPlayer and module.random_events then module.random_events[2](owner, org, flTimeValue) end
    if module.pulse then module.pulse[2](owner, org, flTimeValue) end

   -- что бы легче можно было фурри вырезать

    if owner.PlayerClassName then
        if owner.PlayerClassName == "furry" then
            org.assimilated = 0
        elseif org.furryinfected then
            org.assimilated = math_Approach(org.assimilated, 1, flTimeValue / 30 * (org.pulse or 70) / 70)
            if org.assimilated >= 1 then
                hg.Furrify(owner)
                org.furryinfected = false
                org.assimilated = 0 
            end
        else

            local flStunTimeLeft = (org.lightstun or 0) - CurTime()
            if flStunTimeLeft <= 0 then
                org.assimilated = math_Approach(org.assimilated, 0, (flTimeValue / 60 * (org.pulse or 70) / 70) * 6)
            end
        end
    else
        org.assimilated = 0
    end

    org.berserk = math_Approach(org.berserk, 0, flTimeValue / 60)
    org.noradrenaline = math_Approach(org.noradrenaline, 0, flTimeValue / 45)

    if org.berserk > 0 and not org.berserkActive then
        org.berserkActive = true
        owner.lastBerserkLaughSoundCD = CurTime() + 5
        timer.Simple(3.95, function()
            if IsValid(owner) then
                org.berserkActive2 = true
            end
        end)
    elseif org.berserk <= 0 then
        org.berserkActive = false
        org.berserkActive2 = false
        owner.BerserkKills = nil
    end

    org.noradrenalineActive = (org.noradrenaline > 0)

    if (org.llegamputated or org.rlegamputated) and org.berserk <= 0.3 then
        org.needfake = true
    end
    if org.rarmamputated and org.larmamputated and owner:IsPlayer() then
        local hands = owner:GetWeapon("weapon_hands_sh")
        if IsValid(hands) and owner:GetActiveWeapon() ~= hands then
            owner:SetActiveWeapon(hands)
        end
    end

    if org.otrub then
        org.uncon_timer = (org.uncon_timer or 0) + flTimeValue
    else
        org.uncon_timer = 0
    end

    local bJustWentUncon = (not org.otrub) and org.needotrub
    local bJustWokeUp = (not org.needotrub) and org.otrub and (org.uncon_timer or 0) > 6

    if bIsPlayer and bJustWentUncon then
        hook.Run("HG_OnOtrub", owner)
        hook.Run("PlayerDropWeapon", owner)
    end
    if bIsPlayer and bJustWokeUp then
        hook.Run("HG_OnWakeOtrub", owner)
    end

    org.canmove = (org.spine2 < hg.organism.fake_spine2 and org.spine3 < hg.organism.fake_spine3) and not org.otrub
    org.canmovehead = (org.spine3 < hg.organism.fake_spine3) and not org.otrub
    if not (org.canmove and org.canmovehead and ((org.stun or 0) - CurTime()) < 0) then
        org.needfake = true
    end
    if org.blood < 2700 then
        org.needfake = true
    end

    if org.posturing then
        local ent = hg.GetCurrentCharacter(owner)
        if IsValid(ent) then
            local function applyForce(boneName)
                local phys = ent:GetPhysicsObjectNum(ent:TranslateBoneToPhysBone(ent:LookupBone(boneName)))
                if IsValid(phys) then
                    local down = -ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Spine")):GetAngles():Forward()
                    phys:ApplyForceCenter(down * 500)
                end
            end
            applyForce("ValveBiped.Bip01_R_Foot")
            applyForce("ValveBiped.Bip01_L_Foot")
            applyForce("ValveBiped.Bip01_R_Hand")
            applyForce("ValveBiped.Bip01_L_Hand")
        end
    end

    if org.brain < 0.4 then
        local flNaturalHeal = (org.thiamine > 0) and (flTimeValue / 480) or (flTimeValue / 1800)
        org.thiamine = math_Approach(org.thiamine, 0, flTimeValue / 240)

        local bones = {"liver","heart","stomach","intestines"}
        for _, name in ipairs(bones) do
            if org[name] and org[name] < 1 then
                org[name] = math_Approach(org[name], 0, flNaturalHeal)
            end
        end
        if org.lungsR and org.lungsR[1] and org.lungsR[1] < 1 then
            org.lungsR[1] = math_Approach(org.lungsR[1], 0, flNaturalHeal)
        end
        if org.lungsL and org.lungsL[1] and org.lungsL[1] < 1 then
            org.lungsL[1] = math_Approach(org.lungsL[1], 0, flNaturalHeal)
        end
    end

    if org.otrub and bIsPlayer and owner:Alive() then
        //org.owner:ScreenFade(SCREENFADE.PURGE, color_black, 0.5, 0)
        //org.owner:ConCommand("soundfade 100 99999")
    end

    if bJustWentUncon then
        org.owner.fullsend = true
    end

    if org.brain > 0.05 then
        if math_random(600) < org.brain * 20 then
            org.needfake = true
        end
    end

    org.otrub = org.needotrub
    org.fake = org.needfake

    if org.needfake and owner:IsNPC() then
        local dmgInfo = DamageInfo()
        dmgInfo:SetDamage(10000)
        dmgInfo:SetAttacker(owner)
        owner:TakeDamageInfo(dmgInfo)
    end

    if owner:IsPlayer() and (org.healthRegen or 0) < CurTime() then
        org.healthRegen = CurTime() + 30
        owner:SetHealth(math_min(owner:GetMaxHealth(), owner:Health() + math_max(1.5 - (org.hurt or 0), 0)))
    end

    org.health = owner:Health()

    local rag = (owner:IsPlayer() and owner.FakeRagdoll) or owner
    if IsValid(rag) and rag:IsRagdoll() and (not owner.lastFake or owner.lastFake == 0) then
        local velSqr = rag:GetVelocity():LengthSqr()
        rag:SetCollisionGroup((velSqr > 40000) and COLLISION_GROUP_NONE or COLLISION_GROUP_WEAPON)
    end

    if bIsPlayer then
        if org.otrub or org.fake then
            hg.Fake(owner, nil, true)
        end
        if not org.alive and owner:Alive() then
            owner:Kill()
        end
    end

    if not org.otrub and bIsPlayer then
        local mul = hg.likely_to_phrase(owner)
        org.likely_phrase = (org.likely_phrase or 0) + math_Rand(0, mul) / 100
        if org.likely_phrase >= 1 and IsValid(owner) and not hg.GetCurrentCharacter(owner):IsOnFire() then
            org.likely_phrase = 0
            local str = hg.get_status_message(owner)
            owner:Notify(str, 1, "phrase", 1, nil, Color(255, math_Clamp(1 / mul * 255, 0, 255), math_Clamp(1 / mul * 255, 0, 255), 255))
        end
    end

    if not org.alive then
        org.otrub = true
        org.lungsfunction = false
        org.heartstop = true
    end

    local curTime = CurTime()
    org.sendPlyTime = org.sendPlyTime or 0
    if curTime < org.sendPlyTime and not bJustWentUncon then return end
    org.sendPlyTime = curTime + 1 + (not bIsPlayer and 2 or 0)

    SendBareInfo(org)
    if owner:IsPlayer() then
        owner:SetNetVar("wounds", org.wounds)
        owner:SetNetVar("arterialwounds", org.arterialwounds)
    end
    if bIsPlayer and owner:Alive() then
        SendFullOrganism(org, owner)
    end
end)

hook.Add("Org Think", "regenerationberserk", function(owner, org, flTimeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    if not owner:IsBerserk() then return end

    org.blood = math_Approach(org.blood, 5000, flTimeValue * 60)

    for i, wound in pairs(org.wounds or {}) do
        wound[1] = math_max((wound[1] or 0) - flTimeValue * 10, 0)
    end
    for i, wound in pairs(org.arterialwounds or {}) do
        wound[1] = math_max((wound[1] or 0) - flTimeValue * 10, 0)
    end

    org.internalBleed = math_max((org.internalBleed or 0) - flTimeValue * 10, 0)

    local flRegen = flTimeValue / 120 * org.berserk
    local bones = {
        "lleg","rleg","rarm","larm","chest","pelvis",
        "spine1","spine2","spine3","skull",
        "liver","intestines","heart","stomach"
    }
    for _, name in ipairs(bones) do
        if org[name] then
            org[name] = math_max(org[name] - flRegen, 0)
        end
    end
    if org.lungsR then
        org.lungsR[1] = math_max((org.lungsR[1] or 0) - flRegen, 0)
        org.lungsR[2] = math_max((org.lungsR[2] or 0) - flRegen, 0)
    end
    if org.lungsL then
        org.lungsL[1] = math_max((org.lungsL[1] or 0) - flRegen, 0)
        org.lungsL[2] = math_max((org.lungsL[2] or 0) - flRegen, 0)
    end
    org.brain = math_max(org.brain - flRegen, 0)

    org.hungry = 0

    local flPainDecay = flTimeValue * 10
    org.pain = math_Approach(org.pain, 0, flPainDecay)
    org.painadd = math_Approach(org.painadd, 0, flPainDecay)
    org.avgpain = math_Approach(org.avgpain, 0, flPainDecay)
    org.shock = math_Approach(org.shock, 0, flPainDecay)
    org.immobilization = math_Approach(org.immobilization, 0, flPainDecay)
    org.disorientation = math_Approach(org.disorientation, 0, flPainDecay)

    org.lungsfunction = true
    org.heartstop = false

    owner:SetRunSpeed(math_min(500, 400 + (25 * org.berserk)))
end)

hook.Add("Org Think", "regenerationnoradrenaline", function(owner, org, flTimeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    if org.noradrenaline <= 0 then return end

    local flRegen = flTimeValue / 60 * org.noradrenaline

    if org.lungsR then
        org.lungsR[1] = math_max((org.lungsR[1] or 0) - flRegen, 0)
        org.lungsR[2] = math_max((org.lungsR[2] or 0) - flRegen, 0)
    end
    if org.lungsL then
        org.lungsL[1] = math_max((org.lungsL[1] or 0) - flRegen, 0)
        org.lungsL[2] = math_max((org.lungsL[2] or 0) - flRegen, 0)
    end

    org.hungry = 0
    org.pain = math_Approach(org.pain, 0, flRegen * 10)
    org.painadd = math_Approach(org.painadd, 0, flRegen * 10)
    org.avgpain = math_Approach(org.avgpain, 0, flRegen * 10)
    org.shock = math_Approach(org.shock, 0, flRegen * 10)
    org.immobilization = math_Approach(org.immobilization, 0, flRegen * 10)
    org.disorientation = math_Approach(org.disorientation, 0, flRegen * 10)
    org.adrenaline = math_Approach(org.adrenaline, 5, flRegen * 100)
    org.analgesia = math_Approach(org.analgesia, 1, flRegen * 10)

    if org.noradrenaline > 2 then
        org.brain = math_Approach(org.brain, 0.3, flTimeValue / 60)
    end

    org.pulse = math_Approach(org.pulse, 70, flRegen * 10)
    org.heartbeat = math_Approach(org.heartbeat, 220, flRegen * 10)

    org.lungsfunction = true
    org.heartstop = false
end)


concommand.Add("hg_organism_setvalue", function(ply, cmd, args)
    if not ply:IsAdmin() then return end
    if not args[1] or not args[2] then return end

    local function setOrgValue(target)
        local org = target.organism
        if not org then return end
        if isbool(org[args[1]]) then
            org[args[1]] = tonumber(args[2]) ~= 0
        else
            org[args[1]] = tonumber(args[2])
        end
    end

    if args[3] then
        for i, pl in ipairs(player.GetListByName(args[3])) do
            setOrgValue(pl)
        end
    else
        setOrgValue(ply)
    end
end)

concommand.Add("hg_organism_setvalue2", function(ply, cmd, args)
    if not ply:IsAdmin() then return end
    if not args[1] or not args[2] or not args[3] then return end
    local org = ply.organism
    if not org or not org[args[1]] then return end
    org[args[1]][tonumber(args[2])] = tonumber(args[3])
end)

concommand.Add("hg_organism_clear", function(ply, cmd, args)
    if not ply:IsAdmin() then return end
    if args[1] then
        for i, pl in ipairs(player.GetListByName(args[1])) do
            if pl.organism then hg.organism.Clear(pl.organism) end
        end
    else
        if ply.organism then hg.organism.Clear(ply.organism) end
    end
end)

hook.Add("StartCommand","hg_lol", function(ply, cmd)
    if ply.organism and ply.organism.otrub and ply:Alive() then
        cmd:ClearMovement()
    end
end)

hook.Add("PlayerDeath","next-respawn-full", function(ply)
    ply.fullsend = true
end)


local unlucky_dislocations = {
    "Why can't I fix this goddamn dislocation...",
    "Please... why is it so hard.",
    "Just go back in place already...",
    "This is irritating",
    "I should try again",
}
local finally_fixed = {
    "Finally.",
    "That was harder than I thought",
    "One dislocation away.",
}

local function TryFixLimb(org, sLimbKey, pFixer)
    local pOwner = org.owner
    if not IsValid(pOwner) then return end

    local flSuccessChance = 97 + (pFixer ~= pOwner and (pFixer.organism and pFixer.organism.pain or 0) or 0) - (org.analgesia * 50 + (org.painkiller or 0) * 15) - (pFixer ~= pOwner and 30 or 0) - (pFixer.tries or 0) * 10 - (pFixer.Profession == "doctor" and 100 or 0) - (pFixer == pOwner and (IsValid(pOwner.FakeRagdoll) or (pOwner.Crouching and pOwner.Crouching())) and 10 or 0)
    if math_random(100) > flSuccessChance then
        org[sLimbKey.."dislocation"] = false
        org.painadd = (org.painadd or 0) + 5 * math_random(1, 3)
        org.fearadd = (org.fearadd or 0) + 0.1
        pOwner:EmitSound("physics/flesh/flesh_impact_hard6.wav", 65)
        if pFixer == pOwner and (pFixer.tries or 0) > 3 and math_random(3) == 1 then
            pFixer:Notify(finally_fixed[math_random(#finally_fixed)], 1, "dislocations_unlucky", 1, nil, Color(255,255,255,255))
        end
        pFixer.tries = 0
    else
        pFixer.tries = (pFixer.tries or 0) + 1
        org.painadd = (org.painadd or 0) + 15 * math_random(1, 3)
        org.fearadd = (org.fearadd or 0) + 0.3
        pOwner:EmitSound("physics/body/body_medium_impact_soft"..math_random(7)..".wav", 65)
        if pFixer.Profession ~= "doctor" and math_random(5) == 1 then
            local dmg = DamageInfo()
            dmg:SetDamage(50)
            dmg:SetDamageType(DMG_CLUB)
            if hg.organism.input_list and hg.organism.input_list[sLimbKey.."down"] then
                hg.organism.input_list[sLimbKey.."down"](org, 1, 6, dmg, 0, vector_up)
            end
        end
        if pFixer == pOwner and pFixer.tries > 3 and math_random(3) == 1 then
            pFixer:Notify(unlucky_dislocations[math_random(#unlucky_dislocations)], 1, "dislocations_unlucky", 1, nil, Color(255,255,255,255))
        end
    end
end

concommand.Add("hg_fixdislocation", function(pFixer, cmd, args)
    if not IsValid(pFixer) or not pFixer:IsPlayer() then return end
    if not args or not args[1] then return end

    local pTarget = pFixer
    if args[2] and math.Round(tonumber(args[2])) == 1 then
        local tr = hg.eyeTrace(pFixer)
        if IsValid(tr.Entity) and tr.Entity.organism then
            pTarget = tr.Entity
        end
    end

    if not IsValid(pTarget) or not pTarget.organism then return end
    local org = pTarget.organism
    local pOwner = org.owner

    if not pFixer:Alive() or not org or (pFixer.organism and pFixer.organism.otrub) then return end
    if (pFixer.tried_fixing_limb or 0) > CurTime() then return end
    if not pFixer.organism or not pFixer.organism.canmove or not pFixer.organism.canmovehead then return end
    if (pFixer.organism.pain or 0) > 60 then return end
    pFixer.tried_fixing_limb = CurTime() + (pFixer.organism.pain or 0) / 30

    local nLimbType = math.Round(tonumber(args[1]))
    if nLimbType == 1 then
        if org.llegdislocation then TryFixLimb(org, "lleg", pFixer)
        elseif org.rlegdislocation then TryFixLimb(org, "rleg", pFixer) end
    elseif nLimbType == 2 then
        if org.larmdislocation then TryFixLimb(org, "larm", pFixer)
        elseif org.rarmdislocation then TryFixLimb(org, "rarm", pFixer) end
    elseif nLimbType == 3 then
        if org.jawdislocation then TryFixLimb(org, "jaw", pFixer) end
    end
end)


hook.Add("OnEntityWaterLevelChanged", "ClearBlood", function(ent, old, new)
    if new >= 2 then
        if ent:IsOnFire() then ent:Extinguish() end
        ent:RemoveAllDecals()
    end
end)
