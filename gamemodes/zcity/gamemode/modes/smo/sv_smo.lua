MODE.name = "smo"
MODE.PrintName = "Special Military Operation"
MODE.start_time = 6
MODE.end_time = 6
 
MODE.ROUND_TIME = 9000

MODE.LootSpawn = false

MODE.OverideSpawnPos = true
MODE.PointsProgress = {}

MODE.ForBigMaps = true

MODE.Chance = 0.01

local pointsName = {
	"Alpha",
	"Bravo",
	"Charlie",
	"Delta",
	"Echo",
	"Foxtrot",
	"Golf",
	"Hotel",
	"India",
	"November",
	"Vasilek",
	"Dubok"
}

function MODE.GuiltCheck(Attacker, Victim, add, harm, amt)
	return 1, true--returning true so guilt bans
end

function MODE:CanLaunch()
	do return false end
	local points = zb.GetMapPoints( "HMCD_SWO_AZOV" )
	local points2 = zb.GetMapPoints( "HMCD_SWO_WAGNER" )
	local points3 = zb.GetMapPoints( "HMCD_SWO_CAPPOINT" )
    return (#points > 0) and (#points2 > 0) and (#points3 > 0)
end

util.AddNetworkString("swo_start")
local size = 1000
hg = hg or {}
function MODE:Intermission()
	game.CleanUpMap()

	self.WAGNERPoints = {}
	table.CopyFromTo(zb.GetMapPoints( "HMCD_SWO_WAGNER" ),self.WAGNERPoints)
	self.AZOVPoints = {}
	table.CopyFromTo(zb.GetMapPoints( "HMCD_SWO_AZOV" ),self.AZOVPoints)

	self.CapPoints = zb.GetMapPoints( "HMCD_SWO_CAPPOINT" )
	hg.smo = {}
	for i,point in pairs(self.CapPoints) do
		local max, min = Vector(point.pos.x + size,point.pos.y + size,point.pos.z + size), Vector(point.pos.x - size,point.pos.y - size,point.pos.z - size)
		local capPointPos = max - ((max - min) / 2)
		local tdml = ents.Create("swo_point")
		tdml:SetPos(capPointPos)
		tdml.min = max
		tdml.max = min
		tdml.PointName = pointsName[i]
		tdml:Spawn()
		self.PointsProgress[pointsName[i]] = {0,capPointPos}
	end
	net.Start("SWO_PointsUpdate")
		net.WriteTable(self.PointsProgress)
	net.Broadcast()

	local ctpos
	local tpos
	for i, ply in ipairs(player.GetAll()) do
		if ply:Team() == TEAM_SPECTATOR then continue end
		local pos
		if ply:Team() == 1 then
			if !ctpos then
				ctpos = #self.WAGNERPoints > 0 and self.WAGNERPoints[1].pos or zb:GetRandomSpawn()
				pos = ctpos
			else
				pos = hg.tpPlayer(ctpos, ply, i, 0)
			end
		end

		if ply:Team() == 0 then
			if !tpos then
				tpos = #self.AZOVPoints > 0 and self.AZOVPoints[1].pos or zb:GetRandomSpawn()
				pos = tpos
			else
				pos = hg.tpPlayer(tpos, ply, i, 0)
			end
		end

		ply:SetupTeam(ply:Team())
		ply.Lives = 3

		if pos then
			ply:SetPos(pos)
		end
	end

	net.Start("swo_start")
	net.Broadcast()
end

local player_GetAll = player.GetAll
local team_GetAllTeams = team.GetAllTeams

function MODE:CheckAlivePlayers()
	local tbl = {}

	for i, info in pairs(team_GetAllTeams()) do
		if i == TEAM_UNASSIGNED or i == TEAM_SPECTATOR then continue end
		tbl[i] = {}
	end

	for _, ply in ipairs(player_GetAll()) do
		if ply:Team() == TEAM_UNASSIGNED or ply:Team() == TEAM_SPECTATOR then continue end
		if not ply:Alive() and ply.Lives and ply.Lives < 1 then continue end
		if ply.organism and ply.organism.incapacitated and ply.Lives and ply.Lives < 1 then continue end

		tbl[ply:Team() or 0] = tbl[ply:Team() or 0] or {}
		tbl[ply:Team()][(#tbl[ply:Team() or 0] or 0) + 1] = ply
	end

	return tbl
end

function MODE:ShouldRoundEnd()
	local endround, winner = zb:CheckWinner(self:CheckAlivePlayers())
	local needed = #self.CapPoints * 100
	local allPoints = 0
	for k,points in pairs(self.PointsProgress) do
		allPoints = allPoints + points[1]
	end
	--print(allPoints,needed)
	if allPoints == needed or allPoints == -needed and #self.CapPoints > 0 then return true end
	return endround
end

function MODE:RoundStart()
end

local WagnerEquipment = {
	["default"] = {
		Primary = "weapon_ak74",
		Secondary = "weapon_makarov",
		Other = {"weapon_hands_sh","weapon_melee","weapon_hg_rgd_tpik","weapon_bandage_sh","weapon_medkit_sh","weapon_tourniquet"},
		Ammo = {},
		Attachments = {
			Primary = {
				Allways = true,
				Scopes = {"holo6","optic11","holo12","holo2"},
				Barell = {"supressor8"}
			}
		},
		Armor = {"vest5","helmet1","headphones1"}
	},
	["machinegunner"] = {
		Primary = "weapon_pkm",
		Secondary = "weapon_makarov",
		Other = {"weapon_hands_sh","weapon_melee","weapon_hg_rgd_tpik","weapon_bandage_sh","weapon_medkit_sh","weapon_tourniquet"},
		Ammo = {},
		Attachments = {
			Primary = {
				Allways = true,
				Scopes = {"holo6","optic11"}
			}
		}, 
		Armor = {"vest5","helmet1","headphones1"}
	},
	["sniper1"] = {
		Primary = "weapon_svd",
		Secondary = "weapon_makarov",
		Other = {"weapon_hands_sh","weapon_melee","weapon_hg_rgd_tpik","weapon_bandage_sh","weapon_medkit_sh"},
		Ammo = {},
		Attachments = {
			Primary = {
				Allways = true,
				Scopes = {"optic11","optic3"}
			}
		},
		Armor = {"vest5","helmet1","headphones1"}
	},
	["sniper2"] = {
		Primary = "weapon_asval",
		Secondary = "weapon_makarov",
		Other = {"weapon_hands_sh","weapon_melee","weapon_hg_rgd_tpik","weapon_bandage_sh","weapon_medkit_sh"},
		Ammo = {},
		Attachments = {
			Primary = {
				Allways = true,
				Scopes = {"optic3","optic4"}
			}
		},
		Armor = {"vest5","helmet1","headphones1"}
	},
}

local UkrEquipment = {
	["default"] = {
		Primary = "weapon_m4a1",
		Secondary = "weapon_glock17",
		Other = {"weapon_hands_sh","weapon_sogknife","weapon_hg_grenade_tpik","weapon_bandage_sh","weapon_medkit_sh","weapon_tourniquet"},
		Ammo = {},
		Attachments = {
			Primary = {
				Allways = true,
				Scopes = {"holo17","holo14","holo11","holo4"},
				Barell = {"supressor2"}
			}
		},
		Armor = {"vest1","helmet1","headphones1"}
	},
	["machinegunner"] = {
		Primary = "weapon_m249",
		Secondary = "weapon_glock17",
		Other = {"weapon_hands_sh","weapon_sogknife","weapon_hg_grenade_tpik","weapon_bandage_sh","weapon_medkit_sh","weapon_tourniquet"},
		Ammo = {},
		Attachments = {
			Primary = {
				Allways = true,
				Scopes = {"holo17","holo14","holo11","holo4"},
			}
		},
		Armor = {"vest1","helmet1","headphones1"}
	},
	["sniper1"] = {
		Primary = "weapon_sr25",
		Secondary = "weapon_glock17",
		Other = {"weapon_hands_sh","weapon_sogknife","weapon_medkit_sh"},
		Ammo = {},
		Attachments = {
			Primary = {
				Allways = true,
				Scopes = {"optic6","optic2"},
			}
		},
		Armor = {"vest3","helmet1","headphones1"}
	}
}

local function GiveEquip(ply,team)
	local teamequip = (team == 1 and WagnerEquipment) or UkrEquipment
	local classequip = table.Random(teamequip)

	local inv = ply:GetNetVar("Inventory")
	inv["Weapons"]["hg_sling"] = true
	ply:SetNetVar("Inventory",inv)
	
	local Primary = ply:Give(classequip.Primary)
	ply:GiveAmmo(Primary:GetMaxClip1() * 4,Primary:GetPrimaryAmmoType(),true)
	local atts = {}

	local scopeorno = ( classequip.Attachments.Primary.Allways and 1 ) or (classequip.Attachments.Primary.Scopes and math.random(0,1)) or 0
	if scopeorno > 0 then
		hg.AddAttachmentForce(ply,Primary,classequip.Attachments.Primary.Scopes[math.random(#classequip.Attachments.Primary.Scopes)])		
	end

	local barrelorno = ( classequip.Attachments.Primary.Allways and 1 ) or (classequip.Attachments.Primary.Barell and math.random(0,1)) or 0
	if barrelorno > 0 and classequip.Attachments.Primary.Barell then
		hg.AddAttachmentForce(ply,Primary,classequip.Attachments.Primary.Barell[math.random(#classequip.Attachments.Primary.Barell)])		
	end


	local Secondary = ply:Give(classequip.Secondary)
	ply:GiveAmmo(Secondary:GetMaxClip1() * 4,Secondary:GetPrimaryAmmoType(),true)
			
	hg.AddArmor(ply, classequip.Armor)

	for k,v in ipairs(classequip.Other) do
		ply:Give(v)
	end

	local walkietalkie = ply:Give("weapon_walkie_talkie")
	walkietalkie.Frequency = (team == 1 and math.Round(math.Rand(88,95),1) ) or math.Round(math.Rand(100,108),1)

	ply:Give("weapon_hands_sh")
	ply:SelectWeapon("weapon_hands_sh")
	
	timer.Simple(0.2,function()
		ply:SelectWeapon("weapon_hands_sh")
	end)
end

local function spawnswoplayer(ply)
	local WAGNERPoints = zb.GetMapPoints( "HMCD_SWO_WAGNER" )
	local AZOVPoints = zb.GetMapPoints( "HMCD_SWO_AZOV" )

	if not ply:Alive() then ply:Spawn() end

	ply:SetSuppressPickupNotices(true)
	ply.noSound = true

		if ply:Team() == 1 then
			ply:SetPlayerClass("wagner")
			zb.GiveRole(ply, "RF Armed Forces", Color(71,89,0))
		else
			ply:SetPlayerClass("ukr")
			zb.GiveRole(ply, "UA Armed Forces", Color(89,76,0))
		end

	GiveEquip( ply, ply:Team() )

	timer.Simple(0.1,function()
		ply.noSound = false
	end)

	ply:SetSuppressPickupNotices(false)
end

function MODE:GetPlySpawn(ply)
	local plyTeam = ply:Team()
	if ply:Team() == 1 then
		if self.WAGNERPoints and #self.WAGNERPoints > 0 then
			ply:SetPos(self.WAGNERPoints[#self.WAGNERPoints].pos)
			if #self.WAGNERPoints > 1 then 
				table.remove(self.WAGNERPoints)
			end
		end
	else
		if self.AZOVPoints and #self.AZOVPoints > 0 then
			ply:SetPos(self.AZOVPoints[#self.AZOVPoints].pos)
			if #self.AZOVPoints > 1 then 
				table.remove(self.AZOVPoints)
			end
		end
	end
end

function MODE:GiveEquipment()
	self.WAGNERPoints = {}
	table.CopyFromTo(zb.GetMapPoints( "HMCD_SWO_WAGNER" ),self.WAGNERPoints)
	self.AZOVPoints = {}
	table.CopyFromTo(zb.GetMapPoints( "HMCD_SWO_AZOV" ),self.AZOVPoints)
	
	timer.Simple(0.1,function()

		for _, ply in ipairs(player.GetAll()) do
			if not ply:Alive() then continue end
			ply:SetSuppressPickupNotices(true)
			ply.noSound = true

			if ply:Team() == 1 then
				ply:SetPlayerClass("wagner")
				zb.GiveRole(ply, "RF Armed Forces", Color(71,89,0))
			else
				ply:SetPlayerClass("ukr")
				zb.GiveRole(ply, "UA Armed Forces", Color(89,76,0))
			end

			GiveEquip( ply, ply:Team() )

			timer.Simple(0.1,function()
				ply.noSound = false
			end)

			ply:SetSuppressPickupNotices(false)
		end
	end)
end

hg = hg or {}
hg.smo = hg.smo or {}

local cd = 0

util.AddNetworkString("SWO_PointsUpdate")

function MODE:RoundThink()
	self.ThinkPlayersDeath = self.ThinkPlayersDeath or CurTime()
	if self.ThinkPlayersDeath < CurTime() then
		self.ThinkPlayersDeath = CurTime() + 1

		for i, ply in ipairs(player_GetAll()) do
			if !ply:Alive() and ply.timeDeath and (ply.timeDeath < CurTime()) then
				ply.timeDeath = nil
				spawnswoplayer(ply)
			end
		end
	end

	if cd < CurTime() then
		local needSend = false
		for name, Point in pairs(hg.smo) do
			--print(name)
			--PrintTable(Point)
			for i, ply in pairs(Point) do
				if not ply:Alive() then table.RemoveByValue(Point,ply) continue end
				if ply:Team() == 1 then
					self.PointsProgress[name][1] = math.min( (self.PointsProgress[name][1] or 0) + 1, 100 )
				else
					self.PointsProgress[name][1] = math.max( (self.PointsProgress[name][1] or 0) - 1, -100 )
				end
				needSend = true
			end
		end
		if needSend then
			--PrintTable(self.PointsProgress)
			net.Start("SWO_PointsUpdate")
				net.WriteTable(self.PointsProgress)
			net.Broadcast()
		end
		cd = CurTime() + 0.5 -- cat coding moment fuck you
	end
end

function MODE:GetTeamSpawn()
	return zb.TranslatePointsToVectors(zb.GetMapPoints( "HMCD_TDM_T" )), zb.TranslatePointsToVectors(zb.GetMapPoints( "HMCD_TDM_CT" ))
end

function MODE:CanSpawn()
end

util.AddNetworkString("swo_roundend")
function MODE:EndRound()
	timer.Simple(2,function()
		net.Start("swo_roundend")
		net.Broadcast()
	end)

	local endround, winner = zb:CheckWinner(self:CheckAlivePlayers())
	for k,ply in player.Iterator() do
		if ply:Team() == winner then
			ply:GiveExp(math.random(15,30))
			ply:GiveSkill(math.Rand(0.1,0.15))
			--print("give",ply)
		else
			--print("take",ply)
			ply:GiveSkill(-math.Rand(0.05,0.1))
		end
	end
end

util.AddNetworkString("swo_respawn")
function MODE:PlayerDeath(ply)
	if not IsValid(ply) then return end 
	ply.Lives = ply.Lives or 3
	if ply.Lives < 1 then ply.Lives = 0 return end

	net.Start("swo_respawn")
		net.WriteFloat(CurTime())
	net.Send(ply)

	ply.timeDeath = CurTime() + 5
	ply.Lives = ply.Lives - 1
end