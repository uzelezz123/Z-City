util.AddNetworkString("hg_add_equipment")
util.AddNetworkString("hg_drop_equipment")

function hg.SetArmorRestrictions(ply, restrictions)
	if not IsValid(ply) then return end
	ply.ArmorRestrictions = restrictions
end

function hg.ClearArmorRestrictions(ply)
	if not IsValid(ply) then return end
	ply.ArmorRestrictions = nil
end


function hg.CanEquipArmorPiece(ply, equipment)
	if not IsValid(ply) or not ply.ArmorRestrictions or not istable(ply.ArmorRestrictions) then
		return true
	end
	
	local equipName = string.Replace(equipment, "ent_armor_", "")
	local placement = hg.GetArmorPlacement(equipName)
	
	local isRestricted = ply.ArmorRestrictions[equipName] or ply.ArmorRestrictions[placement] or ply.ArmorRestrictions["all"]
	
	return not isRestricted
end

net.Receive("hg_drop_equipment", function(len, ply)
    local equipment = net.ReadString()

    if equipment == "hg_flashlight" then
        ply:ConCommand("hg_dropflashlight")
    end

    if equipment == "hg_sling" then
        ply:ConCommand("hg_dropsling")
    end

    if equipment == "hg_brassknuckles" then
        ply:ConCommand("hg_dropkastet")
    end

    if not ply.organism.canmove then return end

    hg.DropArmor(ply, equipment)
end)

function hg.AddArmor(ply, equipment, ent)
    if not IsValid(ply) then return end

	if not hg.CanEquipArmorPiece(ply, equipment) then
		if ply:IsPlayer() then
			--ply:ChatPrint("huy")
		end
		return false
	end
	
	local can = hook.Run("CanEquipArmor", ply, equipment)
	
	if(can == false)then
		return nil
	end
	
    if equipment and istable(equipment) then
        for i,equipment1 in pairs(equipment) do
            hg.AddArmor(ply, equipment1)
        end
        return
    end
    equipment = string.Replace(equipment,"ent_armor_","")
    local placement
    for plc, tbl in pairs(hg.armor) do
        placement = tbl[equipment] and tbl[equipment][1] or placement
    end
    
    if not placement then
        print("sh_equipment.lua: no such equipment as: " .. equipment)
        return false
    end
    
    if hg.armor[placement][equipment].whitelistClasses and !hg.armor[placement][equipment].whitelistClasses[ply.PlayerClassName] then return false end

    for plc, arm in pairs(ply.armors) do
        //if not hg.armor[plc] or not hg.armor[plc][arm] or not hg.armor[plc][arm].restricted then continue end

        if hg.armor[plc][arm].restricted and table.HasValue(hg.armor[plc][arm].restricted, placement) then
            if not hg.DropArmor(ply, ply.armors[plc]) then return false end
        end
        
        if hg.armor[placement][equipment].restricted and table.HasValue(hg.armor[placement][equipment].restricted, plc) then
            if not hg.DropArmor(ply, ply.armors[plc]) then return false end
        end
    end

    if ply.armors[placement] and ply:IsPlayer() then
		local currentArmorData = hg.armor[placement] and hg.armor[placement][ply.armors[placement]]
		
        if not hg.DropArmor(ply, ply.armors[placement]) then return false end
    end
    
    if hg.armor[placement][equipment].AfterPickup then
        hg.armor[placement][equipment].AfterPickup(ply)
    end

    if hg.armor[placement][equipment].voice_change then
        if eightbit and eightbit.EnableEffect and ply.UserID then
            eightbit.EnableEffect(ply:UserID(), eightbit.EFF_MASKVOICE)
        end
    end

	if ent then
		ent:ApplyData(ply,equipment)
	else
		local item = hg.armor[placement][equipment]
		local mat = istable(item.material) and item.material[1] or item.material
		ply:SetNWString("ArmorMaterials" .. equipment, mat)

		local skin = istable(item.material) and table.Random(item.material) or nil
		if item.skins then
			ply:SetNWInt("ArmorSkins" .. equipment, skin)
		end
	end

    ply.armors[placement] = equipment
    
    ply:SyncArmor()
    return true
end

