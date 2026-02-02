ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "ent_hg_smokenade"
ENT.Spawnable = false
ENT.Model = "models/props_junk/jlare.mdl"

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Grenade"
ENT.Spawnable = false
ENT.Model = "models/pwb/weapons/w_f1_thrown.mdl"
ENT.timeToBoom = 3
ENT.Fragmentation = 300 * 3 --300 не страшно
ENT.BlastDis = 8 --meters
ENT.Penetration = 8
ENT.ishggrenade = true
ENT.spoon = "models/weapons/arc9/darsu_eft/skobas/rgd5_skoba.mdl"
ENT.Sound = {"m67/m67_detonate_01.wav", "m67/m67_detonate_02.wav", "m67/m67_detonate_03.wav"}
ENT.SoundFar = {"m67/m67_detonate_far_dist_01.wav", "m67/m67_detonate_far_dist_02.wav", "m67/m67_detonate_far_dist_03.wav"}
ENT.SoundWater = "m67/water/m67_water_detonate_01.wav"
ENT.SoundBass = {
    "snd_jack_fragsplodeclose.wav", --;; Мне насрать если чет не нравится можете изменить!!!
    "m67/m67_detonate_02.wav",
    "snd_jack_bigsplodeclose.wav"
}
ENT.DebrisSounds = {
    "explosion_debris/interior/explosion_debris_sprinkle_interior_wave01.wav",
    "explosion_debris/interior/explosion_debris_sprinkle_interior_wave010.wav",
    "explosion_debris/interior/explosion_debris_sprinkle_interior_wave02.wav",
    "explosion_debris/interior/explosion_debris_sprinkle_interior_wave03.wav",
    "explosion_debris/interior/explosion_debris_sprinkle_interior_wave04.wav",
    "explosion_debris/interior/explosion_debris_sprinkle_interior_wave05.wav",
    "explosion_debris/interior/explosion_debris_sprinkle_interior_wave06.wav",
    "explosion_debris/interior/explosion_debris_sprinkle_interior_wave07.wav",
    "explosion_debris/interior/explosion_debris_sprinkle_interior_wave09.wav"
}