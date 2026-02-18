hg.DynamicMusicV2 = hg.DynamicMusicV2 or {}
hg.DynamicMusicV2.Trakcs = hg.DynamicMusicV2.Trakcs or {}

--[[
    ["условный трек"] = {
        ["SelectPreset"] = function(ply)
            local intens = 0
            local org = ply.organism
            if org.adrenaline > 0.2 then
                intens = intens + 1
            end

            -- и так далее...
        end,

        ["Presets"] = {
            [1] = {"Название для слоев1"}
            [2] = {
                ["Название для слоев2"] = {volume = 1}, 
                ["Название для слоев4"] = {volume = 1}
            }

            -- думаю понятно...
        },

        ["Layers"] = {
            ["Название для слоев1"] = ".wav .mp3 путь к любому файлу который может сожрать игра",
            ["Название для слоев2"] = ".wav .mp3 путь к любому файлу который может сожрать игра",
            ["Название для слоев3"] = ".wav .mp3 путь к любому файлу который может сожрать игра",
            ["Название для слоев4"] = ".wav .mp3 путь к любому файлу который может сожрать игра",
            ["Название для слоев5"] = ".wav .mp3 путь к любому файлу который может сожрать игра",
        }
    }
--]]

local function basicSelectPreset(ply)
    local intens = 0
    local org = ply.organism
    if org.adrenaline > 0.2 then
        intens = intens + 1
    end

    return intens
end

local function AddTrack(strName, tPresets, tLayers, fSelectPreset, strAuthor, strNormalName, iBPM, fOffset)
    hg.DynamicMusicV2.Trakcs[strName] = {}
    local Track = hg.DynamicMusicV2.Trakcs[strName]

    Track["Presets"] = tPresets
    Track["Layers"] = tLayers
    Track["SelectPreset"] = fSelectPreset or basicSelectPreset
    Track["Author"] = strAuthor or "Unknown"
    Track["Name"] = strNormalName or "Unknown"
    Track["BPM"] = iBPM
    Track["Offset"] = fOffset
end

-- Mr.Point

AddTrack(
    "highrise",
    { -- Presets
        [1] = {
            --["bass"]        = { volume = 1 },
            --["cymbals"]        = { volume = 1 },
            ["hats"]        = { volume = 1 },
            --["kick"]        = { volume = 1 },
            ["perc"]        = { volume = 1 },
            --["piano"]        = { volume = 1 },
            --["pluck"]        = { volume = 1 },
            --["snare"]        = { volume = 1 },
        },
        ["perhod"] = {
            ["kick"]        = { volume = 1 },
        },
        [2] = {
            ["bass"]        = { volume = 1 },
            --["hats"]        = { volume = 1 },
            ["kick"]        = { volume = 3 },
            ["perc"]        = { volume = 1 },
        },
        [3] = {
            ["bass"]        = { volume = 1 },
            ["hats"]        = { volume = 1 },
            ["kick"]        = { volume = 1 },
            ["snare"]        = { volume = 2 },
            --["perc"]        = { volume = 1 },
        }
    },
    { -- Layers
        ["bass"] = "zcity_ost/mrpoint/highrise/highrise_bass.wav",
        ["cymbals"] = "zcity_ost/mrpoint/highrise/highrise_cymbals.wav",
        ["hats"] = "zcity_ost/mrpoint/highrise/highrise_hats.wav",
        ["kick"] = "zcity_ost/mrpoint/highrise/highrise_kick.wav",
        ["perc"] = "zcity_ost/mrpoint/highrise/highrise_perc.wav",
        ["piano"] = "zcity_ost/mrpoint/highrise/highrise_piano.wav",
        ["pluck"] = "zcity_ost/mrpoint/highrise/highrise_pluck.wav",
        ["snare"] = "zcity_ost/mrpoint/highrise/highrise_snare.wav"
    },
    function(ply)
        local intens = 0
        local org = ply.organism
        if !org or !ply:Alive() then return 0 end
        if org.adrenaline > 0.5 then
            intens = intens + 1
        end
        local vehicle = ply.GlideGetVehicle and ply:GlideGetVehicle() or ply:GetVehicle()
        if !IsValid(vehicle) then return intens end
        if vehicle and vehicle:GetVelocity():Length() > 200 then
            intens = intens + 1
        end

        if vehicle and vehicle:GetVelocity():Length() > 600 then
            intens = intens + 1
        end

        return intens
    end,
    "Mr. Point",
    "On The Highrise"
)

