if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_base"
SWEP.PrintName = "Curare vial"
SWEP.Instructions = "Curare only becomes active when it contaminates a wound or is introduced directly to the bloodstream; it is not active when ingested orally. This poison causes weakness of the skeletal muscles and, when administered in a sufficient dose, eventual death by asphyxiation due to paralysis of the diaphragm."
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
SWEP.HoldType = "normal"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/props_junk/PopCan01a.mdl"
if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_poisongoo")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_poisongoo"
	SWEP.BounceWeaponIcon = false
end

SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Slot = 3
SWEP.SlotPos = 4
SWEP.WorkWithFake = false
SWEP.offsetVec = Vector(5, -1.5, -0.6)
SWEP.offsetAng = Angle(0, 0, -10)
SWEP.ModelScale = 0.3

if SERVER then
    function SWEP:OnRemove() end
end

local mat = "models/mat_jack_hmcd_armor"
function SWEP:DrawWorldModel()
	self.model = IsValid(self.model) and self.model or ClientsideModel(self.WorldModel)
	local WorldModel = self.model
	local owner = self:GetOwner()
	WorldModel:SetNoDraw(true)
	WorldModel:SetModelScale(self.ModelScale or 1)
	if IsValid(owner) then
		local offsetVec = self.offsetVec
		local offsetAng = self.offsetAng
		local boneid = owner:LookupBone(((owner.organism and owner.organism.rarmamputated) or (owner.zmanipstart ~= nil and owner.zmanipseq == "interact" and not owner.organism.larmamputated)) and "ValveBiped.Bip01_L_Hand" or "ValveBiped.Bip01_R_Hand")
		if not boneid then return end
		local matrix = owner:GetBoneMatrix(boneid)
		if not matrix then return end
		local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())
		WorldModel:SetMaterial(mat)
		WorldModel:SetPos(newPos)
		WorldModel:SetAngles(newAng)
		WorldModel:SetupBones()
	else
		WorldModel:SetPos(self:GetPos())
		WorldModel:SetAngles(self:GetAngles())
	end

	WorldModel:DrawModel()
end

function SWEP:SetHold(value)
	self:SetWeaponHoldType(value)
	self:SetHoldType(value)
	self.holdtype = value
end

function SWEP:Think()
	self:SetHold(self.HoldType)
end

SWEP.traceLen = 5

function SWEP:GetEyeTrace()
	return hg.eyeTrace( self:GetOwner())
end

local OpenMenu

local whitelist = {
	["weapon_bandage_sh"] = true,
	["weapon_buck200knife"] = true,
	["weapon_hammer"] = true,
	["weapon_hatchet"] = true,
	["weapon_hg_axe"] = true,
	["weapon_hg_bottlebroken"] = true,
	["weapon_hg_crowbar"] = true,
	["weapon_hg_shuriken"] = true,
	["weapon_hg_spear"] = true,
	["weapon_hg_spear_knife"] = true,
	["weapon_hg_spear_pro"] = true,
	["weapon_mannitol"] = true,
	["weapon_medkit_sh"] = true,
	["weapon_melee"] = true,
	["weapon_morphine"] = true,
	["weapon_needle"] = true,
	["weapon_pocketknife"] = true,
	["weapon_sogknife"] = true,
	["weapon_tomahawk"] = true,
	["weapon_adrenaline"] = true,
	["weapon_bloodbag"] = true,
	["weapon_naloxone"] = true,
	--["weapon_tourniquet"] = true,--it doesnt actually touch the wound
	["weapon_bigbandage_sh"] = true,
	["weapon_fentanyl"] = true,
	["weapon_hg_glassshard"] = true,
	["weapon_hg_glassshard_taped"] = true,
	["weapon_hg_machete"] = true,
	["weapon_hg_shovel"] = true,
}

