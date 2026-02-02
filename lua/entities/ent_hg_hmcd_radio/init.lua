AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel(self.Model)
    self:PhysicsInit(SOLID_VPHYSICS)
    if SERVER then
        self:SetMoveType(MOVETYPE_VPHYSICS)
    end
    self:SetSolid(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    self:DrawShadow(true)
    self:AddEFlags(EFL_IN_SKYBOX)
    
    local phys = self:GetPhysicsObject()

    if SERVER and IsValid(phys) then
        phys:SetMass(10)
        phys:Wake()
        phys:EnableMotion(true)
    end
end

hook.Add("OnEntityCreated", "radioCreate", function( ent )
	if ent:GetClass() == "ent_hg_hmcd_radio" then
		SetGlobalEntity("radio",ent)
	end
end)

util.AddNetworkString("RadioURLInput")
util.AddNetworkString("PlayRadioSound")
util.AddNetworkString("RadioChangeValue")
util.AddNetworkString("RadioChangeVolume")
util.AddNetworkString("RadioPause")
util.AddNetworkString("RadioStop")
util.AddNetworkString("RadioLooping")
util.AddNetworkString("paint_radio")

net.Receive("RadioURLInput", function(len, ply)
	local url = net.ReadString()
	local ent = net.ReadEntity()
	
	if ent:GetClass() != "ent_hg_hmcd_radio" or (ent:GetPos():Distance(ply:EyePos()) > 75) then return end

	net.Start("PlayRadioSound")
	net.WriteString(url)
	net.WriteInt(ent:EntIndex(),32)
	net.Broadcast()
end)

net.Receive("paint_radio", function(len, ply)
	local url = net.ReadString()
	local ent = net.ReadEntity()

	if ent:GetClass() != "ent_hg_hmcd_radio" or (ent:GetPos():Distance(ply:EyePos()) > 75) then return end

	ent:SetTextureURL( url )

	
	net.Start("paint_radio")
		net.WriteString( url )
		net.WriteEntity( ent )
	net.Broadcast()
end)

net.Receive("RadioChangeValue", function(len, ply)
	local val = net.ReadFloat()
	local index = net.ReadInt(32)
	local ent = Entity(index)

	if ent:GetClass() != "ent_hg_hmcd_radio" or (ent:GetPos():Distance(ply:EyePos()) > 75) then return end

	net.Start("RadioChangeValue")
	net.WriteFloat(val)
	net.WriteInt(index,32)
	net.Broadcast()
end)

net.Receive("RadioChangeVolume", function(len, ply)
	local val = net.ReadFloat()
	local index = net.ReadInt(32)
	local ent = Entity(index)
	
	if ent:GetClass() != "ent_hg_hmcd_radio" or (ent:GetPos():Distance(ply:EyePos()) > 75) then return end

	net.Start("RadioChangeVolume")
	net.WriteFloat(val)
	net.WriteInt(index,32)
	net.Broadcast()
end)

net.Receive("RadioPause", function(len, ply)
	local bool = net.ReadBool()
	local ent = net.ReadEntity()
	
	if ent:GetClass() != "ent_hg_hmcd_radio" or (ent:GetPos():Distance(ply:EyePos()) > 75) then return end
	
	net.Start("RadioPause")
		net.WriteBool(bool)
		net.WriteInt(ent:EntIndex(),32)
	net.Broadcast()
end)

net.Receive("RadioLooping", function(len, ply)
	local bool = net.ReadBool()
	local ent = net.ReadEntity()

	if ent:GetClass() != "ent_hg_hmcd_radio" or (ent:GetPos():Distance(ply:EyePos()) > 75) then return end

	net.Start("RadioLooping")
		net.WriteBool(bool)
		net.WriteInt(ent:EntIndex(),32)
	net.Broadcast()
end)

net.Receive("RadioStop", function(len, ply)
	local ent = net.ReadEntity()

	if ent:GetClass() != "ent_hg_hmcd_radio" or (ent:GetPos():Distance(ply:EyePos()) > 75) then return end

	net.Start("RadioStop")
		net.WriteInt(ent:EntIndex(),32)
	net.Broadcast()
end)