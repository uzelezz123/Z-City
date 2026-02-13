local CLASS = player.RegClass("headcrabzombie")

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

CLASS.CanUseDefaultPhrase = false
CLASS.CanEmitRNDSound = false
CLASS.CanUseGestures = false

local fallbackMats = {
	["Rebel"] = {
		["main"] = "models/zombie_classic/zombie_classic_sheet",
		["pants"] = "models/zombie_classic/zombie_classic_sheet",
		["boots"] = "models/zombie_classic/zombie_classic_sheet",
	},
	["Metrocop"] = {
		["main"] = "models/balaclava_hood/berd_diff_018_a_uni",
		["pants"] = "models/humans/male/group02/lambda",
		["boots"] = "models/humans/male/group01/formal"
	},
	["Combine"] = {
		["main"] = "models/zombie_classic/combinesoldiersheet_zombie",
		["pants"] = "models/gruchk_uwrist/css_seb_swat/swat/gear2",
		["boots"] = "models/humans/male/group01/formal"
	},
}

local clr_darkred = Color(75, 0, 0)
function CLASS.On(self)
	--\\ Remember old player cloth to set it later
	local clothTbl = {}
	if SERVER then
		if self.CurAppearance then
			for i, v in pairs(self.CurAppearance.AClothes) do
				clothTbl[i] = v
			end
		end
	end

	if SERVER then
		ApplyAppearance(self,nil,nil,nil,true)
		local Appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()
		Appearance.AAttachments = ""

		self:SetNetVar("Accessories", "")
		self.CurAppearance = Appearance
	end

    self:SetNWString("PlayerName", "Zombie")
	self:SetModel("models/zcity/player/zombie_classic.mdl")

	--\\ Set cloth and other materials
	if self:GetModel() == "models/zcity/player/zombie_classic.mdl" then
		if SERVER then
			self:SetBodygroup(1, 1)
		end

		self:SetSubMaterial(0, fallbackMat)

		if SERVER then
			if not table.IsEmpty(clothTbl) and not fallbackMats[self.PreZombClass] then
				self:SetSubMaterial(self:GetSubMaterialIdByName("distac/gloves/players_sheet"), hg.Appearance.Clothes[1][clothTbl["main"]])
				self:SetSubMaterial(self:GetSubMaterialIdByName("distac/gloves/pants"), hg.Appearance.Clothes[1][clothTbl["pants"]])
				self:SetSubMaterial(self:GetSubMaterialIdByName("distac/gloves/cross"), hg.Appearance.Clothes[1][clothTbl["boots"]])
			else
				self:SetSubMaterial(self:GetSubMaterialIdByName("distac/gloves/players_sheet"), fallbackMats[self.PreZombClass]["main"])
				self:SetSubMaterial(self:GetSubMaterialIdByName("distac/gloves/pants"), fallbackMats[self.PreZombClass]["pants"])
				self:SetSubMaterial(self:GetSubMaterialIdByName("distac/gloves/cross"), fallbackMats[self.PreZombClass]["boots"])
			end
			self:SetPlayerColor(clr_darkred:ToVector())
		end

		self:SetSubMaterial(4, "")
	end

	if SERVER then
		--\\ Startup organism effects
		if IsValid(self.organism) then
			self.organism.temperature = 41
			self.organism.brain = 0.05
			self.organism.disorientation = 2
			self.organism.otrub = false
			self.organism.needotrub = false
			self.organism.painadd = -10
		end

		self:SetNetVar("headcrab", false)

		for k, v in ipairs(ents.FindByClass("npc_*")) do
			if table.HasValue(rebels, v:GetClass()) or table.HasValue(combines, v:GetClass()) then
				v:AddEntityRelationship(self, D_HT, 99)
			elseif table.HasValue(zombies, v:GetClass()) then
				v:AddEntityRelationship(self, D_LI, 99)
			end
		end

		--\\ Npc relationships
		local index = self:EntIndex()
		hook.Add("OnEntityCreated", "relation_shipdo" .. index, function(ent)
			if not IsValid(self) or self.PlayerClassName ~= "headcrabzombie" then
				hook.Remove("OnEntityCreated","relation_shipdo" .. index)
				return
			end

			if ent:IsNPC() then
				if table.HasValue(rebels, ent:GetClass()) or table.HasValue(combines, ent:GetClass()) then
					ent:AddEntityRelationship(self, D_HT, 99)
				elseif table.HasValue(zombies, ent:GetClass()) then
					ent:AddEntityRelationship(self, D_LI, 99)
				end
			end
		end)

		--\\ Remove armor
		local armors = self:GetNetVar("Armor",{})
		if armors["head"] and !hg.armor["head"][armors["head"]].nodrop then
			hg.DropArmorForce(self, armors["head"])
		end

		if armors["face"] and !hg.armor["face"][armors["face"]].nodrop then
			hg.DropArmorForce(self, armors["face"])
		end

		--\\ Give hands if we don't have it
		if self:HasWeapon("weapon_hands_sh") then
			self:SelectWeapon("weapon_hands_sh")
		else
			local hands = self:Give("weapon_hands_sh")
			self:SelectWeapon(hands)
		end
	end