AddTrack(
    "breakaleg",
    { -- Presets
        [0] = {
            --["bass"]        = { volume = 1 },
            --["cymbal"]        = { volume = 1 },
            ["hat"]        = { volume = 1 },
            --["hat_lead"]        = { volume = 1 },
            ----["high_snare"]        = { volume = 1 },
            --["kick"]        = { volume = 1 },
            --["percusion"]        = { volume = 1 },
            ["snare"]        = { volume = 1 },
            --["snare_hat"]        = { volume = 1 },
            --["snare_lead"]        = { volume = 1 },
            --["synth"]        = { volume = 3 },
        },
        [1] = {
            --["bass"]        = { volume = 1 },
            --["cymbal"]        = { volume = 1 },
            --["hat"]        = { volume = 1 },
            --["hat_lead"]        = { volume = 1 },
            ----["high_snare"]        = { volume = 1 },
            ["kick"]        = { volume = 2 },
            ["percusion"]        = { volume = 1 },
            ["snare"]        = { volume = 1 },
            --["snare_hat"]        = { volume = 1 },
            --["snare_lead"]        = { volume = 1 },
            --["synth"]        = { volume = 3 },
        },
        [2] = {
            --["bass"]        = { volume = 1 },
            ["cymbal"]        = { volume = 1 },
            ["hat"]        = { volume = 1 },
            ["hat_lead"]        = { volume = 1 },
            --["high_snare"]        = { volume = 1 },
            ["kick"]        = { volume = 3 },
            --["percusion"]        = { volume = 1 },
            ["snare"]        = { volume = 1 },
            --["snare_hat"]        = { volume = 1 },
            --["snare_lead"]        = { volume = 1 },
            --["synth"]        = { volume = 3 },
        },
        [3] = {
            ["bass"]        = { volume = 1 },
            ["cymbal"]        = { volume = 1 },
            ["hat"]        = { volume = 1 },
            ["hat_lead"]        = { volume = 1 },
            --["high_snare"]        = { volume = 1 },
            ["kick"]        = { volume = 3 },
            ["percusion"]        = { volume = 1 },
            ["snare"]        = { volume = 1 },
            --["snare_hat"]        = { volume = 1 },
            --["snare_lead"]        = { volume = 1 },
            --["synth"]        = { volume = 3 },
        },
        [4] = {
            ["bass"]        = { volume = 1 },
            ["cymbal"]        = { volume = 1 },
            ["hat"]        = { volume = 1 },
            ["hat_lead"]        = { volume = 1 },
            ["high_snare"]        = { volume = 1 },
            ["kick"]        = { volume = 3 },
            --["percusion"]        = { volume = 1 },
            ["snare"]        = { volume = 1 },
            --["snare_hat"]        = { volume = 1 },
            --["snare_lead"]        = { volume = 1 },
            --["synth"]        = { volume = 3 },
        },
        [5] = {
            ["bass"]        = { volume = 1 },
            ["cymbal"]        = { volume = 1 },
            ["hat"]        = { volume = 1 },
            ["hat_lead"]        = { volume = 1 },
            --["high_snare"]        = { volume = 1 },
            ["kick"]        = { volume = 3 },
            ["percusion"]        = { volume = 1 },
            ["snare"]        = { volume = 1 },
            --["snare_hat"]        = { volume = 1 },
            --["snare_lead"]        = { volume = 1 },
            ["synth"]        = { volume = 3 },
        },
    },
    { -- Layers
        ["bass"] = "zcity_ost/mrpoint/breakaleg/bass_sidechained.ogg",
        ["cymbal"] = "zcity_ost/mrpoint/breakaleg/cymbal_snare.ogg",
        ["hat"] = "zcity_ost/mrpoint/breakaleg/hat.ogg",
        ["hat_lead"] = "zcity_ost/mrpoint/breakaleg/hat_lead.ogg",
        ["high_snare"] = "zcity_ost/mrpoint/breakaleg/high_snare.ogg",
        ["kick"] = "zcity_ost/mrpoint/breakaleg/kick.ogg",
        ["percusion"] = "zcity_ost/mrpoint/breakaleg/percusion.ogg",
        ["snare"] = "zcity_ost/mrpoint/breakaleg/snare.ogg",
        ["snare_hat"] = "zcity_ost/mrpoint/breakaleg/snare_hat.ogg",
        ["snare_lead"] = "zcity_ost/mrpoint/breakaleg/snare_lead.ogg",
        ["synth"] = "zcity_ost/mrpoint/breakaleg/synth_sidechained.ogg",
    },
    function(ply)
        local intens = 0
        local org = ply.organism
        if (!org or org.otrub) or !ply:Alive() then return -1 end
        if org.fear > 0.1 then
            intens = intens + 1
        end

        if org.fear > 0.6 then
            intens = intens + 1
        end

        if org.adrenaline > 0.1 then
            intens = intens + 1
        end

        if org.adrenaline > 1.5 then
            intens = intens + 1
        end

        if org.adrenaline > 2.5 then
            intens = intens + 1
        end

        return intens
    end,
    "Mr. Point",
    "Break A Leg"
)

