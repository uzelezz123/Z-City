ENT={}

SWARM_CV_Thumper_AllowMelee = CreateConVar("swarm_thumper_allowmelee", 1, bit.bor(FCVAR_ARCHIVE), "Allows melee attacks for thumpers" )
SWARM_CV_Thumper_AllowPsych = CreateConVar("swarm_thumper_allowpsych", 1, bit.bor(FCVAR_ARCHIVE), "Allows 'psych' attacks for thumpers" )
SWARM_CV_Thumper_MeleeDmg = CreateConVar("swarm_thumper_meleedmg", 20, bit.bor(FCVAR_ARCHIVE), "Melee damage from thumpers" )

SWARM_CV_Thumper_ALLOWKO = CreateConVar("swarm_thumper_allowknockdown", 1, bit.bor(FCVAR_ARCHIVE), "Allows knockdown upon melee attack for thumpers" )
SWARM_CV_Thumper_KOTime = CreateConVar("swarm_thumper_knockdowntime", 1, bit.bor(FCVAR_ARCHIVE), "Knockdown time from thumpers" )
SWARM_CV_Thumper_KOScaleTime = CreateConVar("swarm_thumper_knockdowntimeforscale", 2, bit.bor(FCVAR_ARCHIVE), "Knockdown time WHEN swarm_thumper_scaleknockdowntime is 1" )
SWARM_CV_Thumper_ScaleKOTime = CreateConVar("swarm_thumper_scaleknockdowntime", 0, bit.bor(FCVAR_ARCHIVE), "Scale(using victim health) knockdown time?" )
SWARM_CV_Thumper_AKOTime = CreateConVar("swarm_thumper_knockdownrecoverytime", 2, bit.bor(FCVAR_ARCHIVE), "Knockdown recovery time from thumpers" )

SWARM_CV_Thumper_PsychDmg = CreateConVar("swarm_thumper_psychdmg", 2, bit.bor(FCVAR_ARCHIVE), "Psych attack damage from thumpers" )
SWARM_CV_Thumper_PsychRange = CreateConVar("swarm_thumper_psychrange", 500, bit.bor(FCVAR_ARCHIVE), "Psych atttack range of thumpers" )
SWARM_CV_Thumper_PsychCD = CreateConVar("swarm_thumper_psychcooldown", 5, bit.bor(FCVAR_ARCHIVE), "Psych cooldown of thumpers" )
SWARM_CV_Thumper_PsychCDRand = CreateConVar("swarm_thumper_psychcooldownrandomness", 2, bit.bor(FCVAR_ARCHIVE), "Randomness of psych cooldown +math.Rand(-number,0)" )
SWARM_CV_Thumper_PsychInvert = CreateConVar("swarm_thumper_psychtimecalcinvert", 1, bit.bor(FCVAR_ARCHIVE), "Invert psych time calculations" )

SWARM_CV_Thumper_DetectRange = CreateConVar("swarm_thumper_detectrange", 200, bit.bor(FCVAR_ARCHIVE), "Detect range of thumper(radius of echolocation circle)" )
SWARM_CV_Thumper_ForgetRange = CreateConVar("swarm_thumper_forgetrange", 500, bit.bor(FCVAR_ARCHIVE), "Enemy forget range of thumper" )
SWARM_CV_Thumper_ForgetTime = CreateConVar("swarm_thumper_forgettime", 5, bit.bor(FCVAR_ARCHIVE), "Enemy forget time of thumper" )

AddCSLuaFile()
ENT.Base = "swarm_ai_base"	--Why dont just create an NPC?
ENT.Type = "ai"

ENT.PrintName     = "Swarm Thumper"

ENT.m_fMaxYawSpeed = 100 -- Max turning speed
ENT.m_iClass = CLASS_ZOMBIE -- NPC Class

AccessorFunc( ENT, "m_iClass", "NPCClass" )
AccessorFunc( ENT, "m_fMaxYawSpeed", "MaxYawSpeed" )

ENT.NextEnemyFind=0
ENT.EnemyFindCD=2

