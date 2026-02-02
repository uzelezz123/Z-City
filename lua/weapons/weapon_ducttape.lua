if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Duct Tape"
SWEP.Instructions = "Reinforced duct tape, useful if you're a terrorist and want to take someone prisoner. It is also useful for creating barricades."
SWEP.Category = "ZCity Other"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.DefaultClip = 0
SWEP.Primary.ClipSize = 0

SWEP.Secondary.Ammo = "none"
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.ClipSize = 0

SWEP.Primary.Automatic = true
--__settings__--
SWEP.fastHitAllow = false
SWEP.HoldType = "slam"
SWEP.DamageType = DMG_CLUB
SWEP.Penetration = 2
SWEP.traceOffsetAng = Angle(70, -5, 0)
SWEP.traceOffsetVec = Vector(3, .5, 0)
SWEP.traceLen = 12
SWEP.offsetVec = Vector(4, -3.5, -1.5)
SWEP.offsetAng = Angle(90, 180, 0)

SWEP.HitSound = "Flesh.ImpactHard"
SWEP.HitSound2 = "Flesh.ImpactHard"
SWEP.HitWorldSound = "Flesh.ImpactHard"

SWEP.r_forearm = Angle(0, 15, 0)
SWEP.r_upperarm = Angle(5, -60, 15)
SWEP.r_hand = Angle(0, 0, 0)
SWEP.l_forearm = Angle(0, 0, 0)
SWEP.l_upperarm = Angle(0, 0, 0)

SWEP.weaponInvCategory = false

SWEP.DeploySnd = "physics/body/body_medium_impact_soft5.wav"
SWEP.HolsterSnd = ""

SWEP.modeNames = {[true] = "huy",[false] = "chlen"}

SWEP.sprint_ang = Angle(20,0,0)
SWEP.sprint_pos = Vector(-5,0,-5)

local clr, mat = Color(100, 100, 100, 255), "models/shiny"
function SWEP:Initialize()
	--self:SetModelScale(0.15)
	--self:SetColor(clr)
	--self:SetMaterial(mat)
	self:Activate()
	if IsValid(self:GetPhysicsObject()) then
		self:GetPhysicsObject():SetMass(5)
	end
end

function SWEP:InitializeAdd()
	--self:PhysicsInit(SOLID_VPHYSICS)
end

function SWEP:OwnerChanged()
	--self:SetModelScale(0.15)
	--self:SetColor(clr)
	--self:SetMaterial(mat)
	self:Activate()
	self:SetHoldType(self.HoldType)
	if IsValid(self:GetPhysicsObject()) then
		self:GetPhysicsObject():SetMass(5)
	end
end

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_ducttape")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_ducttape"
	SWEP.BounceWeaponIcon = false
end

--
SWEP.ViewModel = ""
SWEP.WorldModel = "models/distac/scotch.mdl"
SWEP.WorldModelReal = "models/distac/weapon/scotchanim.mdl"
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 4
SWEP.SlotPos = 1
SWEP.WorkWithFake = false
SWEP.angHold = Angle(0, 0, 0)
SWEP.UnTapeables = { MAT_SAND,MAT_SLOSH,MAT_SNOW}
SWEP.TapeAmount = 100

SWEP.AnimList = {
	["start"] = { "start", 2.5, false },
	["stop"] = { "start", 1, false },
}

SWEP.setlh = true
SWEP.setrh = true

SWEP.HoldPos = Vector(8,0.2,-25)
SWEP.HoldAng = Angle(0,0,0)

SWEP.ViewBobCamBase = "ValveBiped.Bip01_R_UpperArm"
SWEP.ViewBobCamBone = "ValveBiped.Bip01_R_Hand"
SWEP.ViewPunchDiv = 120

game.AddDecal("hmcd_jackatape","decals/mat_jack_hmcd_ducttape")

function SWEP:SetupDataTables()
	self:NetworkVar("Int", 0, "TapeAmount")
	self:SetTapeAmount(self.TapeAmount)
	self:NetworkVar("Float", 0, "Holding")
end

function SWEP:GetEyeTrace()
	return hg.eyeTrace(self:GetOwner())
end

