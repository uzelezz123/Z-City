ENT={}

SWARM_CV_Sentinel_MeleeDmg = CreateConVar("swarm_sentinel_meleedmg", 15, bit.bor(FCVAR_ARCHIVE), "Melee damage" )
SWARM_CV_Sentinel_BleedDur = CreateConVar("swarm_sentinel_bleedduration", 6, bit.bor(FCVAR_ARCHIVE), "Bleeding duration" )


AddCSLuaFile()
ENT.Spawnable = true

ENT.Base = "swarm_ai_base"	--Why dont just create an NPC?
ENT.Type = "ai"

ENT.PrintName     = "Swarm Sentinel"

ENT.m_fMaxYawSpeed = 50 -- Max turning speed
ENT.m_iClass = CLASS_ZOMBIE -- NPC Class

AccessorFunc( ENT, "m_iClass", "NPCClass" )
AccessorFunc( ENT, "m_fMaxYawSpeed", "MaxYawSpeed" )

ENT.Swarm = true

ENT.NextEnemyFind=0
ENT.EnemyFindCD=0

ENT.NextShoot=0
ENT.ShootCD=1

ENT.NextAttack=0
ENT.AttackCD=1

ENT.Points=0

ENT.MeleeRange = 110
ENT.MeleeRangeBonus = 20

ENT.Anim="barf_humanoid"--2471

ENT.InfectiousC = 3

ENT.CantMove =true

ENT.MaxInfectedHealthMul = 2

function ENT:Initialize()

	if(SERVER)then
		self:SetupGenes()
		self.NextDeath = CurTime()+3000*self:GetLifeTimeMul(4)*SWARM_CV_DeathTimerMul:GetFloat()
		self:SetModel("models/swarm/sentinel.mdl")
		--self:SetColor(Color(220,255,220))
		--self:SetModelScale(0.5,0)
		
		--self:SetAngles(Angle(0,0,180))
		
		self:SetHullType( HULL_MEDIUM_TALL )
		self:SetHullSizeNormal()
		self:SetSolid( SOLID_BBOX )
		self:SetMoveType( MOVETYPE_NONE )
		self:CapabilitiesAdd( bit.bor( CAP_MOVE_GROUND, CAP_SQUAD ) )
		self:CapabilitiesRemove( bit.bor( CAP_OPEN_DOORS, CAP_AUTO_DOORS ) )
		
		self:SetHealth( 200*self:GetHealthMul(5) )
		self:SetMaxHealth(1000)

		--self:SetColor(Color(255,0,0))
		self:SetBloodColor(BLOOD_COLOR_GREEN)


		
		self:DropToFloor()
		self._DropToFloor = true
	end
	--self:SetKeyValue( "additionalequipment", GetConVarString("gmod_npcweapon") )
end

function ENT:OnRemove( )	
	if(IsValid(self.Bullseye))then
		self.Bullseye:Remove()
	end
end

local ignoreplayers = GetConVar("ai_ignoreplayers")
function ENT:OnTakeDamage( dmginfo )	--Taking damage...
	self:ApplyFireIntoleranceMul(dmginfo)
	--print(dmginfo:GetDamage())
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
	--if((dude:IsNPC() and (dude:Disposition(self)==D_HT or dude:Disposition(self)==D_FR)) or (dude:IsPlayer() and !ignoreplayers:GetBool()))then
		--print("TRIGGERED BY",dude)
		--self:SetEnemy( dude, true )
		--self:UpdateEnemyMemory( dude, dude:GetPos() )
		--self.RunAway = nil
		--self:TaskComplete()
	--end
	self:HostileNotificationMother(dude,dmginfo:GetDamage())
end

function ENT:Attack( ent )
	if(!self.Attacking and self:OnGround())then
		self.Attacking = CurTime()+0.8
		self.AttackEnemy = ent
		self._Attacking = true
		self:EmitSound("NPC_BlackHeadcrab.ImpactAngry")
		self:SetSchedule( SCHED_COMBAT_FACE )
		self:SetIdealActivity(ACT_MELEE_ATTACK1)
	end
end

