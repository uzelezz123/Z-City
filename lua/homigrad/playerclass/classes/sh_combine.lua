
local CLASS = player.RegClass("Combine")


local combine_models = {
    "models/player/combine_soldier.mdl"
}


local callsigns = {
    "Alfa","Bravo","Charlie","Delta","Echo",
    "Foxtrot","Tango","Sierra","Uniform","Kilo","Yankee","Regent",
    "Zulu","Omega","Nova","Viper","Ghost","Raven",
}

local leader_callsigns = {"Leader", "Obliterator", "Overlord", "Director", "Control"}

local CombineSquads = {squads = {}, playerSquad = {}, usedCallsigns = {}, squadSize = 4}

local function GetSquadForCombine(ply)
    for name, data in pairs(CombineSquads.squads) do
        for i = #data.members, 1, -1 do
            local m = data.members[i]
            if not IsValid(m) or m.PlayerClassName ~= "Combine" then table.remove(data.members, i) end
        end
        if #data.members < CombineSquads.squadSize then return name end
    end
    
    local available = {}
    for _, cs in ipairs(callsigns) do
        if not CombineSquads.usedCallsigns[cs] then table.insert(available, cs) end
    end
    if #available == 0 then return callsigns[math.random(#callsigns)] end
    
    local newName = available[math.random(#available)]
    CombineSquads.usedCallsigns[newName] = true
    CombineSquads.squads[newName] = {members = {}, usedNumbers = {}}
    return newName
end

local function AssignCombineCallsign(ply, isLeader)
    if math.random(1, 1000) <= 1 then return "Scug" end
    
    if isLeader then return leader_callsigns[math.random(#leader_callsigns)] .. "-1" end
    
    local squadName = GetSquadForCombine(ply)
    local squad = CombineSquads.squads[squadName]
    if not squad then return callsigns[math.random(#callsigns)] .. "-" .. math.random(10, 99) end
    
    local num
    repeat num = math.random(10, 99) until not squad.usedNumbers[num]
    squad.usedNumbers[num] = true
    table.insert(squad.members, ply)
    CombineSquads.playerSquad[ply] = squadName
    
    return squadName .. "-" .. num
end

local function RemoveCombineFromSquad(ply)
    local name = CombineSquads.playerSquad[ply]
    if not name then return end
    local squad = CombineSquads.squads[name]
    if squad then
        for i, m in ipairs(squad.members) do
            if m == ply then table.remove(squad.members, i) break end
        end
        if #squad.members == 0 then
            CombineSquads.squads[name] = nil
            CombineSquads.usedCallsigns[name] = nil
        end
    end
    CombineSquads.playerSquad[ply] = nil
end

hook.Add("PostCleanupMap", "CombineSquads_Reset", function()
    CombineSquads.squads = {}
    CombineSquads.playerSquad = {}
    CombineSquads.usedCallsigns = {}
end)


local primary_weapons = {
    "weapon_osipr",
    "weapon_mp7",
    "weapon_mp7"
}

--;; Реврайт сабклассов (бай дека)
--;; Теперь можно настроить нормально лодаут,
--;; цвет, модель, дополнительные настройки и т.д.
local combine_subclasses = {
    default = {
        color = Color(0,220,220),
        models = combine_models,
        loadout = {
            {weapon = "weapon_melee"}, --;; ближний бой мясо кишки
            {
                weapon = "weapon_hg_hl2nade_tpik",
                count = 1
            },
            {
                weapon = "weapon_hk_usp",
                ammo_mult = 3
            },

            {
                weapon_random_pool = primary_weapons,
                ammo_mult = 3
            }
        },
    },

    elite = {
        color = Color(246,13,13),
        models = {"models/player/combine_super_soldier.mdl"},
        loadout = {
            {weapon = "weapon_melee"},
            {
                weapon = "weapon_hg_hl2nade_tpik",
                count = 1
            },
            {
                weapon = "weapon_hk_usp",
                ammo_mult = 3
            },
            {
                weapon = "weapon_osipr",
                ammo_mult = 3,
                extra_balls = 3 
            }
        }
    },

    sniper = {
        color = Color(0,220,220),
        models = combine_models,
        loadout = {
            {weapon = "weapon_melee"},
            {
                weapon = "weapon_hg_hl2nade_tpik",
                count = 1
            },
            {
                weapon = "weapon_hk_usp",
                ammo_mult = 3
            },
            {
                weapon = "weapon_combinesniper",
                ammo_mult = 3
            }
        }
    },

    shotgunner = {
        color = Color(220,0,0),
        models = combine_models,
        skin = 1,
        loadout = {
            {weapon = "weapon_melee"},
            {
                weapon = "weapon_hg_flashbang_tpik",
                count = 1
            },
            {
                weapon = "weapon_hk_usp",
                ammo_mult = 3
            },
            {
                weapon = "weapon_breachcharge",
                count = 1
            },
            {
                weapon = "weapon_spas12",
                ammo_mult = 3
            }
        }
    }
}

local combines = {
    "npc_combine_s",
    "npc_strider",
    "npc_metropolice",
    "npc_hunter",
    "npc_rollermine",
    "npc_cscanner",
    "npc_combinegunship",
    "npc_combinedropship",
    "npc_clawscanner",
    "npc_manhack",
    "npc_combine_camera",
    "npc_turret_ceiling",
    "npc_turret_floor"
}

local rebels = {
    "npc_alyx",
    "npc_barney",
    "npc_citizen",
    "npc_eli",
    "npc_fisherman",
    "npc_kleiner",
    "npc_magnusson",
    "npc_mossman",
    "npc_odessa",
    "npc_rollermine_hacked",
    "npc_turret_floor_resistance",
    "npc_vortigaunt"
}

function CLASS.Off(self)
    if CLIENT then return end

	if eightbit and eightbit.EnableEffect and self.UserID then
		eightbit.EnableEffect(self:UserID(), 0)
	end

    RemoveCombineFromSquad(self)

    for k,v in ipairs(ents.FindByClass("npc_*")) do
        if table.HasValue(combines,v:GetClass()) then
            v:AddEntityRelationship( self, D_HT, 99 )
        elseif table.HasValue(rebels,v:GetClass()) then
            v:AddEntityRelationship( self, D_LI, 0 )
        end
    end

	self:SetNWString("PlayerRole", nil)
	self:SetNWString("PlayerName", self.oldname_cmb or self:GetNWString("PlayerName"))
    self.organism.CantCheckPulse = nil
    self.leader = nil
	hook.Remove("OnEntityCreated", "relation_shipdo"..self:EntIndex())
end


CLASS.NoFreeze = true
CLASS.CanEmitRNDSound = false

local function giveSubClassLoadout(ply, subclass)
    local config = combine_subclasses[subclass] or combine_subclasses["default"]
    for _, item in ipairs(config.loadout or {}) do
        if item.weapon_random_pool then
            local randWep = item.weapon_random_pool[math.random(#item.weapon_random_pool)]
            local wep = ply:Give(randWep)
            if wep and item.ammo_mult then
                ply:GiveAmmo(wep:GetMaxClip1() * item.ammo_mult, wep:GetPrimaryAmmoType(), true)
            end
        else
            local wep = ply:Give(item.weapon)
            if wep then
                --;; патрончики
                if item.ammo_mult then
                    ply:GiveAmmo(wep:GetMaxClip1() * item.ammo_mult, wep:GetPrimaryAmmoType(), true)
                end
                --;; пример кастомной какахи 
                if item.count then
                    wep.count = item.count
                end
                if item.extra_balls then
                    wep:SetNWInt("Balls", item.extra_balls)
                end
            end
        end
    end
end

function CLASS.On(self, data)
    if CLIENT then return end

	if eightbit and eightbit.EnableEffect and self.UserID then
		eightbit.EnableEffect(self:UserID(), eightbit.EFF_PROOT) --!! placeholder
	end

    ApplyAppearance(self,nil,nil,nil,true)
    local Appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()
    Appearance.AAttachments = ""
    Appearance.AColthes = ""

    local sub = self.subClass or "default"
    local cfg = combine_subclasses[sub] or combine_subclasses["default"]
    local useModel = cfg.models[math.random(#cfg.models)]
    self:SetModel(useModel)
    self:SetSubMaterial()
    self:SetNetVar("Accessories", "")
    self:SetPlayerColor(cfg.color:ToVector())

    if cfg.skin then
        self:SetSkin(cfg.skin)
    end

    self.organism.CantCheckPulse = true

    --;; Армор
    self.armors = {}
    self.armors["torso"] = "cmb_armor"
    self.armors["head"] = "cmb_helmet"
    self:SyncArmor()

    if not data.bNoEquipment then
        giveSubClassLoadout(self, sub)
    end

    if sub == "elite" then
        self:SetModel("models/player/combine_super_soldier.mdl")
    end

    self.subClass = nil
    self.organism.recoilmul = 0.6

    local isLeader = self.leader or (sub == "elite")
    local callsign = AssignCombineCallsign(self, isLeader)

    self.oldname_cmb = self:GetNWString("PlayerName")
    if zb.GiveRole then zb.GiveRole(self, self.leader and "Leader" or "Soldier", Color(89,230,255)) end
    self:SetNWString("PlayerName", callsign)

    for k,v in ipairs(ents.FindByClass("npc_*")) do
        if table.HasValue(combines,v:GetClass()) then
            v:AddEntityRelationship( self, D_LI, 0 )
            v:ClearEnemyMemory()
        elseif table.HasValue(rebels,v:GetClass()) then
            v:AddEntityRelationship( self, D_HT, 99 )
            v:ClearEnemyMemory()
        end
    end

    local index = self:EntIndex()
    hook.Add( "OnEntityCreated", "relation_shipdo"..index, function( ent )
        if not IsValid(self) then hook.Remove("OnEntityCreated","relation_shipdo"..index) return end
        if ( ent:IsNPC() ) then
            --print(ent:GetClass())
            if table.HasValue(combines,ent:GetClass()) then
                ent:AddEntityRelationship( self, D_LI, 0 )
            end

            if table.HasValue(rebels,ent:GetClass()) then
                ent:AddEntityRelationship( self, D_HT, 99 )
            end
        end
    end )

    self.CurAppearance = appearance
end

function CLASS.Guilt(self, victim)
    if CLIENT then return end

    if victim:GetPlayerClass() == self:GetPlayerClass() then
        return 1
    end
end

function CLASS.PlayerDeath(self)

    for k,v in ipairs(ents.FindByClass("npc_*")) do
        if table.HasValue(combines,v:GetClass()) then
            v:AddEntityRelationship( self, D_HT, 99 )
        elseif table.HasValue(rebels,v:GetClass()) then
            v:AddEntityRelationship( self, D_LI, 0 )
        end
    end

    hook.Remove( "OnEntityCreated", "relation_shipdo"..self:EntIndex())
end

if SERVER then
	local cmb_phrases = {
		"npc/combine_soldier/vo/reportingclear.wav",
		"npc/combine_soldier/vo/ripcordripcord.wav",
		"npc/combine_soldier/vo/reportallpositionsclear.wav",
		"npc/combine_soldier/vo/readyweaponshostilesinbound.wav",
		"npc/combine_soldier/vo/overwatchrequestreserveactivation.wav",
		"npc/combine_soldier/vo/overwatchconfirmhvtcontained.wav",
		"npc/combine_soldier/vo/onedown.wav",
		"npc/combine_soldier/vo/heavyresistance.wav",
		"npc/combine_soldier/vo/containmentproceeding.wav",
		"npc/combine_soldier/vo/contactconfirmprosecuting.wav",
		"npc/combine_soldier/vo/movein.wav",
		"npc/combine_soldier/vo/overwatchteamisdown.wav",
		"npc/combine_soldier/vo/prosecuting.wav",
		"npc/combine_soldier/vo/stayalertreportsightlines.wav",
		"npc/combine_soldier/vo/teamdeployedandscanning.wav",
		"npc/combine_soldier/vo/copythat.wav",
		"npc/combine_soldier/vo/engagedincleanup.wav",
		"npc/combine_soldier/vo/executingfullresponse.wav",
		"npc/combine_soldier/vo/goactiveintercept.wav",
		"npc/combine_soldier/vo/necroticsinbound.wav",
		"npc/combine_soldier/vo/standingby].wav",
		"npc/combine_soldier/vo/stayalert.wav",
		"npc/combine_soldier/vo/targetmyradial.wav",
		"npc/combine_soldier/vo/weareinaninfestationzone.wav",
		"npc/combine_soldier/vo/wehavenontaggedviromes.wav"
	}

	hook.Add("HG_ReplacePhrase", "combine_phrase", function(ply, phrase, muffed, pitch)
		if IsValid(ply) and ply.PlayerClassName == "Combine" then
			return ply, cmb_phrases[math.random(#cmb_phrases)], muffed, pitch
		end
	end)
end

if CLIENT then
    local color_hp = Color(0,255,255,220)
    local color_ar = Color(0,255,255,220)
    local color_glow = Color(15,165,165,0)
    local color_glow_ar = Color(15,165,165,0)
    local color_glow_ammo = Color(15,165,165,0)
    local color_sight = Color(15,165,165,220)
    local color_pulse = Color(15,165,165,220)

    local color_hp2 = Color(165,15,15)
    local color_ar2 = Color(165,15,15)
    local color_glow2 = Color(165,15,15)
    local color_glow_ar2 = Color(165,15,15)
    local color_glow_ammo2 = Color(165,15,15)
    local color_sight2 = Color(165,15,15)
    local color_pulse2 = Color(165,15,15)

    local armor_txt, hp_txt, pulse_txt, stamina_txt, ammo_txt = 0,0,0,0,0
    local bloodlerp, ammolerp = 0,0
    local blood_old, old_hp_txt, old_ar_txt, old_ammo_txt = 5000,0,0,0
    local pos_sight = Vector(ScrW(),ScrH(),0)
    local bg_color = Color(0,0,0,150)
    local armorlerp = 0

    surface.CreateFont("CMBFontDefault",{
        font = "Roboto Light",
        extended = true,
        size = ScreenScale(24),
        weight = 500,
        scanlines = 3,
        antialias = true
    })

    surface.CreateFont("CMBFontSmall",{
        font = "Roboto Light",
        extended = true,
        size = ScreenScale(7.5),
        weight = 1500,
        scanlines = 3,
        antialias = true
    })

    surface.CreateFont("CMBFontSmallBG",{
        font = "Roboto Light",
        extended = true,
        size = ScreenScale(7.5),
        weight = 500,
        blursize = 1,
        scanlines = 3,
        antialias = true
    })

    surface.CreateFont("CMBFontDefaultBG",{
        font = "Roboto Light",
        extended = true,
        size = ScreenScale(24.5),
        weight = 1500,
        blursize = 1,
        scanlines = 3,
        antialias = true
    })

    local function drawGlowingText(txt, font, x, y, col, col_glow, col_glow2, align)
        draw.DrawText(txt, font, x+1, y+1, col_glow, align)
        if col_glow2 then
            draw.DrawText(txt, font, x+2, y+2, col_glow2, align)
        end
        draw.DrawText(txt, font, x, y, col, align)
    end

    local function drawBGPanel(pos_x,pos_y,alpha)
        local size_w, size_h = ScrW()*0.12, ScrH()*0.075
        local pos_w, pos_h = ScrW()*pos_x, ScrH()*pos_y - size_h
        return {pos_w, pos_h}, {size_w, size_h}
    end

    local silentlerp = 0
    local silentclr = Color(0,255,255,220)
    
    function CLASS.HUDPaint(self)
        if not self:Alive() then return end
        local lply = LocalPlayer()
        local frt = FrameTime() * 5
        local role = self:GetNWString("PlayerRole")
        local is_red = (role == "Leader" or role == "Shotgunner" or role == "Elite")

        --;; HP
        do
            local pos, size = drawBGPanel(0.065,0.98)
            surface.SetFont("CMBFontDefault")
            local bloodcount = math.Round(100 * self.organism.blood/5000 , 0)
            local _,txt_size_y = surface.GetTextSize(bloodcount)
            hp_txt = math.min(hp_txt + 1, bloodcount)
            local col_bg = bg_color
            col_bg.a = 225
            draw.DrawText("000","CMBFontDefaultBG",
                pos[1]+size[1]*0.08 + 1,
                pos[2]+(size[2]/2) - txt_size_y/2 + 1,
                col_bg,
                TEXT_ALIGN_RIGHT
            )

            if is_red then
                color_glow2.a = math.Round(Lerp(frt, color_glow2.a, old_hp_txt ~= hp_txt and 255 or 0))
                drawGlowingText(hp_txt, "CMBFontDefault", pos[1]+size[1]*0.08, pos[2]+(size[2]/2) - txt_size_y/2, color_hp2, color_glow2, nil, TEXT_ALIGN_RIGHT)
            else
                color_glow.a = math.Round(Lerp(frt, color_glow.a, old_hp_txt ~= hp_txt and 255 or 0))
                drawGlowingText(hp_txt, "CMBFontDefault", pos[1]+size[1]*0.08, pos[2]+(size[2]/2) - txt_size_y/2, color_hp, color_glow, nil, TEXT_ALIGN_RIGHT)
            end
            old_hp_txt = hp_txt

            draw.DrawText("% | BLOOD","CMBFontSmall",
                pos[1]+size[1]*0.085+1,
                pos[2]+(size[2]/1.8)+1,
                col_bg,
                TEXT_ALIGN_LEFT
            )
            draw.DrawText("% | BLOOD","CMBFontSmall",
                pos[1]+size[1]*0.085,
                pos[2]+(size[2]/1.8),
                is_red and color_hp2 or color_hp,
                TEXT_ALIGN_LEFT
            )
        end

        --;; Пульс
        do
            local pos, size = drawBGPanel(0.035,0.925)
            surface.SetFont("CMBFontSmall")
            local org = self.organism
            if not org or not org.pulse then return end
            local pulse = org.heartbeat
            pulse_txt = math.Round(math.min(pulse_txt + 1, pulse))
            local col_bg = bg_color
            col_bg.a = 225

            draw.DrawText(pulse_txt,"CMBFontSmall",
                pos[1]+size[1]*-0.09,
                pos[2]+(size[2]/2),
                col_bg,
                TEXT_ALIGN_LEFT
            )
            draw.DrawText(pulse_txt,"CMBFontSmall",
                pos[1]+size[1]*-0.095,
                pos[2]+(size[2]/2),
                is_red and color_hp2 or color_hp,
                TEXT_ALIGN_LEFT
            )
            draw.DrawText("| HEART.B/MIN","CMBFontSmall",
                pos[1]+size[1]*0.06 + 1 + 10,
                pos[2]+(size[2]/2)+1,
                col_bg,
                TEXT_ALIGN_LEFT
            )
            draw.DrawText("| HEART.B/MIN","CMBFontSmall",
                pos[1]+size[1]*0.06 + 12,
                pos[2]+(size[2]/2),
                is_red and color_hp2 or color_hp,
                TEXT_ALIGN_LEFT
            )
        end

        --;; Выносливость
        do
            local pos, size = drawBGPanel(0.035,0.895)
            surface.SetFont("CMBFontSmall")
            local org = self.organism
            if not org or not org.stamina then return end
            local stamina = org.stamina[1] or 180
            stamina_txt = math.Round(math.min(stamina_txt + 1, stamina))
            local col_bg = bg_color
            col_bg.a = 225

            draw.DrawText(stamina_txt,"CMBFontSmall",
                pos[1]+size[1]*-0.09,
                pos[2]+(size[2]/2),
                col_bg,
                TEXT_ALIGN_LEFT
            )
            draw.DrawText(stamina_txt,"CMBFontSmall",
                pos[1]+size[1]*-0.095,
                pos[2]+(size[2]/2),
                is_red and color_hp2 or color_hp,
                TEXT_ALIGN_LEFT
            )
            draw.DrawText("| STAMINA","CMBFontSmall",
                pos[1]+size[1]*0.065 + 1 + 10,
                pos[2]+(size[2]/2)+1,
                col_bg,
                TEXT_ALIGN_LEFT
            )
            draw.DrawText("| STAMINA","CMBFontSmall",
                pos[1]+size[1]*0.065 + 12,
                pos[2]+(size[2]/2),
                is_red and color_hp2 or color_hp,
                TEXT_ALIGN_LEFT
            )
        end
        --;; Silent mode
        do
            local pos, size = drawBGPanel(0.5,0.99)
            surface.SetFont("CMBFontSmall")
            silentlerp = LerpFT(0.1,silentlerp,(self:KeyDown(IN_DUCK) or self:KeyDown(IN_WALK)) and 1 or 0)
            local col_bg = bg_color
            col_bg.a = 225*silentlerp
            silentclr.a = 225*silentlerp
            local txt = "SNEAK MODE"
            draw.DrawText(txt,"CMBFontSmall",
                pos[1],
                pos[2]+(size[2]/2),
                col_bg,
                TEXT_ALIGN_CENTER
            )
            draw.DrawText(txt,"CMBFontSmall",
                pos[1],
                pos[2]+(size[2]/2),
                silentclr,
                TEXT_ALIGN_CENTER
            )
        end
        --;; Боезапас
        local wep = self:GetActiveWeapon()
        if IsValid(wep) and wep.Clip1 then
            ammolerp = Lerp(frt,ammolerp,(wep:Clip1() < 0) and 0 or 1)
            local pos, size = drawBGPanel(0.93,0.98)
            surface.SetFont("CMBFontDefault")
            local _,txt_size_y = surface.GetTextSize(self:Armor())
            local col_bg = bg_color
            col_bg.a = 225*ammolerp
            ammo_txt = math.min(ammo_txt + 1, wep:Clip1())

            draw.DrawText("000","CMBFontDefaultBG",
                pos[1]+size[1]*0.08 + 1,
                pos[2]+(size[2]/2) - txt_size_y/2 + 1,
                col_bg,
                TEXT_ALIGN_RIGHT
            )

            if is_red then
                color_glow_ammo2.a = math.Round(Lerp(frt, color_glow_ammo2.a, old_ammo_txt ~= ammo_txt and 255 or 0))
                drawGlowingText(ammo_txt,"CMBFontDefault",
                    pos[1]+size[1]*0.08,
                    pos[2]+(size[2]/2) - txt_size_y/2,
                    color_ar2, color_glow_ammo2, nil, TEXT_ALIGN_RIGHT
                )
            else
                color_glow_ammo.a = math.Round(Lerp(frt, color_glow_ammo.a, old_ammo_txt ~= ammo_txt and 255 or 0))
                drawGlowingText(ammo_txt,"CMBFontDefault",
                    pos[1]+size[1]*0.08,
                    pos[2]+(size[2]/2) - txt_size_y/2,
                    color_ar, color_glow_ammo, nil, TEXT_ALIGN_RIGHT
                )
            end
            old_ammo_txt = ammo_txt

            draw.DrawText("AMMO","CMBFontSmall",
                pos[1]+size[1]*0.085+1,
                pos[2]+(size[2]/1.8)+1,
                col_bg,
                TEXT_ALIGN_LEFT
            )
            draw.DrawText("AMMO","CMBFontSmall",
                pos[1]+size[1]*0.085,
                pos[2]+(size[2]/1.8),
                is_red and color_ar2 or color_ar,
                TEXT_ALIGN_LEFT
            )
        end
    end

    local cmb_mat = Material("sprites/mat_jack_helmoverlay_r")
    hook.Add("RenderScreenspaceEffects","Combine_helmet",function()
        local lply = LocalPlayer()
        if lply:Alive() and lply.PlayerClassName == "Combine" then
            local role = lply:GetNWString("PlayerRole")
            if role == "Elite" or role == "Shotgunner" then
                surface.SetDrawColor(255,25,25,255)
            else
                surface.SetDrawColor(25,190,190,255)
            end
            surface.SetMaterial(cmb_mat)
            surface.DrawTexturedRectRotated(
                (ScrW()/2) - 5,
                (ScrH()/2) - 5,
                ScrW() + 10,
                ScrH() + 450,
                180
            )
            render.PushFilterMag(TEXFILTER.ANISOTROPIC)
            render.PushFilterMin(TEXFILTER.ANISOTROPIC)
                CLASS.HUDPaint(lply)
            render.PopFilterMag()
            render.PopFilterMin()
        end
    end)
end

hook.Add("HG_CanThoughts", "CombineCantDumat", function(ply)
	if ply.PlayerClassName == "Combine" then
		return false
	end
end)

--;; Серверные хуки и звуки шагов/смерти
if SERVER then
    hook.Add("HG_PlayerFootstep","Combine_footsteps",function(ply)
        local chr = hg.GetCurrentCharacter(ply)
        if ply:Alive() and ply.PlayerClassName == "Combine" then
            --;; Если есть ragdoll и т.п.
            ply.CombineLerpedFootStep = LerpFT(0.5,ply.CombineLerpedFootStep or 60, (not ply:IsSprinting() and (ply:KeyDown(IN_DUCK) or ply:KeyDown(IN_WALK))) and 20 or 60)
            if IsValid(ply.FakeRagdoll) and ply:GetNetVar("lastFake") == 0 then return end
            chr:EmitSound("npc/combine_soldier/gear" .. math.random(1,6) .. ".wav",
                ply.CombineLerpedFootStep
            )
        end
    end)

    local hitgroups_sounds = {
        [HITGROUP_STOMACH] = true,
        [HITGROUP_CHEST]   = true,
        [HITGROUP_LEFTARM] = true,
        [HITGROUP_RIGHTARM] = true,
        [HITGROUP_RIGHTLEG] = true,
        [HITGROUP_LEFTLEG]  = true
    }
    hook.Add("HomigradDamage","Combine_painsounds",function(ply, dmgInfo, hitgroup, ent)
        --[[if ply.PlayerClassName == "Combine" then
            ply.painCD = ply.painCD or 0
            if hitgroups_sounds[hitgroup] and ply.painCD < CurTime() and ply.organism and not ply.organism.otrub and ply:Alive() then
                local snd = "npc/combine_soldier/pain" .. math.random(1,3) .. ".wav"
                ent:EmitSound(snd,80,ply.VoicePitch)
                ply.painCD = CurTime() + SoundDuration(snd)
                ply.lastPhr = snd
            end
        end--]]
    end)

    hook.Add("HGReloading","Combine_reloadalert",function(wep)
        local ply = wep:GetOwner()
        if not IsValid(ply) then return end
        local nearPlayers = ents.FindInSphere(ply:GetPos(),300)
        for _,mate in ipairs(nearPlayers) do
            if mate:IsPlayer() and mate ~= ply and mate:Alive() and mate.PlayerClassName == "Combine" then
                if ply:Alive() and not ply.organism.otrub and ply.PlayerClassName == "Combine" and wep.ShellEject ~= "ShotgunShellEject" then
                    local phrase = (math.random(1,2) == 2) and "npc/combine_soldier/vo/coverme.wav" or "npc/combine_soldier/vo/coverhurt.wav"
                    ply:EmitSound(phrase,75,ply.VoicePitch)
                    ply.phrCld = CurTime() + (SoundDuration(phrase) or 0)
                    ply.lastPhr = phrase
                    return
                end
            end
        end
    end)

    util.AddNetworkString("CombineRadioStart")
    util.AddNetworkString("CombineRadioEnd")
    util.AddNetworkString("CombineChatMessage")

    hook.Add("HG_PlayerCanHearPlayersVoice","CombineRadio",function(listener,talker)
        if talker.PlayerClassName == "Combine" and listener.PlayerClassName == "Combine" and talker:Alive() then
            return true,false
        end
    end)

    hook.Add("HG_PlayerSay","CombineChatMessage",function(ply, txtTbl, text)
        if ply.PlayerClassName == "Combine" and ply:Alive() and not ply.organism.otrub then
            ply:EmitSound("npc/metropolice/vo/on1.wav")
        end
    end)
end


if CLIENT then
    local radio_end_sound = Sound("npc/metropolice/vo/off4.wav")
    hook.Add("PlayerStartVoice","CombineRadioStart",function(ply)
        if ply.PlayerClassName == "Combine" and ply:Alive() then
            ply:EmitSound(radio_end_sound)
        end
    end)
    hook.Add("PlayerEndVoice","CombineRadioEnd",function(ply)
        if ply.PlayerClassName == "Combine" and ply:Alive() then
            ply:EmitSound(radio_end_sound)
        end
    end)

    hook.Add("HG_NoSoundproof","CombineNoSoundproof",function(pPly, lply)
        if pPly.PlayerClassName == "Combine" and pPly:Alive() and lply.PlayerClassName == "Combine" and lply:Alive() then
            return true 
        end
    end)
end

if CLIENT then
    local pnv_enabled = false
    local next_toggle_time = 0
    local toggle_cooldown = 1
    local transition_time = 1
    local transition_start = 0
    local transitioning = false
    local pnv_light = nil

    local pnv_color_1 = {
        ["$pp_colour_addr"] = 0,
        ["$pp_colour_addg"] = 0.07,
        ["$pp_colour_addb"] = 0.1,
        ["$pp_colour_brightness"] = 0.01,
        ["$pp_colour_contrast"] = 0.6,
        ["$pp_colour_colour"] = 0.08,
        ["$pp_colour_mulr"] = 0,
        ["$pp_colour_mulg"] = 0.1,
        ["$pp_colour_mulb"] = 0.2
    }
    local pnv_color_2 = {
        ["$pp_colour_addr"] = 0.06,
        ["$pp_colour_addg"] = 0,
        ["$pp_colour_addb"] = 0,
        ["$pp_colour_brightness"] = 0.05,
        ["$pp_colour_contrast"] = 0.6,
        ["$pp_colour_colour"] = 0.08,
        ["$pp_colour_mulr"] = 0.2,
        ["$pp_colour_mulg"] = 0,
        ["$pp_colour_mulb"] = 0
    }

    local function togglePNV()
        local ply = LocalPlayer()
        if ply.PlayerClassName ~= "Combine" or not ply:Alive() then
            if pnv_enabled then
                pnv_enabled = false
                surface.PlaySound("items/nvg_off.wav")
                hook.Remove("RenderScreenspaceEffects","PNV_ColorCorrection")
                if IsValid(pnv_light) then
                    pnv_light:Remove()
                    pnv_light = nil
                end
            end
            return
        end

        pnv_enabled = not pnv_enabled
        transition_start = CurTime()

        if pnv_enabled then
            transitioning = true
            surface.PlaySound("items/nvg_on.wav")
            hook.Add("RenderScreenspaceEffects","PNV_ColorCorrection",function()
                if ply.PlayerClassName ~= "Combine" then return end
                local progress = math.min((CurTime() - transition_start)/transition_time,1)
                local class = ply:GetNWString("PlayerRole")
                local cc = (class == "Elite" or class == "Shotgunner") and table.Copy(pnv_color_2) or table.Copy(pnv_color_1)
                for k,v in pairs(cc) do
                    cc[k] = v * progress
                end
                DrawColorModify(cc)
                DrawBloom(0.1*progress,1*progress,2*progress,2*progress,1*progress,0.4*progress,1,1,1)
                if progress >= 1 then transitioning = false end
            end)
        else
            transitioning = false
            surface.PlaySound("items/nvg_off.wav")
            hook.Remove("RenderScreenspaceEffects","PNV_ColorCorrection")
        end
    end

    hook.Add("RenderScreenspaceEffects","PNV_ColorCorrection",function()
        local ply = LocalPlayer()
        if ply.PlayerClassName ~= "Combine" then return end
        if pnv_enabled then
            local class = ply:GetNWString("PlayerRole")
            local cc = (class == "Elite" or class == "Shotgunner") and pnv_color_2 or pnv_color_1
            DrawColorModify(cc)
            DrawBloom(0.1,0.5,2,2,1,0.4,1,1,1)
        end
    end)

    hook.Add("PreDrawHalos","PNV_Light",function()
        local ply = LocalPlayer()
        if ply.PlayerClassName ~= "Combine" then return end
        if pnv_enabled then
            if not IsValid(pnv_light) then
                pnv_light = ProjectedTexture()
                pnv_light:SetTexture("effects/flashlight001")
                pnv_light:SetBrightness(2)
                pnv_light:SetEnableShadows(false)
                pnv_light:SetConstantAttenuation(0.02)
                pnv_light:SetNearZ(12)
                pnv_light:SetFOV(70)
            end
            pnv_light:SetPos(ply:EyePos())
            pnv_light:SetAngles(ply:EyeAngles())
            pnv_light:Update()
        elseif IsValid(pnv_light) then
            pnv_light:Remove()
            pnv_light = nil
        end
    end)

    hook.Add("Think","PNV_Think",function()
        local ply = LocalPlayer()
        if ply:Alive() and ply.PlayerClassName == "Combine" then
            if input.IsKeyDown(KEY_F) and not gui.IsGameUIVisible() and not IsValid(vgui.GetKeyboardFocus()) and (CurTime() > next_toggle_time) then
                togglePNV()
                next_toggle_time = CurTime() + toggle_cooldown
            end
        end
        if not ply:Alive() and pnv_enabled then togglePNV() end
        if ply.PlayerClassName ~= "Combine" and pnv_enabled then togglePNV() end

        if pnv_enabled and IsValid(pnv_light) then
            pnv_light:SetPos(ply:EyePos())
            pnv_light:SetAngles(ply:EyeAngles())
            pnv_light:Update()
        end
    end)
end


return CLASS