--function SWEP:DrawWorldModel()
--	self.model = IsValid(self.model) and self.model or ClientsideModel(self.WorldModel)
--	local WorldModel = self.model
--	local owner = self:GetOwner()
--	WorldModel:SetNoDraw(true)
--	--WorldModel:SetModelScale(0.15)
--	if IsValid(owner) then
--		local offsetVec = self.offsetVec
--		local offsetAng = self.offsetAng
--		local boneid = owner:LookupBone(((owner.organism and owner.organism.rarmamputated) or (owner.zmanipstart ~= nil and owner.zmanipseq == "interact" and not owner.organism.larmamputated)) and "ValveBiped.Bip01_L_Hand" or "ValveBiped.Bip01_R_Hand")
--		if not boneid then return end
--		local matrix = owner:GetBoneMatrix(boneid)
--		if not matrix then return end
--		local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())
--		WorldModel:SetPos(newPos)
--		WorldModel:SetAngles(newAng)
--		WorldModel:SetupBones()
--	else
--		WorldModel:SetPos(self:GetPos())
--		WorldModel:SetAngles(self:GetAngles())
--	end
--
--	--WorldModel:SetColor(clr) -- поч не робит
--	--WorldModel:SetMaterial(mat)
--	
--	WorldModel:DrawModel()
--end

local bone, name
function SWEP:BoneSet(lookup_name, vec, ang)
    if IsValid(self:GetOwner()) and !self:GetOwner():IsPlayer() then return end
	hg.bone.Set(self:GetOwner(), lookup_name, vec, ang)
end

local lang1, lang2 = Angle(0, -10, 0), Angle(0, 10, 0)
function SWEP:Animation()
	if (self:GetOwner().zmanipstart ~= nil and not self:GetOwner().organism.larmamputated) then return end
	local hold = self:GetHolding()
    self:BoneSet("r_upperarm", vector_origin, Angle(0, -10 - hold / 1.5, 10))
    self:BoneSet("r_forearm", vector_origin, Angle(0, hold / 1, 0))

    self:BoneSet("l_upperarm", vector_origin, lang1)
    self:BoneSet("l_forearm", vector_origin, lang2)
end

function SWEP:Think()
	local owner = self:GetOwner()
	if IsValid(owner) and owner:KeyDown(IN_ATTACK) then return end
	self:SetHolding(math.max(self:GetHolding() - 1, 25))
	self:PlayAnim('start', 0)
end

function SWEP:CustomTiming()
	self.lasttapeamount = self.lasttapeamount or self:GetTapeAmount()
	if self:GetTapeAmount() < self.lasttapeamount then
		self.LerpedHolding = 0.25
		self.lasttapeamount = self:GetTapeAmount()
	end

	self.LerpedHolding = math.Clamp(LerpFT(0.01, self.LerpedHolding or 0, self:GetHolding() / 100), 0, 0.68)

	self.setlh = !(self.LerpedHolding <= 0.26)
	return self.LerpedHolding
end

local colWhite = Color(255, 255, 255, 255)
local colGray = Color(200, 200, 200, 200)
local OffsetPos = {290,220}
if CLIENT then
    local Mat = Material("vgui/wep_jack_hmcd_ducttape")
	local mul = 1
    function SWEP:DrawHUD() 

		surface.SetDrawColor(0,0,0)
        surface.SetMaterial(Mat)
        surface.DrawTexturedRect(ScrW()-352.5,ScrH()-252.5,306,156)

		surface.SetDrawColor(255,255,255,255)
		surface.SetMaterial(Mat)
		mul = Lerp(FrameTime()*15, mul, ((self:GetTapeAmount()+10)/100) )
		surface.DrawTexturedRectUV(ScrW()-350,ScrH()-250,300 * mul,150,0, 0, 1 * mul , 1)

        local Owner = self:GetOwner()
		local toScreen = self:GetEyeTrace().HitPos:ToScreen()
		for i=1,10 do
			surface.DrawCircle(toScreen.x, toScreen.y, 55-i, 155-i*15,155-i*15,155-i*15,205)
		end
    end
end

