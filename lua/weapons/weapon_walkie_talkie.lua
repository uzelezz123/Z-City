if(SERVER)then 
	AddCSLuaFile() 
end

SWEP.Base = "weapon_base"
SWEP.PrintName = "Walkie-talkie"
SWEP.Instructions = "Use the walkie-talkie to communicate with other people in the 4km radius. Must be on the same frequency."
SWEP.Category = "ZCity Other"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.IdleHoldType = "normal"
SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/sirgibs/ragdoll/css/terror_arctic_radio.mdl"

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_walkietalkie")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_walkietalkie.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Slot = 5
SWEP.SlotPos = 5
SWEP.WorkWithFake = true
SWEP.offsetVec = Vector(6, 5.5, -41)
SWEP.offsetAng = Angle(180, 160, 180)

SWEP.Frequency = 88.6
SWEP.Frequencies = {
	88.6,
    92.3,
    97.5,
    101.8,
    107.8
}

local ST_TYPE_LOCALFILE = 0
local ST_TYPE_URL = 1

SWEP.FMStations = {
	[97.5] = {ST_TYPE_LOCALFILE, function() return "radiorandom/radio" .. math.random(1,10) .. ".wav", 0 end},

	--[98.2] = {ST_TYPE_LOCALFILE, function()
	--	local track = "zc_dyna_music/medge/a".. math.random(1,15) ..".mp3"
	--	return track, SoundDuration(track)
	--end},
}

function SWEP:BippSound(ent, pitch)
    ent:EmitSound("radio/voip_end_transmit_beep_0" .. math.random(1,8) .. ".wav", 35, pitch)
end

if SERVER then
    function SWEP:CanListen(output, input, isChat)
		if !self.isOn or !input:GetWeapon("weapon_walkie_talkie").isOn then
			return false
		end
		if(not IsValid(output) or not IsValid(input))then 
			return
		end

        if(not output:Alive() or output.organism.otrub or not input:Alive() or input.organism.otrub)then 
			return false
		end

        if(not input:HasWeapon("weapon_walkie_talkie"))then 
			return
		end

        if(output:GetActiveWeapon() ~= self)then 
			return
		end

		if self.FMStations[self.Frequency] then
			return
		end

        if(output:GetWeapon("weapon_walkie_talkie").Frequency == input:GetWeapon("weapon_walkie_talkie").Frequency or output:Team() == 1002)then 
			return true
		end
    end

    hook.Add("CanListenOthers", "radio", function(output, input, isChat, teamonly, text)
        local wep = output:GetWeapon("weapon_walkie_talkie")

		if not IsValid(wep) then 
			return
		end

        if wep:CanListen(output, input, isChat) then

            if isChat then
				wep:BippSound(output, 100)

				if output == input then 
					return 
				end
                
                wep:BippSound(input, 100)

				if input:GetPos():DistToSqr(output:GetPos()) < 600000 and not output.organism.otrub and not input.organism.otrub then
					return true
				else
                    input:ChatPrint("Walkie Talkie: " .. text)

					return false
				end
			else
				return true, false
            end
        end
    end)

	hook.Add("StartVoice", "radio", function(output)
        local wep = output:GetWeapon("weapon_walkie_talkie")

		if(not IsValid(wep))then 
			return 
		end

		for i, input in player.Iterator() do
			if wep:CanListen(output, input, false) then
				if output == input then 
					wep:SetInUsing(true)
					wep:BippSound(output, 100) 
					continue 
				end

				wep:BippSound(input, 100)
			end
		end
    end)

	hook.Add("EndVoice", "radio", function(output)
        local wep = output:GetWeapon("weapon_walkie_talkie")

		if not IsValid(wep) then 
			return 
		end

		for i, input in player.Iterator() do
			if wep:CanListen(output, input, false) then
				if output == input then 
					wep:BippSound(output, 100) 
					wep:SetInUsing(false)
					continue 
				end

				wep:BippSound(input, 100)
			end
		end
    end)

	function SWEP:OnRemove() end

	function SWEP:Deploy()
		self:SetHudFrequency(self.Frequency)
		self.isOn = self.isOn or false
		self:SetIsOn(self.isOn)
		self:SetInUsing(false)
	end

