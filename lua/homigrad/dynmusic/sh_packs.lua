--[[
    - добавить все из zcity content dyn-music

--]]
hg = hg or {}
hg.DynaMusic = hg.DynaMusic or {}
local DMusic = hg.DynaMusic

DMusic.MusicMeta = DMusic.MusicMeta or {}
local musMeta = DMusic.MusicMeta

function musMeta:AddMusic( tbl, adrLevel, strPath, volMul, intRepeats )
    if not tbl or not strPath then return end
    tbl[adrLevel] = {strPath, volMul or 1, intRepeats and 1 or nil, intRepeats }
end

local musMetaTbl = {
    ["ambient"] = {},
    ["combat_1"] = {},
}

function musMeta:CreateTbl()
    return table.Copy( musMetaTbl )
end

--

DMusic.Pack = DMusic.Pack or {}

function DMusic:AddPack( strName )
    DMusic.Pack[strName] = {}
end

function DMusic:AddSequence( strPacMusic, strName, tblMusic )
    DMusic.Pack[strPacMusic][strName] = tblMusic
end

-- CreatePack
DMusic:AddPack( "mirrors_edge" )

-- Music
local Music = musMeta:CreateTbl()
musMeta:AddMusic(Music, 0, "zc_dyna_music/medge/a1.mp3", 0.1 )
musMeta:AddMusic(Music, 1, "zc_dyna_music/medge/c1.mp3" )
-- Add2Pack
DMusic:AddSequence( "mirrors_edge", "01", Music )

-- Music
local Music = musMeta:CreateTbl()
musMeta:AddMusic(Music, 0, "zc_dyna_music/medge/a2.mp3", 0.1 )
musMeta:AddMusic(Music, 1, "zc_dyna_music/medge/c2.mp3" )
-- Add2Pack
DMusic:AddSequence( "mirrors_edge", "02", Music )

-- Music
local Music = musMeta:CreateTbl()
musMeta:AddMusic(Music, 0, "zc_dyna_music/medge/a3.mp3", 0.1 )
musMeta:AddMusic(Music, 1, "zc_dyna_music/medge/c4.mp3" )
musMeta:AddMusic(Music, 4, "zc_dyna_music/medge/c3.mp3" )
-- Add2Pack
DMusic:AddSequence( "mirrors_edge", "03", Music )

-- Music
local Music = musMeta:CreateTbl()
musMeta:AddMusic(Music, 0, "zc_dyna_music/medge/a4.mp3", 0.1 )
musMeta:AddMusic(Music, 1, "zc_dyna_music/medge/c6.mp3" )
musMeta:AddMusic(Music, 4, "zc_dyna_music/medge/c5.mp3" )
-- Add2Pack
DMusic:AddSequence( "mirrors_edge", "04", Music )

-- Music
local Music = musMeta:CreateTbl()
musMeta:AddMusic(Music, 0, "zc_dyna_music/medge/a5.mp3", 0.1 )
musMeta:AddMusic(Music, 1, "zc_dyna_music/medge/c6.mp3" )
musMeta:AddMusic(Music, 4, "zc_dyna_music/medge/c7.mp3" )
-- Add2Pack
DMusic:AddSequence( "mirrors_edge", "05", Music )

-- Music
local Music = musMeta:CreateTbl()
musMeta:AddMusic(Music, 0, "zc_dyna_music/medge/a6.mp3", 0.1 )
musMeta:AddMusic(Music, 1, "zc_dyna_music/medge/c10.mp3" )
musMeta:AddMusic(Music, 4, "zc_dyna_music/medge/c9.mp3" )
-- Add2Pack
DMusic:AddSequence( "mirrors_edge", "06", Music )

-- Music
local Music = musMeta:CreateTbl()
musMeta:AddMusic(Music, 0, "zc_dyna_music/medge/a7.mp3", 0.1 )
musMeta:AddMusic(Music, 1, "zc_dyna_music/medge/c9.mp3" )
musMeta:AddMusic(Music, 4, "zc_dyna_music/medge/c10.mp3" )
-- Add2Pack
DMusic:AddSequence( "mirrors_edge", "07", Music )

-- Music
local Music = musMeta:CreateTbl()
musMeta:AddMusic(Music, 0, "zc_dyna_music/medge/a8.mp3", 0.1 )
musMeta:AddMusic(Music, 1, "zc_dyna_music/medge/c12.mp3" )
musMeta:AddMusic(Music, 4, "zc_dyna_music/medge/c13.mp3" )
-- Add2Pack
DMusic:AddSequence( "mirrors_edge", "08", Music )

-- Music
local Music = musMeta:CreateTbl()
musMeta:AddMusic(Music, 0, "zc_dyna_music/medge/a9.mp3", 0.1 )
musMeta:AddMusic(Music, 1, "zc_dyna_music/medge/c15.mp3" )
musMeta:AddMusic(Music, 4, "zc_dyna_music/medge/c14.mp3" )
-- Add2Pack
DMusic:AddSequence( "mirrors_edge", "09", Music )


-- CreatePack
DMusic:AddPack( "swat4" )