end

--// Reset organism and npc relationship
function CLASS.Off(self)
    if CLIENT then return end

	for k, v in ipairs(ents.FindByClass("npc_*")) do
        if table.HasValue(rebels, v:GetClass()) then
            v:AddEntityRelationship(self, D_LI, 99)
        elseif table.HasValue(combines, v:GetClass()) or table.HasValue(zombies, v:GetClass()) then
            v:AddEntityRelationship(self, D_HT, 99)
        end
    end
	if IsValid(self.organism) then
		self.organism.brain = 0
		self.organism.disorientation = 0
	end

	hook.Remove("OnEntityCreated", "relation_shipdo"..self:EntIndex())
end

--// Reset npc relationship
function CLASS.PlayerDeath(self)
	for k, v in ipairs(ents.FindByClass("npc_*")) do
        if table.HasValue(rebels, v:GetClass()) then
            v:AddEntityRelationship(self, D_LI, 99)
        elseif table.HasValue(combines, v:GetClass()) or table.HasValue(zombies, v:GetClass()) then
            v:AddEntityRelationship(self, D_HT, 99)
        end
    end

    hook.Remove("OnEntityCreated", "relation_shipdo" .. self:EntIndex())
end

function CLASS.Guilt(self, victim)
    if CLIENT then return end

	--[[if victim:GetPlayerClass() == self:GetPlayerClass() then
        return 1 --// Idk if zombies really need this so uncomment if you want
    end]]

	return 0
end

--// We'll do some tricky stuff there..
function CLASS.Think(self)
    if CLIENT then return end

	--\\ Remove armor
	local armors = self:GetNetVar("Armor",{})
	if armors["head"] and !hg.armor["head"][armors["head"]].nodrop then
		hg.DropArmorForce(self, armors["head"])
	end

	if armors["face"] and !hg.armor["face"][armors["face"]].nodrop then
		hg.DropArmorForce(self, armors["face"])
	end

	--\\ Only hands will be active..
	local wep = self:GetActiveWeapon()
	if IsValid(wep) and wep ~= NULL and wep:GetClass() ~= "weapon_hands_sh" then
		if self:HasWeapon("weapon_hands_sh") then
			self:SelectWeapon("weapon_hands_sh")
		else
			local hands = self:Give("weapon_hands_sh")
			self:SelectWeapon(hands)
		end
	end

	--\\ Organism stuff
	local org = self.organism

	org.stamina["max"] = 200
	org.stamina["range"] = 200

	if org.otrub then
		org.consciousness = 1
		org.adrenalineAdd = 4
		org.analgesia = 0.4
	end

	if org.pain >= 75 then
		org.painadd = -10
	end

	org.pulse = 70
	org.o2["curregen"] = 2

	if org.consciousness <= 0.3 then
		org.consciousness = 1
		org.needotrub = false
	end

	org.jawdislocation = false
	org.llegdislocation = false
	org.rlegdislocation = false
	org.rarmdislocation = false
end

--// Phrase stuff
local zomb_pain = {"npc/zombie/zombie_die2.wav"}
for i = 1, 6 do
	table.insert(zomb_pain, "npc/zombie/zombie_pain" .. i .. ".wav")
end

local zomb_phrases, zomb_burnphrases = {}, {}
for i = 1, 3 do
	table.insert(zomb_phrases, "npc/zombie/zombie_alert" .. i .. ".wav")
end
for i = 1, 14 do
	table.insert(zomb_phrases, "npc/zombie/zombie_voice_idle" .. i .. ".wav")
	table.insert(zomb_burnphrases, "npc/zombie/zombie_voice_idle" .. i .. ".wav")
end

