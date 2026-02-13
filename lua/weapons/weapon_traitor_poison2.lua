if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_base"
SWEP.PrintName = "VX vial"
SWEP.Instructions = "VX is an extremely toxic synthetic chemical compound in the organophosphorus class, specifically, a thiophosphonate. In the class of nerve agents, it was developed for military use in chemical warfare after translation of earlier discoveries of organophosphate toxicity in pesticide research."
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
SWEP.WorldModel = "models/props_junk/PopCan01a.mdl"
if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_poisonliquid")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_poisonliquid"
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
SWEP.offsetAng = Angle(0, 0, -10)
SWEP.ModelScale = 0.3

if SERVER then
    function SWEP:OnRemove() end
end

local mat = "models/mat_jack_hmcd_armor"
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
		WorldModel:SetMaterial(mat)
		WorldModel:SetPos(newPos)
		WorldModel:SetAngles(newAng)
		WorldModel:SetupBones()
	else
		WorldModel:SetPos(self:GetPos())
		WorldModel:SetAngles(self:GetAngles())
	end

	WorldModel:DrawModel()
end

function SWEP:SetHold(value)
	self:SetWeaponHoldType(value)
	self:SetHoldType(value)
	self.holdtype = value
end

function SWEP:Think()
	self:SetHold(self.HoldType)
end

SWEP.traceLen = 5

function SWEP:GetEyeTrace()
	return hg.eyeTrace(self:GetOwner())
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

function SWEP:DoPoison(ent)
    local owner = self:GetOwner()

    owner:EmitSound("snd_jack_hmcd_needleprick.wav",30)
	
	ent.poisoned = true

    self:Remove()
	owner:SelectWeapon("weapon_hands_sh")
end

if SERVER then
	hook.Add("PlayerUse","otravleno_dibil!!!",function(ply,ent)
		if IsValid(ent) and ent.poisoned then
			if ply.organism then
				ply.organism.poison2 = CurTime()
				ent.poisoned = nil
			end
		end
	end)

    hook.Add("Org Clear", "RemovePoison2", function(org)
        org.poison2 = nil
		org.poison2notificate = nil
    end)

	hook.Add("Org Think", "poison2",function(owner, org, timeValue)
		if not owner:IsPlayer() or not owner:Alive() then return end
		if (not org.poison2) or (not org.alive) then return end
		
		if (not org.poison2notificate) and ((org.poison2 + 15) < CurTime()) then
			org.poison2notificate = true
			org.owner:Notify("Something stops me from breathing normally.", true, "poison2", 3)
			org.owner:EmitSound( ( ThatPlyIsFemale(org.owner) and "vo/npc/female01/moan0"..math.random(5)..".wav" ) or "vo/npc/male01/moan0"..math.random(5)..".wav")
		end

		if (org.poison2 + 30) < CurTime() then
        	org.o2.regen = 0
		end
	end)
end

function SWEP:SecondaryAttack()
end

function SWEP:Initialize()
	self:SetHold(self.HoldType)
	self:SetModelScale(self.ModelScale)
	self:Activate()
	if IsValid(self:GetPhysicsObject()) then
		self:GetPhysicsObject():SetMass(5)
	end
end

function SWEP:PrimaryAttack()
	if SERVER then
        local tr = self:GetEyeTrace()

        if IsValid(tr.Entity) and IsValid(tr.Entity:GetPhysicsObject()) and not tr.Entity:IsPlayer() then
            self:DoPoison(tr.Entity)
        end
	end
end

function SWEP:Reload()
end