hg.PhysBullet = hg.PhysBullet or {}
local PLUGIN = hg.PhysBullet
PLUGIN.NetMaxCreateBullet = 250
PLUGIN.NetCreateUsage = PLUGIN.NetCreateUsage or 0
PLUGIN.NetCreateLast = PLUGIN.NetCreateLast or 0
PLUGIN.NetMaxUpdateBullet = 300
PLUGIN.NetUpdateUsage = PLUGIN.NetUpdateUsage or 0
PLUGIN.NetUpdateLast = PLUGIN.NetUpdateLast or 0
PLUGIN.NetCDCreateBullet = 0.1
PLUGIN.NetCDUpdateBullet = 1
PLUGIN.NetCDRemoveBullet = 0.1 --; Unused

util.AddNetworkString("HG.Plugin[bullet](CreateBullet)")
util.AddNetworkString("HG.Plugin[bullet](UpdateBullet)")
util.AddNetworkString("HG.Plugin[bullet](RemoveBullet)")

function PLUGIN.NetworkWriteBulletsTable(bullet, net_table)
	for _, info in ipairs(net_table) do
		local key = info[1]
		local write = info[2]
		
		if(write(bullet[key]) == false)then
			return false
		end
	end
end

function PLUGIN.NetworkBulletUpdate(bullet, ply, forced)
	if(PLUGIN.NetUpdateLast and PLUGIN.NetUpdateLast + 1 <= CurTime())then
		PLUGIN.NetUpdateLast = CurTime()
		PLUGIN.NetUpdateUsage = 0
	end

	if(forced or PLUGIN.NetUpdateUsage < PLUGIN.NetMaxUpdateBullet)then
		local recipients = RecipientFilter(true)
		
		recipients:AddPVS(bullet.Pos)
		
		PLUGIN.NetUpdateUsage = PLUGIN.NetUpdateUsage + recipients:GetCount()
	
		net.Start("HG.Plugin[bullet](UpdateBullet)", true)
			if(PLUGIN.NetworkWriteBulletsTable(bullet, PLUGIN.NetworkTableUpdate) == false)then
				net.Abort()
				return false
			end
		
		if(ply)then
			net.Send(ply)
		else
			net.Send(recipients)
		end
	end
end

function PLUGIN.NetworkBulletFull(bullet, ply, forced)
	if(PLUGIN.NetCreateLast and PLUGIN.NetCreateLast + 1 <= CurTime())then
		PLUGIN.NetCreateLast = CurTime()
		PLUGIN.NetCreateUsage = 0
	end
	
	if(forced or PLUGIN.NetCreateUsage < PLUGIN.NetMaxCreateBullet)then
		local recipients = RecipientFilter(true)
		
		recipients:AddPVS(bullet.Pos)
	
		PLUGIN.NetCreateUsage = PLUGIN.NetCreateUsage + recipients:GetCount()
	
		net.Start("HG.Plugin[bullet](CreateBullet)", true)
			if(PLUGIN.NetworkWriteBulletsTable(bullet, PLUGIN.NetworkTableFull) == false)then
				net.Abort()
				return false
			end
		
		if(ply)then
			net.Send(ply)
		else
			net.Send(recipients)
		end
	end
end

function PLUGIN.NetworkBulletRemove(bullet, ply)
	net.Start("HG.Plugin[bullet](RemoveBullet)", true)
		PLUGIN.net_writekey(bullet.Key)
	
	if(ply)then
		net.Send(ply)
	else
		net.SendPVS(bullet.Pos)
	end
end

net.Receive("HG.Plugin[bullet](CreateBullet)", function(len, ply)
	-- if(not ply.HG_PHYSBULLET_LastFullNet or (ply.HG_PHYSBULLET_LastFullNet + PLUGIN.NetCDCreateBullet) <= CurTime())then
	local bullet_key = PLUGIN.net_readkey()
	local bullet = PLUGIN.BulletsTable[bullet_key]
	
	if(bullet)then
		PLUGIN.NetworkBulletFull(bullet, ply)
	end
	-- end
end)