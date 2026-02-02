AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local red = Color( 255, 0, 0 )
function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	timer.Simple(0.1,function()
		if not IsValid(self) then return end
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
	end)
	self:SetUseType(ONOFF_USE)
	self:DrawShadow(true)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(5)
		phys:Wake()
		phys:EnableMotion(true)
	end
	self.Tail = util.SpriteTrail( self, 0, red, true, 5, 1, 0.5, 1 / ( 5 + 1 ) * 0.5, "sprites/combineball_trail_red_1" )
end

function ENT:AddThink()
	if not self.timer then return end
	self.nextthink = self.nextthink or CurTime()
	if self.nextthink > CurTime() then return end
	local time = self.timeToBoom - (CurTime() - self.timer)

	self.nextthink = CurTime() + 0.5 * math.max(time / (self.timeToBoom * 0.75),0.5) 
	
	if not self.Exploded then
		self:EmitSound("weapons/grenade/tick1.wav",65)
		hg.EmitAISound(self:GetPos(), 256, 2, 8)
	end

	if time < 0 and not self.Exploded then
		self:Explode()
	end
	--self:NextThink(CurTime() + 0.5 * math.max(time / (self.timeToBoom * 0.75),0.5))
	--return true
end

function ENT:PoopBomb()
	self.Tail:Remove()
	return math.random(100) == 100
end