ENT={}
AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName		= "Swarm Projectile"

ENT.DeathTime=5

ENT.InfHealthPenalty = -2

function ENT:Initialize()
	if(SERVER)then
		self.Entity:SetModel("models/props_junk/PopCan01a.mdl")
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		self:SetUseType(SIMPLE_USE)
		self:DrawShadow(true)
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetMass(1)
			phys:Wake()
			phys:EnableMotion(true)
		end
		self.DieTime=CurTime()+self.DeathTime
		util.SpriteTrail( self, 0, Color( 200, 200, 0 ), false, 15, 1, 0.4, 1 / ( 15 + 1 ) * 0.5, "trails/plasma" )
		
						
		self.AcquiredGenes = self.AcquiredGenes or {}
		self.GeneticData = self.GeneticData or {}
	end
end

function ENT:Think()
	if(self.DieTime and self.DieTime<=CurTime())then
		self:Remove()
	end
end

function ENT:TryInfect( ent,amt )
	if((self.GeneticData["I"] or 0)>=3)then
		SWARM:TryInfect(ent,amt,self)
	end
end

function ENT:PhysicsCollide(coldata)
	if(self.Collided)then return end
	self.Collided = true
	local ent = coldata.HitEntity
	local dmg = DamageInfo()
	dmg:SetDamage(self.Damage)
	dmg:SetAttacker((IsValid(self:GetOwner()) and self:GetOwner()) or self)
	dmg:SetInflictor(self)
	ent:TakeDamageInfo(dmg)

	self:TryInfect(ent,20,(IsValid(self:GetOwner()) and self:GetOwner()) or self)
	
	self:Remove()
end
--[[
function ENT:Touch(ent)
	if(SERVER)then
		local dmg = DamageInfo()
		dmg:SetDamage(10)
		dmg:SetAttacker(self:GetOwner() or self)
		dmg:SetInflictor(self)
		ent:TakeDamageInfo(dmg)
		self:Remove()
	end
end]]

function ENT:Draw()

end

scripted_ents.Register(ENT,"ent_swm_projectile")