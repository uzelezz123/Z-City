ENT={}

SWARM_CV_SENTRY_ProjectileDmg = CreateConVar("swarm_sentry_projectiledmg", 6, bit.bor(FCVAR_ARCHIVE), "Projectile damage from sentries" )


SWARM_CV_SENTRY_DetectRange = CreateConVar("swarm_sentry_detectrange", 600, bit.bor(FCVAR_ARCHIVE), "Detect range" )
SWARM_CV_SENTRY_ForgetRange = CreateConVar("swarm_sentry_forgetrange", 900, bit.bor(FCVAR_ARCHIVE), "Enemy forget range" )
SWARM_CV_SENTRY_ForgetTime = CreateConVar("swarm_sentry_forgettime", 5, bit.bor(FCVAR_ARCHIVE), "Enemy forget time" )

AddCSLuaFile()
ENT.Spawnable = true

ENT.Base = "swarm_ai_base"	--Why dont just create an NPC?
ENT.Type = "ai"

ENT.PrintName     = "Swarm Sentry"

ENT.m_fMaxYawSpeed = 10 -- Max turning speed
ENT.m_iClass = CLASS_ZOMBIE -- NPC Class

AccessorFunc( ENT, "m_iClass", "NPCClass" )
AccessorFunc( ENT, "m_fMaxYawSpeed", "MaxYawSpeed" )

ENT.NextEnemyFind=0
ENT.EnemyFindCD=0

ENT.NextShoot=0
ENT.ShootCD=5

ENT.Swarm = true

ENT.InfectiousC = 2

ENT.ForgetRangeCVAR = SWARM_CV_SENTRY_ForgetRange
ENT.ForgetTimeCVAR = SWARM_CV_SENTRY_ForgetTime

function ENT:Initialize()

	if(SERVER)then
		self:SetupGenes()
		self.NextDeath = CurTime()+2000*self:GetLifeTimeMul(4)*SWARM_CV_DeathTimerMul:GetFloat()
		self:SetModel("models/headcrabblack.mdl")
		self:SetColor(Color(220,255,220))
		--self:SetModelScale(0.5,0)
		
		self:SetHullType( HULL_TINY )
		self:SetHullSizeNormal() 
		self:SetSolid( SOLID_BBOX )
		self:SetMoveType( MOVETYPE_STEP )
		self:CapabilitiesAdd( bit.bor( CAP_MOVE_GROUND, CAP_SQUAD ) )
		self:CapabilitiesRemove( bit.bor( CAP_OPEN_DOORS, CAP_AUTO_DOORS ) )
		
		self:SetHealth( 30*self:GetHealthMul(3) )
		self:SetMaxHealth( 150 )

		--self:SetColor(Color(255,0,0))
		self:SetBloodColor(BLOOD_COLOR_GREEN)
		
		self.JustSpawned = CurTime()+2
	end
	--self:SetKeyValue( "additionalequipment", GetConVarString("gmod_npcweapon") )
end

local ignoreplayers = GetConVar("ai_ignoreplayers")
function ENT:OnTakeDamage( dmginfo )	--Taking damage...
	self:ApplyFireIntoleranceMul(dmginfo)
	dmginfo:SetDamage(dmginfo:GetDamage()/self:GetDefenceMul(dmginfo:GetDamageType(),4))
	local newhealth = self:Health()-dmginfo:GetDamage()
	local dudeF = dmginfo:GetAttacker().Faction
	local dude = dmginfo:GetAttacker()
	if(dudeF~=nil and dudeF==self.Faction)then return end
	self:SetHealth(newhealth)
	if(newhealth<=0 and !self.Died)then
		self.Died = true
		if(IsValid(self.SWARM_Mother))then
			self.SWARM_Mother:DisownNpc(self)
		end
		self:Remove()
	end
	if((dude:IsNPC() and (dude:Disposition(self)==D_HT or dude:Disposition(self)==D_FR)) or (dude:IsPlayer() and !ignoreplayers:GetBool()))then
		self:SetEnemy( dude, true )
		self:UpdateEnemyMemory( dude, dude:GetPos() )

	end
	self:HostileNotificationMother(dude,dmginfo:GetDamage())
end


function ENT:Think()
	if(SERVER)then
		self:SetNPCState(NPC_STATE_NONE)
		if(SWARM_CV_AllowSpeed:GetBool())then
			self:SetVelocity(self:GetMoveVelocity()*(self:GetSpeedMul(2)-1))
		end
		self:DeathThink()
	end

	if(SERVER and (!self.NextDropToFloor or self.NextDropToFloor<=CurTime()) and !self.Leaping and self:GetVelocity():LengthSqr()<5)then
		self.NextDropToFloor = CurTime()+5
		self:DropToFloor()
	end

	if(!self.NextEnemyUpdate or self.NextEnemyUpdate<=CurTime())then
		self.NextEnemyUpdate=CurTime()+0.3
		self:ValidateEnemyData( )
	end

	local parent = self:GetParent()
	if(IsValid(parent))then
		parent.SwarmPerc=(parent.SwarmPerc or 0)+FrameTime()*2
		parent.Swm=true
	end
	if(self.JustSpawned and self.JustSpawned<=CurTime())then
		self.JustSpawned=nil
	end
	
	if(SERVER and ((!self.NextEntityHullClearing or self.NextEntityHullClearing<=CurTime()) and !self.JustSpawned))then
		self.NextEntityHullClearing = CurTime() + 1
		SWARM:ClearEntityHull(self,20)
	end
