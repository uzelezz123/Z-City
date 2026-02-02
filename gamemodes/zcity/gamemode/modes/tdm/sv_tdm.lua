local MODE = MODE

MODE.name = "tdm"
MODE.BuyTime = 40
MODE.StartMoney = 6500
MODE.start_time = 20
MODE.buymenu = true

MODE.ROUND_TIME = 240

MODE.Chance = 0.04

function MODE.GuiltCheck(Attacker, Victim, add, harm, amt)
	return 1, true--returning true so guilt bans
end

function MODE:CanLaunch()
	local points = zb.GetMapPoints( "HMCD_TDM_T" )
	local points2 = zb.GetMapPoints( "HMCD_TDM_CT" )
    return (#points > 0) and (#points2 > 0)
end

MODE.ForBigMaps = true

util.AddNetworkString("tdm_start")
function MODE:Intermission()
	game.CleanUpMap()

	for i, ply in ipairs(player.GetAll()) do
		ply:SetupTeam(ply:Team())
		
		ply:SetNWInt( "TDM_Money", self.StartMoney )
	end

	net.Start("tdm_start")
	net.Broadcast()
end

function MODE:CheckAlivePlayers()
	return zb:CheckAliveTeams(true)
end

function MODE:ShouldRoundEnd()
	local endround, winner = zb:CheckWinner(self:CheckAlivePlayers())
	return endround
end

function MODE:RoundStart()
	for k,ply in player.Iterator() do
		ply:Freeze(false)
	end
end

local tblweps = {
	[0] = {
		"weapon_akm",
	},
	[1] = {
		"weapon_m4a1",
	},
}

local tblatts = {
	[0] = {
		{""},
	},
	[1] = {
		{"holo14","laser2","grip3"},
	},
}

local tblarmors = {
	[0] = {
		{"vest4","helmet1"},
	},
	[1] = {
		{"vest4","helmet1"},
	},
}

local giveweapons = CreateConVar("zb_tdm_giveweapon","1",FCVAR_LUA_SERVER,"TDMSPAWNS",0,1)

function MODE:GetPlySpawn(ply)
end

function MODE:GiveEquipment()
	timer.Simple(0.1,function()
		local mrand = math.random(#tblweps[0])

		for _, ply in ipairs(player.GetAll()) do
			if not ply:Alive() then continue end
			
			local inv = ply:GetNetVar("Inventory")
			inv["Weapons"]["hg_sling"] = true
			ply:SetNetVar("Inventory",inv)

			ply:SetSuppressPickupNotices(true)
			ply.noSound = true

			if ply:Team() == 1 then
				ply:SetPlayerClass("swat")
				zb.GiveRole(ply, "Counter Terrorist", Color(0,0,190))
				ply:SetNetVar("CurPluv", "pluvberet")
			else
				ply:SetPlayerClass("terrorist")
				zb.GiveRole(ply, "Terrorist", Color(190,0,0))
				ply:SetNetVar("CurPluv", "pluvboss")
			end

			--[[if giveweapons:GetBool() then
				local gun = ply:Give(tblweps[ply:Team()][mrand])
				ply:GiveAmmo(gun:GetMaxClip1() * 3,gun:GetPrimaryAmmoType(),true)
				
				hg.AddAttachmentForce(ply,gun,tblatts[ply:Team()][mrand])
				hg.AddArmor(ply, tblarmors[ply:Team()][mrand])


				ply:Give("weapon_hg_rgd_tpik")
				ply:Give("weapon_walkie_talkie")
				ply:Give("weapon_bandage_sh")
				ply:Give("weapon_tourniquet")
			end--]]

			//ply:Give("weapon_melee")

			ply:Give("weapon_melee")
			ply:Give("weapon_bandage_sh")
			ply:Give("weapon_tourniquet")
			ply.organism.allowholster = true

			local Radio = ply:Give("weapon_walkie_talkie")
			Radio.Frequency = (ply:Team() == 1 and 2) or 5
			local hands = ply:Give("weapon_hands_sh")
			ply:SelectWeapon("weapon_hands_sh")

			timer.Simple(0.1,function()
				ply.noSound = false
			end)

			ply:SetSuppressPickupNotices(false)
		end
	end)
end

function MODE:RoundThink()
end

function MODE:GetTeamSpawn()
	return zb.TranslatePointsToVectors(zb.GetMapPoints( "HMCD_TDM_T" )), zb.TranslatePointsToVectors(zb.GetMapPoints( "HMCD_TDM_CT" ))
end

function MODE:CanSpawn()
end

util.AddNetworkString("tdm_roundend")
function MODE:EndRound()
	timer.Simple(2,function()
		net.Start("tdm_roundend")
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

function MODE:PlayerDeath(ply)
end
util.AddNetworkString( "tdm_open_buymenu" )
function MODE:ShowSpare1(ply ) -- OpenMenu
	if not ply:Alive() then return end
	net.Start( "tdm_open_buymenu" )
	net.Send( ply )
end

util.AddNetworkString( "tdm_buyitem" )

local AttachmentPrice = 50
net.Receive("tdm_buyitem",function(len,ply)
	if !CurrentRound().buymenu then return end
	if ((zb.ROUND_START or 0) + 40 < CurTime()) then ply:ChatPrint("Time's up!") return end
	local tItem = net.ReadTable()
	if not istable(tItem) then return end
	local category = tItem[1]
	local index = tItem[2]
	if not category or not index then return end
	local buyItems = CurrentRound().BuyItems
	if not buyItems or not buyItems[category] or not buyItems[category][index] then return end
	local item = buyItems[category][index]

	if not item then return end

	if tItem[3] then
		if not ply:HasWeapon(item.ItemClass) then ply:ChatPrint("You can't buy this attachment without a weapon.") return end
		if ((ply:GetNWInt("TDM_Money",0) - AttachmentPrice) < 0) then ply:ChatPrint("Not enough money.") return end

		local wep = ply:GetWeapon(item.ItemClass)
		hg.AddAttachmentForce( ply,wep,tItem[3] )
		ply:SetNWInt( "TDM_Money", ply:GetNWInt("TDM_Money",0) - AttachmentPrice )
		ply:EmitSound("items/itempickup.wav")

		return
	end

	if ((ply:GetNWInt("TDM_Money",0) - item.Price) < 0) then ply:ChatPrint("Not enough money.") return end
	local ent = ply:Give(item.ItemClass)
	
	if ent.Use and IsValid(ent) then
		ent:Use( ply )
	end

	if IsValid(ent) and ent:GetClass() == "weapon_bloodbag" then
		ent.bloodtype = "o-"
		ent.modeValues[1] = 1
	end

	if item.Amount then
		ent.AmmoCount = item.Amount
	end

	if ent.GetPrimaryAmmoType then
		ply:GiveAmmo(ent:GetMaxClip1() * 1,ent:GetPrimaryAmmoType(),true)
	end

	ply:SetNWInt( "TDM_Money", ply:GetNWInt("TDM_Money",0) - item.Price )
	ply:EmitSound("items/itempickup.wav")
end)
