if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "SLAM"
SWEP.Category = "Weapons - Explosive"
SWEP.Instructions = "Selectable Lightweight Attack Munition or (M2/M3/M4 SLAM) is a small United States multi-purpose landmine produced by ATK Precision Fuze Company. It has a passive infrared sensor, and a magnetic influence sensor which allow it to be used as a demolition munition, off-route mine, or full-width belly attack mine."
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 4
SWEP.SlotPos = 4

SWEP.WorldModel = "models/mmod/weapons/w_slam.mdl"
SWEP.WorldModelReal = "models/mmod/weapons/c_slam.mdl"
SWEP.WorldModelExchange = false
SWEP.ViewModel = ""
SWEP.HoldType = "slam"

SWEP.HoldPos = Vector(-6,0,-2)
SWEP.HoldAng = Angle(-5,0,0)

SWEP.setlh = true
SWEP.setrh = true

SWEP.AnimList = {
	["deploy"] = {"tripmine_draw", 1, false},
    ["idle"] = {"tripmine_idle", 1, true},
	["attach"] = {"tripmine_attach1", 0.5, false}
}

if CLIENT then
    SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_slam")
    SWEP.IconOverride = "vgui/wep_jack_hmcd_slam"
    SWEP.BounceWeaponIcon = false
end

SWEP.offsetVec = Vector(2.7, -5, 0)
SWEP.offsetAng = Angle(-80, 180, 190)
local SLAMPlacementRadius = 80

function SWEP:Deploy()
	self:PlayAnim("deploy")

	return true
end

function SWEP:PlaceSLAM(pos, ang, tr)
    ang:RotateAroundAxis(ang:Right(), -90)
    ang:RotateAroundAxis(ang:Up(), 0)

    local ent = ents.Create("ent_hg_slam")
    ent:SetAngles(ang)
    ent:SetPos(pos)
    ent:Spawn()

    constraint.Weld(ent, tr.Entity, 0, tr.PhysicsBone or 0, 9999, true, true)
    self:SetPlaced(true)
    self:SetSLAM(ent)
    ent.owner = self:GetOwner()

    self:Remove()
end

function SWEP:InitAdd()
    self:SetHoldType("slam")
	self:PlayAnim("deploy")
end

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "Placed")
    self:NetworkVar("Entity", 0, "SLAM")
    self:NetworkVarNotify("Placed", self.OnVarChanged)
end

function SWEP:OnVarChanged(name, old, new)
    if not new then return end
    self.WorldModel = "models/mmod/weapons/w_slam.mdl"
    self.offsetVec = Vector(1.5, -12, -1)
    self.offsetAng = Angle(180, 80, 30)
end

local function InPlacementRadius(ply, tr)
    return tr.HitPos:DistToSqr(ply:GetPos()) <= SLAMPlacementRadius * SLAMPlacementRadius
end

local function CanPlace(ply, tr)
	if not tr.Hit or tr.HitSky or not tr.HitPos or not InPlacementRadius(ply, tr) then return false end
	if tr.Entity and IsValid(tr.Entity) and (tr.Entity:IsPlayer() or tr.Entity:IsNPC() or tr.Entity:IsNextBot() or tr.Entity:IsRagdoll() or tr.Entity:GetClass():find("slam")) then return false end

	return true
end

if CLIENT then
    local csent = ClientsideModel(SWEP.WorldModel)
    csent:SetNoDraw(true)
    
    function SWEP:DrawHUD()
        if self:GetPlaced() then return end
        if not IsValid(csent) then
            csent = ClientsideModel(self.WorldModel)
            csent:SetNoDraw(true)
        end
        local ply = self:GetOwner()
        local tr = ply:GetEyeTrace()

        if not CanPlace(ply, tr) then return end

        local pos, ang = tr.HitPos, tr.HitNormal:Angle()
        ang:RotateAroundAxis(ang:Right(), -90)
        ang:RotateAroundAxis(ang:Up(), 0)

        cam.Start3D()
            csent:SetPos(pos)
            csent:SetAngles(ang)
            csent:SetMaterial("models/wireframe")
            csent:DrawModel()
			csent:SetBodygroup(1, 1)
        cam.End3D()
    end
end

function SWEP:PrimaryAttack()
    local ply = self:GetOwner()
    
    if not self:GetPlaced() then
        local tr = ply:GetEyeTrace()
        if not CanPlace(ply, tr) then return end
        if CLIENT then return end
        local pos, ang = tr.HitPos, tr.HitNormal:Angle()
        pos = pos + ang:Forward() * 2

		self:PlayAnim("attach")
		timer.Simple(0.4, function()
			if IsValid(self) and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon() == self then
				self:PlaceSLAM(pos, ang, tr)
			end
		end)
    end
end

function SWEP:SecondaryAttack()
	return false
end