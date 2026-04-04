-- sv_moodles.lua
-- Server-side moodle sync template
if not SERVER then return end

util.AddNetworkString("Moodle_Add")
util.AddNetworkString("Moodle_Remove")

local MOODLE_DEBUG = false
local DEBUG_COLOR_SV = Color(255, 150, 0)

if MOODLE_DEBUG then
    print("[Moodles] Server-side system started (DEBUG)")
end

-- Helper for safe numeric reads
local function safeNum(v, fallback)
    if type(v) == "number" then return v end
    if type(v) == "table" and type(v[1]) == "number" then return v[1] end
    return fallback or 0
end

-- Core function to handle state changes and networking
-- Only sends net messages when a state actually changes
local function manageMoodleState(ply, moodle, active, material, count, bypass_cooldown)
    ply.MoodleStates = ply.MoodleStates or {}
    local org = ply.organism
    if org and (org.desensitized or 0) > 0 then
        local desensitized_moodles = {
            ["bleeding"] = 0.2,
            ["hurt"] = 0.3,
            ["pain"] = 0.4,
            ["trauma"] = 0.5,
            ["stimulated"] = 0.6,
            ["encumbered"] = 0.7,
            ["amputation"] = 0.8,
            ["dislocation"] = 0.8,
            ["fracture"] = 0.8,
        }
        local base_id = (moodle:match("(.+)_%d+$") or moodle)
        if desensitized_moodles[base_id] and org.desensitized > desensitized_moodles[base_id] then
            active = false
        end
    end

    local current_moodle = ply.MoodleStates[moodle]
    local changed = (current_moodle ~= nil) ~= active
    local count_changed = active and current_moodle and current_moodle.count ~= (count or 1)

    if changed or count_changed then
        if active then
            ply.MoodleStates[moodle] = { mat = material, count = count or 1 }
            net.Start("Moodle_Add")
            net.WriteString(moodle)
            net.WriteString(material or "")
            net.WriteInt(count or 1, 8)
            net.Send(ply)
        else
            ply.MoodleStates[moodle] = nil
            net.Start("Moodle_Remove")
            net.WriteString(moodle)
            net.Send(ply)
        end
    end
end

local function manageHierarchicalMoodle(ply, baseID, levels, value)
    local active_level = 0
    for i = #levels, 1, -1 do
        local level_info = levels[i]
        if value >= level_info.threshold then
            active_level = i
            break
        end
    end

    for i = 1, #levels do
        local level_info = levels[i]
        local moodleID = baseID .. "_" .. i
        local should_be_active = (i == active_level)
        -- When a moodle is being deactivated as part of a hierarchy change, bypass the cooldown to prevent flickering.
        local bypass_cooldown = (not should_be_active and active_level > 0)
        manageMoodleState(ply, moodleID, should_be_active, level_info.texture, nil, bypass_cooldown)
    end
end

