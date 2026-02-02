local mside = GetConVar("cl_sidespeed"):GetInt()
local mforw = GetConVar("cl_forwardspeed"):GetInt()

local curtime = CurTime()
local _math_abs = math.abs

local limit = 30

local function admin_advert(ply, n)
	if curtime > CurTime() then return end
	curtime = CurTime() + 2

	local text = string.format("%s - возможно использует чит. ПО. [%i/%i]", ply:Name(), n, limit)
	Msg("[AC] ")print(text)

	for k, v in ipairs(player.GetAll()) do
		if v:IsAdmin() then
			v:ChatPrint(text)
		end
	end

	if tonumber(n) > limit and not ply.PlayerBlocked then
		RunConsoleCommand("ulx", "banid", ply:SteamID(), "0", "[AC] Cheats")
		for k, v in ipairs(player.GetAll()) do
			if v:IsAdmin() then
				v:ChatPrint( ply:Name() .. " ЧИТЕР ПОГАНЫЙ" )
			end
		end
	end
end

local function mvcheck(ply, cmd)
	if (ply.ac_Anti or 0) > CurTime() then
		return
	end

	local side = cmd:GetSideMove()
	local forward = cmd:GetForwardMove()
	
	side = _math_abs(side)
	forward = _math_abs(forward)
	
	if (side == 0 and forward == 0 ) then return end 
	if (mforw == forward or mside == side) then return end

	if (side > mside or forward > mforw) then ply.AimCheck = ply.AimCheck + 1 admin_advert(ply, ply.AimCheck) return end
	if (side > mside - 5) then ply.AimCheck = ply.AimCheck + 1 admin_advert(ply, ply.AimCheck) return end
	if (forward > mforw - 5) then ply.AimCheck = ply.AimCheck + 1 admin_advert(ply, ply.AimCheck) return end
end

hook.Add("StartCommand", "ac_check", mvcheck)

local function initial_aimcheck(ply)
	ply.AimCheck = 0
end

hook.Add("PlayerInitialSpawn", "ac_add", initial_aimcheck)
