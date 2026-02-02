AddCSLuaFile()
ENT={}
ENT.Spawnable = false

ENT.Base = "base_ai"
ENT.Type = "ai"

--C - Carnivore(Ferocious)
--H - Herbivore
--T - Lifetime
--L - Health
--M - Mutation modifier
--I - Infectious
--E - Intelligent

--Rf - Resistance flame
--Rp - Resistance projectile 
--Rm - Resistance melee

--D - Damage

--S - Speed

--A - Royal way of coronation
--B - Their blood way of coronation

--P - Defending(Unused)

ENT.PossibleGenes = {
	{{"C",1},10},
	{{"H",1},20},
	{{"T",1},40},
	{{"L",1},40},
	{{"M",0.6},35},
	
	{{"Rf",1},30},
	{{"Rp",1},30},
	{{"Rm",1},30},
	
	{{"D",1},20},
	
	{{"S",1},10},
	
	{{"A",1},10},
	{{"B",1},20},
	
	{{"I",1},8},

	--{{"P",1},20},
}

ENT.GenesAddTable = {
	["C"]={
		["H"]=-1,
		["E"]=-0.4,
		["I"]=function(self,amt)
			local chance = self:GetGene("C")*12 + self:GetGene("I")*20
			--print(chance)
			if(chance<20)then
				return 0
			end
			if(math.random(1,100)<=chance)then
				return 1
			else
				return 0
			end
		end,
	},
	["H"]={
		["C"]=-1,
		["E"]=function(self,amt)
			local chance = self:GetGene("H")*7
			if(chance<20)then
				return 0
			end
			if(math.random(1,100)<=chance)then
				return 1
			else
				return 0
			end
		end,
		["I"]=function(self,amt)
			local chance = self:GetGene("H")*10
			if(chance<20)then
				return 0
			end
			if(math.random(1,100)<=chance)then
				return -1
			else
				return 0
			end
		end,
	},
	["T"]={
		["L"]=-1,
		["M"]=0.6,
	},
	["L"]={
		["T"]=-1,
		["M"]=-1,
	},
	
	["Rf"]={
		["Rp"]=-0.8,
		["Rm"]=-1,
		["D"]=-0.2,
		["L"]=-0.2,
	},
	["Rp"]={
		["Rf"]=-0.8,
		["Rm"]=-1,
		["D"]=-0.2,
	},
	["Rm"]={
		["Rf"]=-0.6,
		["Rp"]=-1,
		["D"]=-0.2,
	},
	
	["S"]={
		["Rf"]=-0.3,
		["Rp"]=-0.3,
		["Rm"]=-0.3,
		["D"]=-0.3,
	},
	
	["A"]={
		["B"]=-1,
	},
	["B"]={
		["A"]=-1,
	},
}

function ENT:SetupGenes()
	self.AcquiredGenes = self.AcquiredGenes or {}
	self.GeneticData = self.GeneticData or {}
end

function ENT:GeneAddSideEffects(gene,amt)
	if(self.GenesAddTable[gene] and amt>0)then
		for agene, info in pairs(self.GenesAddTable[gene])do
			self.AcquiredGenes[agene] = math.max((self.AcquiredGenes[agene] or 0)+((isfunction(info) and info(self,amt)) or info)*amt,-1)
		end
	end
end

function ENT:AcquireGene(gene,amt)
	if(!SWARM_CV_Evolve:GetBool())then return end
	if(!self.AcquiredGenes)then
		self.AcquiredGenes ={}
	end
	self.AcquiredGenes[gene] = math.max((self.AcquiredGenes[gene] or 0)+amt,0)
	self:GeneAddSideEffects(gene,amt)
end

function ENT:EvolveGenetics()
	if(!SWARM_CV_Evolve:GetBool())then return end
	if(!self.AcquiredGenes)then
		self.AcquiredGenes ={}
	end
	for gene,amt in pairs(self.AcquiredGenes)do
		self.GeneticData[gene] = math.max((self.GeneticData[gene] or 0)+amt,0)
	end
