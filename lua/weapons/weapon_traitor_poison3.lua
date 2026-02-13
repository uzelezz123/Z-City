if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_base"
SWEP.PrintName = "Cyanide canister"
SWEP.Instructions = "Produces gas, which prevents transport of electrons from cytochrome c to oxygen. As a result, the electron transport chain is disrupted, meaning that the cell can no longer aerobically produce ATP for energy. Tissues that depend highly on aerobic respiration, such as the central nervous system and the heart, are particularly affected."
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
SWEP.WorldModel = "models/jordfood/jtun.mdl"
if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_poisoncanister")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_poisoncanister"
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
SWEP.offsetAng = Angle(0, 0, 0)
SWEP.ModelScale = 1

if SERVER then
    function SWEP:OnRemove() end
end

function SWEP:DrawWorldModel()
	self.model = IsValid(self.model) and self.model or ClientsideModel(self.WorldModel)
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

	WorldModel:DrawModel()
end

function SWEP:Initialize()
	self:SetHold(self.HoldType)

	if self:GetOwner():IsNPC() then -- why not lol
		self.HoldType = "melee"
		self:SetHold(self.HoldType)
	end
end

function SWEP:SetHold(value)
	self:SetWeaponHoldType(value)
	self:SetHoldType(value)
	self.holdtype = value
end

function SWEP:Think()
end

SWEP.traceLen = 5

function SWEP:GetEyeTrace()
	return hg.eyeTrace( self:GetOwner())
end

if CLIENT then
	function SWEP:DrawHUD()
		if GetViewEntity() ~= LocalPlayer() then return end
		if LocalPlayer():InVehicle() then return end
        local tr = self:GetEyeTrace()
        local toScreen = tr.HitPos:ToScreen()

        surface.SetDrawColor(255,255,255,155)
        surface.DrawRect(toScreen.x-2.5, toScreen.y-2.5, 5, 5)
	end
end

function SWEP:DoPoison(tr)
    local owner = self:GetOwner()

    owner:EmitSound("physics/metal/soda_can_impact_hard2.wav", owner:IsNPC() and 75 or 40)

	local ent = ents.Create("ent_hg_cyanide_canister")
	ent:SetPos(owner:IsNPC() and owner:EyePos() or tr.HitPos)
	ent:Spawn()

    self:Remove()
	owner:SelectWeapon("weapon_hands_sh")
end

if SERVER then
    hook.Add("Org Clear", "RemovePoison3", function(org)
        org.poison3 = nil
		org.poison3notificate = nil
    end)

	hook.Add("Org Think", "poison3",function(owner, org, timeValue)
		if not owner:IsPlayer() or not owner:Alive() then return end
		if (not org.poison3) or (not org.alive) then return end
		
		if ((org.poison3 + 4) < CurTime()) and owner.Profession == "cook" then
			org.owner:Notify("It smells like almonds in here... Perfume, perhaps?", true, "cyanide", 3)
		end

		if (not org.poison3notificate) and ((org.poison3 + 20) < CurTime()) then
			org.poison3notificate = true
			org.owner:Notify("It's getting difficult to breathe... for some reason...", true, "cyanide2", 3)
			org.owner:EmitSound(ThatPlyIsFemale(org.owner) and "breathing/inhale/female/inhale_0"..math.random(5)..".wav" or "breathing/inhale/male/inhale_0"..math.random(4)..".wav",65)	
		end

		if (org.poison3 + 30) < CurTime() then
        	org.o2.regen = 0
		end
	end)
end

function SWEP:SecondaryAttack()
end

function SWEP:PrimaryAttack()
	if SERVER then
        local tr = self:GetOwner():IsNPC() and false or self:GetEyeTrace()

        self:DoPoison(tr)
	end
end

function SWEP:Reload()
end

function SWEP:CanBePickedUpByNPCs()
	return true -- why not lol
end

function SWEP:GetNPCRestTimes()
	return 0.1, 0.1
end