function ENT:Think()
	if(SERVER)then
		self:SetNPCState(NPC_STATE_NONE) -- Hack to make it blind
		self:DeathThink()
	end

	if(self._DropToFloor)then
		self:DropToFloor()
		self._DropToFloor = false
	end
	local parent = self:GetParent()
	if(IsValid(parent))then
		parent.SwarmPerc=(parent.SwarmPerc or 0)+FrameTime()*2
		parent.Swm=true
	end

	
	if(IsValid(self.Bullseye))then
		self.Bullseye:SetPos(self:GetPos()+Vector(0,0,10))
	end
	
	--self:SetAngles(Angle(0,0,180))
	
	if(self.Attacking and self.Attacking<=CurTime())then
		self.Attacking = nil
		if(IsValid(self.AttackEnemy) and self.AttackEnemy:GetPos():Distance(self:GetPos())<(self.MeleeRange+self.MeleeRangeBonus))then
			local dmg = DamageInfo()
			dmg:SetDamage(SWARM_CV_Sentinel_MeleeDmg:GetInt()*self:GetDamageMul(5))
			dmg:SetDamageType(DMG_SLASH)
			dmg:SetAttacker(self)
			dmg:SetInflictor(self)
			self.AttackEnemy:TakeDamageInfo(dmg)
			if(SWARM_CV_Sentinel_BleedDur:GetInt()!=0)then
				--local time = SWARM_CV_Thumper_KOTime:GetFloat()
				--if(SWARM_CV_Thumper_ScaleKOTime:GetBool())then
				--	time = math.max((1-math.min(self.AttackEnemy:Health()/self.AttackEnemy:GetMaxHealth(),1))*SWARM_CV_Thumper_KOScaleTime:GetFloat(),0.2)
				--end
				SWARM:ApplyBleed(self.AttackEnemy,SWARM_CV_Sentinel_BleedDur:GetFloat()*self:GetDamageMul(5),self)
				self:EmitSound("Wood_Panel.Strain")
			end
			local phys = self.AttackEnemy:GetPhysicsObject()
			if(IsValid(phys) and !self.AttackEnemy:IsPlayer())then
				phys:ApplyForceCenter(-(self.AttackEnemy:HeadTarget(self:GetShootPos())-self:GetShootPos()):GetNormalized()*4450*self:GetDamageMul(5))
				phys:ApplyTorqueCenter(VectorRand()*1450)
			elseif(self.AttackEnemy:IsPlayer())then
				self.AttackEnemy:SetVelocity(-(self.AttackEnemy:HeadTarget(self:GetShootPos())-self:GetShootPos()):GetNormalized()*200*self:GetDamageMul(5))
			end
			
			self:TryInfect(self.AttackEnemy,20,self)
			self:EmitSound("NPC_BlackHeadcrab.Impact")--NPC_FastHeadcrab.Bite--Egg.Crack--NPC_BlackHeadcrab.Impact
			self.Points=self.Points+10
		end
		self.AttackEnemy = nil
	end
end

function ENT:Touch(ent)

end


----
----

function ENT:Classify(  )
	return self.m_iClass
end

function ENT:TaskStart_FindEnemy( data )
	if(data==nil)then data = {} end

	local lastenem = self:GetEnemy()
	--self:EmitSound("npc/stalker/stalker_alert"..math.random(1,3).."b.wav",65)
	if(!IsValid(lastenem) or (lastenem.Alive and !lastenem:Alive()) or lastenem:GetPos():Distance(self:GetPos())>(self.MeleeRange))then
	
		local et = ents.FindInSphere( self:GetPos(), data.Radius or 500 )
		local bestdistance = math.huge
		local bestenemy = nil
		for _, v in pairs( et ) do
			if ( v:IsValid() && v != self && (self:Disposition(v)==D_HT or self:Disposition(v)==D_FR) and (!v.Alive or v:Alive()) and self:IsEntityPossibleEnemy(v,-1) ) then
				local dist = v:GetPos():DistToSqr(self:GetPos())
				if(bestdistance>dist and (!v:IsPlayer() or !ignoreplayers:GetBool()))then
					bestenemy=v
					bestdistance=dist
				end
			end
		end
		if(bestenemy)then
			--ghh=CurTime()
			if(!self.MovingTo)then
				self:SetLastPosition(bestenemy:GetPos())
			end
			self:SetEnemy( bestenemy, true )
			self:UpdateEnemyMemory( bestenemy, bestenemy:GetPos() )
			--self.RunAway = nil
			self:TaskComplete()
			return
		end		
		
	end
	if(IsValid(lastenem))then
		return
	end

	self:SetEnemy( NULL )
	self:ClearEnemyMemory( )
	--print("NULLING")
