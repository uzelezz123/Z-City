ENT={}

AddCSLuaFile()
ENT.Base = "base_ai"	--Why dont just create an NPC?
ENT.Type = "ai"

ENT.PrintName     = "Swarm _Bullseye"

ENT.m_fMaxYawSpeed = 0 -- Max turning speed
ENT.m_iClass = CLASS_HEADCRAB -- NPC Class

AccessorFunc( ENT, "m_iClass", "NPCClass" )
AccessorFunc( ENT, "m_fMaxYawSpeed", "MaxYawSpeed" )


function ENT:Initialize()

	if(SERVER)then

		--self:SetModel("models/zombie/zombie_soldier.mdl")
		--self:SetColor(Color(220,255,220))
		--self:SetModelScale(0.5,0)
		
		self:SetHullType( HULL_TINY_CENTERED )
		self:SetHullSizeNormal() 
		self:SetSolid( SOLID_BBOX )
		self:SetMoveType( MOVETYPE_STEP )
		self:CapabilitiesAdd( bit.bor( CAP_MOVE_GROUND, CAP_SQUAD, CAP_MOVE_JUMP, CAP_OPEN_DOORS, CAP_AUTO_DOORS ) )
		--self:CapabilitiesRemove( bit.bor( CAP_OPEN_DOORS, CAP_AUTO_DOORS ) )
		
		self:SetHealth( 1000 )
		self:DrawShadow(false)
		--self:SetColor(Color(255,0,0))
		--self:SetBloodColor(BLOOD_COLOR_GREEN)
	end
	--self:SetKeyValue( "additionalequipment", GetConVarString("gmod_npcweapon") )
end

function ENT:Draw()
	--self:DrawModel()
end

function ENT:OnTakeDamage( dmginfo )	--Taking damage...

end


function ENT:Think()

end

function ENT:Touch(ent)

end


----
----

function ENT:Classify(  )
	return self.m_iClass
end

--[[
function ENT:GetRelationship( entity )
	if(entity.Classify)then
		class=entity:Classify()
	end
		
	if(class and class==CLASS_PLAYER)then
		return D_HT
	elseif(entity:GetClass()=="player")then
		return D_HT
	else
		return D_LI
	end
end]]


function ENT:SelectSchedule( iNPCState )
	

	
end


function ENT:OnCondition( iCondition )

	--Msg( self, " Condition: ", iCondition, " - ", self:ConditionName(iCondition), "\n" )

end

function ENT:RunAI( strExp )

end

scripted_ents.Register(ENT,"npc_swarm_bullseye")