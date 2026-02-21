
local MODE = MODE

MODE.GuiltDisabled = true
MODE.PoliceTime = 9999

function MODE:AfterBaseInheritance()
	self.Types.standard2 = self.Types.standard
	self.Types.soe2 = self.Types.soe

	self.Types.wildwest = nil
	self.Types.gunfreezone = nil
	self.Types.standard = nil
	self.Types.soe = nil
end

function MODE:CanLaunch()
	return false
end

function MODE:IsDoor(ent)
	return ent:GetClass() == "prop_door_rotating" or ent:GetClass() == "prop_door"
end

local crysound
local hooks = {}
function MODE:RandomStuff()
	for _, v in ents.Iterator() do
		if self:IsDoor(v) then
			if math.random(1, 100) != 1 then continue end
			v:Fire("Toggle")
		elseif v.GetPhysicsObject and IsValid(v:GetPhysicsObject()) and !self:IsDoor(v) then
			if v:GetClass() == "prop_ragdoll" then
				if math.random(1, 100) != 1 then continue end
				local bones = v:GetPhysicsObjectCount()
				for i = 0, bones - 1 do
					local phys = v:GetPhysicsObjectNum( i )
					if ( IsValid( phys ) ) then
						phys:EnableGravity(false)
						phys:Wake()

						phys:SetVelocity(Vector(math.Rand(-1000, 1000), math.Rand(-1000, 1000), math.Rand(-1000, 1000)))
					end
				end
			else
				if math.random(1, 5000) != 1 then continue end
				v:GetPhysicsObject():SetVelocity(Vector(math.Rand(-1000, 1000), math.Rand(-1000, 1000), math.Rand(-1000, 1000)))
			end
		end
	end

	if math.random(1, 25) == 1 and !IsValid(crysound) then
		local snd = math.random(2) == 1 and "cry2.wav" or "cry1.wav"
		if crysound then return end
		local tbl = ents.FindByClass("func_door_rotating")
		table.Add(ents.FindByClass("prop_door_rotating"))
		
		local door
		for i, ent in RandomPairs(tbl) do
			if DoorIsOpen(ent) then
				door = ent

				break
			end
		end

		local pos = door:GetPos() + door:GetAngles():Right() * 1
		crysound = CreateSound(door, snd)
		crysound:Play()

		hook.Add("PlayerUse", "dooruse"..door:EntIndex(), function(ply, ent)
			if ent == door then
				crysound:Stop()
				crysound = nil
			end

			hook.Remove("PlayerUse", "dooruse"..ent:EntIndex())
		end)

		hooks[#hooks + 1] = "dooruse"..door:EntIndex()

		return
	end
end

hook.Add("PostCleanupMap", "removehooksass", function()
	for i, hooka in ipairs(hooks) do
		hook.Remove("PlayerUse", hooka)
	end
end)

local modes = {
	"soe2",
	"standard2",
}

function MODE:SubModes()
	return modes
end

function MODE:Intermission()
	game.CleanUpMap()

	MODE.saved.TimePlayed = 0
	MODE.saved.KillTime = CurTime() + 60

	local _,CROUND = CurrentRound()

	if not CROUND or CROUND == "hmcd" then
		CROUND = table.Random(self:SubModes())
	end

	self.Type = CROUND
	local player_count = 0

	for k, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end
		ply:KillSilent()

		ply.isPolice = false
		ply.isTraitor = false
		ply.isGunner = false
		ply.MainTraitor = false
		ply.SubRole = nil
		ply.Profession = nil

		ply:SetupTeam(0)

		ply.organism.recoilmul = DefaultSkillIssue
		player_count = player_count + 1
	end

	MODE.TraitorFrequency = nil
	MODE.TraitorWord = MODE.TraitorWords[math.random(1, #MODE.TraitorWords)]
	MODE.TraitorWordSecond = MODE.TraitorWords[math.random(1, #MODE.TraitorWords)]
	local traitors_needed = 0

	MODE.TraitorExpectedAmt = traitors_needed
	local main_traitor = nil
	local traitors = {}


	//MODE.NextRoundMainTraitors = MODE.NextRoundMainTraitors or {}
	for i, ply in RandomPairs(player.GetAll()) do
		if ply.isTraitor or ply:Team() == TEAM_SPECTATOR then continue end
		//if not MODE.NextRoundMainTraitors[ply:SteamID()] then continue end

		if traitors_needed > 0 then
			ply.isTraitor = true
			traitors_needed = traitors_needed - 1
			traitors[#traitors + 1] = ply

			main_traitor = ply
			ply.MainTraitor = true
			//MODE.NextRoundMainTraitors[ply:SteamID()] = nil
		end
	end


	for i, ply in RandomPairs(player.GetAll()) do
		if ply.isTraitor or ply:Team() == TEAM_SPECTATOR then continue end
		if math.random(100) > (ply.Karma or 100) then continue end

		if traitors_needed > 0 then
			ply.isTraitor = true
			traitors_needed = traitors_needed - 1
			traitors[#traitors + 1] = ply

			if not main_traitor then
				main_traitor = ply
				ply.MainTraitor = true
			end
		end
	end

	if traitors_needed > 0 then
		for i, ply in RandomPairs(player.GetAll()) do
			if ply.isTraitor or ply:Team() == TEAM_SPECTATOR then continue end

			if traitors_needed > 0 then
				ply.isTraitor = true
				traitors_needed = traitors_needed - 1
				traitors[#traitors + 1] = ply

				if not main_traitor then
					main_traitor = ply
					ply.MainTraitor = true
				end
			end
		end
	end

	-- self.saved.PoliceTime = CurTime() + math.min(self.Types[self.Type].PoliceTime * (#player.GetAll() / 4),self.Types[self.Type].PoliceTime * 2.2)
	self.saved.PoliceTime = 99999
	self.PoliceSpawned = false
	self.PoliceAllowed = false

	for k, ply in player.Iterator() do
		if(MODE.ShouldStartRoleRound())then
			net.Start("HMCD_RoundStart")	--; TODO Structure description
				net.WriteBool(ply.isTraitor)	--; Is Traitor
				net.WriteBool(ply.isGunner)	--; Is Gunner
				net.WriteString(self.Type)	--; Round Type
				net.WriteBool(false)	--; Round Started
				net.WriteString("")	--; SubRole
				net.WriteBool(ply.MainTraitor == true)	--; MainTraitor

				if(ply.isTraitor)then
					net.WriteString(MODE.TraitorWord)
					net.WriteString(MODE.TraitorWordSecond)
					net.WriteUInt(MODE.TraitorExpectedAmt, MODE.TraitorExpectedAmtBits)
				else
					net.WriteString("")
					net.WriteString("")
					net.WriteUInt(0, MODE.TraitorExpectedAmtBits)
				end

				net.WriteString("")	--; Profession
			net.Send(ply)

			local role = self.Roles[self.Type][(ply.isTraitor and "traitor") or (ply.isGunner and "gunner") or "innocent"]

			zb.GiveRole(ply, role.name, role.color)
		end
	end

	self:CreateTimer("WaitForRandomStuff", math.Rand(60, 120), 1, function()
		self:CreateTimer("FearRandomStuff", 5, 0, function()
			self:RandomStuff()
		end)
	end)
end

function MODE:ShouldRoundEnd()
	return #zb:CheckAlive() == 0
end

function MODE:EndRound()
	timer.Remove("HMCDSpawnSWAT")
	timer.Remove("SpawnAdditionalPolice")
	timer.Remove("SpawnAdditionalNationalGuard")

	for k, _ in pairs(self.saved.Timers or {}) do
		timer.Remove(k)
	end

	self.deadPoliceCount = 0
	self.swatDeployed = false
	self.spawnedPoliceCount = 0
	self.roundStartType = nil

	local traitors, gunners = {}, {}
	local players_alive = 0
	local endround, winner = zb:CheckWinner(self:CheckAlivePlayers())

	for i, ply in player.Iterator() do
		if ply.isTraitor and ply:Team() ~= TEAM_SPECTATOR then
			traitors[#traitors + 1] = ply
		end

		if ply.isGunner and ply:Team() ~= TEAM_SPECTATOR then
			gunners[#gunners + 1] = ply
		end

		if(ply:Alive() and ply.organism and !ply.organism.incapacitated)then
			players_alive = players_alive + 1
		end

		ply.isPolice = false
		ply.isTraitor = false
		ply.isGunner = false
		ply.MainTraitor = false
		ply.SubRole = nil
		ply.Profession = nil

		self:ResetNetworkVars(ply)
	end

	timer.Simple(2,function()
		net.Start("hmcd_roundend")
			net.WriteUInt(#traitors, MODE.TraitorExpectedAmtBits)

			for _, traitor in ipairs(traitors) do
				net.WriteEntity(traitor)
			end

			net.WriteUInt(#gunners, MODE.TraitorExpectedAmtBits)

			for _, gunner in ipairs(gunners) do
				net.WriteEntity(gunner)
			end
		net.Broadcast()
	end)
end

function MODE:SkipVictim(ply)
	if ply:GetNetVar("disappearance") then
		return true
	end
end

function MODE:CheckInAGroup(ply)
	local players = zb:CheckAlive()
	local flag = false

	for i2, ply2 in ipairs(players) do
		if IsLookingAt(ply2, ply:EyePos(), 0.8) and hg.isVisible(ply:EyePos(), ply2:EyePos(), {ply, ply2}, MASK_VISIBLE) then
			flag = true
		end
	end

	return flag
end

util.AddNetworkString("check_lightness")

local checkedPlayer
local checkPlayers = {}
local maxLen = math.sqrt(3)
net.Receive("check_lightness", function(len, ply)
	local vec = net.ReadVector()
	
	if vec:Length() > maxLen then return end
	if vec[1] < 0 or vec[2] < 0 or vec[3] < 0 then return end

	if checkedPlayer and !checkPlayers[ply] then
		checkPlayers[ply] = true
		
		checkedPlayer.lightcolor = checkedPlayer.lightcolor or Vector(0.5, 0.5, 0.5)
		checkedPlayer.lightcolor = LerpVector(0.5, checkedPlayer.lightcolor, vec)
	end
end)

function MODE:CheckInDarkness(ply)
	return ply.lightcolor and ply.lightcolor:Length() < 0.1
end

function MODE:SelectTheBestVictim()
	local alive = zb:CheckAlive()
	local victims = {}
	local victims_stats = {}

	for i, ply in ipairs(alive) do
		if self:SkipVictim(ply) then continue end
		
		local index = #victims_stats + 1

		victims_stats[index] = {}
		local tbl = victims_stats[index]
		tbl.ply = ply
		tbl.harmed = math.min(zb.HarmAttacked[ply] or 0, 40) / 40
		tbl.not_in_a_group = !self:CheckInAGroup(ply) and 1 or 0
		tbl.in_darkness = self:CheckInDarkness(ply) and 25 or 0
		tbl.has_a_gun = ishgweapon(ply:GetActiveWeapon()) and 1 or 0
		tbl.doesnt_move = (ply.avgvelocity or 0) < 200 and 1 or 0
		tbl.randomness = math.random(-3, 3)

		tbl.calculated_interest = tbl.harmed + tbl.not_in_a_group
			+ tbl.in_darkness + tbl.in_darkness + tbl.has_a_gun
			+ tbl.doesnt_move + tbl.randomness
	end
	
	self.saved.KillTime = CurTime() + math.random(30, 90) * math.max(#alive / 20, 0.5)

	if #alive == 1 then
		self.saved.KillTime = CurTime() + 5
	end

	local victim = table.Random(alive)
	local max_interest = -5
	for i, tbl in ipairs(victims_stats) do
		if max_interest < tbl.calculated_interest then
			max_interest = tbl.calculated_interest
			vicitm = tbl.ply
		end
		-- print(tbl.calculated_interest, tbl.ply)
	end

	return vicitm
end

function MODE:ReturnToRealmOfLiving(ply)
	local entindex = ply:EntIndex()

	local players = zb:CheckAlive()

	self:CreateTimer("ReturnToLife " .. entindex, 10, 0, function()
		if !IsValid(ply) or !ply:Alive() then
			timer.Remove("ReturnToLife " .. entindex)
		else
			for i2, ply2 in ipairs(players) do
				if IsLookingAt(ply2, ply:EyePos(), 0.8) and hg.isVisible(ply:EyePos(), ply2:EyePos(), {ply, ply2}, MASK_VISIBLE) then
					return
				else
					ply:SetNetVar("disappearance", false)
					timer.Remove("ReturnToLife " .. entindex)
				end
			end
		end
	end)
end

function MODE:Disappear(ply)
	ply:SetCustomCollisionCheck(true)
	ply:CollisionRulesChanged()
	ply:SetNetVar("disappearance", true)

	if self.CurrentVictim == ply then
		self.CurrentVictim = nil
	end

	self:CreateTimer("disappearance " .. ply:EntIndex(), math.Rand(60, 120), 1, function()
		if IsValid(ply) and ply:Alive() then
			if #zb:CheckAlive() > 1 and (math.random(1, 3) == 1) then
				self:CreateTimer("Afterlife " .. ply:EntIndex(), 119, 1, function()
					if IsValid(ply) and ply:Alive() then
						ply:KillSilent()
						ply:ChatPrint("You were taken into the afterlife.")
					end
				end)

				ply:SetLocalVar("afterlife", CurTime())
			else
				self:ReturnToRealmOfLiving(ply)
			end
		end
	end)
end

local counted_players = {}
function MODE:PropKill(ply)
	local index = ply:EntIndex()

	if self.CurrentVictim == ply then
		self.CurrentVictim = nil
	end

	self:CreateTimer("Fear_PropKill " .. index, 5, math.random(30, 60), function()
		if !IsValid(ply) or !ply:Alive() then
			timer.Remove("Fear_PropKill " .. index)
			return
		end

		for _, v in ipairs(ents.FindInSphere(ply:GetPos(), 256)) do
			if v.GetPhysicsObject and IsValid(v:GetPhysicsObject()) and !self:IsDoor(v) then
				if math.random(1, 50) == 1 then
					local pos
					if !IsValid(ply.FakeRagdoll) then
						pos = ply:GetBoneMatrix(ply:LookupBone("ValveBiped.Bip01_Head1")):GetTranslation()
					elseif IsValid(ply.FakeRagdoll) then
						pos = ply.FakeRagdoll:GetBoneMatrix(ply.FakeRagdoll:LookupBone("ValveBiped.Bip01_Head1")):GetTranslation()
					end

					if !pos then return end

					local dir = (pos - v:GetPos()):GetNormalized()
					v:GetPhysicsObject():SetVelocity(dir * math.Rand(500, 2000))
					timer.Adjust("Fear_PropKill " .. index, math.Rand(1, 10))
					return
				end
			end
		end
	end)
end

function MODE:RoundThink()
	self.BaseClass.RoundThink(self)
	local players = zb:CheckAlive()

	self.saved.TimePlayed = (self.saved.TimePlayed or 0) + 0.5
	
	self.NextLightCheck = self.NextLightCheck or self.saved.TimePlayed + 5

	if self.saved.TimePlayed > self.NextLightCheck then
		self.NextLightCheck = self.saved.TimePlayed + 5
		
		if table.Count(counted_players) >= #players then
			counted_players = {}
		end
		
		for i, ply in ipairs(players) do
			if ply.lightcolor and counted_players[ply] then continue end
			counted_players[ply] = true
			checkedPlayer = ply
			ply.lastcheckedcolor = MODE.saved.TimePlayed

			net.Start("check_lightness")
			net.WriteEntity(ply)
			net.Broadcast()
	
			timer.Simple(0.5, function()
				checkedPlayer = nil
				checkPlayers = {}
			end)

			break
		end
	end

	self.CurrentVictim = IsValid(self.CurrentVictim) and self.CurrentVictim:Alive() and self.CurrentVictim or self:SelectTheBestVictim()

	local ply = self.CurrentVictim
	
	-- print(ply, CurTime(), MODE.saved.KillTime)

	if !IsValid(ply) then return end
	if CurTime() < self.saved.KillTime then return end

	--print(ply, CurTime(), MODE.saved.KillTime, true)

	if #players == 1 then
		ply:KillSilent()

		return
	end

	local wep = ply:GetActiveWeapon()
	local use_weapon = math.random(2) == 1 and ishgweapon(wep) and wep.CanSuicide and wep:Clip1() > 0 and ply:GetNWFloat("willsuicide", 0) == 0
	if !use_weapon then
		local flag = true

		for i2, ply2 in ipairs(players) do
			if IsLookingAt(ply2, ply:EyePos(), 0.8) and hg.isVisible(ply:EyePos(), ply2:EyePos(), {ply, ply2}, MASK_VISIBLE) then
				flag = false
			end
		end

		if flag then -- we can kill him :3	
			if math.random(2) == 1 then
				ply:KillSilent()
			elseif math.random(2) == 1 then
				self:PropKill(ply)
			elseif math.random(2) == 1 then
				hg.BreakNeck(ply)
			elseif math.random(2) == 1 then
				self:StartEvent("scary_black_guy", ply)
			else
				self:Disappear(ply)
			end
		else
			if math.random(2) == 1 then
				for k, v in player.Iterator() do
					v:ScreenFade(SCREENFADE.IN, Color(0, 0, 0), 0.7, 0.4)
				end
				ply:KillSilent()
			elseif math.random(2) == 1 then
				local bot = ents.Create("bot_fear")
				bot.Victim = ply
				bot:Spawn()
			elseif math.random(2) == 1 then
				for k, v in player.Iterator() do
					v:ScreenFade(SCREENFADE.IN, Color(0, 0, 0), 0.7, 0.4)
				end

				self:Disappear(ply)
			else
				self:StartEvent("scary_black_guy", ply)
			end
		end
	else
		if ply.suiciding then
			wep:PrimaryAttack(true)
		else
			local ent = wep:GetTrace().Entity
			if IsValid(ent) and ent:IsPlayer() and math.random(2) == 1 then
				wep:PrimaryAttack(true)
			else
				ply:SetNWFloat("willsuicide", CurTime() + 5)
			end
		end
	end

	self.CurrentVictim = nil
end

function MODE:ResetNetworkVars(ply)
	ply:SetNWFloat("willsuicide", 0)
	ply:SetLocalVar("afterlife", nil)
	ply:SetNetVar("disappearance", nil)
	ply:SetCustomCollisionCheck(false)
	ply:CollisionRulesChanged()
end

function MODE:PlayerSilentDeath(ply)
	self:ResetNetworkVars(ply)
end

function MODE:PlayerDeath(ply)
	self:ResetNetworkVars(ply)

	self:CreateTimer("Fear_End", 3, 1, function()
		local alive = zb:CheckAlive()

		if #alive == 1 then
			MODE.saved.KillTime = CurTime() + 120
			
			for i, ent in ipairs(ents.FindByClass('env_soundscape*')) do
				ent:Remove()
			end

			if timer.Exists("disappearance " .. alive[1]:EntIndex()) then
				timer.Adjust("disappearance " .. alive[1]:EntIndex(), 0)
			end
		end
	end)
end

function MODE:Ragdoll_Create(ply, ent)
	ent:SetCustomCollisionCheck(true)
	ent:CollisionRulesChanged()
end

function MODE:HG_PlayerCanHearPlayersVoice(listener, talker)
	if listener:GetNetVar("disappearance") or talker:GetNetVar("disappearance") then return true end
end

function MODE:HG_PlayerCanSeePlayersChat(listener, talker)
	if listener:GetNetVar("disappearance") or talker:GetNetVar("disappearance") then return true end
end
