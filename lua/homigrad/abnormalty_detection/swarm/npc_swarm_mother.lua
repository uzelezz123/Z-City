ENT={}

SWARM_CV_MOTHER_PointsMul = CreateConVar("swarm_mother_pointsmul", 1, bit.bor(FCVAR_ARCHIVE), "Point yield multiplier" )
SWARM_CV_MOTHER_ReservePointsMul = CreateConVar("swarm_mother_reservepointsmul", 1, bit.bor(FCVAR_ARCHIVE), "Reserve points(Used for determening if ready for coronaion) yield multiplier" )

AddCSLuaFile()
ENT.Spawnable = true

ENT.Base = "swarm_ai_base"	--Why dont just create an NPC?
ENT.Type = "ai"

ENT.PrintName     = "Swarm Mother"

ENT.m_fMaxYawSpeed = 10 -- Max turning speed
ENT.m_iClass = CLASS_HEADCRAB -- NPC Class

AccessorFunc( ENT, "m_iClass", "NPCClass" )
AccessorFunc( ENT, "m_fMaxYawSpeed", "MaxYawSpeed" )

ENT.Swarm = true

ENT.NextEnemyFind=0
ENT.EnemyFindCD=1

ENT.NextShoot=0
ENT.ShootCD=1

ENT.SpawnAmt=0
ENT.Spawnplus=1

ENT.NextPoint=0
ENT.PointCD=2

ENT.Points=0
ENT.ReservePoints = 0

ENT.Anim="barf_humanoid"--2471

ENT.Npcs={
	"npc_swarm",
	"npc_swarm_sentry",
	"npc_swarm_thumper",
}

--ENT.AdditiveCost = 20
ENT.AdditiveCost = 0

ENT.NpcCost={
	["npc_swarm"]=5+10,
	["npc_swarm_sentry"]=15+10,
	["npc_swarm_thumper"]=25+10,
}
ENT.NpcOrdersList={}

ENT.NpcOrderCD={
	["npc_swarm"] = 2,
	["npc_swarm_sentry"]=5,
	["npc_swarm_thumper"]=4,
}

ENT.NpcOrderChance={
	["npc_swarm"] = {"npc_swarm",1000},
	["npc_swarm_sentry"] = {"npc_swarm_sentry",1000},
	["npc_swarm_thumper"] = {"npc_swarm_thumper",1000},
}

ENT.NpcAmtForOtherNpc = {
	["npc_swarm_thumper"] = 3
}

SWARM_MOTHER_NpcOrderChanceMinus={
	["npc_swarm"] = 10,
	["npc_swarm_sentry"]=30,
	["npc_swarm_thumper"]=100,
}

ENT.OrderWeightFunc = function(orig,wintab)
	if(SWARM_MOTHER_NpcOrderChanceMinus[wintab[1]])then
		wintab[2] = wintab[2] - SWARM_MOTHER_NpcOrderChanceMinus[wintab[1]]
	end
end

function ENT:OrderWeightCreationFunc()
	local totalamt = 0
	for npc,amt in pairs(self.CreatedNpcsAmt)do
		totalamt = totalamt + amt
	end
	for npc,amt in pairs(self.CreatedNpcsAmt)do
		if(self.NpcOrderChance[npc] and amt>0)then
			self.NpcOrderChance[npc][2] = 1-(amt/totalamt)
		elseif(self.NpcOrderChance[npc])then
			self.NpcOrderChance[npc][2] = 1000
			if(self.NpcAmtForOtherNpc[npc] and self.NpcAmtForOtherNpc[npc]<totalamt)then
				self.NpcOrderChance[npc][2] = 0
			end
		end
	end
	return self.NpcOrderChance
end

ENT.OrdersLimit = 10

ENT.MaxInfectedHealthMul = 2