end

function ENT:Shoot( dir )
	self:SetIdealActivity(ACT_RANGE_ATTACK1)
	hel=ents.Create('ent_swm_projectile')
	hel:SetPos(self:GetPos()+Vector(0,0,10))
	hel:Spawn()
	hel:Activate()
	hel:SetOwner(self)
	hel.Damage = SWARM_CV_SENTRY_ProjectileDmg:GetFloat()*self:GetDamageMul(8)
	self:EmitSound('NPC_HeadCrab.Gib',35)
	
	hel.GeneticData = table.Copy(self.GeneticData)
	
	local phys = hel:GetPhysicsObject()
	if IsValid(phys) then		
		phys:SetVelocity(dir)
	end
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

function ENT:TaskStart_FindEnemy( data )	
	if(data==nil)then data = {} end

	local lastenem = self:GetEnemy()
	
	if(!IsValid(lastenem) or (lastenem.Alive and !lastenem:Alive()) or lastenem:GetPos():Distance(self:GetPos())>(data.Radius or SWARM_CV_SENTRY_ForgetRange:GetInt()))then
	
		local et = ents.FindInSphere( self:GetPos(), data.Radius or SWARM_CV_SENTRY_DetectRange:GetInt() )
		local bestdistance = math.huge
		local bestenemy = nil
		for k, v in pairs( et ) do

			if ( v:IsValid() && v != self && (self:Disposition(v)==D_HT or self:Disposition(v)==D_FR) and (!v.Alive or v:Alive()) and self:IsEntityPossibleEnemy(v) ) then
				local dist = v:GetPos():DistToSqr(self:GetPos())
				if(bestdistance>dist and (!v:IsPlayer() or !ignoreplayers:GetBool()))then
					bestenemy=v
					bestdistance=dist
				end
			end

		end
		if(bestenemy)then
			--ghh=CurTime()
			self:SetLastPosition(bestenemy:GetPos())
			self:SetEnemy( bestenemy, true )
			--self:SetNPCState(NPC_STATE_COMBAT)
			self:UpdateEnemyMemory( bestenemy, bestenemy:GetPos() )
			--self:TaskComplete()
			return
		end		
		
	end
	if(IsValid(lastenem))then
		self:SetLastPosition(lastenem:GetPos())
		self:UpdateEnemyMemory( lastenem, lastenem:GetPos() )
		--self:SetNPCState(NPC_STATE_COMBAT)
		--self:TaskComplete()
		return
	end
	
	self:SetEnemy( NULL )
end


function ENT:SelectSchedule( iNPCState )
	if(self.JustSpawned)then
		self:SetSchedule( SCHED_RUN_RANDOM )
	else
		if(IsValid(self:GetEnemy()))then
			self:SetSchedule( SCHED_FORCED_GO_RUN )
		else
			self:SetSchedule( SCHED_IDLE_WANDER )
		end
	end
end


function ENT:OnCondition( iCondition )

	--Msg( self, " Condition: ", iCondition, " - ", self:ConditionName(iCondition), "\n" )

end

function ENT:Draw()
	self:DrawModel()
end

function ENT:RunAI( strExp )
--self:SetIdealActivity(ACT_IDLE_AIM_RIFLE_STIMULATED)
	local lastenem = self:GetEnemy()
	if( IsValid(lastenem) and (!lastenem.Alive or lastenem:Alive()) )then
		local aimpos = lastenem:GetShootPos()
		if(IsValid(lastenem.fakeragdoll))then
			aimpos=lastenem.fakeragdoll:GetPos()
		end
	
		if(lastenem:GetPos():Distance(self:GetPos())<300)then	
			local traceinfo = {
				start = self:GetPos(),
				endpos = aimpos,
				filter = self,
			}
			local trace = util.TraceLine(traceinfo)
			if(trace.Entity==lastenem or trace.Entity==lastenem.fakeragdoll)then
				if(self.NextShoot<=CurTime())then	
					self.NextShoot=CurTime()+self.ShootCD			
					self:Shoot( ( (aimpos+lastenem:GetVelocity()/4)-self:GetPos() ):GetNormalized()*750 )
				end
			end
		end
	end

	if(self.NextEnemyFind<=CurTime())then	
		self.NextEnemyFind=CurTime()+self.EnemyFindCD
		self:TaskStart_FindEnemy()
	end

	if ( self:IsRunningBehavior() ) then
		return true
	end

	if ( self:DoingEngineSchedule() ) then
		return true
	end

	if ( self.CurrentSchedule ) then
		self:DoSchedule( self.CurrentSchedule )
	end

	if ( !self.CurrentSchedule ) then
		self:SelectSchedule()
	end

	self:MaintainActivity()
end
scripted_ents.Register(ENT,"npc_swarm_sentry")
list.Set( "NPC", "npc_swarm_sentry", {
	Name = "Sentry",
	Class = "npc_swarm_sentry",
	Category = "Swarm"
})