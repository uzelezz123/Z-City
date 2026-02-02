SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Zoraki Stalker M906"
SWEP.Author = "Zoraki"
SWEP.Instructions = "Generic subcompact non-lethal gas pistol. Chambered in 9mm P.A.K"
SWEP.Category = "Weapons - Pistols"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/zcity/weapons/zoraki/zoraki.mdl"

SWEP.WepSelectIcon2 = Material("entities/zcity/zoraki.png")
SWEP.IconOverride = "entities/zcity/zoraki.png"

SWEP.CustomShell = "9x18"
--SWEP.EjectPos = Vector(0,-20,5)
--SWEP.EjectAng = Angle(0,90,0)

SWEP.weight = 0.8
SWEP.punchmul = 1.5
SWEP.punchspeed = 3
SWEP.ScrappersSlot = "Secondary"

SWEP.LocalMuzzlePos = Vector(0,2.7,4)
SWEP.LocalMuzzleAng = Angle(1.45,89.9,0)
SWEP.WeaponEyeAngles = Angle(0,-90,0)
SWEP.DontUsePhysBullets = true
SWEP.weaponInvCategory = 4
SWEP.ShellEject = "EjectBrass_9mm"
SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = 6
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "9mm PAK Blank"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 8
SWEP.Primary.Sound = {"zcitysnd/sound/weapons/firearms/hndg_beretta92fs/beretta92_fire1.wav", 75, 90, 100}
SWEP.SupressedSound = {"zcitysnd/sound/weapons/makarov/makarov_suppressed_fp.wav", 55, 90, 100}
SWEP.Primary.SoundEmpty = {"zcitysnd/sound/weapons/makarov/handling/makarov_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Force = 5
SWEP.ReloadTime = 5
SWEP.ReloadSoundes = {
	"none",
	"none",
	"pwb/weapons/fnp45/clipout.wav",
	"none",
	"none",
	"pwb/weapons/fnp45/clipin.wav",
	"pwb/weapons/fnp45/sliderelease.wav",
	"none",
	"none",
	"none"
}

SWEP.PPSMuzzleEffect = "pcf_jack_mf_tpistol" -- shared in sh_effects.lua

SWEP.Primary.Wait = PISTOLS_WAIT
SWEP.DeploySnd = {"homigrad/weapons/draw_pistol.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/holster_pistol.mp3", 55, 100, 110}
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false
SWEP.HoldType = "revolver"
SWEP.ZoomPos = Vector(-3, 0, 4.6636)
SWEP.RHandPos = Vector(-5, -1.5, 2)
SWEP.LHandPos = false
SWEP.SprayRand = {Angle(-0, -0.01, 0), Angle(-0.01, 0.01, 0)}
SWEP.Ergonomics = 1
SWEP.AnimShootMul = 2
SWEP.AnimShootHandMul = 0.1
SWEP.addSprayMul = 0.5
SWEP.Penetration = 4
SWEP.ShockMultiplier = 2
SWEP.WorldPos = Vector(4.5, -1.4, 0.45)
SWEP.WorldAng = Angle(0, 90, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(-6, -4, 0.1)
SWEP.attAng = Angle(0, 0, 0)
SWEP.lengthSub = 25
SWEP.DistSound = "zcitysnd/sound/weapons/makarov/makarov_dist.wav"
SWEP.holsteredBone = "ValveBiped.Bip01_R_Thigh"
SWEP.holsteredPos = Vector(5, 0, -3)
SWEP.holsteredAng = Angle(180, 20, 150)
SWEP.shouldntDrawHolstered = true
SWEP.podkid = 0.1

--local to head
SWEP.RHPos = Vector(12,-4.5,3.5)
SWEP.RHAng = Angle(5,-5,90)
--local to rh
SWEP.LHPos = Vector(-1.2,-1.4,-2.5)
SWEP.LHAng = Angle(5,9,-110)

--RELOAD ANIMS PISTOL
SWEP.ReloadAnimLH = {
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(-3,-1,-5),
	Vector(-12,1,-22),
	Vector(-12,1,-22),
	Vector(-12,1,-22),
	Vector(-12,1,-22),
	Vector(-2,-1,-3),
	"fastreload",
	Vector(0,0,0),
	"reloadend",
	"reloadend",
}
SWEP.ReloadAnimLHAng = {
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(30,-10,0),
	Angle(60,-20,0),
	Angle(70,-40,0),
	Angle(90,-30,0),
	Angle(40,-20,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
}

SWEP.ReloadAnimRH = {
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(-2,0,0),
	Vector(-1,0,0),
	Vector(0,0,0)
}
SWEP.ReloadAnimRHAng = {
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(15,2,20),
	Angle(15,2,20),
	Angle(0,0,0)
}
SWEP.ReloadAnimWepAng = {
	Angle(0,0,0),
	Angle(5,15,15),
	Angle(-5,21,14),
	Angle(-5,21,14),
	Angle(5,20,13),
	Angle(5,22,13),
	Angle(1,22,13),
	Angle(1,21,13),
	Angle(2,22,12),
	Angle(-5,21,16),
	Angle(-5,22,14),
	Angle(-4,23,13),
	Angle(7,22,8),
	Angle(7,12,3),
	Angle(2,6,1),
	Angle(0,0,0)
}

-- Inspect Assault

SWEP.InspectAnimWepAng = {
	Angle(0,0,0),
	Angle(4,4,15),
	Angle(10,15,25),
	Angle(10,15,25),
	Angle(10,15,25),
	Angle(-6,-15,-15),
	Angle(1,15,-45),
	Angle(15,25,-55),
	Angle(15,25,-55),
	Angle(15,25,-55),
	Angle(0,0,0),
	Angle(0,0,0)
}

if CLIENT then
	hook.Add("PostEntityFireBullets","zoraki906",function(self,bullet)
		if bullet.AmmoType ~= "9mm PAK Flash Defense" then return end
		if not lply:Alive() then return end
		if lply.organism and lply.organism.otrub then return end

		local tr = bullet.Trace

		local view = render.GetViewSetup(true)

		local dot = view.angles:Forward():Dot(tr.Normal)
		
		local pos = tr.StartPos:ToScreen()
		
		if dot < -0.5 and pos.x > 0 and pos.x < ScrW() and pos.y > 0 and pos.y < ScrH() and hg.isVisible(lply:EyePos(), tr.StartPos, {lply, self}, MASK_VISIBLE) then
			hg.AddFlash(view.origin, dot, tr.StartPos, 30, 3000)
		end
	end)
end