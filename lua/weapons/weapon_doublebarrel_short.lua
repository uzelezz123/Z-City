SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Sawed-off IZh-43" -- сам ты дабл баррел
SWEP.Author = "Izhevsk Mechanical Plant"
SWEP.Instructions = "Illegally sawed-off version of IZH-43. Chambered in 12/70"
SWEP.Category = "Weapons - Shotguns"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_shot_m3super90.mdl"

SWEP.WepSelectIcon2 = Material("entities/tfa_ins2_doublebarrel_sawnoff.png")
SWEP.WepSelectIcon2box = true
SWEP.IconOverride = "entities/tfa_ins2_doublebarrel_sawnoff.png"

SWEP.addSprayMul = 2
SWEP.ShellEject = false
SWEP.ScrappersSlot = "Primary"
SWEP.CustomShell = "12x70"
SWEP.weight = 3
SWEP.addweight = 4
SWEP.weaponInvCategory = 1
SWEP.Primary.ClipSize = 2
SWEP.Primary.DefaultClip = 2
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "12/70 gauge"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 16
SWEP.Primary.Spread = Vector(0.02, 0.02, 0.02)
SWEP.Primary.Force = 12
SWEP.Primary.Sound = {"weapons/tfa_ins2/doublebarrel_sawnoff/doublebarrelsawn_fire.wav", 80, 100, 75}
SWEP.Primary.Wait = 0
SWEP.OpenBolt = true
SWEP.WorldModelFake = "models/weapons/arccw/c_ur_dbs.mdl"

SWEP.FakePos = Vector(-6, 1.75, 5)
SWEP.FakeAng = Angle(0, 0, 2.5)
SWEP.AttachmentPos = Vector(0,-0.2,0)
SWEP.AttachmentAng = Angle(0,0,0)
SWEP.FakeAttachment = "1"

SWEP.GunCamPos = Vector(4,-15,-6)
SWEP.GunCamAng = Angle(190,-5,-100)

SWEP.CanEpicRun = true
SWEP.EpicRunPos = Vector(2,10,2)

SWEP.FakeEjectBrassATT = "2"

local path = ")weapons/arccw_ur/dbs/"
local common = ")/arccw_uc/common/"
SWEP.FakeViewBobBone = "CAM_Homefield"
SWEP.FakeReloadSounds = {
	[0.27] = path.."open.ogg",
	[0.4] = path.."eject.ogg",
	[0.60] = path.."struggle.ogg",
	[0.7] = common.."dbs-shell-insert-01.ogg",
	[0.95] =  path.."close.ogg",
}

SWEP.FakeEmptyReloadSounds = {
	[0.27] = path.."open.ogg",
	[0.4] = path.."eject.ogg",
	[0.65] = path.."struggle.ogg",
	[0.75] = common.."dbs-shell-insert-01.ogg",
	[0.76] = common.."dbs-shell-insert-02.ogg",
	[0.94] =  path.."close.ogg",
}

--[[

	["reload"] = {
        Source = "reload",
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        ShellEjectAt = 0.91,
        SoundTable = {
            {s = common .. "cloth_4.ogg", t = 0},
            {s = path .. "open.ogg", t = 0.2},
            {s = path .. "eject.ogg", t = 0.8},
            {s = common .. "magpouch_pull_small.ogg", t = 1.0},
            {s = shellfall, t = 1.0},
            {s = common .. "cloth_2.ogg", t = 1.1},
            {s = path .. "struggle.ogg", t = 1.5, v = 0.5},
            {s = shellin, t = 1.8},
            {s = path .. "grab.ogg", t = 2.15, v = 0.5},
            {s = path .. "close.ogg", t = 2.3},
            {s = common .. "shoulder.ogg", t = 2.4},
            {s = path .. "shoulder.ogg", t = 2.675},
        },
        LHIK = true,
        LHIKIn = 0.5,
        LHIKOut = 0.5,
        MinProgress = 2.05,
    },
    ["reload_empty"] = {
        Source = "reload_empty",
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        ShellEjectAt = 1.0,
        SoundTable = {
            {s = common .. "cloth_4.ogg", t = 0},
            {s = path .. "open.ogg", t = 0.3},
            {s = path .. "eject.ogg", t = 0.8},
            {s = shellfall, t = 0.9},
            {s = shellfall, t = 0.95},
            {s = common .. "cloth_2.ogg", t = 1.1},
            {s = common .. "magpouch_pull_small.ogg", t = 1.2},
            {s = path .. "struggle.ogg", t = 1.7, v = 0.5},
            {s = shellin, t = 1.85},
            {s = shellin, t = 1.9},
            {s = path .. "grab.ogg", t = 2.17, v = 0.5},
            {s = path .. "close.ogg", t = 2.3},
            {s = common .. "shoulder.ogg", t = 2.44},
            {s = path .. "shoulder.ogg", t = 2.6},
        },
        LHIK = true,
        LHIKIn = 0.5,
        LHIKOut = 0.5,
        MinProgress = 2.05,
    },
--]]

SWEP.MagModel = "models/weapons/upgrades/w_magazine_m1a1_30.mdl"

SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewPunchDiv = 70

SWEP.AnimList = {
	["idle"] = "idle",
	["reload"] = "reload",
	["reload_empty"] = "reload_empty",
}
local vector_full = Vector(1,1,1)
SWEP.FakeReloadEvents = {
	[0.15] = function( self, timeMul )
		if CLIENT then
			self:GetOwner():PullLHTowards("ValveBiped.Bip01_Spine2", 1.4 * timeMul)
		end
	end

}
--SWEP.IsPistol = true
SWEP.FakeBodyGroups = "0210"