hook.Add("HG_ReplaceBurnPhrase", "ZombBurnPhrases", function(ply, phrase)
	if ply.PlayerClassName == "headcrabzombie" then
		return ply, zomb_burnphrases[math.random(#zomb_burnphrases)]
	end
end)

hook.Add("HG_ReplacePhrase", "ZombPhrases", function(ply, phrase, muffed, pitch) -- pitch means pitched effect, not exact sound pitch
	if ply.PlayerClassName == "headcrabzombie" then
		local inpain = ply.organism.pain > 60
		local phr = (inpain and zomb_pain[math.random(#zomb_pain)] or zomb_phrases[math.random(#zomb_phrases)])

		return ply, phr, true, pitch -- pitch effect will be useful for zombine
	end
end)

hook.Add("HG_CanThoughts", "ZombCantDumat", function(ply)
	if ply.PlayerClassName == "headcrabzombie" then
		return false
	end
end)

--// Can't pickup weapons and use doors
hook.Add("PlayerCanPickupWeapon", "ZombCantPickup", function(ply, ent)
	if IsValid(ply) and ply.PlayerClassName == "headcrabzombie" and ent:GetClass() ~= "weapon_hands_sh" then
		return false
	end
end)

hook.Add("PlayerUse", "ZombCantPickup", function(ply, ent)
	if IsValid(ply) and ply.PlayerClassName == "headcrabzombie" and ent:GetClass() ~= "func_button" then
		return false
	end
end)

--// Player speed & animation speed stuff
hook.Add("HG_MovementCalc_2", "ZombSpeed", function(mul, ply, cmd, mv)
	if IsValid(ply) and ply.PlayerClassName == "headcrabzombie" then
        mul[1] = 0.8
		if ply:IsSprinting() then
			mul[1] = 1.2
		end
		if ply.SpeedGainMul ~= 70 then
			ply.SpeedGainMul = 70
		end
    end
end)

hook.Add("UpdateAnimation", "ZombAnimRate", function(ply, vel, maxSeqGroundSpeed)
	if ply.PlayerClassName == "headcrabzombie" then
		if not IsValid(ply) or not ply:Alive() then return end

		if vel:LengthSqr() >= 77000 and vel:LengthSqr() < 110000 then
			ply:SetPlaybackRate(1.1)
			return ply, vel, maxSeqGroundSpeed
		end

		if vel:LengthSqr() >= 17000 then
			ply:SetPlaybackRate(1.2)
			return ply, vel, maxSeqGroundSpeed
		end

		if not ply:OnGround() then
			ply:SetPlaybackRate(0.8)
			return ply, vel, maxSeqGroundSpeed
		end
	end
end)

if SERVER then
	hook.Add("HG_PlayerFootstep", "ZombSteps", function(ply)
		local chr = hg.GetCurrentCharacter(ply)
		if ply:Alive() and ply.PlayerClassName == "headcrabzombie" then
			if IsValid(ply.FakeRagdoll) and ply:GetNetVar("lastFake") == 0 then return end
			if not ply:IsSprinting() and (ply:KeyDown(IN_DUCK) or ply:KeyDown(IN_WALK)) then
				chr:EmitSound("npc/zombie/foot_slide" .. math.random(3) .. ".wav", 60, math.random(95, 105), 0.5)
			else
				chr:EmitSound("npc/zombie/foot" .. math.random(3) .. ".wav", 65, math.random(95, 105))
			end
			return true
		end
	end)

	--[[hook.Add("OnHeadExplode", "ZombAmputate", function(ply, rag)
		print(ply, rag)
		if ply.PlayerClassName == "headcrabzombie" then
			rag:SetBodygroup(1, 0)
		end
	end)]]

	--// Zombies can't loot anyone
	hook.Add("ZB_CanLootInventory", "ZombCanLoot", function(ply, ent, canloot)
		if ply.PlayerClassName == "headcrabzombie" then
			return ply, ent, false
		end
	end)

	--// Zombies can't speak
	hook.Add("HG_PlayerCanHearPlayersVoice", "ZombVoice", function(listener, speaker)
		if speaker.PlayerClassName == "headcrabzombie" then
			return false, false
		end
	end)
else
	--// Draw 3d headcrab overlay
	local function DrawHeadcrab(ply, strModel, vecAdjust, fFov)
		if not IsValid(ply.FirstPersonCrab) then
			ply.FirstPersonCrab = ClientsideModel(strModel)
			ply.FirstPersonCrab:SetNoDraw(true)
			return
		end
	
		if not IsValid(ply.FirstPersonCrab2) then
			ply.FirstPersonCrab2 = ClientsideModel(strModel)
			ply.FirstPersonCrab2:SetNoDraw(true)
			ply.FirstPersonCrab2:SetModelScale(1.05)
			return
		end
	
		local mdl = ply.FirstPersonCrab
		local mdl2 = ply.FirstPersonCrab2
	
		if mdl:GetModel() != strModel then
			mdl:SetModel(strModel)
		end
	
		if mdl2:GetModel() != strModel then
			mdl2:SetModel(strModel)
		end
	
		if ply == GetViewEntity() then
			local view = render.GetViewSetup()

			cam.Start3D(view.origin, view.angles, view.fov + fFov, nil, nil, nil, nil, 1, 30)
				cam.IgnoreZ(true)

				local viewpunching = GetViewPunchAngles()
				local ang = view.angles + viewpunching

				ang:RotateAroundAxis(ang:Up(), -90)
				ang:RotateAroundAxis(ang:Forward(), 100)

				mdl:SetRenderOrigin(view.origin + ang:Forward() * vecAdjust.x + ang:Right() * vecAdjust.y + ang:Up() * vecAdjust.z)
				mdl:SetRenderAngles(ang)
				mdl2:SetRenderOrigin(view.origin + ang:Forward() * vecAdjust.x + ang:Right() * vecAdjust.y + ang:Up() * vecAdjust.z)
				mdl2:SetRenderAngles(ang)
				mdl:SetParent(ply, ply:LookupBone("ValveBiped.Bip01_Head1"))
				
				render.SetColorModulation(1, 1, 1)
					render.SetStencilWriteMask(0xFF)
					render.SetStencilTestMask(0xFF)
					render.SetStencilReferenceValue(0)
					render.SetStencilCompareFunction(STENCIL_ALWAYS)
					render.SetStencilPassOperation(STENCIL_KEEP)
					render.SetStencilFailOperation(STENCIL_KEEP)
					render.SetStencilZFailOperation(STENCIL_KEEP)
					render.ClearStencil()
					
					-- Enable stencils
					render.SetStencilEnable(true)
					-- Set everything up everything draws to the stencil buffer instead of the screen
					render.SetStencilReferenceValue(1)
					render.SetStencilCompareFunction(STENCIL_NOTEQUAL)
					render.SetStencilPassOperation(STENCIL_REPLACE)
					
					render.SetBlend(0)
						mdl2:DrawModel()
					render.SetBlend(1)

					render.SetStencilCompareFunction(STENCIL_EQUAL)
					
					mdl:DrawModel()

					DrawBokehDOF(26, 0.93, 15)
					-- Let everything render normally again
					render.SetStencilEnable(false)
				render.SetColorModulation(1, 1, 1)

				cam.IgnoreZ(false)
			cam.End3D()
		end
	end

	hook.Add("Post Pre Post Processing", "ZombDrawHeadcrab", function()
		if lply.PlayerClassName == "headcrabzombie" and lply:Alive() and lply.organism and not lply.organism.otrub then
			DrawHeadcrab(lply, "models/nova/w_headcrab.mdl", vector_origin, -50)
		end
	end)

	--// Change view from head to upper torso because zombie model doesn't have proper head bone..
	-- "HG_CalcView", ply, origin, angles, fova, znear, zfar
	hook.Add("HGAddView", "ZombView", function(ply, origin, angles)
		if ply:Alive() and ply.PlayerClassName == "headcrabzombie" then
			local ply_spine_index = ply:LookupBone("ValveBiped.Bip01_Spine4")
			if !ply_spine_index then return end
			local ply_spine_matrix = ply:GetBoneMatrix(ply_spine_index)
			local spineAng = ply_spine_matrix:GetAngles()

			origin = origin + spineAng:Right() * -8 + spineAng:Forward() * -2
			angles.z = math.sin(CurTime() * 2) * 4

			local chr = hg.GetCurrentCharacter(ply)
			if CLIENT and hg.IsLocal(ply) and chr:GetBodygroup(1) ~= 0 then
				chr:SetBodygroup(1, 0)
			elseif chr:GetBodygroup(1) == 0 and not ply.organism.headamputated then
				chr:SetBodygroup(1, 1)
			end

			return ply, origin, angles -- change da fov maybe??
		end
	end)

	hook.Add("hg_AdjustMouseSensitivity", "ZombSens", function(sensitivity)
		if lply.PlayerClassName == "headcrabzombie" and lply:GetVelocity():LengthSqr() >= 140000 and lply:GetMoveType() == MOVETYPE_WALK then
			return 0.25
		end
	end)
end

hook.Add("PlayerCanLegAttack", "ZombKick", function(ply)
	if ply.PlayerClassName == "headcrabzombie" then
		return false
	end
end)

--// Zombie animations
hook.Add("CalcMainActivity", "ZombAnims", function(ply, vel)
	if ply.PlayerClassName == "headcrabzombie" then
		local anim = ACT_HL2MP_RUN_ZOMBIE
		if vel:LengthSqr() <= 0 then
			anim = ACT_HL2MP_IDLE_ZOMBIE
		end
		if ply:IsFlagSet(FL_ANIMDUCKING) then
			anim = ACT_HL2MP_WALK_CROUCH_ZOMBIE_01 -- ACT_HL2MP_WALK_ZOMBIE_06
		end
		if not ply:IsOnGround() and ply:GetMoveType() ~= MOVETYPE_NOCLIP then
			if vel:Length2DSqr() >= 17000 then
				anim = ACT_HL2MP_RUN_ZOMBIE_FAST
			else
				anim = ACT_HL2MP_JUMP_SLAM
			end
		end

		return anim, -1
	end
end)

--// Zombie can't drive vehicles
hook.Add("CanPlayerEnterVehicle", "ZombVehicle", function(ply, ent)
	if ply.PlayerClassName == "headcrabzombie" then
		return false
	end
end)