AddTrack(
    "overdose",
    { -- Presets
        [0] = {
            --["kick"]        = { volume = 2 },
            --["perc"]        = { volume = 1 },
            --["synth_bass"]        = { volume = 0.5 },
            --["synth_keys"]        = { volume = 2 },
            --["weird"]        = { volume = 2 },
        },
        [1] = {
            --["kick"]        = { volume = 1 },
            --["perc"]        = { volume = 0.5 },
            ["synth_bass"]        = { volume = 0.5 },
            --["synth_keys"]        = { volume = 2 },
            --["weird"]        = { volume = 2 },
        },
        [2] = {
            ["kick"]        = { volume = 1 },
            ["perc"]        = { volume = 0.5 },
            ["synth_bass"]        = { volume = 0.7 },
            --["synth_keys"]        = { volume = 1 },
            --["weird"]        = { volume = 1 },
        },
        [3] = {
            ["kick"]        = { volume = 1 },
            ["perc"]        = { volume = 1 },
            ["synth_bass"]        = { volume = 2 },
            --["synth_keys"]        = { volume = 1 },
            ["weird"]        = { volume = 0.5 },
        },
        [4] = {
            ["kick"]        = { volume = 1 },
            ["perc"]        = { volume = 1 },
            ["synth_bass"]        = { volume = 2 },
            ["synth_keys"]        = { volume = 1 },
            ["weird"]        = { volume = 2 },
        },
        [5] = {
            ["kick"]        = { volume = 2 },
            ["perc"]        = { volume = 1 },
            ["synth_bass"]        = { volume = 2 },
            ["synth_keys"]        = { volume = 1 },
            ["weird"]        = { volume = 2 },
        },
    },
    { -- Layers
        ["kick"] = "zcity_ost/uzelezz/overdose/kick.wav",
        ["perc"] = "zcity_ost/uzelezz/overdose/perc.wav",
        ["synth_bass"] = "zcity_ost/uzelezz/overdose/synth_bass.wav",
        ["synth_keys"] = "zcity_ost/uzelezz/overdose/synth_keys.wav",
        ["weird"] = "zcity_ost/uzelezz/overdose/weird.wav",
    },
    function(ply)
        local intens = 0
        local org = ply.organism
        if (!org or org.otrub) or !ply:Alive() then return -1 end

        -- if org.noradrenaline then
        --     local timediff = SysTime() - hg.noradrenalineStartTime
        --     return org.noradrenaline > 1.5 and 5 or (timediff < 3) and 1 or timediff < 8 and 2 or (org.noradrenaline > 0.6 and 3 or org.noradrenaline > 0.3 and 2 or org.noradrenaline > 0.1 and 1 or 0)
        -- end

        if org.fear > 0.1 then
            intens = intens + 1
        end

        if org.fear > 0.6 then
            intens = intens + 1
        end

        if org.adrenaline > 0.1 then
            intens = intens + 1
        end

        if org.adrenaline > 1.5 then
            intens = intens + 1
        end

        if org.adrenaline > 2.5 then
            intens = intens + 1
        end
        
        return intens
    end,
    "uzelezz",
    "Overdose",
    160,
    0.1
)

AddTrack(
    "final_heartbeat",
    { -- Presets
        [0] = {
            ["kick"]        = { volume = 1 },
            --["cymbal"]        = { volume = 2 },
            --["synth_bass"]        = { volume = 2 },
            --["synth_bass2"]        = { volume = 2 },
            --["synth_perc"]        = { volume = 2 },
            --["ride"]        = { volume = 2 },
            ["keys"]        = { volume = 1 },
        },
        [1] = {
            ["kick"]        = { volume = 2 },
            ["cymbal"]        = { volume = 1 },
            --["synth_bass"]        = { volume = 2 },
            --["synth_bass2"]        = { volume = 2 },
            --["synth_perc"]        = { volume = 2 },
            ["ride"]        = { volume = 1 },
            ["keys"]        = { volume = 2 },
        },
        [2] = {
            ["kick"]        = { volume = 2 },
            ["cymbal"]        = { volume = 2 },
            ["synth_bass"]        = { volume = 2 },
            --["synth_bass2"]        = { volume = 2 },
            --["synth_perc"]        = { volume = 2 },
            ["ride"]        = { volume = 2 },
            ["keys"]        = { volume = 2 },
        },
        [3] = {
            ["kick"]        = { volume = 2 },
            ["cymbal"]        = { volume = 2 },
            --["synth_bass"]        = { volume = 2 },
            ["synth_bass2"]        = { volume = 2 },
            --["synth_perc"]        = { volume = 2 },
            ["ride"]        = { volume = 2 },
            ["keys"]        = { volume = 2 },
        },
    },
    { -- Layers
        ["kick"] = "zcity_ost/uzelezz/final_heartbeat/kick.wav",
        ["cymbal"] = "zcity_ost/uzelezz/final_heartbeat/cymbal.wav",
        ["synth_bass"] = "zcity_ost/uzelezz/final_heartbeat/synth_bass.wav",
        ["synth_bass2"] = "zcity_ost/uzelezz/final_heartbeat/synth_bass2.wav",
        ["synth_perc"] = "zcity_ost/uzelezz/final_heartbeat/synth_perc.wav",
        ["ride"] = "zcity_ost/uzelezz/final_heartbeat/ride.wav",
        ["keys"] = "zcity_ost/uzelezz/final_heartbeat/keys.wav",
    },
    function(ply)
        local intens = 0
        local org = ply.organism
        if (!org or org.otrub) or !ply:Alive() then return -1 end
        
        return 2
    end,
    "uzelezz",
    "Final Heartbeat",
    140,
    0.15
)