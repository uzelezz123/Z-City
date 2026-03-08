GM.Name = "ZCity"
GM.Author = "uzelezz, sadsalat, Mr. Point, Zac90, Deka, Mannytko"
GM.Email = "N/A"
GM.Website = "N/A"

team.SetUp(0, "Players", Color(255, 0, 0))
team.SetUp(1, "Players2", Color(0, 0, 255))
team.SetUp(2, "Players3", Color(0, 255, 0))

DeriveGamemode("sandbox")

local blur = Material("pp/blurscreen")
local hg_potatopc -- НАДО ЭТО ГОВНО ПЕРЕПИСАТЬ НОРМАЛЬНО, И ВСЕ МЕНЮШКИ ОДИНАКОВЫЕ ТОЖЕ!!!
function hg.DrawBlur(panel, amount, passes, alpha)
	if is3d2d then return end
	amount = amount or 5
	hg_potatopc = hg_potatopc or hg.ConVars.potatopc

	if(hg_potatopc:GetBool())then
		surface.SetDrawColor(0, 0, 0, alpha or (amount * 20))
		surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
	else
		surface.SetMaterial(blur)
		surface.SetDrawColor(0, 0, 0, alpha or 125)
		surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())

		local x, y = panel:LocalToScreen(0, 0)

		for i = -(passes or 0.2), 1, 0.2 do
			blur:SetFloat("$blur", i * amount)
			blur:Recompute()
			
			render.UpdateScreenEffectTexture()
			surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
		end
	end
end

local function BlockSpawn(ply, ent)
	if game.SinglePlayer() or ply:IsAdmin() then return true end

	return false
end

local spawn = {"PlayerGiveSWEP", "PlayerSpawnEffect", "PlayerSpawnNPC", "PlayerSpawnObject", "PlayerSpawnProp", "PlayerSpawnRagdoll", "PlayerSpawnSENT", "PlayerSpawnSWEP", "PlayerSpawnVehicle"}

for _, v in ipairs(spawn) do
	hook.Add(v, "BlockSpawn", BlockSpawn)
end

hook.Add( "PlayerNoClip", "FeelFreeToTurnItOff", function( ply, desiredState )
	if ( desiredState == false ) then -- the player wants to turn noclip off
		return true -- always allow
	elseif ( ply:IsAdmin() ) then
		return true -- allow administrators to enter noclip
	end

	return false
end )

if CLIENT then
	hook.Add( "PlayerBindPress", "PlayerBindPressExample", function( ply, bind, pressed )
		if ( string.find( bind, "+menu" ) ) then
			--return true
		end
	end )

	hook.Add( "SpawnMenuOpen", "SpawnMenuWhitelist", function()
		local ply = LocalPlayer()
		if ply:IsSuperAdmin() then return end
		if ply:IsAdmin() then return end
		return false
	end )
end

local team_GetAllTeams = team.GetAllTeams

function zb:CheckTeams()
	local tbl = {}
	for i, info in pairs(team_GetAllTeams()) do
		tbl[i] = {}
	end

	for _, ply in player.Iterator() do
		tbl[ply:Team()][#tbl[ply:Team()] + 1] = ply
	end
	return tbl
end

function zb:CheckAliveTeams(incapacitatedcheck)
	local tbl = {}

	for i, info in pairs(team_GetAllTeams()) do
		if i == TEAM_UNASSIGNED or i == TEAM_SPECTATOR then continue end
		tbl[i] = {}
	end

	for _, ply in player.Iterator() do
		if not ply:Alive() then continue end
		if incapacitatedcheck and ply.organism and ply.organism.incapacitated then continue end

		tbl[ply:Team() or 0] = tbl[ply:Team() or 0] or {}
		tbl[ply:Team()][(#tbl[ply:Team() or 0] or 0) + 1] = ply
	end

	return tbl
end

function zb:CheckAlive(incapacitatedcheck)
	local tbl = {}
	for _, ply in player.Iterator() do
		if not ply:Alive() then continue end
		if incapacitatedcheck and ply.organism and ply.organism.incapacitated then continue end
		tbl[#tbl + 1] = ply
	end
	return tbl
end

function zb:CheckPlaying()
	local tbl = {}
	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end
		if not ply:Alive() then continue end
		
		tbl[#tbl + 1] = ply
	end
	return tbl
end
-- А это разве не в корне?
function GM:HandlePlayerLanding( ply, velocity, WasOnGround )
	if SERVER then return end
	if ply == LocalPlayer() and ply == GetViewEntity() then return end

	if ( ply:GetMoveType() == MOVETYPE_NOCLIP ) then return end

	if ( ply:IsOnGround() && !WasOnGround ) then
		ply:AnimRestartGesture( GESTURE_SLOT_JUMP, ACT_LAND, true )
	end

end

function GM:GrabEarAnimation(ply)
	hg.earanim(ply)
end