end

if(SERVER)then
	ENT.schd_IDLE = ai_schedule.New( "Idle" )
	ENT.schd_IDLE:EngTask( "TASK_WAIT", 0 )
	
	ENT.schd_FACE = ai_schedule.New( "Face" )
	ENT.schd_FACE:EngTask( "TASK_FACE_ENEMY", 0 )
	--ENT.schd_IDLE:EngTask( "TASK_WAIT", 1 )
	--ENT.schd_FACE:EngTask( "TASK_WAIT_FACE_ENEMY", 0 )
	
	ENT.schd_ATTACK = ai_schedule.New( "Attack" )
	ENT.schd_ATTACK:EngTask( "TASK_MELEE_ATTACK1", 0 )
	ENT.schd_ATTACK:EngTask( "TASK_WAIT_FACE_ENEMY", 0 )
	
	ENT.schd_ATTACK2 = ai_schedule.New( "Attack2" )
	ENT.schd_ATTACK2:EngTask( "TASK_MELEE_ATTACK2", 0 )
	ENT.schd_ATTACK2:EngTask( "TASK_WAIT_FACE_ENEMY", 0 )
end

function ENT:SelectSchedule( iNPCState )
	if(!self.Attacking)then
		--print(4)
		if(IsValid(self:GetEnemy()))then
			self:StartSchedule(self.schd_FACE)
		else
			self:StartSchedule(self.schd_IDLE)
		end
	else
		--print(1)
		if(self._Attacking)then
			self._Attacking = nil
			if(math.random(0,1)==0)then
				self:StartSchedule(self.schd_ATTACK)
			else
				self:StartSchedule(self.schd_ATTACK2)
			end
		end
	end
end

function ENT:OnCondition( iCondition )

	--Msg( self, " Condition: ", iCondition, " - ", self:ConditionName(iCondition), "\n" )

end

--function ENT:Draw()
	--if(!self._RenderInited)then
		--self._RenderInited = true
		--self:SetRenderAngles(Angle(0,0,180))
		--self:SetRenderOrigin(self:GetPos())
	--end
	--self:DrawModel()
--end

function ENT:RunAI( strExp )
	--print(self.Points)
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

	local lastenem = self:GetEnemy()
	if( IsValid(lastenem) and (!lastenem.Alive or lastenem:Alive()) )then
		if(IsValid(lastenem.fakeragdoll))then
			if(lastenem:GetPos():Distance(self:GetPos())<self.MeleeRange)then
				if(self.NextAttack<=CurTime())then
					self.NextAttack=CurTime()+self.AttackCD
					local dmg = DamageInfo()
					dmg:SetDamage(SWARM_CV_Sentinel_MeleeDmg:GetInt())
					dmg:SetDamageType(DMG_SLASH)
					dmg:SetAttacker(self)
					dmg:SetInflictor(self)
					lastenem:TakeDamageInfo(dmg)
					
					self:TryInfect(lastenem,20,self)
					self:EmitSound("NPC_BlackHeadcrab.Impact")--NPC_FastHeadcrab.Bite--Egg.Crack--NPC_BlackHeadcrab.Impact
					
					self.Points=self.Points+10
				end	
			end
		else
			if(lastenem:GetPos():Distance(self:GetPos())<self.MeleeRange)then
				local traceinfo = {
					start = self:GetShootPos(),
					endpos = lastenem:HeadTarget(self:GetShootPos()),
					filter = self,
				}
				local trace = util.TraceLine(traceinfo)
				if(trace.Entity==lastenem)then
					if(self.NextAttack<=CurTime())then
						self.NextAttack=CurTime()+self.AttackCD
						self:Attack( lastenem )
					end
				end
			end
		end
	end

	self:MaintainActivity()
	
end

scripted_ents.Register(ENT,"npc_swarm_sentinel")
list.Set( "NPC", "npc_swarm_sentinel", {
	Name = "Sentinel",
	Class = "npc_swarm_sentinel",
	Category = "Swarm"
})