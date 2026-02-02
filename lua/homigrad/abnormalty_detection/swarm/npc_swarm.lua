ENT={}

SWARM_CV_SWARM_DeadPointsDiv = CreateConVar("swarm_drone_deadpointsdivider", 5, bit.bor(FCVAR_ARCHIVE), "Upon death points will randomly scatter to one nearby swarm unit and the number is the divider" )
SWARM_CV_SWARM_MeleeDmg = CreateConVar("swarm_drone_meleedmg", 6, bit.bor(FCVAR_ARCHIVE), "Melee damage from drones" )

SWARM_CV_SWARM_DetectRange = CreateConVar("swarm_drone_detectrange", 300, bit.bor(FCVAR_ARCHIVE), "Detect range" )
SWARM_CV_SWARM_ForgetRange = CreateConVar("swarm_drone_forgetrange", 500, bit.bor(FCVAR_ARCHIVE), "Enemy forget range" )
SWARM_CV_SWARM_ForgetTime = CreateConVar("swarm_drone_forgettime", 2, bit.bor(FCVAR_ARCHIVE), "Enemy forget time" )

AddCSLuaFile()
ENT.Spawnable = true

ENT.Base = "swarm_ai_base"	--Why dont just create an NPC?
ENT.Type = "ai"

ENT.PrintName     = "Drone (Swarm)"

ENT.m_fMaxYawSpeed = 100 -- Max turning speed
ENT.m_iClass = CLASS_HEADCRAB -- NPC Class

AccessorFunc( ENT, "m_iClass", "NPCClass" )
AccessorFunc( ENT, "m_fMaxYawSpeed", "MaxYawSpeed" )

ENT.Swarm = true

ENT.NextEnemyFind=0
ENT.EnemyFindCD=0

ENT.NextLeap=0
ENT.LeapCD=1

ENT.Points=0

ENT.BuildEnt="npc_swarm_mother"

ENT.InfectiousC = 1

ENT.MaxInfectedHealthMul = 2

ENT.ForgetRangeCVAR = SWARM_CV_SWARM_ForgetRange
ENT.ForgetTimeCVAR = SWARM_CV_SWARM_ForgetTime

function ENT:Initialize()

	if(SERVER)then
		self:SetupGenes()
		self.NextDeath = CurTime()+1500*self:GetLifeTimeMul(4)*SWARM_CV_DeathTimerMul:GetFloat()
		if(table.Count(self.GeneticData)==0)then
			self:MutateGenes(nil,10)
		end
		if(SWARM_CV_ExperementalModels:GetBool())then
			self:SetModel("models/swarm/drone.mdl")
		else
			self:SetModel("models/headcrab.mdl")
			self:SetColor(Color(220,255,220))
		end
		--models/swarm/drone.mdl
		--models/headcrab.mdl
		--self:SetModelScale(0.5,0)
		
		self:SetHullType( HULL_TINY )
		self:SetHullSizeNormal() 
		self:SetSolid( SOLID_BBOX )
		self:SetMoveType( MOVETYPE_STEP )
		self:CapabilitiesAdd( bit.bor( CAP_MOVE_GROUND, CAP_SQUAD, CAP_MOVE_JUMP ) )
		self:CapabilitiesRemove( bit.bor( CAP_OPEN_DOORS, CAP_AUTO_DOORS ) )
		
		self:SetHealth( 30*self:GetHealthMul(6) )
		self:SetMaxHealth(30)
		
		self.Faction=1
		--self:SetColor(Color(255,0,0))
		self:SetBloodColor(BLOOD_COLOR_GREEN)
		
		self.JustSpawned = CurTime()+2
		--self:SetNPCClass(CLASS_ALIEN_PREY)
	end
	--self:SetKeyValue( "additionalequipment", GetConVarString("gmod_npcweapon") )
end