ENT.NextLeap=0
ENT.LeapCD=5

ENT.NextAttack=0
ENT.AttackCD=1

ENT.Points=0

ENT.BuildEnt="npc_swarm_mother"

ENT.Swarm = true

ENT.MeleeRange = 100
ENT.MeleeRangeBonus = 20

ENT.SearchHeight = 60
ENT.SmallerSearchHeight = 40

ENT.InfectiousC = 2

ENT.MaxInfectedHealthMul = 2

function ENT:Initialize()

	if(SERVER)then
		self:SetupGenes()
		self.NextDeath = CurTime()+4000*self:GetLifeTimeMul(3)*SWARM_CV_DeathTimerMul:GetFloat()
		self:SetModel("models/zombie/zombie_soldier.mdl")
		self:SetColor(Color(220,255,220))
		--self:SetModelScale(0.5,0)
		
		self:SetHullType( HULL_HUMAN )
		self:SetHullSizeNormal() 
		self:SetSolid( SOLID_BBOX )
		self:SetMoveType( MOVETYPE_STEP )
		self:CapabilitiesAdd( bit.bor( CAP_MOVE_GROUND, CAP_SQUAD, CAP_MOVE_JUMP, CAP_OPEN_DOORS, CAP_AUTO_DOORS ) )
		--self:CapabilitiesRemove( bit.bor( CAP_OPEN_DOORS, CAP_AUTO_DOORS ) )
		
		self:SetHealth( 160*self:GetHealthMul(2) )
		--self:SetArrivalSpeed(4220)
		self:SetMaxHealth(200)
		
		self.Faction=1
		--self:SetColor(Color(255,0,0))
		self:SetBloodColor(BLOOD_COLOR_GREEN)
		
		self.JustSpawned = CurTime()+2
	end
	--self:SetKeyValue( "additionalequipment", GetConVarString("gmod_npcweapon") )
end

function ENT:Draw()
	self:DrawModel()
	
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
		self.Died = true
		self:Remove()
	end
	if((dude:IsNPC() and (dude:Disposition(self)==D_HT or dude:Disposition(self)==D_FR)) or (dude:IsPlayer() and !ignoreplayers:GetBool()))then
		--print("TRIGGERED BY",dude)
		self:SetEnemy( dude, true )
		self:UpdateEnemyMemory( dude, dude:GetPos() )
		self.RunAway = nil
		self:TaskComplete()
	end
	self:HostileNotificationMother(dude,dmginfo:GetDamage())
end

local angleZero = Angle(0,0,0)
function ENT:TraceCircle(pos,traceamt,tracerange,filter,ang,arc)
	local found = {}
	--print(ang)
	ang = ang or angleZero
	ang[2] = ang[2] - arc/2
	arc = arc or 360
	local space = arc/traceamt
	local high = -math.sin(math.rad(ang[1]))*tracerange
	local rng = tracerange-high/2
	for i=1,traceamt do
		local result = util.TraceLine({
			start = pos,
			endpos = pos + Vector(math.cos(math.rad(ang[2]+i*space))*rng, math.sin(math.rad(ang[2]+i*space))*rng, high),
			filter = filter,
		})
		--print(rng,high)
		--if(arc==1 and i == 1)then
		--Entity(1):SetPos(pos + Vector(math.cos(math.rad(ang[2]+i*space))*rng, math.sin(math.rad(ang[2]+i*space))*rng, high))
		--	self:Shoot( Vector(math.cos(math.rad(ang[2]+i*space))*rng, math.sin(math.rad(ang[2]+i*space))*rng, high)*10 )
		--end
		if(result.Hit)then
			found[result.Entity]=(result.Fraction*tracerange)
		end
	end
	
	return found
end

function ENT:Shoot( dir )
	self:SetIdealActivity(ACT_RANGE_ATTACK1)
	hel=ents.Create('ent_swm_projectile')
	hel:SetPos(self:GetPos()+Vector(0,0,self.SearchHeight))
	hel:Spawn()
	hel:Activate()
	hel:SetOwner(self)
	self:EmitSound('NPC_HeadCrab.Gib',35)
	
	local phys = hel:GetPhysicsObject()
	if IsValid(phys) then		
		phys:SetVelocity(dir)
	end
