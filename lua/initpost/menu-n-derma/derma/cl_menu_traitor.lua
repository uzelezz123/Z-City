if not hg then return end

local function MenuUnit(num)
    return math.floor(num * math.min(ScrW(), ScrH()) / 1000)
end

local TRAITOR_MENU_FONT = "ZCity_Traitor_Loadout"
local TRAITOR_POINTS_FONT = "ZCity_Traitor_Points"
local TRAITOR_PRESET_BUTTON_HEIGHT = 34
local TRAITOR_LIST_BUTTON_HEIGHT = 38
local TRAITOR_ADDON_BUTTON_HEIGHT = 32
local TRAITOR_BUTTON_SPACING = 4
local TRAITOR_LIST_WIDTH = 0.6
local TRAITOR_HEADER_HEIGHT = 70
local TRAITOR_LIST_SLIDE_SPEED = 10
local TRAITOR_PREVIEW_SLIDE_SPEED = 10
local TRAITOR_CONTENT_FADE_SPEED = 12
local TRAITOR_LIST_START_OFFSET = 80
local TRAITOR_PREVIEW_START_OFFSET = 80

local function CreateTraitorMenuFonts()
    surface.CreateFont(TRAITOR_MENU_FONT, {
        font = "Verily Serif Mono",
        size = ScreenScale(10),
        weight = 400,
        antialias = true
    })

    surface.CreateFont(TRAITOR_POINTS_FONT, {
        font = "Verily Serif Mono",
        size = ScreenScale(12),
        weight = 400,
        antialias = true
    })
end

hook.Add("OnScreenSizeChanged", "ZCity_TraitorLoadout_Fonts", CreateTraitorMenuFonts)
CreateTraitorMenuFonts()

local color_whitey = Color(225, 225, 225, 255)
local clr_verygray = Color(10, 10, 19, 235)
local menu_gradient_right = Color(18, 18, 18, 65)
local clr_1 = Color(100, 100, 100, 35)

local tex_gradient_r = Material("vgui/gradient-r")
local tex_gradient_l = Material("vgui/gradient-l")
local tex_gradient_d = Material("vgui/gradient-d")

local SOUND_TYPEWRITER = "shitty/tap-resonant.wav"
local SOUND_TYPEWRITER_LEVEL = 55
local SOUND_TYPEWRITER_VOLUME = 0.25
local SOUND_TYPEWRITER_PITCH = 102
local SOUND_SETTINGS_CLICK = "shitty/tap_release.wav"
local SOUND_MENU_SELECT = "shitty/tap-resonant.wav"

local function PlayTypewriterSound()
    local ply = LocalPlayer()
    if IsValid(ply) then
        ply:EmitSound(SOUND_TYPEWRITER, SOUND_TYPEWRITER_LEVEL, SOUND_TYPEWRITER_PITCH, SOUND_TYPEWRITER_VOLUME)
        return
    end
    surface.PlaySound(SOUND_TYPEWRITER)
end

