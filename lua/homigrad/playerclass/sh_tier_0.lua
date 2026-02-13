player.classList = player.classList or {}
local classList = player.classList
local PlayerMeta = FindMetaTable("Player")
function PlayerMeta:GetPlayerClass()
	return classList[self.PlayerClassName or ""]
end

local meta
function PlayerMeta:PlayerClassEvent(name, ...) --haha
	meta = self:GetPlayerClass()
	meta = meta and meta[name]
	if meta then return meta(self, ...) end
end

function player.RegClass(name)
	local class = classList[name] or {}
	classList[name] = class
	return class
end

function player.EventPoint(pos, name, radius, ...)
	for i, ply in player.Iterator() do
		if ply:GetPos():Distance(pos) > radius then continue end
		ply:PlayerClassEvent("EventPoint", name, pos, radius, ...)
	end
end

function player.Event(ply, name, ...)
	ply:PlayerClassEvent("Event", name, ...)
end

if SERVER then return end
net.Receive("setupclass", function()
	local ply = net.ReadEntity()
	if not IsValid(ply) then --lol
		return
	end

	ply.PlayerClassName = net.ReadString()
	ply.PlayerClassNameOld = net.ReadString()
	local data = net.ReadTable()
	old = classList[ply.PlayerClassNameOld]
	if old and old.Off then old.Off(ply) end
	ply:PlayerClassEvent("On", data)
end)

hook.Add("PostDrawAppearance", "PlayerClass", function(ent,ply) end)

if CLIENT then
	hook.Add("Player Think", "ClassPlyThink", function(ply, time, dtime)
		ply:PlayerClassEvent("Think", time, dtime)
	end)
end

--hook.Add("HGReloading", "PlayerClass", function(wep) wep:GetOwner():PlayerClassEvent("HGReloading", wep) end)
--hook.Add("PlayerFootstep", "PlayerClass", function(ply, pos, foot, sound, volume, rf) ply:PlayerClassEvent("PlayerFootstep", ply, pos, foot, sound, volume, rf) end)