end

function ENT:Psych( )--Heavy on performance. Rethink
	if(!SWARM_CV_Thumper_AllowPsych:GetBool())then return end
	local lastenem = self:GetEnemy()
	
	local angle = self:GetAngles()
	if(IsValid(lastenem))then
		angle = (lastenem:GetPos()-self:GetPos()):Angle()
		--angle[1] = 0
		--angle[3] = 0
		self:EmitSound("npc/stalker/go_alert2"..((math.random(0,3)==0 and "a") or "")..".wav",75)		
	end
	
	local found = self:TraceCircle(self:GetPos()+vector_up*self.SearchHeight,90,SWARM_CV_Thumper_PsychRange:GetInt(),{self},angle,45)
	--print(self:GetAngles())
	--ents.FindInSphere(self:GetPos(),SWARM_CV_Thumper_PsychRange:GetInt())
	
	for p,distance in pairs(found)do
		if((p:IsPlayer() and p:Alive() and !ignoreplayers:GetBool()) or (p:IsNPC() and !p.Swarm))then
			local dmgn=SWARM_CV_Thumper_PsychDmg:GetFloat()*self:GetDamageMul(5)
			if(p.SwmInf and p.SwmInf>0)then
				dmgn=dmgn + 2
				if(math.random(1,30)==1 and p:IsPlayer() and p:Alive())then
					p.SwarmPerc=(p.SwarmPerc or 0)+30
					p.Swm=true				
				end
			end
			local dist = p:GetPos():DistToSqr(self:GetPos())
			local dmg = DamageInfo()
			dmg:SetDamage((1-(dist/SWARM_CV_Thumper_PsychRange:GetInt()^2))*dmgn)
			dmg:SetDamageType(DMG_BLAST_SURFACE)
			dmg:SetAttacker(self)
			dmg:SetInflictor(self)
			p:TakeDamageInfo(dmg)
			--print((IsValid(lastenem) and math.Round( distance/SWARM_CV_Thumper_PsychRange:GetInt()*15 )) or (1))
			local calc = distance/SWARM_CV_Thumper_PsychRange:GetInt()
			if(SWARM_CV_Thumper_PsychInvert:GetBool())then
				calc = math.min(1-calc+0.1,1)
			else
				--calc = calc*15
			end
			--print(calc)
			SWARM:Psych(p,(IsValid(lastenem) and math.Round( calc*15 )) or (1))
			--[[
			p.Stamina=p.Stamina or 100
			p.Stamina = math.Clamp(p.Stamina-(1-(dist/500^2))*80, 0, 100)
			if(p.Stamina<10 and !p.fake)then
				p:CreateFake()
			end
			]]
		end
	end
	--self:EmitSound("npc/stalker/stalker_alert"..math.random(1,3).."b.wav",65)
end

function ENT:MoveTo(pos,time)
	local lastenem = self:GetEnemy()
	if(!IsValid(lastenem) or (lastenem.Alive and !lastenem:Alive()) or lastenem:GetPos():Distance(self:GetPos())>(300))then
		self.MovingTo=CurTime()+time
		self:SetLastPosition(pos)
		self.Hiding=nil
	end
end

function ENT:Touch(ent)

end


----
----

function ENT:Classify(  )
	return self.m_iClass
end

--function ENT:StartEngineSchedule(sched)
--	print(sched,self:GetEnemy())
	
--end