function hg.DropArmorForce(ent, equipment)
    if not table.HasValue(ent.armors, equipment) then return false end
    local placement
    for plc, tbl in pairs(hg.armor) do
        placement = tbl[equipment] and tbl[equipment][1] or placement
    end

    if not placement then
        print("sh_equipment.lua: no such equipment as: " .. equipment)
        return false
    end
    
    if hg.armor[placement][equipment] then
        local equipmentEnt = ents.Create("ent_armor_" .. equipment)
        equipmentEnt:Spawn()
        equipmentEnt:SetPos(ent:GetPos())
        equipmentEnt:SetAngles(ent:GetAngles())
		equipmentEnt:ReciveData(ent,equipment)

        if ent:GetNetVar("zableval_masku", false) then
            equipmentEnt.zablevano = true
            ent:SetNetVar("zableval_masku", false)
        end

        local phys = equipmentEnt:GetPhysicsObject()

        if IsValid(equipmentEnt) then table.RemoveByValue(ent.armors, equipment) end
        
        if hg.armor[placement][equipment].voice_change then
            if eightbit and eightbit.EnableEffect and ent.UserID then
                eightbit.EnableEffect(ent:UserID(), ent.PlayerClassName == "furry" and eightbit.EFF_PROOT or 0)
            end
        end

        ent:SyncArmor()
        
        return equipmentEnt
    end
end

function hg.DropArmor(ply, equipment)
    if not table.HasValue(ply.armors, equipment) then return false end
    
    local placement
    for plc, tbl in pairs(hg.armor) do
        placement = tbl[equipment] and tbl[equipment][1] or placement
    end
    
    if hg.armor[placement][equipment].nodrop then return false end

    if not placement then
        print("sh_equipment.lua: no such equipment as: " .. equipment)
        return false
    end

    if IsValid(ply) and ply.DropCD and ply.DropCD > CurTime() then return false end

    if hg.armor[placement][equipment] then
        ply:DoAnimationEvent((placement == "head" or placement == "ears" or placement == "face") and ACT_GMOD_GESTURE_MELEE_SHOVE_1HAND or ACT_GMOD_GESTURE_MELEE_SHOVE_2HAND)
	    ply:ViewPunch(Angle(1,-2,1))
        ply.DropCD = CurTime() + 0.35
        --timer.Simple(0.3,function()
        if not IsValid(ply) then return end
        local equipmentEnt = ents.Create("ent_armor_" .. equipment)
        equipmentEnt:Spawn()
        equipmentEnt:SetPos(ply:EyePos())
        equipmentEnt:SetAngles(ply:EyeAngles())
		equipmentEnt:ReciveData(ply,equipment)
        
        if placement == "face" and ply:GetNetVar("zableval_masku", false) then
            equipmentEnt.zablevano = true
            ply:SetNetVar("zableval_masku", false)
        end
        
        local phys = equipmentEnt:GetPhysicsObject()
        if IsValid(phys) then phys:SetVelocity(ply:EyeAngles():Forward() * 150) end
        if IsValid(equipmentEnt) then table.RemoveByValue(ply.armors, equipment) end
        
        if hg.armor[placement][equipment].voice_change then
            if eightbit and eightbit.EnableEffect and ply.UserID then
                eightbit.EnableEffect(ply:UserID(), ply.PlayerClassName == "furry" and eightbit.EFF_PROOT or 0)
            end
        end

        ply:SyncArmor()
        --end)
        return true
    end
end

-- armorstuff
util.AddNetworkString("AddFlash")