end

function ENT:GetGene(gene)
	if(SWARM_CV_InfectionsDefault:GetInt()>=4)then
		if(gene == "S")then
			return 10
		end
	end
	if(SWARM_CV_InfectionsDefault:GetInt()>=3)then
		if(gene == "H")then
			return 10
		end
	end
	if(SWARM_CV_InfectionsDefault:GetInt()>=2)then
		if(gene == "D")then
			return 10
		elseif(gene == "Rm" or gene == "Rp" or gene == "Rf")then
			return 10
		end
	end
	if(SWARM_CV_InfectionsDefault:GetInt()>=1)then
		if(gene == "I")then
			return (self.InfectiousC or 100)+1
		elseif(gene == "C")then
			return 100
		end
	end
	return (self.GeneticData[gene] or 0)
end

function ENT:MutateGenes(genetics,mutationmul)
	if(!SWARM_CV_Evolve:GetBool())then return end
	genetics = genetics or self.GeneticData
	mutationmul = mutationmul or 1
	local chance = mutationmul*SWARM_CV_MutationMul:GetFloat()*(self:GetGene("M")+1)*8
	if(math.random(1,100)<=chance)then
		local amt = math.random(1,math.Round(self:GetGene("M")+1))
		for _=1,amt do
			local ginfo = SWARM:WeightedRandomSelect(self.PossibleGenes)
			local gene,amt = ginfo[1],ginfo[2]
			genetics[gene] = (genetics[gene] or 0)+amt
			if(self.GenesAddTable[gene] and amt>=0)then
				for agene, info in pairs(self.GenesAddTable[gene])do
					if(isfunction(info))then
						info = info(self,amt)
					end
					genetics[agene] = math.max((genetics[agene] or 0)+info*amt,0)
				end
			end
		end
	end
	return genetics
end

function ENT:CopyGenetics(genetics)
	return table.Copy(genetics or {})
end

function ENT:TryInfect( ent,amt )
	if(self:GetGene("I")>=(self.InfectiousC or 5))then
		local forcedhealth = self:GetInfectHealthMul(self.MaxInfectedHealthMul or 1.5)*SWARM.CV_MinHealth:GetInt()
		SWARM:TryInfect(ent,amt,self,forcedhealth)
	end
end

function ENT:GetInfectHealthMul(max,div)
	div = div or 3
	return math.Clamp((self:GetGene("I"))/div,1,max)
end

function ENT:GetDamageMul( max,div )
	div = div or 1.5
	return math.Clamp((self:GetGene("D")+1)/div,1,max)
end

ENT.DefenceGeneMuls = {
	[DMG_SLASH] = {
		["Rm"] = 2
	},
	[DMG_CRUSH] = {
		["Rm"] = 2
	},
	[DMG_GENERIC] = {
		["Rm"] = 1.5
	},
	[DMG_CLUB] = {
		["Rm"] = 2
	},
	
	[DMG_BURN] = {
		["Rf"] = 1.5
	},
	[DMG_SLOWBURN] = {
		["Rf"] = 1.5
	},
	
	[DMG_BUCKSHOT] = {
		["Rp"] = 2
	},
	[DMG_SNIPER] = {
		["Rp"] = 2
	},
	[DMG_BULLET] = {
		["Rp"] = 2
	},
}
--TODO bit.band
function ENT:GetDefenceMul( dmgtype,max,div )
	--print(dmgtype)
	div = div or 1.5
	local def = 0
	for ddmg,info in pairs(self.DefenceGeneMuls)do
		--if(!info)then return 1 end
		if(bit.band(dmgtype,ddmg)==ddmg)then
			for gene,gmul in pairs(info)do
				def = def + self:GetGene(gene)*gmul
			end
		end
	end
	return math.Clamp(def/div,1,max)