local function BindObjects(ent1,pos1,ent2,pos2,power,bone1,bone2)
	ent1.DuctTape = ent1.DuctTape or {}
	ent2.DuctTape = ent2.DuctTape or {}
	local Strength = ent1.DuctTape and ent1.DuctTape[bone1] and #ent1.DuctTape[bone1] or 1
	local weld = !ent1:IsRagdoll() and !ent2:IsRagdoll() and constraint.Rope(ent1,ent2,0,0,ent1:WorldToLocal(pos1),ent2:WorldToLocal(pos2),(pos1-pos2):Length(),-.1,(500+Strength*100)*5,0,"",false) or constraint.Weld(ent1,ent2,bone1,bone2,(500+Strength*100)*15,false,false)
	
	if not ent1.DuctTape[bone1] then
    	ent1.DuctTape[bone1] = {weld,1}
		weld:CallOnRemove("removefromtbl",function() ent1.DuctTape[bone1] = nil end)
	else
		ent1.DuctTape[bone1][2] = ent1.DuctTape[bone1][2] + 1
	end

	if not ent2.DuctTape[bone2] then
    	ent2.DuctTape[bone2] = {weld,1}
		weld:CallOnRemove("removefromtbl",function() ent2.DuctTape[bone2] = nil end)
	else
		ent2.DuctTape[bone2][2] = ent2.DuctTape[bone2][2] + 1
	end

	return ent1:IsWorld() and ent2.DuctTape[bone2][2] or ent1.DuctTape[bone1][2]
end