local ArmorEffect
local force
local function protec(org, bone, dmg, dmgInfo, placement, armor, scale, scaleprot, punch, boneindex, dir, hit, ricochet)
	if not force and org.owner.armors[placement] ~= armor then return 0 end
	force = nil
	
	local prot = placement and hg.armor[placement] and armor and hg.armor[placement][armor] and (hg.armor[placement][armor].protection - (dmgInfo:GetInflictor().bullet and dmgInfo:GetInflictor().bullet.Penetration or 1)) or (10 - ( dmgInfo:GetInflictor().bullet and dmgInfo:GetInflictor().bullet.Penetration or 1))
	
	org.owner.armors_health = org.owner.armors_health or {}

	prot = prot * (org.owner.armors_health[armor] or 1)
	
	if punch then
		if org.owner:IsPlayer() and org.alive and dmgInfo:IsDamageType(DMG_BUCKSHOT + DMG_BULLET) then
			org.owner:ViewPunch(AngleRand(-30, 30))
			
			org.owner:EmitSound("homigrad/physics/shield/bullet_hit_shield_0"..math.random(7)..".wav", 80, math.random(95, 105))

			org.owner:AddTinnitus(3, true)
			net.Start("AddFlash")
				net.WriteVector(hg.eye(org.owner) + org.owner:GetForward() * 3)
				net.WriteFloat(3)
				net.WriteInt(100, 20)
			net.Send(org.owner)

			hg.ExplosionDisorientation(org.owner, 6, 6)

			hg.organism.input_list.spine3(org, bone, (dmg/100) * math.Rand(0,0.1), dmgInfo)
			--org.spine3 = org.spine3 + math.Rand(0.05,1) * dmg / 5
		end
	end
	
	scale = scale * (dmgInfo:IsDamageType(DMG_SLASH) and 0.1 or 1)
	
	ArmorEffect(placement, armor, dmgInfo, org, hit, prot)

	if prot < 0 then
		//dmgInfo:ScaleDamage(scale)
		return 0
	end

	dmgInfo:SetDamageType(DMG_CLUB)
	dmgInfo:SetDamageForce(dmgInfo:GetDamageForce() * 0.4)
	dmgInfo:ScaleDamage(0.2)

	return 0.9
end

ArmorEffect = function(placement, armor, dmgInfo, org, hit, prot)
	local armdata = placement and hg.armor[placement] and hg.armor[placement][armor] or {}
	local eff = prot < 0 and "Impact" or armdata.effect or "Impact"
	local dir = -dmgInfo:GetDamageForce()
	dir:Normalize()
	local effdata = EffectData()
	
	effdata:SetOrigin((hit and isvector(hit) and hit or dmgInfo:GetDamagePosition()) - dir)
	effdata:SetNormal(dir)
	effdata:SetMagnitude(0.25)
	effdata:SetRadius(4)
	effdata:SetNormal(dir)
	effdata:SetStart((hit and isvector(hit) and hit or dmgInfo:GetDamagePosition()) + dir)
	effdata:SetEntity(org.owner)
	effdata:SetSurfaceProp(prot < 0 and 67 or armdata.surfaceprop or 67)
	effdata:SetDamageType(dmgInfo:GetDamageType())

	EmitSound("physics/metal/metal_solid_impact_bullet"..math.random(4)..".wav",dmgInfo:GetDamagePosition(),0,CHAN_AUTO,1,55,nil,100)
	util.Effect(eff,effdata)
end

local ArmorEffectEx = function(ent,dmgInfo,eff,surfaceprop)
	local dir = -dmgInfo:GetDamageForce()
	dir:Normalize()
	local effdata = EffectData()
	
	effdata:SetOrigin( dmgInfo:GetDamagePosition() - dir )
	effdata:SetNormal( dir )
	effdata:SetMagnitude(0.25)
	effdata:SetRadius(4)
	effdata:SetNormal(dir)
	effdata:SetStart(dmgInfo:GetDamagePosition() + dir)
	effdata:SetEntity(ent)
	effdata:SetSurfaceProp(surfaceprop or 67)
	effdata:SetDamageType(dmgInfo:GetDamageType())

	EmitSound("physics/metal/metal_solid_impact_bullet"..math.random(4)..".wav",dmgInfo:GetDamagePosition(),0,CHAN_AUTO,1,55,nil,100)
	util.Effect(eff,effdata)
end

hg.ArmorEffect = ArmorEffect
hg.ArmorEffectEx = ArmorEffectEx

hg.organism = hg.organism or {}
hg.organism.input_list = hg.organism.input_list or {}
hg.organism.input_list.vest1 = function(org, bone, dmg, dmgInfo, ...)
	local protect = protec(org, bone, dmg, dmgInfo, "torso", "vest1", 0.6, 0.6, false, ...)
	return protect
end

hg.organism.input_list.helmet1 = function(org, bone, dmg, dmgInfo, ...)
	local protect = protec(org, bone, dmg, dmgInfo, "head", "helmet1", 1, 0.6, true, ...)
	return protect
end

hg.organism.input_list.helmet2 = function(org, bone, dmg, dmgInfo, ...)
	local protect = protec(org, bone, dmg, dmgInfo, "head", "helmet2", 1, 0.3, true, ...)
	return protect
end