function ENT:Initialize()

	if(SERVER)then
		self:SetupGenes()
		if(table.Count(self.GeneticData)==0)then
			self:MutateGenes(nil,10)
		end
		self.NextCoronation = CurTime()+120*self:GetLifeTimeMul(4)*SWARM_CV_CoronationMul:GetFloat()
		self:SetModel("models/barnacle.mdl")
		self:SetColor(Color(220,255,220))
		--self:SetModelScale(0.5,0)
		
		self:SetAngles(Angle(0,0,180))
		
		self:SetHullType( HULL_MEDIUM )
		self:SetHullSizeNormal() 
		self:SetSolid( SOLID_BBOX )
		self:SetMoveType( MOVETYPE_NONE )
		self:CapabilitiesAdd( bit.bor( CAP_MOVE_GROUND, CAP_SQUAD ) )
		self:CapabilitiesRemove( bit.bor( CAP_OPEN_DOORS, CAP_AUTO_DOORS ) )
		
		self:SetHealth( 100*self:GetHealthMul(10) )
		self:SetMaxHealth(1000)

		--self:SetColor(Color(255,0,0))
		self:SetBloodColor(BLOOD_COLOR_GREEN)

		for i=1,8 do
			self:ManipulateBonePosition(self:LookupBone("Barnacle.tongue"..i),Vector(0,0,30*i))
		end
		--self:ManipulateBoneAngles(0,Angle(0,0,180))
		--self:ManipulateBonePosition(0,Vector(0,0,8))

		
		self:DropToFloor()
		self._DropToFloor = true
		--self:SetPos(self:GetPos()+vector_up*10)

		
		self.Bullseye = ents.Create('npc_swarm_bullseye')
		self.Bullseye:SetHealth(1000)
		self.Bullseye:SetMoveType( MOVETYPE_NONE )
		self.Bullseye:Spawn()
		self.Bullseye:Activate()
		self.Bullseye:SetNotSolid(true)
		self.Bullseye.m_iClass=self.m_iClass
		AccessorFunc(self.Bullseye, "m_iClass", "NPCClass")
		self.Bullseye:SetNPCClass(self.m_iClass)
		
		self.CreatedNpcsAmt = self.CreatedNpcsAmt or {}
		self.CreatedNpcs = self.CreatedNpcs or {}
	end
	--self:SetKeyValue( "additionalequipment", GetConVarString("gmod_npcweapon") )
end

function ENT:DisownNpc(npc)
	self.CreatedNpcs[npc]=nil
	self.CreatedNpcsAmt[npc:GetClass()] = (self.CreatedNpcsAmt[npc:GetClass()] or 1)-1
end

function ENT:OnRemove( )
	if(IsValid(self.Bullseye))then
		self.Bullseye:Remove()
	end
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
		self:Coronation()
		self:Remove()
	end
	if((dude:IsNPC() and (dude:Disposition(self)==D_HT or dude:Disposition(self)==D_FR)) or (dude:IsPlayer() and !ignoreplayers:GetBool()))then
		--print("TRIGGERED BY",dude)
		self:SetEnemy( dude, true )
		self:UpdateEnemyMemory( dude, dude:GetPos() )
		for npc,time in pairs(self.CreatedNpcs)do
			if(IsValid(npc))then
				if(!npc.CantMove)then
					npc:SetEnemy( dude, true )
					npc:UpdateEnemyMemory( dude, dude:GetPos() )
				end
			else
				self.CreatedNpcs[npc]=nil
			end
		end
	end
	self:HostileNotificationMother(dude,dmginfo:GetDamage()*2)
end

