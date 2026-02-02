--[[ 
    TO-DO:
        - Переход с эмбианта на динамику
        - Синхра с серверным режимом - 
                    coop значит играет hl_coop
                    dm - medge
                    игрок комбайн - combine team и т.д.
        - Конструктор паков музыки (просто функция с добавлением трека в лист :) )
        - Возможность отклюичть музыку.
        - Возможность выбрать пак музыки для режимов где нет определенного класса музыки.
        - Возможность настроить громкость эмбианта
        - Переход музыки зависит от адреналина и полученого дамага - (чтобы милишки тоже это вызвали)
--]]

hg = hg or {}
hg.DynaMusic = hg.DynaMusic or {}
local DMusic = hg.DynaMusic

DMusic.MusicMeta = DMusic.MusicMeta or {}
local musMeta = DMusic.MusicMeta

DMusic.CurrentPack = DMusic.CurrentPack or "mirrors_edge"
DMusic.Tracks = DMusic.Tracks or nil

function DMusic:Start( strPack, strTrack )
    DMusic.CurrentPack = strPack or DMusic.CurrentPack
    DMusic.Tracks = DMusic.Tracks or {}
    for k, v in pairs(DMusic.Tracks) do
        if IsValid(v[1]) then v[1]:Stop() v[1] = nil end
    end
    table.Empty( DMusic.Tracks )
    for k, song in pairs( 
        strTrack and DMusic.Pack[DMusic.CurrentPack][strTrack] or 
        table.Random(DMusic.Pack[DMusic.CurrentPack])
    ) do
        --print(k)
        --PrintTable(song)
        if not song[1] then return end
        sound.PlayFile( "sound/"..song[1] , "noplay noblock", function( station )
            if not IsValid(station) then return end
            DMusic.Tracks[k] = {station, song[2], song[3] or 1, song[4] or 0}
            station:SetVolume(0)
        end)

        --DMusic.Tracks[k]
    end
end

--DMusic:Start( "mirrors_edge" )

DMusic.threaded = 0.0
function DMusic:Stop()
    DMusic.Tracks = DMusic.Tracks or {}
    for k, v in pairs(DMusic.Tracks) do
        if IsValid(v[1]) then v[1]:Stop() v[1] = nil end
    end
    table.Empty( DMusic.Tracks )
    DMusic.threaded = 0
end

local hg_sound = ConVarExists("hg_dmusic") and GetConVar("hg_dmusic") or CreateClientConVar("hg_dmusic","1",true,false,"Enable dynamic music (Enable music in gmod settings)",0,1)

concommand.Add("hg_dmusic_skip",function()
    if not DMusic.Tracks then return end 
    for adr,song in pairs(DMusic.Tracks) do
        song[3] = false
    end
end)
local MusicVolume = GetConVar("snd_musicvolume")
hook.Add( "Think", "DMusic.Think", function()
    if not DMusic.Tracks then return end 
    local ply = LocalPlayer()
    if not ply:Alive() then DMusic.threaded = 0 end
    local i = 1
    local Keys = table.GetKeys(DMusic.Tracks)
    local PlyAdr = (ply.organism and ply.organism.adrenalineAdd) or 0
    local musicVolume = MusicVolume:GetFloat()
    --print(PlyAdr/15)
    --print(math.max(PlyAdr*100,10))
    DMusic.threaded = math.min(DMusic.threaded + FrameTime() * 100 * (PlyAdr / (math.max((PlyAdr*25)-.2,20))),4)
    --print(math.Round(threaded,0.1))

    for adr,song in pairs(DMusic.Tracks) do
        if not ply.organism then song[1]:Pause() return end
        --print(PlyAdr)
        --print(adr,Keys[i])
        --print(song[1],PlyAdr <= Keys[i] and PlyAdr >= adr)
        --print(song[1],PlyAdr <= (Keys[i+1] or math.huge) and PlyAdr >= adr)
        --print(math.Round(threaded,1))
        --print(adr)
        --print(threaded, ( Keys[i+1] or 5 ),threaded < ( Keys[i+1] or 5 ))
        if DMusic.threaded < ( Keys[i+1] or 5 ) and
            DMusic.threaded >= adr and 
            ply:Alive() and not 
            ply.organism.otrub and
            hg_sound:GetBool() and 
            (song[3]) 
        then
            if song[1]:GetTime() > song[1]:GetLength() - 1 then
                --song[3] = song[3] + 1
                if ( song[3] and song[3] >= song[4] ) then
                    song[3] = false
                else
                    song[3] = song[3] + 1
                end
                song[1]:SetTime(1)
                --song[1]:Play()
            end
            if song[1]:GetState() != GMOD_CHANNEL_PLAYING then
                --song[1]:SetTime(0)
                song[1]:Play()
            end
            song[1]:SetVolume( math.min( song[1]:GetVolume() + math.max(DMusic.threaded/1000,0.001), (song[2] or 1) * musicVolume ) )
        else
            if song[1]:GetState() != GMOD_CHANNEL_PAUSED and song[1]:GetVolume() <= 0.01 then
                song[1]:Pause()
                if ( not song[3] ) then
                    DMusic:Start( DMusic.CurrentPack )
                end
                --song[1]:SetTime(0)
            else
                --print(song[1],song[1]:GetVolume())
                song[1]:SetVolume( math.min( song[1]:GetVolume() - ( math.max(DMusic.threaded/1000,0.001) ), (song[2] or 1) * musicVolume) )
            end
        end
        i = i + 1
    end 
    --if PlyAdr < 0.01 then
    DMusic.threaded = math.max(DMusic.threaded - FrameTime()*0.2,0)
    --end
    --print(threaded)
end)