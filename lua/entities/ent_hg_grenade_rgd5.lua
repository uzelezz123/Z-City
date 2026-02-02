if SERVER then AddCSLuaFile() end
ENT.Base = "ent_hg_grenade"
ENT.Spawnable = false
ENT.Model = "models/pwb/weapons/w_rgd5_thrown.mdl"
ENT.timeToBoom = 4
ENT.Fragmentation = 320 * 3
ENT.BlastDis = 5 --meters
ENT.Penetration = 7.5

ENT.playedSound = false
function ENT:AddThink()
	if not self.timer or not self.timeToBoom or self.playedSound then return end
	--if (CurTime() - self.timer) <= 0.25 then
		//self:EmitSound("m9/m9_fp.wav", 80)
		self.playedSound = true
	--end
end