hg.organism.input_list.helmet3 = function(org, bone, dmg, dmgInfo, ...)
	local protect = protec(org, bone, dmg, dmgInfo, "head", "helmet3", 1, 0.25, true, ...)
	return protect
end

hg.organism.input_list.helmet5 = function(org, bone, dmg, dmgInfo, ...)
	local protect = protec(org, bone, dmg, dmgInfo, "head", "helmet5", 1, 0.4, true, ...)
	return protect
end

hg.organism.input_list.helmet6 = function(org, bone, dmg, dmgInfo, ...)
	local protect = protec(org, bone, dmg, dmgInfo, "head", "helmet6", 1, 0.5, true, ...)
	return protect
end

hg.organism.input_list.helmet7 = function(org, bone, dmg, dmgInfo, ...)
	local protect = protec(org, bone, dmg, dmgInfo, "head", "helmet7", 1, 0.4, true, ...)
	return protect
end

hg.organism.input_list.vest2 = function(org, bone, dmg, dmgInfo, ...)
	local protect = protec(org, bone, dmg, dmgInfo, "torso", "vest2", 1, 0.3, false, ...)
	return protect
end

hg.organism.input_list.vest3 = function(org, bone, dmg, dmgInfo, ...)
	local protect = protec(org, bone, dmg, dmgInfo, "torso", "vest3", 0.8, 0.3, false, ...)
	return protect
end

hg.organism.input_list.vest4 = function(org, bone, dmg, dmgInfo, ...)
	local protect = protec(org, bone, dmg, dmgInfo, "torso", "vest4", 0.8, 0.3, false, ...)
	return protect
end

hg.organism.input_list.mask1 = function(org, bone, dmg, dmgInfo, ...)
	local protect = protec(org, bone, dmg, dmgInfo, "face", "mask1", 1, 0.9, true, ...)
	return protect
end

hg.organism.input_list.mask3 = function(org, bone, dmg, dmgInfo, ...)
	local protect = protec(org, bone, dmg, dmgInfo, "face", "mask3", 0.95, 0.92, true, ...)
	return protect
end

hg.organism.input_list.vest5 = function(org, bone, dmg, dmgInfo, ...)
	local protect = protec(org, bone, dmg, dmgInfo, "torso", "vest5", 0.8, 0.5, false, ...)
	return protect
end
hg.organism.input_list.vest6 = function(org, bone, dmg, dmgInfo, ...)
	local protect = protec(org, bone, dmg, dmgInfo, "torso", "vest6", 0.8, 0.4, false, ...)
	return protect
end

hg.organism.input_list.vest7 = function(org, bone, dmg, dmgInfo, ...)
	local protect = protec(org, bone, dmg, dmgInfo, "torso", "vest7", 0.8, 0.5, false, ...)
	return protect
end

hg.organism.input_list.vest8 = function(org, bone, dmg, dmgInfo, ...)
	local protect = protec(org, bone, dmg, dmgInfo, "torso", "vest8", 0.7, 0.4, false, ...)
	return protect
end
-------------------------------------------------------------------

-- Gordon's armor
hg.organism.input_list.gordon_helmet = function(org, bone, dmg, dmgInfo, ...)
	local owner = hg.GetCurrentCharacter(org.owner) or org.owner
	--if owner:GetBodygroup(2) ~= 2 then return 0 end
	--owner:SetBodygroup(2,0)
	force = true
	local protect = protec(org, bone, dmg, dmgInfo, "head", "gordon_helmet", 0.5, 0.3, false, ...)
	return protect
end

hg.organism.input_list.gordon_armor = function(org, bone, dmg, dmgInfo, ...)
	force = true
	local protect = protec(org, bone, dmg, dmgInfo, "torso", "gordon_armor", 0.5, 0.3, false, ...)
	return protect
end

hg.organism.input_list.gordon_arm_armor_left = function(org, bone, dmg, dmgInfo, ...)
	force = true
	local protect = protec(org, bone, dmg, dmgInfo, "arm", "gordon_arm_armor_left", 0.5, 0.3, false, ...)
	return protect
end


hg.organism.input_list.gordon_arm_armor_right = function(org, bone, dmg, dmgInfo, ...)
	force = true
	local protect = protec(org, bone, dmg, dmgInfo, "arm", "gordon_arm_armor_right", 0.5, 0.3, false, ...)
	return protect
end


