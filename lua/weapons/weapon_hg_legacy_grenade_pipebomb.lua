if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_hg_legacy_grenade"
SWEP.PrintName = "Pipe-Bomb"
SWEP.Instructions = "A pipe-bomb is an explosive device made from a piece of pipe and an explosive. It has bolts inside that give it a fragmentation effect."
SWEP.Category = "Weapons - Explosive"
SWEP.Spawnable = false
SWEP.HoldType = "grenade"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/w_models/weapons/w_jj_pipebomb.mdl"
if CLIENT then
    SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_pipebomb")
    SWEP.IconOverride = "vgui/wep_jack_hmcd_pipebomb"
    SWEP.BounceWeaponIcon = false
end

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 4
SWEP.SlotPos = 10
SWEP.ENT = "ent_hg_grenade_pipebomb"

SWEP.offsetVec = Vector(4, -2, 0)
SWEP.offsetAng = Angle(180, 0, 0)

SWEP.lefthandmodel = "models/weapons/gleb/w_firematch.mdl"
SWEP.offsetVec2 = Vector(4,-1.2,1)
SWEP.offsetAng2 = Angle(10,0,90)
SWEP.ModelScale2 = 1.5
SWEP.throwsound = "snd_jack_hmcd_lighter.wav"

SWEP.nofunnyfunctions = true
SWEP.timetothrow = 0.5

function SWEP:AddStep()
    if self.starthold then
        local ent = scripted_ents.Get(self.ENT)
        local time = (self.starthold + ent.timeToBoom) - CurTime()
        
        self.nextgrenadetick = self.nextgrenadetick or CurTime()
        if self.nextgrenadetick > CurTime() then return end
        
        if not self.SndStarted then
			self.SndStarted = true
        end

		local Spark=EffectData()
		Spark:SetOrigin(self:GetPos()+self:GetUp()*7)
		Spark:SetScale(2)
		Spark:SetNormal(self:GetUp())
		util.Effect("eff_jack_hmcd_fuzeburn",Spark,true,true)

        self.nextgrenadetick = CurTime() + 0.5 * math.max(time / (ent.timeToBoom * 0.75),0.5)
    end
end

function SWEP:ThrowAdd()
    self:StopSound("snds_jack_gmod/flareburn.wav")
end