function ENT:TaskStart_FindEnemy( data )
	if(data==nil)then data = {} end

	local lastenem = self:GetEnemy()
	--print(lastenem)
	--PrintTable(self:GetKnownEnemies())
	--self:SetNPCState(NPC_STATE_IDLE)

	self:EmitSound("npc/stalker/stalker_alert"..math.random(1,3).."b.wav",65)
	if(!IsValid(lastenem) or (lastenem.Alive and !lastenem:Alive()) or lastenem:GetPos():Distance(self:GetPos())>(data.Radius or 1024))then
	
		--local et = ents.FindInSphere( self:GetPos(), data.Radius or 1024 )
		local et = self:TraceCircle(self:GetPos()+vector_up*self.SearchHeight,360,SWARM_CV_Thumper_DetectRange:GetInt(),{self},self:GetAngles(),360)
		table.Merge(et,self:TraceCircle(self:GetPos()+vector_up*self.SmallerSearchHeight,360,SWARM_CV_Thumper_DetectRange:GetInt()/3,{self},self:GetAngles(),360))
		--PrintTable(et)
		local bestdistance = math.huge
		local bestenemy = nil
		for v, _ in pairs( et ) do
			if ( v:IsValid() && v != self && (self:Disposition(v)==D_HT or self:Disposition(v)==D_FR) and (!v.Alive or v:Alive()) and self:IsEntityPossibleEnemy(v) ) then
				local dist = v:GetPos():DistToSqr(self:GetPos())
				--print((!v:IsPlayer() or !ignoreplayers:GetBool()))
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
			self.RunAway = nil
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

function ENT:ValidateEnemyData( )
	local lastenem = self:GetEnemy()
	if(IsValid(lastenem))then
		if((self:GetPos():DistToSqr(lastenem:GetPos())>SWARM_CV_Thumper_ForgetRange:GetInt()^2) or (lastenem:IsPlayer() and !lastenem:Alive()))then
			if(!self.NextForget)then
				self.NextForget = CurTime() + ((lastenem:IsPlayer() and !lastenem:Alive() and 0) or SWARM_CV_Thumper_ForgetTime:GetFloat())
			elseif(self.NextForget<=CurTime())then
				self:SetEnemy( NULL )
				self:ClearEnemyMemory( )
				self.RunAway = CurTime()+2
				self.NextForget = nil
				return
			end
		end
		if(!self.MovingTo)then
			self:SetLastPosition(lastenem:GetPos())
		end
		if((!self.Combat_NextTaskComplete or self.Combat_NextTaskComplete<=CurTime()) and !self.Attacking)then
			self.Combat_NextTaskComplete = CurTime()+1
			self:TaskComplete()
		end
		self:UpdateEnemyMemory( lastenem, lastenem:GetPos() )
		return
	end
end

if(SERVER)then
	ENT.schd_GOTO = ai_schedule.New( "GoTo" )
	ENT.schd_GOTO:EngTask( "TASK_GET_PATH_TO_SAVEPOSITION", 0 )
	ENT.schd_GOTO:EngTask( "TASK_RUN_PATH", 0 )
	ENT.schd_GOTO:EngTask( "TASK_WAIT_FOR_MOVEMENT", 0 )
	
	ENT.schd_RANDOM = ai_schedule.New( "Random" )
	ENT.schd_RANDOM:EngTask( "TASK_GET_PATH_TO_RANDOM_NODE", 128 )
	ENT.schd_RANDOM:EngTask( "TASK_RUN_PATH", 0 )
	ENT.schd_RANDOM:EngTask( "TASK_WAIT_FOR_MOVEMENT", 0 )
	
	ENT.schd_WANDER = ai_schedule.New( "Wander" )
	ENT.schd_WANDER:EngTask( "TASK_GET_PATH_TO_RANDOM_NODE", 128 )
	ENT.schd_WANDER:EngTask( "TASK_WALK_PATH", 0 )
	ENT.schd_WANDER:EngTask( "TASK_WAIT_FOR_MOVEMENT", 0 )
	
	ENT.schd_RUNENEMY = ai_schedule.New( "RunEnemy" )
	ENT.schd_RUNENEMY:EngTask( "TASK_GET_CHASE_PATH_TO_ENEMY", 0 )
	--ENT.schd_RUNENEMY:EngTask( "TASK_GET_PATH_TO_ENEMY_LKP", 0 )
	ENT.schd_RUNENEMY:EngTask( "TASK_RUN_PATH", 0 )
	ENT.schd_RUNENEMY:EngTask( "TASK_WAIT_FOR_MOVEMENT", 0 )
	
	ENT.schd_HIDE = ai_schedule.New( "Hide" )
	ENT.schd_HIDE:EngTask( "TASK_FIND_COVER_FROM_ORIGIN", 0 )
	ENT.schd_HIDE:EngTask( "TASK_RUN_PATH", 0 )
	ENT.schd_HIDE:EngTask( "TASK_WAIT_FOR_MOVEMENT", 0 )
	
	ENT.schd_ATTACK = ai_schedule.New( "Attack" )
	--ENT.schd_ATTACK:EngTask( "TASK_GET_CHASE_PATH_TO_ENEMY", 0 )
	--ENT.schd_ATTACK:EngTask( "TASK_RUN_PATH", 0 )
	ENT.schd_ATTACK:EngTask( "TASK_MELEE_ATTACK1", 0 )
	--ENT.schd_RUNENEMY:EngTask( "TASK_WAIT_FOR_MOVEMENT", 0 )
	ENT.schd_ATTACK:EngTask( "TASK_WAIT_FACE_ENEMY", 0 )
