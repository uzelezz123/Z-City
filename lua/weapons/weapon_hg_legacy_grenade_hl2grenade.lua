if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_hg_legacy_grenade"
SWEP.PrintName = "Combine Frag Grenade"
SWEP.Instructions = "The Grenade comes equipped with a red blinking light and a chirping timer that are played when the grenade is thrown, letting both the attacker and the victim know when an active grenade is in their vicinity. Most Combine Soldiers carry at least a few of these and use them to flush out and/or kill enemies."
SWEP.Category = "Weapons - Explosive"
SWEP.Spawnable = false
SWEP.HoldType = "grenade"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/Items/grenadeAmmo.mdl"
if CLIENT then
    SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_grenade")
    SWEP.IconOverride = "vgui/wep_jack_hmcd_grenade"
    SWEP.BounceWeaponIcon = false
end

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 4
SWEP.SlotPos = 10
SWEP.ENT = "ent_hg_grenade_hl2grenade"

SWEP.offsetVec = Vector(3.5, -2, 0)
SWEP.offsetAng = Angle(180, 0, 0)
SWEP.spoon = "models/weapons/arc9/darsu_eft/skobas/m18_skoba.mdl"

function SWEP:PickupFunc(ply)
    local wep = ply:GetWeapon(self:GetClass())
    if IsValid(wep) and wep.count < 5 then
        
        wep.count = wep.count + self.count
        self:Remove()
        
        return true
    end
    return false
end

function SWEP:AddStep()
    if not IsValid(self:GetOwner()) then return end
    if self.starthold then
        local ent = scripted_ents.Get(self.ENT)
        local time = (self.starthold + ent.timeToBoom) - CurTime()
        
        self.nextgrenadetick = self.nextgrenadetick or CurTime()
        if self.nextgrenadetick > CurTime() then return end
        
        hg.GetCurrentCharacter(self:GetOwner()):EmitSound("weapons/grenade/tick1.wav",65)

        self.nextgrenadetick = CurTime() + 0.5 * math.max(time / (ent.timeToBoom * 0.75),0.5)
    end
end