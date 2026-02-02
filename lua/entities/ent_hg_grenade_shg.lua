if SERVER then AddCSLuaFile() end
ENT.Base = "ent_hg_grenade"
ENT.Spawnable = false
ENT.Model = "models/jmod/explosives/grenades/sticknade/stick_grenade_nojacket.mdl"
ENT.timeToBoom = math.random(4, 6)
ENT.Fragmentation = 480 * 2 -- это противотанковая епта граната
ENT.BlastDis = 8 --meters
ENT.Penetration = 10