if CLIENT then
	local col1 = Color(0, 0, 0, 150)
	local col2 = Color(0, 0, 0, 200)

	local gradient_u = Material("vgui/gradient-u")
	local function PaintButton(self,w,h)
		BlurBackground(self)
		surface.SetDrawColor(110, 0, 0, 155)
		surface.SetMaterial(gradient_u)
		surface.DrawTexturedRect( 0, 0, w, h )

		surface.SetDrawColor( 70, 0, 0, 128)
		surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
	end

	local gradient_d = Material("vgui/gradient-d")
	local function PaintFrame(self,w,h)
		BlurBackground(self)
		surface.SetDrawColor(50, 0, 0, 155)
		surface.SetMaterial(gradient_d)
		surface.DrawTexturedRect( 0, 0, w, h )

		surface.SetDrawColor( 150, 0, 0, 128)
		surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
	end
	OpenMenu = function()
		local frame = vgui.Create("ZFrame")
        frame:SetSize(400, 300)
        frame:Center()
        frame:SetDraggable(false)
        frame:MakePopup()
        frame:SetBackgroundBlur(true)
        frame:SetSizable(false)

		function frame:Paint( w,h )
			PaintFrame(self,w,h)
		end
        frame:SetDeleteOnClose(true)

        --frame.Paint = function(self, w, h)
        --    draw.RoundedBox(10, 0, 0, w, h, col1) 
        --    surface.SetDrawColor(255, 0, 0, 255) 
        --    surface.DrawOutlinedRect(0, 0, w, h)
        --end

		local dscroll = vgui.Create("DScrollPanel", frame)
		dscroll:Dock(FILL)

		local weps = lply:GetWeapons()

		for i, wep in ipairs(ents.FindInSphere(lply:GetPos(), 64)) do
			if !wep:IsWeapon() or IsValid(wep:GetOwner()) then continue end

			table.insert(weps, wep)
		end
		
		for i, wep in ipairs(weps) do
			if not whitelist[wep:GetClass()] then continue end
			
			local but = vgui.Create("DButton", dscroll)
			but:SetText("Poison " .. wep.PrintName)
			but:SetFont("HomigradFontSmall")
			but:SetPos(50, 150)
			but:SetSize(300, 50)
			but:Dock(TOP)

			but.Paint = function(self, w, h)
				PaintButton(self,w,h)
				--[[draw.RoundedBox(10, 0, 0, w, h, col2) 
				surface.SetDrawColor(255, 0, 0, 255) 
				surface.DrawOutlinedRect(0, 0, w, h)]]
			end

			but.DoClick = function()
				net.Start("choose_poison")
				net.WriteEntity(wep)
				net.SendToServer()

				frame:Close()
				lply:ChatPrint((wep.PrintName or "Weapon").." was poisoned!")
			end
		end
	end

	function SWEP:DrawHUD()
		if GetViewEntity() ~= lply then return end
		if lply:InVehicle() then return end
        local tr = self:GetEyeTrace()
        local toScreen = tr.HitPos:ToScreen()

        surface.SetDrawColor(255,255,255,155)
        surface.DrawRect(toScreen.x-2.5, toScreen.y-2.5, 5, 5)
	end
end

if SERVER then
	util.AddNetworkString("choose_poison")

	net.Receive("choose_poison", function(len, ply)
		local wep = net.ReadEntity()
		if not IsValid(ply) or not ply:Alive() or ply.organism.otrub then return end

		local weps = ply:GetWeapons()
		for i, wep in ipairs(ents.FindInSphere(ply:GetPos(), 64)) do
			if !wep:IsWeapon() or IsValid(wep:GetOwner()) then continue end
			
			table.insert(weps, wep)
		end

		local plywep = ply:GetActiveWeapon()
		if table.HasValue(weps, wep) and IsValid(plywep) and plywep ~= NULL and plywep ~= nil and plywep:GetClass() == "weapon_traitor_poison4" and plywep:GetOwner() == ply and whitelist[wep:GetClass()] then
			plywep:DoPoison(wep)
			plywep:Remove()
			ply:SelectWeapon(wep)
		else -- prank
			if (not org.poison4notificate) and ((org.poison4 + 20) < CurTime()) then
				org.poison4notificate = true
				org.owner:Notify("I'm doing.. Something.. Wrong...", true, "poison4", 3)
				org.owner:EmitSound( ( ThatPlyIsFemale(org.owner) and "vo/npc/female01/moan0"..math.random(5)..".wav" ) or "vo/npc/male01/moan0"..math.random(5)..".wav")
				org.o2.regen = 0
				--hg.organism.AmputateLimb(org, "larm") -- жестокие видеоигры
				--hg.organism.AmputateLimb(org, "rarm")
			end
		end
	end)
end

function SWEP:DoPoison(ent)
    local owner = self:GetOwner()

    owner:EmitSound("snd_jack_hmcd_needleprick.wav",30)
	
	ent.poisoned2 = true

    self:Remove()
	owner:SelectWeapon("weapon_hands_sh")
end

if SERVER then
    hook.Add("Org Clear", "RemovePoison2", function(org)
        org.poison4 = nil
		org.poison4notificate = nil
    end)

	hook.Add("Org Think", "poison2",function(owner, org, timeValue)
		if not IsValid(owner) or not owner:IsPlayer() or not owner:Alive() then return end
		if (not org.poison4) or (not org.alive) then return end
		
		if (not org.poison4notificate) and ((org.poison4 + 20) < CurTime()) then
			org.poison4notificate = true
			org.owner:Notify("Breathing is... oddly harder...", true, "poison4", 3)
			org.owner:EmitSound( ( ThatPlyIsFemale(org.owner) and "vo/npc/female01/moan0"..math.random(5)..".wav" ) or "vo/npc/male01/moan0"..math.random(5)..".wav")
		end

		if (org.poison4 + 30) < CurTime() then
        	org.o2.regen = 0
		end
	end)
end

function SWEP:SecondaryAttack()
end

function SWEP:Initialize()
	self:SetHold(self.HoldType)
	self:SetModelScale(self.ModelScale)
	self:Activate()
	if IsValid(self:GetPhysicsObject()) then
		self:GetPhysicsObject():SetMass(5)
	end
end

function SWEP:PrimaryAttack()
	if CLIENT then
		if not IsFirstTimePredicted() then return end
		OpenMenu()
	end
end

function SWEP:Reload()
end
