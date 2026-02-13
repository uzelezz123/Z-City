if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_bandage_sh"
SWEP.PrintName = "Tourniquet"
SWEP.Instructions = "An esmarch tourniquet designed to stop large (arterial) bleedings. Can also be used to stop light bleedings, although it makes the limb ineffective."
SWEP.Category = "ZCity Medicine"
SWEP.Spawnable = true
SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0
SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/tourniquet/tourniquet.mdl"
if CLIENT then
	SWEP.WepSelectIcon = Material("scrappers/jgut.png")
	SWEP.IconOverride = "scrappers/jgut.png"
	SWEP.BounceWeaponIcon = false

	SWEP.WepSelectIcon2 = Material("scrappers/jgut.png")

	function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
--
--
		surface.SetDrawColor( 255, 255, 255, alpha )
		surface.SetMaterial( self.WepSelectIcon2 )
	
		surface.DrawTexturedRect( x, y + 10,  wide, wide/2 )
	
		self:PrintWeaponInfo( x + wide + 20, y + tall * 0.95, alpha )
	
	end
end

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.WorkWithFake = true
SWEP.offsetVec = Vector(4, -1.5, 0)
SWEP.offsetAng = Angle(-30, 20, -90)
SWEP.ModelScale = 1
SWEP.modeNames = {
	[1] = "tourniquet"
}

function SWEP:InitializeAdd()
	self:SetHold(self.HoldType)

	local owner = self:GetOwner()
	if owner:IsNPC() then
		self:SetHold("melee")
		owner:SetHealth(math.Clamp(owner:Health() + (owner:GetMaxHealth() * 0.3), 0, owner:GetMaxHealth() * 2))
		owner:EmitSound("snd_jack_hmcd_bandage.wav", 75, math.random(95, 105))
		self:Remove()
	end

	self.modeValues = {
		[1] = 1,
	}
end

SWEP.showstats = false

SWEP.modeValuesdef = {
	[1] = 1,
}

local lang1, lang2 = Angle(0, -10, 0), Angle(0, 10, 0)
function SWEP:Animation()
	if (self:GetOwner().zmanipstart ~= nil and not self:GetOwner().organism.larmamputated) then return end
	local aimvec = self:GetOwner():GetAimVector()
	local hold = self:GetHolding()
    self:BoneSet("r_upperarm", vector_origin, Angle(30 - hold / 2, -20 + hold / 2 + 20 * aimvec[3], 5 - hold / 4))
    self:BoneSet("r_forearm", vector_origin, Angle(0, -hold / 2.5, 35 -hold/1.5))

    self:BoneSet("l_upperarm", vector_origin, lang1)
    self:BoneSet("l_forearm", vector_origin, lang2)
end


function SWEP:Heal(ent, mode, bone)
	local org = ent.organism
	if not org then return end
	if self:Tourniquet(ent, bone) then self.modeValues[1] = 0 self:GetOwner():SelectWeapon("weapon_hands_sh") self:Remove() end
end