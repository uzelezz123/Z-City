--[[
    TO-DO
    - Добавить прикольную плажку когда трек включается.
--]]
hg = hg or {}
hg.DynamicMusicV2 = hg.DynamicMusicV2 or {}
hg.DynamicMusicV2.Player = hg.DynamicMusicV2.Player or {}


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

DYNAMIC_MUSIC_PAUSE = 0
DYNAMIC_MUSIC_STOP = -1
DYNAMIC_MUSIC_PLAY = 1

hg.DynamicMusicV2.Player.CurrentTrack = "None"
hg.DynamicMusicV2.Player.State = hg.DynamicMusicV2.Player.State or DYNAMIC_MUSIC_STOP


hg.DynamicMusicV2.Player.Layers = hg.DynamicMusicV2.Player.Layers or {}
local layers = hg.DynamicMusicV2.Player.Layers
local function SetupMusicFile(name, path, callback)
    sound.PlayFile("sound/" .. path, "noplay noblock", function(Channel, Err, ErrStr)
        --print(Channel, Err, ErrStr)
        if IsValid( Channel ) then
            Channel:EnableLooping( true )
            layers[#layers + 1] = {name, Channel}
            callback()
        end
    end)
end

local function GetTrack()
    return hg.DynamicMusicV2.Trakcs and hg.DynamicMusicV2.Trakcs[ hg.DynamicMusicV2.Player.CurrentTrack ]
end

hg.DynamicMusicV2.Player.GetTrack = GetTrack

function hg.DynamicMusicV2.Player.SetupLayers()
    if !IsValid(lply) then return end
    local Track = GetTrack()
    
    if !Track then return end
    
    hg.DynamicMusicV2.Player.Stop(true)
    local amount = table.Count(Track.Layers)
    for k,v in pairs(Track.Layers) do
        SetupMusicFile(k, v, function()
            amount = amount - 1
            --print(amount)
            if amount <= 0 then hg.DynamicMusicV2.Player.Play() end
        end)
    end

    hg.DynamicMusicV2.Player.State = DYNAMIC_MUSIC_PAUSE
end

function hg.DynamicMusicV2.Player.Stop(overide)
    if !IsValid(lply) then return end

    for k,v in ipairs(layers) do
        if !IsValid(v[2]) then continue end
        v[2]:Stop()
    end
    table.Empty(layers)

    if !overide then
        hg.DynamicMusicV2.Player.CurrentTrack = "None"
        hg.DynamicMusicV2.Player.State = DYNAMIC_MUSIC_STOP
    end
end

local function LayerFadeOut(channel)
    if !IsValid(channel) then return end
    local l_volume = LerpFT(0.02, channel:GetVolume(), 0)
    channel:SetVolume(l_volume)
end

local function LayerFade(channel, volume)
    if !IsValid(channel) then return end
    local l_volume = LerpFT(0.02, channel:GetVolume(), volume or 1)
    channel:SetVolume(l_volume)
end

function hg.DynamicMusicV2.Player.Play()
    for i = 1, #layers do
        local layer = layers[i]
        layer[2]:SetVolume( 0 )
        layer[2]:SetTime( 0, true )
        layer[2]:Play()
    end

    hg.DynamicMusicV2.Player.State = DYNAMIC_MUSIC_PLAY
end

function hg.DynamicMusicV2.Player.Start( strTrackName )
    hg.DynamicMusicV2.Player.CurrentTrack = strTrackName or hg.DynamicMusicV2.Player.CurrentTrack
    hg.DynamicMusicV2.Player.SetupLayers()
end

--hg.DynamicMusicV2.Player.Start( "overdose" )
--hg.DynamicMusicV2.Player.Start( "final_heartbeat" )

function hg.DynamicMusicV2.Player.Think()
    if !IsValid(lply) then return end

    if hg.DynamicMusicV2.Player.State != DYNAMIC_MUSIC_PLAY then
        for i = 1, #layers do
            local layer = layers[i]
            LayerFadeOut(layer[2])
        end
    return end

    local Track = GetTrack()

    if !Track then return end

    local Preset = Track["Presets"][Track.SelectPreset(lply)]
    for i = 1, #layers do

        local layer = layers[i]
        local PresetLayer = Preset and Preset[layer[1]] or false
        if PresetLayer then
            LayerFade(layer[2],PresetLayer.volume)
        else
            LayerFadeOut(layer[2])
        end
    end
end

hook.Add("Think", "DynamicMusicV2", hg.DynamicMusicV2.Player.Think)