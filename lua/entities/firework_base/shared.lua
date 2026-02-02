ENT.Type = "anim"
ENT.Author = "Sadsalat"
ENT.Category = "ZCity Other"
ENT.PrintName = "Firework Base"
ENT.IconOverride = "entities/gf2_rocket_large_01.png"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Model = "models/models/gf2/rogue_cheney/rockets/big/rocket_01.mdl"
ENT.Sound = "garrys_fireworks_2/fireworks/explosions/fw_large_pellet_explosion.wav"
ENT.SoundFar = "garrys_fireworks_2/fireworks/explosions/fw_large_pellet_explosion.wav"
ENT.SoundWater = ""
ENT.Speed = 3500
ENT.TruhstTime = 3
ENT.Oskole = false
ENT.Fragmentation = 0

ENT.BlastDamage = 20
ENT.BlastDis = 5

game.AddParticles("particles/pcfs_jack_muzzleflashes.pcf")
game.AddParticles("particles/pcfs_jack_explosions_small3.pcf")
game.AddParticles("particles/pcfs_jack_explosions_incendiary2.pcf")

ENT.RocketTrail =  "gf2_firework_trail_main"

function ENT:OnMatches()
	self.LoopSndID = self:StartLoopingSound("garrys_fireworks_2/fireworks/flares/flare_sound.mp3")
	timer.Simple(0.5,function()
		if IsValid(self) then
			self.Activated = true
		end
	end)
end