end

function ENT:SelectSchedule( iNPCState )
	if(self.MovingTo)then
		self:StartSchedule(self.schd_GOTO)
	elseif(self.Hiding)then
		self:StartSchedule(self.schd_HIDE)
	elseif(self.JustSpawned or self.RunAway)then
		self:StartSchedule(self.schd_RANDOM)
	else
		if(!self.Attacking)then
			if(IsValid(self:GetEnemy()))then
				self:StartSchedule(self.schd_RUNENEMY)
			else
				self:StartSchedule(self.schd_WANDER)
			end
		else
			self:StartSchedule(self.schd_ATTACK)
			--if(self._Attacking)then
			--	self._Attacking = false
				
				--self:SetIdealActivity(ACT_MELEE_ATTACK1)
			--end
		end
	end
end


function ENT:OnCondition( iCondition )

	--Msg( self, " Condition: ", iCondition, " - ", self:ConditionName(iCondition), "\n" )

end

function ENT:SWARM_OnGround( )
	return true
end

function ENT:Attack( ent )
	if(!self.Attacking and self:SWARM_OnGround())then
		self.Attacking = CurTime()+0.8
		self.AttackEnemy = ent
		self._Attacking = true
		self:EmitSound("NPC_BlackHeadcrab.ImpactAngry")
		self:SetSchedule( SCHED_COMBAT_FACE )
		self:SetIdealActivity(ACT_MELEE_ATTACK1)
	end
end