hg.organism.input_list.gordon_leg_armor_left = function(org, bone, dmg, dmgInfo, ...)
	force = true
	local protect = protec(org, bone, dmg, dmgInfo, "leg", "gordon_leg_armor_left", 0.5, 0.3, false, ...)
	return protect
end

hg.organism.input_list.gordon_leg_armor_right = function(org, bone, dmg, dmgInfo, ...)
	force = true
	local protect = protec(org, bone, dmg, dmgInfo, "leg", "gordon_leg_armor_right", 0.5, 0.3, false, ...)
	return protect
end


hg.organism.input_list.gordon_calf_armor_left = function(org, bone, dmg, dmgInfo, ...)
	force = true
	local protect = protec(org, bone, dmg, dmgInfo, "leg", "gordon_calf_armor_left", 0.5, 0.3, false, ...)
	return protect
end


hg.organism.input_list.gordon_calf_armor_right = function(org, bone, dmg, dmgInfo, ...)
	force = true
	local protect = protec(org, bone, dmg, dmgInfo, "leg", "gordon_calf_armor_right", 0.5, 0.3, false, ...)
	return protect
end

-------------------------------------------------------------------

-- Combine armor
hg.organism.input_list.cmb_helmet = function(org, bone, dmg, dmgInfo, ...)
	force = true
	local protect = protec(org, bone, dmg, dmgInfo, "head", "cmb_helmet", 0.8, 0.7, true, ...)
	return protect
end

hg.organism.input_list.cmb_armor = function(org, bone, dmg, dmgInfo, ...)
	force = true
	local protect = protec(org, bone, dmg, dmgInfo, "torso", "cmb_armor", 0.9, 0.7, false, ...)
	return protect
end

hg.organism.input_list.cmb_arm_armor_left = function(org, bone, dmg, dmgInfo, ...)
	force = true
	local protect = protec(org, bone, dmg, dmgInfo, "arm", "cmb_arm_armor_left", 0.9, 0.7, false, ...)
	return protect
end


hg.organism.input_list.cmb_arm_armor_right = function(org, bone, dmg, dmgInfo, ...)
	force = true
	local protect = protec(org, bone, dmg, dmgInfo, "arm", "cmb_arm_armor_right", 0.9, 0.7, false, ...)
	return protect
end


hg.organism.input_list.cmb_leg_armor_left = function(org, bone, dmg, dmgInfo, ...)
	force = true
	local protect = protec(org, bone, dmg, dmgInfo, "leg", "cmb_leg_armor_left", 0.9, 0.7, false, ...)
	return protect
end

hg.organism.input_list.cmb_leg_armor_right = function(org, bone, dmg, dmgInfo, ...)
	force = true
	local protect = protec(org, bone, dmg, dmgInfo, "leg", "cmb_leg_armor_right", 0.9, 0.7, false, ...)
	return protect
end
-- metrocop armor
hg.organism.input_list.metrocop_helmet = function(org, bone, dmg, dmgInfo, ...)
	force = true
	local protect = protec(org, bone, dmg, dmgInfo, "head", "metrocop_helmet", 0.9, 0.7, true, ...)
	return protect
end

hg.organism.input_list.metrocop_armor = function(org, bone, dmg, dmgInfo, ...)
	force = true
	local protect = protec(org, bone, dmg, dmgInfo, "torso", "metrocop_armor", 0.9, 0.7, false, ...)
	return protect
end

-- protogen visor

hg.organism.input_list.protovisor = function(org, bone, dmg, dmgInfo, ...)
	force = true

	org.owner.armors_health = org.owner.armors_health or {}

	local protect = protec(org, bone, dmg, dmgInfo, "head", "protovisor", 0.8, 0.7, true, ...)
	
	org.owner.armors_health["protovisor"] = org.owner.armors_health["protovisor"] or 1
	org.owner.armors_health["protovisor"] = org.owner.armors_health["protovisor"] * math.max((1 - dmg * 10), 0)
	
	if org.owner.armors_health["protovisor"] == 0 then
		org.owner.armors["head"] = nil
	end
	//dmgInfo:GetAttacker():ChatPrint(tostring(org.owner.armors_health["protovisor"]))
	return protect
end

hook.Add("HG_ReplacePhrase", "MaskMuffed", function(ply, phrase, muffed, pitch)
	if IsValid(ply) and ply.armors and ply.armors["face"] == "mask2" then
		return ply, phrase, true, pitch
	end
end)