ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Motion Detector"
ENT.Spawnable = false
ENT.WorldModel = "models/mmod/weapons/w_slam.mdl"

ENT.Sound = "ambient/alarms/klaxon1.wav"
ENT.AlarmCD = 0

local developer = GetConVar("developer")
local offsetPos, offsetAng = Vector(0, 0, 6), Angle(-90, 180, 0)
function ENT:Think()
	local tr = {}
	local pos, ang = self:GetPos(), self:GetAngles()
	local pos, ang = LocalToWorld(offsetPos, offsetAng, pos, ang)
	tr.start = pos
	tr.endpos = tr.start + ang:Forward() * 700
	tr.filter = self
	tr.collisiongroup = COLLISION_GROUP_PLAYER
	local tr = util.TraceLine(tr)

	if developer:GetBool() and LocalPlayer():IsAdmin() then
		debugoverlay.Line(pos, tr.HitPos, 1, color_white, true)
	end

	if SERVER and tr.Hit and (tr.Entity:IsPlayer() or tr.Entity:IsNPC() or (tr.Entity:IsRagdoll() and tr.Entity:GetVelocity():LengthSqr() > 1)) then
		if self.AlarmCD > CurTime() or (tr.Entity:IsPlayer() and tr.Entity.PlayerClassName == "sc_guard") then return end
		self:ActivateAlarm(tr)

		self.AlarmCD = CurTime() + 1
	end

	self:NextThink(CurTime())
	return true
end