function ENT:Coronation()
	if(self.ReservePoints<20)then return end
	if(self:GetCoronationType()=="A")then
		local besttime = CurTime()
		local bestking = nil
		for npc,time in pairs(self.CreatedNpcs)do
			if(IsValid(npc) and npc:GetClass()=="npc_swarm" and besttime>time)then
				bestking = npc
				besttime = time
			end
		end
		if(bestking)then
			bestking.King = true
			bestking.Points = bestking.Points + 30
			bestking.GeneticData = self:CopyGenetics(self.GeneticData)
			bestking.AcquiredGenes = self.AcquiredGenes
			bestking:EvolveGenetics()
			bestking.CreatedNpcs = self.CreatedNpcs
			bestking.CreatedNpcsAmt = self.CreatedNpcsAmt
			bestking:MutateGenes(nil,10)
			bestking.Hostiles = self.Hostiles
			bestking:SetColor(Color(255,150,0))
			self:Remove()
		else
			self.FailedCoronations = (self.FailedCoronations or 0) + 1
			self.NextCoronation = CurTime()+50
		end
	else
		hel=ents.Create("npc_swarm")
		hel.King = true
		hel:SetColor(Color(255,150,0))
		hel.GeneticData = self:CopyGenetics(self.GeneticData)
		hel.AcquiredGenes = self.AcquiredGenes
		hel:EvolveGenetics()
		hel:SetPos(self:GetPos())
		hel:Spawn()
		hel:Activate()
		hel.Points = 30
		hel.CreatedNpcs = self.CreatedNpcs
		hel.CreatedNpcsAmt = self.CreatedNpcsAmt
		hel:MutateGenes(nil,5)
		hel.Hiding = CurTime()+5
		hel.Hostiles = self.Hostiles
		self:EmitSound('NPC_HeadCrab.Gib',35)	
		self:Remove()
	end
end

function ENT:Think()
	if(self.NextCoronation and self.NextCoronation<=CurTime())then
		self:Coronation()
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
	
	if(self.NextPoint<=CurTime())then	
		self.NextPoint=CurTime()+self.PointCD			
		self.Points=self.Points+1*SWARM_CV_MOTHER_PointsMul:GetFloat()
		self.ReservePoints = self.ReservePoints + 1*SWARM_CV_MOTHER_ReservePointsMul:GetFloat()
	end	
	
	if(self.SpawnAmt)then
		self.SpawnAmt=self.SpawnAmt+FrameTime()*self.Spawnplus
		if(self.SpawnAmt>=100)then
			self.SpawnAmt=nil
		end
	end

	if(self.NpcOrderTime)then
		if(self.NpcOrderTime<=CurTime())then
			self:NpcOrderPreDone( )
		end
	end

	if(self.NpcOrderPreDoneTime)then
		if(self.NpcOrderPreDoneTime<=CurTime())then
			self:NpcOrderDone( )
		end
	end
	
	
	if(IsValid(self.Bullseye))then
		self.Bullseye:SetPos(self:GetPos()+Vector(0,0,10))
	end
	
	self:SetAngles(Angle(0,0,180))
end

function ENT:NpcOrder( class, time )
	if(self.NpcOrderTime)then return end
	if(self.NpcCost[class] and self.NpcCost[class]>self.Points)then return end
	self.Points=self.Points-(self.NpcCost[class] or 0)
	self.NpcOrderClass=class
	self.NpcOrderTime=CurTime()+time
	
	self.NpcOrdersList[class] = (self.NpcOrdersList[class] or 0)+1
	local ordersamount = 0
	local mostorders = 0
	local cat = ""
	for class,times in pairs(self.NpcOrdersList)do
		ordersamount = ordersamount + times
		if(times>mostorders)then
			mostorders = times
			cat = class
		end
	end
	if(ordersamount>self.OrdersLimit)then
		self.NpcOrdersList[cat] = (self.NpcOrdersList[cat] or 1) - 1
	end
end

function ENT:NpcOrderPreDone( )
	self.NpcOrderTime=CurTime()+100--piss
	self.NpcOrderPreDoneTime=CurTime()+0.5
end