local ignoreplayers = GetConVar("ai_ignoreplayers")
function ENT:OnTakeDamage( dmginfo )	--Taking damage...
	self:ApplyFireIntoleranceMul(dmginfo)
	dmginfo:SetDamage(dmginfo:GetDamage()/self:GetDefenceMul(dmginfo:GetDamageType(),2))
	local newhealth = self:Health()-dmginfo:GetDamage()
	local dudeF = dmginfo:GetAttacker().Faction
	local dude = dmginfo:GetAttacker()
	if(dudeF~=nil and dudeF==self.Faction)then return end
	self:SetHealth(newhealth)
	if(newhealth<=0 and !self.Died)then
		self.Died = true
		self:TaskStart_ShareDeathPoints()
		if(IsValid(self.SWARM_Mother))then
			self.SWARM_Mother:DisownNpc(self)
		end
		if(self.King)then
			--print(4)
			--PrintTable(self.CreatedNpcs)
			for ent, time in pairs( self.CreatedNpcs ) do
				--print(ent)
				if ( ent:IsValid() and ent:GetClass()=="npc_swarm" and ent!=self ) then
					ent.Points = ent.Points + 30
					ent.King = true
					ent.CreatedNpcs = self.CreatedNpcs
					ent.GeneticData = self.GeneticData
					ent.AcquiredGenes = self.AcquiredGenes
					ent.Hiding = CurTime()+5
					ent:SetColor(Color(255,150,0))
					break
				end
			end
		end
		self:HostileNotificationMother(dude,50)
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
	if(self.Hiding and self.Hiding<=CurTime())then
		self.Hiding=nil
		self:Build()
	end	

	if(self.MovingTo and self.MovingTo<=CurTime())then
		self.MovingTo=nil
	end
	
	if(SERVER and (!self.NextTryHide or self.NextTryHide<=CurTime()))then
		self.NextTryHide = CurTime() + 1
		local lastenem = self:GetEnemy()
		local ready = false
		if(IsValid(lastenem))then
			if(lastenem:GetPos():DistToSqr(self:GetPos())>200^2)then
				ready = true
			end
		else
			ready = true
		end
		if(self.Points>=30 and !self.Hiding and !self.MovingTo and ready)then
		--if(#ents.FindByClass(self.BuildEnt)<2)then
			self.Hiding=CurTime()+30
		end
	end
	
	if(SERVER and ((!self.NextEntityHullClearing or self.NextEntityHullClearing<=CurTime()) and !self.JustSpawned))then
		self.NextEntityHullClearing = CurTime() + 2
		SWARM:ClearEntityHull(self,5)
	end
end

function ENT:Build()
	--if(#ents.FindByClass(self.BuildEnt)>=2)then
	--	self.Hiding=nil
	--	return 
	--end
	if(self.Points<30)then return end
	self.Points=self.Points-30
	hel=ents.Create(self.BuildEnt)
	hel.GeneticData = self:CopyGenetics(self.GeneticData)
	hel.AcquiredGenes = self.AcquiredGenes
	hel:MutateGenes(nil,1)
	if(self.CreatedNpcs)then
		self:TransferMotherRights(hel)
	end
	hel:SetPos(self:GetPos()+Vector(0,0,0))
	hel:Spawn()
	hel:Activate()
	--if(self.King)then
	--	hel:MutateGenes(nil,10)
	--else
	--	hel:MutateGenes(nil,3)
	--end
	self:EmitSound('NPC_HeadCrab.Gib',35)	
	self:Remove()
end

function ENT:SWARM_OnGround( )
	if(util.QuickTrace(self:GetPos(),vector_up*-3,self).Hit)then
		return true
	end
	return false
end

function ENT:Leap( dir )
	if(!self.Leaping and self:SWARM_OnGround())then
		local lastenem = self:GetEnemy()
		self:SetSchedule( SCHED_COMBAT_FACE )
		self.Leaping=true
		self:MoveJumpStart(dir)
		self:SetIdealActivity(ACT_RANGE_ATTACK1)
		self:EmitSound("NPC_BlackHeadcrab.ImpactAngry")
		--self:SetLastPosition(pos)
	end
end

function ENT:MoveTo(pos,time)
	local lastenem = self:GetEnemy()
	if(!IsValid(lastenem) or (lastenem.Alive and !lastenem:Alive()) or lastenem:GetPos():Distance(self:GetPos())>(300))then
		self.MovingTo=CurTime()+time
		self:SetLastPosition(pos)
		self.Hiding=nil
		--print(4)
	end
end

function ENT:Touch(ent)
	if(self.Leaping and ent:GetClass()~=self:GetClass())then
		self.Leaping=false
		if(ent:IsPlayer() or ent:IsNPC())then
			local dmg = DamageInfo()
			dmg:SetDamage(SWARM_CV_SWARM_MeleeDmg:GetFloat()*self:GetDamageMul(5))
			dmg:SetDamageType(DMG_SLASH)
			dmg:SetAttacker(self)
			dmg:SetInflictor(self)
			ent:TakeDamageInfo(dmg)
			
			self:TryInfect(ent,20,self)
			self:EmitSound("NPC_BlackHeadcrab.Impact")--NPC_FastHeadcrab.Bite--Egg.Crack--NPC_BlackHeadcrab.Impact
			self:MoveJumpStop()

			self:SetSchedule( SCHED_FORCED_GO_RUN )
			--self:SetNPCState(NPC_STATE_COMBAT)
		
			self.Points=self.Points+10
			--self:SetParent(ent)
		end
	end
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
	
	if(!IsValid(lastenem) or (lastenem.Alive and !lastenem:Alive()) or lastenem:GetPos():Distance(self:GetPos())>(SWARM_CV_SWARM_ForgetRange:GetInt()))then
	
		local et = ents.FindInSphere( self:GetPos(), data.Radius or SWARM_CV_SWARM_DetectRange:GetInt() )
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
			if(!self.MovingTo)then
				self:SetLastPosition(bestenemy:GetPos())
			end
			self:SetEnemy( bestenemy, true )
			--self:SetNPCState(NPC_STATE_COMBAT)
			self:UpdateEnemyMemory( bestenemy, bestenemy:GetPos() )
			--self:TaskComplete()
			return
		end		
		
	end
	if(IsValid(lastenem))then
		if(!self.MovingTo)then
			self:SetLastPosition(lastenem:GetPos())
		end
		self:UpdateEnemyMemory( lastenem, lastenem:GetPos() )
		--self:SetNPCState(NPC_STATE_COMBAT)
		--self:TaskComplete()
		return
	end
	
	self:SetEnemy( NULL )

end

function ENT:TaskStart_ShareDeathPoints( data )
	local et = ents.FindInSphere( self:GetPos(), 200 )
	for k, ent in pairs( et ) do
		if ( ent:IsValid() and ent.Points and ent:IsNPC() and ent!=self ) then
			ent.Points = ent.Points + math.Round(self.Points/SWARM_CV_SWARM_DeadPointsDiv:GetFloat())
			--print(math.Round(self.Points/SWARM_CV_SWARM_DeadPointsDiv:GetFloat()))
			break
		end
	end
end

function ENT:TaskStart_GetPoints( data )
	if(IsValid(self.SWARM_Mother))then return end
	local et = ents.FindInSphere( self:GetPos(), 200 )

	for k, v in pairs( et ) do
		if ( v:IsValid() and v.Points and v.Points<self.Points and v:IsNPC() and !v.King ) then
			self.Points=self.Points+v.Points
			v.Points=0
		end
	end
end

function ENT:SelectSchedule( iNPCState )
	
	if(self.MovingTo)then
		self:SetSchedule( SCHED_FORCED_GO_RUN )
	elseif(self.Hiding)then
		self:SetSchedule( SCHED_TAKE_COVER_FROM_ENEMY )
	elseif(self.JustSpawned)then
		self:SetSchedule( SCHED_RUN_RANDOM )
	else
		if(!self.Leaping)then
			if(IsValid(self:GetEnemy()))then
				self:SetSchedule( SCHED_FORCED_GO_RUN )
			else
				self:SetSchedule( SCHED_IDLE_WANDER )
			end
		else
			self:SetIdealActivity(ACT_RANGE_ATTACK1)
			--self:SetSchedule( SCHED_RANGE_ATTACK1 )
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
	if(!self.NextPointsGather or self.NextPointsGather<=CurTime())then
		self.NextPointsGather = CurTime() + 2
		self:TaskStart_GetPoints()
	end

	local lastenem = self:GetEnemy()
	if( IsValid(lastenem) and (!lastenem.Alive or lastenem:Alive()) )then
		if(IsValid(lastenem.FakeRagdoll))then
			if(lastenem:GetPos():Distance(self:GetPos())<100)then	
				if(self.NextLeap<=CurTime())then	
					self.NextLeap=CurTime()+self.LeapCD			
					local dmg = DamageInfo()
					dmg:SetDamage(SWARM_CV_SWARM_MeleeDmg:GetInt()*self:GetDamageMul(2.5))
					dmg:SetDamageType(DMG_SLASH)
					dmg:SetAttacker(self)
					dmg:SetInflictor(self)
					lastenem.FakeRagdoll:TakeDamageInfo(dmg)
					
					self:TryInfect(lastenem, 20, self)
					self:EmitSound("NPC_BlackHeadcrab.Impact")--NPC_FastHeadcrab.Bite--Egg.Crack--NPC_BlackHeadcrab.Impact
				
					self.Points=self.Points+10					
				end	
			end
		else
			if(lastenem:GetPos():Distance(self:GetPos())<200)then
				local traceinfo = {
					start = self:GetPos(),
					endpos = lastenem:GetShootPos(),
					filter = self,
				}
				local trace = util.TraceLine(traceinfo)
				if(trace.Entity==lastenem)then
					if(self.NextLeap<=CurTime())then	
						self.NextLeap=CurTime()+self.LeapCD			
						self:Leap( ( (lastenem:GetShootPos()+lastenem:GetVelocity()/3)-self:GetPos() ):GetNormalized()*550 )
					end
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
	--print(self:GetIdealActivity())
	self:MaintainActivity()
	
end

scripted_ents.Register(ENT,"npc_swarm")
list.Set( "NPC", "npc_swarm", {
	Name = "Drone (Swarm)",
	Class = "npc_swarm",
	Category = "Swarm"
})