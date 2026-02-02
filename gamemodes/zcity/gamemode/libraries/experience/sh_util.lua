--
zb = zb or {}

zb.Experience = zb.Experience or {}

zb.Experience.SkillMedals = {
    {
        icon = Material("vgui/mats_jack_awards/pt"),
        name = "Pt",
        skill = { 4.6, 99999999999999 }
    },
    {
        icon = Material("vgui/mats_jack_awards/au"),
        name = "Au",
        skill = { 3.7, 4.6 }
    },
    {
        icon = Material("vgui/mats_jack_awards/pd"),
        name = "Pd",
        skill = { 2.9, 3.7 }
    },
    {
        icon = Material("vgui/mats_jack_awards/ir"),
        name = "Ir",
        skill = { 2.2, 2.9 }
    },
    {
        icon = Material("vgui/mats_jack_awards/os"),
        name = "Os",
        skill = { 1.6, 2.2 }
    },
    {
        icon = Material("vgui/mats_jack_awards/ru"),
        name = "Ru",
        skill = { 1.1, 1.6 }
    },
    {
        icon = Material("vgui/mats_jack_awards/ag"),
        name = "Ag",
        skill = { .7, 1.1 }
    },
    {
        icon = Material("vgui/mats_jack_awards/sn"),
        name = "Sn",
        skill = { .4, .7 }
    },
    {
        icon = Material("vgui/mats_jack_awards/ni"),
        name = "Ni",
        skill = { .2, .4 }
    },
    {
        icon = Material("vgui/mats_jack_awards/cu"),
        name = "Cu",
        skill = { 0, .2 }
    },
}

zb.Experience.Bands = {
    {
        icon = Material("vgui/mats_jack_awards/10"),
        name = "",
        skill = { 15360, 999999999999999999 }
    },
    {
        icon = Material("vgui/mats_jack_awards/9"),
        name = "",
        skill = { 7680, 15360 }
    },
    {
        icon = Material("vgui/mats_jack_awards/8"),
        name = "",
        skill = { 3840, 7680 }
    },
    {
        icon = Material("vgui/mats_jack_awards/7"),
        name = "",
        skill = { 1920, 3840 }
    },
    {
        icon = Material("vgui/mats_jack_awards/6"),
        name = "",
        skill = { 960, 1920 }
    },
    {
        icon = Material("vgui/mats_jack_awards/5"),
        name = "",
        skill = { 480, 960 }
    },
    {
        icon = Material("vgui/mats_jack_awards/4"),
        name = "",
        skill = { 240, 480 }
    },
    {
        icon = Material("vgui/mats_jack_awards/3"),
        name = "",
        skill = { 120, 240 }
    },
    {
        icon = Material("vgui/mats_jack_awards/2"),
        name = "",
        skill = { 60, 120 }
    },
    {
        icon = Material("vgui/mats_jack_awards/1"),
        name = "",
        skill = { 0, 60 }
    },
}

local SHTable = zb.Experience

function zb.Experience.GetAwards( self )
    local skill = self.skill
    local exp = self.exp
    --print(skill,exp)
    --print(MedalTab.skill[1])
    local Medal = nil
    for i = 1, #SHTable.SkillMedals do
        local MedalTab = SHTable.SkillMedals[i]
        if skill >= tonumber( MedalTab.skill[1] ) and skill < tonumber( MedalTab.skill[2] ) then 
            Medal = table.Copy( MedalTab )
            break 
        end
    end

    local Band = nil
    for i = 1, #SHTable.Bands do
        local BandTab = SHTable.Bands[i]
        if exp >= tonumber( BandTab.skill[1] ) and exp < tonumber( BandTab.skill[2] ) then 
            Band = table.Copy( BandTab )
            break 
        end
    end
    

    return Band, Medal
end


local plyMeta = FindMetaTable("Player")

function plyMeta:GetAwards()
    if CLIENT then
        net.Start("zb_xp_get")
            net.WriteEntity(self)
        net.SendToServer()
    end
    return zb.Experience.GetAwards( self )
end

function plyMeta:GetStatVal(dataName, fallback)
    if not CLIENT then return end
    net.Start("get_svPData")
        net.WriteEntity( self )
        net.WriteString( dataName )
    net.SendToServer()
    if self.SvDB and self.SvDB[dataName] then
        return self.SvDB[dataName] 
    end
    return fallback
end

if SERVER then
    util.AddNetworkString("get_svPData")

    net.Receive( "get_svPData", function( len, ply )
        local ent = net.ReadEntity()
        local dataName = net.ReadString()
        if not ent["Get"..dataName] then return end
        net.Start("get_svPData")
            net.WriteEntity( ent )
            net.WriteString( dataName )
            net.WriteFloat( ent["Get"..dataName] and ent["Get"..dataName](ent) or 0 )
        net.Send(ply)
    end)

    hook.Add("PlayerDeath","ZB_GiveKills", function(ply)
        timer.Simple(.1,function()
            if not IsValid(ply) then return end
            local most_harm,biggest_attacker = 0,nil
                --print(ply)
            for attacker,attacker_harm in pairs(zb.HarmDone[ply] or {}) do
                --print(attacker)
                if not IsValid(attacker) then continue end
                if most_harm < attacker_harm then
                    most_harm = attacker_harm
                    biggest_attacker = attacker
                end
            end
            ply:GiveDeaths(1)
            if IsValid(biggest_attacker) then
                if biggest_attacker == ply then
                    biggest_attacker:GiveSuicides(1)
                else
                    biggest_attacker:GiveKills(1)
                end
            end
        end)
    end)
else
    net.Receive( "get_svPData", function()
        local ent = net.ReadEntity()
        local dataName = net.ReadString()
        local dataType = net.ReadFloat()
        ent.SvDB = ent.SvDB or {}
        ent.SvDB[dataName] = dataType
        if zb.Experience.OpenedAccount then
            zb.Experience.OpenedAccount:Udpate(ent)
        end
    end)
end