SWEP.stupidgun = true

function SWEP:ModelCreated(model)
	if CLIENT and self:GetWM() and not isbool(self:GetWM()) and isstring(self.FakeBodyGroups) then
		self:GetWM():SetBodyGroups(self.FakeBodyGroups)
	end
end

SWEP.cameraShakeMul = 0.25

SWEP.LocalMuzzlePos = Vector(18.893,0.388,1.648)
SWEP.LocalMuzzleAng = Angle(0,0,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.Chocking = false 

SWEP.punchmul = 1
SWEP.punchspeed = 0.1

SWEP.NumBullet = 8
SWEP.AnimShootMul = 2
SWEP.AnimShootHandMul = 10
SWEP.ReloadSound = "weapons/tfa_ins2/doublebarrel/shellinsert1.wav"
SWEP.DeploySnd = {"homigrad/weapons/draw_hmg.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/hmg_holster.mp3", 55, 100, 110}
SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(-26, 0.3401, 2.2773)
SWEP.RHandPos = Vector(-15, -2, 4)
SWEP.LHandPos = false
SWEP.SprayRand = {Angle(-0.5, -0.2, 0), Angle(-1, 0.2, 0)}
SWEP.Ergonomics = 0.95
SWEP.Penetration = 7
SWEP.WorldPos = Vector(4, -1, -2)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(-19, 0.2, 0)
SWEP.attAng = Angle(0, 0, 0)
SWEP.lengthSub = 20
SWEP.DistSound = "toz_shotgun/toz_dist.wav"

SWEP.IsPistol = false
SWEP.podkid = 2
SWEP.animposmul = 1
SWEP.ReloadTime = 4

SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_R_UpperArm"
SWEP.ViewPunchDiv = 30

SWEP.ReloadHold = "pistol"

function SWEP:AnimHoldPost(model)

end

function SWEP:ReloadStartPost()
	if not self or not IsValid(self:GetOwner()) then return end
	self.reloadMiddle = CurTime() + self.ReloadTime / 3
end
SWEP.Shooted = 0
function SWEP:Shoot(override)
	--self:GetWeaponEntity():ResetSequenceInfo()
	--self:GetWeaponEntity():SetSequence(1)
	if not self:CanPrimaryAttack() then return false end
	if not self:CanUse() then return false end
	if CLIENT and self:GetOwner() != LocalPlayer() and not override then return false end
	local primary = self.Primary

	if primary.Next > CurTime() then return false end
	if (primary.NextFire or 0) > CurTime() then return false end
    if not self.drawBullet or (self:Clip1() == 0 and not override) then
		self.LastPrimaryDryFire = CurTime()
		self:PrimaryShootEmpty()
		primary.Automatic = false
		return false
	end
    self.Shooted = self.Shooted + 1
	
	primary.Next = CurTime() + primary.Wait
	self:SetLastShootTime(CurTime())
	self:PrimaryShoot()
	self:PrimaryShootPost()
end

function SWEP:Step()
	self:CoreStep()
	local owner = self:GetOwner()
	if not IsValid(owner) or not IsValid(self) then return end
	if CLIENT then
		if self.reloadMiddle and self.reloadMiddle < CurTime() then
            if self.Shooted > 0 then
				local ammotype = hg.ammotypes[string.lower( string.Replace( self.Primary and self.Primary.Ammo or "nil"," ", "") )].BulletSettings
			    self:MakeShell(ammotype.Shell, owner:GetBonePosition(owner:LookupBone("ValveBiped.Bip01_L_Hand")), Angle(0,0,0), Vector(0,0,0)) 
                --self:EmitSound("weapons/tfa_ins2/doublebarrel/shelleject1.wav",70,100,1,CHAN_AUTO)
                self.Shooted = self.Shooted - 1
			else
				self.reloadMiddle = nil
			end
		end
	end
end

--local to head
SWEP.RHPos = Vector(3,-4,3.5)
SWEP.RHAng = Angle(0,0,90)
--local to rh
SWEP.LHPos = Vector(15,-1,-3.3)
SWEP.LHAng = Angle(-110,-90,-90)

local ang1 = Angle(30, -20, 0)
local ang2 = Angle(-10, 50, 0)

function SWEP:AnimationPost()
	self:BoneSet("l_finger0", vector_origin, ang1)
	self:BoneSet("l_finger02", vector_origin, ang2)
end

-- RELOAD ANIM AKM
SWEP.ReloadAnimLH = {
	Vector(0,0,0),
	Vector(-2,-5,-5),
	Vector(-2,-5,-5),
	Vector(-2,-5,-12),
	Vector(-2,-4,-8),
	Vector(-2,1,-7),
	Vector(-2,1,-7),
	Vector(-2,1,-5),
	Vector(0,0,0),
}

SWEP.ReloadAnimRH = {
	Vector(0,0,0)
}

SWEP.ReloadAnimLHAng = {
	Angle(0,0,0),
	Angle(0,0,180),
	Angle(0,0,180),
	Angle(0,0,180),
	Angle(0,0,180),
	Angle(0,0,180),
	Angle(0,0,0),
}

SWEP.ReloadAnimRHAng = {
	Angle(0,0,0),
}

SWEP.ReloadAnimWepAng = {
	Angle(0,0,0),
	Angle(2,5,0),
	Angle(2,5,0),
	Angle(5,10,0),
	Angle(5,10,0),
	--Angle(0,0,0)
}

function SWEP:GetAnimPos_Insert(time)
	return 0
end

function SWEP:GetAnimPos_Draw(time)
	return 0
end

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