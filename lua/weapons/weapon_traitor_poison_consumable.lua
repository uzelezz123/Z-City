--\\
--; https://ru.wikipedia.org/wiki/%D0%A6%D0%B8%D0%B0%D0%BD%D0%B8%D0%B4_%D0%BA%D0%B0%D0%BB%D0%B8%D1%8F
--; При больших дозах или поступлении яда натощак потеря сознания и смерть пострадавшего наступает практически мгновенно 
--; (отравленные мгновенно падают замертво) или через несколько секунд после мучительного удушья, судорог, которые часто сопровождаются пронзительными 
--; криками (иногда до хрипоты) и чрезвычайно сильным расширением зрачков.
--; Нейтрализуется от глюкозы и сам по себе т.к. нестабилен
--//

if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_base"
SWEP.PrintName = "Cyanide Capsule"
SWEP.InstructionsBasic = "Potassium cyanide powder in a capsule\nToxic (time to incapacitation ~90 seconds from 140mg)\nSugary drinks will decompose KCN upon consumption\nNOT to be mixed with food or applied to bandages, you don't want to kill anyone with it do you?"	--; TODO Mansion tea cup
SWEP.Instructions = SWEP.InstructionsBasic
SWEP.Category = "ZCity Other"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.HoldType = "normal"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/tfa_ins2/upgrades/phy_optic_eotech.mdl"
SWEP.Model = "models/Items/Flare.mdl"

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_poisonpowder")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_poisonpowder"
	SWEP.BounceWeaponIcon = false
end

SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Slot = 3
SWEP.SlotPos = 4
SWEP.WorkWithFake = false
SWEP.offsetVec = Vector(5, -1.5, -0.6)
SWEP.offsetAng = Angle(0, 60, 90)
SWEP.ModelScale = 0.3

if SERVER then
	function SWEP:OnRemove() end
end

function SWEP:SetupDataTables()
	self:NetworkVar("Int", 0, "UsesLeft")
end

function SWEP:Initialize()
	self:SetHold(self.HoldType)
	
	if(SERVER)then
		self:SetUsesLeft(5)
	end
	
	self:MarkupUpdate()
end

function SWEP:MarkupUpdate()
	if(self:GetUsesLeft() == 0)then
		self.Instructions = self.InstructionsBasic .. "\n\nIt's empty."
		self.InfoMarkup = nil
	else
		self.Instructions = self.InstructionsBasic .. "\n\n" .. self:GetUsesLeft() * 140 .. " mg left"
		self.InfoMarkup = nil
	end
end

local mat, clr = "debug/env_cubemap_model", Color(185, 180, 180)
function SWEP:DrawWorldModel()
	self.model = IsValid(self.model) and self.model or ClientsideModel(self.Model)
	local WorldModel = self.model
	local owner = self:GetOwner()
	WorldModel:SetNoDraw(true)
	WorldModel:SetModelScale(self.ModelScale or 1)
	if IsValid(owner) then
		local offsetVec = self.offsetVec
		local offsetAng = self.offsetAng
		local boneid = owner:LookupBone(((owner.organism and owner.organism.rarmamputated) or (owner.zmanipstart ~= nil and owner.zmanipseq == "interact" and not owner.organism.larmamputated)) and "ValveBiped.Bip01_L_Hand" or "ValveBiped.Bip01_R_Hand")
		if not boneid then return end
		local matrix = owner:GetBoneMatrix(boneid)
		if not matrix then return end
		local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())
		WorldModel:SetPos(newPos)
		WorldModel:SetAngles(newAng)
		WorldModel:SetupBones()
	else
		WorldModel:SetPos(self:GetPos())
		WorldModel:SetAngles(self:GetAngles())
	end
	WorldModel:SetMaterial(mat)
	WorldModel:SetColor(clr)

	WorldModel:DrawModel()
end

function SWEP:SetHold(value)
	self:SetWeaponHoldType(value)
	self:SetHoldType(value)
	self.holdtype = value
end

function SWEP:Think()
	self:SetHold(self.HoldType)
	
	if(CLIENT)then
		self:MarkupUpdate()
	end
end

SWEP.traceLen = 5

function SWEP:GetEyeTrace()
	return hg.eyeTrace(self:GetOwner())