function ENT:NpcOrderDone( )
	hel=ents.Create(self.NpcOrderClass)
	hel:SetPos(self:GetPos()+Vector(0,0,40))
	hel:Spawn()
	hel:Activate()
	hel:SetOwner(self)
	hel:MoveJumpStart(VectorRand()*400)
	self.NpcOrderTime=nil
	self.NpcOrderPreDoneTime=nil
	
	self.CreatedNpcs[hel]=CurTime()
	self.CreatedNpcsAmt[self.NpcOrderClass] = (self.CreatedNpcsAmt[self.NpcOrderClass] or 0)+1
	hel.SWARM_Mother = self
	hel.HadMother = true
	
	hel.GeneticData = self:CopyGenetics(self.GeneticData)
	hel:MutateGenes()
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
	local et = ents.FindInSphere( self:GetPos(), 300 )

	for k, v in pairs( et ) do
		if ( v:IsValid() && (v:GetClass()~=self:GetClass()) && v.Points && v.Points>0 and v:GetPos():DistToSqr(self:GetPos())<10000 ) then
			self.Points=self.Points+v.Points
			v.Points=0
		end
		if( v:IsValid() && v != self && (self:Disposition(v)==D_HT or self:Disposition(v)==D_FR) and (!v.Alive or (v:Alive() and !ignoreplayers:GetBool())) and self:IsEntityPossibleEnemy(v,-1) )then
			for npc,time in pairs(self.CreatedNpcs)do
				if(IsValid(npc))then
					if(!npc.CantMove and !IsValid(npc:GetEnemy()))then
						npc:SetEnemy( v, true )
						npc:UpdateEnemyMemory( v, v:GetPos() )
					end
				else
					self.CreatedNpcs[npc]=nil
				end
			end
		end
	end
end

function ENT:TaskStart_BringNpcs( data )	

	local et = ents.FindInSphere( self:GetPos(), 2048 )

	for k, v in pairs( et ) do

		if ( v:IsValid() and (v:GetClass()~=self:GetClass()) and v.Points and v.Points>0 and v.MoveTo and v:IsNPC() ) then
			v:MoveTo(self:GetPos(),10)
			--v:SetLastPosition(self:GetPos())
			--v:SetSchedule( SCHED_FORCED_GO_RUN )
		end

	end
end

function ENT:SelectSchedule( iNPCState )
	
	if(self.JustSpawned)then
		self:SetSchedule( SCHED_SLEEP )
	else
		if(self.NpcOrderTime)then
			self:SetIdealActivity(self:GetSequenceActivity(self:LookupSequence(self.Anim)))
			--print(4)
		else
			self:SetSchedule( SCHED_SLEEP )
		end
	end
	
end


function ENT:OnCondition( iCondition )

	--Msg( self, " Condition: ", iCondition, " - ", self:ConditionName(iCondition), "\n" )

end

function ENT:Draw()
	--if(!self._RenderInited)then
		--self._RenderInited = true
		--self:SetRenderAngles(Angle(0,0,180))
		--self:SetRenderOrigin(self:GetPos())
	--end
	self:DrawModel()
end

function ENT:RunAI( strExp )
--self:SetIdealActivity(ACT_IDLE_AIM_RIFLE_STIMULATED)
--[[
	local lastenem = self:GetEnemy()
	if( IsValid(lastenem) and (!lastenem.Alive or lastenem:Alive()) )then
		if(lastenem:GetPos():Distance(self:GetPos())<600)then	
			local traceinfo = {
				start = self:GetPos(),
				endpos = lastenem:GetShootPos(),
				filter = self,
			}
			local trace = util.TraceLine(traceinfo)
			if(trace.Entity==lastenem)then
				if(self.NextShoot<=CurTime())then	
					self.NextShoot=CurTime()+self.ShootCD			
					--self:Shoot( ( (lastenem:GetShootPos()+lastenem:GetVelocity()/6)-self:GetPos() ):GetNormalized()*1950 )
				end
			end
		end
	end]]
	
	if(!self.NextOrder or self.NextOrder<=CurTime())then
		local _,npc =  next(table.SortByKey( self.NpcOrdersList ))
		if(!npc)then
			_,npc = next(self.Npcs)
			times = 0 
		end
		self.NextOrder = CurTime() + self.NpcOrderCD[npc]*(self.NpcOrdersList[npc] or 0)
		--table.Random(self.Npcs)
		local tbl = self:OrderWeightCreationFunc()
		PrintTable(tbl)
		self:NpcOrder(SWARM:WeightedRandomSelect(tbl),0.2)
	end
	--print(self.Points)
	if(self.NextEnemyFind<=CurTime())then	
		self.NextEnemyFind=CurTime()+self.EnemyFindCD
		self:TaskStart_BringNpcs()
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

scripted_ents.Register(ENT,"npc_swarm_mother")
list.Set( "NPC", "npc_swarm_mother", {
	Name = "Mother",
	Class = "npc_swarm_mother",
	Category = "Swarm"
})