
local CLASS = player.RegClass("Metrocop")


local combine_models = {
    "models/player/police.mdl"
}


local callsigns = {
    "Officer Alpha","Officer Bravo","Officer Charlie","Officer Delta"
}


local primary_weapons = {
    "weapon_mp7"
}


local combine_subclasses = {
    default = {
        color = Color(24,24,24),
        models = combine_models,
        loadout = {
            {weapon = "weapon_medkit_sh"},
            {weapon = "weapon_naloxone"},
            {weapon = "weapon_bigbandage_sh"},
            {weapon = "weapon_tourniquet"},
            {weapon = "weapon_hg_stunstick"},
            {weapon = "weapon_handcuffs"},
            {weapon = "weapon_handcuffs_key"},
            {weapon = "weapon_walkie_talkie"},
            {
                weapon = "weapon_hk_usp",
                ammo_mult = 3
            },

            {
                weapon_random_pool = primary_weapons,
                ammo_mult = 3
            }
        },
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

    for k,v in ipairs(ents.FindByClass("npc_*")) do
        if table.HasValue(combines,v:GetClass()) then
            v:AddEntityRelationship( self, D_HT, 99 )
        elseif table.HasValue(rebels,v:GetClass()) then
            v:AddEntityRelationship( self, D_LI, 0 )
        end
    end

	self:SetNWString("PlayerRole", nil)
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
    self.armors["torso"] = "metrocop_armor"
    self.armors["head"] = "metrocop_helmet"
    self:SyncArmor()

    if not data.bNoEquipment then
        giveSubClassLoadout(self, sub)
    end

    self.subClass = nil
    self.organism.recoilmul = 0.85

    local callsign
    if math.random(1,1000) <= 1 then
        callsign = "Scug"
    else
        callsign = table.Random(callsigns) .. "-" .. math.random(1,25)
    end

    if zb.GiveRole then zb.GiveRole(self, "Officer", Color(89,230,255)) end
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

    EmitSound( "npc/metropolice/die" .. math.random(1,4) .. ".wav", self:GetPos() )

    hook.Remove( "OnEntityCreated", "relation_shipdo"..self:EntIndex())
end

if SERVER then
	local mtcop_phrases = {}
	local files,_ = file.Find("sound/npc/metropolice/vo/*.wav","GAME")
	for k,v in ipairs(files) do
		mtcop_phrases[k] = "npc/metropolice/vo/" .. v
	end

	hook.Add("HG_ReplacePhrase", "metropolice_phrase", function(ply, phrase, muffed, pitch)
		if IsValid(ply) and ply.PlayerClassName == "Metrocop" then
			return ply, mtcop_phrases[math.random(#mtcop_phrases)], muffed, pitch
		end
	end)
end

if CLIENT then
    local cmb_mat = Material("sprites/mat_jack_helmoverlay_r")
    hook.Add("PostDrawHUD","Metrocop_helmet",function()
        local lply = LocalPlayer()
        if lply:Alive() and lply.PlayerClassName == "Metrocop" then
            local role = lply:GetNWString("PlayerRole")

            surface.SetDrawColor(150,190,190,255)

            surface.SetMaterial(cmb_mat)
            surface.DrawTexturedRectRotated(
                (ScrW()/2) - 5,
                (ScrH()/2) - 5,
                ScrW() + 10,
                ScrH() + 450,
                180
            )
        end
    end)
end

return CLASS