end

function ENT:GetHealthMul( max,div )
	div = div or 1.5
	return math.Clamp((self:GetGene("L")+1)/div,1,max)
end

function ENT:GetSpeedMul( max,div )
	div = div or 1.5
	return math.Clamp((self:GetGene("S")+1)/div,1,max)
end

function ENT:GetLifeTimeMul( max,div )
	div = div or 2
	return math.Clamp((self:GetGene("T")+1)/div,1,max)
end

function ENT:GetCoronationType( )
	local dif = self:GetGene("A")-self:GetGene("B")
	if(dif>0)then
		return "A"
	else
		return "B"
	end
end

function ENT:GetCarnivoreStrenght( )
	local dif = self:GetGene("C")-self:GetGene("H")
	return dif
end

function ENT:IsEntityMeaty(ent)
	if(ent:IsPlayer() or ent:IsNPC())then
		return true
	end
	return false
end

function ENT:IsEntityPossibleEnemy(ent,amt)
	self.Hostiles = self.Hostiles or {}
	local hostiles = self.Hostiles
	if(IsValid(self.SWARM_Mother))then
		self.SWARM_Mother.Hostiles = self.SWARM_Mother.Hostiles or {}
		hostiles = self.SWARM_Mother.Hostiles
	elseif(self:GetCarnivoreStrenght()>-1 and !self.HadMother)then
		return true
	end
	amt = amt or 100
	if((hostiles[ent] or 0)>amt)then
		return true
	elseif(self:GetCarnivoreStrenght( )>0 and self:IsEntityMeaty(ent))then
		return true
	elseif(!self:IsEntityMeaty(ent))then
		return true
	end
	return false
end

function ENT:SetMother(ent)
	self.SWARM_Mother = ent
end

function ENT:TransferMotherRights(ent)
	ent.CreatedNpcs = self.CreatedNpcs
	ent.Hostiles = self.Hostiles
	for npc,time in pairs(ent.CreatedNpcs)do
		if(IsValid(npc))then
			npc:SetMother(ent)
		else
			ent.CreatedNpcs[npc]=nil
		end
	end
end

function ENT:HostileNotificationMother(enemy,amt)
	if(IsValid(self.SWARM_Mother))then
		self.SWARM_Mother:AddHostile(enemy,amt)
	else
		self:AddHostile(enemy,amt)
	end
end

function ENT:AddHostile(enemy,amt)
	self.Hostiles = self.Hostiles or {}
	self.Hostiles[enemy] = (self.Hostiles[enemy] or 0) + amt
	if((self.AcquiredGenes["C"] or 0)<1)then
		self:AcquireGene("C",amt/200)
	end
end

function ENT:ApplyFireIntoleranceMul( dmg )
	if(bit.band(dmg:GetDamageType(),DMG_BURN)==DMG_BURN or bit.band(dmg:GetDamageType(),DMG_SLOWBURN)==DMG_SLOWBURN)then
		dmg:SetDamage(dmg:GetDamage()*2)
	end
end

function ENT:DeathThink()
	if(self.NextDeath and self.NextDeath<=CurTime() and SWARM_CV_AllowDeath:GetBool() and !self.King)then
		self:TakeDamage(100)
	end
end

function ENT:ValidateEnemyData( )
	if(!SERVER)then return end
	local lastenem = self:GetEnemy()
	if(IsValid(lastenem))then
		if((self:GetPos():DistToSqr(lastenem:GetPos())>self.ForgetRangeCVAR:GetInt()^2) or (lastenem:IsPlayer() and !lastenem:Alive()))then
			if(!self.NextForget)then
				self.NextForget = CurTime() + ((lastenem:IsPlayer() and !lastenem:Alive() and 0) or self.ForgetTimeCVAR:GetFloat())
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

scripted_ents.Register(ENT,"swarm_ai_base")