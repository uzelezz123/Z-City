--\\ SLOTS... i think too many for armor, but this is cool!
ZC_CLOTHES_SLOT_TORSO = 0
ZC_CLOTHES_SLOT_PANTS = 1
ZC_CLOTHES_SLOT_BOOTS = 2
ZC_CLOTHES_SLOT_BACKPACK = 3

ZC_ARMOR_SLOT_HEAD = 4
    ZC_ARMOR_SLOT_FACE = 5
        ZC_ARMOR_SLOT_EYES = 6
    ZC_ARMOR_SLOT_EARS = 7

ZC_ARMOR_SLOT_TORSO = 8
    ZC_ARMOR_SLOT_UPPERARM_L = 9
        ZC_ARMOR_SLOT_FOREARM_L = 10
    ZC_ARMOR_SLOT_UPPERARM_R = 11
        ZC_ARMOR_SLOT_FOREARM_R = 12  

ZC_ARMOR_SLOT_BELLY = 13

ZC_ARMOR_SLOT_PELVIS = 14
    ZC_ARMOR_SLOT_THIGH_L = 15
        ZC_ARMOR_SLOT_SHIN_L = 16
    ZC_ARMOR_SLOT_THIGH_R = 17
        ZC_ARMOR_SLOT_SHIN_R = 18
--//

--\\ Balistic materials
    ZC_ARMOR_MATERIAL_CERAMIC = 3
    ZC_ARMOR_MATERIAL_TITAN = 1.8
    ZC_ARMOR_MATERIAL_ARSTEEL = 1.4

    ZC_ARMOR_MATERIAL_UHMWPE = 1.2
    ZC_ARMOR_MATERIAL_UHMWPE_CERAMIC = 0.85
    ZC_ARMOR_MATERIAL_UHMWPE_ARSTEEL = 0.7
    ZC_ARMOR_MATERIAL_KEVLAR_TITAN = 0.55

    ZC_ARMOR_MATERIAL_KEVLAR = 0.9
    ZC_ARMOR_MATERIAL_KEVLAR_CERAMIC = 0.75
    ZC_ARMOR_MATERIAL_KEVLAR_ARSTEEL = 0.6
    ZC_ARMOR_MATERIAL_KEVLAR_TITAN = 0.45

    ZC_ARMOR_MATERIAL_FIBERGLASS = 5
    ZC_ARMOR_MATERIAL_POLYCARBONATE = 4.5
--//
--\\ Protection classes
--II - 4 protection, IIIA - 8 protection, III - 12 protection, III+ - 16 protection, IV - 22 protection
    ZC_ARMOR_PROTCLASS_I = 1.5
    ZC_ARMOR_PROTCLASS_II = 4
    ZC_ARMOR_PROTCLASS_IIIA = 8
    ZC_ARMOR_PROTCLASS_III = 12
    ZC_ARMOR_PROTCLASS_III_PLUS = 16
    ZC_ARMOR_PROTCLASS_IV = 22
--//

hg.EquipmentAppearanceSlots = {
    ["face"] = ZC_ARMOR_SLOT_FACE,
    ["head"] = ZC_ARMOR_SLOT_HEAD,
    ["spine"] = ZC_ARMOR_SLOT_PELVIS,
    ["torso"] = ZC_ARMOR_SLOT_TORSO
}

hg = hg or {}
hg.organism = hg.organism or {}