local function SetupAnimatedLabel(lbl, text, delay, charSpeed)
    lbl:SetText(string.rep("#", #text))
    lbl:SetMouseInputEnabled(true)
    lbl:SizeToContents()
    lbl.OpenTime = CurTime() + (delay or 0)
    lbl.HoverLerp = 0
    lbl.LineLerp = 0
    lbl.HoverScale = 0.008
    lbl.LabelText = text
    lbl.CharSpeed = charSpeed or 15
end

local function ThinkAnimatedLabel(self)
    local isHovered = self:IsHovered()
    self.HoverLerp = LerpFT(0.2, self.HoverLerp or 0, isHovered and 1 or 0)
    self.LineLerp = LerpFT(0.2, self.LineLerp or 0, isHovered and 1 or 0)

    local elapsed = CurTime() - (self.OpenTime or CurTime())
    local charsToShow = math.floor(math.max(elapsed, 0) * (self.CharSpeed or 15))
    local target = self.LabelText or ""
    local len = #target
    if charsToShow > len then charsToShow = len end

    if self.TypewriterTarget ~= target then
        self.TypewriterTarget = target
        self.LastTypewriterChars = 0
    end

    if charsToShow > 0 and charsToShow > (self.LastTypewriterChars or 0) then
        PlayTypewriterSound()
    end

    self.LastTypewriterChars = charsToShow

    local ntxt = ""
    for i = 1, len do
        if i <= charsToShow then
            ntxt = ntxt .. target:sub(i, i)
        else
            ntxt = ntxt .. "#"
        end
    end

    if self:GetText() ~= ntxt then
        self:SetText(ntxt)
        self:SizeToContents()
    end
end

local function PaintAnimatedLabel(self, w, h)
    local isHovered = self:IsHovered()
    local flash = isHovered and (0.5 + 0.5 * math.sin(CurTime() * 10)) or 0
    local textColor = color_whitey
    local outlineColor = Color(0, 0, 0, 255)

    if isHovered then
        local v = flash * 255
        textColor = Color(v, v, v, 255)
        local inv = 255 - v
        outlineColor = Color(inv, inv, inv, 255)
    end

    surface.SetFont(self:GetFont())
    local tw, th = surface.GetTextSize(self:GetText())
    local scale = 1 + (self.HoverLerp or 0) * (self.HoverScale or 0.02)
    local matrix = Matrix()
    matrix:Translate(Vector(0, h * (1 - scale) * 0.5, 0))
    matrix:Scale(Vector(scale, scale, 1))
    cam.PushModelMatrix(matrix)
    draw.SimpleTextOutlined(self:GetText(), self:GetFont(), 0, h / 2, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, outlineColor)
    if self.LineLerp and self.LineLerp > 0.01 then
        surface.SetDrawColor(255, 255, 255, 255 * self.LineLerp)
        surface.DrawRect(0, h / 2 + th / 2, tw * self.LineLerp, math.max(1, MenuUnit(1)))
    end
    cam.PopModelMatrix()
    return true
end

CreateClientConVar("hmcd_traitor_loadout", "", true, true, "Saved traitor loadout")
CreateClientConVar("hmcd_hero_loadout", "", true, true, "Saved hero loadout")

local RoleConfigs = {
    traitor = {
        title = "TRAITOR",
        buttonTitle = "Traitor",
        maxPoints = 30,
        convar = "hmcd_traitor_loadout",
        saveFile = "zcity_traitor_loadout.txt",
        presetFile = "zcity_traitor_presets.txt",
        skillsets = {
            ["none"] = {cost = 0, name = "None", desc = "You spent time collecting supplies and weapons instead of building a real specialty."},
            ["infiltrator"] = {cost = 15, name = "Infiltrator", desc = "Break necks and disguise as victims."},
            ["assassin"] = {cost = 15, name = "Assassin", desc = "Better gun control and more endurance."},
            ["damned"] = {cost = 30, name = "Damned", desc = "You start with nothing."},
            ["chemist"] = {cost = 10, name = "Chemist", desc = "Detect chemicals in the air."}
        },
        items = {
            ["weapon_p22"] = {cost = 6, name = "Walther P22"},
            ["weapon_taser"] = {cost = 6, name = "Taser"},
            ["weapon_buck200knife"] = {cost = 2, name = "Buck 200 Knife"},
            ["weapon_sogknife"] = {cost = 2, name = "SOG Knife"},
            ["weapon_hg_rgd_tpik"] = {cost = 4, name = "RGD-5 Grenade"},
            ["weapon_adrenaline"] = {cost = 3, name = "Epipen"},
            ["weapon_hg_shuriken"] = {cost = 1, name = "Shuriken"},
            ["weapon_hg_smokenade_tpik"] = {cost = 2, name = "Smoke Grenade"},
            ["weapon_traitor_ied"] = {cost = 5, name = "IED"},
            ["weapon_traitor_ied_shitty"] = {cost = 2, name = "Shitty IED"},
            ["weapon_traitor_poison1"] = {cost = 2, name = "Tetrodotoxin Syringe"},
            ["weapon_traitor_poison2"] = {cost = 2, name = "VX vial"},
            ["weapon_traitor_poison3"] = {cost = 4, name = "Cyanide Canister"},
            ["weapon_traitor_poison4"] = {cost = 2, name = "Curare vial"},
            ["weapon_traitor_poison_consumable"] = {cost = 3, name = "Potassium Cyanide Powder"},
            ["weapon_traitor_suit"] = {cost = 1, name = "Traitor Suit"},
            ["weapon_hg_jam"] = {cost = 1, name = "Door Jam"},
            ["weapon_walkie_talkie"] = {cost = 1, name = "Walkie-Talkie"}
        },
        addons = {
            ["weapon_p22_silencer"] = {cost = 2, name = "P22 Silencer", parent = "weapon_p22"},
            ["weapon_p22_ammo"] = {cost = 2, name = "P22 Extra Ammo", parent = "weapon_p22", desc = "Start with an extra magazine."}
        },
        addonOrder = {
            ["weapon_p22"] = {"weapon_p22_silencer", "weapon_p22_ammo"}
        },
        exclusions = {
            ["weapon_buck200knife"] = {["weapon_sogknife"] = true},
            ["weapon_sogknife"] = {["weapon_buck200knife"] = true}
        },
        defaultPresets = {
            {
                name = "Legacy",
                loadout = {
                    skillset = "none",
                    weapons = {
                        "weapon_p22",
                        "weapon_p22_silencer",
                        "weapon_buck200knife",
                        "weapon_hg_rgd_tpik",
                        "weapon_adrenaline",
                        "weapon_hg_shuriken",
                        "weapon_hg_smokenade_tpik",
                        "weapon_traitor_ied",
                        "weapon_traitor_poison1",
                        "weapon_traitor_suit",
                        "weapon_hg_jam",
                        "weapon_walkie_talkie"
                    }
                }
            },
            {
                name = "Infiltrator",
                loadout = {
                    skillset = "infiltrator",
                    weapons = {
                        "weapon_sogknife",
                        "weapon_adrenaline",
                        "weapon_hg_smokenade_tpik"
                    }
                }
            },
            {
                name = "Assassin",
                loadout = {
                    skillset = "assassin",
                    weapons = {
                        "weapon_p22",
                        "weapon_p22_silencer",
                        "weapon_sogknife",
                        "weapon_adrenaline"
                    }
                }
            },
            {
                name = "Chemist",
                loadout = {
                    skillset = "chemist",
                    weapons = {
                        "weapon_sogknife",
                        "weapon_adrenaline",
                        "weapon_traitor_poison1",
                        "weapon_traitor_poison2",
                        "weapon_traitor_poison3",
                        "weapon_traitor_poison4",
                        "weapon_traitor_poison_consumable"
                    }
                }
            }
        }
    },
    hero = {
        title = "HERO",
        buttonTitle = "Hero",
        maxPoints = 16,
        convar = "hmcd_hero_loadout",
        saveFile = "zcity_hero_loadout.txt",
        presetFile = "zcity_hero_presets.txt",
        items = {
            ["weapon_px4beretta"] = {cost = 4, name = "Beretta PX4", desc = "Reliable sidearm with room for ammo or a suppressor."},
            ["weapon_glock17"] = {cost = 5, name = "Glock 17", desc = "Flexible pistol with strong attachment options."},
            ["weapon_hk_usp"] = {cost = 5, name = "HK USP", desc = "Steady .45 pistol with suppressor support."},
            ["weapon_remington870"] = {cost = 8, name = "Remington 870", desc = "Close range stopper with extra shell support."},
            ["weapon_kar98"] = {cost = 8, name = "Karabiner 98k", desc = "Heavy marksman pick that can take a scope and extra rounds."},
            ["ent_armor_vest3"] = {cost = 4, name = "Kevlar IIIA Vest", icon = "vgui/icons/armor01.png", desc = "Body armor that soaks torso hits."},
            ["ent_armor_helmet1"] = {cost = 2, name = "ACH Helmet III", icon = "vgui/icons/helmet.png", desc = "Ballistic helmet that protects the head."},
            ["ent_armor_helmet7"] = {cost = 2, name = "SSh-68 Helmet", icon = "entities/ent_jack_gmod_ezarmor_ssh68.png", desc = "Steel helmet that protects the head."},
            ["ent_armor_mask1"] = {cost = 2, name = "Ballistic Mask", icon = "vgui/icons/ballisticmask", desc = "Face armor that shields against hits."},
            ["ent_armor_mask2"] = {cost = 2, name = "M40 Gas Mask", icon = "vgui/icons/gasmask", desc = "Face mask offering light protection."},
            ["ent_armor_mask3"] = {cost = 2, name = "Welding Mask", icon = "entities/ent_jack_gmod_ezarmor_weldingkill.png", desc = "Face mask that soaks some hits."},
            ["weapon_vpo209"] = {cost = 12, name = "VPO-209", desc = "Semi-auto carbine chambered in .366 TKM."},
            ["weapon_vpo136"] = {cost = 12, name = "VPO-136", desc = "Semi-auto carbine chambered in 7.62x39mm."},
            ["weapon_mosin"] = {cost = 8, name = "Mosin-Nagant M38", desc = "Bolt-action rifle chambered in 7.62x54mm."}
        },
        addons = {
            ["hero_px4_silencer"] = {cost = 2, name = "PX4 Suppressor", parent = "weapon_px4beretta", attachment = "supressor4", desc = "Keep the PX4 quieter."},
            ["hero_px4_ammo"] = {cost = 2, name = "PX4 Extra Ammo", parent = "weapon_px4beretta", desc = "Start with extra magazine."},
            ["hero_glock_silencer"] = {cost = 2, name = "Glock Suppressor", parent = "weapon_glock17", attachment = "supressor4", desc = "Suppress the Glock 17."},
            ["hero_glock_rmr"] = {cost = 2, name = "Glock RMR", parent = "weapon_glock17", attachment = "holo16", desc = "Adds a compact red dot."},
            ["hero_glock_laser"] = {cost = 1, name = "Glock Laser", parent = "weapon_glock17", attachment = "laser3", desc = "Adds a visible aiming laser."},
            ["hero_glock_ammo"] = {cost = 2, name = "Glock Extra Ammo", parent = "weapon_glock17", desc = "Start with extra magazine."},
            ["hero_usp_silencer"] = {cost = 2, name = "USP Suppressor", parent = "weapon_hk_usp", attachment = "supressor4", desc = "Suppress the USP."},
            ["hero_usp_ammo"] = {cost = 2, name = "USP Extra Ammo", parent = "weapon_hk_usp", desc = "Start with extra magazine."},
            ["hero_remington_ammo"] = {cost = 2, name = "870 Extra Shells", parent = "weapon_remington870", desc = "Start with extra shells."},
            ["hero_kar98_scope"] = {cost = 2, name = "Kar98 Scope", parent = "weapon_kar98", attachment = "optic12", desc = "Adds the Kar98 scope."},
            ["hero_kar98_ammo"] = {cost = 2, name = "Kar98 Extra Ammo", parent = "weapon_kar98", desc = "Start with extra rifle rounds."},
            ["hero_remington_sight"] = {cost = 2, name = "870 Sight", parent = "weapon_remington870", attachment = "holo16", desc = "Adds a sight to the Remington 870."},
            ["hero_vpo209_silencer"] = {cost = 2, name = "VPO-209 Suppressor", parent = "weapon_vpo209", attachment = "supressor1", desc = "Suppress the VPO-209."},
            ["hero_vpo209_optic"] = {cost = 2, name = "VPO-209 Red Dot", parent = "weapon_vpo209", attachment = "holo16", desc = "Adds a red dot sight to the VPO-209."},
            ["hero_vpo209_ammo"] = {cost = 2, name = "VPO-209 Extra Ammo", parent = "weapon_vpo209", desc = "Start with extra magazine."},
            ["hero_vpo136_silencer"] = {cost = 2, name = "VPO-136 Suppressor", parent = "weapon_vpo136", attachment = "supressor1", desc = "Suppress the VPO-136."},
            ["hero_vpo136_optic"] = {cost = 2, name = "VPO-136 Red Dot", parent = "weapon_vpo136", attachment = "holo16", desc = "Adds a red dot sight to the VPO-136."},
            ["hero_vpo136_ammo"] = {cost = 2, name = "VPO-136 Extra Ammo", parent = "weapon_vpo136", desc = "Start with extra magazine."},
            ["hero_mosin_silencer"] = {cost = 2, name = "Mosin Suppressor", parent = "weapon_mosin", attachment = "supressor1", desc = "Suppress the Mosin."},
            ["hero_mosin_scope"] = {cost = 2, name = "Mosin Scope", parent = "weapon_mosin", attachment = "optic12", desc = "Adds a scope to the Mosin."},
            ["hero_mosin_ammo"] = {cost = 2, name = "Mosin Extra Ammo", parent = "weapon_mosin", desc = "Start with extra rounds."}
        },
        addonOrder = {
            ["weapon_px4beretta"] = {"hero_px4_silencer", "hero_px4_ammo"},
            ["weapon_glock17"] = {"hero_glock_silencer", "hero_glock_rmr", "hero_glock_laser", "hero_glock_ammo"},
            ["weapon_hk_usp"] = {"hero_usp_silencer", "hero_usp_ammo"},
            ["weapon_remington870"] = {"hero_remington_sight", "hero_remington_ammo"},
            ["weapon_kar98"] = {"hero_kar98_scope", "hero_kar98_ammo"},
            ["weapon_vpo209"] = {"hero_vpo209_silencer", "hero_vpo209_optic", "hero_vpo209_ammo"},
            ["weapon_vpo136"] = {"hero_vpo136_silencer", "hero_vpo136_optic", "hero_vpo136_ammo"},
            ["weapon_mosin"] = {"hero_mosin_silencer", "hero_mosin_scope", "hero_mosin_ammo"}
        },
        exclusions = {},
        defaultPresets = {
            {
                name = "Street Cop",
                loadout = {
                    weapons = {
                        "weapon_glock17",
                        "hero_glock_rmr",
                        "hero_glock_laser",
                        "hero_glock_ammo"
                    }
                }
            },
            {
                name = "Shotgunner",
                loadout = {
                    weapons = {
                        "weapon_remington870",
                        "hero_remington_ammo",
                        "weapon_walkie_talkie"
                    }
                }
            },
            {
                name = "Hunter",
                loadout = {
                    weapons = {
                        "weapon_kar98",
                        "hero_kar98_scope",
                        "hero_kar98_ammo"
                    }
                }
            }
        }
    }
}

RoleConfigs.hero.items["weapon_walkie_talkie"] = {cost = 1, name = "Walkie-Talkie", desc = "Coordinate with the rest of the round."}

do
    local heroWeaponIds = {
        "weapon_px4beretta",
        "weapon_glock17",
        "weapon_hk_usp",
        "weapon_remington870",
        "weapon_kar98",
        "weapon_vpo209",
        "weapon_vpo136",
        "weapon_mosin"
    }

    for _, weaponId in ipairs(heroWeaponIds) do
        RoleConfigs.hero.exclusions[weaponId] = RoleConfigs.hero.exclusions[weaponId] or {}
        for _, otherId in ipairs(heroWeaponIds) do
            if otherId ~= weaponId then
                RoleConfigs.hero.exclusions[weaponId][otherId] = true
            end
        end
    end

    -- Armor pieces sharing a body placement can't be worn together, so make them mutually exclusive.
    local armorSlots = {
        {"ent_armor_helmet1", "ent_armor_helmet7"},
        {"ent_armor_mask1", "ent_armor_mask2", "ent_armor_mask3"}
    }

    for _, slot in ipairs(armorSlots) do
        for _, armorId in ipairs(slot) do
            RoleConfigs.hero.exclusions[armorId] = RoleConfigs.hero.exclusions[armorId] or {}
            for _, otherId in ipairs(slot) do
                if otherId ~= armorId then
                    RoleConfigs.hero.exclusions[armorId][otherId] = true
                end
            end
        end
    end
end

local function IsArmorItem(id)
    return isstring(id) and string.StartWith(id, "ent_armor_")
end

local function GetSortedIdsByCost(sourceTable)
    local ids = {}
    for id in pairs(sourceTable or {}) do
        table.insert(ids, id)
    end
    table.sort(ids, function(a, b)
        local aInfo = sourceTable[a]
        local bInfo = sourceTable[b]
        if aInfo.cost == bInfo.cost then
            return aInfo.name < bInfo.name
        end
        return aInfo.cost > bInfo.cost
    end)
    return ids
end

for _, config in pairs(RoleConfigs) do
    config.itemOrder = GetSortedIdsByCost(config.items)
    config.skillsetOrder = GetSortedIdsByCost(config.skillsets)
end

local function HasWeaponConflict(config, selectedWeapons, weaponId)
    local exclusions = config.exclusions and config.exclusions[weaponId]
    if exclusions then
        for _, selectedId in ipairs(selectedWeapons) do
            if selectedId ~= weaponId and exclusions[selectedId] then
                return true
            end
        end
    end

    for _, selectedId in ipairs(selectedWeapons) do
        if selectedId ~= weaponId then
            local selectedExclusions = config.exclusions and config.exclusions[selectedId]
            if selectedExclusions and selectedExclusions[weaponId] then
                return true
            end
        end
    end

    return false
end

local function ReadSavedLoadout(config)
    if config.saveFile then
        local data = file.Read(config.saveFile, "DATA")
        if data and data ~= "" then
            local ok, parsed = pcall(util.JSONToTable, data)
            if ok and istable(parsed) then
                return parsed
            end
        end
    end
    local savedData = GetConVar(config.convar):GetString()
    if savedData and savedData ~= "" then
        local ok, parsed = pcall(util.JSONToTable, savedData)
        if ok and istable(parsed) then
            return parsed
        end
    end
    return {}
end

local function SanitizeLoadout(config, rawLoadout)
    local normalizedLoadout = {weapons = {}}
    if config.skillsets then
        normalizedLoadout.skillset = "none"
    end

    if type(rawLoadout) ~= "table" then
        rawLoadout = {}
    end

    if config.skillsets and type(rawLoadout.skillset) == "string" and config.skillsets[rawLoadout.skillset] then
        normalizedLoadout.skillset = rawLoadout.skillset
    end

    local totalPoints = 0
    if config.skillsets and config.skillsets[normalizedLoadout.skillset] then
        totalPoints = config.skillsets[normalizedLoadout.skillset].cost
    end

    local usedWeapons = {}
    local rawWeaponIds = {}
    if type(rawLoadout.weapons) == "table" then
        for k, v in pairs(rawLoadout.weapons) do
            local weaponId
            if type(v) == "string" then
                weaponId = v
            elseif type(k) == "string" and v == true then
                weaponId = k
            end

            if weaponId and not usedWeapons[weaponId] and (config.items[weaponId] or config.addons[weaponId]) then
                usedWeapons[weaponId] = true
                table.insert(rawWeaponIds, weaponId)
            end
        end
    end

    usedWeapons = {}
    for _, weaponId in ipairs(rawWeaponIds) do
        local baseInfo = config.items[weaponId]
        if baseInfo and not usedWeapons[weaponId] and not HasWeaponConflict(config, normalizedLoadout.weapons, weaponId) then
            local weaponCost = baseInfo.cost
            if totalPoints + weaponCost <= config.maxPoints then
                usedWeapons[weaponId] = true
                table.insert(normalizedLoadout.weapons, weaponId)
                totalPoints = totalPoints + weaponCost
            end
        end
    end

    for _, weaponId in ipairs(rawWeaponIds) do
        local addonInfo = config.addons[weaponId]
        if addonInfo and not usedWeapons[weaponId] and usedWeapons[addonInfo.parent] then
            local weaponCost = addonInfo.cost
            if totalPoints + weaponCost <= config.maxPoints then
                usedWeapons[weaponId] = true
                table.insert(normalizedLoadout.weapons, weaponId)
                totalPoints = totalPoints + weaponCost
            end
        end
    end

    return normalizedLoadout
end

local function GetLoadoutPoints(config, loadout)
    local currentPoints = 0

    for _, wep in pairs(loadout.weapons or {}) do
        if config.items[wep] then
            currentPoints = currentPoints + config.items[wep].cost
        elseif config.addons[wep] then
            currentPoints = currentPoints + config.addons[wep].cost
        end
    end

    if config.skillsets and config.skillsets[loadout.skillset] then
        currentPoints = currentPoints + config.skillsets[loadout.skillset].cost
    end

    return currentPoints
end

local RoleState = {}

for roleId, config in pairs(RoleConfigs) do
    RoleState[roleId] = {
        loadout = SanitizeLoadout(config, ReadSavedLoadout(config))
    }
end

local function SaveLoadout(roleId)
    local config = RoleConfigs[roleId]
    local state = RoleState[roleId]
    state.loadout = SanitizeLoadout(config, state.loadout)
    local dataStr = util.TableToJSON(state.loadout)
    if not isstring(dataStr) or dataStr == "" then
        dataStr = "{\"weapons\":[]}"
        if config.skillsets then
            dataStr = "{\"weapons\":[],\"skillset\":\"none\"}"
        end
    end

    if config.saveFile then
        file.Write(config.saveFile, dataStr)
    end

    local cv = GetConVar(config.convar)
    if cv then
        cv:SetString(dataStr)
    end
end

for roleId in pairs(RoleConfigs) do
    SaveLoadout(roleId)
end

local function CloseToMainMenu(panel)
    if not IsValid(panel) then return end

    local luaMenu = panel:GetParent()
    panel:AlphaTo(0, 0.2, 0, function()
        if IsValid(panel) then
            panel:Remove()
        end
    end)

    if not IsValid(luaMenu) then
        return
    end

    for _, child in ipairs(luaMenu:GetChildren()) do
        if child ~= panel then
            child:SetVisible(true)
            child:AlphaTo(255, 0.2, 0)
        end
    end

    if luaMenu.panelparrent then
        luaMenu.panelparrent = vgui.Create("DPanel", luaMenu)
        luaMenu.panelparrent:SetPos(0, 0)
        luaMenu.panelparrent:SetSize(ScrW(), ScrH())
        luaMenu.panelparrent:MoveToFront()
        luaMenu.panelparrent:SetMouseInputEnabled(false)
        luaMenu.panelparrent.Paint = function() end
    end

    if luaMenu.ResetCurrentPanel then
        luaMenu:ResetCurrentPanel()
    end
end

local function OpenRoleEditor(parentPanel, roleId, returnPanel)
    local host = IsValid(parentPanel:GetParent()) and parentPanel:GetParent() or parentPanel
    local editorPanel = vgui.Create("DPanel", host)
    editorPanel:SetPos(0, 0)
    editorPanel:SetSize(ScrW(), ScrH())
    editorPanel:MoveToFront()
    editorPanel.ReturnToPanel = returnPanel
    returnPanel:SetVisible(false)
    returnPanel:SetAlpha(0)
    editorPanel:SetMouseInputEnabled(true)

    local config = RoleConfigs[roleId]
    local state = RoleState[roleId]

    editorPanel:SetAlpha(0)
    editorPanel.Paint = function(self, w, h)
        if hg.DrawBlur then
            hg.DrawBlur(self, 5)
        end
        draw.RoundedBox(0, 0, 0, w, h, clr_verygray)
        surface.SetDrawColor(menu_gradient_right)
        surface.SetMaterial(tex_gradient_r)
        surface.DrawTexturedRect(0, 0, w, h)
        surface.SetDrawColor(clr_verygray)
        surface.SetMaterial(tex_gradient_l)
        surface.DrawTexturedRect(0, 0, w, h)
        surface.SetDrawColor(clr_1)
        surface.SetMaterial(tex_gradient_d)
        surface.DrawTexturedRect(0, 0, w, h)
    end
    editorPanel:AlphaTo(255, 0.15, 0)

    local sw, sh = ScrW(), ScrH()
    local sidebarWidth = math.floor(sw / 3.6)
    local sidebar = vgui.Create("DPanel", editorPanel)
    sidebar:SetSize(sidebarWidth, sh)
    sidebar:SetPos(-sidebarWidth, 0)
    sidebar.TargetX = 0
    sidebar.Think = function(self)
        local curX, curY = self:GetPos()
        if math.abs(curX - self.TargetX) > 0.5 then
            self:SetPos(Lerp(FrameTime() * 8, curX, self.TargetX), curY)
        else
            self:SetPos(self.TargetX, curY)
        end
    end
    sidebar.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(10, 10, 15, 120))
        surface.SetDrawColor(color_whitey.r, color_whitey.g, color_whitey.b, 90)
        surface.DrawRect(w - MenuUnit(1), 0, MenuUnit(1), h)
    end

    local sidebarHeader = vgui.Create("DPanel", sidebar)
    sidebarHeader:Dock(TOP)
    sidebarHeader:SetTall(MenuUnit(TRAITOR_HEADER_HEIGHT))
    sidebarHeader.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(15, 15, 20, 120))
        surface.SetDrawColor(color_whitey.r, color_whitey.g, color_whitey.b, 140)
        surface.DrawRect(0, h - MenuUnit(1), w, MenuUnit(1))
    end

    local sidebarHeaderTitle = vgui.Create("DLabel", sidebarHeader)
    sidebarHeaderTitle:SetPos(MenuUnit(15), MenuUnit(18))
    sidebarHeaderTitle:SetFont("ZCity_Medium")
    sidebarHeaderTitle:SetTextColor(color_whitey)
    sidebarHeaderTitle:SetText(config.title)
    sidebarHeaderTitle:SizeToContents()
    sidebarHeaderTitle.OpenTime = CurTime()
    sidebarHeaderTitle.TargetText = config.title
    function sidebarHeaderTitle:Think()
        local elapsed = CurTime() - (self.OpenTime or CurTime())
        local charsToShow = math.floor(elapsed * 18)
        local target = self.TargetText or ""
        local len = #target
        if charsToShow > len then charsToShow = len end
        if self.TypewriterTarget ~= target then
            self.TypewriterTarget = target
            self.LastTypewriterChars = 0
        end
        if charsToShow > 0 and charsToShow > (self.LastTypewriterChars or 0) then
            PlayTypewriterSound()
        end
        self.LastTypewriterChars = charsToShow
        local ntxt = ""
        for i = 1, len do
            if i <= charsToShow then
                ntxt = ntxt .. target:sub(i, i)
            else
                ntxt = ntxt .. "#"
            end
        end
        if self:GetText() ~= ntxt then
            self:SetText(ntxt)
            self:SizeToContents()
        end
    end

    local backBtn = vgui.Create("DLabel", sidebar)
    backBtn:Dock(BOTTOM)
    backBtn:DockMargin(MenuUnit(15), MenuUnit(2), 0, MenuUnit(20))
    backBtn:SetFont("ZCity_Medium")
    backBtn:SetTextColor(color_whitey)
    backBtn:SetTall(MenuUnit(42))
    SetupAnimatedLabel(backBtn, "<- Return", 0.1, 15)
    function backBtn:DoClick()
        surface.PlaySound(SOUND_SETTINGS_CLICK)
        if IsValid(editorPanel.ReturnToPanel) then
            local returnPanel = editorPanel.ReturnToPanel
            editorPanel:AlphaTo(0, 0.2, 0, function()
                if IsValid(editorPanel) then
                    editorPanel:Remove()
                end
            end)
            returnPanel:SetVisible(true)
            returnPanel:AlphaTo(255, 0.2, 0)
            return
        end
        CloseToMainMenu(editorPanel)
    end
    backBtn.Think = ThinkAnimatedLabel
    backBtn.Paint = PaintAnimatedLabel

    local clearBtn = vgui.Create("DLabel", sidebar)
    clearBtn:Dock(BOTTOM)
    clearBtn:DockMargin(MenuUnit(15), MenuUnit(2), 0, MenuUnit(4))
    clearBtn:SetFont("ZCity_Medium")
    clearBtn:SetTextColor(color_whitey)
    clearBtn:SetTall(MenuUnit(42))
    SetupAnimatedLabel(clearBtn, "Clear All", 0, 15)

    local UpdateUI

    function clearBtn:DoClick()
        surface.PlaySound(SOUND_SETTINGS_CLICK)
        local emptyLoadout = {weapons = {}}
        if config.skillsets then
            emptyLoadout.skillset = "none"
        end
        state.loadout = SanitizeLoadout(config, emptyLoadout)
        SaveLoadout(roleId)
        if UpdateUI then
            UpdateUI()
        end
    end
    clearBtn.Think = ThinkAnimatedLabel
    clearBtn.Paint = PaintAnimatedLabel

    local presetsScroll = vgui.Create("DScrollPanel", sidebar)
    presetsScroll:Dock(FILL)
    local sbar = presetsScroll:GetVBar()
    sbar:SetHideButtons(true)
    function sbar:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 80))
    end
    function sbar.btnGrip:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(100, 100, 100, 150))
    end

    local function LoadUserPresets()
        local data = file.Read(config.presetFile, "DATA")
        if data then
            return util.JSONToTable(data) or {}
        end
        return {}
    end

    local function SaveUserPresets(presets)
        file.Write(config.presetFile, util.TableToJSON(presets))
    end

    local function RefreshPresetsUI()
        presetsScroll:Clear()

        local lblTitlePresets = vgui.Create("DLabel", presetsScroll)
        lblTitlePresets:Dock(TOP)
        lblTitlePresets:SetText("DEFAULT PRESETS")
        lblTitlePresets:SetFont(TRAITOR_MENU_FONT)
        lblTitlePresets:SetTextColor(Color(255, 255, 255, 150))
        lblTitlePresets:SetContentAlignment(5)
        lblTitlePresets:SizeToContentsY()
        lblTitlePresets:DockMargin(0, MenuUnit(10), 0, MenuUnit(5))

        for _, preset in ipairs(config.defaultPresets or {}) do
            local btn = vgui.Create("DButton", presetsScroll)
            btn:Dock(TOP)
            btn:SetTall(MenuUnit(TRAITOR_PRESET_BUTTON_HEIGHT))
            btn:DockMargin(MenuUnit(5), 0, MenuUnit(5), MenuUnit(2))
            btn:SetText(preset.name)
            btn:SetFont(TRAITOR_MENU_FONT)
            btn:SetTextColor(Color(200, 255, 200))
            btn.Paint = function(s, w, h)
                local bgColor = s:IsHovered() and Color(50, 80, 50, 150) or Color(30, 30, 30, 150)
                draw.RoundedBox(0, 0, 0, w, h, bgColor)
                surface.SetDrawColor(200, 200, 200, 50)
                surface.DrawOutlinedRect(0, 0, w, h)
            end
            btn.DoClick = function()
                state.loadout = SanitizeLoadout(config, table.Copy(preset.loadout or {}))
                SaveLoadout(roleId)
                UpdateUI()
                surface.PlaySound(SOUND_MENU_SELECT)
            end
        end

        local lblCustomPresets = vgui.Create("DLabel", presetsScroll)
        lblCustomPresets:Dock(TOP)
        lblCustomPresets:SetText("CUSTOM PRESETS")
        lblCustomPresets:SetFont(TRAITOR_MENU_FONT)
        lblCustomPresets:SetTextColor(Color(255, 255, 255, 150))
        lblCustomPresets:SetContentAlignment(5)
        lblCustomPresets:SizeToContentsY()
        lblCustomPresets:DockMargin(0, MenuUnit(10), 0, MenuUnit(5))

        local userPresets = LoadUserPresets()
        local btnCreate = vgui.Create("DButton", presetsScroll)
        btnCreate:Dock(TOP)
        btnCreate:SetTall(MenuUnit(TRAITOR_PRESET_BUTTON_HEIGHT))
        btnCreate:DockMargin(MenuUnit(5), 0, MenuUnit(5), MenuUnit(5))
        btnCreate:SetText("+ SAVE CURRENT AS PRESET")
        btnCreate:SetFont(TRAITOR_MENU_FONT)
        btnCreate:SetTextColor(Color(255, 255, 255))
        btnCreate.Paint = function(s, w, h)
            local bgColor = s:IsHovered() and Color(100, 100, 100, 150) or Color(30, 30, 30, 150)
            draw.RoundedBox(0, 0, 0, w, h, bgColor)
            surface.SetDrawColor(200, 200, 200, 50)
            surface.DrawOutlinedRect(0, 0, w, h)
        end
        btnCreate.DoClick = function()
            Derma_StringRequest("New Preset", "Enter a name for the new preset:", "Custom Preset " .. (#userPresets + 1), function(text)
                table.insert(userPresets, {name = text, loadout = table.Copy(state.loadout)})
                SaveUserPresets(userPresets)
                RefreshPresetsUI()
                surface.PlaySound(SOUND_MENU_SELECT)
            end)
        end

        for i, preset in ipairs(userPresets) do
            local pnl = vgui.Create("DPanel", presetsScroll)
            pnl:Dock(TOP)
            pnl:SetTall(MenuUnit(TRAITOR_PRESET_BUTTON_HEIGHT))
            pnl:DockMargin(MenuUnit(5), 0, MenuUnit(5), MenuUnit(2))
            pnl.Paint = function(s, w, h)
                draw.RoundedBox(0, 0, 0, w, h, Color(30, 30, 30, 150))
                surface.SetDrawColor(200, 200, 200, 50)
                surface.DrawOutlinedRect(0, 0, w, h)
            end

            local lblName = vgui.Create("DLabel", pnl)
            lblName:Dock(LEFT)
            lblName:DockMargin(MenuUnit(5), 0, 0, 0)
            lblName:SetText(preset.name)
            lblName:SetFont(TRAITOR_MENU_FONT)
            lblName:SetTextColor(Color(255, 255, 255))
            lblName:SizeToContentsX()

            local btnDelete = vgui.Create("DButton", pnl)
            btnDelete:Dock(RIGHT)
            btnDelete:SetWide(MenuUnit(30))
            btnDelete:SetText("X")
            btnDelete:SetFont(TRAITOR_MENU_FONT)
            btnDelete:SetTextColor(Color(255, 100, 100))
            btnDelete.Paint = function(s, w, h)
                if s:IsHovered() then
                    draw.RoundedBox(0, 0, 0, w, h, Color(255, 0, 0, 50))
                end
            end
            btnDelete.DoClick = function()
                table.remove(userPresets, i)
                SaveUserPresets(userPresets)
                RefreshPresetsUI()
                surface.PlaySound(SOUND_MENU_SELECT)
            end

            local btnLoad = vgui.Create("DButton", pnl)
            btnLoad:Dock(RIGHT)
            btnLoad:SetText("LOAD")
            btnLoad:SetFont(TRAITOR_MENU_FONT)
            btnLoad:SetTextColor(Color(200, 255, 200))
            btnLoad:SizeToContentsX()
            btnLoad:SetWide(btnLoad:GetWide() + MenuUnit(10))
            btnLoad.Paint = function(s, w, h)
                if s:IsHovered() then
                    draw.RoundedBox(0, 0, 0, w, h, Color(0, 255, 0, 50))
                end
            end
            btnLoad.DoClick = function()
                state.loadout = SanitizeLoadout(config, table.Copy(preset.loadout or {}))
                SaveLoadout(roleId)
                UpdateUI()
                surface.PlaySound(SOUND_MENU_SELECT)
            end
        end
    end

    RefreshPresetsUI()

    local contentPanel = vgui.Create("DPanel", editorPanel)
    contentPanel:SetPos(sidebarWidth, 0)
    contentPanel:SetSize(sw - sidebarWidth, sh)
    contentPanel.Paint = function() end

    local listsContainer = vgui.Create("DPanel", contentPanel)
    listsContainer:Dock(FILL)
    listsContainer:DockMargin(MenuUnit(20), 0, MenuUnit(20), MenuUnit(20))
    listsContainer.Paint = function() end
    listsContainer.AnimInit = false

    local loadoutScroll = vgui.Create("DScrollPanel", listsContainer)
    local lsbar = loadoutScroll:GetVBar()
    lsbar:SetHideButtons(true)
    function lsbar:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 80))
    end
    function lsbar.btnGrip:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(200, 200, 200, 150))
    end

    local previewPanel = vgui.Create("DPanel", listsContainer)
    previewPanel.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 180))
        surface.SetDrawColor(200, 200, 200, 50)
        surface.DrawOutlinedRect(0, 0, w, h)
    end

    local lblPoints = vgui.Create("DLabel", previewPanel)
    lblPoints:Dock(BOTTOM)
    lblPoints:SetFont(TRAITOR_POINTS_FONT)
    lblPoints:SetTextColor(Color(255, 255, 255))
    lblPoints:SetContentAlignment(9)
    lblPoints:SizeToContentsY()
    lblPoints:DockMargin(0, 0, MenuUnit(14), MenuUnit(12))
    lblPoints:SetAlpha(0)

    loadoutScroll:SetAlpha(0)
    previewPanel:SetAlpha(0)

    listsContainer.Think = function(self)
        local w, h = self:GetSize()
        if w <= 0 or h <= 0 then return end

        local gap = MenuUnit(20)
        local minPanelW = MenuUnit(180)
        local maxListW = w - gap - minPanelW
        if maxListW < minPanelW then
            maxListW = minPanelW
        end

        local listW = math.Clamp(math.floor(w * TRAITOR_LIST_WIDTH), minPanelW, maxListW)
        local previewW = math.max(0, w - listW - gap)

        loadoutScroll:SetSize(listW, h)
        previewPanel:SetSize(previewW, h)

        local baseListX, baseListY = 0, 0
        local basePrevX, basePrevY = listW + gap, 0

        if not self.AnimInit then
            loadoutScroll:SetPos(baseListX, h + MenuUnit(TRAITOR_LIST_START_OFFSET))
            previewPanel:SetPos(basePrevX + previewW + MenuUnit(TRAITOR_PREVIEW_START_OFFSET), basePrevY)
            self.AnimInit = true
        end

        local _, listY = loadoutScroll:GetPos()
        loadoutScroll:SetPos(baseListX, Lerp(FrameTime() * TRAITOR_LIST_SLIDE_SPEED, listY, baseListY))

        local prevX = previewPanel:GetPos()
        previewPanel:SetPos(Lerp(FrameTime() * TRAITOR_PREVIEW_SLIDE_SPEED, prevX, basePrevX), basePrevY)

        loadoutScroll:SetAlpha(math.Clamp(Lerp(FrameTime() * TRAITOR_CONTENT_FADE_SPEED, loadoutScroll:GetAlpha(), 255), 0, 255))
        previewPanel:SetAlpha(math.Clamp(Lerp(FrameTime() * TRAITOR_CONTENT_FADE_SPEED, previewPanel:GetAlpha(), 255), 0, 255))
        lblPoints:SetAlpha(previewPanel:GetAlpha())
    end

    local lblPreviewName = vgui.Create("DLabel", previewPanel)
    lblPreviewName:Dock(TOP)
    lblPreviewName:DockMargin(0, MenuUnit(10), 0, 0)
    lblPreviewName:SetFont(TRAITOR_MENU_FONT)
    lblPreviewName:SetTextColor(Color(255, 255, 255))
    lblPreviewName:SetContentAlignment(5)
    lblPreviewName:SetText("Hover over an item")
    lblPreviewName:SizeToContentsY()

    local lblPreviewDesc = vgui.Create("DLabel", previewPanel)
    lblPreviewDesc:Dock(FILL)
    lblPreviewDesc:DockMargin(MenuUnit(10), MenuUnit(10), MenuUnit(10), MenuUnit(10))
    lblPreviewDesc:SetFont(TRAITOR_MENU_FONT)
    lblPreviewDesc:SetTextColor(Color(200, 200, 200))
    lblPreviewDesc:SetContentAlignment(7)
    lblPreviewDesc:SetWrap(true)
    lblPreviewDesc:SetText("")

    local previewIconMat = nil
    local iconPanel = vgui.Create("DPanel", previewPanel)
    iconPanel:Dock(TOP)
    iconPanel:SetTall(MenuUnit(200))
    iconPanel:DockMargin(MenuUnit(10), MenuUnit(10), MenuUnit(10), 0)
    iconPanel.Paint = function(pnl, w, h)
        if not previewIconMat then return end
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(previewIconMat)
        local matW = math.max(previewIconMat:Width(), 1)
        local matH = math.max(previewIconMat:Height(), 1)
        local iconScale = math.min(w / matW, h / matH)
        local iconW = matW * iconScale
        local iconH = matH * iconScale
        local iconX = (w - iconW) * 0.5
        local iconY = (h - iconH) * 0.5
        surface.DrawTexturedRect(iconX, iconY, iconW, iconH)
    end

    local function UpdatePreview(id, isSkill)
        previewIconMat = nil

        if isSkill then
            local info = config.skillsets[id]
            if info then
                lblPreviewName:SetText(info.name .. " (" .. info.cost .. " pts)")
                lblPreviewDesc:SetText(info.desc or "")
            end
            return
        end

        local info = config.items[id] or config.addons[id]
        if not info then return end

        lblPreviewName:SetText(info.name .. " (" .. info.cost .. " pts)")

        local desc = info.desc or "No description available."
        local swep = weapons.GetStored(id)
        if swep then
            if isstring(swep.Instructions) and swep.Instructions ~= "" then
                desc = swep.Instructions
            end
            if swep.WepSelectIcon then
                if isstring(swep.WepSelectIcon) and swep.WepSelectIcon ~= "" then
                    previewIconMat = Material(swep.WepSelectIcon)
                elseif type(swep.WepSelectIcon) == "IMaterial" then
                    previewIconMat = swep.WepSelectIcon
                end
            end
            if not previewIconMat and isstring(swep.IconOverride) and swep.IconOverride ~= "" then
                previewIconMat = Material(swep.IconOverride)
            end
        elseif info.attachment and hg.attachmentsIcons and hg.attachmentsIcons[info.attachment] then
            previewIconMat = Material(hg.attachmentsIcons[info.attachment])
        end

        if not previewIconMat and isstring(info.icon) and info.icon ~= "" then
            previewIconMat = Material(info.icon)
        end

        lblPreviewDesc:SetText(desc)
    end

    UpdateUI = function()
        loadoutScroll:Clear()
        state.loadout = SanitizeLoadout(config, state.loadout)

        local currentPoints = GetLoadoutPoints(config, state.loadout)
        lblPoints:SetText("POINTS: " .. currentPoints .. " / " .. config.maxPoints)
        lblPoints:SetTextColor(Color(255, 255, 255))

        local function AddCategory(title)
            local catLbl = vgui.Create("DLabel", loadoutScroll)
            catLbl:SetText(title)
            catLbl:SetFont(TRAITOR_MENU_FONT)
            catLbl:SetTextColor(Color(220, 220, 220))
            catLbl:Dock(TOP)
            catLbl:DockMargin(0, MenuUnit(10), 0, MenuUnit(5))
            catLbl:SizeToContentsY()
        end

        if config.skillsets and next(config.skillsets) then
            AddCategory("SKILLSETS")
            for _, id in ipairs(config.skillsetOrder) do
                local info = config.skillsets[id]
                local btn = vgui.Create("DButton", loadoutScroll)
                btn:Dock(TOP)
                btn:SetTall(MenuUnit(TRAITOR_LIST_BUTTON_HEIGHT))
                btn:DockMargin(0, 0, 0, MenuUnit(TRAITOR_BUTTON_SPACING))
                btn:SetText("")
                btn.Paint = function(s, w, h)
                    local isSelected = state.loadout.skillset == id
                    local bgColor = isSelected and Color(100, 100, 100, 150) or Color(30, 30, 30, 150)
                    if s:IsHovered() then
                        bgColor = Color(150, 150, 150, 150)
                    end
                    draw.RoundedBox(0, 0, 0, w, h, bgColor)
                    surface.SetDrawColor(200, 200, 200, 50)
                    surface.DrawOutlinedRect(0, 0, w, h)
                    draw.SimpleText(info.name .. " (" .. info.cost .. " pts)", TRAITOR_MENU_FONT, MenuUnit(10), h / 2, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    if isSelected then
                        draw.SimpleText("EQUIPPED", TRAITOR_MENU_FONT, w - MenuUnit(10), h / 2, Color(100, 255, 100), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                    end
                end
                btn.OnCursorEntered = function()
                    UpdatePreview(id, true)
                end
                btn.DoClick = function()
                    local oldSkillset = state.loadout.skillset
                    local oldCost = config.skillsets[oldSkillset] and config.skillsets[oldSkillset].cost or 0
                    local costDiff = info.cost - oldCost
                    if currentPoints + costDiff > config.maxPoints then
                        surface.PlaySound("buttons/button10.wav")
                        return
                    end
                    state.loadout.skillset = id
                    SaveLoadout(roleId)
                    UpdateUI()
                    surface.PlaySound(SOUND_MENU_SELECT)
                end
            end
        end

        local function AddItemButton(id)
            local info = config.items[id]
            local btn = vgui.Create("DButton", loadoutScroll)
            btn:Dock(TOP)
            btn:SetTall(MenuUnit(TRAITOR_LIST_BUTTON_HEIGHT))
            btn:DockMargin(0, 0, 0, MenuUnit(TRAITOR_BUTTON_SPACING))
            btn:SetText("")
            btn.Paint = function(s, w, h)
                local isSelected = table.HasValue(state.loadout.weapons, id)
                local isDisabled = not isSelected and HasWeaponConflict(config, state.loadout.weapons, id)
                local bgColor = isSelected and Color(100, 100, 100, 150) or Color(30, 30, 30, 150)
                if s:IsHovered() and not isDisabled then
                    bgColor = Color(150, 150, 150, 150)
                end
                draw.RoundedBox(0, 0, 0, w, h, bgColor)
                surface.SetDrawColor(200, 200, 200, 50)
                surface.DrawOutlinedRect(0, 0, w, h)
                draw.SimpleText(info.name .. " (" .. info.cost .. " pts)", TRAITOR_MENU_FONT, MenuUnit(10), h / 2, isDisabled and Color(160, 160, 160) or Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                if isDisabled then
                    draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 190))
                end
                if isSelected then
                    draw.SimpleText("EQUIPPED", TRAITOR_MENU_FONT, w - MenuUnit(10), h / 2, Color(100, 255, 100), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                end
            end
            btn.OnCursorEntered = function()
                UpdatePreview(id, false)
            end
            btn.DoClick = function()
                local isDisabled = not table.HasValue(state.loadout.weapons, id) and HasWeaponConflict(config, state.loadout.weapons, id)
                if isDisabled then
                    surface.PlaySound("buttons/button10.wav")
                    return
                end
                if table.HasValue(state.loadout.weapons, id) then
                    table.RemoveByValue(state.loadout.weapons, id)
                    local addonOrder = config.addonOrder[id]
                    if addonOrder then
                        for _, addonId in ipairs(addonOrder) do
                            table.RemoveByValue(state.loadout.weapons, addonId)
                        end
                    end
                else
                    if currentPoints + info.cost > config.maxPoints then
                        surface.PlaySound("buttons/button10.wav")
                        return
                    end
                    table.insert(state.loadout.weapons, id)
                end
                SaveLoadout(roleId)
                UpdateUI()
                surface.PlaySound(SOUND_MENU_SELECT)
            end

            local addonOrder = config.addonOrder[id]
            if addonOrder and table.HasValue(state.loadout.weapons, id) then
                for _, addonId in ipairs(addonOrder) do
                    local addonInfo = config.addons[addonId]
                    if addonInfo then
                        local addonBtn = vgui.Create("DButton", loadoutScroll)
                        addonBtn:Dock(TOP)
                        addonBtn:SetTall(MenuUnit(TRAITOR_ADDON_BUTTON_HEIGHT))
                        addonBtn:DockMargin(MenuUnit(20), 0, 0, MenuUnit(TRAITOR_BUTTON_SPACING))
                        addonBtn:SetText("")
                        addonBtn.Paint = function(s, w, h)
                            local isSelected = table.HasValue(state.loadout.weapons, addonId)
                            local bgColor = isSelected and Color(100, 100, 100, 150) or Color(25, 25, 25, 150)
                            if s:IsHovered() then
                                bgColor = Color(140, 140, 140, 150)
                            end
                            draw.RoundedBox(0, 0, 0, w, h, bgColor)
                            surface.SetDrawColor(200, 200, 200, 40)
                            surface.DrawOutlinedRect(0, 0, w, h)
                            draw.SimpleText("↳ " .. addonInfo.name .. " (" .. addonInfo.cost .. " pts)", TRAITOR_MENU_FONT, MenuUnit(10), h / 2, Color(235, 235, 235), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                            if isSelected then
                                draw.SimpleText("EQUIPPED", TRAITOR_MENU_FONT, w - MenuUnit(10), h / 2, Color(100, 255, 100), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                            end
                        end
                        addonBtn.OnCursorEntered = function()
                            UpdatePreview(addonId, false)
                        end
                        addonBtn.DoClick = function()
                            if not table.HasValue(state.loadout.weapons, id) then
                                surface.PlaySound("buttons/button10.wav")
                                return
                            end
                            if table.HasValue(state.loadout.weapons, addonId) then
                                table.RemoveByValue(state.loadout.weapons, addonId)
                            else
                                if currentPoints + addonInfo.cost > config.maxPoints then
                                    surface.PlaySound("buttons/button10.wav")
                                    return
                                end
                                table.insert(state.loadout.weapons, addonId)
                            end
                            SaveLoadout(roleId)
                            UpdateUI()
                            surface.PlaySound(SOUND_MENU_SELECT)
                        end
                    end
                end
            end
        end

        AddCategory("WEAPONS & ITEMS")
        for _, id in ipairs(config.itemOrder) do
            if not IsArmorItem(id) then
                AddItemButton(id)
            end
        end

        local hasArmor = false
        for _, id in ipairs(config.itemOrder) do
            if IsArmorItem(id) then
                hasArmor = true
                break
            end
        end

        if hasArmor then
            AddCategory("ARMOR")
            for _, id in ipairs(config.itemOrder) do
                if IsArmorItem(id) then
                    AddItemButton(id)
                end
            end
        end
    end

    UpdateUI()
end

function hg.DrawLoadoutMenu(parentPanel)
    parentPanel:SetAlpha(0)
    parentPanel.Paint = function(self, w, h)
        if hg.DrawBlur then
            hg.DrawBlur(self, 5)
        end
        draw.RoundedBox(0, 0, 0, w, h, clr_verygray)
        surface.SetDrawColor(menu_gradient_right)
        surface.SetMaterial(tex_gradient_r)
        surface.DrawTexturedRect(0, 0, w, h)
        surface.SetDrawColor(clr_verygray)
        surface.SetMaterial(tex_gradient_l)
        surface.DrawTexturedRect(0, 0, w, h)
        surface.SetDrawColor(clr_1)
        surface.SetMaterial(tex_gradient_d)
        surface.DrawTexturedRect(0, 0, w, h)
    end
    parentPanel:AlphaTo(255, 0.15, 0)

    local sw, sh = ScrW(), ScrH()

    local header = vgui.Create("DLabel", parentPanel)
    header:SetFont("ZCity_Medium")
    header:SetTextColor(color_whitey)
    header:SetPos(MenuUnit(48), MenuUnit(44))
    header:SetText("LOADOUT")
    header:SizeToContents()
    header.OpenTime = CurTime()
    header.TargetText = "LOADOUT"
    function header:Think()
        local elapsed = CurTime() - (self.OpenTime or CurTime())
        local charsToShow = math.floor(elapsed * 18)
        local target = self.TargetText or ""
        local len = #target
        if charsToShow > len then charsToShow = len end
        if self.TypewriterTarget ~= target then
            self.TypewriterTarget = target
            self.LastTypewriterChars = 0
        end
        if charsToShow > 0 and charsToShow > (self.LastTypewriterChars or 0) then
            PlayTypewriterSound()
        end
        self.LastTypewriterChars = charsToShow
        local ntxt = ""
        for i = 1, len do
            if i <= charsToShow then
                ntxt = ntxt .. target:sub(i, i)
            else
                ntxt = ntxt .. "#"
            end
        end
        if self:GetText() ~= ntxt then
            self:SetText(ntxt)
            self:SizeToContents()
        end
    end

    local subtitle = vgui.Create("DLabel", parentPanel)
    subtitle:SetFont(TRAITOR_MENU_FONT)
    subtitle:SetTextColor(Color(200, 200, 200, 180))
    subtitle:SetText("Choose which side you want to configure.")
    subtitle:SizeToContents()
    subtitle:SetPos(MenuUnit(48), MenuUnit(90))

    local cardArea = vgui.Create("DPanel", parentPanel)
    cardArea:SetSize(sw, sh)
    cardArea:SetPos(0, 0)
    cardArea.Paint = function() end
    local cardAreaX = sw * 0.11
    local cardAreaY = sh * 0.22
    local cardAreaW = sw * 0.78
    local cardAreaH = sh * 0.58
    local cardWidth = cardAreaW * 0.47
    local cardHeight = cardAreaH
    local cardOffscreenOffset = MenuUnit(80)
    local cardHoverScale = 1.035
    local cardTitleY = 0.38
    local cardPointsY = 0.5
    local cardDescY = 0.62

    local cardData = {
        {
            roleId = "hero",
            title = "HERO",
            desc = "Pick the gunner weapon",
            points = "16 POINTS",
            align = "left"
        },
        {
            roleId = "traitor",
            title = "TRAITOR",
            desc = "Pick the traitor weapon",
            points = "30 POINTS",
            align = "right"
        }
    }

    for _, info in ipairs(cardData) do
        local card = vgui.Create("DButton", cardArea)
        card:SetText("")
        card:SetSize(cardWidth, cardHeight)
        card.BaseW = cardWidth
        card.BaseH = cardHeight
        card.HoveredLerp = 0
        card.AppearLerp = 0
        card.StartTime = CurTime()
        card.TargetX = info.align == "left" and cardAreaX or cardAreaX + cardAreaW - card.BaseW
        card.TargetY = cardAreaY
        card:SetPos(info.align == "left" and -card.BaseW - cardOffscreenOffset or sw + cardOffscreenOffset, card.TargetY)
        card.Think = function(self)
            self.HoveredLerp = LerpFT(0.2, self.HoveredLerp or 0, self:IsHovered() and 1 or 0)
            self.AppearLerp = math.Clamp((CurTime() - self.StartTime) / 0.28, 0, 1)
            local scale = 1 + (cardHoverScale - 1) * self.HoveredLerp
            local targetW = self.BaseW * scale
            local targetH = self.BaseH * scale
            local targetY = self.TargetY - (targetH - self.BaseH) * 0.5
            local targetX = self.TargetX - (targetW - self.BaseW) * 0.5
            local curX, curY = self:GetPos()
            local curW, curH = self:GetSize()
            self:SetSize(Lerp(FrameTime() * 10, curW, targetW), Lerp(FrameTime() * 10, curH, targetH))
            self:SetPos(Lerp(FrameTime() * 10, curX, targetX), Lerp(FrameTime() * 10, curY, targetY))
        end
        card.Paint = function(self, w, h)
            local hover = self.HoveredLerp or 0
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 235))
            surface.SetDrawColor(255, 255, 255, 120 + hover * 135)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
            draw.SimpleText(info.title, "ZCity_Big", w * 0.5, h * cardTitleY, color_whitey, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(info.points, TRAITOR_MENU_FONT, w * 0.5, h * cardPointsY, Color(225, 225, 225, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(info.desc, TRAITOR_MENU_FONT, w * 0.5, h * cardDescY, Color(225, 225, 225, 210), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        card.DoClick = function()
            surface.PlaySound(SOUND_MENU_SELECT)
            OpenRoleEditor(parentPanel, info.roleId, parentPanel)
        end
    end

    local backBtn = vgui.Create("DLabel", parentPanel)
    backBtn:SetFont("ZCity_Medium")
    backBtn:SetTextColor(color_whitey)
    backBtn:SetTall(MenuUnit(42))
    backBtn:SetPos(MenuUnit(15), sh - MenuUnit(62))
    SetupAnimatedLabel(backBtn, "<- Return", 0, 15)
    function backBtn:DoClick()
        surface.PlaySound(SOUND_SETTINGS_CLICK)
        CloseToMainMenu(parentPanel)
    end
    backBtn.Think = ThinkAnimatedLabel
    backBtn.Paint = PaintAnimatedLabel
end

hg.DrawTraitorLoadout = hg.DrawLoadoutMenu
