if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Handcuffs"
SWEP.Instructions = "Restraint devices designed to secure an individual's wrists in proximity to each other. For the rulers of order in the form of police helps to avoid unnecessary problems when transporting detainees. Sometimes they may not be enough."
SWEP.Category = "ZCity Other"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Wait = 2
SWEP.Primary.Next = 0
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.HoldType = "slam"
SWEP.ViewModel = ""

SWEP.WorldModel = "models/grinchfox/weapons/handcuffs/dropped_handcuffs.mdl"
SWEP.WorldModelReal = "models/grinchfox/weapons/handcuffs/c_handcuffs.mdl"
SWEP.WorldModelExchange = false

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_handcuffs")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_handcuffs"
	SWEP.BounceWeaponIcon = false
end

SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Slot = 3
SWEP.SlotPos = 4
SWEP.WorkWithFake = true

SWEP.setlh = true
SWEP.setrh = true

SWEP.AnimList = {
    -- self:PlayAnim( anim,time,cycling,callback,reverse,sendtoclient )
	["deploy"] = { "anim_draw", 1, false },
    ["attack"] = { "anim_fire", 2.5, false, false, function(self)
		if CLIENT then return end
		local tr = self:GetEyeTrace()
		self:Tie(tr)
	end },
	["idle"] = {"anim_idle", 5, true}
}

SWEP.HoldPos = Vector(0,-1,0)
SWEP.HoldAng = Angle(0,0,0)

SWEP.CallbackTimeAdjust = 0.5

if SERVER then
    function SWEP:OnRemove() end
end

function SWEP:SetHold(value)
	self:SetWeaponHoldType(value)
	self:SetHoldType(value)
	self.holdtype = value
end

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "Holding")
end

function SWEP:Animation()
end

function SWEP:Think()
	self:SetHold(self.HoldType)
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

function SWEP:SecondaryAttack()
end

function SWEP:Initialize()
	self:SetHold(self.HoldType)
end

local function handcuff(ragdoll)
	local body = ragdoll:GetPhysicsObjectNum(0)
	local lh = ragdoll:GetPhysicsObjectNum(hg.realPhysNum(ragdoll,5))
	lh:SetPos(body:GetPos())

	local rh = ragdoll:GetPhysicsObjectNum(hg.realPhysNum(ragdoll,7))
	rh:SetPos(body:GetPos())

	local weld = constraint.Weld(ragdoll, ragdoll, hg.realPhysNum(ragdoll,7), hg.realPhysNum(ragdoll,5), 0, true, false)

	local handcuffs = ents.Create("prop_physics")
	handcuffs:SetModel("models/weapons/spy/w_handcuffs.mdl")
	handcuffs:SetPos(rh:GetPos())

	local ang = rh:GetAngles()
	ang:RotateAroundAxis(ang:Right(),-20)
	handcuffs:SetAngles(ang)

	handcuffs:FollowBone(ragdoll,ragdoll:TranslatePhysBoneToBone(hg.realPhysNum(ragdoll,7)))
	handcuffs:SetMoveType(MOVETYPE_VPHYSICS)
	handcuffs:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	handcuffs:Spawn()

	ragdoll.handcuffed = true
	ragdoll.handcuffs = {weld, handcuffs}
end

hg.handcuff = handcuff

SWEP.CoolDown = 0

function SWEP:Tie(tr)
    local ent = tr.Entity
	--self:EmitSound()
	--timer.Simple(1,function()
		if IsValid(ent) and IsValid(self) and IsValid(self:GetOwner()) and self:GetOwner():Alive() and self:GetOwner():GetPos():Distance(ent:GetPos()) < 500 then 
			if IsValid(ent) and (ent:IsRagdoll() or (ent:IsPlayer() and ent:GetVelocity():Length() < 1)) and hg.RagdollOwner(ent) ~= self:GetOwner() then
				--if ent.handcuffed then return end
				self:GetOwner():ChatPrint("Threat handcuffed.")
				
				if ent:IsRagdoll() then handcuff(ent) end

				ent:EmitSound("weapons/357/357_reload3.wav")
				ent:PhysWake()

				local org = ent.organism
				if IsValid(hg.RagdollOwner(ent)) and hg.RagdollOwner(ent):Alive() then
					local ply = hg.RagdollOwner(ent)
					ply:SelectWeapon("weapon_hands_sh")
					ply:SetNetVar("handcuffed",true)
				end
				
				self:GetOwner():SelectWeapon("weapon_hands_sh")

				org.handcuffed = true
				ent:SetNetVar("handcuffed",true)
				self:Remove()
			end
		end
	--end)
end

if SERVER then
	hook.Add("Org Clear","Removehandcuffs",function(org)
		org.handcuffed = false 
		if IsValid(org.owner) and org.owner:IsPlayer() then
			org.owner:SetNetVar("handcuffed",false)
		end
	end)

	hook.Add("Ragdoll_Create","Addhandcuffs", function(ply, ragdoll)
		if ply.organism.handcuffed or ragdoll.organism and ragdoll.organism.handcuffed then
			handcuff(ragdoll)
			ply:SelectWeapon("weapon_hands_sh")
		end
	end)

	hook.Add("PlayerCanPickupWeapon","handcuffDisallowpickup",function(ply,ent)
		if ply.organism.handcuffed and ent:GetClass() != "weapon_handcuffs_key" then
			return false
		end
	end)

	hook.Add("PlayerUse","restrictuser",function(ply, ent)
		if ply.organism.handcuffed then
			return false
		end
	end)
end

hook.Add( "PlayerSwitchWeapon", "WeaponSwitchExample", function( ply, oldWeapon, newWeapon )
	if (ply:GetNetVar("handcuffed",false) or not IsValid(newWeapon)) then
		local hands = ply:GetWeapon(newWeapon:GetClass() == "weapon_handcuffs_key" and "weapon_handcuffs_key" or "weapon_hands_sh")
		if IsValid(hands) and SERVER then
			ply:SetActiveWeapon(hands)
		end

		return true
	end
end )

function SWEP:PrimaryAttack()
	if SERVER then
		if self.CoolDown > CurTime() then return end
        local tr = self:GetEyeTrace()
		--self:SetHolding(math.min(self:GetHolding() + 7, 100))
		self:PlayAnim("attack")
		timer.Simple(0.5,function()
			if IsValid(self) then return end
			self:EmitSound("weapons/357/357_reload3.wav")
		end)
		--if self:GetHolding() < 100 then return end
		self.CoolDown = CurTime() + 2
	end
end

function SWEP:Reload()
end