for i = 1, 7 do
    -- Music
    local Music = musMeta:CreateTbl()
    musMeta:AddMusic(Music, 0, "zc_dyna_music/swat4/a"..i..".mp3", 0.25 )
    musMeta:AddMusic(Music, 1, "zc_dyna_music/swat4/c"..i..".mp3", 1, 3 )
    -- Add2Pack
    DMusic:AddSequence( "swat4", "0"..i, Music )
end

-- CreatePack
DMusic:AddPack( "hl_coop" )

for i = 1, 15 do
    -- Music
    local Music = musMeta:CreateTbl()
    musMeta:AddMusic(Music, 1, "zc_dyna_music/hl_coop/c"..i..".mp3" )
    -- Add2Pack
    DMusic:AddSequence( "hl_coop", "0"..i, Music )
end

local Music = musMeta:CreateTbl()
musMeta:AddMusic(Music, 1, "zc_dyna_music/hl_coop/c"..(8)..".mp3" )
-- Add2Pack
DMusic:AddSequence( "hl_coop", "0"..(9), Music )

-----------------------------------------------------------------------------------------


-- Splinter Cell pack
DMusic:AddPack( "splinter_cell" )

-- Bank
local Music = musMeta:CreateTbl()
musMeta:AddMusic(Music, 0, "am_music/background/bank(calm).mp3", 0.3 )
musMeta:AddMusic(Music, 0.5, "am_music/suspense/bank(suspense).mp3", 0.7 )
musMeta:AddMusic(Music, 1, "am_music/battle/bank(stress).mp3" )
musMeta:AddMusic(Music, 3, "am_music/battle_intensive/bank(intense).mp3" )
DMusic:AddSequence( "splinter_cell", "Bank", Music )

-- Battery
local Music = musMeta:CreateTbl()
musMeta:AddMusic(Music, 0, "am_music/background/battery(calm).mp3", 0.3 )
musMeta:AddMusic(Music, 0, "am_music/background/battery(calm2).mp3", 0.3 )
musMeta:AddMusic(Music, 0.5, "am_music/suspense/battery(suspense).mp3", 0.7 )
musMeta:AddMusic(Music, 1, "am_music/battle/battery(stress).mp3" )
musMeta:AddMusic(Music, 3, "am_music/battle_intensive/battery(intense).mp3" )
DMusic:AddSequence( "splinter_cell", "Battery", Music )

-- Displace
local Music = musMeta:CreateTbl()
musMeta:AddMusic(Music, 0, "am_music/background/displace(calm).mp3", 0.3 )
musMeta:AddMusic(Music, 0.5, "am_music/suspense/displace(suspense).mp3", 0.7 )
musMeta:AddMusic(Music, 1, "am_music/battle/displace(stress).mp3" )
musMeta:AddMusic(Music, 3, "am_music/battle_intensive/displace(intense).mp3" )
DMusic:AddSequence( "splinter_cell", "Displace", Music )

-- Lighthouse
local Music = musMeta:CreateTbl()
musMeta:AddMusic(Music, 0, "am_music/background/lighthouse(calm).mp3", 0.3 )
musMeta:AddMusic(Music, 0, "am_music/background/lighthouse(calm2).mp3", 0.3 )
musMeta:AddMusic(Music, 0.5, "am_music/suspense/lighthouse(suspense).mp3", 0.7 )
musMeta:AddMusic(Music, 1, "am_music/battle/lighthouse(stress).mp3" )
musMeta:AddMusic(Music, 3, "am_music/battle_intensive/lighthouse(intense).mp3" )
musMeta:AddMusic(Music, 3, "am_music/battle_intensive/lighthouse(intense2).mp3" )
DMusic:AddSequence( "splinter_cell", "Lighthouse", Music )

-- Penthouse
local Music = musMeta:CreateTbl()
musMeta:AddMusic(Music, 0, "am_music/background/penthouse(calm).mp3", 0.3 )
musMeta:AddMusic(Music, 0.5, "am_music/suspense/penthouse(suspense).mp3", 0.7 )
musMeta:AddMusic(Music, 1, "am_music/battle/penthouse(stress).mp3" )
musMeta:AddMusic(Music, 3, "am_music/battle_intensive/penthouse(intense).mp3" )
DMusic:AddSequence( "splinter_cell", "Penthouse", Music )

if SERVER then
    util.AddNetworkString("DMusic")
    function DMusic:AddPanic(ply,ammout)
        net.Start("DMusic")
            net.WriteFloat(ammout)
        net.Send(ply)
    end
elseif CLIENT then
    net.Receive("DMusic",function()
        local ammout = net.ReadFloat()

        DMusic.threaded = DMusic.threaded + ammout
    end)
end

hook.Add("HomigradDamage", "Panic", function(ply, dmgInfo, hitgroup, ent, harm, hitBoxs, inputHole)
    if ent:IsPlayer() then
        --print(ply,dmgInfo:GetDamage()*5)
        hg.DynaMusic:AddPanic(ply,dmgInfo:GetDamage()*25)
        if dmgInfo:GetAttacker():IsPlayer() then
            hg.DynaMusic:AddPanic(dmgInfo:GetAttacker(),dmgInfo:GetDamage()*5)
        end
    end
end)