if CLIENT then
    local function DrawFirstPersonHelmet(self, ply)
        if ply:GetNetVar("headcrab") then return end
        if not ply:Alive() then return end
        if ply.organism and ply.organism.otrub then return end
        if not self.Overlay then return end

        local vecAdjust =   self.Overlay.PosAdjust
        local fFov =        self.Overlay.Fov
        local setMat =      self.Overlay.ModelMaterial

        if not IsValid(ply.FirstPersonHelmetModel) then
            ply.FirstPersonHelmetModel = ClientsideModel(self.Overlay.Model)
            ply.FirstPersonHelmetModel:SetNoDraw(true)
            return
        end

        if not IsValid(ply.FirstPersonHelmetModel2) then
            ply.FirstPersonHelmetModel2 = ClientsideModel(self.Overlay.Model)
            ply.FirstPersonHelmetModel2:SetNoDraw(true)
            ply.FirstPersonHelmetModel2:SetModelScale(1.05)
            return
        end

        local mdl = ply.FirstPersonHelmetModel
        local mdl2 = ply.FirstPersonHelmetModel2

        if mdl:GetModel() != self.Overlay.Model then
            mdl:SetModel(self.Overlay.Model)
        end

        if mdl2:GetModel() != self.Overlay.Model then
            mdl2:SetModel(self.Overlay.Model)
        end
        
        if setMat and !mdl.matseted1 then
            mdl:SetSubMaterial(0,setMat)
            mdl.matseted = false
            mdl.matseted1 = true
            --print('huy')
        elseif !setMat and !mdl.matseted then
            --print("huy")
            mdl:SetSubMaterial(0,nil)
            mdl.matseted = true
            mdl.matseted1 = false
        end

        local gp = false
        local view = render.GetViewSetup()
        cam.Start3D(view.origin,view.angles,view.fov + fFov,nil,nil,nil,nil,1,10)
            --cam.IgnoreZ(true)
            local viewpunching = GetViewPunchAngles() / 2
            viewpunching.r = 0
            local ang = view.angles + viewpunching
            mdl:SetRenderOrigin(view.origin + ang:Forward() * (vecAdjust.x + (gp and vecAdjust2.x or 0)) + ang:Right() * (vecAdjust.y + (gp and vecAdjust2.y or 0)) + ang:Up() * (vecAdjust.z + (gp and vecAdjust2.z or 0)))
            mdl2:SetRenderOrigin(view.origin + ang:Forward() * (vecAdjust.x + (gp and vecAdjust2.x or 0)) + ang:Right() * (vecAdjust.y + (gp and vecAdjust2.y or 0)) + ang:Up() * (vecAdjust.z + (gp and vecAdjust2.z or 0)))
            
            if self.Overlay.AngAdjust then
                ang:RotateAroundAxis(ang:Right(), self.Overlay.AngAdjust[1] )
                ang:RotateAroundAxis(ang:Forward(), self.Overlay.AngAdjust[2] )
                ang:RotateAroundAxis(ang:Up(), self.Overlay.AngAdjust[3] )
            end

            if self.RenderModifyPosAng then
                self:RenderModifyPosAng(entDrawOn, pos, ang)
            end

            mdl:SetRenderAngles(ang)
            mdl2:SetRenderAngles(ang)
            mdl:SetParent(ply, ply:LookupBone("ValveBiped.Bip01_Head1"))
            render.SetColorModulation(1,1,1)
                render.SetStencilWriteMask( 0xFF )
                render.SetStencilTestMask( 0xFF )
                render.SetStencilReferenceValue( 0 )
                render.SetStencilCompareFunction( STENCIL_ALWAYS )
                render.SetStencilPassOperation( STENCIL_KEEP )
                render.SetStencilFailOperation( STENCIL_KEEP )
                render.SetStencilZFailOperation( STENCIL_KEEP )
                render.ClearStencil()

                -- Enable stencils
                render.SetStencilEnable( true )
                -- Set everything up everything draws to the stencil buffer instead of the screen
                render.SetStencilReferenceValue( 1 )
                render.SetStencilCompareFunction( STENCIL_NOTEQUAL )
                render.SetStencilPassOperation( STENCIL_REPLACE )
                render.SetBlend(0)
                    mdl2:DrawModel()
                render.SetBlend(1)
                render.SetStencilCompareFunction( STENCIL_EQUAL )
                mdl:DrawModel()
                if not hg.ConVars.potatopc:GetBool() then
                    DrawBokehDOF(8,0.9,15)
                end
                -- Let everything render normally again
                render.SetStencilEnable( false )
            render.SetColorModulation(1,1,1)
            --cam.IgnoreZ(false)
        cam.End3D()
    end
    
    hg.DrawFirstPersonHelmet = DrawFirstPersonHelmet
    local scrw, scrh = ScrW() + 1, ScrH() + 1

    local function DrawSimpleOverlay(self, ply)
        local mat = self.OverlayMaterial
        surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( mat )
		surface.DrawTexturedRect(-1, -1, scrw, scrh)
    end

    hg.DrawSimpleOverlay = DrawSimpleOverlay

    hook.Add("Post Pre Post Processing", "renderEquipmentOverlay", function()
        local Overlay = lply:GetEquipmentBySlot(ZC_ARMOR_SLOT_HEAD)
        
        if lply:IsLocal() then return end
        if IsValid(Overlay) then 
            Overlay:DrawOverlay(lply)
        end
        Overlay = IsValid(lply:GetEquipmentBySlot(ZC_ARMOR_SLOT_EYES)) and lply:GetEquipmentBySlot(ZC_ARMOR_SLOT_EYES) or Overlay
        if IsValid(Overlay) then 
            Overlay:DrawOverlay(lply)
        end
    end)
