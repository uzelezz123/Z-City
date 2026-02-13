SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "PB-4 Osa"
SWEP.Author = "Research Institute of Applied Chemistry"
SWEP.Instructions = "Lightweight, compact, break-action non-lethal handgun. It is designed for self-defense and close-range applications, commonly used by civilians and law enforcement. The pistol has a four-shot capacity and is compatible with various ammunition types. Chambered in 18x45mm"
SWEP.Category = "Weapons - Pistols"
SWEP.ViewModel = ""

SWEP.WorldModel = "models/weapons/w_pist_p228.mdl"
SWEP.WorldModelFake = "models/weapons/krutoiskilet/c_osa.mdl"
SWEP.FakeScale = 1.15

SWEP.FakePos = Vector(-20, 2.8, 3.7)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(0,0,-0.2)
SWEP.AttachmentAng = Angle(0,0,90)
SWEP.MagIndex = nil
SWEP.NoIdleLoop = true

SWEP.AnimList = {
	["idle"] = "shoot1",
	["reload"] = "reload",
	["reload_empty"] = "reload",
}

SWEP.WepSelectIcon2 = Material("entities/zcity/osa.png")
SWEP.IconOverride = "entities/zcity/osa.png"

SWEP.CustomShell = ""

SWEP.weight = 0.8
SWEP.punchmul = 0.1
SWEP.punchspeed = 3
SWEP.ScrappersSlot = "Secondary"

SWEP.LocalMuzzlePos = Vector(4.367,0,2.058)
SWEP.LocalMuzzleAng = Angle(0.398,0,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.weaponInvCategory = 2
SWEP.ShellEject = false
SWEP.Primary.ClipSize = 4
SWEP.Primary.DefaultClip = 4
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "18x45mm Traumatic"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 8
SWEP.Primary.Sound = {"tasty/asval-fire.wav", 75, 90, 100}
SWEP.SupressedSound = {"zcitysnd/sound/weapons/makarov/makarov_suppressed_fp.wav", 65, 90, 100}
SWEP.Primary.SoundEmpty = {"zcitysnd/sound/weapons/makarov/handling/makarov_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Force = 2
SWEP.ReloadTime = 7 -- тут стоял 1 для теста
SWEP.OpenBolt = true
local path = ")weapons/arccw_ur/dbs/"
local common = ")/arccw_uc/common/"
SWEP.FakeReloadSounds = { -- салат почени..
	[0.1] = path.."open.ogg",
	--[0.2] = path.."eject.ogg",
	[0.7] = common.."dbs-shell-insert-01.ogg",
	[1] = common.."dbs-shell-insert-01.ogg",
	[1.5] = common.."dbs-shell-insert-01.ogg",
	[1.8] = common.."dbs-shell-insert-01.ogg",
	[2.1] =  path.."close.ogg",
}

SWEP.FakeEmptyReloadSounds = {
	[0.1] = path.."open.ogg",
	--[0.2] = path.."eject.ogg",
	[0.7] = common.."dbs-shell-insert-01.ogg",
	[1] = common.."dbs-shell-insert-01.ogg",
	[1.5] = common.."dbs-shell-insert-01.ogg",
	[1.8] = common.."dbs-shell-insert-01.ogg",
	[2.1] =  path.."close.ogg",
}

SWEP.FakeVPShouldUseHand = true
SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_R_Forearm"
SWEP.ViewPunchDiv = 100
SWEP.FakeMagDropBone = "magazine"
SWEP.MagModel = "models/weapons/upgrades/w_magazine_makarov_8.mdl"
SWEP.PPSMuzzleEffect = "pcf_jack_mf_suppressed" -- shared in sh_effects.lua

SWEP.Primary.Wait = PISTOLS_WAIT
SWEP.DeploySnd = {"homigrad/weapons/draw_pistol.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/holster_pistol.mp3", 55, 100, 110}
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false
SWEP.HoldType = "revolver"
SWEP.ZoomPos = Vector(-3, 0.1, 2.8)
SWEP.RHandPos = Vector(-5, -1.5, 2)
SWEP.LHandPos = false
SWEP.SprayRand = {Angle(-0, -0.01, 0), Angle(-0.01, 0.01, 0)}
SWEP.Ergonomics = 1
SWEP.AnimShootMul = 2
SWEP.AnimShootHandMul = 0.1
SWEP.addSprayMul = 0.5
SWEP.Penetration = 4

SWEP.ShockMultiplier = 2
SWEP.WorldPos = Vector(4.5, -1.5, -1.9)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(2, -3, 23)
SWEP.attAng = Angle(0.4, 0, 90)
SWEP.lengthSub = 25
SWEP.DistSound = "zcitysnd/sound/weapons/makarov/makarov_dist.wav"
SWEP.holsteredBone = "ValveBiped.Bip01_R_Thigh"
SWEP.holsteredPos = Vector(0, -3, 2)
SWEP.holsteredAng = Angle(0, 20, 30)
SWEP.shouldntDrawHolstered = true

--local to head
SWEP.RHPos = Vector(12,-4.5,3.5)
SWEP.RHAng = Angle(5,-5,90)
--local to rh
SWEP.LHPos = Vector(-1.2,-1.4,-2.8)
SWEP.LHAng = Angle(5,9,-100)

SWEP.podkid = 0.1

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
	hook.Add("PostEntityFireBullets","osapbflash",function(self, bullet)
		if bullet.AmmoType ~= "18x45mm Flash Defense" then return end
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