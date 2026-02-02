--[[
Somewhere far away, mysterious flowers begin to appear
These flowers were one of the first to be created after the monochrome winter
They tried to defend themselves against everything possible
Quickly, they conquered new territories and changed to become even stronger
They do not resemble flowers anymore
]]
--They answer violence with violence and can quickly become deadly force

--Achievements
util.AddNetworkString("SWARM(Psych)")
util.AddNetworkString("SWARM(Knockout)")
util.AddNetworkString("SWARM(Bleed)")

SWARM={}
SWARM.Msg='You die as Swarm bursts from you'

SWARM_CV_InfectionsDefault = CreateConVar("swarm_horrormode", 4, bit.bor(FCVAR_ARCHIVE), "Allow horror by default? (Will simulate C and I genes in all entities. Swarm can infect by default)\nSet to more than 1 to experience hardmode" )
SWARM_CV_MutationMul = CreateConVar("swarm_mutationmul", 1, bit.bor(FCVAR_ARCHIVE), "Mutation multiplier(Yes, these things evolve)" )
SWARM_CV_AllowSpeed = CreateConVar("swarm_allowspeedgenes", 1, bit.bor(FCVAR_ARCHIVE), "Allow S gene to apply speed on npcs" )
SWARM_CV_Evolve = CreateConVar("swarm_allowevolution", 1, bit.bor(FCVAR_ARCHIVE), "Allow swarm npcs to evolve" )
SWARM_CV_CoronationMul = CreateConVar("swarm_coronationtimemul", 1, bit.bor(FCVAR_ARCHIVE), "Life time multiplier (For 'Mother')" )

SWARM.CV_MinInfections = CreateConVar("swarm_mininfections", 4, bit.bor(FCVAR_ARCHIVE), "Number of exposures to infestation before getting infected" )
SWARM.CV_MinHealth = CreateConVar("swarm_minhealth", 40, bit.bor(FCVAR_ARCHIVE), "Critical health at which you'll get infected from physical contact" )
SWARM.CV_InfPerSecond = CreateConVar("swarm_infprogressinsecond", 2, bit.bor(FCVAR_ARCHIVE), "Infection progress per second" )

SWARM_CV_BleedDmg = CreateConVar("swarm_bleeddmg", 1, bit.bor(FCVAR_ARCHIVE), "Bleeding damage" )
SWARM_CV_BleedCD = CreateConVar("swarm_bleedcd", 1, bit.bor(FCVAR_ARCHIVE), "Bleeding damage cooldown" )

SWARM_CV_AllowDeath = CreateConVar("swarm_allowdeathtimer", 1, bit.bor(FCVAR_ARCHIVE), "Allow death timer for every spawned npc(except 'Mother')" )
SWARM_CV_DeathTimerMul = CreateConVar("swarm_deathtimermul", 1, bit.bor(FCVAR_ARCHIVE), "Death timer multiplier" )

SWARM_CV_ExperementalModels = CreateConVar("swarm_experementalmodels", 0, bit.bor(FCVAR_ARCHIVE), "Swarm will use experemental (view)models" )

SWARM.NextNet = 0
SWARM.NextNetCD = 2

local ChangedTable={}

function SWARM:IsChanged(val,id,meta)
	if(meta==nil)then 
		meta = ChangedTable 
	end
	if(meta.ChangedTable==nil)then
		meta['ChangedTable']={}
	end
	
	if( meta.ChangedTable[id] == val )then return false end
	
	meta.ChangedTable[id]=val
	return true
end

function SWARM:WeightedRandomSelect(tab)
	local totalWeight=0
	for i,item in pairs(tab) do
		totalWeight=totalWeight+item[2]
	end
	local randnum=math.random(1,totalWeight)
	local num=0
	
	for i,item in pairs(tab) do
		num=num+item[2]
		if(num>=randnum)then
			return item[1]
		end
	end	
end

--Many of these lines were extracted from [EU]Homicide project, don't expect readable code
function SWARM:Spread(p)
	p:InvoluntaryEvent() 
	for k,v in pairs(ents.FindInSphere(p:GetPos(),120))do 
		if(v:IsPlayer() and v:Alive() and !p:GetNWBool('S_GasMask') and !v:GetNWBool('S_GasMask') and v.SwmInf and v.SwmInf>SWARM.CV_MinInfections:GetInt())then 
			v.Swm=true
		end
		if(v:IsPlayer())then
			v.SwmInf=(v.SwmInf or 0)+1
		end
	end
end