end

local poisonable_entities = {
	["weapon_bigconsumable"] = true,
	["weapon_smallconsumable"] = true,
	["weapon_bandage_sh"] = true,
	["weapon_painkillers"] = true,
	["weapon_betablock"] = true,
}

if CLIENT then
	local colred = Color(150,0,0)
	function SWEP:DrawHUD()
		if GetViewEntity() ~= LocalPlayer() then return end
		if LocalPlayer():InVehicle() then return end
		local tr = self:GetEyeTrace()
		local toScreen = tr.HitPos:ToScreen()

		if(IsValid(tr.Entity) and self:CanPoison(tr.Entity))then
			draw.SimpleText("Poison "..(tr.Entity.PrintName or "Consumable"), "HomigradFont", toScreen.x + 3, toScreen.y + 27, color_black, TEXT_ALIGN_CENTER)
			draw.SimpleText("Poison "..(tr.Entity.PrintName or "Consumable"), "HomigradFont", toScreen.x, toScreen.y + 25, colred, TEXT_ALIGN_CENTER)
			surface.SetDrawColor(195,0,0,155)
			surface.DrawRect(toScreen.x-2.5, toScreen.y-2.5, 5, 5)
		else
			surface.SetDrawColor(255,255,255,155)
			surface.DrawRect(toScreen.x-2.5, toScreen.y-2.5, 5, 5)
		end
	end
end

function SWEP:CanPoison(ent)
	if(poisonable_entities[ent:GetClass()])then
		return true
	end
	
	return false
end

function SWEP:DoPoison(ent)
	local owner = self:GetOwner()

	ent.ConsumePoisoned_KCN = (ent.ConsumePoisoned_KCN or 0) + 1
	
	owner:ChatPrint((ent.PrintName or "Item").." was poisoned!")

	self:SetUsesLeft(math.max(self:GetUsesLeft(0) - 1, 0))
end

if(SERVER)then
    hook.Add("Org Clear", "RemovePoison_KCN", function(org)
        org.Poison_KCN = nil
    end)

	hook.Add("Org Think", "Poison_KCN",function(owner, org, timeValue)
		if not owner:IsPlayer() or not owner:Alive() then return end
		if((not org.Poison_KCN) or (not org.alive))then return end
		
		local poison = org.Poison_KCN
		local poison_start_time = poison.StartTime
		local poison_potency = poison.Potency
		
		if((poison_start_time + (20 / poison_potency)) < CurTime() and (!poison.NextNotification1 or poison.NextNotification1 <= CurTime()))then
			poison.NextNotification1 = CurTime() + math.max(5 / poison_potency, 1)
			
			if not org.otrub then org.owner:EmitSound((ThatPlyIsFemale(org.owner) and "vo/npc/female01/moan0"..math.random(5)..".wav" ) or "vo/npc/male01/moan0"..math.random(5)..".wav") end
		end
		
		if((poison_start_time + (22 / poison_potency)) < CurTime())then
			org.stamina[1] = math.min(org.stamina[1], 50 / poison_potency)
			org.o2[1] = math.min(org.o2[1], org.o2.range / poison_potency)
			org.disorientation = math.max(org.disorientation, 10 * poison_potency)
			org.pulse = math.max(org.pulse, 120 + 10 * poison_potency)
		end

		if((poison_start_time + (90 / poison_potency)) < CurTime())then
			-- org.o2[1] = math.max(org.o2[1] - (poison_potency - 1) * 5, 5)
        	org.o2.regen = 0
		end
	end)
end

function SWEP:SecondaryAttack()
end

function SWEP:PrimaryAttack()
	if self:GetNextPrimaryFire() > CurTime() then return end
	if SERVER then
		if(self:GetUsesLeft() == 0)then
			self:GetOwner():ChatPrint("The capsule is empty.")
			self:SetNextPrimaryFire(CurTime() + 0.8)

			return
		end

		local tr = self:GetEyeTrace()

		if(IsValid(tr.Entity) and self:CanPoison(tr.Entity))then
			self:DoPoison(tr.Entity)
			self:SetNextPrimaryFire(CurTime() + 0.2)
		end
	end
end

function SWEP:Reload()
end