end

function SWEP:DrawWorldModel()
	if !self:GetOwner():IsPlayer() then
		self:DrawModel()
	end
end

function SWEP:SetupDataTables()
	self:NetworkVar( "Float", 0, "HudFrequency" )
	self:NetworkVar( "Bool", 0, "IsOn" )
	self:NetworkVar( "Bool", 1, "InUsing" )
end

local walkietalkie_clr = Color(0,0,0)
local bg_clr = Color(0,75,0)
local bg_off_clr = Color(0,32,0)

SWEP.ScreenPosOffset = Vector(3.4,-2.22,3.57)
SWEP.ScreenAngleOffset = Angle(-5,-18.5,91)

if CLIENT then
	surface.CreateFont("Walkie-Talkie_Fixed-Font", {
		font = "Ari-W9500",
		size = 64,
		weight = 600,
		outline = false
	})

	surface.CreateFont("Walkie-Talkie_Fixed-SmallFont", {
		font = "Ari-W9500",
		size = 50,
		weight = 600,
		outline = false
	})
end

function SWEP:DrawWorldModel2()
	self.model = IsValid(self.model) and self.model or ClientsideModel(self.WorldModel)
	local WorldModel = self.model
	local owner = hg.GetCurrentCharacter(self:GetOwner())

	WorldModel:SetNoDraw(true)
	WorldModel:SetModelScale(self.ModelScale or 1)

	if(IsValid(owner))then
		local offsetVec = self.offsetVec
		local offsetAng = self.offsetAng
		local boneid = owner:LookupBone("ValveBiped.Bip01_L_Hand")

		if(not boneid)then 
			return 
		end

		local matrix = owner:GetBoneMatrix(boneid)

		if(not matrix)then 
			return
		end

		local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())
		WorldModel:SetPos(newPos)
		WorldModel:SetAngles(newAng)
		WorldModel:SetupBones()

		WorldModel:DrawModel()

		newPos, newAng = LocalToWorld(self.ScreenPosOffset, self.ScreenAngleOffset, matrix:GetTranslation(), matrix:GetAngles())

		cam.Start3D2D( newPos, newAng, 0.005 )
			local Frequency = math.Round(self:GetHudFrequency(),1) .. " MHz"
			--local IsOn = self:GetIsOn() and "On" or "Off"
			local width, height = 264, 145
			draw.RoundedBox(3, 0 - width / 2, 0 - height / 2, width, height, self:GetIsOn() and bg_clr or bg_off_clr)
			if self:GetIsOn() then
				draw.SimpleText(Frequency, "Walkie-Talkie_Fixed-Font", 0, -15, walkietalkie_clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText(self:GetOwner():IsSpeaking() and "Broadcasting" or "Reciving", "Walkie-Talkie_Fixed-SmallFont", 0, 40, walkietalkie_clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		cam.End3D2D()

	else
		WorldModel:SetPos(self:GetPos())
		WorldModel:SetAngles(self:GetAngles())
		WorldModel:DrawModel()
	end
end

function SWEP:SetHold(value)
	self:SetWeaponHoldType(value)
	self:SetHoldType(value)
	self.holdtype = value
end

local bone, name
function SWEP:BoneSet(lookup_name, vec, ang)
	local owner = self:GetOwner()
    if IsValid(owner) and !owner:IsPlayer() then return end
	hg.bone.Set(owner, lookup_name, vec, ang, "walkietalkie", 0.01)
end

local handAng1, handAng2 = Angle(-15, -10, 10), Angle(5, -65, -60)
local actAng1, actAng2 = Angle(0, -40, -18), Angle(-5, -5, -70)
function SWEP:Step()
	local owner = self:GetOwner()
	local active = owner:KeyDown(IN_ATTACK) and self:GetIsOn()

	if active then
		self:SetHold(self.HoldType)
	elseif self:GetHoldType() ~= self.IdleHoldType then 
		self:SetHold(self.IdleHoldType)
	end

	if owner:OnGround() and owner:GetVelocity():LengthSqr() <= 1000 and not owner:IsTyping() and not owner:IsFlagSet(FL_ANIMDUCKING) then
		self:BoneSet("l_upperarm", vector_origin, self:GetIsOn() and handAng1 or angle_zero)
		self:BoneSet("l_forearm", vector_origin, self:GetIsOn() and handAng2 or angle_zero)

		self:BoneSet("r_upperarm", vector_origin, active and actAng1 or angle_zero)
		self:BoneSet("r_forearm", vector_origin, active and actAng2 or angle_zero)
	end
end

function SWEP:Think()
	local owner = self:GetOwner()

	if CLIENT then
		local FMStations = self.FMStations[ math.Round(self:GetHudFrequency(),1) ]
		if FMStations and self:GetIsOn() then
			local Type = FMStations[1]
			local Output = FMStations[2]
			self.FM_EventCD = self.FM_EventCD or CurTime() + math.random(125,165)
			if self.FM_EventCD < CurTime() then
				self:BippSound(self:GetOwner())
				self.FM_EventCD = CurTime() + math.random(125,165)
				local play, timeadd = Output()
				timer.Simple(0.5,function()
					local ent = IsValid(self.model) and self.model or self
					ent:EmitSound(play, 55, 100, 1, CHAN_AUTO, nil, 56)
					self.FM_EventCD = self.FM_EventCD + timeadd
				end)
			end
		end
	end
end

if CLIENT then
	function SWEP:MenuAddAdjuster(strName, tbl, howmuch)
		tbl[#tbl + 1] = {function()
			local tbl1 = {}
			tbl1[#tbl1 + 1] = {function() RunConsoleCommand("hg_walkietalkie_adjust", howmuch) return -1 end,"Increase"}
			tbl1[#tbl1 + 1] = {function() RunConsoleCommand("hg_walkietalkie_adjust", -howmuch) return -1 end,"Decrease"}
			hg.CreateRadialMenu(tbl1)
			return -1
		end, strName}
	end
end

if SERVER then
	concommand.Add("hg_walkietalkie_adjust", function(ply, cmd, args)
		if SERVER then
			if not args[1] then return end
			local ActiveWep = ply:GetActiveWeapon()
			local walkietalkie = IsValid(ActiveWep) and ActiveWep:GetClass() == "weapon_walkie_talkie" and ActiveWep or false
			if not walkietalkie then return end
			walkietalkie:AdjustFrequency( tonumber( args[1] ) )
		end
	end)
end

function SWEP:PrimaryAttack()
	if SERVER then return end
	local tbl = {}
	if self:GetIsOn() then
		tbl[#tbl + 1] = {function()
			local tbl1 = {}
			for i = 1, #self.Frequencies do
				local station = math.Round(self.Frequencies[i], 1)
				tbl1[#tbl1 + 1] = { function() RunConsoleCommand("hg_walkietalkie_adjust", station - self:GetHudFrequency() ) end, "Station " .. station .. "MHz" }
				hg.CreateRadialMenu(tbl1)
			end
			return -1
		end, "Public stations"}
		self:MenuAddAdjuster("Change 010.0 MHz", tbl, 010.0)
		self:MenuAddAdjuster("Change 001.0 MHz", tbl, 001.0)
		self:MenuAddAdjuster("Change 000.1 MHz", tbl, 000.1)
	end

	tbl[#tbl + 1] = {function()
		RunConsoleCommand("+reload")
		timer.Simple(0,function() RunConsoleCommand("-reload") end)
	end, self:GetIsOn() and "Turn off Walkie-Talkie" or "Turn on Walkie-Talkie"}
	hg.CreateRadialMenu(tbl)
end

function SWEP:AdjustFrequency(numAdjust)
	self.Frequency = math.Round(math.Clamp(self.Frequency + numAdjust, 87.5, 108),1)
	self:SetHudFrequency(self.Frequency)

	local owner = self:GetOwner()
	owner:EmitSound("radiotune.mp3", 45, math.random(95, 105))
	owner:SetAnimation(PLAYER_ATTACK1)

	return self.Frequency
end

if CLIENT then
	-- local walkietalkie_clr = Color(230,230,230)
	-- local bg_clr = Color(0,0,0,150)
	function SWEP:DrawHUD()
		-- local Frequency = math.Round(self:GetHudFrequency(),1) .. " MHz"
		-- local IsOn = self:GetIsOn() and "On" or "Off"
		-- local width, height = ScreenScale(65), ScreenScaleH(28)
		-- draw.RoundedBox(0, (ScrW() / 2) - width / 2, (ScrH() * 0.912) - height / 2, width, height, bg_clr)

		-- draw.SimpleText(Frequency, "HomigradFontMedium",ScrW() / 2, ScrH() * 0.9, walkietalkie_clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		-- draw.SimpleText("Walkie-Talkie | " .. IsOn, "HomigradFontMedium",ScrW() / 2, ScrH() * 0.92, walkietalkie_clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

function SWEP:Initialize()
	self:SetHold(self.HoldType)
	if SERVER then
		self.isOn = false
	end
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
	local owner = self:GetOwner()
	if SERVER and (!self.turnOnCD or self.turnOnCD < CurTime()) then
		self.turnOnCD = CurTime() + 0.5
		self.isOn = !self.isOn
		self:SetIsOn(self.isOn)
		self:BippSound(owner)
		owner:SetAnimation(PLAYER_ATTACK1)

		--owner:EmitSound("")
		--owner:zChatPrint("Walkie-Talkie is "..(self.isOn and "on" or "off"))
	end
end

if(SERVER)then
	function SWEP:SetFakeGun(ent)
		self:SetNWEntity("fakeGun", ent)
		self.fakeGun = ent
	end

	function SWEP:RemoveFake()
		if(not IsValid(self.fakeGun))then 
			return 
		end

		self.fakeGun:Remove()
		self:SetFakeGun()
	end

	SWEP.RHandPos = Vector(0, 0, 0)

	function SWEP:CreateFake(ragdoll)
		if(IsValid(self:GetNWEntity("fakeGun")))then 
			return
		end

		local ent = ents.Create("prop_physics")
		local lh = ragdoll:GetPhysicsObjectNum(5)
		local rh = ragdoll:GetPhysicsObjectNum(7)

		rh:SetPos(rh:GetPos() + self:GetOwner():EyeAngles():Forward() * 20)
		rh:SetAngles(self:GetOwner():EyeAngles() + Angle(0, 0, -90))
		lh:SetPos(rh:GetPos())

		ent:SetModel(self.WorldModel)
		ent:SetPos(rh:GetPos())
		ent:SetAngles(rh:GetAngles() + Angle(0, 0, 180))
		ent:Spawn()

		ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		ent:SetOwner(ragdoll)
		ent:GetPhysicsObject():SetMass(0)
		ent:SetNoDraw(true)
		ent.dontPickup = true
		ent.fakeOwner = self

		ragdoll:DeleteOnRemove(ent)
		ragdoll.fakeGun = ent

		if(IsValid(ragdoll.ConsRH))then 
			ragdoll.ConsRH:Remove()
		end

		self:SetFakeGun(ent)
		ent:CallOnRemove("homigrad-swep", self.RemoveFake, self)

		local vec = Vector(0, 0, 0)
		vec:Set(-self.RHandPos or vector_origin)
		vec:Rotate(ent:GetAngles())

		rh:SetPos(ent:GetPos() + vec)
	end

	function SWEP:RagdollFunc(pos, angles, ragdoll)
		shadowControl = shadowControl or hg.ShadowControl
		local fakeGun = ragdoll.fakeGun

		//pos:Add(angles:Right() * 5)
		shadowControl(ragdoll, 5, 0.001, angles, 500, 30, pos, 500, 50)
	end
end
