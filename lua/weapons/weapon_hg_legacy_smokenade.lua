if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_hg_legacy_grenade"
SWEP.PrintName = "Smoke bomb"
SWEP.Instructions = "A handmade smoke bomb is an camouflage tool, equipped with a fuse."
SWEP.Category = "Weapons - Explosive"
SWEP.Spawnable = false
SWEP.HoldType = "grenade"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/props_junk/jlare.mdl"
if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_smokebomb")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_smokebomb.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 5
SWEP.SlotPos = 1
SWEP.ENT = "ent_hg_smokenade"

SWEP.nofunnyfunctions = true
SWEP.timetothrow = 0.5

SWEP.lefthandmodel = "models/weapons/gleb/w_firematch.mdl"
SWEP.offsetVec2 = Vector(4,-1.2,1)
SWEP.offsetAng2 = Angle(10,0,90)
SWEP.ModelScale2 = 1.5
SWEP.throwsound = "snd_jack_hmcd_lighter.wav"

SWEP.offsetVec = Vector(3, -2, -1)
SWEP.offsetAng = Angle(145, 0, 0)
SWEP.NoTrap = true

function SWEP:Animation()
	local owner = self:GetOwner()
	self:SetHold((owner.zmanipstart ~= nil and owner.zmanipseq == "interact" and not owner.organism.larmamputated) and "normal" or self.HoldType)

	if not (CLIENT and LocalPlayer() == self:GetOwner() and LocalPlayer() == GetViewEntity()) then return end
	if (self:GetOwner().zmanipstart ~= nil and not self:GetOwner().organism.larmamputated) then return end

	self:BoneSet("r_upperarm", vector_origin, Angle(-90,0,-60))

	if self.startedattack then
		local animpos = math.max((self.startedattack + 0.5) - CurTime(),0) * 2
		
		self:BoneSet("l_upperarm", vector_origin, Angle(-90 * animpos,-60 * animpos,0))
		self:BoneSet("r_upperarm", vector_origin, Angle(-20 * animpos,-40 * animpos,0))
	end

	if self.starthold then
		local animpos = math.max((self.starthold + 0.5) - CurTime(),0) * 2

		--self:BoneSet("r_finger0", vector_origin, Angle(70 * animpos,-10 * animpos,0))
		--self:BoneSet("r_hand", vector_origin, Angle(20 * animpos,0,0))
	end
end