end


local function ArmorEffect(placement, armor, dmgInfo, org, hit, prot)
	if prot < 0 then return end
	local eff = "Impact"
	local dir = -dmgInfo:GetDamageForce()
	dir:Normalize()
	local effdata = EffectData()
	
	effdata:SetOrigin((hit and isvector(hit) and hit or dmgInfo:GetDamagePosition()) - dir)
	effdata:SetNormal(dir)
	effdata:SetMagnitude(0.25)
	effdata:SetRadius(2)
	effdata:SetScale(0.1)
	effdata:SetNormal(dir)
	effdata:SetStart((hit and isvector(hit) and hit or dmgInfo:GetDamagePosition()) + dir)
	effdata:SetEntity(hg.GetCurrentCharacter(org.owner))
	effdata:SetSurfaceProp(77)
	effdata:SetDamageType(dmgInfo:GetDamageType())

	EmitSound("physics/metal/metal_solid_impact_bullet"..math.random(4)..".wav",dmgInfo:GetDamagePosition(),0,CHAN_AUTO,1,55,nil,100)
	util.Effect(eff,effdata)
end

--\\ Armor balistic settings
    --[[
        ENT.HitBoxSet = "TestVest"
        ENT.Protection = 10
        ENT.ProtectionDamageMul = 0.6
        ENT.PenetratedDamageMul = 0.8

        ENT.BalisticMaterial = ZC_ARMOR_MATERIAL_KEVLAR -- actually this is just a mul of degradation armor
        ENT.Durability = 100
        ENT.DurabilityMax = 100
        ENT.DurabilityWarranty = 15

        ENT.NeedPunch = false
    --]]
