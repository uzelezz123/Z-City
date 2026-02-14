if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_bandage_sh"
SWEP.PrintName = "Fury-13"
SWEP.Instructions = "Fury-13 (Not to be confused with \"Furry-13\", an unrelated pathowogen virus strain) is an incredibly potent stimulator drug. Instead of \"modifying\" how your organism works, this drug aims to provide additional resources instead, making you stronger than ever before. Side effects may include permanent brain damage. Do not use on infected person."
SWEP.Category = "ZCity Medicine"
SWEP.Spawnable = true
SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0
SWEP.HoldType = "normal"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/bloocobalt/l4d/items/w_eq_adrenaline.mdl"
if CLIENT then
	SWEP.WepSelectIcon = Material("entities/zcity/fury13.png")
	SWEP.IconOverride = "entities/zcity/fury13.png"
	SWEP.BounceWeaponIcon = false
end
SWEP.AdminOnly = true
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 5
SWEP.SlotPos = 1
SWEP.WorkWithFake = true
SWEP.offsetVec = Vector(3, -2.5, -1)
SWEP.offsetAng = Angle(-30, 20, -90)
SWEP.ModelScale = 0.65
SWEP.Color = Color(255, 170, 80)
SWEP.modeNames = {
	[1] = "fury-13"
}

function SWEP:InitializeAdd()
	self:SetHold(self.HoldType)

	self.modeValues = {
		[1] = 1
	}
end

SWEP.modeValuesdef = {
	[1] = 1
}

SWEP.DeploySnd = ""
SWEP.HolsterSnd = ""

SWEP.showstats = false

function SWEP:Animation()
	local hold = self:GetHolding()
    self:BoneSet("r_upperarm", vector_origin, Angle(0, (-55*hold/65) + hold / 2, 0))
    self:BoneSet("r_forearm", vector_origin, Angle(-hold / 6, -hold / 0.8, (-20*hold/100)))
end

local combines = {
    "npc_combine_s",
    "npc_metropolice",
    "npc_helicopter",
    "npc_combinegunship",
    "npc_combine",
    "npc_stalker",
    "npc_hunter",
    "npc_strider",
    "npc_turret_floor",
	"npc_combine_camera",
    "npc_manhack",
    "npc_cscanner",
    "npc_clawscanner"
}

local rebels = {
    "npc_barney",
    "npc_citizen",
    "npc_dog",
    "npc_eli",
    "npc_kleiner",
    "npc_magnusson",
    "npc_monk",
    "npc_mossman",
    "npc_odessa",
    "npc_rollermine_hacked",
    "npc_turret_floor_resistance",
    "npc_vortigaunt",
    "npc_alyx"
}

local zombies = {
    "npc_fastzombie",
    "npc_fastzombie_torso",
    "npc_headcrab",
    "npc_headcrab_black",
    "npc_headcrab_fast",
    "npc_poisonzombie",
    "npc_zombie",
    "npc_zombie_torso",
    "npc_zombine"
}

function SWEP:NPCHeal(npc, mul, snd)
	if not npc then npc = self:GetOwner() end

	if npc:IsNPC() then
		self:SetHold("melee")
		if not mul then mul = 0.3 end
		npc:SetHealth(math.Clamp(npc:Health() + (npc:GetMaxHealth() * 1 * mul), 0, npc:GetMaxHealth() * math.Clamp(2 * mul, 2, 100)))
		npc:EmitSound(snd or "snd_jack_hmcd_needleprick.wav", 80, math.random(95, 105))
		npc:SetPlaybackRate(2)
		npc:SetKeyValue("m_flPlaybackSpeed", 2)

		if SERVER then --// kill everyone
			local index = npc:EntIndex()
			npc:SetSquad("fury13" .. index)

			for k, v in ipairs(ents.FindByClass("npc_*")) do
				if table.HasValue(rebels, v:GetClass()) or table.HasValue(combines, v:GetClass()) or table.HasValue(zombies, v:GetClass()) then
					v:AddEntityRelationship(npc, D_HT, 99)
					npc:AddEntityRelationship(v, D_HT, 99)
				end
			end

			for k, v in player.Iterator() do
				npc:AddEntityRelationship(v, D_HT, 99)
			end

			hook.Add("OnEntityCreated", "relation_shipdo" .. index, function(ent)
				if not IsValid(npc) or not npc:Alive() then
					hook.Remove("OnEntityCreated", "relation_shipdo" .. index)

					return
				end

				if ent:IsNPC() then
					if table.HasValue(rebels, ent:GetClass()) or table.HasValue(combines, ent:GetClass()) or table.HasValue(zombies, ent:GetClass()) then
						ent:AddEntityRelationship(npc, D_HT, 99)
						npc:AddEntityRelationship(ent, D_HT, 99)
					end
				end
			end)

			self:Remove()
		end
	end
end

function SWEP:OwnerChanged()
	local owner = self:GetOwner()
	if IsValid(owner) and owner:IsNPC() then
		self:NPCHeal(owner, 100, "snd_jack_hmcd_needleprick.wav")
	end
end

if SERVER then
	function SWEP:Heal(ent, mode)
		if ent:IsNPC() then
			self:NPCHeal(ent, 100, "snd_jack_hmcd_needleprick.wav")
		end

		local org = ent.organism
		if not org then return end
		self:SetBodygroup(1, 1)
		local owner = self:GetOwner()
		local entOwner = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or owner
		entOwner:EmitSound("snd_jack_hmcd_needleprick.wav", 80, math.random(75, 90))

		if org.noradrenaline >= 0.4 then
			ent:Kill()
		end

		if ent.PlayerClassName and ent.PlayerClassName != "furry" then
			org.berserk = org.berserk + 2
		else
			org.o2["curregen"] = 0
			org.o2["regen"] = 0
			org.poison4 = CurTime()
			org.internalBleed = org.internalBleed + 10
		end

		self.modeValues[1] = 0

		if self.poisoned2 then
			org.poison4 = CurTime()

			self.poisoned2 = nil
		end

		if self.modeValues[1] == 0 then
			owner:SelectWeapon("weapon_hands_sh")
			self:Remove()
		end
	end
end