function ENT:Think()
	--if(SERVER and self:GetNPCState() != NPC_STATE_NONE)then
	--	print(self:GetNPCState())
	--end
	if(SERVER)then
		--self:SetMoveVelocity(self:GetMoveVelocity()*2)
		--self:SetVelocity(self:GetMoveVelocity()*2)
		--self:SetMoveInterval(0)
		--print(self:GetIdealMoveSpeed())
		self:SetNPCState(NPC_STATE_NONE) -- Hack to make it blind
		if(SWARM_CV_AllowSpeed:GetBool())then
			self:SetVelocity(self:GetMoveVelocity()*(self:GetSpeedMul(2)-1))
		end
		self:DeathThink()
	end
	
	if(SERVER and (!self.NextDropToFloor or self.NextDropToFloor<=CurTime()) and !self.Leaping and self:GetVelocity():LengthSqr()<5)then
		self.NextDropToFloor = CurTime()+5
		self:DropToFloor()
	end
	
	local parent = self:GetParent()
	if(IsValid(parent))then
		parent.SwarmPerc=(parent.SwarmPerc or 0)+FrameTime()*2
		parent.Swm=true
	end
	if(self.JustSpawned and self.JustSpawned<=CurTime())then
		self.JustSpawned=nil
	end
	if(self.RunAway and self.RunAway<=CurTime())then
		self.RunAway = nil
	end
	if(self.Hiding and self.Hiding<=CurTime())then
		self.Hiding=nil
		self:Build()
	end	

	if(self.MovingTo and self.MovingTo<=CurTime())then
		self.MovingTo=nil
	end

	if(SERVER and ((!self.NextEntityHullClearing or self.NextEntityHullClearing<=CurTime()) and !self.JustSpawned))then
		self.NextEntityHullClearing = CurTime() + 1
		SWARM:ClearEntityHull(self,35)
	end
	
	if(self.Attacking and self.Attacking<=CurTime())then
		self.Attacking = nil
		if(IsValid(self.AttackEnemy) and self.AttackEnemy:GetPos():Distance(self:GetPos())<(self.MeleeRange+self.MeleeRangeBonus))then
			local dmg = DamageInfo()
			dmg:SetDamage(SWARM_CV_Thumper_MeleeDmg:GetInt()*self:GetDamageMul(2.5))
			dmg:SetDamageType(DMG_SLASH)
			dmg:SetAttacker(self)
			dmg:SetInflictor(self)
			self.AttackEnemy:TakeDamageInfo(dmg)
			if(SWARM_CV_Thumper_ALLOWKO:GetBool())then
				local time = SWARM_CV_Thumper_KOTime:GetFloat()
				if(SWARM_CV_Thumper_ScaleKOTime:GetBool())then
					time = math.max((1-math.min(self.AttackEnemy:Health()/self.AttackEnemy:GetMaxHealth(),1))*SWARM_CV_Thumper_KOScaleTime:GetFloat(),0.2)
					--print(time)
				end
				SWARM:Knockout(self.AttackEnemy,math.Round(time,2),SWARM_CV_Thumper_AKOTime:GetFloat())
			end
			local phys = self.AttackEnemy:GetPhysicsObject()
			if(IsValid(phys))then
				phys:ApplyForceCenter((self.AttackEnemy:HeadTarget(self:GetShootPos())-self:GetShootPos()):GetNormalized()*4450)
				phys:ApplyTorqueCenter(VectorRand()*1450)
			end
			
			self:TryInfect(self.AttackEnemy,20,self)
			self:EmitSound("NPC_BlackHeadcrab.Impact")--NPC_FastHeadcrab.Bite--Egg.Crack--NPC_BlackHeadcrab.Impact
			self.Points=self.Points+10
		end
		self.AttackEnemy = nil
	end
end

function ENT:RunAI( strExp )
--self:SetIdealActivity(ACT_IDLE_AIM_RIFLE_STIMULATED)
	--print(4)
	if(SWARM_CV_Thumper_AllowMelee:GetBool())then
		local lastenem = self:GetEnemy()
		if( IsValid(lastenem) and (!lastenem.Alive or lastenem:Alive()) )then
			if(IsValid(lastenem.fakeragdoll))then
				if(lastenem:GetPos():Distance(self:GetPos())<self.MeleeRange)then
					if(self.NextAttack<=CurTime())then
						self.NextAttack=CurTime()+self.AttackCD
						local dmg = DamageInfo()
						dmg:SetDamage(SWARM_CV_Thumper_MeleeDmg:GetInt()*self:GetDamageMul(2.5))
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
							self:TaskComplete()
						end
					end
				end
			end
		end
	end

	if(self.NextLeap<=CurTime())then	
		self.NextLeap=CurTime()+SWARM_CV_Thumper_PsychCD:GetFloat()+math.Rand(-SWARM_CV_Thumper_PsychCDRand:GetFloat(),0)
		self:Psych()
	end

	if(self.NextEnemyFind<=CurTime())then	
		self.NextEnemyFind=CurTime()+self.EnemyFindCD
		self:TaskStart_FindEnemy()
	end

	if(!self.NextEnemyUpdate or self.NextEnemyUpdate<=CurTime())then
		self.NextEnemyUpdate=CurTime()+0.3
		self:ValidateEnemyData( )
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

scripted_ents.Register(ENT,"npc_swarm_thumper")
list.Set( "NPC", "npc_swarm_thumper", {
	Name = "Thumper",
	Class = "npc_swarm_thumper",
	Category = "Swarm"
})