function hgCheckDuctTapeObjects(ent1)
	if not ent1.DuctTape then return end

    return (ent1.DuctTape and ent1.DuctTape[0] and #ent1.DuctTape[0]) or 0 
end

if SERVER then
	hook.Add("Should Fake Up","DuctTaped",function(ply)
		if ply and IsValid(ply.FakeRagdoll) then
			local dtape = ply.FakeRagdoll.DuctTape

			if dtape then
				for i,tbl in pairs(dtape) do
					if tbl[2] > 0 then
						tbl[2] = tbl[2] - 0.2
						ply.FakeRagdoll:EmitSound("tape_friction"..math.random(3)..".mp3",65)
						if tbl[2] <= 0 then
							if IsValid(tbl[1]) then
								tbl[1]:Remove()
								tbl[1] = nil
							end
							dtape[i] = nil
						end
						break
					end
				end
				
				if table.Count(dtape) > 0 then
					ply.fakecd = CurTime() + 1
					return false
				end
			end
		end
	end)
end
function SWEP:FindObjects()
	local Owner = self:GetOwner()
	local Pos, Vec, GotOne, Tries, TrOne, TrTwo = select(1, hg.eye(Owner)), Owner:GetAimVector(), false, 0, nil, nil
	while(not(GotOne)and(Tries<100))do
		local Tr=util.QuickTrace(Pos - Vec * 10,Vec*60,{Owner})
		local FindBone = util.QuickTrace(Pos,Vec*60,{Owner})
		if((Tr.Hit)and not(Tr.HitSky)and not(table.HasValue(self.UnTapeables,Tr.MatType)))then
			GotOne=true
			TrOne=Tr
			TrOne.PhysicsBone = FindBone.PhysicsBone
		end
		Tries=Tries+1
	end
	if(GotOne)then
		GotOne=false
		Tries=0
		while(not(GotOne)and(Tries<100))do
			local Tr=util.QuickTrace(Pos - Vec * 10,Vec*60+VectorRand()*1,{Owner,TrOne.Entity})
			local FindBone = util.QuickTrace(Pos,Vec*60,{Owner,TrOne.Entity})
			if((Tr.Hit)and not(Tr.HitSky)and not(table.HasValue(self.UnTapeables,Tr.MatType))and (Tr.Entity ~= TrOne.Entity))then
				GotOne=true
				TrTwo=Tr
				TrTwo.PhysicsBone = FindBone.PhysicsBone
			end
			Tries=Tries+1
		end
	end
	if((TrOne)and(TrTwo))then return true,TrOne,TrTwo else return false,nil,nil end
end

function SWEP:PrimaryAttack()
	local Owner = self:GetOwner()
	if(Owner:KeyDown(IN_SPEED))then return end
	if(SERVER)then
		if not(self.TapeAmount)then self.TapeAmount=100 end
		local Go,TrOne,TrTwo=self:FindObjects()
		self:SetHolding(math.Clamp(self:GetHolding() + 1, 25, 100))
		if(Go)then
			if self:GetHolding() < 100 then return end

			local DoorSealed=false
			if(hgIsDoor(TrOne.Entity))then
				DoorSealed=true
				if !DoorIsOpen(TrOne.Entity) then
					if !TrOne.Entity.LockedDoor then
						TrOne.Entity.LockedDoorMap = true
					end
				else
					TrOne.Entity.LockedDoorMap = false
				end

				TrOne.Entity:Fire("lock","",0)
				TrOne.Entity.LockedDoor = self.TapeAmount
			end
			if(hgIsDoor(TrTwo.Entity))then
				DoorSealed=true
				if !DoorIsOpen(TrTwo.Entity) then
					if !TrTwo.Entity.LockedDoor then
						TrTwo.Entity.LockedDoorMap = true
					end
				else
					TrTwo.Entity.LockedDoorMap = false
				end
				TrTwo.Entity:Fire("lock","",0)
				TrTwo.Entity.LockedDoor = self.TapeAmount
			end
			if(DoorSealed)then
				self.TapeAmount=self.TapeAmount-100
				self:SetTapeAmount(self.TapeAmount)
				sound.Play("snd_jack_hmcd_ducttape.wav",TrOne.HitPos,65,math.random(80,120))
				Owner:SetAnimation(PLAYER_ATTACK1)
				Owner:ViewPunch(Angle(3,0,0))
				self:SprayDecals()
				Owner:PrintMessage(HUD_PRINTCENTER,"Door Sealed")
				timer.Simple(.1,function() if(self.TapeAmount<=0)then self:Remove() end end)

				self:SetHolding(25)
			else
				local Strength = BindObjects(TrOne.Entity,TrOne.HitPos,TrTwo.Entity,TrTwo.HitPos,2,TrOne.PhysicsBone,TrTwo.PhysicsBone)
				if not(self.TapeAmount)then self.TapeAmount=100 end
				self.TapeAmount=self.TapeAmount-10
				self:SetTapeAmount(self.TapeAmount)
				sound.Play("snd_jack_hmcd_ducttape.wav",TrOne.HitPos,65,math.random(80,120))
				Owner:SetAnimation(PLAYER_ATTACK1)
				Owner:ViewPunch(Angle(3,0,0))
				util.Decal("hmcd_jackatape",TrOne.HitPos+TrOne.HitNormal,TrOne.HitPos-TrOne.HitNormal)
				util.Decal("hmcd_jackatape",TrTwo.HitPos+TrTwo.HitNormal,TrTwo.HitPos-TrTwo.HitNormal)
				--Owner:PrintMessage(HUD_PRINTCENTER,"Bond strength: "..tostring(Strength))
				Owner:ChatPrint("Bond strength: " .. tostring(Strength))
				timer.Simple(.1,function() if(self.TapeAmount<=0)then self:Remove() end end)

				self:SetHolding(25)
			end
		end
	end

	self:SetNextPrimaryFire(CurTime() + 1.5)
end

function SWEP:SecondaryAttack()
end

function SWEP:CanSecondaryAttack()
	return false 
end

function SWEP:SprayDecals()
	local Owner = self:GetOwner()
	local pos = select(1, hg.eye(Owner))
	local aim = Owner:GetAimVector()
	local Tr=util.QuickTrace(pos,aim*70,{Owner})
	util.Decal("hmcd_jackatape",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal)

	local Tr2=util.QuickTrace(pos,(aim+Vector(0,0,.15))*70,{Owner})
	util.Decal("hmcd_jackatape",Tr2.HitPos+Tr2.HitNormal,Tr2.HitPos-Tr2.HitNormal)

	local Tr3=util.QuickTrace(pos,(aim+Vector(0,0,-.15))*70,{Owner})
	util.Decal("hmcd_jackatape",Tr3.HitPos+Tr3.HitNormal,Tr3.HitPos-Tr3.HitNormal)

	local Tr4=util.QuickTrace(pos,(aim+Vector(0,.15,0))*70,{Owner})
	util.Decal("hmcd_jackatape",Tr4.HitPos+Tr4.HitNormal,Tr4.HitPos-Tr4.HitNormal)

	local Tr5=util.QuickTrace(pos,(aim+Vector(0,-.15,0))*70,{Owner})
	util.Decal("hmcd_jackatape",Tr5.HitPos+Tr5.HitNormal,Tr5.HitPos-Tr5.HitNormal)

	local Tr6=util.QuickTrace(pos,(aim+Vector(.15,0,0))*70,{Owner})
	util.Decal("hmcd_jackatape",Tr6.HitPos+Tr6.HitNormal,Tr6.HitPos-Tr6.HitNormal)

	local Tr7=util.QuickTrace(pos,(aim+Vector(-.15,0,0))*70,{Owner})
	util.Decal("hmcd_jackatape",Tr7.HitPos+Tr7.HitNormal,Tr7.HitPos-Tr7.HitNormal)
end