--//
local developer = GetConVar("developer")
local function protec(org, bone, dmg, dmgInfo, placement, boneindex, dir, hit, ricochet, hitbox, oldOrgan)
    local armor = org.owner:GetEquipmentBySlot(placement)
	if !IsValid(armor) then return end

    local HitBoxName = hitbox[9]
    local plates = armor.PlatesLinks
    plate = plates and armor[plates[HitBoxName]] or armor

    local durablityMul = math.min(plate.Durability / (plate.DurabilityMax - plate.DurabilityWarranty), 1)
    local protectionDamageMul = math.min(plate.ProtectionDamageMul * (1 + (1 - durablityMul)), 1)
    local penetratedDamageMul = math.min(plate.PenetratedDamageMul * (1 + (1 - durablityMul)), 1)

    local penetration = (dmgInfo:GetInflictor().bullet and dmgInfo:GetInflictor().bullet.Penetration or 1)
    local prot = plate.Protection * durablityMul

	prot = prot - penetration

	if plate.NeedPunch then
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
	
	ArmorEffect(placement, plate, dmgInfo, org, hit, prot)

    local oldDurability = plate.Durability
    if dmgInfo:IsDamageType(DMG_BULLET + DMG_SLASH) and ( (!org.oldPlate or org.oldPlate != plates[HitBoxName]) or (!org.oldDmgInfo1 or org.oldDmgInfo1 != dmgInfo) ) then
        org.oldPlate = plates[HitBoxName]
        org.oldDmgInfo1 = dmgInfo
        plate.Durability = math.max(plate.Durability - (penetration * plate.BalisticMaterial), 0)
    else
        org.oldPlate = nil
    end

    if developer:GetBool() and SERVER then
        local attacker = dmgInfo:GetAttacker()
        if IsValid(attacker) and attacker:IsPlayer() and attacker:IsAdmin() then
            attacker:PrintMessage(HUD_PRINTCONSOLE, "\n--// Damage to armor on " .. (org.owner:IsPlayer() and org.owner:Nick() or "Ragdoll[".. org.owner:EntIndex() .."]"))
            attacker:PrintMessage(HUD_PRINTCONSOLE, "--|| Armor: " .. armor.PrintName .. " | HitBox: " .. HitBoxName .. " | Plate: " .. plates[hitbox[9]])
            attacker:PrintMessage(HUD_PRINTCONSOLE, "--|| OldDur ".. oldDurability ..", Dur ".. plate.Durability ..", Prot ".. prot ..", Dmg ".. dmg ..", Pentr ".. penetration)
            attacker:PrintMessage(HUD_PRINTCONSOLE, "--\\\\ Penetrated? " .. (prot < 0 and "Yes." or "No.") .. "\n\n" )
        end
    end

    if not org.oldDmgInfo or org.oldDmgInfo != dmgInfo then
        org.oldSideLink = armor.SideLinks and armor.SideLinks[HitBoxName] or nil
        armor.nodamagetypeChange = false
    end

    if armor.SideLinks and armor.SideLinks[HitBoxName] != org.oldSideLink then
        armor.nodamagetypeChange = true
    end

    if oldOrgan and !oldOrgan[7] then
        armor.nodamagetypeChange = true
    end

	if prot < 0 then
        org.oldSideLink = armor.SideLinks and armor.SideLinks[HitBoxName] or nil
        org.oldDmgInfo = dmgInfo
		dmgInfo:ScaleDamage(penetratedDamageMul)
		dmgInfo:SetDamageForce(dmgInfo:GetDamageForce() * penetratedDamageMul )
        if dmgInfo:GetInflictor().bullet then
            dmgInfo:GetInflictor().bullet.Penetration = math.max(dmgInfo:GetInflictor().bullet.Penetration * penetratedDamageMul, 0)
        end
		return
	end
    
    if not org.oldDmgInfo or (org.oldDmgInfo != dmgInfo) or armor.SideLinks and !armor.nodamagetypeChange then
        dmgInfo:SetDamageType(DMG_CLUB)
        dmgInfo:SetDamageForce(dmgInfo:GetDamageForce() * protectionDamageMul)
        dmgInfo:ScaleDamage(protectionDamageMul)
    end

	return 1
end

hg.organism = hg.organism or {}
hg.organism.input_list = hg.organism.input_list or {}

function hg.organism:AddArmorInputList(strName, nPlacement)
    hg.organism.input_list[strName] = function(org, bone, dmg, dmgInfo, ...)
        local protect = protec(org, bone, dmg, dmgInfo, nPlacement, ...)
        return protect
    end
end

load_from_armor_file = false
local function loadArmor() 
    local path = "homigrad/equipment_system/entities/"
    local files = file.Find(path.."*.lua", "LUA")
    for k,v in ipairs(files) do
        load_from_armor_file = true
        AddCSLuaFile(path .. v)
        include(path .. v)
    end
end

hook.Add("HG_BaseHitBoxSetLoaded","LoadArmor",function() 
    load_from_armor_file = true 
    loadArmor() 
end)

hook.Add("Initialize", "init-atts", loadArmor)

hook.Add("Think","RemoveMeLoadArmor",function()
    hook.Remove("Think","RemoveMeLoadArmor")
    if !HG_BaseHitBoxSetLoaded then return end 
    loadArmor()
end)

--\\ concommands

    concommand.Add("hg_eqipment_enable", function(ply, cmd, args)
        if !IsValid(ply) then return end
        if !ply:Alive() or !ply.organism or ply.organism.otrub then return end
        if !args[1] or !tonumber(args[1]) then return end
        local Equipment = ply:GetNetVar("zc_equipment", {})
        if not Equipment[tonumber(args[1])] then return end
        local Equip = Entity(Equipment[tonumber(args[1])])
        if !IsValid(Equip) then return end

        if Equip.Enable then
            Equip:Enable(ply)
        end
    end)

--//