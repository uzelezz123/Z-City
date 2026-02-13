if engine.ActiveGamemode() == "ixhl2rp" then return end
AddCSLuaFile("shared.lua")
include("shared.lua")
AddCSLuaFile("sh_anim.lua")
AddCSLuaFile("sh_fake.lua")
AddCSLuaFile("sh_bullet.lua")
AddCSLuaFile("sh_replicate.lua")
AddCSLuaFile("sh_holster_deploy.lua")
AddCSLuaFile("sh_reload.lua")
AddCSLuaFile("sh_spray.lua")
AddCSLuaFile("sh_worldmodel.lua")
AddCSLuaFile("sh_attachment.lua")
AddCSLuaFile("cl_camera.lua")
AddCSLuaFile("cl_optics.lua")
AddCSLuaFile("sh_weaponsinv.lua")
AddCSLuaFile("sh_ammo.lua")
AddCSLuaFile("cl_shells.lua")
AddCSLuaFile("sh_options.lua")

include("sh_fake.lua")
include("sh_anim.lua")
include("sh_bullet.lua")
include("sh_replicate.lua")
include("sh_holster_deploy.lua")
include("sh_reload.lua")
include("sh_spray.lua")
include("sh_worldmodel.lua")
include("sh_attachment.lua")
include("sh_weaponsinv.lua")
include("sh_ammo.lua")
include("sh_options.lua")
if SERVER then
	include("sv_holster_deploy.lua")
	include("sv_attachment.lua")
	include("sv_reload.lua")
	include("sv_worldmodel.lua")
	include("sv_fake.lua")
	include("sv_drop.lua")
else
	include("cl_camera.lua")
	include("cl_optics.lua")
end

-- NPC SHIT
function SWEP:GetNPCBulletSpread()
	return 10
end

function SWEP:GetNPCBurstSettings()
	return (self.Primary.Automatic and 3) or 1, (self.Primary.Automatic and (1 - self.Primary.Wait ) * 20) or 2,self.Primary.Wait
end

function SWEP:GetNPCRestTimes()
	return self.Primary.Wait*2, self.Primary.Wait*2
end

function SWEP:GetCapabilities()
	return bit.bor( CAP_WEAPON_RANGE_ATTACK1, CAP_MOVE_SHOOT )
end

function SWEP:CanBePickedUpByNPCs()
	return true
end
--lua_run local npc = ents.Create("npc_metropolice") npc:Give("weapon_mp7") npc:Spawn() npc:Activate()