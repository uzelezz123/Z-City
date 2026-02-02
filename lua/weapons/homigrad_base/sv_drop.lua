hg = hg or {}

local vpang = Angle(1,-2,1)
local function drop(ply, wep, newWeapon, vel)
	local wep = isentity(wep) and wep or ply:GetActiveWeapon()
	if not IsValid(wep) or wep.NoDrop then return end
	if ply:GetNWFloat("willsuicide", 0) > 0 then return end -- you cant escape.
	local eyeAngles = ply:LocalEyeAngles()
	local isWep = wep.ismelee2 or ishgweapon(wep)
	ply:DoAnimationEvent(ACT_GMOD_GESTURE_MELEE_SHOVE_1HAND)
	ply:ViewPunch(vpang)
	timer.Simple(isWep and 0.0 or 0.0,function()
		if not IsValid(ply) or not IsValid(wep) then return end
		local pos, ang
		
		if wep.WorldModel_Transform then
			pos, ang = wep:WorldModel_Transform(true)
		end
		
		if not IsValid(newWeapon) then
			ply:SelectWeapon("weapon_hands_sh")
			ply:SetActiveWeapon(ply:GetWeapon("weapon_hands_sh"))
		else
			ply:SelectWeapon(newWeapon:GetClass())
			ply:SetActiveWeapon(newWeapon)
		end

		ply:DropWeapon(wep, nil, not IsValid(wep.fakeGun) and (eyeAngles:Forward() * (isnumber(vel) and vel or 250)) + ply:GetVelocity() or nil)
		
		wep.init = true
		wep.IsSpawned = true

		timer.Simple(0,function()
			if pos and ang then
				local tr = {}
				tr.start = ply:EyePos()
				tr.endpos = pos
				tr.filter = {ply,wep}
				tr.mask = MASK_SOLID
				local tr = util.TraceLine(tr)
				if tr.Hit then pos = ply:EyePos() end
				wep:SetPos(pos)
				wep:SetAngles(ang)
			end
		end)

		ply:ViewPunch(Angle(-1,5,-2))
		wep:SetOwner()
		if IsValid(wep.fakeGun) then wep:RemoveFake() end	
	end)
end

hg.drop = drop

concommand.Add("drop", drop)
concommand.Add("dropweapon", drop)
concommand.Add("-drop", drop)
concommand.Add("-dropweapon", drop)
local whitelist = {
	["*drop"] = true,
	["/drop"] = true,
	["!drop"] = true
}

hook.Add("PlayerSay", "homigrad-drop-weapons", function(ply, text)
	if whitelist[text] then
		drop(ply)
		return ""
	end
end)