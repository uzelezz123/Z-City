local attachsounds = {
	"arc9_eft_shared/weap_bolt_catch.ogg",
	"arc9_eft_shared/weap_ar_pickup.ogg",
	"arc9_eft_shared/weap_bolt_out.ogg",
	"arc9_eft_shared/weap_dmr_pickup.ogg",
	"arc9_eft_shared/weap_dmr_use.ogg",
	"arc9_eft_shared/weap_pump_drop.ogg",
	"arc9_eft_shared/weap_rifle_pickup.ogg",
	"arc9_eft_shared/weap_rifle_drop.ogg",
	"arc9_eft_shared/weap_rifle_use.ogg"
}

util.AddNetworkString("ZB_AttachAdd")
util.AddNetworkString("ZB_AttachRemove")
util.AddNetworkString("ZB_AttachDrop")
net.Receive("ZB_AttachAdd", function(len, ply)
	local att = net.ReadString()
	local wep = ply:GetActiveWeapon()
	hg.AddAttachment(ply,wep,att)
	//ply:SetNetVar("Inventory",ply.inventory)
end)

function hg.AddAttachment(ply,wep,att)
	if wep:GetNWFloat("addAttachment", 0) + 1 > CurTime() then return end

	if not IsValid(wep) or not wep.attachments or att == "" then return end
	if not IsValid(ply) then return end
	if not table.HasValue(ply.inventory.Attachments, att) then return end --oops :(
	if ply.organism.larmamputated or ply.organism.rarmamputated then return end -- зубами

	if att and istable(att) then
		for i,atta in pairs(att) do
			hg.AddAttachment(ply,wep,atta)
		end
		return
	end

	local placement = nil

	for plc, tbl in pairs(hg.attachments) do
		placement = tbl[att] and tbl[att][1] or placement
	end

	if not wep.attachments[placement].noblock then
		local restrictAtt = hg.attachments[placement][att].restrictatt
		
		for i,att in pairs(wep.attachments) do
			if not att or not istable(att) or table.IsEmpty(att) or att[1] == "empty" then continue end
			if restrictAtt then
				if hg.attachments[i][att[1]][1] == restrictAtt then
					ply:ChatPrint("There is no space for this attachment.")
					return
				end
			else
				if not wep.availableAttachments[i].noblock and hg.attachments[i][att[1]].restrictatt and hg.attachments[i][att[1]].restrictatt == placement then
					ply:ChatPrint("There is no space for this attachment.")
					return
				end
			end
		end
	end

	if not placement then return end
	if not (table.IsEmpty(wep.attachments[placement]) or wep.attachments[placement][1] == "empty") then
		ply:ChatPrint("There is no space for this attachment.")
		return
	end
	
	--if not wep.availableAttachments[placement] then return end
	local i
	if wep.availableAttachments[placement] then
		for n, atta in pairs(wep.availableAttachments[placement]) do
			i = istable(atta) and atta[1] == att and n or i
		end
	end
	
	--if not i then ply:ChatPrint("You cant place this attachment on this weapon.") return end
	local mountType = wep.availableAttachments[placement] and wep.availableAttachments[placement]["mountType"]
	local mountType2 = hg.attachments[placement][att] and hg.attachments[placement][att].mountType
	if not wep.availableAttachments[placement] then return end
	
	if not wep.availableAttachments[placement][i] and not (mountType or mountType2) then return end
	local mounts = istable(mountType) and table.HasValue(mountType, hg.attachments[placement][att].mountType) or mountType == mountType2
	
	if not mounts then
		return
	end
	

	wep:AttachAnim()
	timer.Simple(0.5,function()
		if wep:IsValid() then
			if not table.HasValue(ply.inventory.Attachments, att) then return end
				
			table.RemoveByValue(ply.inventory.Attachments, att)
			
			ply:SetNetVar("Inventory", ply.inventory)

			wep.attachments[placement] = i and wep.availableAttachments[placement][i] or {att, {}}

			wep:SyncAtts()
			wep:EmitSound(attachsounds[math.random(#attachsounds)], 40)
		end
	end)
end

function hg.AddAttachmentForce(ply,wep,att)
	if not IsValid(wep) or not wep.attachments or att == "" then return end
	
	if att and istable(att) then
		for i,atta in pairs(att) do
			hg.AddAttachmentForce(ply,wep,atta)
		end
		return
	end

	local placement = nil

	for plc, tbl in pairs(hg.attachments) do
		placement = tbl[att] and tbl[att][1] or placement
	end

	if not wep.attachments[placement].noblock then
		local restrictAtt = hg.attachments[placement][att].restrictatt
		
		for i,att in pairs(wep.attachments) do
			if not att or not istable(att) or table.IsEmpty(att) or att[1] == "empty" then continue end
		end
	end

	if not placement then return end

	--if not wep.availableAttachments[placement] then return end
	local i
	if wep.availableAttachments[placement] then
		for n, atta in pairs(wep.availableAttachments[placement]) do
			i = istable(atta) and atta[1] == att and n or i
		end
	end
	
	--if not i then ply:ChatPrint("You cant place this attachment on this weapon.") return end
	local mountType = wep.availableAttachments[placement] and wep.availableAttachments[placement]["mountType"]
	local mountType2 = hg.attachments[placement][att] and hg.attachments[placement][att].mountType
	if not wep.availableAttachments[placement] then return end
	
	if not wep.availableAttachments[placement][i] and not (mountType or mountType2) then return end
	local mounts = istable(mountType) and table.HasValue(mountType, hg.attachments[placement][att].mountType) or mountType == mountType2
	
	if not mounts then
		return
	end

	wep.attachments[placement] = i and wep.availableAttachments[placement][i] or {att, {}}
	timer.Simple(.1,function()
		if wep:IsValid() then
			wep:SyncAtts()
		end
	end)
end

net.Receive("ZB_AttachRemove", function(len, ply)
	local att = net.ReadString()
	local wep = ply:GetActiveWeapon()
	if not IsValid(wep) or not wep.attachments then return end
	if wep:GetNWFloat("addAttachment", 0) + 1 > CurTime() then return end
	if not IsValid(ply) then return end
	if ply.organism.larmamputated or ply.organism.rarmamputated then return end
	--[[if table.HasValue(ply.inventory.Attachments, att) then
		ply:ChatPrint("You already have that attachment.")
		return
	end--]]

	local placement = nil
	for plc, tbl in pairs(hg.attachments) do
		placement = tbl[att] and tbl[att][1] or placement
	end

	if not placement then return end
	if wep.attachments[placement][1] != att then return end
	if table.IsEmpty(wep.attachments[placement]) or wep.attachments[placement][1] == "empty" then return end
	if wep.availableAttachments[placement].cannotremove then return end
	ply.inventory.Attachments[#ply.inventory.Attachments + 1] = att
	local i
	for n, atta in pairs(wep.availableAttachments[placement]) do
		i = istable(atta) and atta[1] == "empty" and n or i
	end
	
	wep:AttachAnim()
	timer.Simple(0.5, function()
		if IsValid(wep) then
			if wep.attachments[placement][1] != att then return end
			wep.attachments[placement] = i and wep.availableAttachments[placement][i] or {}
			ply:SetNetVar("Inventory",ply.inventory)
			wep:SyncAtts()
			wep:EmitSound(attachsounds[math.random(#attachsounds)], 40)
		end
	end)
end)

net.Receive("ZB_AttachDrop", function(len, ply)
	local att = net.ReadString()
	local placement = nil
	for plc, tbl in pairs(hg.attachments) do
		placement = tbl[att] and tbl[att][1] or placement
	end

	if not placement then return end

	if not table.HasValue(ply.inventory["Attachments"],att) then return end

	if hg.attachments[placement][att] then
		local attEnt = ents.Create("ent_att_" .. att)
		attEnt:Spawn()
		attEnt:SetPos(ply:EyePos())
		attEnt:SetAngles(ply:EyeAngles())
		local phys = attEnt:GetPhysicsObject()
		if IsValid(phys) then phys:SetVelocity(ply:EyeAngles():Forward() * 100) end
		if IsValid(attEnt) then table.RemoveByValue(ply.inventory.Attachments, att) end
		ply:SetNetVar("Inventory",ply.inventory)
	end
end)

util.AddNetworkString("sync_atts")
util.AddNetworkString("sync_atts_ply")
local PLAYER = FindMetaTable("Player")
function SWEP:SyncAtts(ply)
	self:SetNetVar("attachments",self.attachments)
	self:SendNetVar("attachments")
end

net.Receive("sync_atts", function(len, ply)
	--local self = net.ReadEntity()
	--if self:GetOwner() != ply then return end

	--self:SyncAtts(ply)
end)