local function ApplyBrainDamageEffects(ply, org)
    local brain_damage = org.brain or 0
    if brain_damage < 0.025 or org.otrub then return end

    -- Increase chance and duration based on brain damage
    local chance = ((brain_damage - 0.025) / 0.975)^2 * 0.8
    if math.random() < chance then
        local fake_moodles = {
            { id = "happy_4", texture = "materials/moodles/Happy_4.png" },
            { id = "energized", texture = "materials/moodles/Energized.png" },
            { id = "pain_4", texture = "materials/moodles/Pain_4.png" },
            { id = "hunger_5", texture = "materials/moodles/Hunger_5.png" },
            { id = "cold_4", texture = "materials/moodles/Cold_4.png" },
            { id = "heat_4", texture = "materials/moodles/Heat_4.png" },
            { id = "trauma_4", texture = "materials/moodles/Trauma_Moodle_4.png" },
            { id = "depression_4", texture = "materials/moodles/Depression_4.png" },
            { id = "faint_2", texture = "materials/moodles/Faint_2.png" },
            { id = "bleeding_4", texture = "materials/moodles/Bleeding_4.png" },
            { id = "fracture_4", texture = "materials/moodles/Fracture_4.png" },
            { id = "bradycardia", texture = "materials/moodles/Bradycardia_Moodle_Animated.png" },
            { id = "tachycardia", texture = "materials/moodles/Tachycardia_Moodle.png" },
            { id = "shock", texture = "materials/moodles/Shock.png" },
            { id = "overdose_4", texture = "materials/moodles/Overdose_Moodle_4.png" },
        }
        local chosen_moodle = fake_moodles[math.random(1, #fake_moodles)]
        
        -- A fake moodle should not have a real counterpart active
        if ply.MoodleStates[chosen_moodle.id] then return end

        -- Check for similar or more severe moodles
        local base_id, level = chosen_moodle.id:match("(.+)_([%d+])")
        if base_id and level then
            level = tonumber(level)
            for existing_moodle_id, _ in pairs(ply.MoodleStates) do
                local existing_base_id, existing_level = existing_moodle_id:match("(.+)_([%d+])")
                if existing_base_id == base_id and existing_level and tonumber(existing_level) >= level then
                    return -- A more severe or equal level moodle is already active
                end
            end
        end

        local fake_id = chosen_moodle.id .. "_fake"
        
        -- Don't stack fake moodles
        if ply.MoodleStates[fake_id] then return end

        manageMoodleState(ply, fake_id, true, chosen_moodle.texture)

        -- Remove after a short, random duration, scaled with brain damage
        local duration = math.Rand(10, 20) + (brain_damage * 30) -- Increased duration and scaling
        timer.Simple(duration, function()
            if not IsValid(ply) then return end
            manageMoodleState(ply, fake_id, false, nil, nil, true) -- Bypass cooldown
        end)
    end
end

-- Main sync function where your custom logic goes
local function SyncMoodles(ply)
    if not IsValid(ply) or not ply:Alive() then return end
    
    ply.MoodleStates = ply.MoodleStates or {}

    -- =======================================================
    -- ACTUAL HOMIGRAD ORGANISM LOGIC
    -- =======================================================
    local org = ply.organism
    if not org then return end

    -- Amputation
    local ampCount = 0
    if org.llegamputated then ampCount = ampCount + 1 end
    if org.rlegamputated then ampCount = ampCount + 1 end
    if org.larmamputated then ampCount = ampCount + 1 end
    if org.rarmamputated then ampCount = ampCount + 1 end
    manageMoodleState(ply, "amputation", ampCount > 0, "materials/moodles/Amputation_Moodle.png", ampCount)

    -- Bleeding
    local bleedRate = org.bleed or 0
    local isArterial = ((org.arteria or 0) + (org.rarmartery or 0) + (org.larmartery or 0) + (org.rlegartery or 0) + (org.llegartery or 0)) > 0
    if isArterial then
        manageMoodleState(ply, "bleeding_4", true, "materials/moodles/Bleeding_4.png")
    else
        manageHierarchicalMoodle(ply, "bleeding", {
            { threshold = 0.01, texture = "materials/moodles/Bleeding_1.png" },
            { threshold = 0.025, texture = "materials/moodles/Bleeding_2.png" },
            { threshold = 0.05, texture = "materials/moodles/Bleeding_3.png" },
            { threshold = 0.065, texture = "materials/moodles/Bleeding_4.png" },
        }, bleedRate)
    end

    -- Hypovolemia (Low Blood Volume)
    local blood = org.blood or 5000
    local blood_loss = 1 - (blood / 5000)
    if blood_loss < 0 then blood_loss = 0 end
    manageHierarchicalMoodle(ply, "hypovolemia", {
        { threshold = 0.05, texture = "materials/moodles/Blood_loss_1.png" },
        { threshold = 0.25, texture = "materials/moodles/Blood_loss_2.png" },
        { threshold = 0.40, texture = "materials/moodles/Blood_loss_3.png" },
        { threshold = 0.55, texture = "materials/moodles/Blood_loss_4.png" },
    }, blood_loss)

    -- Bradycardia & Tachycardia
    local pulse = org.pulse or 70
    manageMoodleState(ply, "bradycardia", pulse < 40, "materials/moodles/Bradycardia_Moodle_Animated.png")
    manageMoodleState(ply, "tachycardia", pulse > 120, "materials/moodles/Tachycardia_Moodle.png")

    -- Brain Damage
    manageHierarchicalMoodle(ply, "brain_damage", {
        { threshold = 0.05, texture = "materials/moodles/Braindamage_Moodle_1.png" },
        { threshold = 0.10, texture = "materials/moodles/Braindamage_Moodle_2.png" },
        { threshold = 0.20, texture = "materials/moodles/Braindamage_Moodle_3.png" },
        { threshold = 0.30, texture = "materials/moodles/Braindamage_Moodle_4_Crit.png" },
    }, org.brain or 0)



    -- Cardiac Arrest
    manageMoodleState(ply, "cardiac_arrest", org.heartstop, "materials/moodles/Cardiacarrest_Moodle.png")

    -- Cold / Heat
    local temperature = org.temperature or 36.7
    manageHierarchicalMoodle(ply, "cold", {
        { threshold = 1.5, texture = "materials/moodles/Cold_1.png" },
        { threshold = 4.5, texture = "materials/moodles/Cold_2.png" },
        { threshold = 6.5, texture = "materials/moodles/Cold_3.png" },
        { threshold = 8.5, texture = "materials/moodles/Cold_4.png" }, 
    }, 36.5 - temperature) -- Invert temperature for cold

    manageHierarchicalMoodle(ply, "heat", {
        { threshold = 37.5, texture = "materials/moodles/Heat_1.png" },
        { threshold = 38.5, texture = "materials/moodles/Heat_2.png" },
        { threshold = 40.0, texture = "materials/moodles/Heat_3.png" },
        { threshold = 42.0, texture = "materials/moodles/Heat_4.png" },
    }, temperature)

    -- Concussion / Critical
    manageMoodleState(ply, "concussion", org.incapacitated and not org.critical, "materials/moodles/Concussion_moodle.png")
    manageMoodleState(ply, "horrified", org.critical, "materials/moodles/HorrifiedMoodle.png")

    -- Tinnitus
    local tinnitus_active = (org.tinnitus_end_time or 0) > CurTime()
    manageMoodleState(ply, "deaf_1", tinnitus_active, "materials/moodles/Deaf_2.png")

    -- Depression (Desensitized)
    local desensitized = org.desensitized or 0
    manageHierarchicalMoodle(ply, "depression", {
        { threshold = 0.25, texture = "materials/moodles/Depression_1.png" },
        { threshold = 0.50, texture = "materials/moodles/Depression_2.png" },
        { threshold = 0.75, texture = "materials/moodles/Depression_3.png" },
        { threshold = 0.95, texture = "materials/moodles/Depression_4.png" },
    }, desensitized)

    -- The mood system was removed, but the happy moodles are still used in other parts of the code.
    -- manageMoodleState(ply, "happy_1", false, nil, nil, true)
    -- manageMoodleState(ply, "happy_2", false, nil, nil, true)
    -- manageMoodleState(ply, "happy_3", false, nil, nil, true)
    -- manageMoodleState(ply, "happy_4", false, nil, nil, true)

    -- Dislocated Spine
    local dislocated_spine = org.spine1dislocation or org.spine2dislocation or org.spine3dislocation
    manageMoodleState(ply, "dislocated_spine", dislocated_spine, "materials/moodles/Dislocated_spine.png")

    -- Partially Broken Spine
    local is_partially_broken = ((org.spine1 > 0.75 and org.spine1 < 1) or (org.spine2 > 0.75 and org.spine2 < 1) or (org.spine3 > 0.75 and org.spine3 < 1))
    manageMoodleState(ply, "partial_spine_break", is_partially_broken, "materials/moodles/Fractured_neck.png")

    -- Broken Spine
    local broken_spine = (org.spine1 == 1) or (org.spine2 == 1) or (org.spine3 == 1)
    manageMoodleState(ply, "fractured_neck", broken_spine, "materials/moodles/Fractured_neck.png")

    local has_jaw = org.jawdislocation
    local has_skull = (org.skull or 0) >= 0.6

    if has_jaw and has_skull then
        manageMoodleState(ply, "dislocated_jaw_and_fractured_skull", true, "materials/moodles/Dislocated_jaw.png")
        manageMoodleState(ply, "dislocated_jaw", false, nil, true)
        manageMoodleState(ply, "fractured_skull", false, nil, true)
    elseif has_jaw then
        manageMoodleState(ply, "dislocated_jaw", true, "materials/moodles/Dislocated_jaw.png")
        manageMoodleState(ply, "dislocated_jaw_and_fractured_skull", false, nil, true)
        manageMoodleState(ply, "fractured_skull", false, nil, true)
    elseif has_skull then
        manageMoodleState(ply, "fractured_skull", true, "materials/moodles/Dislocated_jaw.png")
        manageMoodleState(ply, "dislocated_jaw_and_fractured_skull", false, nil, true)
        manageMoodleState(ply, "dislocated_jaw", false, nil, true)
    else
        manageMoodleState(ply, "dislocated_jaw_and_fractured_skull", false, nil, true)
        manageMoodleState(ply, "dislocated_jaw", false, nil, true)
        manageMoodleState(ply, "fractured_skull", false, nil, true)
    end

    -- Dislocation
    local dislocCount = 0
    if org.llegdislocation then dislocCount = dislocCount + 1 end
    if org.rlegdislocation then dislocCount = dislocCount + 1 end
    if org.larmdislocation then dislocCount = dislocCount + 1 end
    if org.rarmdislocation then dislocCount = dislocCount + 1 end
    manageMoodleState(ply, "dislocation", dislocCount > 0, "materials/moodles/Dislocation_4.png", dislocCount)

    -- Encumbered
    local maxweight = 75 -- You might want to configure this value
    local weightmul = hg.CalculateWeight(ply, maxweight)
    local encumbrance_value = (1 / weightmul) - 1
    manageHierarchicalMoodle(ply, "encumbered", {
        { threshold = 0.25, texture = "materials/moodles/Encumbered_Moodle_1.png" },
        { threshold = 0.5, texture = "materials/moodles/Encumbered_Moodle_2.png" },
        { threshold = 0.75, texture = "materials/moodles/Encumbered_Moodle_3.png" },
        { threshold = 1, texture = "materials/moodles/Encumbered_Moodle_4_Crit.png" },
    }, encumbrance_value)

    -- Endurance
    local stamina = (org.stamina and org.stamina[1]) or 100
    local maxStamina = (org.stamina and org.stamina.max) or 100
    local stPct = stamina / maxStamina
    manageHierarchicalMoodle(ply, "endurance", {
        { threshold = 0.25, texture = "materials/moodles/Endurance_1.png" },
        { threshold = 0.5, texture = "materials/moodles/Endurance_2.png" },
        { threshold = 0.75, texture = "materials/moodles/Endurance_3.png" },
        { threshold = 1, texture = "materials/moodles/Endurance_4.png" },
    }, 1 - stPct)
    manageMoodleState(ply, "energized", stamina > maxStamina * 1.5, "materials/moodles/Energized.png")

    -- Faint (Scaling based on Low Consciousness + Disorientation)
    local consciousness = org.consciousness or 1
    local disorientation = org.disorientation or 0
    local faint_level = 0
    if consciousness < 0.8 or disorientation > 0.1 then faint_level = 1 end
    if consciousness < 0.6 or disorientation > 1 then faint_level = 2 end
    if consciousness < 0.4 or disorientation > 2 then faint_level = 3 end
    if org.otrub and disorientation > 3 then faint_level = 4 end
    manageHierarchicalMoodle(ply, "faint", {
        { threshold = 1, texture = "materials/moodles/Faint_1.png" },
        { threshold = 2, texture = "materials/moodles/Faint_2.png" },
        { threshold = 3, texture = "materials/moodles/Faint_3.png" },
        { threshold = 4, texture = "materials/moodles/Faint_4.png" },
    }, faint_level)

    -- Fight or Flight
    manageMoodleState(ply, "fight_or_flight", (org.adrenaline or 0) > 1, "materials/moodles/FightOrFlight_Moodle.png")

    -- Fractures
    local fracCount = 0
    if (org.lleg or 0) >= 1 then fracCount = fracCount + 1 end
    if (org.rleg or 0) >= 1 then fracCount = fracCount + 1 end
    if (org.larm or 0) >= 1 then fracCount = fracCount + 1 end
    if (org.rarm or 0) >= 1 then fracCount = fracCount + 1 end
    if (org.pelvis or 0) >= 1 then fracCount = fracCount + 1 end
    manageMoodleState(ply, "fracture", fracCount > 0, "materials/moodles/Fracture_4.png", fracCount)
    
    local spine3_thresh = hg and hg.organism and hg.organism.fake_spine3 or 0.8
    manageMoodleState(ply, "fractured_neck", (org.spine3 or 0) >= spine3_thresh, "materials/moodles/Fractured_neck.png")
    manageMoodleState(ply, "fractured_ribs", (org.chest or 0) >= 0.3, "materials/moodles/Fractured_ribs.png")

    -- Hemothorax
    manageMoodleState(ply, "hemothorax", (org.pneumothorax or 0) > 0, "materials/moodles/Hemothorax_Moodle_Animated_Crit.png")

    -- Hunger
    local hunger = org.hungry or 0
    manageHierarchicalMoodle(ply, "hunger", {
        { threshold = 1, texture = "materials/moodles/Hunger_1.png" },
        { threshold = 30, texture = "materials/moodles/Hunger_2.png" },
        { threshold = 60, texture = "materials/moodles/Hunger_3.png" },
        { threshold = 80, texture = "materials/moodles/Hunger_4.png" },
        { threshold = 100, texture = "materials/moodles/Hunger_5.png" },
    }, hunger)

    -- Internal Bleed
    manageMoodleState(ply, "internal_bleed", (org.internalBleed or 0) > 0.1, "materials/moodles/InternalBleed_Moodle_Animated_Crit.png")

    -- Overdose (Using Analgesia/Painkillers as threshold mapping)
    local overdose = org.analgesia or 0
    manageHierarchicalMoodle(ply, "overdose", {
        { threshold = 0.50, texture = "materials/moodles/Overdose_Moodle_1.png" },
        { threshold = 0.75, texture = "materials/moodles/Overdose_Moodle_2.png" },
        { threshold = 0.90, texture = "materials/moodles/Overdose_Moodle_3.png" },
        { threshold = 1.25, texture = "materials/moodles/Overdose_Moodle_4.png" },
    }, overdose)

    -- Oxygen (now includes CO poisoning, as CO2 is not implemented)
    local o2_val = org.o2 and org.o2[1]
    local o2_range = (org.o2 and org.o2.range) or 30
    local o2_pct = (o2_val and o2_range > 0) and (o2_val / o2_range) or 1
    
    local co_level = org.CO or 0
    
    -- A general "bad gas" level. Higher is worse.
    local gas_badness = (1 - o2_pct) + (co_level / 25)

    manageHierarchicalMoodle(ply, "oxygen", {
        { threshold = 0.4, texture = "materials/moodles/Oxygen_Moodle_1.png" },
        { threshold = 0.8, texture = "materials/moodles/Oxygen_Moodle_2.png" },
        { threshold = 1.2, texture = "materials/moodles/Oxygen_Moodle_3.png" },
    }, gas_badness)

    -- Pain
    local pain = org.pain or 0
    manageHierarchicalMoodle(ply, "pain", {
        { threshold = 25, texture = "materials/moodles/Pain_1.png" },
        { threshold = 50, texture = "materials/moodles/Pain_2.png" },
        { threshold = 75, texture = "materials/moodles/Pain_3.png" },
        { threshold = 100, texture = "materials/moodles/Pain_4.png" },
    }, pain)

    -- Respiratory Failure
    local o2_val = org.o2 and org.o2[1]
    local o2_range = org.o2 and org.o2.range
    local o2_pct = (o2_val and o2_range and o2_range > 0) and (o2_val / o2_range) or 1
    manageMoodleState(ply, "respfailure", ((org.trachea or 0) >= 0.5 and o2_pct < 0.9) or org.lungsfunction == false, "materials/moodles/Respfailure.png")

    -- Ripped Eye and Blindness
    local missingEyes = 0
    if org.righteyedestroyed or (org.righteye or 0) >= 1 then missingEyes = missingEyes + 1 end
    if org.lefteyedestroyed or (org.lefteye or 0) >= 1 then missingEyes = missingEyes + 1 end
    local isBlinded = (org.blindness_end_time or 0) > CurTime()
    manageMoodleState(ply, "rippedeye_3", missingEyes == 1, "materials/moodles/Rippedeye_Moodle_3.png")
    manageMoodleState(ply, "rippedeye_4", missingEyes == 2 or isBlinded, "materials/moodles/Rippedeye_Moodle_4.png")

    -- Ripped Jaw
    manageMoodleState(ply, "rippedjaw", (org.jaw or 0) >= 1, "materials/moodles/Rippedjaw_Moodle.png")

    -- Shock
    manageMoodleState(ply, "shock", (org.shock or 0) > 25, "materials/moodles/Shock.png")

    -- Speechless
    local o2_val = org.o2 and org.o2[1]
    local o2_range = org.o2 and org.o2.range
    local o2_pct = (o2_val and o2_range and o2_range > 0) and (o2_val / o2_range) or 1
    manageMoodleState(ply, "speechless", o2_pct < 0.2 or (org.pain or 0) > 80 or (org.brain or 0) > 0.05 or (org.jaw or 0) >= 1 or org.jawdislocation, "materials/moodles/Speechless.png")

    -- Thorax Destroyed
    local is_thorax_destroyed = (org.heart or 0) >= 0.7 or ((org.lungsL and org.lungsL[1] or 0) >= 0.7 or (org.lungsR and org.lungsR[1] or 0) >= 0.7) or (org.trachea or 0) >= 0.7
    manageMoodleState(ply, "thoraxdestroyed", is_thorax_destroyed, "materials/moodles/Thoraxdestroyed_Moodle.png")

    -- Fear
    local fear = org.fear or 0
    manageHierarchicalMoodle(ply, "trauma", {
        { threshold = 0.1, texture = "materials/moodles/Trauma_Moodle_1.png" },
        { threshold = 0.25, texture = "materials/moodles/Trauma_Moodle_2.png" },
        { threshold = 0.5, texture = "materials/moodles/Trauma_Moodle_3.png" },
        { threshold = 0.8, texture = "materials/moodles/Trauma_Moodle_4.png" },
    }, fear)


    -- Unconscious
    manageMoodleState(ply, "unconscious", org.otrub or false, "materials/moodles/Unconscious_Moodle.png")

    -- Sepsis
    manageMoodleState(ply, "sepsis", (org.hemotransfusionshock and (type(org.hemotransfusionshock) == "boolean" or org.hemotransfusionshock > 0)), "materials/moodles/Sepsis_2.png")

    -- Horrified (Noradrenaline/Berserk)
    manageMoodleState(ply, "stimulated", (org.berserk or 0) > 0 or (org.noradrenaline or 0) > 0, "materials/moodles/Stimulated.png")

    if (org.brain or 0) > 0.01 then
        ApplyBrainDamageEffects(ply, org)
    end
end

-- Think loop for periodic syncing
hook.Add("Think", "Moodle_ThinkSync", function()
    local curTime = CurTime()
    local syncInterval = 0.5 -- How often to check states (seconds)
    
    for _, ply in ipairs(player.GetAll()) do
        if not IsValid(ply) then continue end
        
        ply.moodle_last_sync = ply.moodle_last_sync or 0
        if curTime >= ply.moodle_last_sync + syncInterval then
            ply.moodle_last_sync = curTime
            
            local ok, err = pcall(SyncMoodles, ply)
            if not ok and MOODLE_DEBUG then 
                MsgC(DEBUG_COLOR_SV, "[Moodle] Sync error: "..tostring(err).."\n") 
            end
        end
    end
end)

-- Clear moodles on spawn and death
local function ClearMoodles(ply)
    if not IsValid(ply) then return end
    ply.MoodleStates = {}
    net.Start("Moodle_Remove") 
    net.WriteString("*") -- "*" acts as a wildcard to clear all client-side
    net.Send(ply)
end



hook.Add("PlayerDeath", "Moodle_ClearDeath", function(ply)
    ClearMoodles(ply)
end)