function SWARM:MakeAlpha(ply)
	p:SetNWBool("SwarmLeader",true)
	p:SetModel("models/player/zombie_soldier.mdl")
	p:SetMaxHealth(500)
	p:SetHealth(500)
end

function SWARM:ClearEntityHull(ent,dmg)
	filter = ents.FindByClass("npc_swarm_mother")
	filter[#filter+1]=ent
	--local trace = util.TraceLine({start = ent:GetPos()-vector_up, endpos = ent:GetPos()+vector_up*2, filter = filter},ent)
	local trace = util.TraceEntityHull({start = ent:GetPos(), endpos = ent:GetPos(), filter = filter},ent)
	if(trace.Entity and trace.Entity.Swarm)then
		trace.Entity:TakeDamage(dmg)
	end
end

SWARM.Spawns={}
SWARM.NextSpawn=0
SWARM.SpawnCD=2

function SWARM:SetSpawn(pos,amt,ply)
	table.insert(SWARM.Spawns,{pos=pos,amt=amt,GeneticData = ply.SWARM_GeneticData,Mother = ply.SWARM_Mother})
end


--Don't look that much into variables' names. This code is adapted from EU Homicide (C'HS)
function SWARM:GetStats()
	local perc = 0
	local inf = 0
	local points = 0
	local amt = 0
	local mothers = 0
	local ordercd = 0
	local kingbuildcd = 0
	for i,p in pairs(player.GetAll())do
		perc=perc+(p.SwarmPerc or 0)
		if(p.Swm)then
			inf=inf+1
		end
	end
	for _,p in pairs(ents.FindByClass("npc_swarm*"))do
		points=points+(p.Points or 0)
		amt=amt+1
		if(p:GetClass()=="npc_swarm_mother")then
			mothers = mothers + 1
			ordercd = ordercd + math.Round(p.NextOrder-CurTime())
			amt = amt - 1 --Excluding bullseye
		end
		if(p.King and p.Hiding)then
			kingbuildcd = kingbuildcd + p.Hiding-CurTime()
		end
	end	
	return {Percent=perc,Infected=inf,Points = points,NPCAmt=amt,Mothers = mothers,OrderCD = ordercd,KingBuildCD = kingbuildcd}
end

hook.Add('Think','Swarm',function() 
	if(SWARM.NextNet<=CurTime())then	
		SWARM.NextNet = CurTime() + SWARM.NextNetCD
		for _,ply in pairs(player.GetAll())do
			local perc = math.Round(ply.SwarmPerc or 0)
			if(perc<60)then
				perc = 0
			end
			ply:SetNWInt("SwarmPercent",perc)
		end
	end

	for i,p in pairs(player.GetAll())do
		p.SwarmPerc=p.SwarmPerc or 0
		
		g=p.SwarmPerc
		if(p.Swm)then
			p.SwarmPerc=p.SwarmPerc+engine.TickInterval()*SWARM.CV_InfPerSecond:GetFloat()
			if(p.SwarmPerc>110 and p.Inf==1)then 
				p.Fin=1 
			end 
		end		

		if(p.Swm and math.random(0,1200-p.SwarmPerc*2)==0)then 
			SWARM:Spread(p)
		end
		
		if(g~=nil and g!=0)then 
			p.LostInnocence=true
			p:SetColor(Color(255-math.max(g-80,0),255,255-math.max(g-80,0)))
			if(g>200)then
				p:Kill() 
				p.SwarmPerc=nil 
				p.Swm=false 
			end 
		end 
		
		if(p:GetNWBool("SwarmLeader"))then
			
		end
	end 
end)
hook.Add('Think','Swarm2',function()
	if(SWARM.NextSpawn<=CurTime())then
		SWARM.NextSpawn=CurTime()+SWARM.SpawnCD
		for id,spawn in pairs(SWARM.Spawns)do
			spawn.amt=spawn.amt-1
			hel=ents.Create('npc_swarm')
			hel.GeneticData = spawn.GeneticData
			hel.SWARM_Mother = spawn.Mother
			if(IsValid(hel.SWARM_Mother))then
				hel.HadMother = true
				hel.SWARM_Mother.CreatedNpcs[hel]=CurTime()
			end
			hel:SetPos(spawn.pos)
			hel:Spawn()
			hel:Activate()
			hel:EmitSound('Flesh.Break',35)
			if(spawn.amt<=0)then
				SWARM.Spawns[id]=nil
			end
		end
	end
end)

hook.Add('PlayerDeath','Swarm',function(p) 
	if(p.SwarmPerc>110)then 
		CreateSwarm(p,p.SwarmPerc/65+(p.Fin or 0)) 
	end 
	p.Swm=false 
	p.SwarmPerc=nil
	p.Inf=0 
	p.Fin=0 
	p:SetColor(Color(255,255,255))
	p:SetNWBool("SwarmLeader",false)
	p.SwmInf=0
	p:ClearSwarm()
end)

hook.Add('Player Spawn','Swarm',function(p)
	-- if(!p:Alive() or !IsValid(p.FakeRagdoll))then
	p:ClearSwarm()
	-- end
end)

hook.Add('CanPlayerSuicide','Swarm',function(p) 
	if(p.SwarmPerc>10 and p.Swm)then
		p:ChatPrint("You can't.")
		return false
	end
end)

function SWARM:Psych(ply,time)
	if(!ply:IsPlayer())then return end
	net.Start("SWARM(Psych)")
		net.WriteUInt(time,4)
	net.Send(ply)
	
	ply.SWARM_PsychEnd = CurTime()+time
	--seq_cower
	--print(ply:LookupSequence("seq_cower"))
	--ply:AddVCDSequenceToGestureSlot( GESTURE_SLOT_CUSTOM, ply:LookupSequence("seq_cower"), 0, true )
	--ply:AnimSetGestureWeight( GESTURE_SLOT_CUSTOM, 1 )
	--ply:DoCustomAnimEvent(PLAYERANIMEVENT_CUSTOM_GESTURE_SEQUENCE,ply:LookupSequence("seq_cower"))
	--ply:DoCustomAnimEvent( PLAYERANIMEVENT_ATTACK_GRENADE , 321 )
	--hook.Remove("CalcMainActivity",ply)
	
	SWARM_AffectedEntities[ply] = true
end
--SWARM:Psych(Entity(1),1)

function SWARM:Knockout(ply,time,aftertime)
	if(!ply:IsPlayer())then return end
	net.Start("SWARM(Knockout)")
		net.WriteFloat(time)
		net.WriteUInt(aftertime or 0,4)
	net.Send(ply)
	ply.SWARM_KnockoutEnd = CurTime()+time
	ply.SWARM_AfterKnockoutTime = aftertime or 0
	
	ply:ViewPunch(Angle( 30, math.random(-5,5), math.random(-15,15) ))
	
	SWARM_AffectedEntities[ply] = true
end

function SWARM:ApplyBleed(ply,time,attacker)
	if(ply:IsPlayer())then
		net.Start("SWARM(Bleed)")
			net.WriteFloat(time)
		net.Send(ply)
	end
	ply.SWARM_BleedAttacker = attacker
	ply.SWARM_Bleed = (SWARM_Bleed or 0)+time
	ply.SWARM_NextBleed = CurTime()+SWARM_CV_BleedCD:GetFloat()
	
	--ply:ViewPunch(Angle( 30, math.random(-5,5), math.random(-15,15) ))
	
	SWARM_AffectedEntities[ply] = true
end

function SWARM:TryInfect(ply,amt,attacker,forcedhealth)
	if(ply:Health()<(forcedhealth or SWARM.CV_MinHealth:GetInt()) and ply:IsPlayer())then
		if(!ply.Swm)then
			ply.SWARM_GeneticData = attacker.GeneticData
			ply.SWARM_Mother = attacker.SWARM_Mother
		end
		ply.SwarmPerc=(ply.SwarmPerc or 0)+amt
		ply.Swm=true
	end
end

local PlayerMeta = FindMetaTable("Player")
function PlayerMeta:ClearSwarm()
	self.Swm=false
	self.SwarmPerc=0
	self.Inf=0
	self.Fin=0
	self:SetColor(Color(255,255,255))
	self:SetNWBool("SwarmLeader",false)
	self.SwmInf=0
	
	self.SWARM_KnockoutEnd = nil
	self.SWARM_AfterKnockoutEnd = nil
	self.SWARM_PsychEnd = nil
	self.SWARM_Bleed = nil
	self.SWARM_NextBleed = nil
	SWARM:TryUnAffectEntity(self)
end

PlayerMeta.InvoluntaryEvent = PlayerMeta.InvoluntaryEvent or function(self)
	self:EmitSound('Flesh.Strain')
end

hook.Add('PostCleanupMap','Swarm',function()
	for i,p in pairs(player.GetAll())do
		p:ClearSwarm()
	end 
end)



--hook.Add('EntityTakeDamage','Swarm',function(p,dmg)if(dmg:GetAttacker():GetClass()=='npc_swarm')then p.SwarmPerc=(p.SwarmPerc or 0)+105 p.Swm=true p.Inf=1 end end)
--hook.Remove( "DoAnimationEvent", "MA2AnimEventTest")
function CreateSwarm(p,c)
	local ps=p:GetPos()
	SWARM:SetSpawn(ps+Vector(0,0,50),math.Round(c),p)
	p:ChatPrint(SWARM.Msg)
end

function SWARM:TryUnAffectEntity(ply)
	if(IsValid(ply)) and (ply.SWARM_KnockoutEnd or ply.SWARM_AfterKnockoutEnd or ply.SWARM_PsychEnd or ply.SWARM_Bleed)then return end
	SWARM_AffectedEntities[ply] = nil
end

SWARM_AffectedEntities = SWARM_AffectedEntities or {}
--SWARM_PsychedPlayers = SWARM_PsychedPlayers or {}
hook.Add("Think","SWARM_Misc",function()
	for ply,_ in pairs(SWARM_AffectedEntities)do
		if(IsValid(ply))then
			if(ply.SWARM_KnockoutEnd)then
				if(ply.SWARM_KnockoutEnd<=CurTime())then
					ply.SWARM_KnockoutEnd=nil
					ply.SWARM_AfterKnockoutEnd = CurTime() + ply.SWARM_AfterKnockoutTime
				end
			end
			if(ply.SWARM_AfterKnockoutEnd and ply.SWARM_AfterKnockoutEnd<=CurTime())then
				ply.SWARM_AfterKnockoutEnd = nil
			end
			if(ply.SWARM_PsychEnd and ply.SWARM_PsychEnd<=CurTime())then
				ply.SWARM_PsychEnd = nil
			end
			if(ply.SWARM_Bleed)then
				if(ply.SWARM_NextBleed<=CurTime())then
					ply.SWARM_Bleed = ply.SWARM_Bleed - SWARM_CV_BleedCD:GetFloat()
					ply.SWARM_NextBleed = CurTime() + SWARM_CV_BleedCD:GetFloat()
					local dmg = DamageInfo()
					dmg:SetDamage(SWARM_CV_BleedDmg:GetFloat())
					dmg:SetDamageType(DMG_GENERIC)
					if(IsValid(ply.SWARM_BleedAttacker))then
						dmg:SetAttacker(ply.SWARM_BleedAttacker)
					else
						dmg:SetAttacker(game.GetWorld())
					end
					ply:TakeDamageInfo(dmg)
				end
				if(ply.SWARM_Bleed<=0)then
					ply.SWARM_Bleed = nil
				end
			end
		end
		SWARM:TryUnAffectEntity(ply)
	end
end)

hook.Add("CalcMainActivity","Swarm",function(ply,vel)
	if(ply.SWARM_KnockoutEnd)then
		return ACT_INVALID,ply:LookupSequence("seq_cower")
	end
end)

hook.Add("StartCommand","Swarm",function(ply,cmd)
	local max_speed = ply:GetRunSpeed()

	if(ply.SWARM_KnockoutEnd)then
		cmd:ClearMovement()
		cmd:RemoveKey(IN_JUMP)
		cmd:RemoveKey(IN_DUCK)
	end
	if(ply.SWARM_PsychEnd or ply.SWARM_AfterKnockoutEnd or ply.SWARM_Bleed)then
		local bestmul = 1
		
		if(ply.SWARM_AfterKnockoutEnd)then
			--print(1/((ply.SWARM_AfterKnockoutEnd-CurTime())/ply.SWARM_AfterKnockoutTime))
			local mul = math.min((1-((ply.SWARM_AfterKnockoutEnd-CurTime())/ply.SWARM_AfterKnockoutTime))*0.04,0.08)
			bestmul = mul
		end
		if(ply.SWARM_PsychEnd)then
			--print(ply.SWARM_PsychEnd-CurTime())
			bestmul = math.min(bestmul,(1-((ply.SWARM_PsychEnd-CurTime())/15))*0.5)
		end
		if(ply.SWARM_Bleed)then
			bestmul = math.min(bestmul, 0.7)
		end

		max_speed = max_speed * bestmul

		cmd:SetForwardMove(math.Clamp(cmd:GetForwardMove(), -max_speed, max_speed))
		cmd:SetSideMove(math.Clamp(cmd:GetSideMove(), -max_speed, max_speed))
	end
end)
